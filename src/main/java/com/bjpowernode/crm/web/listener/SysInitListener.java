package com.bjpowernode.crm.web.listener;

import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.settings.service.impl.DicServiceImpl;
import com.bjpowernode.crm.utils.ProxyUtil;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

/*
* 在服务器启动后，并且应用域对象创建完毕后，向应用域中存放数据字典中的数据
* */

public class SysInitListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {

        System.out.println("向应用域中存放数据字典开始");

        // 获取应用域对象
        ServletContext application = sce.getServletContext();

        // 创建代理对象
        DicService dicServiceProxy = (DicService) ProxyUtil.getProxyObj(new DicServiceImpl());

        // 获取到的数据字典数据值的map集合，集合中的值应该为：
        // map.put("appellationList", dicValList);
        // map.put("clueStateList", dicValList);
        // map.put("returnPriorityList", dicValList);
        // .......
        Map<String, List<DicValue>> map = dicServiceProxy.getDicValMap();

        // System.out.println("数据字典的值为：" + map);

        // 取出map集合中的key
        Set<String> set = map.keySet();
        // 遍历key集合
        for(String key : set){
            // 将数据字典中的数据根据对应的类型分门别类的存放到应用域中
            application.setAttribute(key, map.get(key));

        }

        System.out.println("向应用域中存放数据字典结束");


        // 解析完数据字典后，解析阶段stage与可能性possibility之间对应关系的properties文件
        // Stage2Possibility.properties 是描述阶段也可能性之间的关系的，stage是key，possibility是value
        ResourceBundle bundle = ResourceBundle.getBundle("Stage2Possibility");

        Map<String, String> pMap = new HashMap<>();

        Enumeration<String> stages = bundle.getKeys();

        while(stages.hasMoreElements()){
            // 阶段
            String stage = stages.nextElement();
            // 可能性
            String possibility = bundle.getString(stage);
            // 保存到map集合中
            pMap.put(stage, possibility);
        }

        System.out.println(pMap);

        // 存入应用域中
        application.setAttribute("pMap", pMap);
    }
}
