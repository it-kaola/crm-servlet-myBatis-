package com.bjpowernode.crm.utils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/*
* 使用jackson，将对应的实体类对象或者map集合转换为json格式的数据
* */
public class ObjectToJsonUtil {

    // 将指定的map集合对象：{"isSuccess", flag} 转换为json格式的数据，并将其传入到响应体中
    public static void mapToJson(HttpServletResponse response, boolean flag){
        Map<String, Boolean> map = new HashMap<>();
        map.put("isSuccess", flag);
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            // 将map集合转为json格式的数据
            String json = objectMapper.writeValueAsString(map);
            // 将其传入到响应体中
            response.getWriter().print(json);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 将对象转换为json格式的数据，并将其传入到响应体中
    public static void objTojson(HttpServletResponse response, Object obj){
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            // 将对象转为json格式的数据
            String json = objectMapper.writeValueAsString(obj);
            // 将其传入到响应体中
            response.getWriter().print(json);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
