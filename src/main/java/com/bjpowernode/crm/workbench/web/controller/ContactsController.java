package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.utils.ObjectToJsonUtil;
import com.bjpowernode.crm.utils.ProxyUtil;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.service.ContactsService;
import com.bjpowernode.crm.workbench.service.impl.ContactsServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class ContactsController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String urlPattern = request.getServletPath();

        if("/workbench/contacts/queryContacts.do".equals(urlPattern)){
            queryContacts(request, response);
        }
    }


    // 查询联系人（条件查询+模糊查询）
    private void queryContacts(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端传来的数据
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String owner = request.getParameter("owner");
        String fullname = request.getParameter("fullname");
        String source = request.getParameter("source");
        String customerId = request.getParameter("customerId");
        String birth = request.getParameter("birth");

        // 将pageNoStr和pageSizeStr转成int类型
        int pageNo = Integer.parseInt(pageNoStr);
        int pageSize = Integer.parseInt(pageSizeStr);
        // 计算起始记录
        int startIndex = (pageNo-1)*pageSize;

        // 创建map集合，封装前端传来的数据
        Map<String, Object> map = new HashMap<>();

        map.put("startIndex", startIndex);
        map.put("pageSize", pageSize);
        map.put("owner", owner);
        map.put("fullname", fullname);
        map.put("source", source);
        map.put("customerId", customerId);
        map.put("birth", birth);

        // 创建代理对象
        ContactsService contactsServiceProxy = (ContactsService) ProxyUtil.getProxyObj(new ContactsServiceImpl());

        PagenationVO<Contacts> pagenationVO = contactsServiceProxy.queryContacts(map);

        // 将数据转换为json格式并写入响应体中
        ObjectToJsonUtil.objTojson(response, pagenationVO);

    }
}
