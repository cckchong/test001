@isTest
private class TestSurveyShareBatch{

    @isTest 
    static void testSurveyShareBatchInsert() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;
        String adminId = surveyTestingUtil.adminId;
        User u = [Select id, name, username from User where id = :ownerId];
        List<Survey_Assignment__Share>listAssignmentShareInsert=new List<Survey_Assignment__Share>();
        Survey_Assignment__Share sa_share = new Survey_Assignment__Share();
                    sa_share.UserOrGroupId = u.id;
                    sa_share.AccessLevel = 'Edit';
                    sa_share.RowCause = Survey_Assignment__Share.RowCause.Survey_Administrator__c;
                    sa_share.ParentId = surveyTestingUtil.adminSurveyAssignmentId;
        listAssignmentShareInsert.add(sa_share);            
        System.runAs(u) {
            SurveyShareBatch theBatch = new SurveyShareBatch(listAssignmentShareInsert);
              system.debug('listAssignmentShareInsert.size()='+listAssignmentShareInsert.size());
              ID batchProcessId = Database.executeBatch(theBatch,9500);
        }
    }
}