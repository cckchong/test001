public without sharing class SurveyAssignmentTriggerHandler {

    private static List<String> listSurveyAdminReason = new List<String>();
    private static List<String> listSurveyTakerReason = new List<String>();
    private static List<String> listAssignmentAdminReason = new List<String>();
    private static List<String> listAssignmentNonOwnerReason = new List<String>();

    static {

        listSurveyAdminReason.add(Survey__Share.RowCause.Owner);
        listSurveyAdminReason.add(Survey__Share.RowCause.Administrator__c);

        listSurveyTakerReason.add(Survey__Share.RowCause.Taker__c);

        listAssignmentAdminReason.add(Survey_Assignment__Share.RowCause.Owner);
        listAssignmentAdminReason.add(Survey_Assignment__Share.RowCause.Survey_Administrator__c);

        listAssignmentNonOwnerReason.add(Survey_Assignment__Share.RowCause.Survey_Administrator__c);
    }

    private static List<Survey_Assignment__c> createSurveyAssignmentAdminList(String surveyId, String nature) {

        List<Survey_Assignment__c> allAdmins = [Select id, Name, User__c, User__r.Name 
                                                from Survey_Assignment__c
                                                where Survey__c = :surveyId
                                                and Assignment_Nature__c = :nature];

        System.debug ('(createSurveyAssignmentAdminList) surveyId: ' + surveyId + ', nature: ' + nature);
        for (Survey_Assignment__c admin : allAdmins) {
            System.debug('(createSurveyAssignmentAdminList) Survey Assignment Id: ' + admin.id 
                            + ', survey assignment name: ' + admin.Name
                            + ', user id: ' + admin.User__c 
                            + ', user name: ' + admin.User__r.Name);        
        }
        return allAdmins;
    }

    // find old survey assignments under a survey
    private static List<Survey_Assignment__c> createNonUpdatedSurveyAssignment (
            String surveyId, List<Survey_Assignment__c> newSurveyAssignmentList) {

        System.debug('createNonUpdatedSurveyAssignment');

        List<Survey_Assignment__c> listNonUpdatedAssignment = new List<Survey_Assignment__c>();
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {

            listNonUpdatedAssignment = 
                    [Select Id, Name, Survey__c, User__c, GroupId__c 
                    From Survey_Assignment__c 
                    Where Survey__c = :surveyId And Id NOT IN :newSurveyAssignmentList];

            for (Survey_Assignment__c sa : listNonUpdatedAssignment) {
                System.debug('(Non updated Survey Assignment) sa.Id: ' + sa.Id 
                    + ', sa.Name: ' + sa.Name 
                    + ', sa.Survey__c: ' + sa.Survey__c
                    + ', sa.User__c: ' + sa.User__c
                    + ', sa.GroupId__c: ' + sa.GroupId__c);
            }
        }
        return listNonUpdatedAssignment;
    }

    private static void saveSurveyAdminList(String surveyId, List<Survey_Assignment__c>  listAssignmentAdminGroup) {

        Survey__c survey = [Select Id, Survey_Admin_List_1__c, Survey_Admin_List_2__c, 
                                Survey_Admin_List_3__c, Survey_Admin_List_4__c, Survey_Admin_List_5__c
                            From Survey__c where Id = :surveyId limit 1];
        if (survey != null) {                   
            for (Survey_Assignment__c sa : listAssignmentAdminGroup) {
                SurveyAdminListHelper.appendAdminId(survey, sa.User__c);                
            }

            System.debug('(appendAdminId) Update survey admin list 1: ' + survey.Survey_Admin_List_1__c);
            System.debug('(appendAdminId) Update survey admin list 2: ' + survey.Survey_Admin_List_2__c);
            System.debug('(appendAdminId) Update survey admin list 3: ' + survey.Survey_Admin_List_3__c);
            System.debug('(appendAdminId) Update survey admin list 4: ' + survey.Survey_Admin_List_4__c);
            System.debug('(appendAdminId) Update survey admin list 5: ' + survey.Survey_Admin_List_5__c);
            Database.SaveResult sr = Database.update(survey, false);
            if (!sr.isSuccess()) {
                Database.Error err = sr.getErrors()[0];
                survey.addError('Unable to append admin ids to survey due to following exception: ' + err.getMessage());
            }
        }
    }

    private static void deleteSurveyAdminList(String surveyId, List<Survey_Assignment__c>  listAssignmentAdminGroup) {
        
        Survey__c survey = [Select Id, Survey_Admin_List_1__c, Survey_Admin_List_2__c, 
                                Survey_Admin_List_3__c, Survey_Admin_List_4__c, Survey_Admin_List_5__c
                            From Survey__c where Id = :surveyId limit 1];
        if (survey != null) {
            
            Integer idx = -1;
            Integer idx2 = -1;
            Integer idx3 = -1;
            Integer idx4 = -1;
            Integer idx5 = -1;
            for (Survey_Assignment__c sa : listAssignmentAdminGroup) {
                //System.debug('(deleteSurveyAdminList) Call SurveyAdminListHelper.deleteAdminId with userId: ' + sa.User__c);
                SurveyAdminListHelper.deleteAdminId(survey, sa.User__c);
            }
            System.debug('(deleteSurveyAdminList) Update survey admin list 1: ' + survey.Survey_Admin_List_1__c);
            System.debug('(deleteSurveyAdminList) Update survey admin list 2: ' + survey.Survey_Admin_List_2__c);
            System.debug('(deleteSurveyAdminList) Update survey admin list 3: ' + survey.Survey_Admin_List_3__c);
            System.debug('(deleteSurveyAdminList) Update survey admin list 4: ' + survey.Survey_Admin_List_4__c);
            System.debug('(deleteSurveyAdminList) Update survey admin list 5: ' + survey.Survey_Admin_List_5__c);
            Database.SaveResult sr = Database.update(survey, false);
            if (!sr.isSuccess()) {
                Database.Error err = sr.getErrors()[0];
                survey.addError('Unable to delete admin Ids from survey admin list in survey due to following exception: '
                                + err.getMessage());
            }
        }
    }

    // create survey assignment share and survey share for new survey assignment custom objects
    public static void createSurveyAssignmentShare(List<Survey_Assignment__c> newSurveyAssignmentList,
            Map<Id, Survey_Assignment__c> newSurveyAssignmentMap) {

        System.debug('createSurveyAssignmentShare fired after insert');

        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {

            String surveyId = newSurveyAssignmentList.get(0).Survey__c;
            System.debug('Survey id: ' + surveyId);

            // group survey assignments into two groups: administrator and taker
            List<Survey_Assignment__c>  listAssignmentAdminGroup = new List<Survey_Assignment__c>();
            List<Survey_Assignment__c>  listAssignmentTakerGroup = new List<Survey_Assignment__c>();
            for (Survey_Assignment__c sa : newSurveyAssignmentList) {
                if (sa.Assignment_Nature__c == SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR) {
                    listAssignmentAdminGroup.add(sa);
                }
                if (sa.Assignment_Nature__c == SurveyAssignmentObjectUtil.NATURE_TAKER) {
                    listAssignmentTakerGroup.add(sa);
                }
            }

            Set<String> setAssignmentAdmin = SurveyAssignmentShareHelper.createAssignmentShareSetByReason(
                newSurveyAssignmentList, listAssignmentAdminReason);
            Set<String> setSurveyAdmin = SurveyAssignmentshareHelper.retrieveSurveyShareSet(surveyId, listSurveyAdminReason, 
                                                '(retrieveSurveyShareSet) (Survey Administrator)');
            Set<String> setSurveyTaker = SurveyAssignmentshareHelper.retrieveSurveyShareSet(surveyId, listSurveyTakerReason, 
                                                '(retrieveSurveyShareSet) (Survey Taker)');
            List<Survey_Assignment__c> allAdmins = createSurveyAssignmentAdminList(surveyId, 
                SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR);

            List<Survey_Assignment__c> listNonUpdatedAssignment = 
                    createNonUpdatedSurveyAssignment(surveyId, newSurveyAssignmentList);
            Set<String> setNonUpdatedAssignmentAdmin = SurveyAssignmentShareHelper.createAssignmentShareSetByReason(listNonUpdatedAssignment, 
                                                                                listAssignmentAdminReason);
            Map<Id, Survey_Assignment__c> allSurveyAssignmentMap = new Map<Id, Survey_Assignment__c>(newSurveyAssignmentMap);
            for (Survey_Assignment__c sa: listNonUpdatedAssignment) {
                allSurveyAssignmentMap.put(sa.ID, sa);
            }

            // all survey administrator can see all survey assignment records
            List<Survey_Assignment__Share> listAssignmentShareInsert = new List<Survey_Assignment__Share>();
            System.debug ('Create survey assignment share for new survey assignment custom objects');
            listAssignmentShareInsert.addAll(SurveyAssignmentShareHelper.createSurveyAssignmentShareList(allAdmins, 
                                                    setAssignmentAdmin, newSurveyAssignmentList));
            System.debug ('Create survey assignment share for non-updated survey assignment custom objects');
            listAssignmentShareInsert.addAll(SurveyAssignmentShareHelper.createSurveyAssignmentShareList(allAdmins, 
                                                    setNonUpdatedAssignmentAdmin, listNonUpdatedAssignment));

            system.debug(allAdmins.size());
            system.debug(setAssignmentAdmin.size());
            system.debug(newSurveyAssignmentList.size());
            system.debug(setNonUpdatedAssignmentAdmin.size());
            system.debug(listNonUpdatedAssignment.size());
            system.debug(listAssignmentShareInsert.size());
            // grant administrator to shared manager for the survey record
            List<Survey__Share> listSurveyShareInsert = new List<Survey__Share>();
            listSurveyShareInsert.addAll(SurveyAssignmentShareHelper.createSurveyShareList(listAssignmentAdminGroup, setSurveyAdmin, 
                    Survey__Share.RowCause.Administrator__c, surveyId, '(Administrator)'));
            listSurveyShareInsert.addAll(SurveyAssignmentShareHelper.createSurveyShareList(listAssignmentTakerGroup, setSurveyTaker, 
                    Survey__Share.RowCause.Taker__c, surveyId, '(Taker)'));

            system.debug(listAssignmentShareInsert.size()+':'+allSurveyAssignmentMap.size());
            SurveyAssignmentShareHelper.persistSurveyAssignmentShareRecord(listAssignmentShareInsert, allSurveyAssignmentMap);
            SurveyAssignmentShareHelper.persistSurveyShareRecord(listSurveyShareInsert, newSurveyAssignmentList, allSurveyAssignmentMap);

            // append new admin user id to survey admin list custom fields in Survey object
            if (listAssignmentAdminGroup != null && listAssignmentAdminGroup.size() > 0) {
                saveSurveyAdminList(surveyId, listAssignmentAdminGroup);
            }
        }
    }

    public static void validateDeleteSurveyAssignment(List<Survey_Assignment__c> oldSurveyAssignmentList) {

        System.debug('validateDeleteSurveyAssignment fired before delete');

        // issue error message if user or group id is survey owner 
        if (oldSurveyAssignmentList != null && oldSurveyAssignmentList.size() > 0) {
            
            for (Survey_Assignment__c sa : oldSurveyAssignmentList) {
                System.debug ('Old survey assignment id: ' + sa.id 
                        + ', old survey assignment name: ' + sa.name
                        + ', user id: ' + sa.User__c 
                        + ', group Id: ' + sa.GroupId__c);
            }

            String surveyId = oldSurveyAssignmentList.get(0).Survey__c;
            System.debug('Survey id: ' + surveyId); 

            if (String.isNotBlank(surveyId)) {
                String surveyOwner = '';
                String surveyName  = '';
                List<Survey__c> listSurvey = [Select Id, OwnerId, Name from Survey__c where Id = :surveyId];
                if (listSurvey != null && listSurvey.size() > 0) {
                    surveyOwner = listSurvey.get(0).OwnerId;
                    surveyName = listSurvey.get(0).Name;
                }

                for (Survey_Assignment__c sa : oldSurveyAssignmentList) {
                    if (surveyOwner.equalsIgnoreCase(sa.User__c)) {
                        String userName = [Select Name From User where id = :sa.User__c].get(0).Name;
                        sa.addError('Survey Assignment record cannot delete. Reason: ' 
                            +  userName + '(' + sa.User__c + ') is survey owner of ' + surveyName);
                    }
                }
            }
        }
    }

    public static void deleteSurveyAssignmentShare(List<Survey_Assignment__c> oldSurveyAssignmentList,
        Map<Id, Survey_Assignment__c> oldSurveyAssignmentMap) {

        System.debug('deleteSurveyAssignmentShare fired after delete');
        List<string> UserGroupListAdminReason=new List<string>();//Add by DTT Team
        List<string> UserGroupListTakerReason=new List<string>();//Add by DTT Team

        // delete manual sharing in survey_share table
        List<Survey__Share> listSurveyShare = new List<Survey__Share>();
        if (oldSurveyAssignmentList != null && oldSurveyAssignmentList.size() > 0) {

            String surveyId = oldSurveyAssignmentList.get(0).Survey__c;
            System.debug('(deleteSurveyAssignmentShare) Survey id: ' + surveyId);   

            if (String.IsNotBlank(surveyId)) {

                // group survey assignments into two groups: administrator and taker
                List<Survey_Assignment__c>  listAssignmentAdminGroup = new List<Survey_Assignment__c>();
                for (Survey_Assignment__c sa : oldSurveyAssignmentList) {
                    if (sa.Assignment_Nature__c == SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR) {
                        System.debug('(deleteSurveyAssignmentShare) Delete ' + sa.User__c + ' into listAssignmentAdminGroup');
                        listAssignmentAdminGroup.add(sa);
                    }       
                }


                for (Survey_Assignment__c sa : oldSurveyAssignmentList) {
                    System.debug ('(deleteSurveyAssignmentShare) Old survey assignment id: ' + sa.id 
                            + ', old survey assignment name: ' + sa.name 
                            + ', user id: ' + sa.User__c 
                            + ', group Id: ' + sa.GroupId__c);

                    String userOrGroupId = '';
                    List<String> surveyRowCause = null;
                    if (String.isNotBlank(sa.User__c)) {
                        userOrGroupId = sa.User__c;
                    } else if (String.isNotBlank(sa.GroupId__c)) {
                        userOrGroupId = sa.GroupId__c;
                    }

                    //if (sa.Assignment_Nature__c == SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR) {
                    //  surveyRowCause = listSurveyAdminReason;
                    //} else if (Sa.Assignment_Nature__c == SurveyAssignmentObjectUtil.NATURE_TAKER) {
                    //  surveyRowCause = listSurveyTakerReason;
                    //} //Comment by DTT

                    System.debug ('(deleteSurveyAssignmentShare) surveyId: ' + surveyId + ', userOrGroupId: ' + userOrGroupId + ', rowCause: ' + surveyRowCause);
                    if (String.IsNotBlank(userOrGroupId)) {
                        //List<Survey__Share> listExist = [Select Id From Survey__Share Where ParentId=:surveyId AND UserOrGroupID = :userOrGroupId 
                        //          AND rowCause IN :surveyRowCause];
                        //if (listExist.size() > 0) {
                        //  listSurveyShare.addAll(listExist);
                        //}

                        //Add by DTT support Team
                        if (sa.Assignment_Nature__c == SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR) {
                            UserGroupListAdminReason.add(userOrGroupId);
                         } else if (Sa.Assignment_Nature__c == SurveyAssignmentObjectUtil.NATURE_TAKER) {
                            UserGroupListTakerReason.add(userOrGroupId);
                         } 
                        //Add by DTT support Team
                    }
                }

                //Add by DTT support Team
                List<Survey__Share> TempList1 = [Select Id,ParentId,UserOrGroupID,rowCause From Survey__Share Where ParentId =:surveyId AND UserOrGroupID in:UserGroupListAdminReason AND rowCause IN :listSurveyAdminReason];
                List<Survey__Share> TempList2 = [Select Id,ParentId,UserOrGroupID,rowCause From Survey__Share Where ParentId =:surveyId AND UserOrGroupID in:UserGroupListTakerReason AND rowCause IN :listSurveyTakerReason];
                if (TempList1.size() > 0) {
                            listSurveyShare.addAll(TempList1);
                }
                if (TempList2.size() > 0) {
                            listSurveyShare.addAll(TempList2);
                }
                //Add by DTT support Team

                //for (Survey__Share ss : listSurveyShare) {
                //   System.debug('(deleteSurveyAssignmentShare) Survey Share id: ' + ss.id);
                //}
                
                if (listSurveyShare != null && listSurveyShare.size() > 0) {
                    List<Database.DeleteResult> drs = Database.delete(listSurveyShare, false);
                    Integer i = 0;
                    for (Database.DeleteResult result : drs) {
                        if (!result.isSuccess()) {
                            Database.Error err = result.getErrors()[0];
                            oldSurveyAssignmentMap.get(listSurveyShare.get(i).parentId).addError(
                                'Unable to remove sharing access to survey due to following exception: '
                                   + err.getMessage());
                        }
                        i++;
                    }
                }

                // delete admin user id to survey admin list custom fields in Survey object
                if (listAssignmentAdminGroup != null && listAssignmentAdminGroup.size() > 0) {
                    deleteSurveyAdminList(surveyId, listAssignmentAdminGroup); 
                }
            }
        }
    }
    
    public static void validateUserAndGroupMutuallyExclusive(List<Survey_Assignment__c> newSurveyAssignmentList) {

        System.debug('validateUserAndGroupMutuallyExclusive fired before insert or before update');

        // issue error message if both user id and group id are inputted
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            
            String surveyId = newSurveyAssignmentList.get(0).Survey__c;
            System.debug('Survey id: ' + surveyId); 

            for (Survey_Assignment__c sa : newSurveyAssignmentList) {
                System.debug ('(validateUserAndGroupMutuallyExclusive) New survey assignment id: ' + sa.Id 
                        + ', new survey assignment name: ' + sa.Name
                        + ', survey id: ' + sa.Survey__c
                        + ', user id: ' + sa.User__c 
                        + ', group Id: ' + sa.GroupId__c);
                
                if (String.IsNotBlank(sa.User__c) && String.IsNotBlank(sa.GroupId__c)) {
                    sa.addError('Survey Assignment record cannot create or update. Reason: user id and group id must be mutually exclusive.');
                } else if (String.IsBlank(sa.User__c) && String.IsBlank(sa.GroupId__c)) {
                    sa.addError('Survey Assignment record cannot create or update. Reason: user id and group id are both blank.');
                } else if (String.IsNotBlank(sa.GroupId__c)) {
                    if (!SurveyAssignmentObjectUtil.NATURE_TAKER.equalsIgnoreCase(sa.Assignment_Nature__c)) {
                        sa.addError('Assignment nature must be ' + SurveyAssignmentObjectUtil.NATURE_TAKER + 
                                    ' when groupd id is inputted.');
                    }
                }
                
                if (String.IsBlank(sa.Assignment_Nature__c)) {
                    sa.addError('Assignment nature cannot be blank.');
                }
            }
        }
    }
}