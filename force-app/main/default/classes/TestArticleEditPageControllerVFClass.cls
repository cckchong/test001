@isTest
private class TestArticleEditPageControllerVFClass {
	/*
	static testMethod void readArticle() {    	
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
			Portal_Content__c announcement = TestUtil.getAnnouncement();      	        
	        insert announcement;
	        
	        List<DepartmentSetting__c> depts = TestUtil.getDepartmentSettings();
	        insert depts;
	        
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	        
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('Id', announcement.Id); 
	        
	        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
	        ArticleEditPageController extn = new  ArticleEditPageController(controller);
	        PageReference pr1 = extn.updateContents();
	        extn.changeContents();
	        PageReference pr2 = extn.changeDept();
	        extn.changeCategory();
	        //extn.changeSubCategory();
	        PageReference pr3 = extn.post();
	        PageReference pr4 = extn.edit();
	        PageReference pr5 = extn.saveClone();
	        extn.save();
	        PageReference pr6 = extn.cancel();
	        extn.deleteRecord();
	        PageReference pr7 = extn.shareRecord();
	        PageReference pr8 = extn.cloneRecord();
	        //PageReference pr9 = extn.publishArticle();
	        PageReference pr10 = extn.UnpublishArticle();
	        List<SelectOption> avadepts = extn.availableDepartment;
	        List<SelectOption> avaSubCats = extn.availableSubCategory;
	        System.assertEquals('Sample Title', extn.objPC.Title_en__c);
	        
	        List<String> listStrings2 = extn.getLanguages();
	        Map<String, String> mapStrings2 = extn.getSummaryLangVar();
	        Map<String, String> mapStrings3 = extn.getTitleLangVar();
	        Map<String, String> mapStrings4 = extn.getContentsLangVar();
	        Map<String, String> mapStrings5 = extn.getRevisedLangVar();
     	}	        
    }
    
    static testMethod void createArticle() {    	
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
			Portal_Content__c announcement = TestUtil.getAnnouncement();
			announcement.LangAlreadySendNotification__c ='en';  	        
	        insert announcement;
	        
	        List<DepartmentSetting__c> depts = TestUtil.getDepartmentSettings();
	        insert depts;
	        
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	        
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('Id', announcement.Id); 
	        ApexPages.currentPage().getParameters().put('Create', 'true');
	        ApexPages.currentPage().getParameters().put('RecordTypeId', announcement.RecordTypeId);
	        
	        
	        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
	        ArticleEditPageController extn = new  ArticleEditPageController(controller);
	        
	        PageReference pr1 = extn.updateContents();
	        extn.changeContents();
	        PageReference pr2 = extn.changeDept();
	        PageReference pr3 = extn.post();
	        PageReference pr4 = extn.edit();
	        PageReference pr5 = extn.saveClone();
	        extn.save();
	        PageReference pr6 = extn.cancel();
	        PageReference pr7 = extn.shareRecord();
	        PageReference pr8 = extn.cloneRecord();
	        PageReference pr19 = extn.UnpublishArticle();
	        PageReference pr10 = extn.previewArticle();
	        PageReference pr11 = extn.publishArticle();
	        extn.saveCreate();
	        List<SelectOption> avadepts = extn.availableDepartment;
	        extn.selectedCategory = 'Global';
	        List<SelectOption> avaSubCats = extn.availableSubCategory;
	        extn.selectedCategory = 'Regional';
	        List<SelectOption> avaSubCats2 = extn.availableSubCategory;
	        
	        String str = extn.setEditorLang;
	        String str1 = extn.getLanguageLabel();
     	}	        
    }
    */
}