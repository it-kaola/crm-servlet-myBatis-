package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.DateTimeToStrTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.dao.*;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.ClueService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

// 目标类对象

public class ClueServiceImpl implements ClueService {

    // 用户相关的表
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    // 线索相关的表
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
    private ClueRemarkDao clueRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ClueRemarkDao.class);
    private ClueActivityRelationDao clueActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);

    // 客户相关的表
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);

    // 联系人相关的表
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private ContactsRemarkDao contactsRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    private ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);

    // 交易相关的表
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);

    @Override
    public boolean saveClue(Clue clue) {

        boolean flag = false;

        int count = clueDao.saveClue(clue);

        if(count == 1){
            flag = true;
        }

        return flag;
    }


    @Override
    public PagenationVO<Clue> queryClues(Map<String, Object> map) {

        // 根据条件查询出符合条件的记录数量（若条件全为空则查询所有记录）
        int total = clueDao.queryCluesNumByCondition(map);

        // 根据条件查询出符合条件的线索（若条件全为空则查询所有线索）
        List<Clue> clueList = clueDao.queryCluesByCondition(map);

        // 创建PagenationVO对象，封装由数据库查到的数据
        PagenationVO<Clue> pagenationVO = new PagenationVO<>();

        pagenationVO.setTotal(total);
        pagenationVO.setDataList(clueList);

        return pagenationVO;
    }


    @Override
    public boolean deleteClue(String[] ids) {
        boolean flag = false;

        // 先查询线索备注表，查询要删除的线索关联了几条备注信息
        int count1 = clueRemarkDao.queryClueRemarkNum(ids);

        // 先删除关联的线索备注
        int count2 = clueRemarkDao.deleteClueRemark(ids);

        if(count1 == count2){
            flag = true;
        }

        // 删除线索
        int count3 = clueDao.deleteClue(ids);

        if(count3 == ids.length){
            flag = true;
        }else{
            flag = false;
        }

        return flag;
    }


    @Override
    public Map<String, Object> getUserListAndClue(String clueId) {

        // 查询用户信息列表
        List<User> userList = userDao.queryUserList();

        // 根据线索id查询指定线索
        Clue clue = clueDao.getClueById(clueId);

        // 创建map集合封装数据
        Map<String, Object> map = new HashMap<>();
        map.put("userList", userList);
        map.put("clueObj", clue);

        return map;
    }

    @Override
    public boolean updateClue(Clue clue) {
        boolean flag = true;

        int count = clueDao.updateClue(clue);

        if(count != 1){
            flag = false;
        }

        return flag;
    }


    @Override
    public Clue showClueDetail(String id) {

        Clue clue = clueDao.getOneClue(id);

        return clue;
    }


    @Override
    public boolean debundClueAndAct(String id) {

        boolean flag = false;

        int count = clueActivityRelationDao.debundClueAndAct(id);

        if(count == 1){
            flag = true;
        }

        return flag;
    }


    @Override
    public boolean bundClueAndAct(String clueId, String[] actIds) {
        boolean flag = true;

        // 循环插入数据
        for(String actId : actIds){
            // 创建市场活动和线索的关系对象
            ClueActivityRelation clueActivityRelation = new ClueActivityRelation();
            clueActivityRelation.setId(UUIDUtil.getUUID());
            clueActivityRelation.setClueId(clueId);
            clueActivityRelation.setActivityId(actId);
            // 连接数据库，插入相关记录
            int count = clueActivityRelationDao.bundClueAndAct(clueActivityRelation);
            if(count != 1){
                flag = false;
            }
        }

        return flag;
    }


    @Override
    public boolean convertClue(String clueId, String createBy, Tran transaction) {

        String createTime = DateTimeToStrTimeUtil.getStrTime();

        boolean flag = true;

        // 1. 根据传过来线索的id查询出对应的线索对象，方便后面步骤的转换
        Clue clue = clueDao.getClueById(clueId);

        // 2. 根据第一步得到的线索对象中的公司属性，连接数据库，精确查询客户表中是否存在对应的记录，如果客户表中没有相应记录，添加客户记录；如果已存在相应记录，不做任何操作
        String company = clue.getCompany();
        // 连接数据库，查询客户，这里应该返回一个Customer对象，方便后面的操作
        Customer customer = customerDao.getCustomerByName(company);
        if(customer == null){
            // 如果Customer对象为空，说明数据库中没有相应的客户记录，应该创建一条新的记录

            customer = new Customer();

            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(clue.getOwner());
            customer.setName(company);
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setCreateBy(createBy);
            customer.setCreateTime(createTime);
            customer.setDescription(clue.getDescription());
            customer.setAddress(clue.getAddress());

            // 连接数据库，向表中添加一条客户记录
            int count1 = customerDao.saveCustomer(customer);

            if(count1 != 1){
                flag = false;
            }
        }

        /*经过第2步后，客户信息已经拥有了，将来在处理其他表时，如果要使用到客户的id，可以直接通过customer对象获取*/

        // 3. 通过第1步得到的线索对象中的信息，创建联系人，并保存到数据库中
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setOwner(clue.getOwner());
        contacts.setSource(clue.getSource());
        contacts.setCustomerId(customer.getId());
        contacts.setFullname(clue.getFullname());
        contacts.setAppellation(clue.getAppellation());
        contacts.setEmail(clue.getEmail());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setCreateBy(createBy);
        contacts.setCreateTime(DateTimeToStrTimeUtil.getStrTime());
        contacts.setDescription(clue.getDescription());
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setAddress(clue.getAddress());
        // 连接数据库，添加联系人的记录
        int count2 = contactsDao.saveContacts(contacts);
        if(count2 != 1){
            flag = false;
        }

        /*经过第3步后，联系人信息已经拥有了，将来在处理其他表时，如果要使用到联系人的id，可以直接通过contacts对象获取*/


        // 4. 将线索备注转换到客户备注以及联系人备注
        // 根据clueId查询出对应的线索备注
        List<ClueRemark> clueRemarkList = clueRemarkDao.getClueRemarkListByClueId(clueId);
        // 遍历线索列表
        for(ClueRemark clueRemark : clueRemarkList){
            // 取出备注信息
            String noteContent = clueRemark.getNoteContent();

            // 创建客户备注对象，添加备注，向数据库中插入该条记录
            CustomerRemark customerRemark = new CustomerRemark();
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setNoteContent(noteContent);
            customerRemark.setCreateBy(createBy);
            customerRemark.setCreateTime(createTime);
            customerRemark.setEditFlag("0");
            customerRemark.setCustomerId(customer.getId());
            // 向数据库中插入该条记录
            int count3 = customerRemarkDao.saveCustomerRemark(customerRemark);

            if(count3 != 1){
                flag = false;
            }

            // 创建联系人备注对象，添加备注，向数据库中插入该条记录
            ContactsRemark contactsRemark = new ContactsRemark();
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setNoteContent(noteContent);
            contactsRemark.setCreateBy(createBy);
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setEditFlag("0");
            contactsRemark.setContactsId(contacts.getId());
            // 向数据库中插入该条记录
            int count4 = contactsRemarkDao.saveContactsRemark(contactsRemark);

            if(count4 != 1){
                flag = false;
            }
        }

        // 5. 将"线索和市场活动"的关系转移到"联系人和市场活动"的关系
        // 通过clueId查询到该线索关联的市场活动关系列表
        List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getClueActRelationList(clueId);
        // 遍历线索关联的市场活动关系列表
        for(ClueActivityRelation clueActivityRelation : clueActivityRelationList){
            // 获取到关联的市场活动的id
            String activityId = clueActivityRelation.getActivityId();

            // 创建市场活动与联系人关系的对象
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setContactsId(contacts.getId());
            contactsActivityRelation.setActivityId(activityId);
            // 连接数据库，插入该条记录
            int count5 = contactsActivityRelationDao.saveContactsActRelation(contactsActivityRelation);

            if(count5 != 1){
                flag = false;
            }
        }

        // 6. 如果交易对象不为null，则说明要添加一条交易记录
        if(transaction != null){
            // transaction对象已经在controller中封装好了一些数据了，如 id name money expectedDate stage activityId createTime createBy
            // 这里可以根据第1步查询到的线索对象，进一步完善交易信息
            transaction.setSource(clue.getSource());
            transaction.setOwner(clue.getOwner());
            transaction.setNextContactTime(clue.getNextContactTime());
            transaction.setDescription(clue.getDescription());
            transaction.setContactsId(contacts.getId());
            transaction.setCustomerId(customer.getId());
            transaction.setContactSummary(clue.getContactSummary());
            // 将该条记录存入数据库中
            int count6 = tranDao.saveTransaction(transaction);

            if(count6 != 1){
                flag = false;
            }

            // 7. 如果创建了交易，则创建一条与该交易关联的交易历史，交易与交易历史的关系是一对多的关系，一条交易记录对应多条交易历史
            TranHistory tranHistory = new TranHistory();

            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setCreateBy(createBy);
            tranHistory.setCreateTime(createTime);
            tranHistory.setExpectedDate(transaction.getExpectedDate());
            tranHistory.setMoney(transaction.getMoney());
            tranHistory.setStage(transaction.getStage());
            tranHistory.setTranId(transaction.getId());
            // 向数据库添加一条交易历史记录
            int count7 = tranHistoryDao.saveTranHistory(tranHistory);

            if(count7 != 1){
                flag = false;
            }
        }

        // 8. 删除线索备注
        String[] clueIds = {clueId};
        int count8 = clueRemarkDao.deleteClueRemark(clueIds);
        if(count8 != clueRemarkList.size()){
            flag = false;
        }

        // 9. 通过clueId删除市场活动和备注的关系
        int count9 = clueActivityRelationDao.deleteClueActivityRelation(clueId);
        if(count9 != clueActivityRelationList.size()){
            flag = false;
        }

        // 10. 删除线索
        int count10 = clueDao.deleteClue(clueIds);
        if(count10 != clueIds.length){
            flag = false;
        }

        return flag;
    }




}
