@isTest
private class TestACGAdminCtrlVFClass {

    static testMethod void editPage() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	u.Administrative_Category__c = 'General';
    	u.Administrative_Target__c ='Apparel;TALCORP;PAL';
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u'	       	
			//List<ACG_Hierarchy__c> acgs = TestClassUtil.getTestACGHierarchy();
			//insert acgs;
			
	       	Portal_Content__c template = TestClassUtil.getTemplate();
			template.Tech_Total_Component__c = 8;
	        insert template;	
	        
	        Portal_Content__c template2 = TestClassUtil.getTemplate();
			template2.Tech_Total_Component__c = 6;
	        insert template2;
	        
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
	        
	        Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        listToCreate.add(announcement);
	        
	        Portal_Content__c HTML = TestClassUtil.getHTML();
	        listToCreate.add(HTML);
	        
	        Portal_Content__c HTMLBlank = TestClassUtil.getHTML();
	        HTMLBlank.System_Setting__c ='BlankHTML';
	        listToCreate.add(HTMLBlank);
			
			insert listToCreate;
	        
	        List<Portal_Content__c> listToCreateSettings = new List<Portal_Content__c>();
	        Portal_Content__c settingMainPage2 = TestClassUtil.getSettings();
	        settingMainPage2.Template_ID__c = template.Id;
	        settingMainPage2.Content_Category__c = 'General';
        	settingMainPage2.Distribution_Level__c = 'Site';
        	settingMainPage2.Distribution_Target__c = 'TALCORP';
	        settingMainPage2.Component_Number__c = String.ValueOf(1);
	        settingMainPage2.Content_Type__c = 'HTML';
	        settingMainPage2.HTML_Selected__c = HTML.Id;
			listToCreateSettings.add(settingMainPage2);
			
			Portal_Content__c settingMainPage6 = TestClassUtil.getSettings();
	        settingMainPage6.Template_ID__c = template.Id;
	        settingMainPage2.Content_Category__c = 'General';
        	settingMainPage2.Distribution_Level__c = 'Site';
        	settingMainPage2.Distribution_Target__c = 'TALCORP';
	        settingMainPage6.Component_Number__c = String.ValueOf(3);
	        settingMainPage6.Content_Type__c = 'Rich Text';
	        settingMainPage6.Fixed_Component__c = 'Article Detail';
			insert (settingMainPage6);	
			
			Portal_Content__c settingMainPage5 = TestClassUtil.getSettings();
	        settingMainPage5.Template_ID__c = template.Id;
	        settingMainPage2.Content_Category__c = 'General';
        	settingMainPage2.Distribution_Level__c = 'Site';
        	settingMainPage2.Distribution_Target__c = 'TALCORP';
	        settingMainPage5.Component_Number__c = String.ValueOf(2);
	        settingMainPage5.Content_Type__c = 'Rich Text';
	        settingMainPage5.Fixed_Component__c = 'List View';
	        settingMainPage5.Child_Page__c = settingMainPage6.Id;
			listToCreateSettings.add(settingMainPage5);	
			
			insert listToCreateSettings;
			test.startTest();

	        ACGAdminCtrl extn = new  ACGAdminCtrl();
	        
	        //Search Criteria - Local TAL CORP Page
	        extn.selectedContentCategory = 'General';
	        extn.selectedDistLevel = 'Site';
			extn.selectedDistTarget = 'TALCORP';
			extn.selectedPage = 'MainPage';
	        PageReference pr1 = extn.searchPages();
	        System.assertEquals('/apex/' + template.Template_Name__c +'?uniquePageName=MainPage_General_Site_TALCORP&edit=true&Id=' + announcement.Id +'&title=Sample Title&ContentCategory=General&DistLevel=Site&DistTarget=TALCORP', extn.pageLink);	
	       	
	        //Test Validation on Creating page	        
	        List<SelectOption> avaTemplates = extn.availableTemplateNames;
	        List<SelectOption> avaCC = extn.availableNewContentCategory;
	        List<SelectOption> avaDL = extn.availableNewDistLevel;
	        List<SelectOption> avaDT = extn.availableNewDistTarget;
	        List<SelectOption> avaPN = extn.availableNewPageName;
	             
	        extn.selectedContentCategory = '';
	        extn.selectedDistLevel = '';
			extn.selectedDistTarget = '';
			extn.selectedPage = '';
			
	        PageReference pr2;
	       	extn.selectedNewTemplate = '<Select one>';
	        pr2 = extn.createPage();	        
	        extn.selectedNewTemplate = template.Id;
	        
	        extn.selectedNewContentCategory = '<Select one>';
	        pr2 = extn.createPage();
	        extn.selectedNewContentCategory = 'General';
	        
	        extn.selectedNewDistLevel = '<Select one>';
	        pr2 = extn.createPage();
	        extn.selectedNewDistLevel = 'Site';
	        
	        extn.selectedNewDistTarget = '<Select one>';
	        pr2 = extn.createPage();
	        extn.selectedNewDistTarget = 'KAT';
	        
	        extn.selectedNewPageName = '<Select one>';
	        pr2 = extn.createPage();
	        extn.selectedNewPageName = 'MainPage';
	        
	        pr2 = extn.createPage();
	        System.assertEquals('Page created successfully!', extn.strResult);
	        System.assertEquals('/apex/MainTemplate1_Left?uniquePageName=MainPage_General_Site_KAT&edit=true&ContentCategory=General&DistLevel=Site&DistTarget=KAT', extn.pageLink);
	        
	        //Existing Page found
	        PageReference pr3 = extn.createPage();	        
	        //Open the existing page instead of creating a new page
	        System.assertEquals('/apex/MainTemplate1_Left?uniquePageName=MainPage_General_Site_KAT&edit=true&ContentCategory=General&DistLevel=Site&DistTarget=KAT', extn.pageLink);
	        
	        	        
	        //Convert Template
	        extn.selectedContentCategory = 'General';
	        extn.selectedDistLevel = 'Site';
			extn.selectedDistTarget = 'TALCORP';
			extn.selectedPage = 'MainPage';
	        extn.selectedConvertTemplate = template2.Id;
	        extn.convertTemplate();
	        
	        extn.selectedConvertTemplate = template.Id;
	        extn.convertTemplate();
	        
	        test.stopTest();
	        
     	}	        
    }
}