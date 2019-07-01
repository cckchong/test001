/**
 * Test for LibraryPrintQRCodeCtrl 
 */
@isTest
public class TestLibraryPrintQRCodeCtrl {
    static testMethod void myUnitTest(){
        
        Library_Item__c li = LibraryTestDataUtility.insertLibraryItem();
        
        // Inserting a Library Item should give us an Inventory
        
        List<Library_Inventory__c> linvList = 
            [
                SELECT Id
                FROM Library_Inventory__c
                WHERE Library_Item_Master__c =: li.Id
            ];
        
        System.assertNotEquals(null, linvList);
        System.assertEquals(1, linvList.size());
        
        // Setup a Mock standard page
        ApexPages.StandardController sc = new ApexPages.StandardController(linvList[0]);
        LibraryPrintQRCodeCtrl qr = new LibraryPrintQRCodeCtrl(sc);
        PageReference pageRef = Page.LibraryPrintQRCodeVFpage;
        pageRef.getParameters().put('id', String.valueOf(li.Id));
        Test.setCurrentPage(pageRef);
        
        System.assertEquals(qr.inv.Id, linvList[0].Id);      
    }
}