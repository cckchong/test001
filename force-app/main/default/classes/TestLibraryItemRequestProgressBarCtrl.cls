/**
 * Test for LibraryItemRequestProgressBarCtrl 
 */
@isTest
public class TestLibraryItemRequestProgressBarCtrl {
    static testMethod void unitTest() {
        
        Library_Item_Request__c lir = LibraryTestDataUtility.insertLibraryRequestNotSubmitted();
        
        // Setup a Mock standard page
        ApexPages.StandardController sc = new ApexPages.StandardController(lir);
        LibraryItemRequestProgressBarCtrl pb = new LibraryItemRequestProgressBarCtrl(sc);
        
        System.assertNotEquals(pb.MyRequest, null);
       
        
        System.assertEquals(pb.MyRequest.Id, lir.Id);
        System.assertEquals(pb.MyRequest.Request_Progress__c, 1);
        System.assertEquals(pb.MyRequest.Request_Progress_Book__c, 1);
        System.assertEquals(pb.MyRequest.Request_Progress_BBA__c, 1);        
    }
}