package com.bjpowernode.crm.handler;

import com.bjpowernode.crm.utils.SqlSessionUtil;
import org.apache.ibatis.session.SqlSession;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

/*
* 事务代理对象
* 功能：帮助业务层实现数据库事务的提交与回滚，这样业务层只需要关心业务代码的逻辑，功能专一
* */

public class TransactionInvocationHandler implements InvocationHandler {

    private Object target; // 目标类对象

    public TransactionInvocationHandler(Object target){
        this.target = target;
    }

    // 代理对象的方法
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {

        SqlSession sqlSession = null;
        Object result = null;

        try{

            sqlSession = SqlSessionUtil.getSqlSession();

            // 目标类方法的调用
            // 在该项目中对应的是，业务层(service)实现类对象的方法调用
            result = method.invoke(target, args);

            // 功能增强，在目标类方法调用的基础上，实现事务的提交
            sqlSession.commit();

        }catch (Exception e){ // 代理对象在这里已经将目标类方法（method.invoke(target, args);）出现的异常进行的捕捉
            // 遇到异常，事务需要回滚
            if(sqlSession != null){
                sqlSession.rollback();
            }
            e.printStackTrace();
            // 继续向上抛出捕获到的异常
            throw e.getCause(); // 需要加上这行代码，继续向上抛出捕获到的异常
        }finally {
            SqlSessionUtil.close(sqlSession);
        }

        return result;

    }

    // 获得代理对象
    public Object getProxy(){
        return Proxy.newProxyInstance(target.getClass().getClassLoader(), target.getClass().getInterfaces(), this);
    }

}
