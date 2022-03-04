package com.bjpowernode.crm.web.filter;

import javax.servlet.*;
import java.io.IOException;

/*
* 添加过滤器，设置请求体和响应体的编码方式
* */

public class EncodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {

        // 过滤post请求的中文乱码
        servletRequest.setCharacterEncoding("utf-8");
        // 过滤响应体中的中文乱码
        servletResponse.setContentType("text/html;charset=utf-8");
        // 将拦截的request和response对象还给web服务器
        filterChain.doFilter(servletRequest, servletResponse);
    }
}
