@isTest
private class TestPCOverrideNewButtonControllerVFClass {

	static testMethod void createAnnouncement() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        insert announcement;
	        
	        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Portal_Content__c; 
			Map<String,Schema.RecordTypeInfo> PortalContentRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
	        Id rtId = PortalContentRecordTypeInfo.get('Article').getRecordTypeId();
	        
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('RecordType', rtId);
	        
	        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
	        PortalContentOverrideNewButtonController extn = new  PortalContentOverrideNewButtonController(controller);
	        PageReference pageReturn = extn.onload();	        
			Boolean result = pageReturn.getUrl().contains('/apex/ACGArticleEditVFPage');
			System.assertEquals(true, result);			
     	}	        
    }
    
    static testMethod void createAnnouncementMasterRecordType() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        insert announcement;
	        
	        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Portal_Content__c; 
			Map<String,Schema.RecordTypeInfo> PortalContentRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
	        Id rtId = PortalContentRecordTypeInfo.get('Article').getRecordTypeId();
	        
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        //ApexPages.currentPage().getParameters().put('RecordType', rtId);
	        
	        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
	        PortalContentOverrideNewButtonController extn = new  PortalContentOverrideNewButtonController(controller);
	        PageReference pageReturn = extn.onload();	        
			Boolean result = pageReturn.getUrl().contains('/apex/ACGArticleEditVFPage') || pageReturn.getUrl().contains('/apex/HTMLEditVFPage');
			System.assertEquals(true, result);			
     	}	        
    }
    
    static testMethod void createHTML() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        insert announcement;
	        
	        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Portal_Content__c; 
			Map<String,Schema.RecordTypeInfo> PortalContentRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
	        Id rtId = PortalContentRecordTypeInfo.get('HTML').getRecordTypeId();
	        
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('RecordType', rtId);
	        
	        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
	        PortalContentOverrideNewButtonController extn = new  PortalContentOverrideNewButtonController(controller);
	        PageReference pageReturn = extn.onload();
	        Boolean result = pageReturn.getUrl().contains('/apex/HTMLEditVFPage');
			System.assertEquals(true, result);
     	}	        
    }
    
    static testMethod void createSettings() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        insert announcement;
	        
	        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Portal_Content__c; 
			Map<String,Schema.RecordTypeInfo> PortalContentRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
	        Id rtId = PortalContentRecordTypeInfo.get('Settings').getRecordTypeId();
	        
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('RecordType', rtId);
	        
	        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
	        PortalContentOverrideNewButtonController extn = new  PortalContentOverrideNewButtonController(controller);
	        PageReference pageReturn = extn.onload();
	        Boolean result = pageReturn.getUrl().contains('retURL=');
			System.assertEquals(true, result);
     	}	        
    }
    
	static testMethod void errorCase() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c announcement = TestClassUtil.getAnnouncement();
	        insert announcement;	        
	        
	        PageReference pageRef = Page.MainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('RecordType', 'a1234567891234');
	        
	        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(announcement);   
	        PortalContentOverrideNewButtonController extn = new  PortalContentOverrideNewButtonController(controller);
	        PageReference pageReturn = extn.onload();
	        System.assertEquals(null, pageReturn);
     	}	        
    }
}