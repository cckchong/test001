@isTest
private class TestArticleControllerVFClass {
	/*
    static testMethod void readArticle() {    	
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        Portal_Content__c template = TestUtil.getTemplate();
	        insert template;	      
	        			
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
			Portal_Content__c announcement = TestUtil.getAnnouncement();
	        listToCreate.add(announcement); 
	        	        
	        Portal_Content__c settingDetailPage = TestUtil.getSettings();
	        settingDetailPage.Template_ID__c = template.Id;
	        settingDetailPage.Page_Name__c = 'DetailPage';
	        settingDetailPage.Content_Type__c = 'Rich Text';
	        settingDetailPage.Fixed_Component__c = 'Article Detail';
	        settingDetailPage.BU__c = '';	        
	        insert settingDetailPage;
	        	        
	        Portal_Content__c settingListPage = TestUtil.getSettings();
	        settingListPage.Template_ID__c = template.Id;
	        settingListPage.Page_Name__c = 'ListPage';
	        settingListPage.Content_Type__c = 'Rich Text';
	        settingListPage.Fixed_Component__c ='List View';
	        settingListPage.BU__c = '';
	        settingListPage.Child_Page__c = settingDetailPage.Id;
	        listToCreate.add(settingListPage);
	        insert listToCreate;
	        
	        Portal_Content__c settingMainPage = TestUtil.getSettings();
	        settingMainPage.Template_ID__c = template.Id;
	        settingMainPage.BU__c = '';
	        settingMainPage.Child_List_Page__c = settingListPage.Id;
	        settingMainPage.Child_Page__c = settingDetailPage.Id;
	        insert settingMainPage;
			
			Portal_Content__c p = [Select Id,Child_List_Unique_Page_Name__c, Child_Unique_Page_Name__c From Portal_Content__c Where Id =:settingMainPage.Id];
			
			System.assertEquals('ListPage_Local_TAL', p.Child_List_Unique_Page_Name__c);
			System.assertEquals('DetailPage_Local_TAL', p.Child_Unique_Page_Name__c);
			
			List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
			
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ArticleController extn = new  ArticleController();
	        extn.Category = 'Local';
	        extn.SubCategory = 'TAL';
	        extn.articleListPage = 'ListPage_Local_TAL';
	        extn.articleDetailPage = 'DetailPage_Local_TAL';
	        String lpURL = extn.articleListPageURL;
	        String dpURL = extn.articleDetailPageURL;
	        List<ArticleWrapper> listArticles = extn.getArticleFeed();
	        System.assertEquals(1, extn.iNoOfArticle);
	        System.assertEquals('Sample Title', listArticles.get(0).objpc.Title_en__c);
     	}	        
    }
    
    static testMethod void readArticleDept() {    	
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c announcement = TestUtil.getAnnouncement();
	        insert announcement;
	        
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	        
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('department', 'IT');
	        
	        ArticleController extn = new  ArticleController();
	        String dpURL = extn.articleDetailPageURL;
	        String lpURL = extn.articleListPageURL;
	        List<ArticleWrapper> listArticles = extn.getArticleFeed();
     	}	        
    }
    */
}