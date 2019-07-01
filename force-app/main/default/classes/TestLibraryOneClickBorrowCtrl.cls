/**
 * Test for LibraryOneClickBorrowCtrl'
 */
@isTest
public class TestLibraryOneClickBorrowCtrl {
    
    static testMethod void myUnitTest(){
       
        LibraryTestDataUtility.insertLibraryCategorySettings();
    	
    	LibraryOneClickBorrowCtrl lCtrl = new LibraryOneClickBorrowCtrl(null);
    	lCtrl.isSalesforceOne = false;
    	system.assertEquals(lCtrl.isSalesforceOne, false);
    	
        User u = LibraryTestDataUtility.createUser('System Administrator');
        lCtrl.isOverDue(u.id);
        
        String str = lCtrl.historyBack();
        
        Location__c genLoc = LibraryTestDataUtility.insertGenLocation('HKO');
        Location__c deLoc= LibraryTestDataUtility.insertDetailLocation('HKO-PD',genLoc.id);
        
        Location__c loc = LibraryBookScanCtrl.getLocation('HKO-PD');
        
        Library_Inventory__c bookinv = LibraryBookScanCtrl.getLibraryItemDetail('12345','123');
        
        library_Item__c bookItem = LibraryTestDataUtility.insertLibItem('Book');
        
        bookinv = [select id,Serial_Number__c, QR_Code_Number__c from library_Inventory__c];
        bookinv = LibraryBookScanCtrl.getLibraryItemDetail(bookinv.QR_Code_Number__c,'123');
        
        TalMobileNavigationRouting tnr = LibraryOneClickBorrowCtrl.oneClickBorrow(bookinv.id);
        
        Library_Item_Request__c lir = LibraryTestDataUtility.insertLibRequest(bookinv.id,Label.Library_Request_Status_Borrowed);
        
        lir.Overdue_Datetime__c =system.today()-5;
        update lir;
        lCtrl.isOverDue(UserInfo.getUserId());
        
        
    }
}