@isTest
private class TestACGArticleWrapperClass {

    static testMethod void myUnitTest() {
        Portal_Content__c announcement = TestClassUtil.getAnnouncement();
        insert announcement;
        Map<Id, String> mapId2Image = new Map<Id, String>();
        mapId2Image.put(announcement.Id, 'url');
        ACGArticleWrapper aw = new ACGArticleWrapper(announcement, mapId2Image);
        System.assertEquals(true, aw.showDefault);
        
        Map<Id, List<FeedItem>> mapFeedItems = new Map<Id, List<FeedItem>>();
        List<FeedItem> itms = new List<FeedItem>();
        mapFeedItems.put(announcement.Id, itms);
        ACGArticleWrapper aw2 = new ACGArticleWrapper(announcement, 0, mapFeedItems, mapId2Image);
        System.assertEquals(0, aw2.feedsize);
        System.assertEquals('url', aw2.imageURL);
        announcement.Tech_Id__c = announcement.Id;
        announcement.Id = null;
        ACGArticleWrapper aw3 = new ACGArticleWrapper(announcement, 0, mapFeedItems, mapId2Image);
        System.assertEquals(0, aw3.feedsize);
        System.assertEquals('url', aw3.imageURL);
    }
}