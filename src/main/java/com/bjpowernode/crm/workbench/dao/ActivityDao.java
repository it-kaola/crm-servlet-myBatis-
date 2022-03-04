package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Activity;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ActivityDao {

    // 保存新增的市场活动信息
    int saveMarketActivity(Activity activityObj);

    int queryTotalByCondition(Map<String, Object> map);

    List<Activity> queryMarketActivitiesByCondition(Map<String, Object> map);

    int deleteMarketActivity(String[] ids);

    Activity queryOneActivity(String id);

    int updateMarketActivity(Activity activityObj);

    Activity getActDetailById(String id);

    List<Activity> getActListByClueId(String clueId);

    List<Activity> getActListByNameAndNotByClueId(@Param("activityName") String actName, @Param("clueId") String clueId);

    List<Activity> getActListByName(String actName);
}
