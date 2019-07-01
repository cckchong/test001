/*
    LibraryItemRequestTriggerHandler Class
    Used to handle create,update,insert or upsert actions of library request records
*/
public without sharing class LibraryItemRequestTriggerHandler {

    //////////////////////////////////////////////// Before Insert //////////////////////////////////////////////// 
    public static void isBeforeInsert(List<Library_Item_Request__c> libItemReqs) {
        List<Library_Item_Request__c> ReqsAddtoCart = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> ReqsToInsert = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> ReqsToPendingApproval = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> ReqsToReserved = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> ReqsExceptAddToCart = new List<Library_Item_Request__c>();
        
        Map<String, RecordType> mapRt = new Map<String,RecordType>();
        
        for(RecordType r:[SELECT DeveloperName, Id FROM RecordType WHERE SObjectType = 'Library_Item_Request__c']) {
            mapRt.put(r.DeveloperName, r);
        }
        
        for(Library_Item_Request__c lir : libItemReqs) {            
            //Check if the request is just added to cart but not submitted for apporval
            if(lir.Status__c == Label.Library_Request_Status_Not_Submitted) {                    
                if(mapRt.containsKey(Label.Library_Request_Locked)) {
                    lir.RecordTypeId = mapRt.get(Label.Library_Request_Locked).Id;
                }
                ReqsAddtoCart.add(lir);
            } else if (lir.Status__c ==Label.Library_Request_Status_PendingApproval) {
                if(mapRt.containsKey(Label.Library_Request_Initial)) {
                    lir.RecordTypeId = mapRt.get(Label.Library_Request_Initial).Id;
                }
                ReqsToPendingApproval.add(lir);
                ReqsExceptAddToCart.add(lir);
            } else if (lir.Status__c == Label.Library_Request_Status_Reserved) {
                if(lir.Item_Category__c ==Label.Library_RecordType_Book) {
                    if(mapRt.containsKey(Label.Library_Request_Book)) {
                        lir.RecordTypeId = mapRt.get(Label.Library_Request_Book).Id;
                    }
                } else if(lir.Item_Category__c == Label.Library_RecordType_Book) {
                    if(mapRt.containsKey(Label.Library_Request_Burberry_Archive)) {
                        lir.RecordTypeId = mapRt.get(Label.Library_Request_Burberry_Archive).Id;
                    }
                } else {
                    if(mapRt.containsKey(Label.Library_Request_Outbound)) {
                        lir.RecordTypeId = mapRt.get(Label.Library_Request_Outbound).Id;
                    }
                }
                ReqsToReserved.add(lir);
                ReqsExceptAddToCart.add(lir);
            } else {
                if(lir.Item_Category__c == Label.Library_RecordType_Book) {
                    if(mapRt.containsKey(Label.Library_Request_Book)) {
                        lir.RecordTypeId = mapRt.get(Label.Library_Request_Book).Id;
                    }
                }else if(mapRt.containsKey(Label.Library_Request_Locked)) {
                    lir.RecordTypeId = mapRt.get(Label.Library_Request_Locked).Id;
                }
                ReqsToInsert.add(lir);
                ReqsExceptAddToCart.add(lir);
            }
        }
        isBlacklistSubmitter(ReqsExceptAddToCart);
        ReqsToInsert.addAll(ReqsAddtoCart);
        if(!ReqsToInsert.isEmpty()) {
            queueForApproval(ReqsToInsert);
        }
        if(!ReqsToPendingApproval.isEmpty()) {
            submitLibItemReqApproval(ReqsToPendingApproval, Label.Library_Request_Status_PendingApproval,'');
        }
        if(!ReqsToReserved.isEmpty()) {
            updateStatusToReservedOrWaitlist(ReqsToReserved);
        }
    }
    
    //////////////////////////////////////////////// Before Update //////////////////////////////////////////////// 
    public static void isBeforeUpdate(List<Library_Item_Request__c> libItemReqs, Map<Id,Library_Item_Request__c> oldMapLibReqItems) {
        
        List<Library_Item_Request__c> ReservedToBorrowedReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> BorrowedToReturnedReqs = new List<Library_Item_Request__c>();     
        List<Library_Item_Request__c> NotSubmittedToPendingApprovalReqs = new List<Library_Item_Request__c>();          
        List<Library_Item_Request__c> NotSubmittedToReservedReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> PendingApprovalToReservedReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> ReservedToOutboundInTransitReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> OutboundInTransitToArrivedReqs = new List<Library_Item_Request__c>(); 
        List<Library_Item_Request__c> ArrivedToBorrowedReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> BorrowedReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> BorrowedToInboundInTransitReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> InboundInTransitToReturnedReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> CancelledReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> RejectedReqs = new List<Library_Item_Request__c>();
        List<Library_Item_Request__c> LostReqs = new List<Library_Item_Request__c>();
        
        Map<String, RecordType> mapRt = new Map<String,RecordType>();
        
        for(RecordType r:[SELECT DeveloperName, Id FROM RecordType WHERE SObjectType = 'Library_Item_Request__c']) {
            mapRt.put(r.DeveloperName, r);
        }
        
        for(Library_Item_Request__c libItemReq: libItemReqs) {
            
            //Process for Book Borrowing
            if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Reserved && libItemReq.Status__c == Label.Library_Request_Status_Borrowed) { //Books
                if(mapRt.containsKey(Label.Library_Request_Inbound) && libItemReq.Item_Category__c != Label.Library_RecordType_Book && libItemReq.Item_Category__c != Label.Library_Item_category_Burberry) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Inbound).Id;
                }
                ReservedToBorrowedReqs.add(libItemReq);
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c ==Label.Library_Request_Status_Borrowed && libItemReq.Status__c == Label.Library_Request_Status_Returned) { //Books
                if(libItemReq.Item_Category__c != Label.Library_Item_category_Burberry) {
                    if(mapRt.containsKey(Label.Library_Request_Locked)) {
                        libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Locked).Id;
                    }
                }
                BorrowedToReturnedReqs.add(libItemReq);
            }           
            //Standard Process
            else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Not_Submitted && libItemReq.Status__c == Label.Library_Request_Status_PendingApproval) {
                if(libItemReq.Item_Category__c == Label.Library_Item_category_Burberry) {
                    if(mapRt.containsKey(Label.Library_Request_Burberry_Archive)) {
                        libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Burberry_Archive).Id;
                    }
                } else if(mapRt.containsKey(Label.Library_Request_Initial)) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Initial).Id;
                }
                NotSubmittedToPendingApprovalReqs.add(libItemReq);                  
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Not_Submitted && libItemReq.Status__c == Label.Library_Request_Status_Reserved) { //Share with Book process
                if(libItemReq.Item_Category__c == Label.Library_RecordType_Book) {
                    if(mapRt.containsKey(Label.Library_Request_Book)) {
                        libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Book).Id;
                    }
                } else if(libItemReq.Item_Category__c == Label.Library_Item_category_Burberry) {
                    if(mapRt.containsKey(Label.Library_Request_Burberry_Archive)) {
                        libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Burberry_Archive).Id;
                    }
                } else {
                    if(mapRt.containsKey(Label.Library_Request_Outbound)) {
                        libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Outbound).Id;
                    }
                }
                NotSubmittedToReservedReqs.add(libItemReq);
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_PendingApproval && libItemReq.Status__c == Label.Library_Request_Status_Reserved) {
                if(mapRt.containsKey(Label.Library_Request_Outbound) && libItemReq.Item_Category__c != Label.Library_RecordType_Book && libItemReq.Item_Category__c != Label.Library_Item_category_Burberry) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Outbound).Id;
                }
                PendingApprovalToReservedReqs.add(libItemReq);
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Reserved && libItemReq.Status__c == Label.Library_Request_Status_Outbound) {
                ReservedToOutboundInTransitReqs.add(libItemReq);
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Outbound && libItemReq.Status__c == Label.Library_Request_Status_Arrived) {
                if(mapRt.containsKey(Label.Library_Request_Inbound) && libItemReq.Item_Category__c != Label.Library_RecordType_Book && libItemReq.Item_Category__c != Label.Library_Item_category_Burberry) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Inbound).Id;
                }               
                OutboundInTransitToArrivedReqs.add(libItemReq);
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Arrived && libItemReq.Status__c == Label.Library_Request_Status_Borrowed) {
                ArrivedToBorrowedReqs.add(libItemReq);
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Borrowed && libItemReq.Status__c == Label.Library_Request_Status_Borrowed && oldMapLibReqItems.get(libItemReq.Id).Tech_Renewal_request__c == true && libItemReq.Tech_Renewal_request__c == false) {
                BorrowedReqs.add(libItemReq);
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Borrowed && libItemReq.Status__c == Label.Library_Request_Status_Inbound) {
                BorrowedToInboundInTransitReqs.add(libItemReq);
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Inbound && libItemReq.Status__c == Label.Library_Request_Status_Returned) {
                if(mapRt.containsKey(Label.Library_Request_Locked)) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Locked).Id;
                }
                InboundInTransitToReturnedReqs.add(libItemReq);    
            } 
            /*else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_Reserved && libItemReq.Status__c == Label.Library_Request_Status_Cancelled) {
                if(mapRt.containsKey(Label.Library_Request_Locked)) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Locked).Id;
                }
                CancelledReqs.add(libItemReq);
            } else if(oldMapLibReqItems.get(libItemReq.Id).Status__c == Label.Library_Request_Status_PendingApproval && libItemReq.Status__c == Label.Library_Request_Status_Cancelled && libItemReq.Library_Request_Inventory__c != null ) {
                if(mapRt.containsKey(Label.Library_Request_Locked)) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Locked).Id;
                }
                CancelledReqs.add(libItemReq);
            } 
            */ 
              else if(libItemReq.Status__c == Label.Library_Request_Status_Cancelled && libItemReq.Library_Request_Inventory__c != null ) {
                if(mapRt.containsKey(Label.Library_Request_Locked)) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Locked).Id;
                }
                CancelledReqs.add(libItemReq);
            } else if(libItemReq.Status__c == Label.Library_Request_Status_Rejected) {
                if(mapRt.containsKey(Label.Library_Request_Locked)) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Locked).Id;
                }
                RejectedReqs.add(libItemReq);
            } else if(libItemReq.Status__c == 'Lost') {
                if(mapRt.containsKey(Label.Library_Request_Locked)) {
                    libItemReq.RecordTypeId = mapRt.get(Label.Library_Request_Locked).Id;
                }
                LostReqs.add(libItemReq);
            }
        }
        
        if(!ReservedToBorrowedReqs.isEmpty()) {
            updateStatusToBorrowed(ReservedToBorrowedReqs);
        }       
        if(!BorrowedToReturnedReqs.isEmpty()) {
            cancelOrReturnProcessFlow(BorrowedToReturnedReqs, oldMapLibReqItems);
        }       
        if(!NotSubmittedToPendingApprovalReqs.isEmpty()) {
            //check if the user is blacklisted upon submitting request
            isBlacklistSubmitter(NotSubmittedToPendingApprovalReqs);
            submitLibItemReqApproval(NotSubmittedToPendingApprovalReqs, Label.Library_Request_Status_PendingApproval,'');
        }
        if(!NotSubmittedToReservedReqs.isEmpty()) {
            isBlacklistSubmitter(NotSubmittedToReservedReqs);
            updateStatusToReservedOrWaitlist(NotSubmittedToReservedReqs);
        }       
        if(!PendingApprovalToReservedReqs.isEmpty()) {
            updateStatusToReservedOrWaitlist(PendingApprovalToReservedReqs);
        }
        if(!ReservedToOutboundInTransitReqs.isEmpty()) {
            updateStatusToOutboundInTransit(ReservedToOutboundInTransitReqs); //
        }
        if(!OutboundInTransitToArrivedReqs.isEmpty()) {
            updateStatusToArrived(OutboundInTransitToArrivedReqs);
        }       
        if(!ArrivedToBorrowedReqs.isEmpty()) {
            updateStatusToBorrowed(ArrivedToBorrowedReqs);
        }
        if(!BorrowedReqs.isEmpty()) {
            updateRelatedInvReturnDate(BorrowedReqs);
        }
        if(!BorrowedToInboundInTransitReqs.isEmpty()) {
            updateStatusToInboundInTransit(BorrowedToInboundInTransitReqs);
        }
        if(!InboundInTransitToReturnedReqs.isEmpty()) {
            cancelOrReturnProcessFlow(InboundInTransitToReturnedReqs, oldMapLibReqItems); //
        }
        if(!CancelledReqs.isEmpty()) {
            cancelOrReturnProcessFlow(CancelledReqs, oldMapLibReqItems);
        }
        if(!RejectedReqs.isEmpty()) {
            cancelOrReturnProcessFlow(RejectedReqs, oldMapLibReqItems);
        }
        if(!LostReqs.isEmpty()) {
            updateStatusToLost(LostReqs);
        }
    }
    
    //////////////////////////////////////////////// After Insert ////////////////////////////////////////////////
    public static void isAfterInsert(List<Library_Item_Request__c> libItemReqs) {               
        //Sharing Rules - Share Request to Item Owners
        SharingManagementUtil.createSharingRulesForLibraryRequest(libItemReqs);
    }
    //////////////////////////////////////////////// After Update //////////////////////////////////////////////// 
    public static void isAfterUpdate(List<Library_Item_Request__c> libItemReqs) {
        //Sharing Rules - Share Request to Item Owners
        //SharingManagementUtil.createSharingRulesForLibraryRequest(libItemReqs);
        
        //added by nick wu for update inventory status to available when rejected request
        updateInventoryStatus(libItemReqs);
    }
    
    //update the inventory status to available if request had been rejected
    public static void updateInventoryStatus(List<Library_Item_Request__c> libItemReqs){
        
        List<Library_Item_Request__c> rejectedRequestList = new List<Library_Item_Request__c>();
        List<String> rejectedIvenIds = new List<String>();
        for(Library_Item_Request__c lir : libItemReqs){
            //request is rejected
            if(lir.status__c == Label.Library_Request_Status_Rejected){
                rejectedRequestList.add(lir);
                rejectedIvenIds.add(lir.Library_Request_Inventory__c);
            }
        }
        
        //lending status = not available, and ids in request
        List<Library_Inventory__c> invList = [select id, Lending_Status__c from Library_Inventory__c where 
                                                Lending_Status__c =: Label.Library_Inventory_Lending_Status_unavailable AND
                                                id IN: rejectedIvenIds];
                                                
        List<Library_Inventory__c> updateList = new List<Library_Inventory__c>();
        
        if(invList!=null && !invList.isEmpty()){
            for(Library_Inventory__c li : invList){
                li.lending_status__c = Label.Library_Inventory_Lending_Status_available;
                updateList.add(li);
            }
        }
        SystemUtil.SafeUpdate(updateList);
        
    }
    
    //update is blacklisted user to false if they submitted items
    public static void updateBlacklistUsers(List<Library_Item_Request__c> libItemReqs) {
        Set<Id> submitterIds = new Set<Id>();
        Set<Id> blacklistUserIds = new Set<Id>();
        List<User> UsersToUpdate = new List<User>();
        for(Library_Item_Request__c lir: libItemReqs) {
            submitterIds.add(lir.OwnerId);
        }
        for(Library_Item_Request__c lir: [Select Id, OwnerId From Library_Item_Request__c 
                                            Where Status__c =: Label.Library_Request_Status_Borrowed 
                                            And Overdue__c = true
                                            And OwnerId IN :submitterIds]) {
            blacklistUserIds.add(lir.OwnerId);
        }
        for(User usr: [Select Id, Name, Library_Is_Blacklisted__c From User Where Id IN :SubmitterIds]) {
            if(blacklistUserIds.contains(usr.Id) && usr.Library_Is_Blacklisted__c == false) {
                usr.Library_Is_Blacklisted__c = true;
                UsersToUpdate.add(usr);
            }
            else if(!blacklistUserIds.contains(usr.Id) && usr.Library_Is_Blacklisted__c == true) {
                usr.Library_Is_Blacklisted__c = false;
                UsersToUpdate.add(usr);
            }
        }
        SystemUtil.SafeUpdate(UsersToUpdate);
    }
    
    /*
        Nick Wu
        Blacklist logic
        1. user is no in blacklist
        2. if user is in blacklist, item owner must same as current user
    */
    public static void isBlacklistSubmitter(List<Library_Item_Request__c> libItemReqs) {
        Set<Id> SubmitterIds = new Set<Id>();       
        
        
        for(Library_Item_Request__c lir : libItemReqs) {
            SubmitterIds.add(lir.OwnerId);
        }
        Map<Id,User> userMaps = new Map<Id,User>([Select Id, Library_Is_Blacklisted__c From User Where Id IN : SubmitterIds And Library_Is_Blacklisted__c = true]);
        
        
        for(Library_Item_Request__c lir : libItemReqs) {            
            // if blacklist true && item owner != current user
            if(userMaps.containsKey(lir.OwnerId) 
               && String.valueOf(userMaps.get(lir.OwnerId).id).left(15) != lir.Library_Item_Owner__c ){
                lir.addError(Label.Library_BlackList_Message);
             }
        }
    }
    
    //Used In Before Insert Only
    public static void queueForApproval(List<Library_Item_Request__c> libItemReqs) {
        List<Id> libItemIds = new List<Id>();
        for(Library_Item_Request__c lir : libItemReqs) {
            libItemIds.add(lir.Library_Item__c);
        }
        Map<ID, Library_Item__c> libItemMap = new Map<ID, Library_Item__c>(
                    [SELECT Id, OwnerId, Owner_2__c, Owner_3__c, Owner_4__c, Require_Approval__c FROM Library_Item__c WHERE Id IN: libItemIds]);
        
        List<Library_Item_Request__c> libItemReqsToReserved = new List<Library_Item_Request__c>();
        for(Library_Item_Request__c lir : libItemReqs) {            
            if(lir.Status__c != Label.Library_Request_Status_Not_Submitted) {
                if(libItemMap.containsKey(lir.Library_Item__c)) {
                    if(libItemMap.get(lir.Library_Item__c).Require_Approval__c) {
                        lir.Status__c = Label.Library_Request_Status_PendingApproval;
                    }
                } else {
                    lir.Status__c = Label.Library_Request_Status_Reserved;
                    libItemReqsToReserved.add(lir);
                }
            }  
            if(libItemMap.containsKey(lir.Library_Item__c)) {
                lir.Owner_1__c = libItemMap.get(lir.Library_Item__c).OwnerId;
                
                if(libItemMap.get(lir.Library_Item__c).Owner_2__c != null && libItemMap.get(lir.Library_Item__c).Require_Approval__c) {
                    lir.Owner_2__c = libItemMap.get(lir.Library_Item__c).Owner_2__c;
                } else {
                    lir.Owner_2__c = libItemMap.get(lir.Library_Item__c).OwnerId;
                }
                
                if(libItemMap.get(lir.Library_Item__c).Owner_3__c != null && libItemMap.get(lir.Library_Item__c).Require_Approval__c) {
                    lir.Owner_3__c = libItemMap.get(lir.Library_Item__c).Owner_3__c;
                } else {
                    lir.Owner_3__c = libItemMap.get(lir.Library_Item__c).OwnerId;
                }
                
                if(libItemMap.get(lir.Library_Item__c).Owner_4__c != null && libItemMap.get(lir.Library_Item__c).Require_Approval__c) {
                    lir.Owner_4__c = libItemMap.get(lir.Library_Item__c).Owner_4__c;
                } else {
                    lir.Owner_4__c = libItemMap.get(lir.Library_Item__c).OwnerId;
                }
            }
        }
    }
    
    //Find all available library inventory of the items
    public static Map<Id, List<Id>> getLibraryMasterToInvMap (Set<Id> libItemIds) {
        
        Map<Id, List<Id>> returnMap = new Map<Id, List<Id>>();
        for(Library_Inventory__c libInv : [Select Id, Name, Library_Item_Master__c
                                            From Library_Inventory__c
                                            Where Library_Item_Master__c In :libItemIds
                                            And Lending_Status__c =:Label.Library_Inventory_Lending_Status_available
                                            And Disposed__c = false]) {
            if(returnMap.containsKey(libInv.Library_Item_Master__c)) {              
                returnMap.get(libInv.Library_Item_Master__c).add(libInv.Id);
            } else {
                List<Id> ids = new List<Id>();
                ids.add(libInv.Id);
                returnMap.put(libInv.Library_Item_Master__c, ids);
            }
        }
        return returnMap;
    }
    
    //update library item request status to reserved or waitlist by input library request list
    public static void updateStatusToReservedOrWaitlist(List<Library_Item_Request__c> libItemReqs) {
        linkInventoryToRequest(libItemReqs, Label.Library_Request_Status_Reserved);
    }
    
    //associated the inventory with the library request by inputting list of library request and status
    public static void linkInventoryToRequest(List<Library_Item_Request__c> libItemReqs, String reqStatus) {
        Set<Id> setIds = new Set<Id>();
        Map<Id, List<Id>> LibMasterToInvMap = new Map<Id, List<Id>>();
        List<Library_Inventory__c> libInvsToUpdate = new List<Library_Inventory__c>();
        
        for(Library_Item_Request__c libItemReq: libItemReqs) {
            setIds.add(libItemReq.Library_Item__c);         
        }
        if(!setIds.isEmpty()) {
            LibMasterToInvMap = getLibraryMasterToInvMap(setIds);
        }
        for(Library_Item_Request__c libItemReq: libItemReqs) {
            if(libItemReq.Library_Request_Inventory__c == null) {
                //Available Item Inventory found
                if(LibMasterToInvMap.containsKey(libItemReq.Library_Item__c)) {
                    //Link the Item Inventory to Request
                    if(LibMasterToInvMap.get(libItemReq.Library_Item__c).size()>0) {
                        libItemReq.Library_Request_Inventory__c = LibMasterToInvMap.get(libItemReq.Library_Item__c)[0];
                        //Update Corresponding Library Inventory
                        Library_Inventory__c libInv = new Library_Inventory__c(Id=LibMasterToInvMap.get(libItemReq.Library_Item__c)[0], Lending_Status__c=Label.Library_Inventory_Lending_Status_unavailable);
                        libInvsToUpdate.add(libInv);
                        
                        LibMasterToInvMap.get(libItemReq.Library_Item__c).remove(0);
                        
                        if(reqStatus == Label.Library_Request_Status_Reserved) {
                            //Update the reserved date time (Waitlist > Reserved)
                            libItemReq.Reserved_Date_Time__c = Datetime.now();
                        }
                    } else {
                        if(reqStatus == Label.Library_Request_Status_Reserved) {
                            libItemReq.Status__c = Label.Library_Request_Status_Waitlist;
                        }
                    }           
                }
                //No Available Library Inventory and update Status to Label.Library_Request_Status_Waitlist
                else {
                    if(reqStatus == Label.Library_Request_Status_Reserved) {
                        libItemReq.Status__c = Label.Library_Request_Status_Waitlist;
                    }
                }   
            }
            else {
                //Update the reserved date time after request is approved
                if(libItemReq.Reserved_Date_Time__c == null) {
                    libItemReq.Reserved_Date_Time__c = Datetime.now();
                }
            }       
        }
        if(!libInvsToUpdate.isEmpty()) {
            SystemUtil.SafeUpdate(libInvsToUpdate);
        }   
    }   
    
    //update the library request to outbound in transit status
    public static void updateStatusToOutboundInTransit(List<Library_Item_Request__c> libItemReqs) {
        Set<Id> libInvIds = new Set<Id>();
        Map<Id, Library_Inventory__c> libReqtoInvMap= new Map<Id, Library_Inventory__c>();
        List<Library_Inventory__c> invsToUpdate = new List<Library_Inventory__c>();
        for(Library_Item_Request__c libItemReq: libItemReqs) {
            integer iDurationDays = 0;
            //Compare Location
            if(libItemReq.Request_Target_Home_Location_Site__c == libItemReq.Inventory_Home_Location_Site__c) { //Same Site
                iDurationDays = Integer.ValueOf(Library_Category_Settings__c.getValues(libItemReq.Item_Category__c).Borrow_Duration_Days_Same_Site__c);
            } else if(libItemReq.Request_Target_Home_Location_Country__c == libItemReq.Inventory_Home_Location_Country__c) { //Different Site, Same Country
                iDurationDays = Integer.ValueOf(Library_Category_Settings__c.getValues(libItemReq.Item_Category__c).Borrow_Duration_Days_Same_Country__c);
            } else { //Different Site, Different Country
                iDurationDays = Integer.ValueOf(Library_Category_Settings__c.getValues(libItemReq.Item_Category__c).Borrow_Duration_Days_Different_Country__c);
            }
            libItemReq.Overdue_Datetime__c = Datetime.now().addDays(iDurationDays); /*Configurable days*/
            libItemReq.Tech_Borrow_Duration__c = iDurationDays;
            libItemReq.Outbound_In_Transit_Date_Time__c = Datetime.now();
            libItemReq.Tech_Return_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(libItemReq.Item_Category__c).Return_Notification_Days__c)); /*Configurable days*/
            libItemReq.Tech_Overdue_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Label.Library_Overdue_Notification)); /*Configurable days*/
            
            //
            libInvIds.add(libItemReq.Library_Request_Inventory__c);
        }
        
        //Update Current Detail Location of Inventory to NULL 
        //Update Return Date/Time of the Inventory
        for(Library_Inventory__c r: [Select Id, Name, Target_Address__c, Detail_Current_Location__c, Return_Date_Time__c From Library_Inventory__c Where Id IN :libInvIds]) {
            libReqtoInvMap.put(r.Id, r);
        }
        for(Library_Item_Request__c libItemReq: libItemReqs) {  
            if(libReqtoInvMap.containsKey(libItemReq.Library_Request_Inventory__c)) {
                libReqtoInvMap.get(libItemReq.Library_Request_Inventory__c).Detail_Current_Location__c = null;
                libReqtoInvMap.get(libItemReq.Library_Request_Inventory__c).Return_Date_Time__c = libItemReq.Overdue_Datetime__c;
                invsToUpdate.add(libReqtoInvMap.get(libItemReq.Library_Request_Inventory__c));
            }
        }       
        if(!invsToUpdate.isEmpty()) {
            SystemUtil.SafeUpdate(invsToUpdate);
        }
    }    
    
    //update the library request to arrived status
    public static void updateStatusToArrived(List<Library_Item_Request__c> libItemReqs) {
        Set<Id> libInvIds = new Set<Id>();
        Map<Id, Library_Inventory__c> libReqtoInvMap= new Map<Id, Library_Inventory__c>();
        List<Library_Inventory__c> invsToUpdate = new List<Library_Inventory__c>();
        for(Library_Item_Request__c libItemReq: libItemReqs) {  
            libInvIds.add(libItemReq.Library_Request_Inventory__c);
        }
        for(Library_Inventory__c r: [Select Id, Name, Target_Address__c From Library_Inventory__c Where Id IN :libInvIds]) {
            libReqtoInvMap.put(r.Id, r);
        }
        for(Library_Item_Request__c libItemReq: libItemReqs) {  
            libItemReq.Mailing_Room_Arrival_Date_Time__c = Datetime.now();
            if(libReqtoInvMap.containsKey(libItemReq.Library_Request_Inventory__c)) {
                libReqtoInvMap.get(libItemReq.Library_Request_Inventory__c).Target_Address__c = libItemReq.Target_Location__c;
                invsToUpdate.add(libReqtoInvMap.get(libItemReq.Library_Request_Inventory__c));
            }
            ChatterUtil.simpleTextPostWithMention(libItemReq.Id, libItemReq.OwnerId,'You may pick up your requested item (' +libItemReq.Item_Name__c +') ');
        }       
        if(!invsToUpdate.isEmpty()) {
            SystemUtil.SafeUpdate( invsToUpdate);
        }
    }
    
    //update the inventory return date by inputting list of library requests
    public static void updateRelatedInvReturnDate(List<Library_Item_Request__c> libItemReqs) {      
        Set<Id> libInvIds = new Set<Id>();
        Map<Id, Library_Inventory__c> libReqtoInvMap= new Map<Id, Library_Inventory__c>();
        List<Library_Inventory__c> invsToUpdate = new List<Library_Inventory__c>();
        
        for(Library_Item_Request__c libItemReq: libItemReqs) {
            libInvIds.add(libItemReq.Library_Request_Inventory__c);
        }
        if(!libInvIds.isEmpty()) {
            //Update Return Date/Time of the Inventory
            for(Library_Inventory__c r: [Select Id, Name, Return_Date_Time__c From Library_Inventory__c Where Id IN :libInvIds]) {
                libReqtoInvMap.put(r.Id, r);
            }
            for(Library_Item_Request__c libItemReq: libItemReqs) {  
                if(libReqtoInvMap.containsKey(libItemReq.Library_Request_Inventory__c)) {
                    libReqtoInvMap.get(libItemReq.Library_Request_Inventory__c).Return_Date_Time__c = libItemReq.Overdue_Datetime__c; /*Configurable days*/
                    invsToUpdate.add(libReqtoInvMap.get(libItemReq.Library_Request_Inventory__c));
                }               
            }       
            if(!invsToUpdate.isEmpty()) {
                SystemUtil.SafeUpdate( invsToUpdate);
            }
        }
    }
    
    //update library request to borrowed status
    public static void updateStatusToBorrowed(List<Library_Item_Request__c> libItemReqs) {      
        Set<Id> libInvIds = new Set<Id>();
        Map<Id, Library_Inventory__c> libReqtoInvMap= new Map<Id, Library_Inventory__c>();
        List<Library_Inventory__c> invsToUpdate = new List<Library_Inventory__c>();
        for(Library_Item_Request__c libItemReq: libItemReqs) {  
            libItemReq.Pick_Up_Date_Time__c = Datetime.now();
            if(libItemReq.Item_Category__c == Label.Library_RecordType_Book) {
                libItemReq.Check_Out_Date_Time__c = Datetime.now();
                libItemReq.Overdue_Datetime__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(libItemReq.Item_Category__c).Borrow_Duration_Days_Same_Site__c)); /*Configurable days*/
                libItemReq.Tech_Return_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Library_Category_Settings__c.getValues(libItemReq.Item_Category__c).Return_Notification_Days__c)); /*Configurable days*/
                libItemReq.Tech_Overdue_Email_Notification_WF_DT__c = Datetime.now().addDays(Integer.ValueOf(Label.Library_Overdue_Notification)); /*Configurable days*/
                //
                libInvIds.add(libItemReq.Library_Request_Inventory__c);
            }
        }
        
        //If Item Category of the Inventory is Book
        if(!libInvIds.isEmpty()) {
            //Update Return Date/Time of the Inventory
            for(Library_Inventory__c r: [Select Id, Name, Return_Date_Time__c From Library_Inventory__c Where Id IN :libInvIds]) {
                libReqtoInvMap.put(r.Id, r);
            }
  
            for(Library_Item_Request__c libItemReq: libItemReqs) {
                if(libItemReq.Item_Category__c == Label.Library_RecordType_Book) {
                    if(libReqtoInvMap.containsKey(libItemReq.Library_Request_Inventory__c)) {
                        libReqtoInvMap.get(libItemReq.Library_Request_Inventory__c).Return_Date_Time__c = libItemReq.Overdue_Datetime__c; /*Configurable days*/
                        invsToUpdate.add(libReqtoInvMap.get(libItemReq.Library_Request_Inventory__c));
                    }
                }
            }
            if(!invsToUpdate.isEmpty()) {
                SystemUtil.SafeUpdate(invsToUpdate);
            }
        }
    }
    
    //update the library request to inbound in transit status
    public static void updateStatusToInboundInTransit(List<Library_Item_Request__c> libItemReqs) {
        for(Library_Item_Request__c libItemReq: libItemReqs) {  
            libItemReq.Inbound_In_Transit_Date_Time__c = Datetime.now();
        }
    }  
    
    //update the library request to returned status
    public static void updateStatusToReturned(List<Library_Item_Request__c> libItemReqs) {
        //for(Library_Item_Request__c libItemReq: libItemReqs) {          
        //}
    }
    
    //update hte library request to lost status
    public static void updateStatusToLost(List<Library_Item_Request__c> libItemReqs) {
        //Update related item inventory to Not Available and mark disposal
        List<Library_Inventory__c> LibItemInvsToUpdate = new List<Library_Inventory__c>();
        Map<Id, Library_Item_Request__c> libInvIdToReqIdMap = new Map<Id, Library_Item_Request__c>();
        for(Library_Item_Request__c libItemReq: libItemReqs) {
            libInvIdToReqIdMap.put(libItemReq.Library_Request_Inventory__c, libItemReq);  
            //Post to Chatter of the Request record 
            ChatterUtil.simpleTextPostWithMention(libItemReq.Id, libItemReq.Library_Item_Owner__c,'This item (' + libItemReq.Item_Name__c +') was lost!' );
            //Notify requester as well if the lost is not reported by requester
            if(libItemReq.OwnerId != UserInfo.getUserId()) {
                ChatterUtil.simpleTextPostWithMention(libItemReq.Id, libItemReq.OwnerId,'This item (' + libItemReq.Item_Name__c +') was lost during in-transit process!' );
            }
        }
        /*
        for(Library_Inventory__c inv: [Select Id, Name, Lending_Status__c, Disposal_Date__c, Disposed__c, Reason_for_Disposal__c 
                                        From Library_Inventory__c Where Id IN :libInvIdToReqIdMap.KeySet()]) {
            inv.Lending_Status__c = 'Available';
            inv.Disposal_Date__c = Date.today();
            inv.Disposed__c = true;
            inv.Reason_for_Disposal__c = 'Item Lost: ' + libInvIdToReqIdMap.get(inv.Id).Name ;
            LibItemInvsToUpdate.add(inv);           
        }
        if(!LibItemInvsToUpdate.isEmpty()) {
            update LibItemInvsToUpdate;
        }
        */
    }
    
    
    //check the requested item whether had been rejected within 7 days 
    public static void submitLibItemReqApproval(List<Library_Item_Request__c> LibItemList, String LibItemReqStatus, String ApprovalComments) {
        
        //Check if any items are rejected in the last 7 days        
        Map<Id, Library_Item_Request__c> rejectedMap = rejectedRequestMap(LibItemList);

        List<Approval.ProcessSubmitRequest> itemsToProcess = new List<Approval.ProcessSubmitRequest>();
        
        for(Library_Item_Request__c lir : LibItemList) {
            //Check if any rejected in the last 7 days for the item
            if(!rejectedMap.containsKey(lir.Library_Item__c)) {
                if(lir.Status__c == LibItemReqStatus) {
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(lir.id);
                    req1.setComments(ApprovalComments);
                    itemsToProcess.add(req1);
                }
            } else {
                lir.Status__c = Label.Library_Request_Status_Rejected;
            }
        }
                
        if(!itemsToProcess.isEmpty()) {
            List<Approval.ProcessResult> result = Approval.process(itemsToProcess);
            //Submitted for Approval and Reserve the inventory
            linkInventoryToRequest(LibItemList, Label.Library_Request_Status_PendingApproval);
        }
    }
    
    //Process Flow for returning item
    public static void cancelOrReturnProcessFlow(List<Library_Item_Request__c> libItemReqs,  Map<Id,Library_Item_Request__c> oldMapLibReqItems)
    {
        List<Library_Inventory__c> LibInvsToUpdate = new List<Library_Inventory__c>();
        List<Library_Item_Request__c> LibItemReqsToUpdate = new List<Library_Item_Request__c>();
        Set<Id> setReturnItemIds = new Set<Id>();
        Map<Id, List<Library_Item_Request__c>> mapWaitlist = new Map<Id, List<Library_Item_Request__c>>();
        //Get all items returned
        for(Library_Item_Request__c libItemReq: libItemReqs) {
            setReturnItemIds.add(libItemReq.Library_Item__c);
            libItemReq.Return_Date_Time__c = Datetime.now();    
        }
        if(!setReturnItemIds.isEmpty()) {
            //Get a waitlist map for each of the returned item      
            for(Library_Item_Request__c libItemReq: [Select Id, Name, Library_Item__c, Library_Item__r.Item_Name__c, Status__c, OwnerId From Library_Item_Request__c Where Library_Item__c IN :setReturnItemIds And Status__c =: Label.Library_Request_Status_Waitlist order By Createddate asc ]) {
                if(mapWaitlist.containsKey(libItemReq.Library_Item__c)) {
                    mapWaitlist.get(libItemReq.Library_Item__c).add(libItemReq);
                } else {
                    List<Library_Item_Request__c> reqs = new List<Library_Item_Request__c>();
                    reqs.add(libItemReq);
                    mapWaitlist.put(libItemReq.Library_Item__c, reqs);
                }
            }
            
            List<Library_Item_Request__Share> LibraryRequestSharingRules = new List<Library_Item_Request__Share>();
            for(Library_Item_Request__c libItemReq: libItemReqs) {
                //if someone in the waitlist
                if(mapWaitlist.containsKey(libItemReq.Library_Item__c)) {
                    if(mapWaitlist.get(libItemReq.Library_Item__c).size()>0) {
                        Library_Item_Request__c newlibItemReq = 
                            new Library_Item_Request__c(Id=mapWaitlist.get(libItemReq.Library_Item__c)[0].Id,
                                                        //Automatically reserved the item for the people in the waitlist
                                                        Library_Request_Inventory__c = libItemReq.Library_Request_Inventory__c, 
                                                        Reserved_Date_Time__c = Datetime.now(),
                                                        Status__c = Label.Library_Request_Status_Reserved
                                                        //,Send_Overdue_Reminder_Email_Datetime__c = Datetime.now()
                                                        );                      
                        
                        //LibraryRequestSharingRules.add(new Library_Item_Request__Share(AccessLevel = 'Edit', ParentId = mapWaitlist.get(libItemReq.Library_Item__c)[0].Id, UserOrGroupId = libItemReq.OwnerId ));                       
                        
                        /*
                            Fixed by Nick Wu
                            create the sharing rule only for the owner are different 
                            to avoid INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY exception
                        */
                        if(mapWaitlist.get(libItemReq.Library_Item__c)[0].OwnerId != libItemReq.OwnerId){
                        
                            Library_Item_Request__Share itemRequestShare =  
                                            new Library_Item_Request__Share(AccessLevel = 'Edit', 
                                                            ParentId = mapWaitlist.get(libItemReq.Library_Item__c)[0].Id, 
                                                            UserOrGroupId = libItemReq.OwnerId );
                            LibraryRequestSharingRules.add(itemRequestShare);    
                        }   

                    } 
                }       
            }
            if(!LibraryRequestSharingRules.isEmpty()) {
                SystemUtil.SafeInsert(LibraryRequestSharingRules);
            }
            
            for(Library_Item_Request__c libItemReq: libItemReqs) {
                //if someone in the waitlist
                if(mapWaitlist.containsKey(libItemReq.Library_Item__c)) {
                    if(mapWaitlist.get(libItemReq.Library_Item__c).size()>0) {
                        Library_Item_Request__c newlibItemReq = 
                            new Library_Item_Request__c(Id=mapWaitlist.get(libItemReq.Library_Item__c)[0].Id,
                                                        //Automatically reserved the item for the people in the waitlist
                                                        Library_Request_Inventory__c = libItemReq.Library_Request_Inventory__c, 
                                                        Reserved_Date_Time__c = Datetime.now(),
                                                        Status__c = Label.Library_Request_Status_Reserved
                                                        //,Send_Overdue_Reminder_Email_Datetime__c = Datetime.now()
                                                        );
                        ChatterUtil.simpleTextPostWithMention(mapWaitlist.get(libItemReq.Library_Item__c)[0].Id, mapWaitlist.get(libItemReq.Library_Item__c)[0].OwnerId, 'You may pick up your requested item (' + mapWaitlist.get(libItemReq.Library_Item__c)[0].Library_Item__r.Item_Name__c +') ');
                        
                        LibItemReqsToUpdate.add(newlibItemReq);
                        mapWaitlist.get(libItemReq.Library_Item__c).remove(0);
                    } else {
                        //if no one else left in the waitlist
                        //update the lending status of the inventory to available
                        Library_Inventory__c libInv = new Library_Inventory__c(Id=oldMapLibReqItems.get(libItemReq.Id).Library_Request_Inventory__c, Lending_Status__c='Available', Return_Date_Time__c=null, Target_Address__c=null, Detail_Current_Location__c=null);
                        LibInvsToUpdate.add(libInv);
                    }
                        
                } else {
                    //if no one in the waitlist
                    //update the lending status of the inventory to available
                    /*
                        Modified by NickWu
                        If the inventory id no longer existed, dont add into update list
                    */
                    if(oldMapLibReqItems.get(libItemReq.Id).Library_Request_Inventory__c != null || oldMapLibReqItems.get(libItemReq.Id).Library_Request_Inventory__c !=''){
                        Library_Inventory__c libInv = new Library_Inventory__c(Id=oldMapLibReqItems.get(libItemReq.Id).Library_Request_Inventory__c, Lending_Status__c='Available', Return_Date_Time__c=null, Target_Address__c=null, Detail_Current_Location__c=null);
                        LibInvsToUpdate.add(libInv);
                    }
                }           
            }

            //check the sharing rule if inserted successful.
            if(!LibraryRequestSharingRules.isEmpty()) {
                SystemUtil.SafeDelete(LibraryRequestSharingRules);
            }
            
            if(!LibItemReqsToUpdate.isEmpty()){
                SystemUtil.SafeUpdate(LibItemReqsToUpdate);
            }
            
            /*
            if(!LibInvsToUpdate.isEmpty()){
                SystemUtil.SafeUpdate(LibInvsToUpdate);
            }*/
            
        }
    }
    
    //Check if there is rejected request within last 7 days
    public static Map<Id, Library_Item_Request__c> rejectedRequestMap(List<Library_Item_Request__c> libItemReqs) {
        Set<Id> setItemIds = new Set<Id>();
        for(Library_Item_Request__c req: libItemReqs) {
            setItemIds.add(req.Library_Item__c);
        }
        Map<Id, Library_Item_Request__c> rejectedLibItemReqsMap = new Map<Id, Library_Item_Request__c>();
        for( Library_Item_Request__c req: 
            [Select Id, Name, Library_Item__c
             From Library_Item_Request__c
             Where Library_Item__c = :setItemIds
             And CreatedById = :userInfo.getUserId()
             And Id IN (Select TargetObjectId 
                        From ProcessInstance
                        Where CreatedById = :userInfo.getUserId()
                        And Status =: Label.Library_Request_Status_Rejected
                        And CreatedDate > :datetime.now() - Integer.valueOf(Label.Library_Rejected_Request_Day))]) {
            rejectedLibItemReqsMap.put(req.Library_Item__c, req);                   
        } 
        return rejectedLibItemReqsMap;
    }
}