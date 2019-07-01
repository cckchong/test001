@isTest
private class TestPortal_ContentTriggerHandlerClass {
	/*
    static testMethod void myUnitTest() {
        List<Portal_Content__c> listTriggerNew = new List<Portal_Content__c>();
        List<Portal_Content__c> listTriggerOld = new List<Portal_Content__c>();
        Map<Id,Portal_Content__c> NewMapPortalContent = new Map<Id,Portal_Content__c>();
        Map<Id,Portal_Content__c> OldMapPortalContent = new Map<Id,Portal_Content__c>();
		
		Portal_Content__c announcement = TestUtil.getAnnouncement();
		announcement.Revised_en__c = true;
		announcement.Revised_zhhk__c = true;
		announcement.Revised_zhcn__c = true;
		announcement.Revised_th__c = true;
		announcement.Revised_vi__c = true;
		announcement.Revised_id__c = true;
		insert announcement;
		NewMapPortalContent.put(announcement.Id, announcement);
		
		Portal_Content__c announcement2 = TestUtil.getAnnouncement();
		announcement2.Revised_en__c = false;
		announcement2.Revised_zhhk__c = false;
		announcement2.Revised_zhcn__c = false;
		announcement2.Revised_th__c = false;
		announcement2.Revised_vi__c = false;
		announcement2.Revised_id__c = false;
		insert announcement2;
		announcement2.Tech_Distribution_Site_Formula_Text__c = '';
		announcement2.Tech_Distribution_Grade_Formula_Text__c = '';		
		update announcement2;
		
		announcement.Id = announcement2.Id;
		listTriggerNew.add(announcement);
		OldMapPortalContent.put(announcement2.Id, announcement2);
		
		RecordType rt = [Select Id, Name From RecordType Where DeveloperName = 'Rich_Text' limit 1];
		Portal_ContentTriggerHandler.addReviseWord(listTriggerNew, OldMapPortalContent, rt);
		
		Portal_ContentTriggerHandler.storeCreatedDateAndLastModdate(listTriggerNew, rt);
		System.assertEquals(listTriggerNew.get(0).LastModifiedDate, listTriggerNew.get(0).Tech_LastUpdateDate__c);
		
		listTriggerNew.get(0).Tech_CreatedDate__c = date.today();
		Portal_ContentTriggerHandler.storeCreatedDateAndLastModdate(listTriggerNew, rt);		
		
		Portal_ContentTriggerHandler.ensureSubCatIsDefined(listTriggerNew, rt);
		System.assertEquals(true, listTriggerNew.get(0).Sub_Category__c != null);
		
		listTriggerNew.get(0).Sub_Category__c = null;
		Portal_ContentTriggerHandler.ensureSubCatIsDefined(listTriggerNew, rt);
		
    }
    
    static testMethod void mySharingRulesTest() {
    	
    		Portal_Content__c template = TestUtil.getTemplate();
	        insert template;	      
	        
	        List<SiteSetting__c> sites = TestUtil.getSiteSettings();
	        insert sites;
	        			
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
			Portal_Content__c announcement = TestUtil.getAnnouncement();
	        listToCreate.add(announcement);     
	        
	        Portal_Content__c Video = TestUtil.getVideo();
	      	listToCreate.add(Video);     
	        Portal_Content__c HTML = TestUtil.getHTML();
	       	listToCreate.add(HTML);   
	       	insert listToCreate;
	       	   
	        Portal_Content__c settingVideo = TestUtil.getSettings();
	        settingVideo.Template_ID__c = template.Id;
	        settingVideo.Page_Name__c = 'MainPage';
	        settingVideo.Content_Type__c = 'Video';
	        settingVideo.BU__c = '';
	        settingVideo.Video_Selected__c = Video.Id;
	        insert settingVideo;
	        
	        Portal_Content__c settingHTML = TestUtil.getSettings();
	        settingHTML.Template_ID__c = template.Id;
	        settingHTML.Page_Name__c = 'MainPage';
	        settingHTML.Content_Type__c = 'HTML';
	        settingHTML.BU__c = '';
	        settingHTML.HTML_Selected__c = HTML.Id;
	        insert settingHTML;
	        
	        settingHTML.BU__c = 'IT';
	        update settingHTML;
	        
    }
    */
}