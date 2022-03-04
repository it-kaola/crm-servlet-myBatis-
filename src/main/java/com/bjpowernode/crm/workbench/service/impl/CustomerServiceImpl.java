package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.dao.CustomerDao;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.service.CustomerService;

import java.util.List;
import java.util.Map;

public class CustomerServiceImpl implements CustomerService {

    CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);

    @Override
    public PagenationVO<Customer> queryCustomers(Map<String, Object> map) {

        // 根据条件查询用户列表
        List<Customer> customerList = customerDao.getCustomerByCondition(map);

        // 根据条件查询用户列表的数量
        int total = customerDao.getTotalByCondition(map);

        // 创建视图对象，封装数据
        PagenationVO<Customer> pagenationVO = new PagenationVO<>();
        pagenationVO.setDataList(customerList);
        pagenationVO.setTotal(total);

        return pagenationVO;
    }

    @Override
    public List<String> getCustomerName(String name) {

        List<String> customerNames = customerDao.getCustomerName(name);

        return customerNames;
    }
}