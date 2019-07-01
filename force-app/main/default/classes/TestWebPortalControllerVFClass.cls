@isTest
private class TestWebPortalControllerVFClass {
	/*
    static testMethod void positiveCase() {            
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
				        
			Portal_Content__c template = TestUtil.getTemplate();
			template.Tech_Total_Component__c = 8;
	        insert template;	  
	              
	        String groupName = 'Test Group' + TestUtil.generateRandomString();
	        CollaborationGroup chatterGroup = new CollaborationGroup(Name=groupName, CollaborationType='Public');
			chatterGroup.OwnerId = UserInfo.getUserId() ;
			try
			{
				insert chatterGroup;
			}
			catch (exception ex)
			{
				//chatterGroup = [Select Id, Name From CollaborationGroup Where Name = :groupName limit 1];
			}	
	        
	        FeedItem ChatterPhoto = TestUtil.getChatterPhoto();
	        ChatterPhoto.ParentId=chatterGroup.Id;
	        insert ChatterPhoto;
	        
	        FeedItem ChatterFile = TestUtil.getChatterFile();
	        ChatterFile.ParentId=chatterGroup.Id;
	        insert ChatterFile;
	        
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
	        
			Portal_Content__c announcement = TestUtil.getAnnouncement();
	        listToCreate.add(announcement);   
	        
	        Portal_Content__c settingDetailPage = TestUtil.getSettings();
	        settingDetailPage.Template_ID__c = template.Id;
	        settingDetailPage.Page_Name__c = 'DetailPage';
	        settingDetailPage.Content_Type__c = 'Rich Text';
	        settingDetailPage.Fixed_Component__c = 'Article Detail';
	        settingDetailPage.BU__c = '';
	        insert (settingDetailPage);	   
	        
	        Portal_Content__c settingListPage = TestUtil.getSettings();
	        settingListPage.Template_ID__c = template.Id;
	        settingListPage.Page_Name__c = 'ListPage';
	        settingListPage.Content_Type__c = 'Rich Text';
	        settingListPage.Fixed_Component__c ='List View';
	        settingListPage.BU__c = '';
	        settingListPage.Child_Page__c = settingDetailPage.Id;
	        listToCreate.add(settingListPage);	             
	        
	        Portal_Content__c video = TestUtil.getVideo();
	        listToCreate.add(video);
	        
	        Portal_Content__c HTML = TestUtil.getHTML();
	        listToCreate.add(HTML);
	        
	        Portal_Content__c HTMLSiteMap = TestUtil.getHTML();
	        HTMLSiteMap.System_Setting__c ='SiteMap';	        
	        listToCreate.add(HTMLSiteMap);
	        
	        Portal_Content__c HTMLBlank = TestUtil.getHTML();
	        HTMLBlank.System_Setting__c ='BlankHTML';	        
	        listToCreate.add(HTMLBlank);	        
	        
	        insert listToCreate;
	        
	        List<Portal_Content__c> listToCreateSettings = new List<Portal_Content__c>();
	        Portal_Content__c settingMainPage = TestUtil.getSettings();
	        settingMainPage.Template_ID__c = template.Id;
	        settingMainPage.BU__c = '';
	        settingMainPage.Child_List_Page__c = settingListPage.Id;
	        settingMainPage.Child_Page__c = settingDetailPage.Id;
	        settingMainPage.Component_Number__c = String.ValueOf(1);
	        settingMainPage.Content_Type__c = 'Rich Text';
	        settingMainPage.Feed_Category__c = 'Local';
	        settingMainPage.Article_Feed_Title__c = 'Announcement';
			listToCreateSettings.add(settingMainPage);
			
			Portal_Content__c settingMainPage2 = TestUtil.getSettings();
	        settingMainPage2.Template_ID__c = template.Id;
	        settingMainPage2.BU__c = '';
	        settingMainPage2.Component_Number__c = String.ValueOf(2);
	        settingMainPage2.Content_Type__c = 'HTML';
	        settingMainPage2.HTML_Selected__c = HTML.Id;
			listToCreateSettings.add(settingMainPage2);
			
			Portal_Content__c settingMainPage3 = TestUtil.getSettings();
	        settingMainPage3.Template_ID__c = template.Id;
	        settingMainPage3.BU__c = '';
	        settingMainPage3.Component_Number__c = String.ValueOf(3);
	        settingMainPage3.Content_Type__c = 'Video';
	        settingMainPage3.Video_Selected__c = video.Id;
			listToCreateSettings.add(settingMainPage3);	        

			Portal_Content__c settingMainPage4 = TestUtil.getSettings();
	        settingMainPage4.Template_ID__c = template.Id;
	        settingMainPage4.BU__c = '';
	        settingMainPage4.Component_Number__c = String.ValueOf(4);
	        settingMainPage4.Content_Type__c = 'Chatter';
	        settingMainPage4.Chatter_Feed_ID__c = chatterGroup.Id;
			settingMainPage4.Number_of_Slides__c = 1;
			settingMainPage4.Slideshow_Topic__c = 'Test1;Test2';
			listToCreateSettings.add(settingMainPage4);	 			
			
			Portal_Content__c settingMainPage5 = TestUtil.getSettings();
	        settingMainPage5.Template_ID__c = template.Id;
	        settingMainPage5.BU__c = '';
	        settingMainPage5.Component_Number__c = String.ValueOf(5);
	        settingMainPage5.Content_Type__c = 'Rich Text';
	        settingMainPage5.Fixed_Component__c = 'List View';
	        settingMainPage5.Child_Page__c = settingDetailPage.Id;
			listToCreateSettings.add(settingMainPage5);	
			
	        Portal_Content__c settingMainPage6 = TestUtil.getSettings();
	        settingMainPage6.Template_ID__c = template.Id;
	        settingMainPage6.BU__c = '';
	        settingMainPage6.Component_Number__c = String.ValueOf(6);
	        settingMainPage6.Content_Type__c = 'Rich Text';
	        settingMainPage6.Fixed_Component__c = 'Article Detail';
			listToCreateSettings.add(settingMainPage6);	
			
			Portal_Content__c settingMainPage7 = TestUtil.getSettings();
	        settingMainPage7.Template_ID__c = template.Id;
	        settingMainPage7.BU__c = '';
	        settingMainPage7.Component_Number__c = String.ValueOf(6);
	        settingMainPage7.Content_Type__c = 'RSS';
	        settingMainPage7.RSS_Feed_URL__c = 'http://www.computerweekly.com/rss/All-Computer-Weekly-content.xml';
	        settingMainPage7.RSS_Title__c = 'Computer';
			listToCreateSettings.add(settingMainPage7);	
			
			
			insert listToCreateSettings;
			
			List<DepartmentSetting__c> depts = TestUtil.getDepartmentSettings();
	        insert depts;
			
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	        
			PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
        	
			ApexPages.currentPage().getParameters().put('uniquePageName', 'MainPage_Local_TAL');
			ApexPages.currentPage().getParameters().put('feedCat', 'Local');
			ApexPages.currentPage().getParameters().put('title', 'Announcement');
			ApexPages.currentPage().getParameters().put('Id', announcement.Id);  
        	WebPortalController extn = new  WebPortalController();
        	List<Portal_Content__c> returnLists = extn.getSettings();
        	List<DepartmentWrapper> returnDepts = extn.getDepartmentList();
        	extn.ChatterGroupSecurityCheck();
        	List<ContentVersionWrapper> returnCV = extn.getChatterFiles();
        	List<ContentVersionWrapper> returnCV2 = extn.getChatterPhotos();
        	String str = extn.strSiteMapId;
        	Integer num1 = extn.newGlobalArticleNum;
        	Integer num2 = extn.newRegionalArticleNum;
        	Integer num3 = extn.newLocalArticleNum;
        	Boolean bEdit = extn.canEdit;   
        	String str2 = extn.strSiteMapId;	
		}       
    }
    
    static testMethod void negativeCase1_CatchError2() {            
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {    
			Portal_Content__c template = TestUtil.getTemplate();
			template.Tech_Total_Component__c = 8;
	        insert template;	        		
	        
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
	                
	        Portal_Content__c HTMLBlank = TestUtil.getHTML();
	        HTMLBlank.System_Setting__c ='BlankHTML';	        
	        listToCreate.add(HTMLBlank);
	        
	        insert listToCreate;
	        
	        List<Portal_Content__c> listToCreateSettings = new List<Portal_Content__c>();
	        Portal_Content__c settingMainPage = TestUtil.getSettings();
	        settingMainPage.Template_ID__c = template.Id;
	        settingMainPage.BU__c = '';
	        settingMainPage.Component_Number__c = String.ValueOf(1);
	        
	        //Test Global Case
	        //And Content Type = ''
	        settingMainPage.Content_Type__c = '';
	        settingMainPage.Category__c = 'Global';
	        settingMainPage.Sub_Category__c = 'Far East';
	        settingMainPage.Fixed_Component__c = '';
			listToCreateSettings.add(settingMainPage);
			
			insert listToCreateSettings;
			
			PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
        	
			ApexPages.currentPage().getParameters().put('uniquePageName', 'MainPage_Global_Far_East');
        	WebPortalController extn = new  WebPortalController();
        	List<Portal_Content__c> returnLists = extn.getSettings();    
        	
        	List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs)
			{
				system.debug('@@@ ' + msg.getDetail());
				if (msg.getDetail().contains('The content type for 1 '))
				{
					b = true;
				}
			}
			//Assert the Page Message was Properly Displayed   
			System.assert(b);	
			
		}       
    }
    static testMethod void negativeCase1_NoSettingRecordFound() {            
    	User u = TestUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {    
			
			Portal_Content__c template = TestUtil.getTemplate();
			template.Tech_Total_Component__c = 8;
	        insert template;	        		
	        
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
	                
	        Portal_Content__c HTMLBlank = TestUtil.getHTML();
	        HTMLBlank.System_Setting__c ='BlankHTML';	        
	        listToCreate.add(HTMLBlank);
	        
	        insert listToCreate;
	        
			PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
        	
			ApexPages.currentPage().getParameters().put('uniquePageName', 'MainPage_Global_Far_East');
        	WebPortalController extn = new  WebPortalController();
        	List<Portal_Content__c> returnLists = extn.getSettings();    
        	        	
			System.assertEquals('/apex/DefaultErrorPage', extn.redirectUrl);	
			
		}       
    }
    */
}