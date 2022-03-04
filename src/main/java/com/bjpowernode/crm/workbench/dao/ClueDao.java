package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {

    int saveClue(Clue clue);

    int queryCluesNumByCondition(Map<String, Object> map);

    List<Clue> queryCluesByCondition(Map<String, Object> map);

    int deleteClue(String[] ids);

    Clue getOneClue(String id);

    Clue getClueById(String clueId);

    int updateClue(Clue clue);
}
