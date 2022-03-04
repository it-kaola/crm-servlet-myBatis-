package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.dao.ContactsDao;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.service.ContactsService;

import java.util.List;
import java.util.Map;

public class ContactsServiceImpl implements ContactsService {

    ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);

    @Override
    public PagenationVO<Contacts> queryContacts(Map<String, Object> map) {

        // 根据条件，查询出联系人列表
        List<Contacts> contactsList = contactsDao.getContactsByCondition(map);

        // 根据条件，查询出联系人的数量
        int total = contactsDao.getContactsTotalByCondition(map);

        // 创建视图层对象，封装数据
        PagenationVO<Contacts> pagenationVO = new PagenationVO<>();
        pagenationVO.setTotal(total);
        pagenationVO.setDataList(contactsList);

        return pagenationVO;

    }


    @Override
    public List<Contacts> getContactsList(String fullname) {

        List<Contacts> contactsList = contactsDao.getContactsList(fullname);

        return contactsList;

    }
}
