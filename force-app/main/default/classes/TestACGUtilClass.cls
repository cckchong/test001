@isTest
private class TestACGUtilClass {

    static testMethod void myUnitTest() {
        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
		Portal_Content__c announcement = TestClassUtil.getAnnouncement();
        listToCreate.add(announcement);
        insert listToCreate;
        
        Portal_Content__c pc = ACGUtil.getfullArticle(announcement.Id);
        System.assertEquals(pc.title_en__c, announcement.title_en__c);
        
        List<Portal_Content__c> pcs = ACGUtil.getPageArticleFeeds('General', 'Site', 'TALCORP', 5, true);
        System.assertEquals(1, pcs.size());
        
        Integer i = ACGUtil.getPageArticleFeedsCount('General', 'Site', 'TALCORP', 72);
        System.assertEquals(1, i);
        
        Portal_Content__c template = TestClassUtil.getTemplate();
	    insert template;	
	        
        Portal_Content__c settingMainPage = TestClassUtil.getSettings();
        settingMainPage.Template_ID__c = template.Id;
        settingMainPage.Content_Category__c = 'General';
        settingMainPage.Distribution_Level__c = 'Site';
        settingMainPage.Distribution_Target__c = 'TALCORP';
        insert settingMainPage;
        
        pc = ACGUtil.getACGSettingByUniquePageName('MainPage_General_Site_TALCORP');
        System.assertEquals('MainPage_General_Site_TALCORP', pc.Unique_Page_Name__c);
        
        pc = ACGUtil.getACGSettingById(settingMainPage.Id, 'Settings');
        System.assertEquals('MainPage_General_Site_TALCORP', pc.Unique_Page_Name__c);
        
        pc = ACGUtil.getUserPreferLanguageArticle(announcement, 'en');        
        System.assertEquals(announcement.Title_en__c, pc.Title__c);
        
        List<ACG_Hierarchy__c> acgs = ACGUtil.getPageListValues('TALCORP');
        String str = ACGUtil.getDivisonName('TALCORP');
        
        str = ACGUtil.getPageURL('TALCORP', 'Site');
        
        acgs = ACGUtil.getACGList('General', 'Group', 'TALGroup');        
        acgs = ACGUtil.getACGList('General', 'Division', 'Apparel');
        acgs = ACGUtil.getACGList('General', 'Site', 'TALCORP');
        acgs = ACGUtil.getACGLevelList('General','TALCORP');
    }
}