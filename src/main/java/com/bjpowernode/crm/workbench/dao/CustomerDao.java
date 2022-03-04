package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerDao {

    Customer getCustomerByName(String company);

    int saveCustomer(Customer customer);

    List<Customer> getCustomerByCondition(Map<String, Object> map);

    int getTotalByCondition(Map<String, Object> map);

    List<String> getCustomerName(String name);
}
