package com.bjpowernode.crm.utils;

/*
* 功能：生成一个全世界唯一的UUID
* */

import java.util.UUID;

public class UUIDUtil {

    public static String getUUID(){
        UUID uuid = UUID.randomUUID();
        return String.valueOf(uuid).replaceAll("-", "");
    }
}
