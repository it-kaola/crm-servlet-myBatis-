package com.bjpowernode.crm.workbench.domain;

/*
* 市场活动备注类
* */

public class ActivityRemark {

    // 主键
    private String id;
    // 备注信息
    private String noteContent;
    // 创建时间
    private String createTime;
    // 创建人
    private String createBy;
    // 修改时间
    private String editTime;
    // 修改人
    private String editBy;
    // 是否修改过的标记 0表示未修改，1表示已修改
    private String editFlag;
    // 市场活动id 存在外键约束
    private String activityId;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNoteContent() {
        return noteContent;
    }

    public void setNoteContent(String noteContent) {
        this.noteContent = noteContent;
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

    public String getEditFlag() {
        return editFlag;
    }

    public void setEditFlag(String editFlag) {
        this.editFlag = editFlag;
    }

    public String getActivityId() {
        return activityId;
    }

    public void setActivityId(String activityId) {
        this.activityId = activityId;
    }
}
