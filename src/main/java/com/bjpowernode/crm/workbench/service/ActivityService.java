package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityService {

    boolean saveMarketActivity(Activity activityObj);

    PagenationVO<Activity> queryMarketActivities(Map<String, Object> map);

    boolean deleteMarketActivity(String[] ids);

    Map<String, Object> getUserListAndActivity(String id);

    boolean updateMarketActivity(Activity activityObj);

    Activity showActDetail(String id);

    List<ActivityRemark> getActRemarkList(String activityId);

    boolean deleteOneActRemark(String id);

    boolean saveActRemark(ActivityRemark activityRemark);

    boolean updateActRemark(ActivityRemark activityRemark);

    List<Activity> getActListByClueId(String clueId);

    List<Activity> getActListByNameAndNotByClueId(String actName, String clueId);

    List<Activity> getActListByName(String actName);
}
