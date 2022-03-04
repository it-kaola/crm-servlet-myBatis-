package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    int queryClueRemarkNum(String[] ids);

    int deleteClueRemark(String[] ids);

    List<ClueRemark> getClueRemarkListByClueId(String clueId);
}
