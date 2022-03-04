package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.domain.TranHistory;

import java.util.List;
import java.util.Map;

public interface TranService {
    PagenationVO<Customer> queryTransaction(Map<String, Object> map);

    boolean saveTransaction(Tran transaction, String customerName);

    Tran getTransactionById(String id);

    List<TranHistory> getTranHistoryListByTranId(String tranId);

    boolean changeStage(Tran transaction);

    Map<String, Object> getChartData();
}
