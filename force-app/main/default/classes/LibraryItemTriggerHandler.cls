/**
 * @description Trigger Handler for the Library Item object
 * @date 26/01/2015
 */
public without sharing class LibraryItemTriggerHandler {
    /*
    public static void preventCloneNullItem(List<Library_Item__c> items) {
        for(Library_Item__c li : items) {
            if(li.Item_Name__c == null && li.Item_Description__c ==null) {
                li.addError('You are not allowed to clone this item!');
            }
        }       
    }
    */
    
    /**
     * @description updates a Technical Owner field with the Owner Id and 
     *              if the record type is Book, set Require Approval to false
     */
    public static void updateWarehouseTechOwner(List<Library_Item__c> items) {
        //Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>([Select Id, Name From RecordType Where Name = 'Warehouse' or Name = 'Burberry Archive' limit 2]);
        
        //Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>([Select Id, Name From RecordType Where Name = 'Book' limit 1]);
        
        for(Library_Item__c li : items) {
            //system.debug('@@@ li.recordTypeId ' + li.recordTypeId);
            //system.debug('@@@ mapRecordType ' + mapRecordType);
            //if(mapRecordType.containsKey(li.recordTypeId)) { //all records
                if(li.Tech_Owner__c != li.OwnerId) {
                    li.Tech_Owner__c = li.OwnerId;
                }
            //}
            //Book
            /*if(mapRecordType.containsKey(li.recordTypeId)) {
                li.Require_Approval__c = false;             
            }*/
        }       
    }
    
    /**
     *Added by TAL (Twinkle Li) @20170718
     *Description: initialize default value of 'Require Approval' to be 'FALSE'
     *             if the record type is Book or Fabric
    */
    public static void updateRequireApproval(List<Library_Item__c> items) {
        Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>([Select Id, Name From RecordType Where Name = 'Book' or developerName = 'Fabric' limit 2]);
        
        for(Library_Item__c li : items) {
            if(mapRecordType.containsKey(li.recordTypeId)) {
                li.Require_Approval__c = false;             
            }
        }       
    }
    
    //added by nickwu
    /**
     * @description update the Weave_Knit_Type_Text__c & Fabric_Finishing_Text__c fields
     */
    public static void updateFabricFinishingText(List<Library_Item__c> items){
        
        for(Library_Item__c li : items){
            if(li.Weave_Knit_Type_TGA__c!=null &&li.Weave_Knit_Type_TGA__c!=''){
                li.Weave_Knit_Type_Text__c= li.Weave_Knit_Type_TGA__c;
            }
            if(li.Fls_Fabric_Finish__c!=null &&li.Fls_Fabric_Finish__c!=''){
                li.Fabric_Finishing_Text__c = li.Fls_Fabric_Finish__c;
            }
        }
    }
    
    
    /**
     * @description Automatically create an inventory and default the location based on Type
     */
    public static void createInventory(List<Library_Item__c> items) {
        boolean disableCreation = false;
        
        try {
            disableCreation = Boolean.valueOf(Label.Library_Tech_Disable_Inventory_Creation);
        } catch (Exception e) {}
        
        if(disableCreation) {
            return;
        }
        
        List<Library_Inventory__c> invs = new List<Library_Inventory__c>();
        Set<Id> itemIds= new Set<Id>();
        for(Library_Item__c li : items) {
            itemIds.add(li.RecordTypeId);
        }
        Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>([Select Id, Name From RecordType Where Id IN:itemIds]);
        for(Library_Item__c li : items) {
            if(mapRecordType.get(li.recordTypeID).Name != Label.Library_RecordType_Fabric) {
                if(li != null && li.recordTypeID != null) {
                    Library_Inventory__c inv = new Library_Inventory__c();
                    inv.Library_Item_Master__c = li.Id;
                    inv.Lending_Status__c = Label.Library_Inventory_Lending_Status_unavailable;
                    inv.Disposal_Date__c = date.today() + Integer.valueOf(Label.Library_Disposal_Days);
                    
                    String locationId = '';
                    /*
                        Nick Wu
                        For books, automatically assigned 4 locations by defaults, as well as lending status.
                    */
                    List<Location__c> dummyGenLocation = new List<Location__c>();
                    List<Location__c> dummyDetailLocation = new List<Location__c>();
                    
                    if(Test.isRunningTest()) {
                        dummyDetailLocation = [SELECT Id FROM Location__c WHERE RecordType.DeveloperName = 'Detail_Location' LIMIT 1];
                        dummyGenLocation = [SELECT Id FROM Location__c WHERE RecordType.DeveloperName = 'General_Location' LIMIT 1];
                    }
                    
                    if(mapRecordType.get(li.recordTypeID).Name == Label.Library_RecordType_Book) {

                        
                        locationId = Label.Library_Default_Location_Book;
                        inv.Lending_Status__c = Label.Library_Inventory_Lending_Status_available;
                        
                        if(!Test.isRunningTest()) {
                            inv.Detail_Home_Location__c = Label.Library_Default_DetailLocation_Book;
                            inv.Detail_Current_Location__c= Label.Library_Default_DetailLocation_Book;
                            inv.Target_Address__c = Label.Library_Default_Location_Book;
                        } else {
                            inv.Detail_Home_Location__c = dummyDetailLocation[0].Id;
                            inv.Detail_Current_Location__c= dummyDetailLocation[0].Id;
                            inv.Target_Address__c = dummyGenLocation[0].Id;
                        }
                        
                    } else if(mapRecordType.get(li.recordTypeID).Name == Label.Library_Item_category_Burberry) {
                        locationId = Label.Library_Default_Location_Burberry_Archive;
                    } else if(mapRecordType.get(li.recordTypeID).Name == Label.Library_Item_category_Samples_PD) {
                        locationId = Label.Library_Default_Location_Samples_PD;
                    } else if(mapRecordType.get(li.recordTypeID).Name == Label.Library_Item_category_Samples_TGA) {
                        locationId = Label.Library_Default_Location_Samples_TGA;
                    } else if(mapRecordType.get(li.recordTypeID).Name == Label.Library_Item_category_Warehouse) {
                        locationId = Label.Library_Default_Location_Warehouse;
                    } else if (mapRecordType.get(li.recordTypeID).Name == Label.Library_Item_category_Chico) {
                        locationId = Label.Library_Default_Location_Chico_Archive;
                    } else {
                        locationId = Label.Library_Default_Location_Book;
                    }
                    
                    if(Test.isRunningTest()) {
                        locationId = dummyGenLocation[0].Id;
                    }
                    
                    inv.Original_Address__c = locationId;
                    
                    
                    invs.add(inv);
                }
            }
        }
        insert invs;
        //SystemUtil.SafeInsert(invs);
    }
    
    /**
     * @description Concatenates all 4 FLS Content fields into a single String
     *
     */
    public static void concatenateContent(List<Library_Item__c> items) {
        for(Library_Item__c li : items) {
            li.Tech_Content_Concatenated__c = '';
            if(li.Fls_Content__c != null && li.Fls_Content__c != '') {
                li.Tech_Content_Concatenated__c = li.Tech_Content_Concatenated__c + li.Fls_Content__c + ';';
            }
            if(li.Fls_Content_2__c != null && li.Fls_Content_2__c != '') {
                li.Tech_Content_Concatenated__c = li.Tech_Content_Concatenated__c + li.Fls_Content_2__c + ';';
            }
            if(li.Fls_Content_3__c != null && li.Fls_Content_3__c != '') {
                li.Tech_Content_Concatenated__c = li.Tech_Content_Concatenated__c + li.Fls_Content_3__c + ';';
            }
            if(li.Fls_Content_4__c != null && li.Fls_Content_4__c != '') {
                li.Tech_Content_Concatenated__c = li.Tech_Content_Concatenated__c + li.Fls_Content_4__c + ';';
            }
            if(li.Tech_Owner__c == null) {  
                li.Tech_Owner__c = li.OwnerId;
            }
        }
    }
    
    /**
     * @description Get the FLS Fabric Records as long as Sample Fabric ID is populated
     */
    public static void getFlsFabricRecords(Map<Id,Library_Item__c> NewItemMap, Map<Id,Library_Item__c> OldItemMap) {
        
        //List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SObjectType = 'Library_Item__c' AND DeveloperName = 'Samples'];
        //String rtId = rtList[0].Id;
        
        Set<Id> rtIds = new Set<Id>();
        for(RecordType rt :[SELECT Id FROM RecordType WHERE SObjectType = 'Library_Item__c' AND (DeveloperName = 'SamplesPD' OR DeveloperName = 'SamplesTGA')]) {
            rtIds.add(rt.Id);
        }
        
        List<String> itemsToBeProcessed = new List<String>();
        List<String> itemsToDeleteConditions = new List<String>();
        
        for(Library_Item__c li : NewItemMap.values()) {
            String currRt = NewItemMap.get(li.Id).RecordTypeId;
            //if( currRt == rtId && Trigger.isInsert) {
            if(rtIds.contains(currRt) && Trigger.isInsert) {
                
                itemsToBeProcessed.add(li.Id);
                
            //} else if( Trigger.isUpdate && currRt == rtId && (
            } else if( Trigger.isUpdate && rtIds.contains(currRt) && (
            
                    NewItemMap.get(li.Id).Sample_Fabric_ID_1__c != OldItemMap.get(li.Id).Sample_Fabric_ID_1__c ||
                    NewItemMap.get(li.Id).Sample_Fabric_ID_2__c != OldItemMap.get(li.Id).Sample_Fabric_ID_2__c ||
                    NewItemMap.get(li.Id).Sample_Fabric_ID_3__c != OldItemMap.get(li.Id).Sample_Fabric_ID_3__c ||
                    NewItemMap.get(li.Id).Sample_Fabric_ID_4__c != OldItemMap.get(li.Id).Sample_Fabric_ID_4__c
                )) {
                
                itemsToBeProcessed.add(li.Id);
                
                if(NewItemMap.get(li.Id).Sample_Fabric_ID_1__c == null || NewItemMap.get(li.Id).Sample_Fabric_ID_1__c == '' 
                    && OldItemMap.get(li.Id).Sample_Fabric_ID_1__c != null && OldItemMap.get(li.Id).Sample_Fabric_ID_1__c != '') {
                    
                    itemsToDeleteConditions.add(' ( Sample__c = \'' + li.Id + '\' AND Fabric_ID__c = \'' + OldItemMap.get(li.Id).Sample_Fabric_ID_1__c + '\') ');
                }
                if(NewItemMap.get(li.Id).Sample_Fabric_ID_2__c == null || NewItemMap.get(li.Id).Sample_Fabric_ID_2__c == '' 
                    && OldItemMap.get(li.Id).Sample_Fabric_ID_2__c != null && OldItemMap.get(li.Id).Sample_Fabric_ID_2__c != '') {
                    
                    itemsToDeleteConditions.add(' ( Sample__c = \'' + li.Id + '\' AND Fabric_ID__c = \'' + OldItemMap.get(li.Id).Sample_Fabric_ID_2__c + '\') ');
                }
                if(NewItemMap.get(li.Id).Sample_Fabric_ID_3__c == null || NewItemMap.get(li.Id).Sample_Fabric_ID_3__c == '' 
                    && OldItemMap.get(li.Id).Sample_Fabric_ID_3__c != null && OldItemMap.get(li.Id).Sample_Fabric_ID_3__c != '') {
                    
                    itemsToDeleteConditions.add(' ( Sample__c = \'' + li.Id + '\' AND Fabric_ID__c = \'' + OldItemMap.get(li.Id).Sample_Fabric_ID_3__c + '\') ');
                }
                if(NewItemMap.get(li.Id).Sample_Fabric_ID_4__c == null || NewItemMap.get(li.Id).Sample_Fabric_ID_4__c == '' 
                    && OldItemMap.get(li.Id).Sample_Fabric_ID_4__c != null && OldItemMap.get(li.Id).Sample_Fabric_ID_4__c != '') {
                    
                    itemsToDeleteConditions.add(' ( Sample__c = \'' + li.Id + '\' AND Fabric_ID__c = \'' + OldItemMap.get(li.Id).Sample_Fabric_ID_4__c + '\') ');
                }
            }
        }
        
        if(!itemsToBeProcessed.isEmpty()) {
            LibraryItemTriggerHandler.upsertSampleFabric(itemstoBeProcessed);
        }
        
        if(!itemsToDeleteConditions.isEmpty()) {
            String query = String.format('SELECT Id FROM Sample_Fabric__c WHERE {0}',
                                     new List<String>{ String.join(itemsToDeleteConditions, ' OR ') }); 
            
            List<Sample_Fabric__c> itemResultSet = (List<Sample_Fabric__c>) Database.query(query);
            
            if(!ErrorUtils.isEmpty(itemResultSet)) {
                SystemUtil.SafeDelete(itemResultSet);
            }
        }
    }
    
    //Perform upsert sample fabric by updating the old fabric id
    @future (callout=true)
    public static void upsertSampleFabric2(String sampleFabricId, String oldFabricId, String fabricId, String colorId) {
        
        Map<String, List<Library_Item__c>> resultMap;
        Map<String, List<String>> keyToFabricIds = new Map<String, List<String>>();
        List<Sample_Fabric__c> sfList = [SELECT Id, Fabric__c, Sample__c, Sample_Fabric_External_Id__c,
                                            Tech_Getting_Data__c FROM Sample_Fabric__c WHERE Id =: sampleFabricId];
        
        List<String> fabricIds = new List<String>();    
        fabricIds.add(fabricId);
        
        List<Library_Item__c> updateFabrics = new List<Library_Item__c>();
        
        keyToFabricIds.put(sampleFabricId, fabricIds);
        if(keyToFabricIds != null && !keyToFabricIds.isEmpty()) {
            LibrarySourceFabricRepository repo = new LibrarySourceFabricRepository();
            resultMap = repo.getItems(keyToFabricIds);
            List<Sample_Fabric__c> sfListToUpdate = new List<Sample_Fabric__c>();
            
            // Now we need to insert the junction object
            if(resultMap != null && !resultMap.isEmpty()) {
                for(String key : resultMap.keyset()) {
                    List<Library_Item__c> liList = resultMap.get(key);
                    for(Library_Item__c li : liList) {
                        //throw new TalException(li.Id);
                        sfList[0].Fabric__c = li.Id;
                        sfList[0].Sample_Fabric_External_Id__c = li.Id + '-' + key;
                        sfList[0].Tech_Getting_Data__c = false;
                        
                        //2015-01-07
                        li.Sample_Fabric_ID_1__c = li.Fabric_ID__c;
                        updateFabrics.add(li);
                    }
                }
                try{
                    upsert sfList;
                }catch(Exception e){}
                
                SystemUtil.SafeUpdate(updateFabrics);
                
                List<Library_Item__c> deleteme = [select id from library_item__c where id = :fabricId];
                if(!ErrorUtils.isEmpty(deleteme)) {
                    delete deleteme;
                }
            }
        }
        
        //FIXME: Delete the manually created one.
    }
    
    //Perform upsert sample fabric by list of sampleIds
    @future (callout=true)
    public static void upsertSampleFabric(List<String> sampleIds) {
        Map<String, List<Library_Item__c>> resultMap;
        Map<String, List<String>> keyToFabricIds = new Map<String, List<String>>();
        
        
        for(Library_Item__c li : [SELECT Id, Sample_Fabric_ID_1__c, Sample_Fabric_ID_2__c, Sample_Fabric_ID_3__c, Sample_Fabric_ID_4__c
                        FROM Library_item__c WHERE id IN: sampleIds]) {
        List<String> fabricIds = new List<String>();
        
            if(li.Sample_Fabric_ID_1__c != null) {
                fabricIds.add(li.Sample_Fabric_ID_1__c);
            }
            if(li.Sample_Fabric_ID_2__c != null) {
                fabricIds.add(li.Sample_Fabric_ID_2__c);
            }
            if(li.Sample_Fabric_ID_3__c != null) {
                fabricIds.add(li.Sample_Fabric_ID_3__c);
            }
            if(li.Sample_Fabric_ID_4__c != null) {
                fabricIds.add(li.Sample_Fabric_ID_4__c);
            } 
            
            keyToFabricIds.put(li.Id, fabricIds);
        }
        if(keyToFabricIds != null && !keyToFabricIds.isEmpty()) {
            LibrarySourceFabricRepository repo = new LibrarySourceFabricRepository();
            resultMap = repo.getItems(keyToFabricIds);
            List<Sample_Fabric__c> sfList = new List<Sample_Fabric__c>();
            
            // Now we need to insert the junction object
            if(resultMap != null && !resultMap.isEmpty()) {
                for(String key : resultMap.keyset()) {
                    List<Library_Item__c> liList = resultMap.get(key);
                    for(Library_Item__c li : liList) {
                        Sample_Fabric__c sf = new Sample_Fabric__c(Fabric__c=li.Id, Sample__c=key, Sample_Fabric_External_Id__c = li.Id + '-' + key);
                        sfList.add(sf);
                    }
                }
                try{
                    upsert sfList Sample_Fabric_External_Id__c;
                }catch(Exception e){}
            }
        }
    }
    
    /**
     * @description If the approvers are updated on a Library Item record, the approvers also need to be updated on active requests
     */
    public static void updateRequestApprovers(Map<Id,Library_Item__c> NewItemMap, Map<Id,Library_Item__c> OldItemMap) {
        List<Library_Item__c> itemsToUpdate = new List<Library_Item__c>();
        List<Library_Item_Request__c> requestsToUpdate = new List<Library_Item_Request__c>();
        
        for(Library_Item__c li : NewItemMap.values()) {
            if(li.OwnerId != OldItemMap.get(li.Id).OwnerId ||
                li.Owner_2__c != OldItemMap.get(li.Id).Owner_2__c ||
               li.Owner_3__c != OldItemMap.get(li.Id).Owner_3__c ||
               li.Owner_4__c != OldItemMap.get(li.Id).Owner_4__c
              ) {
                itemsToUpdate.add(li);
            }
        }
        
        if(itemsToUpdate != null && !itemsToUpdate.isEmpty()) {
            for(Library_Item_Request__c lir : 
                    [
                        SELECT Id, Owner_1__c, Owner_2__c, Owner_3__c, Owner_4__c, Library_Item__c
                        FROM Library_Item_Request__c 
                        WHERE Library_Item__c IN: itemsToUpdate
                    ]) 
            {
                Library_Item__c li = NewItemMap.get(lir.Library_Item__c);
                lir.Owner_1__c = li.OwnerId;
                        
                if(li.Owner_2__c != null) {
                    lir.Owner_2__c = li.Owner_2__c;
                } else {
                    lir.Owner_2__c = li.OwnerId;
                }
                
                if(li.Owner_3__c != null) {
                    lir.Owner_3__c = li.Owner_3__c;
                } else {
                    lir.Owner_3__c = li.OwnerId;
                }
                
                if(li.Owner_4__c != null) {
                    lir.Owner_4__c = li.Owner_4__c;
                } else {
                    lir.Owner_4__c = li.OwnerId;
                }
                
                requestsToUpdate.add(lir);
            }
        }
        SystemUtil.SafeUpdate(requestsToUpdate);
    }
    
    /**
     * @description Based on the "Can Be Borrowed" flag on the Library Item, update the inventory accordingly
     */
    public static void updateRelatedInventory(Map<Id,Library_Item__c> NewItemMap, Map<Id,Library_Item__c> OldItemMap) {
        Set<Id> relatedItemIds = new Set<Id>();
        Set<Id> relatedInvIds = new Set<Id>();
        
        for(Library_Item__c itm: NewItemMap.Values()) {
            if(itm.Can_Be_Borrowed__c != OldItemMap.get(itm.Id).Can_Be_Borrowed__c) {               
                relatedItemIds.add(itm.Id);
            }
        }
        
        Map<Id, List<Library_Inventory__c>> relatedInvsMap = new Map<Id, List<Library_Inventory__c>>();
        List<Library_Inventory__c> invs = [Select Id, Lending_Status__c, Library_Item_Master__c, Detail_Home_Location__c
            From Library_Inventory__c
            Where Library_Item_Master__c =:relatedItemIds
            And Lending_Status__c != :Label.Library_cannotBorrow];
        for(Library_Inventory__c inv: invs) {
            relatedInvIds.add(inv.Id);
        }
        
        Set<Id> invsLinkedWithActiveRequest = new Set<Id>();
        Set<Id> itmsLinkedWithActiveRequest = new Set<Id>();
        for(Library_Item_Request__c lir: [Select Id, Name, Library_Request_Inventory__c, Library_Item__c
                                            From Library_Item_Request__c
                                            Where Library_Request_Inventory__c IN :relatedInvIds
                                            And Status__c != :Label.Library_Request_Status_Not_Submitted 
                                            And Status__c != :Label.Library_Request_Status_Returned
                                            And Status__c != :Label.Library_Request_Status_Rejected
                                            And Status__c != :Label.Library_Request_Status_Cancelled
                                            And Status__c != :Label.Library_Request_Status_Lost]) {
            invsLinkedWithActiveRequest.add(lir.Library_Request_Inventory__c);
            itmsLinkedWithActiveRequest.add(lir.Library_Item__c);
        }
        
        for(Library_Inventory__c inv: invs) {
            if(!invsLinkedWithActiveRequest.contains(inv.Id)) { //Check if the inventory is linked with active request
                if(relatedInvsMap.containsKey(inv.Library_Item_Master__c)) {
                    relatedInvsMap.get(inv.Library_Item_Master__c).add(inv);
                } else {
                    List<Library_Inventory__c> newlist = new List<Library_Inventory__c>();
                    newlist.add(inv);
                    relatedInvsMap.put(inv.Library_Item_Master__c, newlist);
                }
            }
        }
        
        List<Library_Inventory__c> invsToUpdate = new List<Library_Inventory__c>();
        for(Library_Item__c itm: NewItemMap.Values()) {
            if(itm.Can_Be_Borrowed__c != OldItemMap.get(itm.Id).Can_Be_Borrowed__c) {
                if(itmsLinkedWithActiveRequest.contains(itm.Id) //&& UserInfo.getProfileId() != '00e90000001VWBb'
                ) { //Item linked with Active Request
                    itm.addError(Label.Library_Item_Linked_With_Active_Request);
                } else if(itm.Can_Be_Borrowed__c) { //Change to Can Be Borrow = true, update all related inventory to Available
                    if(relatedInvsMap.containsKey(itm.Id)) {
                        for(Library_Inventory__c li: relatedInvsMap.get(itm.Id)) {
                            //Check if the detail home location is filled i.e already in the warehouse
                            if(li.Detail_Home_Location__c != null) {
                                li.Lending_Status__c = Label.Library_Inventory_Lending_Status_available;
                            }
                            invsToUpdate.add(li);
                        }
                    }
                } else { //Change to Can Be Borrow = false, update all related inventory to Not Available
                    if(relatedInvsMap.containsKey(itm.Id)) {
                        for(Library_Inventory__c li: relatedInvsMap.get(itm.Id)) {
                            li.Lending_Status__c = Label.Library_Inventory_Lending_Status_unavailable;
                            invsToUpdate.add(li);
                        }
                    }
                }
            }
        }
        if(!invsToUpdate.isEmpty()) {
            SystemUtil.SafeUpdate(invsToUpdate);
        }
        
    }
}