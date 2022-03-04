package com.bjpowernode.crm.settings.domain;

/*
* 在实际开发中，常用的字符串形式的日期和时间主要有以下两种
*   1. 年月日
*       yyyy-MM-dd 一共10位字符串
*   2. 年月日时分秒
*       yyyy-MM-dd HH:mm:ss 一共19位字符串
* */

/*
* 关于登录
*   首先验证账号和密码
*       select * from tbl_user where loginAct=? and loginPwd=?;
*   执行完上述sql语句后，返回一个User对象。若User对象为null，表示账号密码错误；若User对象不为null，表示账号密码正确
*   继续验证以下其他字段信息是否合法：
*       expireTime 失效时间
*       allowIps ip地址
*       lockState 用户锁定状态
* */

public class User {

    // 编号 主键 唯一标识
    private String id;
    // 登录账号
    private String loginAct;
    // 用户的真实姓名
    private String name;
    // 登录密码
    private String loginPwd;
    // 用户邮箱
    private String email;
    // 失效时间，在数据库中的数据类型是char(19)，表示由 yyyy-MM-dd HH:mm:ss 组成
    private String expireTime;
    // 用户锁定状态，0表示锁定，1表示启用
    private String lockState;
    // 部门编号
    private String deptno;
    // 允许访问的ip地址
    private String allowIps;
    // 该用户记录的创建时间 19位
    private String createTime;
    // 该用户记录的创建者
    private String createBy;
    // 该用户记录的修改时间 19位
    private String editTime;
    // 该用户记录的修改人
    private String editBy;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLoginAct() {
        return loginAct;
    }

    public void setLoginAct(String loginAct) {
        this.loginAct = loginAct;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLoginPwd() {
        return loginPwd;
    }

    public void setLoginPwd(String loginPwd) {
        this.loginPwd = loginPwd;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getExpireTime() {
        return expireTime;
    }

    public void setExpireTime(String expireTime) {
        this.expireTime = expireTime;
    }

    public String getLockState() {
        return lockState;
    }

    public void setLockState(String lockState) {
        this.lockState = lockState;
    }

    public String getDeptno() {
        return deptno;
    }

    public void setDeptno(String deptno) {
        this.deptno = deptno;
    }

    public String getAllowIps() {
        return allowIps;
    }

    public void setAllowIps(String allowIps) {
        this.allowIps = allowIps;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public String getCreateBy() {
        return createBy;
    }

    public void setCreateBy(String createBy) {
        this.createBy = createBy;
    }

    public String getEditTime() {
        return editTime;
    }

    public void setEditTime(String editTime) {
        this.editTime = editTime;
    }

    public String getEditBy() {
        return editBy;
    }

    public void setEditBy(String editBy) {
        this.editBy = editBy;
    }

}
