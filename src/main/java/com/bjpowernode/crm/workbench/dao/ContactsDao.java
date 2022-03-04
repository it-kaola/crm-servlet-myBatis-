package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Contacts;

import java.util.List;
import java.util.Map;

public interface ContactsDao {

    int saveContacts(Contacts contacts);

    List<Contacts> getContactsByCondition(Map<String, Object> map);

    int getContactsTotalByCondition(Map<String, Object> map);

    List<Contacts> getContactsList(String fullname);
}
