package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationDao {

    int debundClueAndAct(String id);

    int bundClueAndAct(ClueActivityRelation clueActivityRelation);

    List<ClueActivityRelation> getClueActRelationList(String clueId);

    int deleteClueActivityRelation(String clueId);
}
