@isTest
private class TestACGPreviewCtrlVFClass {

    static testMethod void previewAnnouncement() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c pc = TestClassUtil.getAnnouncement();
	        insert pc;
	        
	        PageReference pageRef = Page.ACGMainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('Id', pc.Id);
	        ApexPages.currentPage().getParameters().put('iSize', '12');
	        ApexPages.currentPage().getParameters().put('type', 'richtext');
	        
	        ACGPreviewCtrl extn = new  ACGPreviewCtrl();
	        System.assertEquals(1, extn.portalComponent.size());
     	}	        
    }
    
    static testMethod void previewHTML() {    	
    	User u = TestClassUtil.getTestACGSystemAdminUser();
    	insert u;
		System.runAs(u) {
			// The following code runs as user 'u' 		
			Portal_Content__c html = TestClassUtil.getHTML();
        	insert html;	
	        
	        PageReference pageRef = Page.ACGMainTemplate1_Left;
        	Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('Id', html.Id);
	        ApexPages.currentPage().getParameters().put('iSize', '12');
	        ApexPages.currentPage().getParameters().put('type', 'HTML');
	        
	        ACGPreviewCtrl extn = new  ACGPreviewCtrl();	        
        	System.assertEquals(1, extn.portalComponent.size());
     	}	        
    }
}