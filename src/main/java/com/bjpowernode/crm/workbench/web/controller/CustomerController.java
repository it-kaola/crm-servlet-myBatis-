package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.utils.ObjectToJsonUtil;
import com.bjpowernode.crm.utils.ProxyUtil;
import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.service.CustomerService;
import com.bjpowernode.crm.workbench.service.impl.ClueServiceImpl;
import com.bjpowernode.crm.workbench.service.impl.CustomerServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class CustomerController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String urlPattern = request.getServletPath();

        if("/workbench/customer/queryCustomers.do".equals(urlPattern)){
            queryCustomers(request, response);
        }
    }


    // 查询所有客户（条件查询+连接查询）
    private void queryCustomers(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端传来的数据
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");

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
        map.put("phone", phone);
        map.put("website", website);

        // 创建代理对象
        CustomerService customerServiceProxy = (CustomerService) ProxyUtil.getProxyObj(new CustomerServiceImpl());

        PagenationVO<Customer> pagenationVO = customerServiceProxy.queryCustomers(map);

        // 将数据转成json格式，并写入响应体中
        ObjectToJsonUtil.objTojson(response, pagenationVO);

    }
}
