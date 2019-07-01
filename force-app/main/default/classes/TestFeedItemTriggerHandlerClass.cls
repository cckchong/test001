@isTest(SeeAllData=true)
private class TestFeedItemTriggerHandlerClass {
    
    static testMethod void negativeCase() {
        
        Portal_Content__c announcement = TestClassUtil.getAnnouncement();
        insert announcement;
        
        String groupName = Label.ACGChatterGroupPrefix + Label.ACGChatterGroupGeneral + 'Apparel' + Label.ACGChatterGroupSuffix;
        CollaborationGroup chatterGroup = TestClassUtil.getChatterGroup();
        chatterGroup.Name = groupName;
        try {
            insert chatterGroup;
        } catch (exception ex) {
            chatterGroup = [Select Id From CollaborationGroup Where Name =:groupName limit 1];
        }
        
        FeedItem f = new FeedItem();
        f.ParentId = chatterGroup.Id;
        f.Body = 'Announcement: ' + announcement.Title_en__c + ' \n\n '+ announcement.Summary_en__c;
        f.type='LinkPost';
        f.Title = '[Read More]';
        f.LinkURL = '/' + announcement.Id;
        f.CreatedById = Label.ServiceAccountUserId; 
        insert (f);
        system.assertEquals(false, f.Id == null);
        List<FeedItem> feeds = [Select Type, Title, ParentId, LinkUrl, LikeCount, Id, CreatedBy.Name, CreatedById, Body, CreatedDate, LastModifiedDate
                                From FeedItem                           
                                Where ParentId = :chatterGroup.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardtestuser@talgroup.com', 
            EmailEncodingKey='UTF-8', LastName='TestingACG', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardtestuser@talgroup.com');
        
        insert u;
        System.runAs(u) {            
            FeedItemTriggerHandler.validatePostingRight(feeds);
        }
    }
    
}