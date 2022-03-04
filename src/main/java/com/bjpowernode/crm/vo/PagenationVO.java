package com.bjpowernode.crm.vo;

import java.util.List;

public class PagenationVO<T> {

    // 查询的总记录条数
    private int total;
    // 查询到的数据列表
    private List<T> dataList;

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }

    public List<T> getDataList() {
        return dataList;
    }

    public void setDataList(List<T> dataList) {
        this.dataList = dataList;
    }

    @Override
    public String toString() {
        return "PagenationVO{" +
                "total=" + total +
                ", dataList=" + dataList +
                '}';
    }
}
