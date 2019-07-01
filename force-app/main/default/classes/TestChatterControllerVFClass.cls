@isTest
private class TestChatterControllerVFClass {

    static testMethod void myUnitTest() {            
        String groupName = 'ACG-Test Group' + TestClassUtil.generateRandomString();
        CollaborationGroup chatterGroup = new CollaborationGroup(Name=groupName, CollaborationType='Public');
        chatterGroup.OwnerId = UserInfo.getUserId() ;
        try {
            insert chatterGroup;
        } catch (exception ex) {
            
        }       
        
        ChatterController extn = new ChatterController();
        extn.chatterID = chatterGroup.Id;
        String chatterGroupName = extn.chatterGroupName;
           
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardtestuser@talgroup.com', 
            EmailEncodingKey='UTF-8', LastName='TestingACG', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardtestuser@talgroup.com');
        
        insert u;
        System.runAs(u) {            
            Boolean canPost = extn.bCanPost;                 
            System.assertEquals(false, canPost);  
        }
        
    }
}