/*
	LibraryOneClickBorrowCtrl Class
	Used to perform change book request to borrowed status
*/
public with sharing class LibraryOneClickBorrowCtrl {
	
	public boolean isSalesforceOne{get;set;}{isSalesforceOne = SystemUtil.isMobileDevice();}
	
	public LibraryOneClickBorrowCtrl(ApexPages.StandardController sc) {
		
	}
	
	//check if is over due
	public boolean isOverDue(String UserId){
		Integer overDueNum = 0;
		overDueNum = [Select count() From Library_Item_Request__c Where 
		Status__c = :Label.Library_Request_Status_Borrowed And Overdue__c = true And OwnerId =:UserId];
		if(overDueNum>0){
			return  true;
		}else{
			return false;
		}
	}
	
	
	public String historyBack(){
		String returnURL=LibraryUtil.jsBack();
		return returnURL;
	}
	
	//Perform one click borrow action in inventory detail page
	@RemoteAction
	public static TalMobileNavigationRouting oneClickBorrow(String inventoryId) {
		
		TalMobileNavigationRouting route = new TalMobileNavigationRouting();
		
		List<Library_Inventory__c> libInv = 
			[
				SELECT Id, Lending_Status__c, Library_Item_Master__c, Original_Address__c, Item_Category__c
				FROM Library_Inventory__c 
				WHERE Id = :inventoryId
				AND Lending_Status__c =: Label.Library_Inventory_Lending_Status_available
			];
		
		if(libInv != null && !libInv.isEmpty()) {
			
			Library_Inventory__c inv = libInv[0];
			
			if(inv.Item_Category__c != Label.Library_RecordType_Book) {
				throw new TalException(Label.Library_Inventory_Not_Book);
			}
			
			Library_Item_Request__c lr = new Library_Item_Request__c(
					Library_Item__c = inv.Library_Item_Master__c,
					Library_Request_Inventory__c = inv.Id,
					Target_Location__c = inv.Original_Address__c,
					Status__c =Label.Library_Request_Status_Borrowed,
					Pick_Up_Date_Time__c = Datetime.now(),
					Check_Out_Date_Time__c = Datetime.now(),
                	Overdue_Datetime__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(Label.Library_RecordType_Book).Borrow_Duration_Days_Same_Site__c)),
                	Tech_Return_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(Label.Library_RecordType_Book).Return_Notification_Days__c)),
                	Tech_Overdue_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Label.Library_Overdue_Notification))
				);	
			
			upsert lr;
			
			inv.Target_Address__c= Label.Library_Default_Location_Book;
			inv.Original_Address__c =  Label.Library_Default_Location_Book;
			inv.Return_Date_Time__c = lr.Overdue_Datetime__c;
			inv.Lending_Status__c = Label.Library_Inventory_Lending_Status_unavailable;
			
			SystemUtil.SafeUpdate(inv);
			
			route.navResult = TalMobileNavigationRouting.NAV_RESULT.OBJECTID;
			route.navResultObjectId = lr.Id;
			
		} else {
			throw new TalException(Label.Library_Book_Not_Available + ' (' + inventoryId + ')');	
		}
		
		return route;
	}
}