package com.bjpowernode.crm.settings.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.MD5Util;
import com.bjpowernode.crm.utils.ObjectToJsonUtil;
import com.bjpowernode.crm.utils.ProxyUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/*
* 相应模块的Servlet实现类
* */
public class UserController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String urlPattern = request.getServletPath();

        if("/settings/user/loginVerification.do".equals(urlPattern)){
            loginVerify(request, response);

        }else if("/settings/user/delete".equals(urlPattern)){
            // 执行相应操作

        }
    }

    // 实现登录验证
    private void loginVerify(HttpServletRequest request, HttpServletResponse response) {

        // 获取前端传来的参数
        String loginAct = request.getParameter("loginAct");
        String loginPwd = request.getParameter("loginPwd");
        // 获取浏览器的ip地址
        String ip = request.getRemoteAddr();

        // 将明文形式的密码转换为MD5加密后的密码格式
        loginPwd = MD5Util.getMD5(loginPwd);

        // 创建代理类对象
        UserService userServiceProxy = (UserService) ProxyUtil.getProxyObj(new UserServiceImpl());

        try{
            // 通过代理类对象访问目标类对象，再由目标类对象访问数据库，查询记录
            User user = userServiceProxy.loginVerify(loginAct, loginPwd, ip); // 实际执行的是TransactionInvocationHandler对象的invoke()方法

            // 将查询到的user对象放入会话域中
            request.getSession().setAttribute("user", user);

            // 程序能够执行到此处，说明账号和密码没有错误，在数据库中可以找到相关的记录
            // 此时应该向响应体中传入 {isSuccess:true}
            ObjectToJsonUtil.mapToJson(response, true); // 该工具类已经将结果写入响应体中

        }catch (Exception e){
            e.printStackTrace();

            // 程序能够执行到此处，说明数据库中没有相关记录
            // 此时应该向响应体中传入 {isSuccess:false, errorMsg:"相应的错误提示消息"}

            // 对于以上格式的json数据，我们有两种方式来进行处理
                // 1. 将多项数据封装成map集合，再使用jackson转换成对应的json格式数据
                // 2. 创建一个VO（view object）对象，再使用jackson转换成对应的json格式数据
                        // private boolean isSuccess;
                        // private String errorMsg;

                // 如果对于展示的数据将来需要经常性的重复使用，则创建一个VO类
                // 如果于展示的数据只是临时需要，利用map集合封装即可

            String errorMsg = e.getMessage();
            Map<String, Object> map = new HashMap<>();
            map.put("isSuccess", false);
            map.put("errorMsg", errorMsg);
            // 将map集合转为json格式的数据，并写入响应体中
            ObjectToJsonUtil.objTojson(response, map);
        }



    }
}
