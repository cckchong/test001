@isTest
private class TestArticleListPageControllerVFClass {
	/*
	static testMethod void readArticle() {    	
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        Portal_Content__c template = TestUtil.getTemplate();
	        insert template;	      
	        
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	        			
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
			
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
        	
			ApexPages.currentPage().getParameters().put('articleDetailPage', 'DetailPage_Local_TAL');
        	ApexPages.currentPage().getParameters().put('Category', 'Local');
        	ApexPages.currentPage().getParameters().put('SubCategory', 'TAL');  
	        
	        ArticleListPageController extn = new  ArticleListPageController();
	        extn.Category = 'Local';
	        extn.SubCategory = 'TAL';
	        extn.articleListPage = 'ListPage_Local_TAL';
	        extn.articleDetailPage = 'DetailPage_Local_TAL';
	        String dpURL = extn.articleDetailPageURL;
	        List<SelectOption> pagesizes = extn.availablePageSize;
	        Integer pageNum = extn.getPageNumber();
	        Integer TotalPages = extn.getTotalPages();
	        extn.doNext();
	        extn.doPrevious();
	        Boolean bPrev = extn.getHasPrevious();
	        Boolean bNext = extn.getHasNext();
	        pageReference pr = extn.refresh();
	        List<ArticleWrapper> listArticles = extn.getArticleFeeds();
	        System.assertEquals('Sample Title', listArticles.get(0).objpc.Title_en__c);
     	}	        
    }
    
    static testMethod void readArticleDept() {    	
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        Portal_Content__c template = TestUtil.getTemplate();
	        insert template;	      
	        
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	        			
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
			Portal_Content__c announcement = TestUtil.getAnnouncement();
			announcement.BU__c = 'IT';
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
			
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
        	
			ApexPages.currentPage().getParameters().put('articleDetailPage', 'DetailPage_Local_TAL');
        	ApexPages.currentPage().getParameters().put('Category', 'Local');
        	ApexPages.currentPage().getParameters().put('SubCategory', 'TAL');
        	ApexPages.currentPage().getParameters().put('department', 'IT');        	
	        
	        ArticleListPageController extn = new  ArticleListPageController();

	        List<ArticleWrapper> listArticles = extn.getArticleFeeds();	        
	        System.assertEquals('Sample Title', listArticles.get(0).objpc.Title_en__c);
     	}	        
    }
    */
}