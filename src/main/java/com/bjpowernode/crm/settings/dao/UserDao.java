package com.bjpowernode.crm.settings.dao;

import com.bjpowernode.crm.settings.domain.User;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface UserDao {

    // 通过账号和密码查询数据库中是否有相应的记录，有返回对应的User对象，没有返回null
    User selectOneUser(@Param("loginAct") String loginAct, @Param("loginPwd") String loginPwd);

    // 查询所有用户列表
    List<User> queryUserList();
}
