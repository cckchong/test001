@isTest
private class TestACGArticleDetailCtrlVFClass {

    static testMethod void readArticleDetail() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        insert announcement;
	        
	        PageReference pageRef = Page.ACGMainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        // Add parameters to page URL
        	ApexPages.currentPage().getParameters().put('Id', announcement.Id);
        	ApexPages.currentPage().getParameters().put('ContentCategory', 'General');
        	ApexPages.currentPage().getParameters().put('DistLevel', 'Site');
        	ApexPages.currentPage().getParameters().put('DistTarget', 'TALCORP');  
	        ACGArticleDetailCtrl extn = new  ACGArticleDetailCtrl();
	        extn.getRecordSecurity();
	        //List<String> listStrings = extn.getAllArticleFeedIds();
	        ACGArticleWrapper aw = extn.fullArticle;
	        System.assertEquals('Sample Title', aw.objpc.Title_en__c);
	        System.assertEquals(announcement.Id, aw.objpc.Id);
	        
	        List<String> listStrings2 = extn.getLanguages();
	        Map<String, String> mapStrings2 = extn.getLanguagesLabel();
	        Map<String, String> mapStrings3 = extn.getTitleLangVar();
	        Map<String, String> mapStrings4 = extn.getContentsLangVar();
	        Map<String, String> mapStrings5 = extn.getRevisedLangVar();
     	}	        
    }
    static testMethod void previewArticleDetail() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        insert announcement;
	        
	        PageReference pageRef = Page.ACGMainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        // Add parameters to page URL
        	ApexPages.currentPage().getParameters().put('Id', announcement.Id);
        	ApexPages.currentPage().getParameters().put('ContentCategory', 'General');
        	ApexPages.currentPage().getParameters().put('DistLevel', 'Site');
        	ApexPages.currentPage().getParameters().put('DistTarget', 'TALCORP');
        	ApexPages.currentPage().getParameters().put('preview', 'true');  
	        ACGArticleDetailCtrl extn = new  ACGArticleDetailCtrl();
	        ACGArticleWrapper aw = extn.fullArticle;
	        System.assertEquals('Sample Title', aw.objpc.Title_en__c);
	        System.assertEquals(announcement.Id, aw.objpc.Id);
     	}	        
    }
}