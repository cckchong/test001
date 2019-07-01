@isTest(SeeAllData=true)
private class TestFeedCommentTriggerHandler {    
    
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
        
        //Add manager Role to another chatter group
        CollaborationGroup chatterGroupManager = TestClassUtil.getChatterGroup();
        chatterGroupManager.Name = Label.ACGChatterGroupPrefix + 'TEST' + Label.ACGChatterGroupSuffix;
        insert chatterGroupManager;
        
        User admin = [Select Id, Name From User where id = :Label.ServiceAccountUserId];
		System.runAs(admin) {
	        FeedItem f = new FeedItem();
	        f.ParentId = chatterGroup.Id;
	        f.Body = 'Announcement: ' + announcement.Title_en__c + ' \n\n '+ announcement.Summary_en__c;
	        f.type='LinkPost';
	        f.Title = '[Read More]';
	        f.LinkURL = '/' + announcement.Id;
	        f.CreatedById = Label.ServiceAccountUserId; 
	        insert (f);
	        
	        FeedComment fc = new FeedComment();
	        fc.CommentBody = 'Thanks';
	        fc.FeedItemId = f.Id;
	        insert (fc);
		}
        List<FeedItem> feeds = [Select Type, Title, ParentId, LinkUrl, LikeCount, Id, CreatedBy.Name, CreatedById, Body, CreatedDate, LastModifiedDate
                                From FeedItem                           
                                Where ParentId = :chatterGroup.Id];
        
        List<FeedComment> comments = [Select Id, CommentBody, FeedItemId, ParentId
                                From FeedComment                           
                                Where ParentId = :chatterGroup.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardtestuser@talgroup.com', 
            EmailEncodingKey='UTF-8', LastName='TestingACG', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardtestuser@talgroup.com');
        
        insert u;
        System.runAs(u) {            
            FeedItemTriggerHandler.validatePostingRight(feeds);
            FeedCommentTriggerHandler.validatePostingRight(comments);
        }
    }
    
}