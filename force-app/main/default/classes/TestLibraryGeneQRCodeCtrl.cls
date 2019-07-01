/*
* Test class of LibraryGeneQRCodeCtrl
*/
@isTest
private class TestLibraryGeneQRCodeCtrl {

    static testMethod void myUnitTest() {
        
        
        
        Library_Item__c li = LibraryTestDataUtility.insertLibraryItem();
        
        // Inserting a Library Item should give us an Inventory
        
        List<Library_Inventory__c> linvList = 
            [
                SELECT Id
                FROM Library_Inventory__c
                WHERE Library_Item_Master__c =: li.Id
            ];
            
        
        ApexPages.StandardController sc = new ApexPages.StandardController(linvList[0]);
        
        LibraryGenerateQRCodeCtrl lgc = new LibraryGenerateQRCodeCtrl(sc);
        system.assertEquals(lgc.inv, null);
        system.assertEquals(lgc.bPrintableView, false);
        PageReference pageRef = Page.LibraryPrintQRCodeVFpage;
        pageRef.getParameters().put('generate', 'true');
        Test.setCurrentPage(pageRef);
        
        lgc.genQrCode();
        system.assertEquals(lgc.donothing(),null);
        LibraryGenerateQRCodeCtrl.autonumber('321100','321');
        
    }
}