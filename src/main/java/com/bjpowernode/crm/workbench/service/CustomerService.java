package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    PagenationVO<Customer> queryCustomers(Map<String, Object> map);

    List<String> getCustomerName(String name);
}
