/**
 * LibraryInventoryTriggerHandler Class
 *
 * @Author: AN, WG, NW
 * @Object: Library_Inventory__c, Library_Item_Request__c
 * @Description Handles the inventory trigger, update the information of Library_item_request__c
 * 
 */
public without sharing class LibraryInventoryTriggerHandler {
    
    /**
     * @description Entry point for After Insert
     */ 
    public static void isAfterInsert(List<Library_Inventory__c> libInvs) {
        updateWaitlistReqsToReserved(libInvs);
    }
    
    /**
     * @description Entry point for After Update
     */
    public static void isAfterUpdate(Map<Id,Library_Inventory__c> NewInvMap, Map<Id,Library_Inventory__c> OldInvMap) {
        List<Library_Inventory__c> libInvs = new List<Library_Inventory__c>();
        for(Library_Inventory__c inv: NewInvMap.Values()) {
            if(inv.Lending_Status__c == Label.Library_Inventory_Lending_Status_available && OldInvMap.get(inv.Id).Lending_Status__c == Label.Library_Inventory_Lending_Status_unavailable) {                
                libInvs.add(inv);
            }
        }
        updateWaitlistReqsToReserved(libInvs);
    }
    
    
    /**
     * @description Not allow user to update the inventory lending status when it was in request flow
     */
    public static void preventUpdateStatus (List<Library_Inventory__c> libInvs, Map<Id,Library_Inventory__c> OldInvMap){
        Set<Id> setInvs = new Set<Id>();
        
        for(Library_Inventory__c inv: libInvs) {
            //Valid those inventory with changed lending status
            if(inv.Lending_Status__c != OldInvMap.get(inv.Id).Lending_Status__c) {
                setInvs.add(inv.Id);
            }
        }
        
        Map<Id, Library_Item_Request__c> libItemsMap = new Map<Id, Library_Item_Request__c>();
        
        List<String> burberryList = new List<String>();
        List<String> otherCatList = new List<String>();
        List<String> otherList = new List<String>();
        
        burberryList.add(Label.Library_Request_Status_PendingApproval);
        burberryList.add(Label.Library_Request_Status_Reserved);
        burberryList.add(Label.Library_Request_Status_Outbound);
        
        otherCatList.add(Label.Library_RecordType_Book);
        otherCatList.add(Label.Library_Item_category_Burberry);
        otherCatList.add('');
        
        otherList.add(Label.Library_Request_Status_PendingApproval);
        otherList.add(Label.Library_Request_Status_Reserved);
        otherList.add(Label.Library_Request_Status_Outbound);
        otherList.add(Label.Library_Request_Status_Arrived);
        otherList.add(Label.Library_Request_Status_Borrowed);
        
        /*
            Query logic:
            Book -            lock Reserved
            BurberryArchive - lock Pending Approval,Reserved,Outbound In-Transit
            Others -          lock 'Pending Approval','Reserved','Outbound In-Transit','Arrived', 'Borrowed'
        */
        for(Library_Item_Request__c req:[Select Id, Name, Library_Item__c, Library_Request_Inventory__c, Status__c
                                        From Library_Item_Request__c Where
                                         ((
                                            Item_Category__c =: Label.Library_RecordType_Book AND 
                                            Status__c =: Label.Library_Request_Status_Reserved
                                         ) OR 
                                         (
                                            Item_Category__c =: Label.Library_Item_category_Burberry AND 
                                            Status__c IN: burberryList
                                            //Status__c IN ('Pending Approval','Reserved','Outbound In-Transit') 
                                         )OR 
                                         (
                                         	Item_Category__c NOT IN: otherCatList AND
                                            //Item_Category__c NOT IN ('Book','Burberry Archive','') AND 
                                            Status__c IN: otherList
                                            //Status__c IN ('Pending Approval','Reserved','Outbound In-Transit','Arrived', 'Borrowed')
                                         ))
                                        And Library_Request_Inventory__c IN :setInvs]) {
            libItemsMap.put(req.Library_Request_Inventory__c, req);
        }
        
        for(Library_Inventory__c inv: libInvs) {
            if(inv.Lending_Status__c != OldInvMap.get(inv.Id).Lending_Status__c) {
                if(libItemsMap.containsKey(inv.Id) && inv.Lending_Status__c == Label.Library_Inventory_Lending_Status_available) {
                    inv.addError(Label.Library_not_allowed_update_lendingStatus);
                }
            }
        }
    }
    
    /**
     * @description Do not allow users to update the location of the record during specific States
     */
    public static void preventUpdateLocation(List<Library_Inventory__c> libInvs, Map<Id,Library_Inventory__c> OldInvMap) {
        Set<Id> setInvs = new Set<Id>();
        for(Library_Inventory__c inv: libInvs) {
            //Valid those inventory with changed Home Location
            if(inv.Original_Address__c != OldInvMap.get(inv.Id).Original_Address__c) {
                setInvs.add(inv.Id);
            }
        }
        Map<Id, Library_Item_Request__c> libItemsMap = new Map<Id, Library_Item_Request__c>();
        
        list<String> statusList = new list<String>();
        statusList.add(Label.Library_Request_Status_PendingApproval);
        statusList.add(Label.Library_Request_Status_Waitlist);
        statusList.add(Label.Library_Request_Status_Reserved);
        statusList.add(Label.Library_Request_Status_Outbound);
        statusList.add(Label.Library_Request_Status_Arrived);
        statusList.add(Label.Library_Request_Status_Borrowed);
        statusList.add(Label.Library_Request_Status_Inbound);
        
        for(Library_Item_Request__c req:[Select Id, Name, Library_Item__c, Library_Request_Inventory__c, Status__c
                                        From Library_Item_Request__c Where Status__c IN: statusList
                                        And Library_Request_Inventory__c IN :setInvs]) {
            libItemsMap.put(req.Library_Request_Inventory__c, req);
        }
        for(Library_Inventory__c inv: libInvs) {
            if(inv.Original_Address__c != OldInvMap.get(inv.Id).Original_Address__c) {
                if (!(!libItemsMap.containsKey(inv.Id) && (inv.Target_Address__c == inv.Original_Address__c || inv.Target_Address__c == null))) {
                    inv.addError(Label.Library_Cannot_Update_Inventory_Location);
                }
            }
        }
    }
    
    /**
     * @description Checks if there are any Library Request records that are on Waitlist, and assigns the new Inventory record if it's available.
     */
    public static void updateWaitlistReqsToReserved(List<Library_Inventory__c> libInvs) {
        Map<Id, Integer> libItemsMap = new Map<Id, Integer>();
        for(Library_Inventory__c inv: libInvs) {
            if(libItemsMap.containsKey(inv.Library_Item_Master__c)) {
                libItemsMap.put(inv.Library_Item_Master__c, libItemsMap.get(inv.Library_Item_Master__c) + 1);
            } else {
                libItemsMap.put(inv.Library_Item_Master__c, 1);
            }
        }

        //Find if any status of requests are in waitlist with these items
        List<Library_Item_Request__c> reqs = new List<Library_Item_Request__c> ();
        List<Library_Item_Request__c> reqsToUpdate = new List<Library_Item_Request__c> ();
        List<Library_Inventory__c> invsToUpdate = new List<Library_Inventory__c> ();
        Map<Id, List<Library_Item_Request__c>> libItemsToWaitlistReqMap = new Map<Id, List<Library_Item_Request__c>>();
        reqs = [Select Id, Name, Library_Item__c, Library_Request_Inventory__c, OwnerId From Library_Item_Request__c Where 
                Status__c = :Label.Library_Request_Status_Waitlist And Library_Item__c IN :libItemsMap.keySet() And Library_Request_Inventory__c = null Order By CreatedDate];
        
        for(Library_Item_Request__c req: reqs) {
            if(libItemsToWaitlistReqMap.containsKey(req.Library_Item__c)) {
                if(libItemsMap.get(req.Library_Item__c) > libItemsToWaitlistReqMap.get(req.Library_Item__c).size()) {
                    libItemsToWaitlistReqMap.get(req.Library_Item__c).add(req);
                }   
            } else {
                List<Library_Item_Request__c> rs = new List<Library_Item_Request__c>();
                rs.add(req);
                libItemsToWaitlistReqMap.put(req.Library_Item__c, rs);
            }           
        }

        
        //Update Waitlist Request
        for(Library_Inventory__c inv: libInvs) {
            if(libItemsToWaitlistReqMap.containsKey(inv.Library_Item_Master__c)) {
                if(libItemsToWaitlistReqMap.get(inv.Library_Item_Master__c).size()>0) {
                    libItemsToWaitlistReqMap.get(inv.Library_Item_Master__c)[0].Library_Request_Inventory__c = inv.Id;
                    libItemsToWaitlistReqMap.get(inv.Library_Item_Master__c)[0].Status__c = Label.Library_Request_Status_Reserved;
                    libItemsToWaitlistReqMap.get(inv.Library_Item_Master__c)[0].Reserved_Date_Time__c = Datetime.now();
                    //Update Related Inventory to Not Available
                    Library_Inventory__c updateInv = new Library_Inventory__c(Id=inv.Id, Lending_Status__c= Label.Library_Inventory_Lending_Status_unavailable);
                    invsToUpdate.add(updateInv);
                    
                    //Nick Wu added to notify the user when waitlist changed to reserved
                    try{
                        Library_Item_Request__c lr = libItemsToWaitlistReqMap.get(inv.Library_Item_Master__c)[0];
                        ChatterUtil.simpleTextPostWithMention(inv.id, lr.ownerid, 'The request ' + lr.name + ' has been updated to Reserved status');
                    }catch(Exception ex){
                    }
                    
                    
                    reqsToUpdate.add(libItemsToWaitlistReqMap.get(inv.Library_Item_Master__c)[0]);
                    libItemsToWaitlistReqMap.get(inv.Library_Item_Master__c).remove(0);                 
                }
            }
        }

        if(!reqsToUpdate.isEmpty()) {
            SystemUtil.SafeUpdate(reqsToUpdate);    
        }

        if(!invsToUpdate.isEmpty()) {
            SystemUtil.SafeUpdate(invsToUpdate);    
        }
        
    }
}