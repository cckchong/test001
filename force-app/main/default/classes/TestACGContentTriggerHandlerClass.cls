/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestACGContentTriggerHandlerClass {

    static testMethod void myUnitTest() {
        List<Portal_Content__c> listTriggerNew = new List<Portal_Content__c>();
        List<Portal_Content__c> listTriggerOld = new List<Portal_Content__c>();
        Map<Id,Portal_Content__c> NewMapPortalContent = new Map<Id,Portal_Content__c>();
        Map<Id,Portal_Content__c> OldMapPortalContent = new Map<Id,Portal_Content__c>();
		
		Portal_Content__c announcement = TestClassUtil.getAnnouncement();
		announcement.Revised_en__c = true;
		announcement.Revised_zhhk__c = true;
		announcement.Revised_zhcn__c = true;
		announcement.Revised_th__c = true;
		announcement.Revised_vi__c = true;
		announcement.Revised_id__c = true;
		insert announcement;
		NewMapPortalContent.put(announcement.Id, announcement);
		
		Portal_Content__c announcement2 = TestClassUtil.getAnnouncement();
		announcement2.Revised_en__c = false;
		announcement2.Revised_zhhk__c = false;
		announcement2.Revised_zhcn__c = false;
		announcement2.Revised_th__c = false;
		announcement2.Revised_vi__c = false;
		announcement2.Revised_id__c = false;
		insert announcement2;
		
		announcement.Id = announcement2.Id;
		listTriggerNew.add(announcement);
		OldMapPortalContent.put(announcement2.Id, announcement2);
		
		RecordType rt = [Select Id, Name From RecordType Where DeveloperName = 'Rich_Text' limit 1];
		ACGContentTriggerHandler.addReviseWord(listTriggerNew, OldMapPortalContent, rt);
		
		ACGContentTriggerHandler.storeCreatedDateAndLastModdate(listTriggerNew, rt);
		System.assertEquals(listTriggerNew.get(0).LastModifiedDate, listTriggerNew.get(0).Tech_LastUpdateDate__c);
		
		listTriggerNew.get(0).Tech_CreatedDate__c = date.today();
		ACGContentTriggerHandler.storeCreatedDateAndLastModdate(listTriggerNew, rt);
		
    }
    
    static testMethod void mySharingRulesTest() {
    	
		Portal_Content__c template = TestClassUtil.getTemplate();
        insert template;
        
        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
        Portal_Content__c Video = TestClassUtil.getVideo();
      	listToCreate.add(Video);     
        Portal_Content__c HTML = TestClassUtil.getHTML();
       	listToCreate.add(HTML);   
       	insert listToCreate;
       	   
        Portal_Content__c settingVideo = TestClassUtil.getSettings();
        settingVideo.Template_ID__c = template.Id;
        settingVideo.Page_Name__c = 'MainPage';
        settingVideo.Content_Type__c = 'Video';
        settingVideo.Video_Selected__c = Video.Id;
        insert settingVideo;
        
        Portal_Content__c settingHTML = TestClassUtil.getSettings();
        settingHTML.Template_ID__c = template.Id;
        settingHTML.Page_Name__c = 'MainPage';
        settingHTML.Content_Type__c = 'HTML';
        settingHTML.HTML_Selected__c = HTML.Id;
        insert settingHTML;
        
        update settingHTML;
	        
    }
}