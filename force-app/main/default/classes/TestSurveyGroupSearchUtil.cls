@isTest
private class TestSurveyGroupSearchUtil {
    
    @isTest static void testSearchNestedGroupMembers() {
        SurveyGroupSearchTestingUtil util = new SurveyGroupSearchTestingUtil();
        String ownerId = util.ownerId;
        String group2Id = util.group2Id;
        String group1Id = util.group1Id;
        
        List<String> ownerIdList = new List<String>();
        List<String> group2IdList = new List<String>();
        List<String> group1IdList = new List<String>();
        
        ownerIdList.add(ownerId);
        group2IdList.add(group2Id);
        group1IdList.add(group1Id);        

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {

            //Set<String> setUsers = SurveyGroupSearchUtil.searchGroupMembers(group2Id);          
            Set<String> setUsers = SurveyGroupSearchUtil.searchGroupMembers(group2IdList);          
            System.assertEquals(2, setUsers.size());
            //System.assert(setUsers.contains(util.Taker1Id));
            //System.assert(setUsers.contains(util.Taker2Id));
            //System.assert(setUsers.contains(util.Taker4Id));
            //System.assert(setUsers.contains(util.Taker5Id));

            //setUsers = SurveyGroupSearchUtil.searchGroupMembers(group1Id);          
            setUsers = SurveyGroupSearchUtil.searchGroupMembers(group1IdList);          
            System.assertEquals(4, setUsers.size());
            System.assert(setUsers.contains(util.Taker1Id));
            System.assert(setUsers.contains(util.Taker2Id));
            //System.assert(setUsers.contains(util.Taker3Id));
            //System.assert(setUsers.contains(util.Taker4Id));
            //System.assert(setUsers.contains(util.Taker5Id));
        }
    }
    
    @isTest static void testSearchTopLevelGroupMembers() {
        SurveyGroupSearchTestingUtil util = new SurveyGroupSearchTestingUtil();
        String ownerId = util.ownerId;
        String group3Id = util.group3Id;
        
        List<String> group3IdList = new List<String>();        
        group3IdList.add(group3Id);        

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {

            //Set<String> setUsers = SurveyGroupSearchUtil.searchGroupMembers(group3Id);          
            Set<String> setUsers = SurveyGroupSearchUtil.searchGroupMembers(group3IdList);          
            System.assertEquals(2, setUsers.size());
            System.assert(setUsers.contains(util.Taker1Id));
            System.assert(setUsers.contains(util.Taker3Id));
        }
    }
    
    @isTest static void testSearchLateSurveyTaker() {
        SurveyGroupSearchTestingUtil util = new SurveyGroupSearchTestingUtil();
        String surveyId = util.surveyId;
        String ownerId = util.ownerId;
        String group2Id = util.group2Id;
        String group3Id = util.group2Id;
        String group1Id = util.group2Id;
        //add by DTT
        survey__c mySurvey=[select id, Is_Public__c from survey__c where id=:surveyId];
        mySurvey.Is_Public__c='P';  
        mySurvey.Allow_Anonymous__c=true;
        update mySurvey;   
        //add by DTT

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {

            List<User> lstUsers = SurveyGroupSearchUtil.searchLateSurveyTaker(surveyId);            
            System.assertEquals(1, lstUsers.size());

            Set<String> setUsers = new Set<String>();
            for (User user : lstUsers) {
                setUsers.add(user.Id);
            }
            System.assertEquals(1, setUsers.size());

            System.assert(setUsers.contains(util.Taker2Id));
            //System.assert(setUsers.contains(util.Taker3Id));
            //System.assert(setUsers.contains(util.Taker4Id));
            //System.assert(setUsers.contains(util.Taker5Id));

            System.assertEquals(1, SurveyGroupSearchUtil.getNumLateTakers(surveyId));
        }
    }
    //add by DTT
    @isTest static void testSearchLateSurveyTakerPublic() {
        SurveyGroupSearchTestingUtil util = new SurveyGroupSearchTestingUtil();
        String surveyId = util.surveyId;
        String ownerId = util.ownerId;
        String group2Id = util.group2Id;
        String group3Id = util.group2Id;
        String group1Id = util.group2Id;
       
        survey__c mySurvey=[select id, Is_Public__c from survey__c where id=:surveyId];
        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {

            List<User> lstUsers = SurveyGroupSearchUtil.searchLateSurveyTaker(surveyId);            
            // System.assertEquals(1, lstUsers.size());

            Set<String> setUsers = new Set<String>();
            for (User user : lstUsers) {
                setUsers.add(user.Id);
            }
            // System.assertEquals(1, setUsers.size());

            System.assert(!setUsers.contains(util.Taker2Id));
            //System.assert(setUsers.contains(util.Taker3Id));
            //System.assert(setUsers.contains(util.Taker4Id));
            //System.assert(setUsers.contains(util.Taker5Id));

            // System.assertEquals(1, SurveyGroupSearchUtil.getNumLateTakers(surveyId));

            boolean usertest=SurveyGroupSearchUtil.isUser(u.id);
            System.assertEquals(true, usertest);
        }
    }
}