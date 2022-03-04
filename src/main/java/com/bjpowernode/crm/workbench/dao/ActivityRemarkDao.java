package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ActivityRemarkDao {

    int queryDelActRemarkCount(String[] ids);

    int deleteActRemark(String[] ids);

    List<ActivityRemark> getActRemarkList(String activityId);

    int deleteOneActRemark(String id);

    int saveActRemark(ActivityRemark activityRemark);

    int updateActRemark(ActivityRemark activityRemark);
}
