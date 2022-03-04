package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.DateTimeToStrTimeUtil;
import com.bjpowernode.crm.utils.ObjectToJsonUtil;
import com.bjpowernode.crm.utils.ProxyUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.Clue;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.ClueService;
import com.bjpowernode.crm.workbench.service.impl.ActivityServiceImpl;
import com.bjpowernode.crm.workbench.service.impl.ClueServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClueController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String urlPattern = request.getServletPath();

        if("/workbench/clue/queryUserList.do".equals(urlPattern)){
            queryUserList(request, response);
        }else if ("/workbench/clue/saveClue.do".equals(urlPattern)){
            saveClue(request, response);
        }else if ("/workbench/clue/queryClues.do".equals(urlPattern)){
            queryClues(request, response);
        }else if ("/workbench/clue/deleteClue.do".equals(urlPattern)){
            deleteClue(request, response);
        }else if ("/workbench/clue/getUserListAndClue.do".equals(urlPattern)){
            getUserListAndClue(request, response);
        }else if ("/workbench/clue/updateClue.do".equals(urlPattern)){
            updateClue(request, response);
        }else if ("/workbench/clue/showClueDetail.do".equals(urlPattern)){
            showClueDetail(request, response);
        }else if ("/workbench/clue/getActListByClueId.do".equals(urlPattern)){
            getActListByClueId(request, response);
        }else if ("/workbench/clue/debundClueAndAct.do".equals(urlPattern)){
            debundClueAndAct(request, response);
        }else if ("/workbench/clue/getActListByNameAndNotByClueId.do".equals(urlPattern)){
            getActListByNameAndNotByClueId(request, response);
        }else if ("/workbench/clue/bundClueAndAct.do".equals(urlPattern)){
            bundClueAndAct(request, response);
        }else if ("/workbench/clue/getActListByName.do".equals(urlPattern)){
            getActListByName(request, response);
        }else if ("/workbench/clue/convertClue.do".equals(urlPattern)){
            convertClue(request, response);
        }
    }



    // 查询用户列表
    private void queryUserList(HttpServletRequest request, HttpServletResponse response) {

        // 创建代理对象
        UserService userServiceProxy = (UserService) ProxyUtil.getProxyObj(new UserServiceImpl());

        List<User> userList = userServiceProxy.queryUserList(); // 实际执行的是TransactionInvocationHandler中的invoke()方法

        // 将数据转成json格式并写入响应体中
        ObjectToJsonUtil.objTojson(response,userList);

    }


    // 保存线索（添加线索）
    private void saveClue(HttpServletRequest request, HttpServletResponse response) {
        // 获取从前端传来的数据
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String appellation = request.getParameter("appellation");
        String fullname = request.getParameter("fullname");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");

        String id = UUIDUtil.getUUID();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeToStrTimeUtil.getStrTime();

        // 创建线索对象，封装数据
        Clue clue = new Clue();
        clue.setId(id);
        clue.setOwner(owner);
        clue.setCompany(company);
        clue.setAppellation(appellation);
        clue.setFullname(fullname);
        clue.setJob(job);
        clue.setEmail(email);
        clue.setPhone(phone);
        clue.setWebsite(website);
        clue.setMphone(mphone);
        clue.setState(state);
        clue.setSource(source);
        clue.setDescription(description);
        clue.setContactSummary(contactSummary);
        clue.setNextContactTime(nextContactTime);
        clue.setAddress(address);
        clue.setCreateBy(createBy);
        clue.setCreateTime(createTime);

        // 创建代理对象
        ClueService clueServiceProxy = (ClueService) ProxyUtil.getProxyObj(new ClueServiceImpl());

        boolean flag = clueServiceProxy.saveClue(clue);

        // 将数据转成json格式，并写入响应体中
        ObjectToJsonUtil.mapToJson(response, flag);

    }


    // 查询所有线索信息 （需要结合分页查询和条件查询（动态sql））
    private void queryClues(HttpServletRequest request, HttpServletResponse response) {

        // 获取从前端获得的数据
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String fullname = request.getParameter("fullname");
        String company = request.getParameter("company");
        String phone = request.getParameter("phone");
        String source = request.getParameter("source");
        String owner = request.getParameter("owner");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");

        // 将pageSize和pageNo转成int类型
        int pageNo = Integer.parseInt(pageNoStr);
        int pageSize = Integer.parseInt(pageSizeStr);

        // 计算每次分页的起始页
        int startIndex = (pageNo-1)*pageSize;

        // 创建map集合，封装数据
        Map<String, Object> map = new HashMap<>();
        map.put("startIndex", startIndex);
        map.put("pageSize", pageSize);
        map.put("fullname", fullname);
        map.put("company", company);
        map.put("phone", phone);
        map.put("source", source);
        map.put("owner", owner);
        map.put("mphone", mphone);
        map.put("state", state);

        // 创建代理对象
        ClueService clueServiceProxy = (ClueService) ProxyUtil.getProxyObj(new ClueServiceImpl());

        PagenationVO<Clue> pagenationVO = clueServiceProxy.queryClues(map);

        // 将数据转成json格式并写入响应体中
        ObjectToJsonUtil.objTojson(response, pagenationVO);

    }


    // 批量删除线索
    private void deleteClue(HttpServletRequest request, HttpServletResponse response) {
        // 获取从前端传来的数据
        String[] ids = request.getParameterValues("id");

        // 创建代理对象
        ClueService clueServiceProxy = (ClueService) ProxyUtil.getProxyObj(new ClueServiceImpl());

        boolean flag = clueServiceProxy.deleteClue(ids);

        ObjectToJsonUtil.mapToJson(response, flag);
    }


    // 获取修改信息(用户信息列表和需要修改的线索对象)
    private void getUserListAndClue(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端传来的数据
        String clueId = request.getParameter("clueId");

        // 创建线索的代理对象
        ClueService clueServiceProxy = (ClueService) ProxyUtil.getProxyObj(new ClueServiceImpl());

        Map<String, Object> map = clueServiceProxy.getUserListAndClue(clueId);

        // 将数据转成json格式，并写入响应体
        ObjectToJsonUtil.objTojson(response, map);

    }


    // 更新线索
    private void updateClue(HttpServletRequest request, HttpServletResponse response) {

        // 获取从前端传来的数据
        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String appellation = request.getParameter("appellation");
        String fullname = request.getParameter("fullname");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");

        String editBy = ((User) request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeToStrTimeUtil.getStrTime();

        // 创建线索对象，封装数据
        Clue clue = new Clue();
        clue.setId(id);
        clue.setOwner(owner);
        clue.setCompany(company);
        clue.setAppellation(appellation);
        clue.setFullname(fullname);
        clue.setJob(job);
        clue.setEmail(email);
        clue.setPhone(phone);
        clue.setWebsite(website);
        clue.setMphone(mphone);
        clue.setState(state);
        clue.setSource(source);
        clue.setDescription(description);
        clue.setContactSummary(contactSummary);
        clue.setNextContactTime(nextContactTime);
        clue.setAddress(address);
        clue.setCreateBy(editBy);
        clue.setCreateTime(editTime);

        // 创建代理对象
        ClueService clueServiceProxy = (ClueService) ProxyUtil.getProxyObj(new ClueServiceImpl());

        boolean flag = clueServiceProxy.updateClue(clue);

        // 将数据转成json格式并写入响应体中
        ObjectToJsonUtil.mapToJson(response, flag);

    }


    // 显示线索详细信息
    private void showClueDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 获取前端传递过来的值
        String id = request.getParameter("id");

        // 创建代理对象
        ClueService clueServiceProxy = (ClueService) ProxyUtil.getProxyObj(new ClueServiceImpl());

        Clue clue = clueServiceProxy.showClueDetail(id);

        // 将得到的线索对象放到请求域中
        request.setAttribute("clue", clue);

        // 请求转发，跳转到对应线索的详细信息页
        request.getRequestDispatcher("/workbench/clue/detail.jsp").forward(request, response);
    }


    // 根据线索id，获取对应线索关联的市场活动列表
    private void getActListByClueId(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端传过来的值
        String clueId = request.getParameter("clueId");

        // 创建市场活动的代理对象，因为获取的是市场活动列表信息
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        List<Activity> activityList = activityServiceProxy.getActListByClueId(clueId);

        ObjectToJsonUtil.objTojson(response, activityList);
    }


    // 根据关联关系表的id，解除线索与市场活动的关联关系
    private void debundClueAndAct(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端传过来的值
        String id = request.getParameter("id");

        // 创建代理对象
        ClueService clueServiceProxy = (ClueService) ProxyUtil.getProxyObj(new ClueServiceImpl());

        boolean flag = clueServiceProxy.debundClueAndAct(id);

        ObjectToJsonUtil.mapToJson(response, flag);
    }


    // 根据市场活动名称获取市场活动列表，并且展现的市场活动没有与当前线索关联过，已经与当前线索关联的市场不展示
    private void getActListByNameAndNotByClueId(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端传过来的数据
        String actName = request.getParameter("actName");
        String clueId = request.getParameter("clueId");

        // 创建市场活动的代理对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        List<Activity> activityList = activityServiceProxy.getActListByNameAndNotByClueId(actName, clueId);

        // 将数据转成json格式并写入响应体中
        ObjectToJsonUtil.objTojson(response, activityList);
    }


    // 为当前线索关联市场活动
    private void bundClueAndAct(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端传递过来的参数
        String clueId = request.getParameter("clueId");
        String[] actIds = request.getParameterValues("actId");

        // 创建代理对象
        ClueService clueServiceProxy = (ClueService) ProxyUtil.getProxyObj(new ClueServiceImpl());

        boolean flag = clueServiceProxy.bundClueAndAct(clueId, actIds);

        // 将数据转成json格式并写入响应体中
        ObjectToJsonUtil.mapToJson(response, flag);

    }


    // 根据市场活动名，获取并展现相应的市场活动列表
    private void getActListByName(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端传过来的数据
        String actName = request.getParameter("actName");

        // 创建市场活动的代理对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        List<Activity> activityList = activityServiceProxy.getActListByName(actName);

        // 将数据转成json格式，并写入响应体中
        ObjectToJsonUtil.objTojson(response, activityList);
    }


    // 执行线索转换的操作
    private void convertClue(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 获取从前端传递过来的数据
        String clueId = request.getParameter("clueId");
        // 创建人
        String createBy = ((User) request.getSession().getAttribute("user")).getName();

        // 从前端获取标记位，判断是否为空，如果不为空表示该请求需要创建交易记录
        String flag = request.getParameter("flag");

        // 创建一个交易对象，业务层根据这个交易对象是否为空，来判断是否需要向数据库添加交易记录
        Tran transaction = null;

        if(flag != null){
            // 不为空表示该请求需要创建交易记录

            transaction = new Tran();

            String money = request.getParameter("money"); // 交易金额
            String name = request.getParameter("name"); // 交易名称
            String expectedDate = request.getParameter("expectedDate"); // 预计成交日期
            String stage = request.getParameter("stage"); // 交易阶段
            String activityId = request.getParameter("activityId"); // 市场活动id
            String id = UUIDUtil.getUUID(); // 交易id
            String createTime = DateTimeToStrTimeUtil.getStrTime(); // 交易创建时间

            transaction.setId(id);
            transaction.setName(name);
            transaction.setMoney(money);
            transaction.setExpectedDate(expectedDate);
            transaction.setStage(stage);
            transaction.setActivityId(activityId);
            transaction.setCreateTime(createTime);
            transaction.setCreateBy(createBy);
        }

        // 创建代理对象
        ClueService clueServiceProxy = (ClueService) ProxyUtil.getProxyObj(new ClueServiceImpl());

        // 为业务层传递的参数：
        // 1. 必须传递一个clueId，这样我们才知道要转换哪条线索
        // 2. 必须传递一个交易对象transaction，通过这个交易对象是否为空来让业务层知道是否需要连接数据库添加交易记录
        // 3. 还需要传递一个创建人信息，因为线索的转换需要将线索的信息转换成客户和联系人的记录，还有可能需要添加交易记录，这些都需要创建人的信息
        boolean convertFlag = clueServiceProxy.convertClue(clueId, createBy, transaction);

        if(convertFlag){
            // 如果请求成功，convertFlag为true，重定向到线索展示页面
            response.sendRedirect(request.getContextPath() + "/workbench/clue/index.jsp");
        }
    }
}
