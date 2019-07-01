@isTest
private class TestSurveyTriggerHandler {
    
    @isTest static void testDeleteSurvey() {
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        List<String> listAssignmentIds = new List<String>();
        listAssignmentIds.add(surveyTestingUtil.ownerSurveyAssignmentId);
        listAssignmentIds.add(surveyTestingUtil.groupSurveyAssignmentId);
        listAssignmentIds.add(surveyTestingUtil.adminSurveyAssignmentId);
        listAssignmentIds.add(surveyTestingUtil.takerSurveyAssignmentId);

        User u = [Select Id, Name, UserName From User where id = :ownerId];
        System.runAs(u) {
            Survey__c survey = [Select Id From Survey__c Where ID = :surveyId limit 1];
            delete survey;

            // verify all survey assignment records associated to this survey does not exist
            List<Survey_Assignment__c> lstSurveyAssignments = [Select Id From Survey_Assignment__c 
                                                  Where Id IN :listAssignmentIds];
            System.assertEquals(0, lstSurveyAssignments.size());
        }
    }
    
    @isTest static void testChangeSurveyOwner() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;
        String adminId = surveyTestingUtil.adminId;
        String newOwnerId = surveyTestinGUtil.newOwnerId;
        String group2Id = surveyTestingUtil.group2Id;
        String ownerSurveyAssignmentId = surveyTestingUtil.ownerSurveyAssignmentId;
        String group2SurveyAssignmentId = null;

        User u = [Select id, Name From User Where id = :adminId];
        System.runAs(u) {
            Survey_Assignment__c newSas = new Survey_Assignment__c();
            newSas.Survey__c = surveyId;
            newSas.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
            newSas.GroupId__c = group2Id;
            insert newSas;
            group2SurveyAssignmentId = newSas.Id;
        }

        List<String> listAssignmentIds = new List<String>();
        listAssignmentIds.add(surveyTestingUtil.ownerSurveyAssignmentId);
        listAssignmentIds.add(surveyTestingUtil.groupSurveyAssignmentId);
        listAssignmentIds.add(surveyTestingUtil.adminSurveyAssignmentId);
        listAssignmentIds.add(surveyTestingUtil.takerSurveyAssignmentId);
        listAssignmentIds.add(group2SurveyAssignmentId);

        User u2 = [Select Id, Name, UserName From User where id = :ownerId];
        System.runAs(u2) {

            Survey__c survey = [Select Id From Survey__c Where ID = :surveyId limit 1];
            if (survey != null) {
                survey.OwnerId = newOwnerId;
                update survey;

                // verify survey assignment record of old owner is deleted
                List<Survey_Assignment__c> lstOldOwnerAssignment = [Select Id From Survey_Assignment__c 
                                                  Where ID = :ownerSurveyAssignmentId];
                System.assertEquals(0, lstOldOwnerAssignment.size());
            
                // verify old owner does not have access to the survey and survey assignment records associated 
                // to the survey
                List<Survey__Share> lstSurveyShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey__Share 
                                                  Where ParentId = :surveyId AND UserOrGroupId = :ownerId];
                System.assertEquals(0, lstSurveyShare.size());
            
                List<Survey_Assignment__Share> lstOldOwnerAssignmentShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey_Assignment__Share 
                                                  Where ParentId IN :listAssignmentIds AND UserORGroupId = :ownerId];
                System.assertEquals(0, lstOldOwnerAssignmentShare.size());
            
                // verify admin survey assignment record is created for new owner
                List<Survey_Assignment__c> lstNewOwnerAssignment = [Select Id, User__c, Assignment_Nature__c From Survey_Assignment__c 
                                                  Where Survey__c = :surveyId AND User__c = :newOwnerId];
                System.assertEquals(1, lstNewOwnerAssignment.size());
                System.assertEquals(SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR, lstNewOwnerAssignment.get(0).Assignment_Nature__c);            
                
                List<String> listNewAssignmentIds = new List<String>();
                listNewAssignmentIds.add(lstNewOwnerAssignment.get(0).Id);
                listNewAssignmentIds.add(surveyTestingUtil.groupSurveyAssignmentId);
                listNewAssignmentIds.add(surveyTestingUtil.adminSurveyAssignmentId);
                listNewAssignmentIds.add(surveyTestingUtil.takerSurveyAssignmentId);
                listNewAssignmentIds.add(group2SurveyAssignmentId);

                // verify new owner can access the survey and survey assignment records associated to the survey
                List<Survey__Share> lstNewOwnerSurveyShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey__Share 
                                                  Where ParentId = :surveyId AND UserOrGroupId = :newOwnerId];
                System.assertEquals(1, lstNewOwnerSurveyShare.size());
                System.assertEquals(Survey__Share.RowCause.Owner, lstNewOwnerSurveyShare.get(0).RowCause);

                List<Survey_Assignment__Share> lstNewOwnerAssignmentShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey_Assignment__Share 
                                                  Where ParentId IN :listNewAssignmentIds AND UserOrGroupId = :newOwnerId];
                System.assertEquals(5, lstNewOwnerAssignmentShare.size());
                // 4 owner row clause and 1 survey administrator row cause
                Map <String, Survey_Assignment__Share> mapNewShare = new Map<String, Survey_Assignment__Share>();
                for (Survey_Assignment__Share sas : lstNewOwnerAssignmentShare) {
                    mapNewshare.put(sas.ParentId, sas);
                }
                System.assertEquals(true, mapNewshare.containsKey(lstNewOwnerAssignment.get(0).Id));
                System.assertEquals(true, mapNewshare.containsKey(surveyTestingUtil.groupSurveyAssignmentId));
                System.assertEquals(true, mapNewshare.containsKey(surveyTestingUtil.adminSurveyAssignmentId));
                System.assertEquals(true, mapNewshare.containsKey(surveyTestingUtil.takerSurveyAssignmentId));
                System.assertEquals(true, mapNewshare.containsKey(group2SurveyAssignmentId));

                System.assertEquals(Survey_Assignment__Share.RowCause.Owner, mapNewshare.get(lstNewOwnerAssignment.get(0).Id).RowCause);
                System.assertEquals(Survey_Assignment__Share.RowCause.Owner, mapNewshare.get(surveyTestingUtil.groupSurveyAssignmentId).RowCause);
                System.assertEquals(Survey_Assignment__Share.RowCause.Owner, mapNewshare.get(surveyTestingUtil.adminSurveyAssignmentId).RowCause);
                System.assertEquals(Survey_Assignment__Share.RowCause.Owner, mapNewshare.get(surveyTestingUtil.takerSurveyAssignmentId).RowCause);
                System.assertEquals(Survey_Assignment__Share.RowCause.Survey_Administrator__c, mapNewshare.get(group2SurveyAssignmentId).RowCause);

                // verify survey owner is updated
                survey = [Select Id, OwnerId From Survey__c Where ID = :surveyId limit 1];
                System.assertEquals(newOwnerId, survey.OwnerId);

                // verify survey assignment records' owner is updated
                lstNewOwnerAssignment = [Select Id From Survey_Assignment__c 
                                                  Where Survey__c = :surveyId and OwnerId = :newOwnerId];
                System.assertEquals(5, lstNewOwnerAssignment.size());
            }       
        }
    }

    @isTest static void testChangeSurveyOwnerToSurveyAdmin() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;
        String adminId = surveyTestingUtil.adminId;
        String group2Id = surveyTestingUtil.group2Id;
        String ownerSurveyAssignmentId = surveyTestingUtil.ownerSurveyAssignmentId;
        String adminSurveyAssignmentId = surveyTestingUtil.adminSurveyAssignmentId;
        String groupSurveyAssignmentId = surveyTestingUtil.groupSurveyAssignmentId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;
        String group2SurveyAssignmentId = null;

        User u = [Select id, Name From User Where id = :adminId];
        System.runAs(u) {
            Survey_Assignment__c newSas = new Survey_Assignment__c();
            newSas.Survey__c = surveyId;
            newSas.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
            newSas.GroupId__c = group2Id;
            insert newSas;
            group2SurveyAssignmentId = newSas.Id;
        }

        List<String> listAssignmentIds = new List<String>();
        listAssignmentIds.add(ownerSurveyAssignmentId);
        listAssignmentIds.add(groupSurveyAssignmentId);
        listAssignmentIds.add(adminSurveyAssignmentId);
        listAssignmentIds.add(takerSurveyAssignmentId);
        listAssignmentIds.add(group2SurveyAssignmentId);

        User u2 = [Select Id, Name, UserName From User where id = :ownerId];
        System.runAs(u2) {

            // adminId is already a survey administrator
            Survey__c survey = [Select Id From Survey__c Where ID = :surveyId limit 1];
            if (survey != null) {
                survey.OwnerId = adminId;
                update survey;

                // verify survey assignment record of old owner is deleted
                List<Survey_Assignment__c> lstOldOwnerAssignment = [Select Id From Survey_Assignment__c 
                                                  Where ID = :ownerSurveyAssignmentId];
                System.assertEquals(0, lstOldOwnerAssignment.size());
            
                // verify old owner does not have access to the survey and survey assignment records associated 
                // to the survey
                List<Survey__Share> lstSurveyShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey__Share 
                                                  Where ParentId = :surveyId AND UserOrGroupId = :ownerId];
                System.assertEquals(0, lstSurveyShare.size());
            
                List<Survey_Assignment__Share> lstOldOwnerAssignmentShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey_Assignment__Share 
                                                  Where ParentId IN :listAssignmentIds AND UserORGroupId = :ownerId];
                System.assertEquals(0, lstOldOwnerAssignmentShare.size());
            
                // verify exactly one admin survey assignment record is created for the new owner
                List<Survey_Assignment__c> lstNewOwnerAssignment = [Select Id, User__c, Assignment_Nature__c From Survey_Assignment__c 
                                                  Where Survey__c = :surveyId AND User__c = :adminId];
                System.assertEquals(1, lstNewOwnerAssignment.size());
                System.assertEquals(adminSurveyAssignmentId, lstNewOwnerAssignment.get(0).Id);
                System.assertEquals(SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR, lstNewOwnerAssignment.get(0).Assignment_Nature__c);            
                
                List<String> listNewAssignmentIds = new List<String>();
                listNewAssignmentIds.add(groupSurveyAssignmentId);
                listNewAssignmentIds.add(adminSurveyAssignmentId);
                listNewAssignmentIds.add(takerSurveyAssignmentId);
                listNewAssignmentIds.add(group2SurveyAssignmentId);

                // verify new owner can access the survey and survey assignment records associated to the survey
                List<Survey__Share> lstNewOwnerSurveyShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey__Share 
                                                  Where ParentId = :surveyId AND UserOrGroupId = :adminId];
                System.assertEquals(2, lstNewOwnerSurveyShare.size());

                Set<String> setRowCause = new Set<String>();
                for (Survey__Share ss : lstNewOwnerSurveyShare) {
                    setRowCause.add(ss.RowCause);
                }
                System.assertEquals(2, setRowCause.size());
                System.assert(setRowCause.contains(Survey__Share.RowCause.Owner));
                System.assert(setRowCause.contains(Survey__Share.RowCause.Administrator__c));

                List<Survey_Assignment__Share> lstNewOwnerAssignmentShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey_Assignment__Share 
                                                  Where ParentId IN :listNewAssignmentIds AND UserOrGroupId = :adminId];
                System.assertEquals(7, lstNewOwnerAssignmentShare.size());

                // verify survey owner is updated
                survey = [Select Id, OwnerId From Survey__c Where ID = :surveyId limit 1];
                System.assertEquals(adminId, survey.OwnerId);

                // verify survey assignment records' owner is updated
                lstNewOwnerAssignment = [Select Id From Survey_Assignment__c 
                                                  Where Survey__c = :surveyId and OwnerId = :adminId];
                System.assertEquals(5, lstNewOwnerAssignment.size());
            }       
        }
    }

    @isTest static void testUpdateSurveyExceptOwnerField() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;
        String adminId = surveyTestingUtil.adminId;
        String ownerSurveyAssignmentId = surveyTestingUtil.ownerSurveyAssignmentId;
        String adminSurveyAssignmentId = surveyTestingUtil.adminSurveyAssignmentId;
        String groupSurveyAssignmentId = surveyTestingUtil.groupSurveyAssignmentId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;

        List<String> listAssignmentIds = new List<String>();
        listAssignmentIds.add(ownerSurveyAssignmentId);
        listAssignmentIds.add(groupSurveyAssignmentId);
        listAssignmentIds.add(adminSurveyAssignmentId);
        listAssignmentIds.add(takerSurveyAssignmentId);

        User u = [Select Id, Name, UserName From User where id = :adminId];
        System.runAs(u) {

            Survey__c survey = [Select Id From Survey__c Where ID = :surveyId limit 1];
            if (survey != null) {
                survey.Thank_You_Text__c = 'thank you text modified.';
                survey.Survey_Header__c = 'survey header modified.';
                survey.Survey_Toggle__c = false;
                update survey;

                // verify no change to survey and survey assignment records         
                List<Survey__Share> lstSurveyShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey__Share 
                                                  Where ParentId = :surveyId AND UserOrGroupId = :ownerId];
                System.assertEquals(1, lstSurveyShare.size());

                lstSurveyShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey__Share 
                                                  Where ParentId = :surveyId AND UserOrGroupId = :adminId];
                System.assertEquals(1, lstSurveyShare.size());

                List<Survey_Assignment__Share> lstOldOwnerAssignmentShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey_Assignment__Share 
                                                  Where ParentId IN :listAssignmentIds AND UserORGroupId = :ownerId];
                System.assertEquals(4, lstOldOwnerAssignmentShare.size());
                for (Survey_Assignment__Share sas : lstOldOwnerAssignmentShare) {
                    System.assertEquals(Survey_Assignment__Share.RowCause.Owner, sas.RowCause);             
                }

                List<Survey_Assignment__Share> lstAdminAssignmentShare = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                  From Survey_Assignment__Share 
                                                  Where ParentId IN :listAssignmentIds AND UserORGroupId = :adminId];
                System.assertEquals(4, lstAdminAssignmentShare.size());
                for (Survey_Assignment__Share sas : lstAdminAssignmentShare) {
                    System.assertEquals(Survey_Assignment__Share.RowCause.Survey_Administrator__c, sas.RowCause);               
                }
            
                // verify survey owner is updated
                survey = [Select Id, OwnerId, Thank_You_Text__c, Survey_Header__c, Survey_Toggle__c From Survey__c Where ID = :surveyId limit 1];
                System.assertEquals(ownerId, survey.OwnerId);
                System.assertEquals('thank you text modified.', survey.Thank_You_Text__c);
                System.assertEquals('survey header modified.', survey.Survey_Header__c);
                System.assertEquals(false, survey.Survey_Toggle__c);

                // verify survey assignment records' owner is updated
                List<Survey_Assignment__c> lstAssignments = [Select Id From Survey_Assignment__c 
                                                            Where Survey__c = :surveyId and OwnerId = :ownerId];
                System.assertEquals(5, lstAssignments.size());
            }       
        }
    }
    
}