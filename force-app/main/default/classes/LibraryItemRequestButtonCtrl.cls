/*
	LibraryItemRequestButtonCtrl Class
	
	@Author: AN, WG, NW
	@Object: Library_Item_Request__c
	@Description: Used to handle all action of customized buttons in Library_Item_Request__c
*/
public without sharing class LibraryItemRequestButtonCtrl {

	public Library_Item_Request__c libItemReq {get;set;}
	
	public String strErrorMessage {get;set;}
	
	public Boolean isSalesforceOne {get;set;}{isSalesforceOne=SystemUtil.isMobileDevice();}
	
	String btnSuccessMessage = Label.Library_JavaScriptName+LibraryUtil.jsAlert(Label.Library_Success_Msg);
	String btnFailureMessage = Label.Library_JavaScriptName+LibraryUtil.jsAlert(Label.Library_perform_action);				
	
	public boolean isProfileCheck{get;set;}{
		isProfileCheck= false;
	}
	
	//Constructor, get the Library_Item_Request__c record by the recordId and assign the request id to libItemReq
	public LibraryItemRequestButtonCtrl(ApexPages.StandardController controller) {
		
		List<Library_Item_Request__c> libItemReqs = 
			[Select Id, Name, Status__c, Overdue__c, Overdue_Datetime__c, Library_Item__c, Item_Category__c,
					Library_Item__r.Require_Approval__c, OwnerId, Library_Item_Owner__c, Tech_Borrow_Duration__c, CreatedById, 
					Library_Request_Inventory__c
				From Library_Item_Request__c 
				Where Id =: ((Library_Item_Request__c) controller.getRecord()).Id];
		
		if(!libItemReqs.isEmpty()) {
			this.libItemReq = libItemReqs[0];
		}	
		strErrorMessage = '';
    }
	
	//Perform warehouse checkout action in request detail page
	public PageReference warehouseCheckOutAction() {
		String returnURL = '';
		Map<Id, String> mapProfile = new Map<Id, String>();
 		for(Profile p: [SELECT Name, Id FROM Profile]) {
			mapProfile.put(p.Id, P.Name);
		}
		
		//Check Profile
		if(mapProfile.containsKey(UserInfo.getProfileId())) {
			
			if( (mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEPA && mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBAA ) || 
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEPA && libItemReq.Item_Category__c == Label.Library_Item_category_Samples_PD) ||
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEFA && libItemReq.Item_Category__c == Label.Library_RecordType_Fabric) ||
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEBAA && libItemReq.Item_Category__c == Label.Library_Item_category_Burberry) ||
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEWA && libItemReq.Item_Category__c == Label.Library_Item_category_Warehouse) ||
				(libItemReq.Item_Category__c == Label.Library_RecordType_Book && (mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBAA ||
																				  mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBASU)
				)) {
				//Check Request Status
				if(libItemReq.Status__c == Label.Library_Request_Status_Reserved) {
					if(libItemReq.Item_Category__c == Label.Library_RecordType_Book) {
						libItemReq.Status__c = Label.Library_Request_Status_Borrowed;
					} else {
						libItemReq.Status__c = Label.Library_Request_Status_Outbound;
					}
					SystemUtil.SafeUpdate(libItemReq);		
					returnURL = btnSuccessMessage;					
				} else {
					returnURL = btnFailureMessage;
				}	
			} else {
				returnURL = btnFailureMessage;
			}
		} else {
			returnURL = btnFailureMessage;
		}
		returnURL += LibraryUtil.jsNavSObject(libItemReq.Id);
		/*
		if(isSalesforceOne) {
			returnURL += Label.Library_Mobile_NavigateObject + '(\'' + libItemReq.Id+'\');';
		} else {
			returnURL += Label.Library_window_location_href + '=\'/' + libItemReq.Id+'\'';
		}
		*/
		PageReference pr = new PageReference(returnURL);
		return pr;  
	}
	
	
	//Perform the warehouse checkin action in request detail page
	public PageReference warehouseCheckInAction() {
		String returnURL = '';
		Map<Id, String> mapProfile = new Map<Id, String>();
 		for(Profile p: [SELECT Name, Id FROM Profile]) {
			mapProfile.put(p.Id, P.Name);
		}
		
		//Check Profile
		if(mapProfile.containsKey(UserInfo.getProfileId())) {

			if( (mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEPA && mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBAA) || 
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEPA && libItemReq.Item_Category__c == Label.Library_Item_category_Samples_PD) ||
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEFA && libItemReq.Item_Category__c == Label.Library_RecordType_Fabric) ||
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEBAA && libItemReq.Item_Category__c == Label.Library_Item_category_Burberry) ||
				(libItemReq.Item_Category__c == Label.Library_RecordType_Book && (mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBAA ||
																				  mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBASU)
				)) {
				//Check Request Status
				if(libItemReq.Status__c == Label.Library_Request_Status_Inbound 
					|| (libItemReq.Status__c == Label.Library_Request_Status_Borrowed && libItemReq.Item_Category__c == Label.Library_RecordType_Book)
					|| (libItemReq.Status__c == Label.Library_Request_Status_Borrowed && libItemReq.Item_Category__c == Label.Library_Item_category_Burberry)) {
				
					libItemReq.Status__c = Label.Library_Request_Status_Returned;
					
					SystemUtil.SafeUpdate(libItemReq);
					
					/*
						Nick Wu
						Add change inventory status to Available if user cancel the process
						if request under pending approval or reserved status
					*/
					List<Library_Inventory__c> invList = [Select id, Lending_Status__c, Target_Address__c, Original_Address__c, Detail_Current_Location__c, Detail_Home_Location__c from Library_Inventory__c where ID =: libItemReq.Library_Request_Inventory__c];
					
					if(invList!=null && !invList.isEmpty()){

						invList[0].Lending_Status__c = Label.Library_Inventory_Lending_Status_available;
						invList[0].Detail_Current_Location__c = invList[0].Detail_Home_Location__c;
						invList[0].Target_Address__c = invList[0].Original_Address__c;
						SystemUtil.SafeUpdate(invList);
					}
					
					returnURL = btnSuccessMessage;
					
				} else {
					returnURL = btnFailureMessage;
				}	
			} else {
				returnURL = btnFailureMessage;
			}
		} else {
			returnURL = btnFailureMessage;
		}
		returnURL += LibraryUtil.jsNavSObject(libItemReq.Id);
		/*
		if(isSalesforceOne) {

			returnURL += Label.Library_Mobile_NavigateObject + '(\'' + libItemReq.Id+'\');';
		} else {
			returnURL += Label.Library_window_location_href + '=\'/' + libItemReq.Id+'\'';
		}
		*/
		PageReference pr = new PageReference(returnURL);
		return pr;  
	}
	
	//Perform the mailing room outbound checkin action in request detail page
	public PageReference mailRoomCheckInOutboundAction() {
		String returnURL = '';
		Map<Id, String> mapProfile = new Map<Id, String>();
 		for(Profile p: [SELECT Name, Id FROM Profile 
 						WHERE Name =: Label.Library_Profile_SA
 						OR Name =: Label.Library_Profile_TFEMRS
 						OR Name =: Label.Library_Profile_TFEPA
 						OR Name =: Label.Library_Profile_TFEBAA
 						OR Name=: Label.Library_Profile_TFEWA
 						OR Name=: Label.Library_Profile_TFEFA]) {
			mapProfile.put(p.Id, P.Name);
		}
		
		//Check Profile
		if(mapProfile.containsKey(UserInfo.getProfileId())) {

			if( (mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEPA && mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBAA) || 
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEPA && libItemReq.Item_Category__c == Label.Library_Item_category_Samples_PD) ||
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEBAA && libItemReq.Item_Category__c == Label.Library_Item_category_Burberry) ||
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEWA && libItemReq.Item_Category__c == Label.Library_Item_category_Warehouse)
				) {
				//Check Request Status

				if(libItemReq.Status__c == Label.Library_Request_Status_Outbound) {
					
					libItemReq.Status__c = Label.Library_Request_Status_Arrived;					

					SystemUtil.SafeUpdate(libItemReq);
					returnURL = btnSuccessMessage;
					
				} else {
					returnURL = btnFailureMessage;
				}	
			} else {
				returnURL = btnFailureMessage;
			}
		} else {
			returnURL = btnFailureMessage;
		}		
		returnURL += LibraryUtil.jsNavSObject(libItemReq.Id);
		/*
		if(isSalesforceOne) {

			returnURL += Label.Library_Mobile_NavigateObject + '(\'' + libItemReq.Id+'\');';
		} else {
			returnURL += Label.Library_window_location_href + '=\'/' + libItemReq.Id+'\'';
		}
		*/
		PageReference pr = new PageReference(returnURL);
		return pr;  
	}
	
	//check if it is validated mailing room inbound checkin
	public boolean isValidMailRoomCheckInInbound(Map<Id, String> mapProfile, Library_Item_Request__c libItemReq){
		Boolean b = false;
		if(mapProfile.containsKey(UserInfo.getProfileId())) {
			
			if( (mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEPA && mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBAA) || 
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEPA && libItemReq.Item_Category__c == Label.Library_Item_category_Samples_PD) ||
				(mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEBAA && libItemReq.Item_Category__c == Label.Library_Item_category_Burberry)) {
				//Check Request Status
				
				if(libItemReq.Status__c == Label.Library_Request_Status_Borrowed) {
					b = true;
				}
			}
		}
		return b;
	}
	
	//Perform the mailing room inbound checkin action in request detail page
	public PageReference mailRoomCheckInInboundAction() {
		String returnURL = '';
		Map<Id, String> mapProfile = new Map<Id, String>();
 		for(Profile p: [SELECT Name, Id FROM Profile 
 						WHERE Name =: Label.Library_Profile_SA
 						OR Name =: Label.Library_Profile_TFEMRS
 						OR Name =: Label.Library_Profile_TFEPA
 						OR Name =: Label.Library_Profile_TFEBAA
 						OR Name=: Label.Library_Profile_TFEWA
 						OR Name=: Label.Library_Profile_TFEFA]) {
			mapProfile.put(p.Id, P.Name);
		}
		
		//Check Profile
		if(isValidMailRoomCheckInInbound(mapProfile, libItemReq)){				
			libItemReq.Status__c = Label.Library_Request_Status_Inbound;				
			SystemUtil.SafeUpdate(libItemReq);
			returnURL = btnSuccessMessage;
		} else {
			returnURL = btnFailureMessage;
		}
		returnURL += LibraryUtil.jsNavSObject(libItemReq.Id);
		/*
		if(isSalesforceOne) {
			
			returnURL += Label.Library_Mobile_NavigateObject + '(\'' + libItemReq.Id+'\');';
		} else {
			returnURL += Label.Library_window_location_href + '=\'/' + libItemReq.Id+'\'';
		}
		*/
		PageReference pr = new PageReference(returnURL);
		return pr;  
	}
	
	//Check if valid to perform Receive
	public boolean isValidReceive(Map<Id, String> mapProfile, Library_Item_Request__c libItemReq){
		Boolean b = false;
		if(mapProfile.containsKey(UserInfo.getProfileId()) || libItemReq.OwnerId == UserInfo.getUserId()) {
				
			if(libItemReq.Status__c == Label.Library_Request_Status_Arrived 
				|| (libItemReq.Status__c == Label.Library_Request_Status_Reserved && libItemReq.Item_Category__c == Label.Library_RecordType_Book) 
				|| (libItemReq.Status__c == Label.Library_Request_Status_Outbound && libItemReq.Item_Category__c == Label.Library_Item_category_Burberry)) {
				b = true;
			}
		}
		return b;
	}
	
	//Perform Receive action
	public PageReference receiveAction() {
		String returnURL = '';
		Map<Id, String> mapProfile = new Map<Id, String>();
 		for(Profile p: [SELECT Name, Id FROM Profile 
 						WHERE Name =: Label.Library_Profile_SA]) {
			mapProfile.put(p.Id, P.Name);
		}
		
		if(isValidReceive(mapProfile, libItemReq)){
				libItemReq.Status__c = Label.Library_Request_Status_Borrowed;
				SystemUtil.SafeUpdate(libItemReq);
				returnURL = btnSuccessMessage;
		} else {
			returnURL = btnFailureMessage;
		}
		returnURL += LibraryUtil.jsNavSObject(libItemReq.Id);
		/*
		if(isSalesforceOne) {
			returnURL += Label.Library_Mobile_NavigateObject + '(\'' + libItemReq.Id+'\');';
		} else {
			returnURL += Label.Library_window_location_href + '=\'/' + libItemReq.Id+'\'';
		}
		*/
		PageReference pr = new PageReference(returnURL);
		return pr;  
	}
	
	
	/*
		added by nick wu
		
		Mailing Room Staff: "In-Transit ( O )", "Arrived", "Borrowed"
		Warehouse admin/ librarian = "Reserved", "In-Transit ( i )"
		Requester: borrowed
		Admin all
		
		Check valid to perform report lost action
		
	*/
	public boolean isValidReportLost(Map<Id,String> mapProfile, Library_Item_Request__c libItemReq){
		Boolean b = false;
		String profileName =  mapProfile.get(UserInfo.getProfileId());
		
		if(
			//mailing room staff
			(profileName == Label.Library_Profile_TFEMRS &&
		     (libItemReq.Status__c == Label.Library_Request_Status_Outbound ||
		     libItemReq.Status__c == Label.Library_Request_Status_Arrived ||
		     libItemReq.Status__c == Label.Library_Request_Status_Borrowed)
		    ) 
		    ||
		    //Wareohuse admin /librarian
		    ((profileName == Label.Library_Profile_TFEWA ||
		      profileName == Label.Library_Profile_TFEWL) &&
		      (libItemReq.Status__c == Label.Library_Request_Status_Reserved ||
		      libItemReq.Status__c == Label.Library_Request_Status_Inbound )
		    )
		    ||
		    //Requester
		    (libItemReq.OwnerId == UserInfo.getUserId() && 
		     libItemReq.Status__c == Label.Library_Request_Status_Borrowed)
			||
			//Admin can do all
			profileName == Label.Library_Profile_SA
		 ){
		    b= true;
		   }
		
		return b;
	}
	
	//Perform report lost action in library request detail page
	public PageReference reportLostAction() {
		String returnURL = '';
		Map<Id, String> mapProfile = new Map<Id, String>();
 		for(Profile p: [SELECT Name, Id FROM Profile 
 						WHERE Name =: Label.Library_Profile_SA						
 						OR Name =: Label.Library_Profile_TFEMRS
 						OR Name =: Label.Library_Profile_TFEWA
 						OR Name =: Label.Library_Profile_TFEWL]) {
			mapProfile.put(p.Id, P.Name);
		}
		
		//Check Profile
		if(isValidReportLost(mapProfile,libItemReq)){		
			libItemReq.Status__c = Label.Library_Request_Status_Lost;	
			SystemUtil.SafeUpdate(libItemReq);
			returnURL = btnSuccessMessage;				
		} else {
			returnURL = btnFailureMessage;
		}
		returnURL += LibraryUtil.jsNavSObject(libItemReq.Id);
		/*
		if(isSalesforceOne) {
			returnURL += Label.Library_Mobile_NavigateObject + '(\'' + libItemReq.Id+'\');';
		} else {
			returnURL += Label.Library_window_location_href + '=\'/' + libItemReq.Id+'\'';
		}
		*/
		PageReference pr = new PageReference(returnURL);
		return pr;  
	}
	
	//Perform cancel request action
	public PageReference cancelAction() {
		String returnURL = '';
		
		//Check if it is in pending approval process
		list<ProcessInstance> existingApprovals = [Select p.TargetObjectId, p.Status, p.Id From ProcessInstance p 
													WHERE TargetObjectId = :libItemReq.Id And Status =: Label.Library_Request_Approval_Pending];

		if(existingApprovals.size()>0) {
			returnURL = Label.Library_JavaScriptName+ Label.Library_Mobile_Alert +'(\''+Label.Library_recall_approvalprocess+'\');';
		} else {
			Map<Id, String> mapProfile = new Map<Id, String>();
	 		for(Profile p: [SELECT Name, Id FROM Profile 
	 						WHERE Name =: Label.Library_Profile_SA	]) {
				mapProfile.put(p.Id, P.Name);
			}
			//Check Profile
			if(mapProfile.containsKey(UserInfo.getProfileId()) || libItemReq.OwnerId == UserInfo.getUserId()) {
					
				if(libItemReq.Status__c == Label.Library_Request_Status_Waitlist || libItemReq.Status__c == Label.Library_Request_Status_PendingApproval || libItemReq.Status__c == Label.Library_Request_Status_Reserved) {
									
					libItemReq.Status__c = Label.Library_Request_Status_Cancelled;
					SystemUtil.SafeUpdate(libItemReq);
					/*
						Nick Wu
						Add change inventory status to Available if user cancel the process
						if request under pending approval or reserved status
					*/
					List<Library_Inventory__c> invList = [Select id, Lending_Status__c from Library_Inventory__c where ID =: libItemReq.Library_Request_Inventory__c];
					
					if(invList!=null && !invList.isEmpty()){
						invList[0].Lending_Status__c = Label.Library_Inventory_Lending_Status_available;
						SystemUtil.SafeUpdate(invList);
					}
					
					returnURL = btnSuccessMessage;
				} else {
					returnURL = btnFailureMessage;
				}					
			} else {
				returnURL = btnFailureMessage;
			}
		}
		returnURL += LibraryUtil.jsNavSObject(libItemReq.Id);
		/*
		if(isSalesforceOne) {
			returnURL += Label.Library_Mobile_NavigateObject + '(\'' + libItemReq.Id+'\');';
		} else {
			returnURL += Label.Library_window_location_href + '=\'/' + libItemReq.Id+'\'';
		}
		*/
		
		PageReference pr = new PageReference(returnURL);
		return pr;  
	}
	
	//Perform renew action
	public PageReference RenewButtonAction() {
		String returnURL = '';
		//Cannot Renew if overdue
		//N-days prior to the the due date if no other user has request/reserved an item
		//should not be able to submit if it has been rejected less than a week
		if(libItemReq.Status__c == Label.Library_Request_Status_Borrowed && libItemReq.CreatedById == UserInfo.getUserId()) {
			if(libItemReq.Overdue__c) {
				//Cannot Renew - Overdue
				returnURL = Label.Library_JavaScriptName+Label.Library_Mobile_Alert+'(\''+Label.Library_not_allowed_renew_overdue+'\');';
			} else if(libItemReq.Overdue_Datetime__c < datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(libItemReq.Item_Category__c).Renewal_Day__c)) /*Configurable days*/ ) {
				//Cannot Renew prior to the due date
				returnURL = Label.Library_JavaScriptName+Label.Library_Mobile_Alert+'(\''+Label.Library_not_allowed_renew_dueDate+'\');';
			} else {
				//Check if any user in waitlist
				List<Library_Item_Request__c> libItemReqsInWaitlist = 
					[Select Id, Name From Library_Item_Request__c 
						Where Library_Item__c = :libItemReq.Library_Item__c
						And Status__c =: Label.Library_Request_Status_Waitlist];
				if(!libItemReqsInWaitlist.isEmpty()) {
					//Cannot Renew if someone is in the waitlist
					//strErrorMessage = 'You are not allowed to renew becasue someone is in the waitlist!';
					returnURL = Label.Library_JavaScriptName+Label.Library_Mobile_Alert+'(\''+Label.Library_not_allowed_renew+'\');';
				} else {
					//No Renewal Approval Required for Books
					if(libItemReq.Item_Category__c != Label.Library_RecordType_Book) {
						//Check if approval process is required for the item or if the requester is also the item owner
	                    if(libItemReq.Library_Item__r.Require_Approval__c && libItemReq.OwnerId != libItemReq.Library_Item_Owner__c) { 
							//Check if there is rejected request within last 7 days
							List<Library_Item_Request__c> rejectedLibItemReqs = 
								[Select Id, Name, Library_Item__c
									From Library_Item_Request__c
									Where Library_Item__c = :libItemReq.Library_Item__c
									And CreatedById = :userInfo.getUserId()
									And Id IN (Select TargetObjectId 
												From ProcessInstance
												Where CreatedById = :userInfo.getUserId()
												And Status =: Label.Library_Request_Status_Rejected
												And CreatedDate > :datetime.now() - Integer.valueOf(Label.Library_Rejected_Request_Day) /*Configurable days*/)];				
							if(!rejectedLibItemReqs.isEmpty()) {
								//Cannot Renew if it has been rejected in last 7 days
								returnURL = Label.Library_JavaScriptName+Label.Library_Mobile_Alert+'(\' '+Label.Library_not_allowed_renew_rejected + Label.Library_Rejected_Request_Day + ' days!\');';
							} else {
								List<ProcessInstance> pendingApprovals = 
									[Select TargetObjectId, Id 
										From ProcessInstance
										Where CreatedById = :userInfo.getUserId()
										And TargetObjectId = :libItemReq.Id
										And Status =: Label.Library_Request_Approval_Pending];
								if(!pendingApprovals.isEmpty()) {
									
									returnURL = Label.Library_JavaScriptName+Label.Library_Mobile_Alert+'(\''+Label.Library_not_allowed_renew_approval+'\');';
								} else {
									//Update this flag to indicate it is a renewal request
									libItemReq.Tech_Renewal_request__c = true;
									SystemUtil.SafeUpdate(libItemReq);
									//Submit Renewal Request for Approval
									List<Library_Item_Request__c> libItemReqRenewalReqs = new List<Library_Item_Request__c>();
									libItemReqRenewalReqs.add(libItemReq);
									LibraryItemRequestTriggerHandler.submitLibItemReqApproval(libItemReqRenewalReqs, Label.Library_Request_Status_Borrowed,Label.Library_Request_Approval_Renewal);
								}							
							}
	                    } else {
	                    	//Add Duration to Overdue Date/Time
	                    	libItemReq.Overdue_Datetime__c = libItemReq.Overdue_Datetime__c.addDays(Integer.ValueOf(libItemReq.Tech_Borrow_Duration__c));
	                    	SystemUtil.SafeUpdate(libItemReq);
	                    	List<Library_Inventory__c> relatedInv = [Select Id, Name, Return_Date_Time__c From Library_Inventory__c Where Id =:libItemReq.Library_Request_Inventory__c];
	                    	if(!relatedInv.isEmpty()) {
	                    		relatedInv[0].Return_Date_Time__c = libItemReq.Overdue_Datetime__c;
	                    		SystemUtil.SafeUpdate(relatedInv);
	                    	}
	                    }
					} else {
						//Assume books will only be borrowed at the same site
						libItemReq.Overdue_Datetime__c = libItemReq.Overdue_Datetime__c.addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(libItemReq.Item_Category__c).Borrow_Duration_Days_Same_Site__c));
						SystemUtil.SafeUpdate(libItemReq);
						List<Library_Inventory__c> relatedInv = [Select Id, Name, Return_Date_Time__c From Library_Inventory__c Where Id =:libItemReq.Library_Request_Inventory__c];
                    	if(!relatedInv.isEmpty()) {
                    		relatedInv[0].Return_Date_Time__c = libItemReq.Overdue_Datetime__c;
                    		SystemUtil.SafeUpdate(relatedInv);
                    	}
					}							     
				}					
			}
		} else {
			returnURL = Label.Library_JavaScriptName+Label.Library_Mobile_Alert+'(\''+Label.Library_not_allowed_renew2+'\');';
		}
		
		if(returnURL == '') {			
			returnURL = Label.Library_JavaScriptName+Label.Library_Mobile_Alert+'(\''+Label.Library_Request_Submitted+'\');';
		}
		returnURL += LibraryUtil.jsNavSObject(libItemReq.Id);
		/*
		if(isSalesforceOne) {
			returnURL += Label.Library_Mobile_NavigateObject + '(\'' + libItemReq.Id+'\');';
		} else {
			returnURL += Label.Library_window_location_href + '=\'/' + libItemReq.Id+'\'';
		}
		*/
		PageReference pr = new PageReference(returnURL);
		return pr;  
	}
}