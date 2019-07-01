/**
 * LibraryBookScanCtrl
 * 
 * JavaScript Remoting functions to handle Book Scan page
 */
global without sharing class LibraryBookScanCtrl {

	public LibraryBookScanCtrl(){}
	
	public boolean isSalesforceOne{get;set;}{isSalesforceOne = SystemUtil.isMobileDevice();}

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
    
    //return the library item details by scanning barcode
    @RemoteAction
    global static Library_Inventory__c getLibraryItemDetail(String barcodeNum, String action) {
        if(action == '') {}
        if(barcodeNum != null && barcodeNum != '') {
        	
        	List<String> statusList = new List<String>();
			statusList.add(Label.Library_Request_Status_Reserved);
			statusList.add(Label.Library_Request_Status_Borrowed);
			statusList.add( Label.Library_Request_Status_Outbound);
			statusList.add( Label.Library_Request_Status_Inbound);
			statusList.add(Label.Library_Request_Status_Arrived);
        	
        	//('Reserved', 'Borrowed', 'Outbound In-Transit', 'Inbound In-Transit', 'Arrived')
            List<Library_Inventory__c> libInvList =
                [
                    SELECT Id, Library_Item_Master__c, QR_Code_Number__c, Library_Item_Master__r.Item_Name__c, Library_Item_Master__r.Item_Description__c, Serial_Number__c, Original_Address__r.Name, Lending_Status__c, Target_Address__r.Name,
                                (SELECT Id, Requester__c, Status__c, Target_Location__r.Name
                             FROM Library_Item_Requests__r 
                             WHERE Status__c IN: statusList )
                    FROM Library_Inventory__c
                    WHERE Serial_Number__c LIKE : barcodeNum
                    OR QR_Code_Number__c LIKE :barcodeNum
                ];
            
            if(libInvList != null && !libInvList.isEmpty()) {            	
                return libInvList[0];
            }
        }
        return null;
    }
    
    //check if is over due
	public boolean isOverDue(String uid){
		Integer overDueNum = 0;
		overDueNum = [Select count() From Library_Item_Request__c Where 
		Status__c = :Label.Library_Request_Status_Borrowed And Overdue__c = true And OwnerId =:uid];
		if(overDueNum>0){
			return  true;
		}else{
			return false;
		}
	}
    
    /**
	 * @description Perform book scanning. Takes in a list of Library Inventory Ids from the HTTP Request
	 */
	global PageReference BookScanProcessing(){
		
		PageReference pr;
		String returnURL = '';
		String multiLibItemId = ApexPages.currentPage().getParameters().get(Label.Library_multiLibItemId);
		String userId = ApexPages.currentPage().getParameters().get(Label.Library_UserId);
		
		String[] inventoryIds = multiLibItemId.split(';');
		Boolean overDue = isOverDue(userId);
		List<User> usrs = [Select Id, Library_Is_Blacklisted__c From User Where Id = :userId limit 1];
		
		Schema.DescribeSObjectResult sobj = Library_Item_Request__c.sObjectType.getDescribe();
        
		//Check if the user has the permission to create a library request
		//if(sobj.isCreateable()) {
			
			
			//get all available status inventories in scanned items
			List <Library_Inventory__c> invList = [SELECT Id, name, Return_Date_Time__c,Lending_Status__c, Item_Category__c, Library_Item_Master__c, Library_Item_Master__r.ownerId, Original_Address__c FROM Library_Inventory__c WHERE 
												   Lending_Status__c =:Label.Library_Inventory_Lending_Status_available AND ID IN: inventoryIds];
			
			//stored these inventory into a map and using the library Item id as key for checking duplicated library inventories
			Map<Id, Library_Inventory__c>invMap = new Map<Id, Library_Inventory__c>();
			for(Library_Inventory__c li : invList){
				invMap.put(li.Library_Item_Master__c, li);
			}

			
			List<Library_Item_Request__c> availableList = [Select id, Item_Category__c, name, Library_Request_Inventory__c FROM Library_Item_Request__c Where Status__c = :Label.Library_Request_Status_Reserved AND
														   OwnerId =: UserId AND Library_Request_Inventory__c IN 
														   (SELECT Id FROM Library_Inventory__c WHERE Lending_Status__c =: Label.Library_Inventory_Lending_Status_unavailable AND ID IN: inventoryIds) ];
			
			//inventory associated with other users
			List<Library_Item_Request__c> notAvailableList = [Select id, Requester__c,Library_Request_Inventory__c FROM Library_Item_Request__c Where 
															  OwnerId !=: UserId AND Library_Request_Inventory__c IN 
															  (SELECT Id FROM Library_Inventory__c WHERE Lending_Status__c =: Label.Library_Inventory_Lending_Status_unavailable AND ID IN: inventoryIds) ];
			
			
			// get all owned requests which associated with Available inventories
			//List<Library_Item_Request__c> availableList = LibraryUtil.availableList(inventoryIds,UserId);
			// get all owned request which associated with NOT Available inventories
			//List<Library_Item_Request__c> notAvailableList = LibraryUtil.notAvailableList(inventoryIds,UserId);
			
			// handle the situation some items are brand new, some are reserved
			if(invList != null && !invList.isEmpty() && availableList != null && !availableList.isEmpty()){
				Integer totalsize = 0;
				totalsize = invList.size() + availableList.size();
				if(inventoryIds.size() == totalsize){
					
					/*********************************************************************
						First create item request for brand new items
					**********************************************************************/
					List<Library_Item_Request__c> lirList = new List<Library_Item_Request__c>();
				
					for(Library_Inventory__c inv : invList){
						
						//check if overDue
						if(overDue && UserId != inv.Library_Item_Master__r.ownerId){
							returnURL =Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_BlackList_Message);
							returnURL += historyBack();
							pr = new PageReference(returnURL);
							return pr;
						}
						
						//check if the item category equals to Book
						if(inv.Item_Category__c != Label.Library_RecordType_Book) {
							returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Inventory_Not_Book);
							returnURL += historyBack();
							pr = new PageReference(returnURL);
							return pr;
						}
						Library_Item_Request__c lr = new Library_Item_Request__c(
							OwnerId = UserId,
							Library_Item__c = inv.Library_Item_Master__c,
							Library_Request_Inventory__c = inv.Id,
							Target_Location__c = inv.Original_Address__c,
							Status__c = Label.Library_Request_Status_Borrowed,
							Pick_Up_Date_Time__c = Datetime.now(),
							Check_Out_Date_Time__c = Datetime.now(),
		                	Overdue_Datetime__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(Label.Library_RecordType_Book).Borrow_Duration_Days_Same_Site__c)),
		                	Tech_Return_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(Label.Library_RecordType_Book).Return_Notification_Days__c)),
		                	Tech_Overdue_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Label.Library_Overdue_Notification))
						);
						
						lirList.add(lr);
						
						inv.Return_Date_Time__c = lr.Overdue_Datetime__c;
						inv.Lending_Status__c = Label.Library_Inventory_Lending_Status_unavailable;
					}
					
					/*********************************************************************
						Secondly create item request for brand new items
					**********************************************************************/
					for(Library_Item_Request__c lir : availableList){
						
						if(lir.Item_Category__c != Label.Library_RecordType_Book) {
							returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Inventory_Not_Book);
							returnURL += historyBack();
							pr = new PageReference(returnURL);
							return pr;
						}
						
						lir.Status__c = Label.Library_Request_Status_Borrowed;
						lir.Pick_Up_Date_Time__c = Datetime.now();
						lir.Check_Out_Date_Time__c = Datetime.now();
	                	lir.Overdue_Datetime__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(Label.Library_RecordType_Book).Borrow_Duration_Days_Same_Site__c));
	                	lir.Tech_Return_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(Label.Library_RecordType_Book).Return_Notification_Days__c));
	                	lir.Tech_Overdue_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Label.Library_Overdue_Notification));
						lirList.add(lir);
					}
					
					try{
						upsert lirList;
						SystemUtil.SafeUpdate(invList);
						returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Success_Msg);
					}catch(Exception ex){
						returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_perform_action);
						returnURL += historyBack();
						pr = new PageReference(returnURL);
						return pr;
					}
					
					
				}
			}
			//if all book inventories are available for borrow
			else if(invList != null && !invList.isEmpty() && invList.size()== inventoryIds.size()){
				
				//check duplicated item
				if(invMap != null && !invMap.isEmpty() && invList.size()!=invMap.values().size()){
					returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_OneItemBorrowOnce);		
					returnURL += historyBack();
					pr = new PageReference(returnURL);
					return pr;
				}
				
				List<Library_Item_Request__c> lirList = new List<Library_Item_Request__c>();
				
				for(Library_Inventory__c inv : invList){
					
					//check for overdue item
					if(overDue && UserId != inv.Library_Item_Master__r.ownerId){
						returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_BlackList_Message);
						returnURL += historyBack();
						pr = new PageReference(returnURL);
						return pr;
					}
					
					//check item not in book type
					if(inv.Item_Category__c != Label.Library_RecordType_Book) {
						returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Inventory_Not_Book);
						returnURL += historyBack();
						pr = new PageReference(returnURL);
						return pr;
					}
					//create request for the book item
					Library_Item_Request__c lr = new Library_Item_Request__c(
						OwnerId = UserId,
						Library_Item__c = inv.Library_Item_Master__c,
						Library_Request_Inventory__c = inv.Id,
						Target_Location__c = inv.Original_Address__c,
						Status__c = Label.Library_Request_Status_Borrowed,
						Pick_Up_Date_Time__c = Datetime.now(),
						Check_Out_Date_Time__c = Datetime.now(),
	                	Overdue_Datetime__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(Label.Library_RecordType_Book).Borrow_Duration_Days_Same_Site__c)),
	                	Tech_Return_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(Label.Library_RecordType_Book).Return_Notification_Days__c)),
	                	Tech_Overdue_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Label.Library_Overdue_Notification))
					);
					
					lirList.add(lr);
					
					//update the return date time and lending status for associated inventories
					inv.Return_Date_Time__c = lr.Overdue_Datetime__c;
					inv.Lending_Status__c = Label.Library_Inventory_Lending_Status_unavailable;
				}
				
				try{
					upsert lirList;
					SystemUtil.SafeUpdate(invList);
					returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Success_Msg);
				}catch(Exception ex){
					returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_perform_action);
					returnURL += historyBack();
					pr = new PageReference(returnURL);
					return pr;
				}
				
			}
			//if available list equals to inventoryIds, that means all scanned inventories are available
			else if(availableList!=null && !availableList.isEmpty() && availableList.size() == inventoryIds.size()){
				
				/*
					1. Inventory is Not Available
					2. Library Request that is in the "Reserved"
					3. OwnerId is equal to the current User
				*/
				for(Library_Item_Request__c lir : availableList){
					
					if(lir.Item_Category__c != Label.Library_RecordType_Book) {
						returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Inventory_Not_Book);
						returnURL += historyBack();
						pr = new PageReference(returnURL);
						return pr;
					}
					
					lir.Status__c = Label.Library_Request_Status_Borrowed;
					lir.Pick_Up_Date_Time__c = Datetime.now();
					lir.Check_Out_Date_Time__c = Datetime.now();
                	lir.Overdue_Datetime__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues('Book').Borrow_Duration_Days_Same_Site__c));
                	lir.Tech_Return_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues('Book').Return_Notification_Days__c));
                	lir.Tech_Overdue_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Label.Library_Overdue_Notification));
				}
				try{
					upsert availableList;
					returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Success_Msg);
				}catch(Exception ex){
					returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_perform_action);
					returnURL += historyBack();
					pr = new PageReference(returnURL);
					return pr;
				}
			}
			//if the size of available list NOT equals to scanned inventories, that means some of scanned inventories NOT Available
			else if(availableList!=null && !availableList.isEmpty() && availableList.size() != inventoryIds.size()){
					
				String requestNames ='';
				for(Library_Item_Request__c lir : availableList){
					requestNames += lir.Library_Request_Inventory__c + ',';
				}
				requestNames = requestNames.removeEnd(',');
				returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Msg_invReserved + requestNames + ')'); 
				returnURL += historyBack();
				pr = new PageReference(returnURL);
				return pr;

			}
			//if Not available list has records, that means some of inventories reserved by other users
			else if(notAvailableList!=null && !notAvailableList.isEmpty()){
				//if inventory not available && it is not associated with to library request with current user
				
				String requestNames ='';
				for(Library_Item_Request__c lir : notAvailableList){
					requestNames += lir.Requester__c + ' Inventory ID: ' + lir.Library_Request_Inventory__c + ' ,';
				}
				requestNames = requestNames.removeEnd(',');
				returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Msg_invReservedByOthers + requestNames + ')');	
				returnURL += historyBack();
				pr = new PageReference(returnURL);
				return pr;
			}
			//Other unexpected cases
			else{
				returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_perform_action);
				returnURL += historyBack();		
				pr = new PageReference(returnURL);
				return pr;
			}
		//}
	    /*			
		else{
			returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_not_allowed_scanbook);
			returnURL += historyBack();
			pr = new PageReference(returnURL);
			return pr;
		}
		*/
		returnURL +=historyBack();
		pr = new PageReference(returnURL);
		return pr;
	}
	
	global String historyBack(){
		String returnURL=LibraryUtil.jsBack();
		return returnURL;
	}
	
	
	global PageReference bookReturn() {

        String action = ApexPages.currentPage().getParameters().get(Label.Library_actionType);
        String multiLibItemId = ApexPages.currentPage().getParameters().get(Label.Library_multiLibItemId);
        
        String locationId = ApexPages.currentPage().getParameters().get(Label.Library_locationId);
        
        String[] inventoryIds = multiLibItemId.split(';');
        String returnURL ='';
        boolean someRecordsNotProcessed = false;
        boolean isDetailLocation = false;
        
		List<Library_Item_Request__c> reqsTocheckout = new List<Library_Item_Request__c>(); 
		List<String> libInvIds = new List<String>();
		List<Library_Inventory__c> libInventory = new List<Library_Inventory__c>();
		 
		for(Library_Item_Request__c lir : [SELECT Id, Status__c, Library_Request_Inventory__c  FROM LIbrary_Item_Request__c 
										   WHERE Status__c =:Label.Library_Request_Status_Borrowed AND Item_Category__c = :Label.Library_RecordType_Book AND 
											Library_Request_Inventory__c IN: inventoryIds] ) {
			
			lir.Status__c = Label.Library_Request_Status_Returned;
			if(lir.Library_Request_Inventory__c != null) {
				libInvIds.add(lir.Library_Request_Inventory__c);
			}
			reqstoCheckout.add(lir);
		}
		
		// Get the Parent Location
		List<Location__c> theLocation = [
										SELECT id, name, Parent_Location__c, RecordType.Name FROM Location__c WHERE 
										RecordType.Name = :Label.Location_RecordType_DetailLocation and Id = :locationId
										];
		
		for(Library_Inventory__c li : [SELECT Id, Detail_Current_Location__c, Original_Address__c, Target_Address__c , Lending_Status__c, Item_Name__c, Name  FROM Library_Inventory__c WHERE ID IN: libInvIds]) {

			if(!ErrorUtils.isEmpty(theLocation)) {
				if(theLocation[0].RecordType.Name == Label.Location_RecordType_DetailLocation  && theLocation[0].Parent_Location__c == li.Original_Address__c ) {
					li.Detail_Current_Location__c = locationId; 
					//Update Home Location for first time check in
					if(li.Detail_Home_Location__c == null) {
						li.Detail_Home_Location__c = locationId;
					}
					li.Target_Address__c = theLocation[0].Parent_Location__c;
				}else{
					isDetailLocation = true;
					returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_LocationNotAligned);
					
					returnURL +=historyBack();
					return new PageReference(returnURL);
				}     
			}
			//Update Status                
			li.Lending_Status__c = Label.Library_Inventory_Lending_Status_available;
			libInventory.add(li);
		}
		
			SystemUtil.SafeUpdate(reqsToCheckout);
			SystemUtil.SafeUpdate(libInventory);
			
		
		if(reqsToCheckout.size() != inventoryIds.size()) {
			someRecordsNotProcessed = true;
		}
		
		if(someRecordsNotProcessed) {
			returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_errorInProcess)+ historyBack();
			return new PageReference(returnURL);
		} else {
			if(Site.getSiteId()!=null || Site.getSiteId()!=''){
				returnURL = Label.Library_JavaScriptName + LibraryUtil.jsNavURL('bookscan?redirect=true');
			}else{
				returnURL = Label.Library_JavaScriptName + LibraryUtil.jsNavURL('apex/LibraryBookScanPage?redirect=true');
			}
			
			
			return new PageReference(returnURL);
		}
	}

}