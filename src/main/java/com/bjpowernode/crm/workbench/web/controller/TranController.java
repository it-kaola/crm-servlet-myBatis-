package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.DateTimeToStrTimeUtil;
import com.bjpowernode.crm.utils.ObjectToJsonUtil;
import com.bjpowernode.crm.utils.ProxyUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.ContactsService;
import com.bjpowernode.crm.workbench.service.CustomerService;
import com.bjpowernode.crm.workbench.service.TranService;
import com.bjpowernode.crm.workbench.service.impl.ActivityServiceImpl;
import com.bjpowernode.crm.workbench.service.impl.ContactsServiceImpl;
import com.bjpowernode.crm.workbench.service.impl.CustomerServiceImpl;
import com.bjpowernode.crm.workbench.service.impl.TranServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String urlPattern = request.getServletPath();

        if("/workbench/transaction/queryTransaction.do".equals(urlPattern)){
            queryTransaction(request, response);
        }else if("/workbench/transaction/createTran.do".equals(urlPattern)){
            createTran(request, response);
        }else if("/workbench/transaction/getCustomerName.do".equals(urlPattern)){
            getCustomerName(request, response);
        }else if("/workbench/transaction/getActivityList.do".equals(urlPattern)){
            getActivityList(request, response);
        }else if("/workbench/transaction/getContactsList.do".equals(urlPattern)){
            getContactsList(request, response);
        }else if("/workbench/transaction/saveTransaction.do".equals(urlPattern)){
            saveTransaction(request, response);
        }else if("/workbench/transaction/showTranDetail.do".equals(urlPattern)){
            showTranDetail(request, response);
        }else if("/workbench/transaction/getTranHistoryListByTranId.do".equals(urlPattern)){
            getTranHistoryListByTranId(request, response);
        }else if("/workbench/transaction/changeStage.do".equals(urlPattern)){
            changeStage(request, response);
        }else if("/workbench/transaction/getChartData.do".equals(urlPattern)){
            getChartData(request, response);
        }
    }




    // 查询交易列表（连接查询+条件查询+模糊查询）
    private void queryTransaction(HttpServletRequest request, HttpServletResponse response) {
        // 获取前端传来的数据
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String customerId = request.getParameter("customerId");
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String contactsId = request.getParameter("contactsId");

        // 将页数和每页展示的记录数转成int类型
        int pageNo = Integer.parseInt(pageNoStr);
        int pageSize = Integer.parseInt(pageSizeStr);
        // 每页起始的记录数
        int startIndex = (pageNo-1)*pageSize;

        // 创建map集合，将前端传过来的数据封装起来，由控制器层向业务层传参
        Map<String, Object> map = new HashMap<>();
        map.put("pageSize", pageSize);
        map.put("startIndex", startIndex);
        map.put("name", name);
        map.put("owner", owner);
        map.put("customerId", customerId);
        map.put("stage", stage);
        map.put("type", type);
        map.put("source", source);
        map.put("contactsId", contactsId);

        // 创建代理对象
        TranService tranServiceProxy = (TranService) ProxyUtil.getProxyObj(new TranServiceImpl());

        PagenationVO<Customer> pagenationVO = tranServiceProxy.queryTransaction(map);

        // 将数据转成json格式，并写入响应体中
        ObjectToJsonUtil.objTojson(response, pagenationVO);
    }


    // 点击创建时，查出用户列表
    private void createTran(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 创建代理对象
        UserService userServiceProxy = (UserService) ProxyUtil.getProxyObj(new UserServiceImpl());

        List<User> userList = userServiceProxy.queryUserList();

        // 将数据存放在请求域中
        request.setAttribute("userList", userList);

        // 请求转发
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request, response);
    }


    // 通过模糊查询，查出相应的客户名称
    private void getCustomerName(HttpServletRequest request, HttpServletResponse response) {

        String name = request.getParameter("name");

        // 创建代理对象
        CustomerService customerServiceProxy = (CustomerService) ProxyUtil.getProxyObj(new CustomerServiceImpl());

        List<String> customerNames = customerServiceProxy.getCustomerName(name);

        // 将数据转为json格式并写入响应体中
        ObjectToJsonUtil.objTojson(response, customerNames);
    }


    // 通过模糊查询，查出市场活动列表
    private void getActivityList(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端传来的数据
        String actName = request.getParameter("actName");

        // 创建市场活动代理对象
        ActivityService activityServiceProxy = (ActivityService) ProxyUtil.getProxyObj(new ActivityServiceImpl());

        List<Activity> activityList = activityServiceProxy.getActListByName(actName);

        // 将数据转成json格式并写入响应体中
        ObjectToJsonUtil.objTojson(response, activityList);

    }


    // 通过模糊查询，查出联系人列表
    private void getContactsList(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端传过来的数据
        String fullname = request.getParameter("fullname");

        // 创建代理对象
        ContactsService contactsServiceProxy = (ContactsService) ProxyUtil.getProxyObj(new ContactsServiceImpl());

        List<Contacts> contactsList = contactsServiceProxy.getContactsList(fullname);

        // 将数据转成json格式并写入响应体中
        ObjectToJsonUtil.objTojson(response, contactsList);
    }


    // 保存交易信息，创建交易
    private void saveTransaction(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String money = request.getParameter("money");
        String name = request.getParameter("tranName");
        String expectedDate = request.getParameter("expectedDate");
        String customerName = request.getParameter("customerName"); // 注意：这里不是客户的id，而是客户的名字
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String activityId = request.getParameter("activityId");
        String contactsId = request.getParameter("contactsId");
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeToStrTimeUtil.getStrTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");

        // 创建交易对象
        Tran transaction = new Tran();

        transaction.setId(id);
        transaction.setOwner(owner);
        transaction.setMoney(money);
        transaction.setName(name);
        transaction.setExpectedDate(expectedDate);
        transaction.setStage(stage);
        transaction.setType(type);
        transaction.setSource(source);
        transaction.setActivityId(activityId);
        transaction.setContactsId(contactsId);
        transaction.setCreateBy(createBy);
        transaction.setCreateTime(createTime);
        transaction.setDescription(description);
        transaction.setContactSummary(contactSummary);
        transaction.setNextContactTime(nextContactTime);

        // 创建代理对象
        TranService tranServiceProxy = (TranService) ProxyUtil.getProxyObj(new TranServiceImpl());

        boolean flag = tranServiceProxy.saveTransaction(transaction, customerName);

        if(flag){
            // 重定向
            response.sendRedirect(request.getContextPath() + "/workbench/transaction/index.jsp");
        }

    }


    // 展示交易的详细信息
    private void showTranDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 获取前端传来的数据
        String id = request.getParameter("id");

        // 创建代理对象
        TranService tranServiceProxy = (TranService) ProxyUtil.getProxyObj(new TranServiceImpl());

        Tran transaction = tranServiceProxy.getTransactionById(id);

        // 获取交易的阶段
        String stage = transaction.getStage();
        // 从应用域中获取阶段与可能性的map集合
        Map<String, String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pMap");
        // 获取可能性
        String possibility = pMap.get(stage);
        // 将possibility传入transaction对象中
        transaction.setPossibility(possibility);

        // 将得到的数据存放在请求域中
        request.setAttribute("transaction", transaction);
        // 将可能性存入请求域中
        request.setAttribute("possibility", possibility);

        // 请求转发，跳转到详细信息页
        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request, response);

    }


    // 根据交易id获得交易历史列表
    private void getTranHistoryListByTranId(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端传来的数据
        String tranId = request.getParameter("tranId");

        // 创建代理对象
        TranService tranServiceProxy = (TranService) ProxyUtil.getProxyObj(new TranServiceImpl());

        List<TranHistory> tranHistoryList = tranServiceProxy.getTranHistoryListByTranId(tranId);

        // 阶段与可能性对应关系的map集合
        Map<String, String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pMap");

        for(TranHistory tranHistory : tranHistoryList){
            // 取得tranHistory对象对应的stage
            String stage = tranHistory.getStage();
            // 根据pMap取得对应的possibility
            String possibility = pMap.get(stage);
            // 将得到的possibility存入tranHistory对象的属性中
            tranHistory.setPossibility(possibility);
        }

        // 将数据转成json格式并写入响应体
        ObjectToJsonUtil.objTojson(response, tranHistoryList);
    }


    // 更改交易阶段，更新交易信息，并创建多一条交易历史
    private void changeStage(HttpServletRequest request, HttpServletResponse response) {

        // 获取从前端传来的数据
        String id = request.getParameter("id");
        String stage = request.getParameter("stage");
        // 以下两项数据是创建交易历史记录需要用到的
        String money = request.getParameter("money");
        String expectedDate = request.getParameter("expectedDate");

        String editBy = ((User) request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeToStrTimeUtil.getStrTime();

        // 将以上的数据封装成一个Tran对象
        Tran transaction = new Tran();

        transaction.setId(id);
        transaction.setStage(stage);
        transaction.setMoney(money);
        transaction.setExpectedDate(expectedDate);
        transaction.setEditTime(editTime);
        transaction.setEditBy(editBy);

        // 为transaction添加可能性
        Map<String, String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pMap");
        transaction.setPossibility(pMap.get(stage));

        // 创建代理对象
        TranService tranServiceProxy = (TranService) ProxyUtil.getProxyObj(new TranServiceImpl());

        boolean flag = tranServiceProxy.changeStage(transaction);

        // 创建map集合封装数据
        Map<String, Object> map = new HashMap<>();
        map.put("isSuccess", flag);
        map.put("TranObj", transaction);


        // 将数据转成json格式并写入响应体
        ObjectToJsonUtil.objTojson(response, map);

    }


    // 获取展示图表所需要的的数据
    private void getChartData(HttpServletRequest request, HttpServletResponse response) {

        // 创建代理对象
        TranService tranServiceProxy = (TranService) ProxyUtil.getProxyObj(new TranServiceImpl());

        // 使用map封装业务层处理后的数据
        Map<String, Object> map = tranServiceProxy.getChartData();

        // 将数据转成json格式并写入响应体中
        ObjectToJsonUtil.objTojson(response, map);
    }
}
