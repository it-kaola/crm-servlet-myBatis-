package com.bjpowernode.crm.settings.test;

import com.bjpowernode.crm.utils.DateTimeToStrTimeUtil;
import com.bjpowernode.crm.utils.MD5Util;

public class Test01 {
    public static void main(String[] args) {


        /*验证失效时间*/
        /*
        String expireTime = "2022-12-31 24:59:59"; // 假定的失效时间为：2022-12-31 24:59:59
        // 获取系统当前时间的字符串
        String strDate = DateTimeToStrTime.getStrTime();
        // 与失效时间作比较
        int count = expireTime.compareTo(strDate);
        if(count < 0){
            System.out.println("账号已失效！");
        }
        */


        /*验证用户锁定状态，1表示启用，0表示锁定*/
        /*
        String lockState = "0";
        if("0".equals(lockState)){
            System.out.println("账号已锁定！");
        }
        */


        /*验证IP地址的有效性*/
        /*
        // 浏览器的IP地址
        String ip = "192.168.1.3";
        // 允许访问的ip地址群，每个ip地址用逗号分隔
        String allowIps = "192.168.1.1,192.168.1.2";
        // 判断
        if(allowIps.contains(ip)){
            System.out.println("有效的ip地址");
        }else{
            System.out.println("ip地址受限！");
        }
        */


        /*验证密码是否正确*/
        /*
        String pwd = "123";
        // 获取明文密码的密文形式
        pwd = MD5Util.getMD5(pwd);
        System.out.println(pwd);
        */
    }
}
