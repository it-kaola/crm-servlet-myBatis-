package com.bjpowernode.crm.exception;

/*
* 自定义的登录异常
* */

public class LoginException extends Exception {

    public LoginException() {}

    public LoginException(String message) {
        super(message);
    }
}
