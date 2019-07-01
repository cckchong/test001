@isTest
private class TestWebPortalAdminControllerVFClass {
	/*
    static testMethod void editPage() {    	
    	User u = TestUtil.getTestACGSystemAdminUser();
    	u.Administrative_Regions__c ='Far East Garment Operation;CORP;China;TAL;PAL';
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        List<DepartmentSetting__c> depts = TestUtil.getDepartmentSettings();
	        insert depts;
	        
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	       	
	       	Portal_Content__c template = TestUtil.getTemplate();
			template.Tech_Total_Component__c = 8;
	        insert template;	
	        
	        Portal_Content__c template2 = TestUtil.getTemplate();
			template2.Tech_Total_Component__c = 6;
	        insert template2;
	        
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
	        
	        Portal_Content__c announcement = TestUtil.getAnnouncement();
	        listToCreate.add(announcement);   
	        
	        Portal_Content__c HTML = TestUtil.getHTML();
	        listToCreate.add(HTML);
	        
	        Portal_Content__c HTMLBlank = TestUtil.getHTML();
	        HTMLBlank.System_Setting__c ='BlankHTML';	        
	        listToCreate.add(HTMLBlank);
			
			insert listToCreate;
	        
	        List<Portal_Content__c> listToCreateSettings = new List<Portal_Content__c>();
	        Portal_Content__c settingMainPage2 = TestUtil.getSettings();
	        settingMainPage2.Template_ID__c = template.Id;
	        settingMainPage2.BU__c = 'IT';
	        settingMainPage2.Component_Number__c = String.ValueOf(1);
	        settingMainPage2.Content_Type__c = 'HTML';
	        settingMainPage2.HTML_Selected__c = HTML.Id;
			listToCreateSettings.add(settingMainPage2);
			
			Portal_Content__c settingMainPage6 = TestUtil.getSettings();
	        settingMainPage6.Template_ID__c = template.Id;
	        settingMainPage6.BU__c = 'IT';
	        settingMainPage6.Component_Number__c = String.ValueOf(3);
	        settingMainPage6.Content_Type__c = 'Rich Text';
	        settingMainPage6.Fixed_Component__c = 'Article Detail';
			insert (settingMainPage6);	
			
			Portal_Content__c settingMainPage5 = TestUtil.getSettings();
	        settingMainPage5.Template_ID__c = template.Id;
	        settingMainPage5.BU__c = 'IT';
	        settingMainPage5.Component_Number__c = String.ValueOf(2);
	        settingMainPage5.Content_Type__c = 'Rich Text';
	        settingMainPage5.Fixed_Component__c = 'List View';
	        settingMainPage5.Child_Page__c = settingMainPage6.Id;
			listToCreateSettings.add(settingMainPage5);	
			
			insert listToCreateSettings;
			
			
			test.startTest();

	        WebPortalAdminController extn = new  WebPortalAdminController();
	        
	        List<SelectOption> avaCats = extn.availableCategory;
	        List<SelectOption> avaSubCats = extn.availableSubCategory;
	        List<SelectOption> avaDepts = extn.availableDepartment;
	        List<SelectOption> avaPageNames = extn.availablePageNames;
	        
	        //Search Criteria - Local TAL IT Page
	        extn.selectedCategory = 'Local';
	        avaSubCats = extn.availableSubCategory;
	        extn.selectedSubCategory = 'TAL';	        
	        avaDepts = extn.availableDepartment;
			extn.selectedDepartment = 'IT';
			avaPageNames = extn.availablePageNames;
			extn.selectedPage = 'MainPage';
				        
	        PageReference pr1 = extn.searchPages();
	        System.assertEquals('apex/MainTemplate1_Left?uniquePageName=MainPage_Local_TAL_IT&edit=true&department=IT&Id=' + announcement.Id +'&Category=Local&SubCategory=TAL&feedCat=Local&title=TAL', extn.pageLink);	
	        
	        List<SelectOption> avaTemps = extn.availableTemplateNames;
	        List<SelectOption> avaNewCats = extn.availableNewCategory;
	        List<SelectOption> avaNewSubCats = extn.availableNewSubCategory;
	        List<SelectOption> avaNewDepts = extn.availableNewDepartment;
	        List<SelectOption> avaNewPageNames = extn.availableNewPageName;
	        
	        //Test Validation on Creating page
	        PageReference pr2;// = new PageReference();
	       	extn.selectedNewTemplate = '<Select one>';
	        pr2 = extn.createPage();	        
	        extn.selectedNewTemplate = template.Id;
	        
	        extn.selectedNewCategory = '<Select one>';
	        pr2 = extn.createPage();
	        extn.selectedNewCategory = 'Local';
	        
	        extn.selectedNewSubCategory = '<Select one>';
	        pr2 = extn.createPage();
	        extn.selectedNewSubCategory = 'TAL';
	        
	        extn.selectedNewDepartment = '<Select one>';
	        pr2 = extn.createPage();
	        extn.selectedNewDepartment = 'HKHCM';
	        
	        extn.selectedNewPageName = '<Select one>';
	        pr2 = extn.createPage();
	        extn.selectedNewPageName = 'MainPage';
	        
	        pr2 = extn.createPage();
	        System.assertEquals('apex/MainTemplate1_Left?uniquePageName=MainPage_Local_TAL_HKHCM&edit=true&department=HKHCM', extn.pageLink);
	        
	        //Existing Page found
	        PageReference pr3 = extn.createPage();	        
	        //Open the existing page instead of creating a new page
	        System.assertEquals('apex/MainTemplate1_Left?uniquePageName=MainPage_Local_TAL_HKHCM&edit=true&department=HKHCM', extn.pageLink);
	        
	        	        
	        //Convert Template
	        extn.selectedConvertTemplate = template2.Id;
	        extn.convertTemplate();
	        
	        extn.selectedConvertTemplate = template.Id;
	        extn.convertTemplate();
	        
	        extn.selectedNewCategory = 'Regional';
	        avaNewSubCats = extn.availableNewSubCategory;
	        extn.selectedNewCategory = 'Global';
	        avaNewSubCats = extn.availableNewSubCategory;
	        test.stopTest();
	        	        
     	}	        
    }
    */
}