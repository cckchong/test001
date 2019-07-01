@isTest
public class TestArticleDetailsControllerVFClass {
	/*
    static testMethod void readArticleDetail() {    	
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
	        
	        // Add parameters to page URL
        	ApexPages.currentPage().getParameters().put('Id', announcement.Id);
        	ApexPages.currentPage().getParameters().put('Category', 'Local');
        	ApexPages.currentPage().getParameters().put('SubCategory', 'TAL');  
	        ArticleDetailsController extn = new  ArticleDetailsController();
	        extn.getRecordSecurity();
	        List<String> listStrings = extn.getArticleFeedId();
	        ArticleWrapper aw = extn.fullArticle;
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
	        
	        // Add parameters to page URL
        	ApexPages.currentPage().getParameters().put('Id', announcement.Id);
        	ApexPages.currentPage().getParameters().put('Category', 'Local');
        	ApexPages.currentPage().getParameters().put('SubCategory', 'TAL');
        	ApexPages.currentPage().getParameters().put('department', 'IT');
        	ApexPages.currentPage().getParameters().put('Preview', 'true');  
	        ArticleDetailsController extn = new  ArticleDetailsController();
	        extn.getRecordSecurity();
	        List<String> listStrings = extn.getArticleFeedId();
	        ArticleWrapper aw = extn.fullArticle;
	        System.assertEquals('Sample Title', aw.objpc.Title_en__c);
	        System.assertEquals(announcement.Id, aw.objpc.Id);
     	}	        
    }
    
    static testMethod void articleNotFound() {    	
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	        
			// The following code runs as user 'u' 		
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        // Add parameters to page URL
        	ApexPages.currentPage().getParameters().put('Id', 'a12345678901234');
        	ApexPages.currentPage().getParameters().put('Category', 'Local');
        	ApexPages.currentPage().getParameters().put('SubCategory', 'TAL');
        	ApexPages.currentPage().getParameters().put('department', 'IT');
	        ArticleDetailsController extn = new  ArticleDetailsController();
	        ArticleWrapper aw = extn.fullArticle;
	        
	        List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs)
			{
				if (msg.getDetail().contains('Article Not Found'))
				{
					b = true;
				}
			}
			//Assert the Page Message was Properly Displayed   
			System.assert(b); 
	    }	        
    }    	
    */
}