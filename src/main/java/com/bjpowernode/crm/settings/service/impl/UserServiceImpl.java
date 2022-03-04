package com.bjpowernode.crm.settings.service.impl;

import com.bjpowernode.crm.exception.LoginException;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.DateTimeToStrTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;

import java.util.List;

public class UserServiceImpl implements UserService {

    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    @Override
    public User loginVerify(String loginAct, String loginPwd, String ip) throws LoginException {

        // 连接数据库，查询记录
        User user = userDao.selectOneUser(loginAct, loginPwd);

        if(user == null){
            throw new LoginException("账号或密码错误！");
        }

        // 程序能够执行到此处，说明账号和密码是正确的
        // 接下来应该验证其余3个字段是否符合要求

        // 失效时间
        String currentTime = DateTimeToStrTimeUtil.getStrTime();
        if(currentTime.compareTo(user.getExpireTime()) > 0){
            throw new LoginException("账号已失效！");
        }

        // ip地址
        if(! user.getAllowIps().contains(ip)){
            throw new LoginException("ip地址受限！");
        }

        // 用户锁定状态
        if("0".equals(user.getLockState())){
            throw new LoginException("账号已锁定！");
        }

        return user;
    }

    @Override
    public List<User> queryUserList() {

        List<User> userList = userDao.queryUserList();

        return userList;
    }
}
