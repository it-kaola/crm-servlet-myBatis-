package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.dao.ActivityDao;
import com.bjpowernode.crm.workbench.dao.ActivityRemarkDao;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityService;
import org.apache.ibatis.annotations.Param;

import javax.jws.Oneway;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/*
* 目标类对象
* */

public class ActivityServiceImpl implements ActivityService {

    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);


    @Override
    public boolean saveMarketActivity(Activity activityObj) {

        boolean flag = false;

        // 连接数据库，保存市场活动信息
        int count = activityDao.saveMarketActivity(activityObj);

        if(count == 1){
            // 程序执行到此处说明，信息插入成功
            flag = true;
            return flag;
        }

        return flag;
    }


    @Override
    public PagenationVO<Activity> queryMarketActivities(Map<String, Object> map) {

        // 取得总记录条数 total
        int total = activityDao.queryTotalByCondition(map);

        // 取得每页查询到的数据列表
        List<Activity> activityList = activityDao.queryMarketActivitiesByCondition(map);

        // 将以上两项数据封装到pagenationVO对象中
        PagenationVO<Activity> pagenationVO = new PagenationVO<>();
        pagenationVO.setTotal(total);
        pagenationVO.setDataList(activityList);

        // 返回VO对象
        return pagenationVO;
    }


    @Override
    public boolean deleteMarketActivity(String[] ids) {

        boolean flag = true;

        // 因为市场活动信息与市场活动备注表是一对多的关系，在执行删除操作的时候，需要先删除关系为多的表，即先删除市场活动备注信息再删除市场活动信息

        // 1. 先查询需要删除的市场活动备注有几条，方便判断最后是否删除成功
        int count1 = activityRemarkDao.queryDelActRemarkCount(ids);

        // 2. 执行删除操作，删除市场活动备注信息
        int count2 = activityRemarkDao.deleteActRemark(ids);

        if(count1 != count2){
            // 如果两个结果不相等，证明这个删除行为是有问题的
            flag = false;
        }

        // 3. 最后删除市场活动信息
        int count3 = activityDao.deleteMarketActivity(ids);

        if(count3 != ids.length){
            // 控制器传来的ids数组的长度就是需要删除的市场活动信息的数量，如果影响记录的条数与ids数组的长度不一致，说明这个删除行为是有问题的
            flag = false;
        }

        return flag;
    }


    @Override
    public Map<String, Object> getUserListAndActivity(String id) {
        // 查询用户信息列表
        List<User> userList = userDao.queryUserList();

        // 根据id查询对应的市场活动信息
        Activity activity = activityDao.queryOneActivity(id);

        // 创建map集合，封装前面获得的数据
        Map<String, Object> map = new HashMap<>();
        map.put("userList", userList);
        map.put("activityObj", activity);

        // 返回map集合
        return map;
    }


    @Override
    public boolean updateMarketActivity(Activity activityObj) {
        boolean flag = false;

        // 连接数据库，保存市场活动信息
        int count = activityDao.updateMarketActivity(activityObj);

        if(count == 1){
            // 程序执行到此处说明，信息插入成功
            flag = true;
            return flag;
        }

        return flag;
    }


    @Override
    public Activity showActDetail(String id) {

        // 根据id查询市场活动信息
        // 这里不能使用Dao层的queryOneActivity方法，因为queryOneActivity方法查询出来的owner字段是用户表的id值
        // 这里需要用到表的连接查询
        Activity activity = activityDao.getActDetailById(id);

        return activity;
    }


    @Override
    public List<ActivityRemark> getActRemarkList(String activityId) {

        List<ActivityRemark> activityRemarkList = activityRemarkDao.getActRemarkList(activityId);

        return activityRemarkList;
    }


    @Override
    public boolean deleteOneActRemark(String id) {

        boolean flag = false;

        int count = activityRemarkDao.deleteOneActRemark(id);

        if(count == 1){
            flag = true;
        }

        return flag;
    }


    @Override
    public boolean saveActRemark(ActivityRemark activityRemark) {

        boolean flag = false;

        int count = activityRemarkDao.saveActRemark(activityRemark);

        if(count == 1){
            flag = true;
        }

        return flag;
    }


    @Override
    public boolean updateActRemark(ActivityRemark activityRemark) {

        boolean flag = false;

        int count = activityRemarkDao.updateActRemark(activityRemark);

        if(count == 1){
            flag = true;
        }

        return flag;
    }


    @Override
    public List<Activity> getActListByClueId(String clueId) {

        List<Activity> activityList = activityDao.getActListByClueId(clueId);

        return activityList;
    }


    @Override
    public List<Activity> getActListByNameAndNotByClueId(String actName, String clueId) {

        List<Activity> activityList = activityDao.getActListByNameAndNotByClueId(actName, clueId);

        return activityList;
    }


    @Override
    public List<Activity> getActListByName(String actName) {

        List<Activity> activityList = activityDao.getActListByName(actName);

        return activityList;
    }

}
