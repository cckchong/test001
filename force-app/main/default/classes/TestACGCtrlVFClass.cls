@isTest
private class TestACGCtrlVFClass {

    static testMethod void positiveCase() {            
    	List<User> users = new List<User>();
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	User u2 = TestClassUtil.getTestACGSystemAdminUser();
    	users.add(u);
    	users.add(u2);
    	
    	insert users;
		System.runAs(u) {
				        
			Portal_Content__c template = TestClassUtil.getTemplate();
			template.Tech_Total_Component__c = 8;
	        insert template;	  
	              
	        String groupName = 'Test Group' + TestClassUtil.generateRandomString();
	        CollaborationGroup chatterGroup = new CollaborationGroup(Name=groupName, CollaborationType='Public');
			chatterGroup.OwnerId = u2.Id;
			try {
				insert chatterGroup;
			} catch (exception ex) {
				//chatterGroup = [Select Id, Name From CollaborationGroup Where Name = :groupName limit 1];
			}	
	        
	        FeedItem ChatterPhoto = TestClassUtil.getChatterPhoto();
	        ChatterPhoto.ParentId=chatterGroup.Id;
	        insert ChatterPhoto;
	        
	        FeedItem ChatterFile = TestClassUtil.getChatterFile();
	        ChatterFile.ParentId=chatterGroup.Id;
	        insert ChatterFile;
	        
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
	        
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        listToCreate.add(announcement);   
	        
	        Portal_Content__c settingDetailPage = TestClassUtil.getSettings();
	        settingDetailPage.Template_ID__c = template.Id;
	        settingDetailPage.Page_Name__c = 'DetailPage';
	        settingDetailPage.Content_Type__c = 'Rich Text';
	        settingDetailPage.Fixed_Component__c = 'Article Detail';
	        insert (settingDetailPage);	   
	        
	        Portal_Content__c settingListPage = TestClassUtil.getSettings();
	        settingListPage.Template_ID__c = template.Id;
	        settingListPage.Page_Name__c = 'ListPage';
	        settingListPage.Content_Type__c = 'Rich Text';
	        settingListPage.Fixed_Component__c ='List View';
	        settingListPage.Child_Page__c = settingDetailPage.Id;
	        listToCreate.add(settingListPage);	             
	        
	        Portal_Content__c video = TestClassUtil.getVideo();
	        listToCreate.add(video);
	        
	        Portal_Content__c HTML = TestClassUtil.getHTML();
	        listToCreate.add(HTML);
	        
	        Portal_Content__c HTMLSiteMap = TestClassUtil.getHTML();
	        HTMLSiteMap.System_Setting__c ='SiteMap';	        
	        listToCreate.add(HTMLSiteMap);
	        
	        Portal_Content__c HTMLBlank = TestClassUtil.getHTML();
	        HTMLBlank.System_Setting__c ='BlankHTML';	        
	        listToCreate.add(HTMLBlank);	        
	        
	        insert listToCreate;
	        
	        List<Portal_Content__c> listToCreateSettings = new List<Portal_Content__c>();
	        Portal_Content__c settingMainPage = TestClassUtil.getSettings();
	        settingMainPage.Template_ID__c = template.Id;
	        settingMainPage.Child_List_Page__c = settingListPage.Id;
	        settingMainPage.Child_Page__c = settingDetailPage.Id;
	        settingMainPage.Component_Number__c = String.ValueOf(1);
	        settingMainPage.Content_Type__c = 'Rich Text';
	        settingMainPage.Article_Feed_Title__c = 'Announcement';
	        settingMainPage.Content_Category__c = 'General';
	        settingMainPage.Distribution_Level__c = 'Site';
	        settingMainPage.Distribution_Target__c = 'TALCORP';
			listToCreateSettings.add(settingMainPage);
			
			Portal_Content__c settingMainPage2 = TestClassUtil.getSettings();
	        settingMainPage2.Template_ID__c = template.Id;
	        settingMainPage2.Component_Number__c = String.ValueOf(2);
	        settingMainPage2.Content_Type__c = 'HTML';
	        settingMainPage2.HTML_Selected__c = HTML.Id;
			listToCreateSettings.add(settingMainPage2);
			/*
			Portal_Content__c settingMainPage3 = TestClassUtil.getSettings();
	        settingMainPage3.Template_ID__c = template.Id;
	        settingMainPage3.BU__c = '';
	        settingMainPage3.Component_Number__c = String.ValueOf(3);
	        settingMainPage3.Content_Type__c = 'Video';
	        settingMainPage3.Video_Selected__c = video.Id;
			listToCreateSettings.add(settingMainPage3);	        

			Portal_Content__c settingMainPage4 = TestClassUtil.getSettings();
	        settingMainPage4.Template_ID__c = template.Id;
	        settingMainPage4.Component_Number__c = String.ValueOf(4);
	        settingMainPage4.Content_Type__c = 'Chatter';
	        settingMainPage4.Chatter_Feed_ID__c = chatterGroup.Id;
			settingMainPage4.Number_of_Slides__c = 1;
			settingMainPage4.Slideshow_Topic__c = 'Test1;Test2';
			listToCreateSettings.add(settingMainPage4);	 			
			
			Portal_Content__c settingMainPage5 = TestClassUtil.getSettings();
	        settingMainPage5.Template_ID__c = template.Id;
	        settingMainPage5.Component_Number__c = String.ValueOf(5);
	        settingMainPage5.Content_Type__c = 'Rich Text';
	        settingMainPage5.Fixed_Component__c = 'List View';
	        settingMainPage5.Child_Page__c = settingDetailPage.Id;
			listToCreateSettings.add(settingMainPage5);	
			
	        Portal_Content__c settingMainPage6 = TestClassUtil.getSettings();
	        settingMainPage6.Template_ID__c = template.Id;
	        settingMainPage6.Component_Number__c = String.ValueOf(6);
	        settingMainPage6.Content_Type__c = 'Rich Text';
	        settingMainPage6.Fixed_Component__c = 'Article Detail';
			listToCreateSettings.add(settingMainPage6);	
			
			Portal_Content__c settingMainPage7 = TestClassUtil.getSettings();
	        settingMainPage7.Template_ID__c = template.Id;
	        settingMainPage7.Component_Number__c = String.ValueOf(6);
	        settingMainPage7.Content_Type__c = 'RSS';
	        settingMainPage7.RSS_Feed_URL__c = 'http://www.computerweekly.com/rss/All-Computer-Weekly-content.xml';
	        settingMainPage7.RSS_Title__c = 'Computer';
			listToCreateSettings.add(settingMainPage7);			
			*/
			insert listToCreateSettings;			
	        
			PageReference pageRef = Page.ACGMainTemplate1_Left;

        	System.Test.setCurrentPage(pageRef);
        	
			ApexPages.currentPage().getParameters().put('uniquePageName', 'MainPage_General_Site_TALCORP');
			ApexPages.currentPage().getParameters().put('title', 'Announcement');
			
        	ACGCtrl extn = new  ACGCtrl();

        	String str = extn.strSiteMapId;
        	Integer num1 = extn.newArticleNum;
        	Boolean bFollow = extn.bFollowing;
        	Boolean bEdit = extn.bEditMode;
        	
        	System.assertEquals(false, str==null);
        	System.assertEquals(1, num1);
        	System.assertEquals(false, bFollow);
			PageReference prFollow = ACGCtrl.followPage(chatterGroup.Id);
			bFollow = extn.bFollowing;
			System.assertEquals(false, bFollow);
            
	        //PageReference prUnFollow = ACGCtrl.unfollowPage(chatterGroup.Id);
	        //bFollow = extn.bFollowing;
	        //System.assertEquals(false, bFollow);
        	//PageReference prForceSubmit = extn.forceSubmit();
		}  
    }
    
	static testMethod void positiveCase2() {            
    	List<User> users = new List<User>();
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	User u2 = TestClassUtil.getTestACGSystemAdminUser();
    	users.add(u);
    	users.add(u2);
    	
    	insert users;
		System.runAs(u) {
				        
			Portal_Content__c template = TestClassUtil.getTemplate();
			template.Tech_Total_Component__c = 8;
	        insert template;	  
	              
	        String groupName = 'Test Group' + TestClassUtil.generateRandomString();
	        CollaborationGroup chatterGroup = new CollaborationGroup(Name=groupName, CollaborationType='Public');
			chatterGroup.OwnerId = u2.Id;
			try {
				insert chatterGroup;
			} catch (exception ex) {
				//chatterGroup = [Select Id, Name From CollaborationGroup Where Name = :groupName limit 1];
			}	
	        
	        FeedItem ChatterPhoto = TestClassUtil.getChatterPhoto();
	        ChatterPhoto.ParentId=chatterGroup.Id;
	        insert ChatterPhoto;
	        
	        FeedItem ChatterFile = TestClassUtil.getChatterFile();
	        ChatterFile.ParentId=chatterGroup.Id;
	        insert ChatterFile;
	        
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
	        
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        listToCreate.add(announcement);   
	        
	        Portal_Content__c settingDetailPage = TestClassUtil.getSettings();
	        settingDetailPage.Template_ID__c = template.Id;
	        settingDetailPage.Page_Name__c = 'DetailPage';
	        settingDetailPage.Content_Type__c = 'Rich Text';
	        settingDetailPage.Fixed_Component__c = 'Article Detail';
	        insert (settingDetailPage);	   
	        
	        Portal_Content__c settingListPage = TestClassUtil.getSettings();
	        settingListPage.Template_ID__c = template.Id;
	        settingListPage.Page_Name__c = 'ListPage';
	        settingListPage.Content_Type__c = 'Rich Text';
	        settingListPage.Fixed_Component__c ='List View';
	        settingListPage.Child_Page__c = settingDetailPage.Id;
	        listToCreate.add(settingListPage);	             
	        
	        Portal_Content__c video = TestClassUtil.getVideo();
	        listToCreate.add(video);
	        
	        Portal_Content__c HTML = TestClassUtil.getHTML();
	        listToCreate.add(HTML);
	        
	        Portal_Content__c HTMLSiteMap = TestClassUtil.getHTML();
	        HTMLSiteMap.System_Setting__c ='SiteMap';	        
	        listToCreate.add(HTMLSiteMap);
	        
	        Portal_Content__c HTMLBlank = TestClassUtil.getHTML();
	        HTMLBlank.System_Setting__c ='BlankHTML';	        
	        listToCreate.add(HTMLBlank);	        
	        
	        insert listToCreate;
	        
	        List<Portal_Content__c> listToCreateSettings = new List<Portal_Content__c>();
	        Portal_Content__c settingMainPage = TestClassUtil.getSettings();
	        settingMainPage.Template_ID__c = template.Id;
	        settingMainPage.Child_List_Page__c = settingListPage.Id;
	        settingMainPage.Child_Page__c = settingDetailPage.Id;
	        settingMainPage.Component_Number__c = String.ValueOf(1);
	        settingMainPage.Content_Type__c = 'Rich Text';
	        settingMainPage.Article_Feed_Title__c = 'Announcement';
	        settingMainPage.Content_Category__c = 'General';
	        settingMainPage.Distribution_Level__c = 'Site';
	        settingMainPage.Distribution_Target__c = 'TALCORP';
			listToCreateSettings.add(settingMainPage);
			
			Portal_Content__c settingMainPage2 = TestClassUtil.getSettings();
	        settingMainPage2.Template_ID__c = template.Id;
	        settingMainPage2.Component_Number__c = String.ValueOf(2);
	        settingMainPage2.Content_Type__c = 'HTML';
	        settingMainPage2.HTML_Selected__c = HTML.Id;
			listToCreateSettings.add(settingMainPage2);
			/*
			Portal_Content__c settingMainPage3 = TestClassUtil.getSettings();
	        settingMainPage3.Template_ID__c = template.Id;
	        settingMainPage3.BU__c = '';
	        settingMainPage3.Component_Number__c = String.ValueOf(3);
	        settingMainPage3.Content_Type__c = 'Video';
	        settingMainPage3.Video_Selected__c = video.Id;
			listToCreateSettings.add(settingMainPage3);	        

			Portal_Content__c settingMainPage4 = TestClassUtil.getSettings();
	        settingMainPage4.Template_ID__c = template.Id;
	        settingMainPage4.Component_Number__c = String.ValueOf(4);
	        settingMainPage4.Content_Type__c = 'Chatter';
	        settingMainPage4.Chatter_Feed_ID__c = chatterGroup.Id;
			settingMainPage4.Number_of_Slides__c = 1;
			settingMainPage4.Slideshow_Topic__c = 'Test1;Test2';
			listToCreateSettings.add(settingMainPage4);	 			
			
			Portal_Content__c settingMainPage5 = TestClassUtil.getSettings();
	        settingMainPage5.Template_ID__c = template.Id;
	        settingMainPage5.Component_Number__c = String.ValueOf(5);
	        settingMainPage5.Content_Type__c = 'Rich Text';
	        settingMainPage5.Fixed_Component__c = 'List View';
	        settingMainPage5.Child_Page__c = settingDetailPage.Id;
			listToCreateSettings.add(settingMainPage5);	
			
	        Portal_Content__c settingMainPage6 = TestClassUtil.getSettings();
	        settingMainPage6.Template_ID__c = template.Id;
	        settingMainPage6.Component_Number__c = String.ValueOf(6);
	        settingMainPage6.Content_Type__c = 'Rich Text';
	        settingMainPage6.Fixed_Component__c = 'Article Detail';
			listToCreateSettings.add(settingMainPage6);	
			
			Portal_Content__c settingMainPage7 = TestClassUtil.getSettings();
	        settingMainPage7.Template_ID__c = template.Id;
	        settingMainPage7.Component_Number__c = String.ValueOf(6);
	        settingMainPage7.Content_Type__c = 'RSS';
	        settingMainPage7.RSS_Feed_URL__c = 'http://www.computerweekly.com/rss/All-Computer-Weekly-content.xml';
	        settingMainPage7.RSS_Title__c = 'Computer';
			listToCreateSettings.add(settingMainPage7);			
			*/
			insert listToCreateSettings;			
	        
			PageReference pageRef = Page.ACGMainTemplate1_Left;

        	System.Test.setCurrentPage(pageRef);
        	
			ApexPages.currentPage().getParameters().put('uniquePageName', 'MainPage_General_Site_TALCORP');
			ApexPages.currentPage().getParameters().put('title', 'Announcement');
			
        	ACGCtrl extn = new  ACGCtrl();
        	List<Portal_Content__c> returnLists = extn.getSettings();
        	List<DepartmentWrapper> returnDepts = extn.getDepartmentList();
        	List<ContentVersionWrapper> returnCV = extn.getChatterFiles();
        	List<ContentVersionWrapper> returnCV2 = extn.getChatterPhotos();
		}  
    }
}