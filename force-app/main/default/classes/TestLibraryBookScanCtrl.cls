/**
 * Test Class of LibraryBookScanCtrl
 */
@isTest
private class TestLibraryBookScanCtrl {
	
	//test method of reserved books
    static testMethod void unitTestReservedBook() {
    	
    	LibraryTestDataUtility.insertLibraryCategorySettings();
    	
        LibraryBookScanCtrl lCtrl = new LibraryBookScanCtrl();
        Employee__c e1;
        e1 = LibraryBookScanCtrl.authenticateExternalUser('12345');
        User u = LibraryTestDataUtility.createUser(Label.Library_Profile_SA);
        Employee__c e= LibraryTestDataUtility.insertEmployee('12345',u);
        e1 = LibraryBookScanCtrl.authenticateExternalUser('12345');
        
        Location__c genLoc = LibraryTestDataUtility.insertGenLocation('HKO');
        Location__c deLoc= LibraryTestDataUtility.insertDetailLocation('HKO-PD',genLoc.id);
        
        Location__c loc = LibraryBookScanCtrl.getLocation('HKO-PD');
        
        Library_Inventory__c bookinv = LibraryBookScanCtrl.getLibraryItemDetail('12345','123');
        
        library_Item__c bookItem = LibraryTestDataUtility.insertLibItem('Book');
        
        bookinv = [select id,Serial_Number__c, QR_Code_Number__c from library_Inventory__c];
        bookinv = LibraryBookScanCtrl.getLibraryItemDetail(bookinv.QR_Code_Number__c,'123');
        
        
        Library_Item_Request__c lir = LibraryTestDataUtility.insertLibRequest(bookItem.id,bookinv.id,Label.Library_Request_Status_Reserved);
        
        PageReference pageRef = Page.LibraryBookScanPage;
        pageRef.getParameters().put(Label.Library_multiLibItemId, bookinv.id);
        pageRef.getParameters().put(Label.Library_UserId, u.id);
        pageRef.getParameters().put(Label.Library_locationId, loc.id);
        Test.setCurrentPage(pageRef);
        
        system.assertEquals(bookinv.Lending_status__c,Label.Library_Inventory_Lending_Status_available);
        
        PageReference pr = lCtrl.BookScanProcessing();
        pageRef.getParameters().remove(Label.Library_locationId);
        pr = lCtrl.BookScanProcessing();
    }
    
    
    //test method of return book
    static testMethod void unitTestReturnBook() {
    	LibraryTestDataUtility.insertLibraryCategorySettings();
    	
        LibraryBookScanCtrl lCtrl = new LibraryBookScanCtrl();
        Employee__c e1;
        e1 = LibraryBookScanCtrl.authenticateExternalUser('12345');
        User u = LibraryTestDataUtility.createUser(Label.Library_Profile_SA);
        Employee__c e= LibraryTestDataUtility.insertEmployee('12345',u);
        e1 = LibraryBookScanCtrl.authenticateExternalUser('12345');
        
        Location__c genLoc = LibraryTestDataUtility.insertGenLocation('HKO');
        Location__c deLoc= LibraryTestDataUtility.insertDetailLocation('HKO-PD',genLoc.id);
        
        Location__c loc = LibraryBookScanCtrl.getLocation('HKO-PD');
        
        Library_Inventory__c bookinv = LibraryBookScanCtrl.getLibraryItemDetail('12345','123');
        
        library_Item__c bookItem = LibraryTestDataUtility.insertLibItem('Book');
        
        bookinv = [select id,Serial_Number__c, QR_Code_Number__c from library_Inventory__c];
        bookinv = LibraryBookScanCtrl.getLibraryItemDetail(bookinv.QR_Code_Number__c,'123');
        
        
        Library_Item_Request__c lir = LibraryTestDataUtility.insertLibRequest(bookItem.id,bookinv.id,Label.Library_Request_Status_Borrowed);
        
        PageReference pageRef = Page.LibraryBookScanPage;
        pageRef.getParameters().put(Label.Library_multiLibItemId, bookinv.id);
        pageRef.getParameters().put(Label.Library_locationId, loc.id);
        Test.setCurrentPage(pageRef);
        PageReference pr = lCtrl.bookReturn();
        
    }
    
}