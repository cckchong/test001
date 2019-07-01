@isTest
private class TestACGArticleEditCtrlVFClass {
    
    static testMethod void readArticle() {      
        User u = TestClassUtil.getTestACGSystemAdminUser();
        insert u;
        System.runAs(u) {
            // The following code runs as user 'u'      
            
            //List<ACG_Hierarchy__c> acgs = TestClassUtil.getTestACGHierarchy();
            //insert acgs;
                        
            List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
            Portal_Content__c announcement = TestClassUtil.getAnnouncement();               
            insert announcement;
            
            PageReference pageRef = Page.ACGMainTemplate1_Left;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('Id', announcement.Id); 
            
            ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
            ACGArticleEditCtrl extn = new  ACGArticleEditCtrl(controller);
            PageReference pr1 = extn.switchLanguageInEditMode();
            extn.switchLanguageInReadMode();
            PageReference pr3 = extn.sendNotificationEmail();
            PageReference pr4 = extn.edit();
            extn.save();
            PageReference pr6 = extn.cancel();
            PageReference pr7 = extn.shareRecord();
            extn.objPC.Status__c = 'Draft';
            PageReference pr2 = extn.previewArticle();
            PageReference pr8 = extn.cloneRecord();
            PageReference pr9 = extn.publishArticle();
            PageReference pr10 = extn.UnpublishArticle();
            PageReference pr11 = extn.refreshAllDistributionOnChangeConCat();
            PageReference pr12 = extn.refreshAllDistributionOnChangeArticleType();
            PageReference pr13 = extn.refreshAllDistribution();
            
            System.assertEquals('Sample Title', extn.objPC.Title_en__c);
            
            List<String> listStrings2 = extn.getLanguages();
            Map<String, String> mapStrings2 = extn.getSummaryLangVar();
            Map<String, String> mapStrings3 = extn.getTitleLangVar();
            Map<String, String> mapStrings4 = extn.getContentsLangVar();
            Map<String, String> mapStrings5 = extn.getRevisedLangVar();
            String str = extn.setEditorLang;
            extn.strLanguage = 'en';
            String strLang = extn.getLanguageLabel();
            
            extn.deleteRecord();
        }           
    }
    
    static testMethod void createArticle() {        
        User u = TestClassUtil.getTestACGSystemAdminUser();
        insert u;
        System.runAs(u) {
            // The following code runs as user 'u'      
            List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
            Portal_Content__c announcement = TestClassUtil.getAnnouncement();               
            insert announcement;
            
            PageReference pageRef = Page.ACGMainTemplate1_Left;
            Test.setCurrentPage(pageRef);
            
            RecordType rt = [Select Id, Name From RecordType Where DeveloperName = 'Rich_Text' limit 1];
            ApexPages.currentPage().getParameters().put('Id', announcement.Id);
            ApexPages.currentPage().getParameters().put('Create', 'true');
            ApexPages.currentPage().getParameters().put('RecordTypeId', rt.Id);         
            
            ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
            ACGArticleEditCtrl extn = new  ACGArticleEditCtrl(controller);
            //Fill in information
            extn.bIsBlog = false;
            extn.objPC.Content_Category__c = 'General';
            extn.selectedContentCategory = 'General';           
            extn.objPC.Distribution_Level__c = 'Site';
            extn.selectedDistLevel = 'Site';            
            extn.objPC.Distribution_Target__c = 'TALCORP';
            extn.selectedDistTarget.add(new SelectOption('TALCORP','TALCORP'));         
            extn.objPC.title_en__c ='Sample Title';
            extn.objPC.summary_en__c = 'Sample Summary'; 

            PageReference pr1 = extn.switchLanguageInEditMode();
            extn.switchLanguageInReadMode();
            PageReference pr3 = extn.sendNotificationEmail();
            PageReference pr4 = extn.edit();
            extn.save();
            PageReference pr6 = extn.cancel();
            PageReference pr7 = extn.shareRecord();
            PageReference pr2 = extn.previewArticle();
            PageReference pr8 = extn.cloneRecord();
            PageReference pr9 = extn.publishArticle();
            PageReference pr10 = extn.UnpublishArticle();
            PageReference pr11 = extn.refreshAllDistributionOnChangeConCat();
            PageReference pr12 = extn.refreshAllDistributionOnChangeArticleType();
            PageReference pr13 = extn.refreshAllDistribution();
            
            System.assertEquals('Sample Title', extn.objPC.Title_en__c);
            
            List<String> listStrings2 = extn.getLanguages();
            Map<String, String> mapStrings2 = extn.getSummaryLangVar();
            Map<String, String> mapStrings3 = extn.getTitleLangVar();
            Map<String, String> mapStrings4 = extn.getContentsLangVar();
            Map<String, String> mapStrings5 = extn.getRevisedLangVar();
            String str = extn.setEditorLang;
            extn.strLanguage = 'en';
            String strLang = extn.getLanguageLabel();
        }           
    }
    
    
        //add by DTT
        @isTest (seealldata=true)
        static void uploadedDocument() {      
        // User u = TestClassUtil.getTestACGSystemAdminUser();
        // insert u;
        // System.runAs(u) {
            // The following code runs as user 'u'      
          List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
            Portal_Content__c announcement = TestClassUtil.getAnnouncement();               
            insert announcement;
            
            PageReference pageRef = Page.ACGMainTemplate1_Left;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('Id', announcement.Id); 
            
            ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
            ACGArticleEditCtrl extn = new  ACGArticleEditCtrl(controller);
            RecordType rt = [Select Id, Name From RecordType Where DeveloperName = 'Rich_Text' limit 1];
            ApexPages.currentPage().getParameters().put('Id', announcement.Id);
            ApexPages.currentPage().getParameters().put('Create', 'true');
            ApexPages.currentPage().getParameters().put('RecordTypeId', rt.Id); 
            extn.bIsBlog = false;
            extn.objPC.Content_Category__c = 'General';
            extn.selectedContentCategory = 'General';           
            extn.objPC.Distribution_Level__c = 'Site';
            extn.selectedDistLevel = 'Site';            
            extn.objPC.Distribution_Target__c = 'TALCORP';
            extn.selectedDistTarget.add(new SelectOption('TALCORP','TALCORP'));         
            extn.objPC.title_en__c ='Sample Title';
            extn.objPC.summary_en__c = 'Sample Summary'; 
            extn.documentContent=Blob.valueOf('11111');
            extn.documentContent1=Blob.valueOf('11111');
            extn.documentContent2=Blob.valueOf('11111');
            extn.documentContent3=Blob.valueOf('11111');
            extn.documentContent4=Blob.valueOf('11111');
            extn.documentName='1111';
            extn.documentName1='1111';
            extn.documentName2='1111';
            extn.documentName3='1111';
            extn.documentName4='1111';  
            PageReference pr1 = extn.switchLanguageInEditMode();
            extn.switchLanguageInReadMode();
            PageReference pr3 = extn.sendNotificationEmail();
            PageReference pr4 = extn.edit();
            extn.save();
            extn.bCreate=true;
            extn.saveCreate();
            PageReference pr6 = extn.cancel();
            PageReference pr7 = extn.shareRecord();
            extn.objPC.Status__c = 'Draft';
            PageReference pr2 = extn.previewArticle();
            PageReference pr8 = extn.cloneRecord();
            PageReference pr9 = extn.publishArticle();
            PageReference pr10 = extn.UnpublishArticle();
            PageReference pr11 = extn.refreshAllDistributionOnChangeConCat();
            PageReference pr12 = extn.refreshAllDistributionOnChangeArticleType();
            PageReference pr13 = extn.refreshAllDistribution();
            
            System.assertEquals('Sample Title', extn.objPC.Title_en__c);
            
            List<String> listStrings2 = extn.getLanguages();
            Map<String, String> mapStrings2 = extn.getSummaryLangVar();
            Map<String, String> mapStrings3 = extn.getTitleLangVar();
            Map<String, String> mapStrings4 = extn.getContentsLangVar();
            Map<String, String> mapStrings5 = extn.getRevisedLangVar();
            String str = extn.setEditorLang;
            extn.strLanguage = 'en';
            String strLang = extn.getLanguageLabel();
            
            extn.deleteRecord();
        // }           
    }
}