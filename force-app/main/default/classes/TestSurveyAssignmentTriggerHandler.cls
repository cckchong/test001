@isTest
private class TestSurveyAssignmentTriggerHandler {
    
    @isTest static void testCreateSurveyAssignmentShareForTaker() {
    
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;
        String adminId = surveyTestingUtil.adminId;
        String taker5Id = surveyTestingUtil.taker5Id;

        Survey_Assignment__c sa = new Survey_Assignment__c();
        sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
        sa.Survey__c = surveyId;
        sa.User__c = taker5Id;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {
            insert sa;
        }

        // verify survey owner and survey admin can access the new survey assignment record
        List<Survey_Assignment__Share> listSurveyAssignmentShare = 
                        [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause 
                         From Survey_Assignment__Share 
                         Where ParentId = :sa.Id];
        System.assertEquals(2, listSurveyAssignmentShare.size());

        Map<String, Survey_Assignment__Share> mapShare = new Map<String, Survey_Assignment__Share>();
        for (Survey_Assignment__Share sas : listSurveyAssignmentShare) {
            mapShare.put(sas.UserOrGroupId, sas);
        }

        Set<String> setUserOrGroupId = mapShare.keySet();
        System.assert(setUserOrGroupId.contains(ownerId));
        System.assert(setUserOrGroupId.contains(adminId));

        if (mapShare.containsKey(ownerId)) {
            Survey_Assignment__Share sas = mapShare.get(ownerId);
            System.assertEquals(Survey_Assignment__Share.RowCause.Owner, sas.RowCause);
            System.assertEquals('All', sas.AccessLevel);
        }

        if (mapShare.containsKey(adminId)) {
            Survey_Assignment__Share sas = mapShare.get(adminId);
            System.assertEquals(Survey_Assignment__Share.RowCause.Survey_Administrator__c, sas.RowCause);
            System.assertEquals('Edit', sas.AccessLevel);
        }

        // verify new taker can edit access to the survey
        List<Survey__Share> lstSurveyShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                              From Survey__Share 
                                              Where ParentId = :surveyId And UserOrGroupId = :taker5Id];
        System.assertEquals(1, lstSurveyShare.size());
        System.assertEquals(Survey__Share.RowCause.Taker__c, lstSurveyShare.get(0).RowCause);
        System.assertEquals('Edit', lstSurveyShare.get(0).AccessLevel);     

        Survey__c verifySurvey = [Select Id, Survey_Admin_List_1__c 
                                    , Survey_Admin_List_2__c, Survey_Admin_List_3__c 
                                    , Survey_Admin_List_4__c, Survey_Admin_List_5__c 
                                  From Survey__c 
                                  Where Id = :surveyId limit 1];

        String taker1Id = surveyTestingUtil.taker1Id;
        String taker2Id = surveyTestingUtil.taker2Id;
        String taker3Id = surveyTestingUtil.taker3Id;
        System.assert(!verifySurvey.Survey_Admin_List_1__c.contains(taker1Id) 
            && !verifySurvey.Survey_Admin_List_1__c.contains(taker2Id)
            && !verifySurvey.Survey_Admin_List_1__c.contains(taker3Id)
            && !verifySurvey.Survey_Admin_List_1__c.contains(taker5Id));        
        System.assertEquals(null, verifySurvey.Survey_Admin_List_2__c);
        System.assertEquals(null, verifySurvey.Survey_Admin_List_3__c);
        System.assertEquals(null, verifySurvey.Survey_Admin_List_4__c);
        System.assertEquals(null, verifySurvey.Survey_Admin_List_5__c);
        System.assert(verifySurvey.Survey_Admin_List_1__c.contains(ownerId));       
        System.assert(verifySurvey.Survey_Admin_List_1__c.contains(adminId));       

    }
    
    @isTest static void testCreateSurveyAssignmentShareForAdmin() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;
        String adminId = surveyTestingUtil.adminId;
        String admin2Id = surveyTestingUtil.admin2Id;

        Survey_Assignment__c sa = new Survey_Assignment__c();
        sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR;
        sa.Survey__c = surveyId;
        sa.User__c = admin2Id;

        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {
            insert sa;
        }

        // verify survey owner and survey admin can access the new survey assignment record
        List<Survey_Assignment__Share> listSurveyAssignmentShare = 
                        [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause 
                         From Survey_Assignment__Share 
                         Where ParentId = :sa.Id];
        System.assertEquals(3, listSurveyAssignmentShare.size());

        Map<String, Survey_Assignment__Share> mapShare = new Map<String, Survey_Assignment__Share>();
        for (Survey_Assignment__Share sas : listSurveyAssignmentShare) {
            mapShare.put(sas.UserOrGroupId, sas);
        }

        Set<String> setUserOrGroupId = mapShare.keySet();
        System.assert(setUserOrGroupId.contains(ownerId));
        System.assert(setUserOrGroupId.contains(adminId));
        System.assert(setUserOrGroupId.contains(admin2Id));

        if (mapShare.containsKey(ownerId)) {
            Survey_Assignment__Share sas = mapShare.get(ownerId);
            System.assertEquals(Survey_Assignment__Share.RowCause.Owner, sas.RowCause);
            System.assertEquals('All', sas.AccessLevel);
        }

        if (mapShare.containsKey(adminId)) {
            Survey_Assignment__Share sas = mapShare.get(adminId);
            System.assertEquals(Survey_Assignment__Share.RowCause.Survey_Administrator__c, sas.RowCause);
            System.assertEquals('Edit', sas.AccessLevel);
        }

        if (mapShare.containsKey(admin2Id)) {
            Survey_Assignment__Share sas = mapShare.get(adminId);
            System.assertEquals(Survey_Assignment__Share.RowCause.Survey_Administrator__c, sas.RowCause);
            System.assertEquals('Edit', sas.AccessLevel);
        }

        // verify new admin can edit access to the survey
        List<Survey__Share> lstSurveyShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                              From Survey__Share 
                                              Where ParentId = :surveyId And UserOrGroupId = :admin2Id];
        System.assertEquals(1, lstSurveyShare.size());
        System.assertEquals(Survey__Share.RowCause.Administrator__c, lstSurveyShare.get(0).RowCause);
        System.assertEquals('Edit', lstSurveyShare.get(0).AccessLevel);     

        // verify new admin can edit all survey assignment records of this survey
        List<Survey_Assignment__c> listSurveyAssignment = [Select Id 
                                                           From Survey_Assignment__c
                                                           Where Survey__c = :surveyId];
        System.assertEquals(6, listSurveyAssignment.size());

        List<Survey_Assignment__Share> listNewAdminSurveyAssignmentShare = 
                        [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause 
                         From Survey_Assignment__Share 
                         Where ParentId IN :listSurveyAssignment AND UserOrGroupId = :admin2Id];
        System.assertEquals(6, listNewAdminSurveyAssignmentShare.size());

        Survey__c verifySurvey = [Select Id, Survey_Admin_List_1__c 
                                    , Survey_Admin_List_2__c, Survey_Admin_List_3__c 
                                    , Survey_Admin_List_4__c, Survey_Admin_List_5__c 
                                  From Survey__c 
                                  Where Id = :surveyId limit 1];
        System.assert(verifySurvey.Survey_Admin_List_1__c.contains(ownerId));       
        System.assert(verifySurvey.Survey_Admin_List_1__c.contains(adminId));       
        System.assert(verifySurvey.Survey_Admin_List_1__c.contains(admin2Id));      
    }

    @isTest static void testValidateDeleteSurveyAssignmentSuccess() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String adminSurveyAssignmentId = surveyTestingUtil.adminSurveyAssignmentId;
        String groupSurveyAssignmentId = surveyTestingUtil.groupSurveyAssignmentId;

        List<String> surveyAssignmentIds = new List<String>();
        surveyAssignmentIds.add(adminSurveyAssignmentId);
        surveyAssignmentIds.add(groupSurveyAssignmentId);
        
        List<Survey_Assignment__c> oldSurveyAssignmentList = [Select id, Name, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                                             From Survey_Assignment__c  where ID IN : surveyAssignmentIds];
        SurveyAssignmentTriggerHandler.validateDeleteSurveyAssignment(oldSurveyAssignmentList);
    }

    @isTest static void testValidateDeleteSurveyAssignmentFailure() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerSurveyAssignmentId = surveyTestingUtil.ownerSurveyAssignmentId;
        String ownerId = surveyTestingUtil.ownerId;
        
        List<Survey_Assignment__c> oldSurveyAssignmentList = [Select id, Name, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                                             From Survey_Assignment__c  where ID =  : ownerSurveyAssignmentId];
        List<User> userList = [Select id, Name from User where id = :ownerId];
        String userName = '';
        if (userList != null && userList.size() > 0) {
            userName = userList.get(0).Name;
        }
        String userId = '';
        if (oldSurveyAssignmentList != null && oldSurveyAssignmentList.size() > 0) {
            userId = oldSurveyAssignmentList.get(0).User__c;
        }

        List<Survey__c> surveyList = [Select id, Name from Survey__c where id = :surveyId];
        String surveyName = '';
        if (surveyList != null && surveyList.size() > 0) {
            surveyName = surveyList.get(0).Name;
        }

        try {
            SurveyAssignmentTriggerHandler.validateDeleteSurveyAssignment(oldSurveyAssignmentList);
        } catch (Exception ex) {
            System.assertEquals('Survey Assignment record cannot delete. Reason: ' 
                            +  userName + '(' + userId + ') is survey owner of ' + surveyName  ,ex.getMessage());
        }
    }
    
    @isTest static void testDeleteSurveyAssignment() {
        
        // validate survey share is deleted for the user or group id
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String adminSurveyAssignmentId = surveyTestingUtil.adminSurveyAssignmentId;
        String adminId = surveyTestingUtil.adminId;
        String groupSurveyAssignmentId = surveyTestingUtil.groupSurveyAssignmentId;
        String taker2Id = surveyTestingUtil.taker2Id;
        String taker3Id = surveyTestingUtil.taker3Id;
        String ownerId = surveyTestingUtil.ownerId;

        List<String> delAssignmentIds = new List<String>();
        delAssignmentIds.add(adminSurveyAssignmentId);
        delAssignmentIds.add(groupSurveyAssignmentId);

        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {
            if ([Select Id From Survey_Assignment__c where Id IN :delAssignmentIds].size() > 0) {
                delete [Select Id From Survey_Assignment__c where Id IN :delAssignmentIds];
            }
        }

        List<String> lstUserOrGroupId = new List<String>();
        lstUserOrGroupId.add(adminId);
        lstUserOrGroupId.add(taker2Id);
        lstUserOrGroupId.add(taker3Id);

        // verify adminId, taker2Id and taker3Id do not have access to survey record
        List<Survey__Share> lstSurveyShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                              From Survey__Share 
                                              Where ParentId = :surveyId And UserOrGroupId IN :lstUserOrGroupId];
        System.assertEquals(0, lstSurveyShare.size());

        Survey__c verifySurvey = [Select Id, Survey_Admin_List_1__c 
                            , Survey_Admin_List_2__c, Survey_Admin_List_3__c 
                            , Survey_Admin_List_4__c, Survey_Admin_List_5__c 
                          From Survey__c 
                          Where Id = :surveyId limit 1];
        System.assert(verifySurvey.Survey_Admin_List_1__c.contains(ownerId));       
        System.assert(!verifySurvey.Survey_Admin_List_1__c.contains(adminId));      
    }

    @isTest static void testValidateMutuallyExclusiveTakerAssignment() {
        // Implement test code
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String groupSurveyAssignmentId = surveyTestingUtil.groupSurveyAssignmentId;
        String admin2Id = surveyTestingUtil.admin2Id;
        
        List<Survey_Assignment__c> newSurveyAssignmentList = [Select id, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                                             From Survey_Assignment__c  where ID =  : groupSurveyAssignmentId];
        
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            Survey_Assignment__c sa = newSurveyAssignmentList.get(0);
            sa.User__c = admin2Id;
            try {
                SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(newSurveyAssignmentList);
            } catch (Exception ex) {
                System.assertEquals('Survey Assignment record cannot create/update. Reason: user id and group id must be mutually exclusive.',
                    ex.getMessage());
            }
        } else {
            System.assertEquals(false, true, 'SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive test case 1 failed.');
        }

        newSurveyAssignmentList = [Select id, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                 From Survey_Assignment__c  where ID =  : groupSurveyAssignmentId];
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            Survey_Assignment__c sa = newSurveyAssignmentList.get(0);
            sa.GroupId__c = null;
            sa.User__c = null;
            try {
                SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(newSurveyAssignmentList);
            } catch (Exception ex) {
                System.assertEquals('Survey Assignment record cannot create or update. Reason: user id and group id are both blank.', 
                    ex.getMessage());
            }
        } else {
            System.assertEquals(false, true, 'SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive test case 2 failed.');
        }

        newSurveyAssignmentList = [Select id, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                 From Survey_Assignment__c  where ID =  : groupSurveyAssignmentId];
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            Survey_Assignment__c sa = newSurveyAssignmentList.get(0);
            sa.Assignment_Nature__c = surveyAssignmentObjectUtil.NATURE_ADMINISTRATOR;
            try {
                SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(newSurveyAssignmentList);
            } catch (Exception ex) {
                System.assertEquals('Assignment nature must be ' + SurveyAssignmentObjectUtil.NATURE_TAKER + 
                                    ' when groupd id is inputted.', ex.getMessage());
            }
        } else {
            System.assertEquals(false, true, 'SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive test case 3 failed.');
        }

        newSurveyAssignmentList = [Select id, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                 From Survey_Assignment__c  where ID =  : groupSurveyAssignmentId];
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            Survey_Assignment__c sa = newSurveyAssignmentList.get(0);
            sa.Assignment_Nature__c = null;
            try {
                SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(newSurveyAssignmentList);
            } catch (Exception ex) {
                System.assertEquals('Assignment nature cannot be blank.', ex.getMessage());
            }
        } else {
            System.assertEquals(false, true, 'SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive test case 4 failed.');
        }

        newSurveyAssignmentList = [Select id, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                 From Survey_Assignment__c  where ID =  : groupSurveyAssignmentId];
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            try {
                Survey_Assignment__c sa = newSurveyAssignmentList.get(0);
                sa.Assignment_Nature__c = surveyAssignmentObjectUtil.NATURE_TAKER;
                SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(newSurveyAssignmentList);
            } catch (Exception ex) {
                System.assert(false);
            }
        }
    }

    @isTest static void testValidateMutuallyExclusiveAdminAssignment() {
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String adminSurveyAssignmentId = surveyTestingUtil.adminSurveyAssignmentId;
        String group2Id = surveyTestingUtil.group2Id;
        
        List<Survey_Assignment__c> newSurveyAssignmentList = [Select id, Name, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                                             From Survey_Assignment__c  where ID =  : adminSurveyAssignmentId];
        
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            Survey_Assignment__c sa = newSurveyAssignmentList.get(0);
            sa.GroupId__c = group2Id;
            try {
                SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(newSurveyAssignmentList);
            } catch (Exception ex) {
                System.assertEquals('Survey Assignment record cannot create/update. Reason: user id and group id must be mutually exclusive.',
                    ex.getMessage());
            }
        } else {
            System.assertEquals(false, true, 'SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive test case 1 failed.');
        }

        newSurveyAssignmentList = [Select id, Name, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                 From Survey_Assignment__c  where ID =  : adminSurveyAssignmentId];
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            Survey_Assignment__c sa = newSurveyAssignmentList.get(0);
            sa.User__c = null;
            sa.GroupId__c = null;
            try {
                SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(newSurveyAssignmentList);
            } catch (Exception ex) {
                System.assertEquals('Survey Assignment record cannot create or update. Reason: user id and group id are both blank.', 
                    ex.getMessage());
            }
        } else {
            System.assertEquals(false, true, 'SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive test case 2 failed.');
        }

        newSurveyAssignmentList = [Select id, Name,  User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                 From Survey_Assignment__c  where ID =  : adminSurveyAssignmentId];
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            try {
                Survey_Assignment__c sa = newSurveyAssignmentList.get(0);
                sa.Assignment_Nature__c = surveyAssignmentObjectUtil.NATURE_TAKER;
                SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(newSurveyAssignmentList);
            } catch (Exception ex) {
                System.assert(false);
            }
        } 

        newSurveyAssignmentList = [Select id, Name, User__c, GroupId__c, Survey__c, Assignment_Nature__c 
                                 From Survey_Assignment__c  where ID =  : adminSurveyAssignmentId];
        if (newSurveyAssignmentList != null && newSurveyAssignmentList.size() > 0) {
            try {
                Survey_Assignment__c sa = newSurveyAssignmentList.get(0);
                sa.Assignment_Nature__c = surveyAssignmentObjectUtil.NATURE_ADMINISTRATOR;
                SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(newSurveyAssignmentList);
            } catch (Exception ex) {
                System.assert(false);
            }
        } 
    }

    @isTest static void testDeleteSurveyAssignmentNameSameAsSurveyOwner() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerSurveyAssignmentId = surveyTestingUtil.ownerSurveyAssignmentId;
        String group2Id = surveyTestingUtil.group2Id;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> ownerSurveyAssignmentList = [Select id, Name, User__c, GroupId__c, Survey__c, Assignment_Nature__c, User__r.Name
                                                                 From Survey_Assignment__c  where ID =  : ownerSurveyAssignmentId];
            
            if (ownerSurveyAssignmentList != null && ownerSurveyAssignmentList.size() > 0) {
                Survey_Assignment__c sa = ownerSurveyAssignmentList.get(0);
                String userId = sa.User__c;
                String userName = sa.User__r.Name;
                List<Survey__c> listSurvey = [Select Id, Name From Survey__c where id = :surveyId];     
                try {
                    delete sa;
                } catch (Exception ex) {
                    System.assert(ex.getMessage().contains('Survey Assignment record cannot delete. Reason: ' 
                                +  userName + '(' + userId + ') is survey owner of ' + listSurvey.get(0).Name));
                }
            } else {
                System.assertEquals(false, true, 'SurveyAssignmentTriggerHandler.validateDeleteSurveyAssignment test case 1 failed.');
            }
        }
    }
}