/**
 * LibraryQrCodeScanUtil
 * 
 * JavaScript Remoting functions to handle barcode scanning
 */
global with sharing class LibraryQrCodeScanUtil {
    
    //check the current user whether is burberry user
    public boolean isBurberryUser{get;set;}{
        isBurberryUser = false;
        String str = Label.Library_Check_BurberryUser;
        Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and name like :str limit 1]);
        if(pMap.size()>0){
        	isBurberryUser = true;
        }else{
        	isBurberryUser =false;
        }
    }
    
    //check the current user whether is book admin
    public boolean isBookAdmin{get;set;}{
        isBookAdmin = false;
        String str = Label.Library_Profile_TFEBA;
        Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and name like :str limit 1]);
        if(pMap.size()>0){
        	isBookAdmin = true;
        }else{
        	isBookAdmin =false;
        }
    }
    
    //return the number of overdue items
    public Integer libraryOverdueItemCount {get;set;}{
    	libraryOverdueItemCount=0;
    	libraryOverdueItemCount = LibraryUtil.libraryOverdueItemCount;
    }
    
    //return the warning message for overdue items
    public String libraryOverdueWarningMessage{get;set;}{
    	libraryOverdueWarningMessage='';
    	libraryOverdueWarningMessage = LibraryUtil.libraryOverdueWarningMessage;
    }
    
    //equal to burberry archive admin
    public boolean archiveCheckOutBtn{get;set;}{
    	archiveCheckOutBtn = LibraryUtil.archiveCheckOutBtn;
    }
    
    
    //not equal to Warehouse Librarian and Mail Room Staff
    public boolean confirmReceivedBtn{get;set;}{
    	confirmReceivedBtn= LibraryUtil.confirmReceivedBtn;
    }
    
    //not equal to Warehouse Librarian and Mail Room Staff
    public boolean borrowBtn{get;set;}{
    	borrowBtn= LibraryUtil.borrowBtn;
    }

    //Warehouse admin, warehouse librarian, fabric admin, fabric standard user, PD admin, burberry Admin &  book admin
    public boolean initialCheckInBtn{get;set;}{
    	initialCheckInBtn= LibraryUtil.initialCheckInBtn;
    }
    
    //Warehouse admin, Warehouse librarian, fabric admin, PD admin, 
    public boolean warehouseCheckOutBtn{get;set;}{
    	warehouseCheckOutBtn = LibraryUtil.warehouseCheckOutBtn;
    }
    
    //Warehouse Admin, Fabric Admin,PD Admin,Mail Room Staff
    public boolean MailingRoomCheckinOutBtn{get;set;}{
    	MailingRoomCheckinOutBtn = LibraryUtil.MailingRoomCheckinOutBtn;
    }
    
    //Warehouse Admin, PD Admin,Mail Room Staff
    public boolean MailingRoomCheckinInBtn{get;set;}{
    	MailingRoomCheckinInBtn = LibraryUtil.MailingRoomCheckinInBtn;
    }
    
    // warehouse admin, warehouse librarian, fabric admin, PD admin, burberry standard user, burberry admin, warehouse standard user, system admin
    public boolean returnBtn{get;set;}{
    	returnBtn = LibraryUtil.returnBtn;
    }
    
    //Perform book borrow action
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
    
    
    //Get library item object by barcode, and then return to the detail page
    @RemoteAction
    global static PageReference getLibraryItem(String barcodeNum) {
        PageReference pr = new PageReference('.');
        
        if(barcodeNum != null && barcodeNum != '') {
            List<Library_Inventory__c> libInvList =
                [
                    SELECT Id, Library_Item_Master__c
                    FROM Library_Inventory__c
                    WHERE Serial_Number__c LIKE : barcodeNum
                ];
            
            if(libInvList != null && !libInvList.isEmpty()) {
                pr = new PageReference('/' + libInvList[0].Id);
            }
        }
        return pr;
    }
    
    //get location object by scanning barcode, and then return the location object
    @RemoteAction
    global static Location__c getLocation(String barcodeNum) {

        if(barcodeNum != null && barcodeNum != '') {
            List<Location__c> locList =
                [
                    SELECT Id, Name, Site__c, Country__c, Parent_Location__c
                    FROM Location__c
                    WHERE /*Id_Lowercase__c*/ Name LIKE :barcodeNum //FIXME!!!!!!!!!!!!!!!!!!!!!
                ];
            
            if(locList != null && !locList.isEmpty()) {
                return locList[0];
            }
        }
        return null;
    }
    
    //get Employee object by scanning barcode
    @RemoteAction
    global static Employee__c authenticateExternalUser(String barcodeNum) {

        if(barcodeNum != null && barcodeNum != '') {
            List<Employee__c> empList =
                [
                    SELECT Id, Staff_Card_ID__c, Full_Name__c, User__c
                    FROM Employee__c
                    WHERE Staff_Card_ID__c LIKE :barcodeNum
                ];
            
            if(empList != null && !empList.isEmpty()) {
                return empList[0];
            }
        }
        
        return null;
    }
    
    //return the library item details by scanning barcode
    @RemoteAction
    global static Library_Inventory__c getLibraryItemDetail(String barcodeNum, String action) {
        if(action == '') {}
        if(barcodeNum != null && barcodeNum != '') {
        	
        	List<String> qrCodes = new List<String>();
            qrCodes.add(barcodeNum);
            List<Library_Inventory__c> libInvList = LibraryQrCodeScanUtil.getLibraryItemDetailList(qrCodes);
            
            if(libInvList != null && !libInvList.isEmpty()) {
                return libInvList[0];
            }
        }
        return null;
    }

    @RemoteAction
    global static List<Library_Inventory__c> getLibraryItemDetailList(List<String> qrCodeList) {
        if(qrCodeList != null && !qrCodeList.isEmpty()) {
        	
        	List<String> statusList = new List<String>();
			statusList.add(Label.Library_Request_Status_Reserved);
			statusList.add(Label.Library_Request_Status_Borrowed);
			statusList.add( Label.Library_Request_Status_Outbound);
			statusList.add( Label.Library_Request_Status_Inbound);
			statusList.add(Label.Library_Request_Status_Arrived);
        	
            List<Library_Inventory__c> libInvList =
                [
                    SELECT 	Id, Library_Item_Master__c, 
                    		QR_Code_Number__c, Library_Item_Master__r.Item_Name__c, 
                    		Library_Item_Master__r.Item_Description__c, Serial_Number__c, 
                    		Original_Address__r.Name, Lending_Status__c, Target_Address__r.Name,
							(
                                SELECT Id, Requester__c, Status__c, Target_Location__r.Name
                            	FROM Library_Item_Requests__r 
                            	WHERE Status__c IN: statusList 
                            )
                    FROM Library_Inventory__c
                    WHERE Serial_Number__c IN : qrCodeList
                    OR QR_Code_Number__c IN :qrCodeList
                ];
            
            if(libInvList != null && !libInvList.isEmpty()) {
                return libInvList;
            }
        }
        return null;
    }
    
    //get the library request details by scanning barcode
    @RemoteAction
    global static PageReference getRequestItem(String barcodeNum) {
        PageReference pr = LibraryQrCodeScanUtil.getLibraryItem(barcodeNum);
        if(barcodeNum != null && barcodeNum != '') {
            List<Library_Item_Request__c> libInvList =
                [
                    SELECT Id, Library_Request_Inventory__c
                    FROM Library_Item_Request__c
                    WHERE Library_Request_Inventory__r.Serial_Number__c LIKE : barcodeNum
                    AND Status__c =: Label.Library_Request_Status_Borrowed
                ];
            if(libInvList != null && !libInvList.isEmpty()) {
                pr = new PageReference('/' + libInvList[0].Id);
            } 
        }
        return pr;
    }
    
    //create request by inputting the library item ids
    @RemoteAction
    public static String borrowSelectedAction(String itemIds) {
        String s = '';
        String libItemId = itemIds;
        
        LibraryItemRequestViewCtrl cart = new LibraryItemRequestViewCtrl();
        Id libraryCart = cart.getLibraryCart();    
        
        //Check if the user has the permission to create a library request
        Schema.DescribeSObjectResult sobj = Library_Item_Request__c.sObjectType.getDescribe();   
        if(sobj.isCreateable()) {
	        if(libItemId != null && libraryCart != null) {
	            //Check if it was already added:
	            List<Library_Item_Request__c> existingLir = [SELECT Id FROM LIbrary_Item_Request__c WHERE Status__c =:Label.Library_Request_Status_Not_Submitted AND Library_Item__c = :libItemId AND Bulk_Request__c = :libraryCart];
	            if(existingLir == null || existingLir.isEmpty()) {
	                Library_Item_Request__c lir = new Library_Item_Request__c(Status__c =Label.Library_Request_Status_Not_Submitted, Library_Item__c = libItemId, Bulk_Request__c = libraryCart);
	                try {
	                    SystemUtil.SafeInsert(lir);
	                    s = libraryCart;
	                } catch(DmlException ex) {
                        throw ex;
	                }
	            } else {
	                throw new TalException(Label.Library_MSG_Aready_In_Cart);   
	            }
	        }
        } else {                
                throw new TalException(Label.Library_MSG_Cannot_Complete);
        }
        return s;
    }
    
    @RemoteAction
    public static List<LocationInventoryWrapper> processMemoryLocationBasedAction(List<String> qrcodeList) {
        List<LocationInventoryWrapper> locationInventoryList = new List<LocationInventoryWrapper>();
        
        return locationInventoryList;
    }
    
    @RemoteAction
    public static List<Library_Inventory__c> processMemoryAction(List<String> qrcodeList) {
        List<Library_Inventory__c> inventoryList = new List<Library_Inventory__c>();
        // First check if every QR code is 
        return inventoryList;
    }
    
    /**
     * @description used purely for processMemoryLocationBasedAction(*) and processMemoryAction(*)
     */
    private class LocationInventoryWrapper {
        public Location__c location {get;set;}
        public List<Library_Inventory__c> inventoryList {get;set;}
        
        public LocationInventoryWrapper() {
            
        }
    }
}