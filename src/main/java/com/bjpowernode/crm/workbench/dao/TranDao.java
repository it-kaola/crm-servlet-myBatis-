package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int saveTransaction(Tran transaction);

    List<Customer> getTranByCondition(Map<String, Object> map);

    int getTotalByCondition(Map<String, Object> map);

    Tran getTransactionById(String id);

    int updateTransaction(Tran transaction);

    int getTotal();

    List<Map<String, String>> getDataList();
}
