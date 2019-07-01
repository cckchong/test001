/**
 * Test for LibraryTransferRequestCtrl
 */
@isTest
public class TestLibraryTransferRequestCtrl {
    
    static testMethod void myUnitTest() {
        
        Location__c genLoc = LibraryTestDataUtility.insertGenLocation('HKO');
        Location__c detailLoc = LibraryTestDataUtility.insertDetailLocation('HKO',genLoc.id);
        
        Library_Item__c li = LibraryTestDataUtility.insertLibItem('Warehouse');
        Library_Inventory__c inv = [select id, Target_Address__c, Detail_Current_Location__c from Library_Inventory__c limit 1];
        inv.Target_Address__c = genLoc.id;
        inv.Detail_Current_Location__c = detailLoc.id;
        update inv;
        
        Library_Item_Request__c lir1 = LibraryTestDataUtility.insertLibraryRequestNotSubmitted();
        lir1.Library_Item__c =li.id;
        lir1.Status__c = Label.Library_Request_Status_Waitlist;
        lir1.Target_Location__c = detailLoc.id;
        
        update lir1;
        
        Library_Item_Request__c lir = LibraryTestDataUtility.insertLibraryRequestNotSubmitted();
        lir.Library_Item__c = li.id;
        lir.Library_Request_Inventory__c = inv.id;
        lir.Status__c = Label.Library_Request_Status_Inbound;
        lir.Target_Location__c = detailLoc.id;
        update lir;
        
        
        // Setup a Mock standard page
        ApexPages.StandardController sc = new ApexPages.StandardController(lir);
        PageReference pageRef = Page.LibraryTransferRequestVFPage;
        pageRef.getParameters().put('id', lir.id);
        Test.setCurrentPage(pageRef);
        LibraryTransferRequestCtrl ltr = new LibraryTransferRequestCtrl(sc);
        
        
        
        PageReference p = ltr.transfer();
               
    }
}