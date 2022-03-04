package com.bjpowernode.crm.settings.service;

import com.bjpowernode.crm.exception.LoginException;
import com.bjpowernode.crm.settings.domain.User;

import java.util.List;

public interface UserService {

    User loginVerify(String loginAct, String loginPwd, String ip) throws LoginException;

    List<User> queryUserList();
}
