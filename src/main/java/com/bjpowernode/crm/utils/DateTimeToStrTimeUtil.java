package com.bjpowernode.crm.utils;

/*
* 将系统当前Date类型的时间转换成字符串类型的时间
* */

import java.text.SimpleDateFormat;
import java.util.Date;

public class DateTimeToStrTimeUtil {

    public static String getStrTime(){
        Date date = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        return sdf.format(date);
    }
}
