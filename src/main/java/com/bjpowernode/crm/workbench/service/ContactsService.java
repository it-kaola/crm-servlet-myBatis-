package com.bjpowernode.crm.workbench.service;


import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.Contacts;

import java.util.List;
import java.util.Map;

public interface ContactsService {
    PagenationVO<Contacts> queryContacts(Map<String, Object> map);

    List<Contacts> getContactsList(String fullname);
}
