@isTest
private class TestACGLandingCtrlVFClass {

    static testMethod void positiveCase() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        Portal_Content__c template = TestClassUtil.getTemplate();
	        insert template;	   
	        
	        ACGLandingCtrl extn = new  ACGLandingCtrl();	        
        	String url = extn.getPageUrl();
        	
        	PageReference pr = extn.getDepartmentalPage();      
        	System.assertEquals(true, pr.getUrl().contains('/apex/UnderConstruction?'));
	        
	        Portal_Content__c settingMainPage = TestClassUtil.getSettings();
	        settingMainPage.Template_ID__c = template.Id;
	        settingMainPage.Content_Category__c = 'General';
	        settingMainPage.Distribution_Level__c = 'Site';
	        settingMainPage.Distribution_Target__c = 'TALCORP';
	        insert settingMainPage;
	        
	        Portal_Content__c settingDeptMainPage = TestClassUtil.getSettings();
	        settingDeptMainPage.Template_ID__c = template.Id;
	        settingDeptMainPage.Content_Category__c = 'HKHCM';
	        settingDeptMainPage.Distribution_Level__c = 'Site';
	        settingDeptMainPage.Distribution_Target__c = 'TALCORP';
	        insert settingDeptMainPage;
				        
	        PageReference pageRef = Page.ACGMainTemplate1_Left;
        	Test.setCurrentPage(pageRef);        	
        	ApexPages.currentPage().getParameters().put('ContentCategory', 'HKHCM');  
	        ApexPages.currentPage().getParameters().put('Level', 'Site');  
	        ApexPages.currentPage().getParameters().put('Target', 'TALCORP');  
	        
        	pr = extn.getDepartmentalPage();
        	System.assertEquals(true, pr.getUrl().contains('/apex/MainTemplate1_Left?') && pr.getUrl().contains('uniquePageName=MainPage_HKHCM_Site_TALCORP'));
        	
        	Portal_Content__c settingDeptMainPage2 = TestClassUtil.getSettings();
	        settingDeptMainPage2.Template_ID__c = template.Id;
	        settingDeptMainPage2.Content_Category__c = 'HKHCM';
	        settingDeptMainPage2.Distribution_Level__c = 'Site';
	        settingDeptMainPage2.Distribution_Target__c = 'TALCORP';
	        insert settingDeptMainPage2;
	        pr = extn.getDepartmentalPage();
        	System.assertEquals(true, pr.getUrl().contains('/apex/MainTemplate1_Left?') && pr.getUrl().contains('uniquePageName=MainPage_HKHCM_Site_TALCORP'));
        	        	
        	ApexPages.currentPage().getParameters().put('LandingPage', 'TALCORP');
        	PageReference prSiteMap = extn.getSiteMapURL();
        	System.assertEquals(true, prSiteMap.getUrl().contains('/apex/MainTemplate1_Left?') && prSiteMap.getUrl().contains('uniquePageName=MainPage_General_Site_TALCORP'));
        	ApexPages.currentPage().getParameters().put('LandingPage', 'CORP');
        	prSiteMap = extn.getSiteMapURL();
        	System.assertEquals(true, prSiteMap.getUrl().contains('/apex/UnderConstruction?'));
        	
     	}	        
    }
}