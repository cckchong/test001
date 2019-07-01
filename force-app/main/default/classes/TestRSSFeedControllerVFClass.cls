@isTest
private class TestRSSFeedControllerVFClass {

	static testMethod void RSSfeed() {            		
        RSSFeedController extn = new RSSFeedController();
        system.assertEquals(10, extn.numColumn);
    }
}