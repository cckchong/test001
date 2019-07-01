/**
 * @description test class for ACGFeedItemUtil
 */
@isTest
public class TestACGFeedItemUtil {

    @IsTest
    public static void testTextPost() {
        CollaborationGroup cg = TestClassUtil.getChatterGroup();
        cg.Name = 'Happy Chatter Group';
        insert cg;
        
        Portal_Content__c pc = TestClassUtil.getSettings();
        pc.Chatter_Feed_ID__c = cg.Id;
        pc.Content_Type__c = 'Chatter';
        pc.Component_Number__c = '1';
        
        insert pc;
        
        Set<Id> groupIds = new Set<Id>();
        groupIds.add(cg.Id);
        Map<String, Portal_Content__c> mapChatterGroup = ACGUtil.getAssociatedChatterGroup(groupIds);
        
        System.assertEquals(1, mapChatterGroup.size());
        
        FeedItem fi = new FeedItem(
        	Body = 'Hi Snow',
            Type = 'TextPost',
            ParentId = cg.Id
        );
        
        insert fi;
        
        List<Portal_Content__c> myArticle = [SELECT Id, Title__c, Tech_Article_Feed_Item_Id__c, Tech_Feed_Item_Id__c FROM Portal_Content__c WHERE RecordType.DeveloperName = 'Rich_Text'];
        System.assertEquals(1, myArticle.size());
        System.assertEquals(fi.Body, myArticle[0].Title__c);
        System.assertNotEquals('', myArticle[0].Tech_Article_Feed_Item_Id__c);
        System.assertNotEquals('', myArticle[0].Tech_Feed_Item_Id__c);
        
        FeedComment fc = new FeedComment(CommentBody='Right', FeedItemId = fi.Id);
        insert fc;
        
        List<FeedItem> fiArticle = [SELECT Id, CommentCount FROM FeedItem WHERE Id =: myArticle[0].Tech_Article_Feed_Item_Id__c];
        System.assertEquals(1, fiArticle[0].CommentCount);
        
        FeedComment fc2 = new FeedComment(CommentBody='Right', FeedItemId = myArticle[0].Tech_Article_Feed_Item_Id__c);
        insert fc2;
        
        //List<FeedItem> fiPost = [SELECT Id, CommentCount FROM FeedItem WHERE Id =: fi.Id];
        //System.assertEquals(2, fiPost[0].CommentCount);
        fiArticle = [SELECT Id, CommentCount FROM FeedItem WHERE Id =: myArticle[0].Tech_Article_Feed_Item_Id__c];
        System.assertEquals(2, fiArticle[0].CommentCount);
        
        
    }
    
    @IsTest
    public static void testContentPost() {
        
        CollaborationGroup cg = TestClassUtil.getChatterGroup();
        cg.Name = 'Happy Chatter Group';
        insert cg;
        
        Portal_Content__c pc = TestClassUtil.getSettings();
        pc.Chatter_Feed_ID__c = cg.Id;
        pc.Content_Type__c = 'Chatter';
        pc.Component_Number__c = '1';
        
        insert pc;
        
        Set<Id> groupIds = new Set<Id>();
        groupIds.add(cg.Id);
        Map<String, Portal_Content__c> mapChatterGroup = ACGUtil.getAssociatedChatterGroup(groupIds);
        
        System.assertEquals(1, mapChatterGroup.size());
        
        FeedItem fi = TestClassUtil.getChatterFile();
        fi.ParentId = cg.Id;
        insert fi;
        
        List<Portal_Content__c> myArticle = [SELECT Id, Title__c FROM Portal_Content__c WHERE RecordType.DeveloperName = 'Rich_Text'];
        System.assertEquals(1, myArticle.size());
    }
    
    @IsTest
    public static void testLinkPost() {
        CollaborationGroup cg = TestClassUtil.getChatterGroup();
        cg.Name = 'Happy Chatter Group';
        insert cg;
        
        Portal_Content__c pc = TestClassUtil.getSettings();
        pc.Chatter_Feed_ID__c = cg.Id;
        pc.Content_Type__c = 'Chatter';
        pc.Component_Number__c = '1';
        
        insert pc;
        
        Set<Id> groupIds = new Set<Id>();
        groupIds.add(cg.Id);
        Map<String, Portal_Content__c> mapChatterGroup = ACGUtil.getAssociatedChatterGroup(groupIds);
        
        System.assertEquals(1, mapChatterGroup.size());
        
        FeedItem fi = new FeedItem(
        	Body = 'Hi Snow',
            Type = 'LinkPost',
            LinkUrl = 'http://www.google.com',
            ParentId = cg.Id
        );
        
        insert fi;
        
        List<Portal_Content__c> myArticle = [SELECT Id, Title__c FROM Portal_Content__c WHERE RecordType.DeveloperName = 'Rich_Text'];
        System.assertEquals(1, myArticle.size());
    }
    
    @IsTest
    public static void testAdvancedTextPost() {
        CollaborationGroup cg = TestClassUtil.getChatterGroup();
        cg.Name = 'Happy Chatter Group';
        insert cg;
        
        Portal_Content__c pc = TestClassUtil.getSettings();
        pc.Chatter_Feed_ID__c = cg.Id;
        pc.Content_Type__c = 'Chatter';
        pc.Component_Number__c = '1';
        
        insert pc;
        
        Set<Id> groupIds = new Set<Id>();
        groupIds.add(cg.Id);
        Map<String, Portal_Content__c> mapChatterGroup = ACGUtil.getAssociatedChatterGroup(groupIds);
        
        System.assertEquals(1, mapChatterGroup.size());
        
        FeedItem fi = new FeedItem(
        	Body = 'Hi Snow',
            Type = 'AdvancedTextPost',
            ParentId = cg.Id
        );
        
        insert fi;
        
        List<Portal_Content__c> myArticle = [SELECT Id, Title__c FROM Portal_Content__c WHERE RecordType.DeveloperName = 'Rich_Text'];
        System.assertEquals(0, myArticle.size());
    }
}