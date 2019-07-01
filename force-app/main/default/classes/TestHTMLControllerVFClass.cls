@isTest
private class TestHTMLControllerVFClass {
	
	static testMethod void createHTML() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
	        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();
			Portal_Content__c html = TestClassUtil.getHTML();	        
	        insert html;
	        
	        PageReference pageRef = Page.ACGMainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('Id', html.Id); 
	        ApexPages.currentPage().getParameters().put('Create', 'true');
	        ApexPages.currentPage().getParameters().put('RecordTypeId', html.RecordTypeId);
	        
	        
	        ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(html);   
	        HTMLEditVFPageController extn = new  HTMLEditVFPageController(controller);
	        	        
	        PageReference pr4 = extn.edit();
	        PageReference pr5 = extn.saveClone();
	        extn.save();	        
	        System.assertEquals('', extn.strErrorMessage);
	        
	        PageReference pr6 = extn.cancel();
	        PageReference pr7 = extn.shareRecord();
	        PageReference pr8 = extn.cloneRecord();
	        extn.saveCreate();
	        
	        Schema.DescribeSObjectResult r = Portal_Content__c.sObjectType.getDescribe();
			String keyPrefix = r.getKeyPrefix();
	        extn.deleteRecord();
	        System.assertEquals('/'+ keyPrefix + '/o', extn.redirectUrl);
     	}	        
    }
    
}