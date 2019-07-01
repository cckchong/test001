/**
 * Test for LibraryQrCodeScanUtil
 */
@isTest
public class TestLibraryQrCodeScanUtil {

    
    static testMethod void unitTestScanBooks(){
    	
       LibraryQrCodeScanUtil lcsu = new LibraryQrCodeScanUtil();
       boolean isBurberryUser = lcsu.isBurberryUser;
       boolean isBookAdmin = lcsu.isBookAdmin;
       
       Integer libraryOverdueItemCount = lcsu.libraryOverdueItemCount;
       String libraryOverdueWarningMessage = lcsu.libraryOverdueWarningMessage;
       
       boolean archiveCheckOutBtn = lcsu.archiveCheckOutBtn;
       boolean confirmReceivedBtn =lcsu.confirmReceivedBtn;
       boolean borrowBtn = lcsu.borrowBtn;
       boolean initialCheckInBtn = lcsu.initialCheckInBtn;
       boolean warehouseCheckOutBtn = lcsu.warehouseCheckOutBtn;
       boolean MailingRoomCheckinOutBtn = lcsu.MailingRoomCheckinOutBtn;
       boolean MailingRoomCheckinInBtn = lcsu.MailingRoomCheckinInBtn;
       boolean returnBtn = lcsu.returnBtn;
    	
       Library_Item__c li = LibraryTestDataUtility.insertLibItem('Book');
       Library_Inventory__c inv = [select id, Serial_Number__c from Library_Inventory__c limit 1];
       
       String bookId = LibraryQrCodeScanUtil.bookBorrowAction(inv.Serial_Number__c);
       
       PageReference litem = LibraryQrCodeScanUtil.getLibraryItem(inv.Serial_Number__c);
       
       Location__c generalLocation = LibraryTestDataUtility.insertGenLocation('HKO');
       Location__c detailLocation = LibraryTestDataUtility.insertDetailLocation('3F', generalLocation.Id);//Label.Library_Default_Location_Book);
       
       Location__c loc = LibraryQrCodeScanUtil.getLocation(detailLocation.name);
       loc = LibraryQrCodeScanUtil.getLocation(null);
       
       Library_Inventory__c inv1 = LibraryQrCodeScanUtil.getLibraryItemDetail(null,'aaa');
       inv1 = LibraryQrCodeScanUtil.getLibraryItemDetail(inv.Serial_Number__c,'aaa');
       
       Library_Item_Request__c lir = LibraryTestDataUtility.insertLibRequest(inv1.id,Label.Library_Request_Status_Borrowed);
       
       PageReference RequestItem  = LibraryQrCodeScanUtil.getRequestItem(lir.Library_Request_Inventory__r.Serial_Number__c);
       String selectedBook = LibraryQrCodeScanUtil.borrowSelectedAction(li.id);
    
    }
    
}