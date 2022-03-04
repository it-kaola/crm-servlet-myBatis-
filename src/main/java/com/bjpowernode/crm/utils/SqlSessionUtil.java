package com.bjpowernode.crm.utils;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

import java.io.IOException;
import java.io.InputStream;

/*
* 创建SqlSession对象，并实现关闭SqlSession对象功能
* */
public class SqlSessionUtil {

    private static SqlSessionFactory factory;
    private static ThreadLocal<SqlSession> t = new ThreadLocal<>(); // 利用该线程存放SqlSession对象，保证线程安全

    static{
        String configPath = "mybatis-config.xml"; // mybatis主配置文件的路径，默认从类路径的根开始
        try {
            // 读取mybatis的主配置文件
            InputStream in = Resources.getResourceAsStream(configPath);
            // 创建SqlSessionFactory对象
            factory = new SqlSessionFactoryBuilder().build(in);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static SqlSession getSqlSession(){
        SqlSession sqlSession = t.get(); // 从线程中拿到SqlSession对象

        if(sqlSession == null){
            sqlSession = factory.openSession();
            t.set(sqlSession);
        }

        return sqlSession;
    }

    public static void close(SqlSession sqlSession){
        if(sqlSession != null){
            sqlSession.close();
            t.remove(); // 从线程中去除该SqlSession对象
        }
    }
}
