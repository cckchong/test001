/*
    LibraryMobileQrCodeComponentCtrl Class
    Used to redirects the user to the Library Item Detail page
*/
public with sharing class LibraryMobileQrCodeComponentCtrl {
	
	//Redirects the user to the Library Item Detail page
	@RemoteAction
    public static String bookBorrowAction(String inventoryId) {
        String s = '';
        String libItemId = inventoryId;
        
        //Changed logic, this action now just redirects the user to the Library Item Detail page
        List<Library_Inventory__c> theInventory = [
                                        SELECT Id, Library_Item_Master__c, Lending_Status__c 
                                        FROM Library_Inventory__c 
                                        WHERE Serial_Number__c LIKE :libItemId];
		if(theInventory != null && !theInventory.isEmpty()) {
			s = theInventory[0].Id;
			
			if(theInventory[0].Lending_Status__c != Label.Library_Inventory_Lending_Status_available) {
				throw new TalException(Label.Library_Book_Not_Available + ' (' + inventoryId + ')');	
			}
			
		} else {
			throw new TalException(Label.Library_Book_Not_Found + ' (' + inventoryId + ')');
		}
		
		return s;
    }
}