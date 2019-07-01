@isTest
private class TestWebPortalMainPageControllerVFClass {
	/*
	static testMethod void positiveCase() {    	
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        Portal_Content__c template = TestUtil.getTemplate();
	        insert template;	        			
	        
	        Portal_Content__c settingMainPage = TestUtil.getSettings();
	        settingMainPage.Template_ID__c = template.Id;
	        settingMainPage.BU__c = '';
	        insert settingMainPage;
	        
	        Portal_Content__c settingDeptMainPage = TestUtil.getSettings();
	        settingDeptMainPage.Template_ID__c = template.Id;
	        settingDeptMainPage.BU__c = 'IT';
	        insert settingDeptMainPage;
			
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	        
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);        	
        	ApexPages.currentPage().getParameters().put('department', 'IT');  
	        ApexPages.currentPage().getParameters().put('Local', 'TAL');  
	        
	        WebPortalMainPageController extn = new  WebPortalMainPageController();	        
        	String url = extn.getPageUrl();
        	
        	PageReference pr = extn.getDepartmentalPage();
        	//System.assertEquals('/apex/MainTemplate1_Left?uniquePageName=MainPage_Local_TAL&' + Label.ConnecTalTab, url);
        	//System.assertEquals('/apex/MainTemplate1_Left?department=IT&' + Label.ConnecTalTab + '&uniquePageName=MainPage_Local_TAL_IT', pr.getUrl());
        	
        	ApexPages.currentPage().getParameters().put('Sitename', 'TAL');
        	PageReference prSiteMap = extn.getSiteMapURL();    
        	ApexPages.currentPage().getParameters().put('Sitename', 'CORP');
        	prSiteMap = extn.getSiteMapURL();    
        	ApexPages.currentPage().getParameters().put('Sitename', 'Far East');
        	prSiteMap = extn.getSiteMapURL();    
     	}	        
    }
    static testMethod void negativeCase() {            
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {    
			ApexPages.currentPage().getParameters().put('department', 'IT');        
        	WebPortalMainPageController extn = new  WebPortalMainPageController();
        	String url = extn.getPageUrl();
        	PageReference pr = extn.getDepartmentalPage();
        	//System.assertEquals('/apex/DefaultErrorPage', url);
        	//System.assertEquals('/apex/UnderConstruction?' + Label.ConnecTalTab , pr.getUrl());        	
		}       
    }
    */
}