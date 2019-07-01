/*
* Test class of LibraryItemRequestDeleteCtrl 
*/
@isTest
private class TestLibraryItemRequestDeleteCtrl {

    static testMethod void unitTest() {
        
        Library_Item__c li = LibraryTestDataUtility.insertLibraryItem();
        
        Library_Item_Request__c lir = new Library_Item_Request__c(
            Status__c = 'Not Submitted',
            Library_Item__c = li.id
        );
        
        insert lir;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lir);
        LibraryItemRequestOverwriteDeleteCtrl del = new LibraryItemRequestOverwriteDeleteCtrl(sc);
        
        system.assertNotEquals(null, del);
        
        del.onload();
        
        
        User u1= LibraryTestDataUtility.createUser(Label.Library_Profile_TFEBAA);
        System.runAs(u1){
            Library_Item__c li1 = LibraryTestDataUtility.insertLibraryItem();
            Library_Item_Request__c lir1 = new Library_Item_Request__c(
                Status__c = 'Reserved',
                Library_Item__c = li1.id
            );
        
            insert lir1;
             sc = new ApexPages.StandardController(lir1);
             del = new LibraryItemRequestOverwriteDeleteCtrl(sc);
             del.onload();
        }
        
    }
}