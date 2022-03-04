package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.utils.DateTimeToStrTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.dao.CustomerDao;
import com.bjpowernode.crm.workbench.dao.TranDao;
import com.bjpowernode.crm.workbench.dao.TranHistoryDao;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.domain.TranHistory;
import com.bjpowernode.crm.workbench.service.TranService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranServiceImpl implements TranService {

    // 交易相关的表
    TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);

    // 客户相关的表
    CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);

    @Override
    public PagenationVO<Customer> queryTransaction(Map<String, Object> map) {

        // 根据条件查询用户列表
        List<Customer> customerList = tranDao.getTranByCondition(map);

        // 根据条件查询用户列表的数量
        int total = tranDao.getTotalByCondition(map);

        // 创建视图对象，封装数据
        PagenationVO<Customer> pagenationVO = new PagenationVO<>();
        pagenationVO.setDataList(customerList);
        pagenationVO.setTotal(total);

        return pagenationVO;
    }


    @Override
    public boolean saveTransaction(Tran transaction, String customerName) {

        boolean flag = true;

        // 1. 首先根据customerName精确查询出数据库中是否有该客户的信息
        // 如果存在则直接使用该客户的id；如果不存在，则创建一个新的客户信息
        Customer customer = customerDao.getCustomerByName(customerName);

        if(customer == null){
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(transaction.getOwner());
            customer.setName(customerName);
            customer.setCreateBy(transaction.getCreateBy());
            customer.setCreateTime(DateTimeToStrTimeUtil.getStrTime());
            customer.setContactSummary(transaction.getContactSummary());
            customer.setNextContactTime(transaction.getNextContactTime());
            customer.setDescription(transaction.getDescription());
            // 向数据库中添加客户记录
            int count1 = customerDao.saveCustomer(customer);
            if(count1 != 1){
                return false;
            }
        }

        // 程序执行到此处，一定是有一个客户对象
        // 向交易对象添加客户id
        transaction.setCustomerId(customer.getId());

        // 2. 保存交易信息
        int count2 = tranDao.saveTransaction(transaction);

        if(count2 != 1){
            flag = false;
        }

        // 3. 添加交易历史信息
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setStage(transaction.getStage());
        tranHistory.setMoney(transaction.getMoney());
        tranHistory.setExpectedDate(transaction.getExpectedDate());
        tranHistory.setCreateTime(DateTimeToStrTimeUtil.getStrTime());
        tranHistory.setCreateBy(transaction.getCreateBy());
        tranHistory.setTranId(transaction.getId());

        int count3 = tranHistoryDao.saveTranHistory(tranHistory);

        if(count3 != 1){
            flag = false;
        }

        return flag;
    }


    @Override
    public Tran getTransactionById(String id) {

        Tran transaction = tranDao.getTransactionById(id);

        return transaction;
    }


    @Override
    public List<TranHistory> getTranHistoryListByTranId(String tranId) {

        List<TranHistory> tranHistoryList = tranHistoryDao.getTranHistoryListByTranId(tranId);

        return tranHistoryList;
    }


    @Override
    public boolean changeStage(Tran transaction) {

        boolean flag = true;

        // 连接数据库，更新交易记录
        int count1 = tranDao.updateTransaction(transaction);

        if(count1 != 1){
            flag = false;
        }

        // 生成一条交易记录
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setStage(transaction.getStage());
        tranHistory.setMoney(transaction.getMoney());
        tranHistory.setExpectedDate(transaction.getExpectedDate());
        tranHistory.setCreateTime(DateTimeToStrTimeUtil.getStrTime());
        tranHistory.setCreateBy(transaction.getEditBy());
        tranHistory.setTranId(transaction.getId());

        // 连接数据库，插入一条新的交易历史
        int count2 = tranHistoryDao.saveTranHistory(tranHistory);

        if(count2 != 1){
            flag = false;
        }

        return flag;
    }


    @Override
    public Map<String, Object> getChartData() {
        // 获取交易记录的总条数
        int total = tranDao.getTotal();

        // 获取对应阶段的交易记录的数量
        List<Map<String, String>> dataList = tranDao.getDataList();

        // 将数据封装成map集合
        Map<String, Object> map = new HashMap<>();
        map.put("total", total);
        map.put("dataList", dataList);

        // 返回map集合
        return map;

    }
}
