package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.vo.PagenationVO;
import com.bjpowernode.crm.workbench.domain.Clue;
import com.bjpowernode.crm.workbench.domain.Tran;

import java.util.Map;

public interface ClueService {

    boolean saveClue(Clue clue);

    PagenationVO<Clue> queryClues(Map<String, Object> map);

    boolean deleteClue(String[] ids);

    Clue showClueDetail(String id);

    boolean debundClueAndAct(String id);

    boolean bundClueAndAct(String clueId, String[] actIds);

    boolean convertClue(String clueId, String createBy, Tran transaction);

    Map<String, Object> getUserListAndClue(String clueId);

    boolean updateClue(Clue clue);
}
