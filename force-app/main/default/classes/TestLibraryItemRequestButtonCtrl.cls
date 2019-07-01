/*
*	Test Class of LibraryItemRequestButtonCtrl
*/
@isTest
private class TestLibraryItemRequestButtonCtrl {
	
	static testMethod void unitTestBook() {
    	
    	LibraryTestDataUtility.insertLibraryCategorySettings();
        
        Library_Item__c li = LibraryTestDataUtility.insertLibItem(Label.Library_RecordType_Book);
        Library_Inventory__c inv = [select id from Library_Inventory__c limit 1];
        
        Library_Item_Request__c lir = LibraryTestDataUtility.insertLibRequest(li.id, inv.id,'Reserved');
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lir);
        LibraryItemRequestButtonCtrl buttonCtrl = new LibraryItemRequestButtonCtrl(sc);
        
        PageReference p1 = buttonCtrl.warehouseCheckOutAction();
        PageReference p8 = buttonCtrl.RenewButtonAction();
        PageReference p2 = buttonCtrl.warehouseCheckInAction();
        
        
    }
	
    static testMethod void unitTestBurBerry() {
    	
    	LibraryTestDataUtility.insertLibraryCategorySettings();
    	
        Library_Item__c li = LibraryTestDataUtility.insertLibItem(Label.Library_Item_category_Burberry);
        Library_Inventory__c inv = [select id from Library_Inventory__c limit 1];
         Library_Item_Request__c lir = LibraryTestDataUtility.insertLibRequest(li.id, inv.id,'Reserved');
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lir);
        LibraryItemRequestButtonCtrl buttonCtrl = new LibraryItemRequestButtonCtrl(sc);
        
        PageReference p1 = buttonCtrl.warehouseCheckOutAction();
        PageReference p3 = buttonCtrl.mailRoomCheckInOutboundAction();
        PageReference p5 = buttonCtrl.receiveAction(); 
        PageReference p8 = buttonCtrl.RenewButtonAction();
        PageReference p4 = buttonCtrl.mailRoomCheckInInboundAction();
        PageReference p2 = buttonCtrl.warehouseCheckInAction();
    }
    
    static testMethod void unitTestPD() {
    	
    	LibraryTestDataUtility.insertLibraryCategorySettings();
    	
        Library_Item__c li = LibraryTestDataUtility.insertLibItem(Label.Library_Item_category_Samples_PD);
        
        Library_Item_Request__c lir = new Library_Item_Request__c(
            Status__c = 'Not Submitted',
            Library_Item__c = li.id
        );
        insert lir;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lir);
        LibraryItemRequestButtonCtrl buttonCtrl = new LibraryItemRequestButtonCtrl(sc);
        
        PageReference p1 = buttonCtrl.warehouseCheckOutAction();
        PageReference p2 = buttonCtrl.warehouseCheckInAction();
        PageReference p3 = buttonCtrl.mailRoomCheckInOutboundAction();
        PageReference p4 = buttonCtrl.mailRoomCheckInInboundAction();
        PageReference p5 = buttonCtrl.receiveAction(); 
        PageReference p6 = buttonCtrl.reportLostAction();
        PageReference p7 = buttonCtrl.cancelAction();
        PageReference p8 = buttonCtrl.RenewButtonAction();
    }
    
    static testMethod void unitTestWarehouse() {
    	
    	LibraryTestDataUtility.insertLibraryCategorySettings();
        Library_Item__c li = LibraryTestDataUtility.insertLibItem(Label.Library_Item_category_Warehouse);
        
        Library_Item_Request__c lir = new Library_Item_Request__c(
            Status__c = 'Not Submitted',
            Library_Item__c = li.id
        );
        insert lir;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lir);
        LibraryItemRequestButtonCtrl buttonCtrl = new LibraryItemRequestButtonCtrl(sc);
        
        PageReference p1 = buttonCtrl.warehouseCheckOutAction();
        PageReference p2 = buttonCtrl.warehouseCheckInAction();
        PageReference p3 = buttonCtrl.mailRoomCheckInOutboundAction();
        PageReference p4 = buttonCtrl.mailRoomCheckInInboundAction();
        PageReference p5 = buttonCtrl.receiveAction(); 
        PageReference p6 = buttonCtrl.reportLostAction();
        PageReference p7 = buttonCtrl.cancelAction();
        PageReference p8 = buttonCtrl.RenewButtonAction();
    }
    
}