package com.bjpowernode.crm.web.filter;

/*
* 功能：拦截恶意登录行为，即向浏览器地址栏上直接输入相应的url地址，跳过用户身份验证环节
* */

import com.bjpowernode.crm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        // 向下转型
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        // 获取uri
        String uri = request.getRequestURI();
        // 如果uri为：/crm/login.jsp 或 /crm/settings/user/loginVerification.do 应该放行
        if((request.getContextPath()+"/login.jsp").equals(uri) || (request.getContextPath()+"/settings/user/loginVerification.do").equals(uri)){
            filterChain.doFilter(servletRequest,servletResponse);
        }else{

            // 获取当前请求用户的Session域对象
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            // 通过session域中有无user对象判断当前用户是否存在恶意登录的行为
            if(user != null){
                // 程序执行到此处说明该用户已经先经过登录验证了，可以放行
                filterChain.doFilter(servletRequest, servletResponse);
            }else{
                // 程序执行到此处说明该用户未经过登录验证试图直接访问服务器资源，应该跳转到登录界面
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
        }

    }
}
