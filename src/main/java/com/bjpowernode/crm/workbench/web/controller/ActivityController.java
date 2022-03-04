package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.*;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.impl.ActivityServiceImpl;
import com.sun.org.apache.regexp.internal.RE;

import javax.jws.Oneway;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
* 相应模块的Servlet实现类
* */
public class ActivityController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String urlPattern = request.getServletPath();

        if("/workbench/activity/queryUserList.do".equals(urlPattern)){
            queryUserList(request, response);

        }else if("/workbench/activity/saveMarketActivity.do".equals(urlPattern)){
            saveMarketActivity(request, response);

        }else if("/workbench/activity/queryMarketActivities.do".equals(urlPattern)){
            queryMarketActivities(request, response);

        }else if("/workbench/activity/deleteMarketActivity.do".equals(urlPattern)){
            deleteMarketActivity(request, response);

        }else if("/workbench/activity/getUserListAndActivity.do".equals(urlPattern)){
            getUserListAndActivity(request, response);

        }else if("/workbench/activity/updateMarketActivity.do".equals(urlPattern)){
            updateMarketActivity(request, response);

        }else if("/workbench/activity/showActDetail.do".equals(urlPattern)){
            showActDetail(request, response);

        }else if("/workbench/activity/showActRemarkList.do".equals(urlPattern)){
            showActRemarkList(request, response);

        }else if("/workbench/activity/deleteOneActRemark.do".equals(urlPattern)){
            deleteOneActRemark(request, response);

        }else if("/workbench/activity/saveActRemark.do".equals(urlPattern)){
            saveActRemark(request, response);

        }else if("/workbench/activity/updateActRemark.do".equals(urlPattern)){
            updateActRemark(request, response);

        }
    }



    // 查询所有用户
    private void queryUserList(HttpServletRequest request, HttpServletResponse response) {
        // 创建代理类对象
        UserService userServiceProxy = (UserService) ProxyUtil.getProxyObj(new UserServiceImpl()); // 虽然这里是市场活动的控制器，但处理的业务是跟用户相关的，所以应该创建用户相关的代理类对象

        // 获取所有用户信息的列表
        List<User> userList = userServiceProxy.queryUserList();

        // 将userList通过jackson转换成json格式的数据
        ObjectToJsonUtil.objTojson(response, userList); // 该工具类已经将转换后的json格式的数据写入响应体中了
    }


    // 保存市场活动信息
    private void saveMarketActivity(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端传过来的参数
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");

        // 为传过来的市场活动对象生成一个唯一的uuid
        String id = UUIDUtil.getUUID();
        // 记录创建时间
        String createTime = DateTimeToStrTimeUtil.getStrTime();
        // 记录创建人
        String createBy = ((User) (request.getSession().getAttribute("user"))).getName();

        // 创建一个市场活动实体类对象
        Activity activityObj = new Activity();
        // 将前端传过来的值和id、createTime、createBy封装到该对象中
        activityObj.setId(id);
        activityObj.setOwner(owner);
        activityObj.setName(name);
        activityObj.setStartDate(startDate);
        activityObj.setEndDate(endDate);
        activityObj.setCost(cost);
        activityObj.setDescription(description);
        activityObj.setCreateTime(createTime);
        activityObj.setCreateBy(createBy);

        // 创建市场活动的代理对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        // 保存市场活动信息
        boolean flag = activityServiceProxy.saveMarketActivity(activityObj);

        ObjectToJsonUtil.mapToJson(response, flag);

    }


    // 查询市场活动列表（需要结合条件查询+分页查询）
    private void queryMarketActivities(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端发送过来的参数
        String pageNoStr = request.getParameter("pageNo"); // 页数
        String pageSizeStr = request.getParameter("pageSize"); // 每页展示的记录数
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        // 将页数和每页展示的记录数转成int类型
        int pageNo = Integer.parseInt(pageNoStr);
        int pageSize = Integer.parseInt(pageSizeStr);
        // 每页起始的记录数
        int startIndex = (pageNo-1)*pageSize;

        // 创建map集合，将前端传过来的数据封装起来，由控制器层向业务层传参
        Map<String, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);
        map.put("pageSize", pageSize);
        map.put("startIndex", startIndex);


        // 创建代理类对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());


        /*
        * 前端想要的数据是：
        *   1. 市场活动信息列表 2. 查询的总条数
        *   {"total" : 总记录条数, "dataList" : [{"id":?, "owner":?,....}, {市场活动2}, {市场活动3}.....]}
        * 经过业务层处理后，得到这两项数据，可以通过以下两种方式传递给控制层
        *   1. map： 如果数据是临时使用，使用map封装数据
        *   map.put("total", 总记录条数);
        *   map.put("activityList", List<Activity>);
        *
        *   2. VO：如果数据重复使用，使用VO封装数据
        *   pagenationVO<T>  // 注意：这里要使用泛型，方便其他模块也能使用该VO对象
        *       private int total;
        *       private List<T> dataList;
        * */


        PagenationVO<Activity> pagenationVO = activityServiceProxy.queryMarketActivities(map);

        // 将市场活动列表转成json格式的数据
        ObjectToJsonUtil.objTojson(response, pagenationVO);
    }


    // 删除市场活动信息
    private void deleteMarketActivity(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端传过来的请求
        String[] ids = request.getParameterValues("id");

        // 创建代理类对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        boolean flag = activityServiceProxy.deleteMarketActivity(ids);

        // 把由业务层传回来的数据转成json格式的数据，并写入响应体中
        ObjectToJsonUtil.mapToJson(response, flag);

    }


    // 获取修改信息（包括用户信息列表和需要修改的市场活动对象）
    private void getUserListAndActivity(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端发送过来的数据
        String id = request.getParameter("id");

        // 创建代理对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        // 总结：
        // controller调用service方法，应该返回什么值？
        // 这得看前端需要什么值，根据前端需要的值返回对应的数据即可
        // 在这个需求中，前端需要 UserList和activityObj
        // 这两个数据复用率不高，所以用map集合进行封装即可
        // 如果数据复用率高，考虑使用VO对象进行封装

        Map<String, Object> map = activityServiceProxy.getUserListAndActivity(id);

        // 将map集合转成json格式的数据，并写入响应体中
        ObjectToJsonUtil.objTojson(response, map);

    }


    // 修改市场活动信息
    private void updateMarketActivity(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端传过来的参数
        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");

        // 记录修改时间
        String editTime = DateTimeToStrTimeUtil.getStrTime();
        // 记录创建人
        String editBy = ((User) (request.getSession().getAttribute("user"))).getName();

        // 创建一个市场活动实体类对象
        Activity activityObj = new Activity();
        // 将前端传过来的值和 editTime、editBy封装到该对象中
        activityObj.setId(id);
        activityObj.setOwner(owner);
        activityObj.setName(name);
        activityObj.setStartDate(startDate);
        activityObj.setEndDate(endDate);
        activityObj.setCost(cost);
        activityObj.setDescription(description);
        activityObj.setEditTime(editTime);
        activityObj.setEditBy(editBy);

        // 创建市场活动的代理对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        // 更新市场活动信息
        boolean flag = activityServiceProxy.updateMarketActivity(activityObj);

        ObjectToJsonUtil.mapToJson(response, flag);
    }


    // 展示市场活动详细信息页
    private void showActDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 获取前端传递过来的参数
        String id = request.getParameter("id");

        // 创建代理类对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        Activity activity = activityServiceProxy.showActDetail(id);

        // 将获取到的市场活动对象放入请求域中
        request.setAttribute("activityObj", activity);

        // 请求转发，跳转到市场活动详细信息页，共享同一个请求域
        request.getRequestDispatcher("/workbench/activity/detail.jsp").forward(request,response);
    }


    // 展示市场活动的备注信息列表
    private void showActRemarkList(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端发过来的参数
        String activityId = request.getParameter("activityId");

        // 创建代理类对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        List<ActivityRemark> activityRemarkList = activityServiceProxy.getActRemarkList(activityId);

        // 将数据转成json格式并写入响应体中
        ObjectToJsonUtil.objTojson(response,activityRemarkList);
    }


    // 删除单条市场活动备注信息
    private void deleteOneActRemark(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端传递过来的参数
        String id = request.getParameter("id"); // 市场活动备注信息的id

        // 创建代理对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        boolean flag = activityServiceProxy.deleteOneActRemark(id);

        // 将结果转为json格式，写入响应体中
        ObjectToJsonUtil.mapToJson(response, flag);
    }


    // 添加市场活动备注信息
    private void saveActRemark(HttpServletRequest request, HttpServletResponse response) {
        // 获取从前端传递过来的参数
        String noteContent = request.getParameter("noteContent");
        String activityId = request.getParameter("activityId");

        String id = UUIDUtil.getUUID();
        String createTime = DateTimeToStrTimeUtil.getStrTime();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        String editFlag = "0";

        // 创建市场活动备注信息对象，封装数据
        ActivityRemark activityRemark = new ActivityRemark();

        activityRemark.setId(id);
        activityRemark.setNoteContent(noteContent);
        activityRemark.setCreateTime(createTime);
        activityRemark.setCreateBy(createBy);
        activityRemark.setEditFlag(editFlag);
        activityRemark.setActivityId(activityId);

        // 创建代理类对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        boolean flag = activityServiceProxy.saveActRemark(activityRemark);

        // 创建Map对象，存放多个值
        Map<String, Object> map = new HashMap<>();
        map.put("isSuccess", flag);
        map.put("actRemarkObj", activityRemark);

        // 将数据转成json格式，并写入相应体中
        ObjectToJsonUtil.objTojson(response, map);


    }


    // 更新市场活动备注信息
    private void updateActRemark(HttpServletRequest request, HttpServletResponse response) {
        // 获取由前端传来的参数
        String id = request.getParameter("id");
        String noteContent = request.getParameter("noteContent");

        String editFlag = "1";
        String editTime = DateTimeToStrTimeUtil.getStrTime();
        String editBy = ((User) request.getSession().getAttribute("user")).getName();

        // 创建ActivityRemark对象，封装数据
        ActivityRemark activityRemark = new ActivityRemark();

        activityRemark.setId(id);
        activityRemark.setNoteContent(noteContent);
        activityRemark.setEditFlag(editFlag);
        activityRemark.setEditTime(editTime);
        activityRemark.setEditBy(editBy);

        // 创建代理类对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        boolean flag = activityServiceProxy.updateActRemark(activityRemark);

        // 创建map集合，将数据封装到里面
        Map<String, Object> map = new HashMap<>();
        map.put("isSuccess", flag);
        map.put("actRemarkObj", activityRemark);

        // 将数据转成json格式，并写入响应体中
        ObjectToJsonUtil.objTojson(response, map);

    }

}
