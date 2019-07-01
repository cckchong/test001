@isTest
private class TestACGArticleListCtrlVFClass {

    static testMethod void readArticle() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        Portal_Content__c template = TestClassUtil.getTemplate();
	        insert template;
	        			
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        listToCreate.add(announcement);     
	        
	        Portal_Content__c settingDetailPage = TestClassUtil.getSettings();
	        settingDetailPage.Template_ID__c = template.Id;
	        settingDetailPage.Page_Name__c = 'DetailPage';
	        settingDetailPage.Content_Type__c = 'Rich Text';
	        settingDetailPage.Fixed_Component__c = 'Article Detail';        
	        insert settingDetailPage;
	        	        
	        Portal_Content__c settingListPage = TestClassUtil.getSettings();
	        settingListPage.Template_ID__c = template.Id;
	        settingListPage.Page_Name__c = 'ListPage';
	        settingListPage.Content_Type__c = 'Rich Text';
	        settingListPage.Fixed_Component__c ='List View';
	        settingListPage.Child_Page__c = settingDetailPage.Id;
	        listToCreate.add(settingListPage);
	        insert listToCreate;
	        
	        Portal_Content__c settingMainPage = TestClassUtil.getSettings();
	        settingMainPage.Template_ID__c = template.Id;
	        settingMainPage.Child_List_Page__c = settingListPage.Id;
	        settingMainPage.Child_Page__c = settingDetailPage.Id;
	        insert settingMainPage;
			
			Portal_Content__c p = [Select Id,Child_List_Unique_Page_Name__c, Child_Unique_Page_Name__c From Portal_Content__c Where Id =:settingMainPage.Id];
			
			System.assertEquals('ListPage_General_Site_TALCORP', p.Child_List_Unique_Page_Name__c);
			System.assertEquals('DetailPage_General_Site_TALCORP', p.Child_Unique_Page_Name__c);			
			
	        PageReference pageRef = Page.ACGMainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
        	
			ApexPages.currentPage().getParameters().put('articleDetailPage', 'DetailPage_General_Site_TALCORP');
        	ApexPages.currentPage().getParameters().put('ContentCategory', 'General');
        	ApexPages.currentPage().getParameters().put('DistLevel', 'Site');
        	ApexPages.currentPage().getParameters().put('DistTarget', 'TALCORP');
	        
	        ACGArticleListCtrl extn = new  ACGArticleListCtrl();
	        
	        extn.pageContentCategory = 'General';
	        extn.pageDistLevel = 'Site';
	        extn.pageDistTarget = 'TALCORP';
	        extn.articleListPage = 'ListPage_General_Site_TALCORP';
	        extn.articleDetailPage = 'DetailPage_General_Site_TALCORP';
	        String dpURL = extn.articleDetailPageURL;
	        List<SelectOption> pagesizes = extn.availablePageSize;
	        Integer pageNum = extn.getPageNumber();
	        Integer TotalPages = extn.getTotalPages();
	        extn.doNext();
	        extn.doPrevious();
	        Boolean bPrev = extn.getHasPrevious();
	        Boolean bNext = extn.getHasNext();
	        pageReference pr = extn.refresh();
	        List<ACGArticleWrapper> listArticles = extn.getArticleFeeds();
	        System.assertEquals('Sample Title', listArticles.get(0).objpc.Title_en__c);
     	}	        
    }
}