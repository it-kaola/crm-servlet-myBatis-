package com.bjpowernode.crm.utils;

/*
* 功能：通过对应的业务层(service)接口的实现类对象获得相应的代理对象
*
* 在该项目中：
*   相应的业务层(service)接口实现类对象相当于工厂
*   完成事务提交功能的代理对象相当于代理商
*
* */

import com.bjpowernode.crm.handler.TransactionInvocationHandler;

public class ProxyUtil {
    public static Object getProxyObj(Object serviceImpl){
        return new TransactionInvocationHandler(serviceImpl).getProxy();
    }
}
