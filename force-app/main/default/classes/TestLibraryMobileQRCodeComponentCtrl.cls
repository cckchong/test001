/**
 * Test for LibraryMobileQRCodeComponentCtrl 
 */
@isTest
public class TestLibraryMobileQRCodeComponentCtrl {

    static testMethod void myUnitTest(){
        Library_Item__c li = LibraryTestDataUtility.insertLibItem('Book');
        Library_Inventory__c inv = [select id, Serial_Number__c from Library_Inventory__c limit 1];
        LibraryMobileQrCodeComponentCtrl.bookBorrowAction(inv.Serial_Number__c);
    }
    
    static testMethod void unitTestForLendingStatusNotAvailable(){
        Library_Item__c li = LibraryTestDataUtility.insertLibItem('Book');
        Library_Inventory__c inv = [select id, Serial_Number__c from Library_Inventory__c limit 1];
        inv.Lending_Status__c = Label.Library_Book_Not_Available;
        update inv;
        
        try{
            String str = LibraryMobileQrCodeComponentCtrl.bookBorrowAction(inv.Serial_Number__c);
        }catch(TalException e){
            String TypeName = e.getTypeName();
            System.assertEquals('TalException', TypeName);

        }
    }
    
    static testMethod void unitTestForItemNotFound(){
        try{
            String str = LibraryMobileQrCodeComponentCtrl.bookBorrowAction('abc');
        }catch(TalException e){
            String TypeName = e.getTypeName();
            System.assertEquals('TalException', TypeName);
        }
    }
}