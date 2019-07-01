/*
    LibraryItemRequestViewCtrl Class
    Used to handle redirection and customized buttons in Library Item Request View page
*/
public with sharing class LibraryItemRequestViewCtrl {
    
    public Boolean isSalesforceOne {get;set;}{isSalesforceOne = SystemUtil.isMobileDevice();}
    
    public Boolean isSubmitted {get;set;}
    
    public Boolean isEmptyCart {get;set;}
    
    public Boolean isRequireBrandCus {get;set;}
    
    public Boolean isBookOnly {get;set;}
    
    public Boolean isCancel {get;set;}
    
    String theId;

    public Request__c cart {get;set;}
    
    public String outputMsg{get;set;}
    
    public LibraryItemRequestViewCtrl() {    
    }
    
    public PageReference initial() {
        return null;
    }
    
    public PageReference onload() {
        return null;
    }
    
    public String selectedBrandCustomer{get;set;}
    
    public List<SelectOption> targetLocationSelectOptions {get;set;} { targetLocationSelectOptions = new List<SelectOption>(); }
    public String selectedTargetLocation {get;set;} { selectedTargetLocation = ''; }
    
    //return the list of select option for getting the picklist values from FLS
    public List<SelectOption> BrandCustomerList {
        get {
            List<SelectOption> listBrandCustomer = new List<SelectOption>();
            listBrandCustomer = LibraryCustomSelectionOptionUtil.getFabricSelectionOptionMapByValues().get(Label.FLS_prefix + Label.Library_brand_customer + Label.FLS_end);
            listBrandCustomer.add(new SelectOption('','--None--'));
            SelectOptionUtil.doSort(listBrandCustomer,SelectOptionUtil.FieldToSort.Label);
            return listBrandCustomer;
        }
        set;
    }
    
    //perform cancel action
    public PageReference cancelButton() {
        isCancel = true;
        String returnURL = Label.Library_JavaScriptName + LibraryUtil.jsNavSObject(theId);
        PageReference pr = new PageReference(returnURL);
        return pr;  
    }
    
    //constructor
    public LibraryItemRequestViewCtrl(ApexPages.StandardController controller) {
    
        this.theId = controller.getRecord().Id;
        isSubmitted = false;
        List<Request__c> carts = [SELECT Id, Status__c, Remarks__c, Target_Location__c, Brand_Customer__c FROM Request__c WHERE Id =: this.theId limit 1];
        if(!carts.isEmpty()) {
            this.cart = carts[0];
            isSubmitted = cart.Status__c ==Label.Library_Cart_Status_C;
        }
        if(!isSubmitted) {
            List<Library_Item_Request__c> reqs = [Select Id, Name From Library_Item_Request__c Where Bulk_Request__c =: this.theId limit 1];
            isEmptyCart = reqs.size()==0;
            
            if(!isEmptyCart) {
                List<Library_Item_Request__c> reqsNonBooks = [Select Id, Name From Library_Item_Request__c Where Bulk_Request__c =: this.theId And Item_Category__c !=: Label.Library_RecordType_Book limit 1];
                isBookOnly = reqsNonBooks.size()==0;
                if(!isBookOnly) {
                    List<Library_Item_Request__c> reqsBC = [Select Id, Name From Library_Item_Request__c Where Bulk_Request__c =: this.theId And (Item_Category__c =: Label.Library_RecordType_Fabric OR Item_Category__c =:Label.Library_Item_category_Samples_PD OR Item_Category__c =:Label.Library_Item_category_Samples_TGA) limit 1];
                    isRequireBrandCus = reqsBC.size()>0;
                }
            }
            
            isCancel = false;
        }
        
        for(Location__c l : [SELECT Id, Name FROM Location__c WHERE RecordType.DeveloperName = 'General_Location' ORDER BY Name]) {
            this.targetLocationSelectOptions.add(new SelectOption(l.Id, l.Name));
        }
    }
    
    //perform view library Cart
    public PageReference viewRequest() {
        PageReference pr = new PageReference('/');
       
        if(this.getLibraryCart() != null) {
            pr = new PageReference('/'+this.getLibraryCart());
        }

        return pr;
    }
    
    //Perform create new library request action
    public PageReference overrrideNewRequestAction() {
        //Check if the user has the permission to create a library request
        Schema.DescribeSObjectResult sobj = Library_Item_Request__c.sObjectType.getDescribe();
        String returnURL = '';
        if(sobj.isCreateable()) {          
            if(this.getLibraryCart() != null) {
                returnURL = '/'+this.getLibraryCart();
            }
        } else {
            returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_perform_action);
        }
        PageReference pr = new PageReference(returnURL);
        return pr;
    }
    
    //messages
    public void outputMessage(String s) {
        ApexPages.Message msNoItemsFound = new ApexPages.Message(ApexPages.Severity.INFO, s);
                ApexPages.addMessage(msNoItemsFound);
    }    
    
    /*
        Nick Wu 15 Apr 2015
        validate the initial checkin inventory item whether is still in the process and not allow to change their location info
    */
    public boolean validateInventories(String[] inventoryIds){
        boolean b = true;
        list<Library_Item_Request__c> reqList = [
            select Library_Request_Inventory__c from Library_Item_Request__c where Library_Request_Inventory__c in: inventoryIds 
            AND (  status__c =: Label.Library_Request_Status_Reserved 
                OR status__c =: Label.Library_Request_Status_Inbound 
                OR status__c =: Label.Library_Request_Status_Outbound
                OR status__c =: Label.Library_Request_Status_PendingApproval
                OR status__c =: Label.Library_Request_Status_Arrived
                OR status__c =: Label.Library_Request_Status_Borrowed )
        ];
        
        if(!reqList.isEmpty()){
            b = false;
        }
        return b;
    }
    
    //Perform scan handling actions in Library QR Scan page
    public PageReference bulkActions() {
        String action = ApexPages.currentPage().getParameters().get(Label.Library_actionType);
        String multiLibItemId = ApexPages.currentPage().getParameters().get(Label.Library_multiLibItemId);
        String redirect = ApexPages.currentPage().getParameters().get(Label.Library_redirect);
        String locationId = ApexPages.currentPage().getParameters().get(Label.Library_locationId);
        
        String[] inventoryIds = multiLibItemId.split(';');
        
        boolean someRecordsNotProcessed = false;
        boolean isDetailLocation = false;
        
        if(action == Label.Library_checkout || action == Label.Library_bookcheckout) {
            List<Library_Item_Request__c> reqsTocheckout = new List<Library_Item_Request__c>(); 
            
            for(Library_Item_Request__c lir : [SELECT Id, Status__c FROM LIbrary_Item_Request__c 
                                               WHERE Status__c =:Label.Library_Request_Status_Reserved 
                                               AND Library_Request_Inventory__c IN: inventoryIds] ) {
                if(action == Label.Library_bookcheckout)
                    lir.Status__c = Label.Library_Request_Status_Borrowed;
                else if(action == Label.Library_checkout)
                    lir.Status__c = Label.Library_Request_Status_Outbound;   
                reqstoCheckout.add(lir);
            }
            
            if(!reqstoCheckout.isEmpty()){
                SystemUtil.SafeUpdate(reqsTocheckout);
            }
            if(reqsToCheckout.size() != inventoryIds.size()) {
                someRecordsNotProcessed = true;
            }
            System.debug('=================AAA===');
        } else if (action == Label.Library_checkin) { //Added 2014-12-16 for inital checkin
            Map<Id, String> mapProfile = new Map<Id, String>();
            for(Profile p: [SELECT Name, Id FROM Profile 
                            WHERE Name =: Label.Library_Profile_TFEBA OR
                                  Name =: Label.Library_Profile_SA]) {
                mapProfile.put(p.Id, P.Name);
            }
            
            List<Library_Inventory__c> libInventory = new List<Library_Inventory__c>();            
            
            // Get the Parent Location
            List<Location__c> theLocation = [
                                            SELECT id, name, Parent_Location__c, RecordType.Name FROM Location__c WHERE 
                                            RecordType.Name =:Label.Location_RecordType_DetailLocation and Id = :locationId
                                            ];
            
            for(Library_Inventory__c li : [SELECT Id,Item_Category__c, Detail_Current_Location__c, Detail_Home_Location__c, Target_Address__c, Original_Address__c, Lending_Status__c FROM Library_Inventory__c WHERE ID IN: inventoryIds]) {
                
                if(li.Item_Category__c==Label.Library_RecordType_Book && !mapProfile.containsKey(UserInfo.getProfileId())){
                    String returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_bookAdmin_initialCheckIn);
                    returnURL +=historyBack();
                    return new PageReference(returnURL);
                }
                
                if(!ErrorUtils.isEmpty(theLocation)) {
                    //check the input location whether aligned with the inventory home location
                    if(theLocation[0].RecordType.Name ==Label.Location_RecordType_DetailLocation && theLocation[0].Parent_Location__c == li.Original_Address__c ) {
                        li.Detail_Current_Location__c = locationId;  
                        //Update Home Location for first time check in
                        //if(li.Detail_Home_Location__c == null) {
                        li.Detail_Home_Location__c = locationId;
                        //}
                        li.Target_Address__c = theLocation[0].Parent_Location__c;
                    }else{
                        isDetailLocation = true;
                        String returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_LocationNotAligned);
                        returnURL +=historyBack();
                        return new PageReference(returnURL);
                    }
                }
                //Update Status                
                li.Lending_Status__c = Label.Library_Inventory_Lending_Status_available;
                libInventory.add(li);
            }
            
            //if invalid then return error
            if(!validateInventories(inventoryIds)){
                ErrorUtils.outputInfoMessage(Label.Library_not_allowed_Initial);
                return null;
            }
            
            if(!libInventory.isEmpty()){
                SystemUtil.SafeUpdate(libInventory);
            }
            
        } else if (action == Label.Library_Return || action == Label.Library_returnbook) {
            
            List<Library_Item_Request__c> reqsTocheckout = new List<Library_Item_Request__c>(); 
            List<String> libInvIds = new List<String>();
            List<Library_Inventory__c> libInventory = new List<Library_Inventory__c>();
 
            if(action == Label.Library_Return){
                for(Library_Item_Request__c lir : [SELECT Id, Status__c, Library_Request_Inventory__c  FROM LIbrary_Item_Request__c 
                                                   WHERE 
                                                   ((Status__c =:Label.Library_Request_Status_Inbound AND Item_Category__c <>: Label.Library_Item_category_Burberry) OR
                                                   (Status__c =:Label.Library_Request_Status_Borrowed AND Item_Category__c = :Label.Library_Item_category_Burberry)) AND 
                                                    Library_Request_Inventory__c IN: inventoryIds] ) {
                    
                    lir.Status__c = Label.Library_Request_Status_Returned;
                    if(lir.Library_Request_Inventory__c != null) {
                        libInvIds.add(lir.Library_Request_Inventory__c);
                    }
                    reqstoCheckout.add(lir);
                }
            }else{
                for(Library_Item_Request__c lir : [SELECT Id, Status__c, Library_Request_Inventory__c FROM LIbrary_Item_Request__c WHERE Status__c =: Label.Library_Request_Status_Borrowed AND Library_Request_Inventory__c IN: inventoryIds] ) {
                    lir.Status__c = Label.Library_Request_Status_Returned;
                    if(lir.Library_Request_Inventory__c != null) {
                        libInvIds.add(lir.Library_Request_Inventory__c);
                    }
                    reqstoCheckout.add(lir);
                }
            }
            
            // Get the Parent Location
            List<Location__c> theLocation = [
                                            SELECT id, name, Parent_Location__c, RecordType.Name FROM Location__c WHERE 
                                            RecordType.Name = :Label.Location_RecordType_DetailLocation and Id = :locationId
                                            ];
            
            for(Library_Inventory__c li : [SELECT Id, Detail_Current_Location__c, Original_Address__c, Target_Address__c , Lending_Status__c  FROM Library_Inventory__c WHERE ID IN: libInvIds]) {

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
                        String returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_LocationNotAligned);
                        
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
            
        } else if (action == Label.Library_received) {
            
            Map<Id, String> mapProfile = new Map<Id, String>();
            for(Profile p: [SELECT Name, Id FROM Profile 
                            WHERE Name =: Label.Library_Profile_SA]) {
                mapProfile.put(p.Id, P.Name);
            }
            
            List<Library_Item_Request__c> reqsTocheckout = new List<Library_Item_Request__c>(); 
            
            for(Library_Item_Request__c lir : [SELECT Id, Status__c, Item_Category__c, OwnerId FROM LIbrary_Item_Request__c 
                                               WHERE 
                                               ((Status__c =:Label.Library_Request_Status_Arrived AND Item_Category__c <>:Label.Library_Item_category_Burberry) OR
                                                (Status__c =:Label.Library_Request_Status_Outbound AND Item_Category__c =:Label.Library_Item_category_Burberry)) AND 
                                               Library_Request_Inventory__c IN: inventoryIds] ) {
            
                if(isValidReceive(mapProfile, lir)){
                    lir.Status__c = Label.Library_Request_Status_Borrowed;   
                    reqstoCheckout.add(lir);
                }else{
                    ErrorUtils.outputInfoMessage(Label.Library_NotReqOwner);
                    return null;
                }
            }
            
            SystemUtil.SafeUpdate(reqsToCheckout);
            if(reqsToCheckout.size() != inventoryIds.size()) {
                someRecordsNotProcessed = true;
            }
        } else if (action == Label.Library_mail_out) {
            
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
            
            List<Library_Item_Request__c> reqsTocheckout = new List<Library_Item_Request__c>(); 
            
            for(Library_Item_Request__c lir : [SELECT Id, Status__c, Item_Category__c,  OwnerId FROM LIbrary_Item_Request__c WHERE Status__c = 'Outbound In-Transit' AND Library_Request_Inventory__c IN: inventoryIds] ) {
                if(isValidMailRoomCheckInOutbound(mapProfile, lir)){
                    lir.Status__c =Label.Library_Request_Status_Arrived;   
                    reqstoCheckout.add(lir);
                }else{
                    ErrorUtils.outputInfoMessage(Label.Library_errorInProcess);
                    return null;
                }
            }
            
            SystemUtil.SafeUpdate(reqsToCheckout);
            if(reqsToCheckout.size() != inventoryIds.size()) {
                someRecordsNotProcessed = true;
            }
        } else if (action ==Label.Library_mail_in) {
            
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
            
            List<Library_Item_Request__c> reqsTocheckout = new List<Library_Item_Request__c>(); 
            
            for(Library_Item_Request__c lir : [SELECT Id, Status__c, Item_Category__c,  OwnerId FROM LIbrary_Item_Request__c WHERE Status__c =:Label.Library_Request_Status_Borrowed AND Library_Request_Inventory__c IN: inventoryIds] ) {
                if(isValidMailRoomCheckInInbound(mapProfile, lir)){
                    lir.Status__c = Label.Library_Request_Status_Inbound;
                    reqstoCheckout.add(lir);
                }else{
                    ErrorUtils.outputInfoMessage(Label.Library_errorInProcess);
                    return null;
                }
            }
            
            SystemUtil.SafeUpdate(reqsToCheckout);
            if(reqsToCheckout.size() != inventoryIds.size()) {
                someRecordsNotProcessed = true;
            }
        }
        if(someRecordsNotProcessed) {
            ErrorUtils.outputInfoMessage(Label.Library_errorInProcess);
            return null;
        } else {
        
            return new PageReference('/' + redirect);
        }
    }
    
    //return js back
    public String historyBack(){
        String returnURL=LibraryUtil.jsBack();
        return returnURL;
    }
    
    //check if valid warehouse checkin action
    /*public boolean isValidWarehouseCheckIn(Map<Id, String> mapProfile, Library_Item_Request__c libItemReq){
        Boolean b = false;
        if(mapProfile.containsKey(UserInfo.getProfileId())) {

            if( (mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEPA && mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBAA && mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEFA) || 
                (mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEPA && libItemReq.Item_Category__c == Label.Library_Item_category_Samples_PD) ||
                (mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEFA && libItemReq.Item_Category__c == Label.Library_RecordType_Fabric) ||
                (mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEBAA && libItemReq.Item_Category__c == Label.Library_Item_category_Burberry) ||
                (libItemReq.Item_Category__c == Label.Library_RecordType_Book)) {
                //Check Request Status
                if(libItemReq.Status__c == Label.Library_Request_Status_Inbound 
                    || (libItemReq.Status__c == Label.Library_Request_Status_Borrowed && libItemReq.Item_Category__c == Label.Library_RecordType_Book)
                    || (libItemReq.Status__c == Label.Library_Request_Status_Borrowed && libItemReq.Item_Category__c == Label.Library_Item_category_Burberry)) {
                        b= true;
                }
            }
        }
        return b;
    }*/
    
    //check if valid receive action
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
    
    //check if valid mailing room outbound checkin action
    public boolean isValidMailRoomCheckInOutbound(Map<Id, String> mapProfile, Library_Item_Request__c libItemReq){
        Boolean b = false;
        if(mapProfile.containsKey(UserInfo.getProfileId())) {

            if( (mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEPA && mapProfile.get(UserInfo.getProfileId()) != Label.Library_Profile_TFEBAA) || 
                (mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEPA && libItemReq.Item_Category__c == Label.Library_Item_category_Samples_PD) ||
                (mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEBAA && libItemReq.Item_Category__c == Label.Library_Item_category_Burberry) ||
                (mapProfile.get(UserInfo.getProfileId()) == Label.Library_Profile_TFEWA && libItemReq.Item_Category__c == Label.Library_Item_category_Warehouse)
                ) {
                //Check Request Status
                if(libItemReq.Status__c == Label.Library_Request_Status_Outbound){
                    b= true;
                }
            }
        }
        return b;
    }
    
    //check if valid mailing room inbound checkin action
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
    
    //return default HKO location id for book items
    public String defaultLocation(){
        String str = '';
        str = [Select Id, Name from Location__c where Name =:Label.Location_HKO limit 1][0].id;
        return str;
    }

    /*
        Modified by Nick
        when multiLibItemId, there is no checking for its already added or not
        
        Perform add the selected items to library Cart
    */
    public PageReference addToLibraryCart() {
        String returnURL = '';
        String libItemId = ApexPages.currentPage().getParameters().get(Label.Library_libItemId);
        String multiLibItemId = ApexPages.currentPage().getParameters().get(Label.Library_multiLibItemId);
        String multiInventoryId = ApexPages.currentPage().getParameters().get(Label.Library_barcode);
        
        Id libraryCart = this.getLibraryCart();
        
        String bookStr ='';
        bookStr = ApexPages.currentPage().getParameters().get(Label.Library_RecordType_Book);
         
        
        //Check if the user has the permission to create a library request
        Schema.DescribeSObjectResult sobj = Library_Item_Request__c.sObjectType.getDescribe();
        if(sobj.isCreateable()) {
            
            //For Book only
            if(bookStr==Label.Library_RecordType_Book) {
                Request__c cartObj;
                cartObj = getLibraryCartObj();
                                
                //Check if the user has the permission to create a library request
                if(sobj.isCreateable()) { 
                    List<Library_Item_Request__c> reqLists = new List<Library_Item_Request__c>();
                    reqLists = [SELECT Id, Status__c, Request_Remarks__c, Target_Location__c, Library_Item__r.Require_Approval__c, OwnerId, Library_Item_Owner__c, Item_Category__c 
                                FROM Library_Item_Request__c WHERE Item_Category__c=:Label.Library_RecordType_Book AND Bulk_Request__c = :libraryCart];
                    
                    if(reqLists.isEmpty()){
                        returnURL = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_OnlyBooks)+ LibraryUtil.jsNavSObject(libraryCart);
                        
                        PageReference pr = new PageReference(returnURL);
                        return pr;
                    }
                      
                    List<User> usrs = [Select Id, Library_Is_Blacklisted__c From User Where Id = :UserInfo.getUserId() limit 1];
                    if(!usrs[0].Library_Is_Blacklisted__c) {
                        String btnSuccessMessage = Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_Success_Msg);       
                        
                        List<Library_Item_Request__c> lirList = new List<Library_Item_Request__c>();
                        
                         for(Library_Item_Request__c lir : reqLists) { 
                            
                            //Check if approval process is required for the item or if the requester is also the item owner
                            if(lir.Status__c ==Label.Library_Request_Status_Not_Submitted) 
                                lir.Status__c = Label.Library_Request_Status_Reserved;
                            lir.Request_Remarks__c = '';
                            lir.Target_Location__c = defaultLocation();
                                                        
                            lirList.add(lir);
                        }
                        
                        if(!lirList.isEmpty()) {
                            try {
                                cartObj.Status__c = Label.Library_Cart_Status_C;
                                SystemUtil.SafeUpdate(cartObj);        
                                SystemUtil.SafeUpdate(lirList);
                                returnURL += btnSuccessMessage;
                                outputMsg = Label.Library_Success_Msg;
                            }
                            catch(DmlException ex) {
                                returnURL += Label.Library_JavaScriptName + LibraryUtil.jsAlert(ex.getDmlMessage(0)); 
                                outputMsg =ex.getDmlMessage(0) ;
                            }
                        } else {
                            returnURL += Label.Library_JavaScriptName + LibraryUtil.jsAlert(Label.Library_NoItemsInAddInCart);
                            outputMsg = Label.Library_NoItemsInAddInCart;
                        }
                        
                    } else {
                        returnURL = Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_Msg_OverDue);
                        outputMsg =Label.Library_Msg_OverDue;
                    }
                } else {
                    returnURL = Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_not_allowed_submitCart);
                    outputMsg = Label.Library_not_allowed_submitCart;
                }
                returnURL += LibraryUtil.jsNavSObject(libraryCart);
                PageReference pr = new PageReference(returnURL);
                return pr;
            }   
        
            if(libItemId != null && libraryCart != null) {
                //Check if it was already added:
                List<Library_Item_Request__c> existingLir = [SELECT Id FROM LIbrary_Item_Request__c 
                                                             WHERE Status__c = :Label.Library_Request_Status_Not_Submitted AND Library_Item__c = :libItemId 
                                                             AND Bulk_Request__c = :this.getLibraryCart()];
                                                             
                if(existingLir == null || existingLir.isEmpty()) {
                    
                    Library_Item_Request__c lir = new Library_Item_Request__c(Status__c =Label.Library_Request_Status_Not_Submitted, Library_Item__c = libItemId, Bulk_Request__c = this.getLibraryCart());
                    
                    boolean exceptionOccured = false;
                    
                    try {
                        insert lir;
                    } catch (Exception e) {
                        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                            returnURL += Label.Library_JavaScriptName +LibraryUtil.jsAlert(e.getMessage()); 
                            returnURL += LibraryUtil.jsNavSObject(libraryCart);
                            exceptionOccured = true;
                        } else {
                            SystemUtil.handleException(e);
                        }
                    }
                    
                    if(!exceptionOccured) {
                        returnURL += Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_Add_To_Cart); 
                        returnURL += LibraryUtil.jsNavSObject(libraryCart);
                    }
                    
                }else{
                    returnURL += Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_MSG_Aready_In_Cart); 
                    returnURL += LibraryUtil.jsNavSObject(libraryCart);
                    
                }
            } else if(multiLibItemId != null && libraryCart != null && multiInventoryId != null) { 
                
                String[] libItemIds = multiLibItemId.split(';');
                String[] inventoryIds = multiInventoryId.split(',');
                
                if(libItemIds != null && !libItemIds.isEmpty()) {
                    //Check if it was already added:
                    List<Library_Item_Request__c> existingLir = [SELECT Id, Library_Item__c FROM LIbrary_Item_Request__c WHERE Status__c =:Label.Library_Request_Status_Not_Submitted
                                                                  AND Library_Item__c IN :libItemIds AND Bulk_Request__c = :this.getLibraryCart()];
                    
                    
                    if(existingLir == null || existingLir.isEmpty()) {
                        
                        Map<String, Library_Item_Request__c> existingMap = new Map<String, Library_Item_Request__c>();
                        
                        for(Library_Item_Request__c lir : existingLir){
                            if(!existingMap.containsKey(lir.Library_Item__c))
                                existingMap.put(lir.Library_Item__c, lir);
                        }
                        
                        List<Library_Item_Request__c> lirToInsert = new List<Library_Item_Request__c>();
                        for(Integer i=0;i<libItemIds.size();i++){
                            if(!existingMap.containsKey(libItemIds[i])){
                                // nick wu add Inventory_reserved__c
                                Library_Item_Request__c lir = new Library_Item_Request__c(Status__c =Label.Library_Request_Status_Not_Submitted, Inventory_reserved__c =inventoryIds[i],  Library_Item__c = libItemIds[i], Bulk_Request__c = libraryCart);
                                lirToInsert.add(lir);
                            }
                        }
                        
                        boolean exceptionOccured = false;
                        try {
                            insert lirToInsert;
                            
                        } catch (Exception e) {
                            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                                returnURL += Label.Library_JavaScriptName +LibraryUtil.jsAlert(e.getMessage()); 
                                returnURL += LibraryUtil.jsNavSObject(libraryCart);
                                exceptionOccured = true;
                            } else {
                                SystemUtil.handleException(e);
                            }
                        }
                        
                        if(!exceptionOccured) {
                            returnURL += Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_Add_To_Cart);
                       
                            if(returnURL == '') {
                                returnURL = Label.Library_JavaScriptName;
                            }
                            returnURL += LibraryUtil.jsNavSObject(libraryCart);
                        }

                    } else {
                        returnURL += Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_MSG_Aready_In_Cart);
                        returnURL += LibraryUtil.jsNavSObject(libraryCart);
                        
                    }
                }            
            }        
        } else {
            returnURL = Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_perform_action);
            returnURL += LibraryUtil.jsNavSObject(libItemId);
        }
        if(returnURL == '') {
            returnURL = Label.Library_JavaScriptName + LibraryUtil.jsNavSObject(libItemId);
        }
        
        PageReference pr = new PageReference(returnURL);
        pr.setRedirect(true);
        return pr;
    }
    
    //if my Cart still open, then use the existing one, else create a new cart to store the item requests
    public Id getLibraryCart() {
        List<RecordType> libRequestRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Request__c' AND DeveloperName = :Label.Library_Request];
        List<Request__c> myLibraryRequest = [ SELECT Id FROM Request__c WHERE RecordTypeId = :libRequestRecordType[0].Id AND OwnerId = :UserInfo.getUserId() AND Status__c =:Label.Library_Cart_Status_O];
        
        if(myLibraryRequest != null && !myLibraryRequest.isEmpty()) {
            return myLibraryRequest[0].Id;
        } else {
            Request__c r = new Request__c(RecordTypeId = libRequestRecordType[0].Id, Status__c = Label.Library_Cart_Status_O, Brand_Customer__c = null);
            SystemUtil.SafeInsert(r);
            return r.Id;
        }
    }
    
    //get the library Cart object, if null create a new
    public Request__c getLibraryCartObj(){
        List<RecordType> libRequestRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Request__c' AND DeveloperName = :Label.Library_Request];
        List<Request__c> myLibraryRequest = [ SELECT Id, Status__c FROM Request__c WHERE RecordTypeId = :libRequestRecordType[0].Id AND OwnerId = :UserInfo.getUserId() AND Status__c =:Label.Library_Cart_Status_O];
        
        if(myLibraryRequest != null && !myLibraryRequest.isEmpty()) {
            return myLibraryRequest[0];
        } else {
            Request__c r = new Request__c(RecordTypeId = libRequestRecordType[0].Id, Status__c = Label.Library_Cart_Status_O, Brand_Customer__c = null);
            SystemUtil.SafeInsert(r);
            return r;
        }
    }
    
    public boolean ValidBrandCustomer(){
        boolean b = false;
        if(selectedBrandCustomer!=''){
            b = true;
        }
        return b;
    }
    
    //Perform submit library Cart action
    public PageReference submitCart() {
        
        String returnURL = '';
        Boolean hasError = false;
        
        if (this.isRequireBrandCus == true && String.isEmpty(this.selectedBrandCustomer)) {
            errorPageMsg(String.format('{0} is required', new String[] { Library_Item_Request__c.Brand_Customer_For_Fabric__c.getDescribe().getLabel() }));
            hasError = true;
        }
        
        if (hasError)
            return null;
        
        //Check if the user has the permission to create a library request
        Schema.DescribeSObjectResult sobj = Library_Item_Request__c.sObjectType.getDescribe();
        
        if(sobj.isCreateable()) { 
            if(this.isSalesforceOne && this.selectedTargetLocation != null && this.selectedTargetLocation != '') {
                this.cart.Target_Location__c = this.selectedTargetLocation;
            }
            
            List<Library_Item_Request__c> reqLists = new List<Library_Item_Request__c>();
            List<Library_Inventory__c> invList = new List<Library_Inventory__c>();
            
            Map<String, Library_Inventory__c> invMap = new Map<String,Library_Inventory__c>(
            [Select id, lending_status__c from Library_Inventory__c where Id IN (Select Inventory_reserved__c from Library_Item_Request__c where  Bulk_Request__c = :theId)]);
            
            reqLists = [SELECT Id, Status__c, Request_Remarks__c, Target_Location__c, Library_Item__r.Require_Approval__c, OwnerId, Library_Item_Owner__c, Item_Category__c, 
                        Inventory_reserved__c,Inventory_reserved__r.Lending_Status__c, Library_Request_Inventory__c
                        FROM Library_Item_Request__c WHERE Bulk_Request__c = :theId];
            List<User> usrs = [Select Id, Library_Is_Blacklisted__c From User Where Id = :UserInfo.getUserId() limit 1];
            
            String btnSuccessMessage = Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_Success_Msg);
        
            List<Library_Item_Request__c> lirList = new List<Library_Item_Request__c>();
            
            for(Library_Item_Request__c lir : reqLists) { 
                
                if(lir.Item_Category__c == Label.Library_RecordType_Book && cart.Target_Location__c != defaultLocation()){
                    returnURL = Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_HKOForBookItem);
                    
                    PageReference pr = new PageReference(returnURL);
                    return pr;
                }
                
                /*
                    Nick Wu
                    Blacklist logic
                    1. not in blacklist
                    2. if in blacklist, item owner must same as current user
                */
                if(!usrs[0].Library_Is_Blacklisted__c || 
                   (usrs[0].Library_Is_Blacklisted__c && UserInfo.getUserId().left(15) == lir.Library_Item_Owner__c )) {
                        
                        cart.Brand_Customer__c = selectedBrandCustomer; //add by Jo fung
                    //Check if approval process is required for the item or if the requester is also the item owner
                    if(lir.Library_Item__r.Require_Approval__c && lir.OwnerId != lir.Library_Item_Owner__c) {
                        lir.Status__c = Label.Library_Request_Status_PendingApproval;
                        if(selectedBrandCustomer!=null  && (lir.Item_Category__c == Label.Library_RecordType_Fabric || lir.Item_Category__c == Label.Library_Item_category_Samples_PD || lir.Item_Category__c == Label.Library_Item_category_Samples_TGA)) {
                            cart.Brand_Customer__c = selectedBrandCustomer;
                            lir.Brand_Customer_For_Fabric__c = selectedBrandCustomer;
                        }
                    } else {
                        lir.Status__c = Label.Library_Request_Status_Reserved;
                    }
                    
                    lir.Request_Remarks__c = cart.Remarks__c;
                    lir.Target_Location__c = cart.Target_Location__c;
                    lir.Brand_Customer_For_Fabric__c = cart.Brand_Customer__c; //add by Jo fung
                    
                    //added by nicwu for linking inventory id with request
                    if(lir.Inventory_reserved__c!=null && invMap!=null){
                        if(invMap.containsKey(lir.Inventory_reserved__c) && 
                           invMap.get(lir.Inventory_reserved__c).lending_status__c == Label.Library_Inventory_Lending_Status_available ){
                            
                            lir.Library_Request_Inventory__c = lir.Inventory_reserved__c;
                            Library_Inventory__c li = invMap.get(lir.Library_Request_Inventory__c);
                            li.lending_status__c =Label.Library_Inventory_Lending_Status_unavailable;
                            //li.Target_Address__c = cart.Target_Location__c;
                            invList.add(li);
                        }
                    }
                    
                    lirList.add(lir);
                } else {
                    returnURL = Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_Msg_OverDue);
                    outputMsg = Label.Library_Msg_OverDue;
                    PageReference pr = new PageReference(returnURL);
                    return pr;
                }
            }
            
            if(!lirList.isEmpty()) {
                try {
                    cart.Status__c = Label.Library_Cart_Status_C;
                    SystemUtil.SafeUpdate(cart);        
                    SystemUtil.SafeUpdate(lirList);
                    //added by nicwu
                    SystemUtil.SafeUpdate(invList);
                    returnURL += btnSuccessMessage;
                    outputMsg = Label.Library_Success_Msg;
                }
                catch(DmlException ex) {
                    returnURL += Label.Library_JavaScriptName +LibraryUtil.jsAlert(ex.getDmlMessage(0));
                    outputMsg =ex.getDmlMessage(0) ;
                }
            } else {
                returnURL += Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_NoItemsInAddInCart);
                outputMsg = Label.Library_NoItemsInAddInCart;
            }
        } else {
            returnURL = Label.Library_JavaScriptName +LibraryUtil.jsAlert(Label.Library_not_allowed_submitCart); 
            outputMsg = Label.Library_not_allowed_submitCart;
        }
        Schema.DescribeSObjectResult dsr = library_Item_request__c.sObjectType.getDescribe();
        returnURL += LibraryUtil.jsNavURL(dsr.getKeyPrefix()+'/o');
        PageReference pr = new PageReference(returnURL);
        return pr;
    }
    
    private void errorPageMsg(String msg) {
        pageMsg(ApexPages.Severity.ERROR, msg);
    }
    
    private void pageMsg(ApexPages.Severity severity, String msg) {
        ApexPages.addMessage(new ApexPages.Message(severity, msg));
    }
}