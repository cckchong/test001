/*
* Test Class of LibraryGeneQRCodeCtrl
*/
@isTest
private class TestLibraryItemDetailImageCtrl {

    static testMethod void unitTest() {
        Library_Item__c li = LibraryTestDataUtility.insertLibraryItem();
        
       
        ApexPages.StandardController sc = new ApexPages.StandardController(li);
        LibraryItemDetailImageCtrl lic = new LibraryItemDetailImageCtrl(sc);
        
        System.assertEquals(lic.photoAttachmentList, new List<Attachment>());
        
    }
}