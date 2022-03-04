package com.bjpowernode.crm.settings.service.impl;

import com.bjpowernode.crm.settings.dao.DicTypeDao;
import com.bjpowernode.crm.settings.dao.DicValueDao;
import com.bjpowernode.crm.settings.domain.DicType;
import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DicServiceImpl implements DicService {

    DicTypeDao dicTypeDao = SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    DicValueDao dicValueDao = SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);

    @Override
    public Map<String, List<DicValue>> getDicValMap() {

        // 创建map集合存放数据
        Map<String, List<DicValue>> map = new HashMap<>();

        // 先查询tbl_dic_type表，返回该表中所有类型
        List<DicType> dicTypeList = dicTypeDao.getDicTypeList();

        // 遍历 dicTypeList, 取得DicType对象中的code属性值
        for(DicType dicType : dicTypeList){
            // 取得DicType对象中的code属性值
            String code = dicType.getCode();
            // 根据code，查询tbl_dic_value表中对应的数据
            List<DicValue> dicValList = dicValueDao.getDicVal(code);
            // 将查询到的字典值的结果放到map集合中
            map.put(code+"List", dicValList);
        }

        return map;
    }
}
