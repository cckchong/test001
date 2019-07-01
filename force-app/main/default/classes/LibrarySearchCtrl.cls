/**
         * Controller for LibrarySearchVFPage
         * @author Andrew Ng, Wilson Gong, Nick Wu
         * @date 01/09/2014
         */
        public with sharing class LibrarySearchCtrl {
            
            public String QRCodeNumber {get;set;}
            /** Object Binded to Web Form */
            public Boolean FMP{get;set;}//add by dtt
            public SearchSObjectWrapper sow {get;set;}
            public SearchSObjectWrapper libInvSow {get;set;}
                
            /** The Record Type of Library Item selected */     
            public String selectedRecordType {get;set;} {
                // if(selectedRecordType!=null && selectedRecordType==Label.Library_RecordType_Book_Label) {
                //     selectedRecordType=Label.Library_RecordType_Book;
                // }
            }

            /** Result Set from Searching */
            public List<Library_Item__c> searchResults {get;set;}
                
            /** Number of thangs in my Library Cart */
            public Integer libraryCartItemCount {get;set;}
            public String libraryCartId {get;set;}
            
            /** Just to keep track of Record Type Names to Ids */
            public Map<String, String> recordTypeNametoId {get;set;} { recordTypeNametoId = new Map<String, String>(); }
            
            /** FIXME: Use the interface */
            public LibrarySourceFabricRepository libSourceFabricRepo {get;set;} { libSourceFabricRepo = new LibrarySourceFabricRepository(); }
            /** FIXME:  Use the interface */
            public LibrarySourceLocalRepository libSourceLocalRepo {get;set;} { libSourceLocalRepo = new LibrarySourceLocalRepository(); }
            
            /** The selection values for Fabric */
            private transient Map<String, List<SelectOption>> fabricSelectionMap = new Map<String, List<SelectOption>>();
            private transient Map<String, List<SelectOption>> sampleFabricSelectionMap = new Map<String, List<SelectOption>>();
            
            public boolean isMobile;
            public boolean isSalesforceOne {get;set;} {isSalesforceOne = SystemUtil.isMobileDevice();}
            public Integer pageSectionColumns {get;set;}
            public boolean isShowRecentAddedBooks {get;set;} {isShowRecentAddedBooks = true;}
            
            public static String addedMsg {get;set;}
            public static String existedMsg {get;set;}
            public Map<Id, List<FabricInventoryVO>> libIdToFabricInventoryJson {get;set;} { libIdToFabricInventoryJson = new Map<Id, List<FabricInventoryVO>>(); }
            
            public List<SelectOption> availableRecordTypes {get;set;}
            
            //get the library Cart object id
            @RemoteAction
            public static String getLibraryCart() {
                String s = '';
                LibraryItemRequestViewCtrl reqView = new LibraryItemRequestViewCtrl();
                s = String.valueOf(reqView.getLibraryCart());
                return s;
            }
            
            //get the number of request in the library Cart
            @RemoteAction
            public static Integer getLibraryCartNum() {
                Integer num=0;
                LibraryItemRequestViewCtrl ctr = new LibraryItemRequestViewCtrl();
                String reqId = ctr.getLibraryCart();
                
                if(reqId!=null && reqId!=''){
                    List<Library_Item_Request__c> libReqList = [SELECT Id FROM Library_Item_Request__c WHERE Bulk_Request__r.id =: reqId];
                    num = libReqList.size();
                }else{
                    num = 0;
                }
                return num;
            }
            
            //return whether is mobile environment
            public boolean getIsMobile() {
                return this.isMobile;
            }    
            
            //set is mobile environment
            public void setIsMobile(boolean isMobile) {
                this.isMobile = isMobile;
                if(isMobile) {
                        this.pageSectionColumns = 1;
                }
            }
            
            //return null
            public PageReference jsSetIsMobile() {
                return null;
            }
            
            //get library cart Id
            public Id getLibraryCartId() {
                List<RecordType> libRequestRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Request__c' AND DeveloperName = 'Library_Request'];
                List<Request__c> myLibraryRequest = [ SELECT Id FROM Request__c WHERE RecordTypeId = :libRequestRecordType[0].Id AND OwnerId = :UserInfo.getUserId() AND Status__c = 'O'];
                
                if(myLibraryRequest != null && !myLibraryRequest.isEmpty()) {
                    return myLibraryRequest[0].Id;
                } else {
                    return null;
                }
            }
            
            
            /*
                Added by NickWu 20141223
                To check login user whether is TGA user
            */
            public boolean isTGAUser{get;set;}{
                isTGAUser= false;
                String str = Label.Library_TGA;
                Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and name like :str limit 1]);
                isTGAUser= (pMap.size()>0) ? true:false;
            }
            
            /*
                Added by NickWu
                To check the current login user whether in Burberry achrive profile
            */
            public boolean isBurberryUser{get;set;}{
                isBurberryUser = false;
                String str = Label.Library_Check_BurberryUser;
                Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and name like :str limit 1]);
                isBurberryUser = (pMap.size()>0) ? true:false;
            }
            
            /*
                Added by AlanLau 20171031
                To check the current login user whether in Chico achrive profile
            */
            public boolean isChicoUser{get;set;}{
                isChicoUser = false;
                String str = Label.Library_Check_ChicoUser;
                Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and name like :str limit 1]);
                isChicoUser = (pMap.size()>0) ? true:false;
            }

            /*
                Added by NickWu
                To check the current login user whether in Admin profile
            */
            public boolean isAdmin{get;set;}{
                isAdmin = false;
                String str = Label.Library_Profile_SA;
                Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and (name =:str or name =:Label.Library_Profile_TFELA) limit 1]);
                isAdmin = (pMap.size()>0) ? true:false;
            }

            /*
                Added by NickWu
                To check the current login user whether in Admin profile
            */
            public boolean isWarehouseStandardUser{get;set;}{
                isWarehouseStandardUser = false;
                String str = Label.Library_Profile_TFEWSU;
                Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and name =:str limit 1]);
                isWarehouseStandardUser = (pMap.size()>0) ? true:false;
            }

                
            /**
             * Controller Constructor
             */
            public LibrarySearchCtrl() {
                /*
                    Modified by Nick Wu 29 Apr 2015
                    for disable book
                */
                        initAvailableRecordTypes();
                
                if(isBurberryUser || isAdmin){
                    this.selectedRecordType = Label.Library_RecordType_BurberryArchive_Label;
                }else if(isWarehouseStandardUser){
                    this.selectedRecordType = Label.Library_RecordType_Warehouse;
                }else if (isChicoUser) {
                    this.selectedRecordType = Label.Library_RecordType_ChicoArchive_Label;
                }else{
                    this.selectedRecordType = Label.Library_RecordType_Fabric;
                }

                this.searchResults = new List<Library_Item__c>();
                this.initLibraryCartItemCount();
                FMP=false;
                this.sow = new SearchSObjectWrapper('Library_Item__c');
                this.libInvSow = new SearchSObjectWrapper('Library_Inventory__c');
                this.isMobile = false;
                
                /*
                    NickWu Added to determine whether is mobile login
                */
                if(isSalesforceOne){
                    this.pageSectionColumns = 1;
                } else {
                    this.pageSectionColumns = 2;
                }
            }
            
            /**
             * Get the number of items in the Library
              */
            public void initLibraryCartItemCount() {
                this.libraryCartItemCount = 0;
                String reqId = getLibraryCartId();
                if(reqId!=null && reqId!=''){
                    List<Library_Item_Request__c> libReqList = [SELECT Id FROM Library_Item_Request__c WHERE Bulk_Request__r.id =: reqId];
                    this.libraryCartItemCount = libReqList.size();
                }else{
                    this.libraryCartItemCount = 0;
                }  
            }
           
            //get all field sets from the input ojbect name
            public List<Schema.FieldSetMember> getFieldSet(String sObjectName, Boolean bSampleFabric) { 
                if(selectedRecordType == Label.Library_select) {
                    return null;

                } else {
                    this.fabricSelectionMap = LibraryCustomSelectionOptionUtil.getFabricSelectionOptionMap();
                    this.sampleFabricSelectionMap = LibraryCustomSelectionOptionUtil.getFabricSelectionOptionMapByValues();
                    
                    Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectName);
                    Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
                    Schema.DescribeFieldResult fieldResult;
                    List<Schema.FieldSetMember> filterFields = new List<Schema.FieldSetMember>();
                    List<Schema.FieldSetMember> fieldSet = new List<Schema.FieldSetMember>();
                    ApexPages.Message msgFieldSetMissing = new ApexPages.Message(ApexPages.Severity.WARNING, Label.Library_MSG_NotConfig);
                    
                    if(sObjectName == 'Library_Item__c') {
                        
                        if(bSampleFabric) { //WG 20141222
                            if(Schema.SObjectType.Library_Item__c.fieldSets.getMap().get('SamplesFabric') != null) {
                                fieldSet = Schema.SObjectType.Library_Item__c.fieldSets.getMap().get('SamplesFabric').getFields();
                                
                            } else {
                                ApexPages.addMessage(msgFieldSetMissing);
                            }
                        } else {
                            if(Schema.SObjectType.Library_Item__c.fieldSets.getMap().get(selectedRecordType + 'FieldSet') != null) {
                                
                                /*
                                    Modified by NickWu 20141213
                                    TGA user should not be able to search with weight before dip/ material finishing/ release to sales
                                    
                                */
                                fieldSet = Schema.SObjectType.Library_Item__c.fieldSets.getMap().get(selectedRecordType + 'FieldSet').getFields();
                                    
                            } else {
                                ApexPages.addMessage(msgFieldSetMissing);
                            }
                        }
                            
                        
                    } else if(sObjectName == 'Library_Inventory__c') {
                        if(Schema.SObjectType.Library_Inventory__c.fieldSets.getMap().get(selectedRecordType + 'FieldSet') != null) {
                            fieldSet = Schema.SObjectType.Library_Inventory__c.fieldSets.getMap().get(selectedRecordType + 'FieldSet').getFields();
                        } else {
                            ApexPages.addMessage(msgFieldSetMissing);
                        }
                    }
                    
                    for(Schema.FieldSetMember fs : fieldSet) {
                        
                        //Add field level security checking
                        if(sObjResult.fields.getMap().get(fs.getFieldPath()).getDescribe().isAccessible()) {
                             
                            //Find out all non-formula fields
                            if(!sObjResult.fields.getMap().get(fs.getFieldPath()).getDescribe().isCalculated()) {
                                filterFields.add(fs);
                            }
                            
                            if(fs.getType() == DisplayType.Double) {
                                //Create a range for it
                                if(this.sow.numberWrapperMap.get(fs.getFieldPath()) == null) {
                                    this.sow.numberWrapperMap.put(fs.getFieldPath(), new LibraryNumberWrapper(0,0));
                                }
                                
                            } else if(fs.getType() == DisplayType.MultiPicklist || fs.getType() == DisplayType.Picklist) {
                                //fabric, samples PD, samples TGA
                                if(selectedRecordType == Label.Library_RecordType_Fabric ) {
                                    if(this.sow.multiSelectWrapperMap.get(fs.getFieldPath()) == null) {
                                        String fieldPath = fs.getFieldPath().toLowerCase();
                                            
                                        fieldPath = fieldPath.replace('fls_content_2__c', 'fls_content__c');
                                        fieldPath = fieldPath.replace('fls_content_3__c', 'fls_content__c');
                                            
                                        List<SelectOption> soList = this.fabricSelectionMap.get(fieldPath);
                                        
                                        /*Nick Wu added Sorting*/
                                        if(soList != null && soList.size()>0)
                                            SelectOptionUtil.doSortByFieldPath(soList,SelectOptionUtil.FieldToSort.Label, fieldPath);
                                        
                                        this.sow.multiSelectWrapperMap.put(fs.getFieldPath(), new MultiSelectWrapper(soList));
                                         
                                    }
                                 }else if((selectedRecordType == Label.Library_RecordType_SamplesPD &&
                                          (fs.getFieldPath().toLowerCase()=='Fls_Woven_Type__c' ||
                                           fs.getFieldPath().toLowerCase()=='Fls_Fabric_Finish__c' )) || 
                                        (selectedRecordType == Label.Library_RecordType_SamplesTGA && 
                                         
                                           fs.getFieldPath().toLowerCase()=='Fls_Fabric_Finish__c'
                                        )){
                                        
                                    String fieldPath = fs.getFieldPath().toLowerCase();
                                    List<SelectOption> soList = this.sampleFabricSelectionMap.get(fieldPath);
                                    /*Nick Wu added Sorting*/
                                    if(soList != null && soList.size()>0){
                                        SelectOptionUtil.doSortByFieldPath(soList,SelectOptionUtil.FieldToSort.Label, fieldPath);
                                    }
                                    this.sow.multiSelectWrapperMap.put(fs.getFieldPath(), new MultiSelectWrapper(soList));
                                    
                                }else {
                                    if(this.sow.multiSelectWrapperMap.get(fs.getFieldPath()) == null) {
                                            
                                        List<Schema.PicklistEntry> picklistValues = sObjResult.fields.getMap().get(fs.getFieldPath()).getDescribe().getPicklistValues();
                                        this.sow.multiSelectWrapperMap.put(fs.getFieldPath(), new MultiSelectWrapper(picklistValues));
                                    }
                                }
                                
                            } else if(fs.getType() == DisplayType.datetime) {
                                
                                /*
                                    Nick Wu 20141225
                                    To solve created date is ersed every Search
                                    Added if statement to check whether the LibraryDateWrapper obj is null, if yes, new it.
                                */                    
                                if(this.sow.dateWrapperMap.get(fs.getFieldPath()) == null)
                                    this.sow.dateWrapperMap.put(fs.getFieldPath(), new LibraryDateWrapper());
                                
                            }
                        }
                    }
                    return filterFields;
                }
            }
            

            //get library Item field set
            public List<Schema.FieldSetMember> getFieldSetMaster() {          
                    return getFieldSet('Library_Item__c', false);
            }
            
            //get library inventory field set
            public List<Schema.FieldSetMember> getFieldSetInventory() {           
                    return getFieldSet('Library_Inventory__c', false);
            }
            
            //WG 20141222
            //get library Item field set for sample fabric
            public List<Schema.FieldSetMember> getFieldSetSamplesFabric() { 
                    return getFieldSet('Library_Item__c', true);
            }
                
            //Retrieve FieldSet for Search Criteria
            public List<Schema.FieldSetMember> getFieldResultSet(String sObjectName) {
                    if(selectedRecordType == Label.Library_select) {
                            return null;
                    } else if(sObjectName == 'Library_Item__c') {
                            return Schema.SObjectType.Library_Item__c.fieldSets.getMap().get(selectedRecordType + 'FieldSet').getFields();
                
                    } else if(sObjectName == 'Library_Inventory__c') {
                            return Schema.SObjectType.Library_Inventory__c.fieldSets.getMap().get(selectedRecordType + 'FieldSet').getFields();
                
                    }
                    return null;
            }

            //Retrieve FieldSet for Search Results Columns
            public List<Schema.FieldSetMember> getFieldSearchResultSet() {
                if(selectedRecordType == Label.Library_select) {
                    return null;
                } else {
                    return Schema.SObjectType.Library_Item__c.fieldSets.getMap().get(selectedRecordType + 'ResultFieldSet').getFields();
                }

                return null;
            }
            
            //get the result of library Item field set 
            public List<Schema.FieldSetMember> getFieldResultSetMaster() {
                return getFieldResultSet('Library_Item__c');
            }
            
            //get the result of library inventory field set 
            public List<Schema.FieldSetMember> getFieldResultSetInventory() {
                return getFieldResultSet('Library_Inventory__c');
            }
            
            //return a new library Object with can be borrowed = true and master copy = true
            public Library_Item__c getLibraryItem() {
                Library_Item__c li = new Library_Item__c(Can_Be_Borrowed__c = true, Master_Copy__c = true);
                return li;
            }
            
            //return a new library inventory object
            public Library_Inventory__c getLibraryInventory() {
                Library_Inventory__c li = new Library_Inventory__c();
                return li;
            }
            
            //return a list of selection options for available record types
            
            public void initAvailableRecordTypes() {
                Schema.DescribeSObjectResult schemaResults = Library_Item__c.SObjectType.getDescribe();
                List<Schema.RecordTypeInfo> recordTypeInfos = schemaResults.getRecordTypeInfos();
                List<SelectOption> listRecordTypes = new List<SelectOption>();
                
                        /*
                Modified by Nick Wu 29 Apr 2015
                remove book from the available record types
                */
                for(Schema.RecordTypeInfo rti: recordTypeInfos) {
                    
                    if(rti.getName() != Label.Library_RecordType_Master && rti.getName() != Label.Library_RecordType_Book) {
                        String tempStr ='';
                        if(rti.getName() == Label.Library_RecordType_Book){
                            tempStr = Label.Library_RecordType_Book_Label;
                        }
                        
                        String recordTypeDeveloperName = rti.getName().replace(' ', '');
                        //List<Library_Item__c> itms = [Select Id, Name From Library_Item__c Where RecordType.DeveloperName = :recordTypeDeveloperName limit 1];
                        //if(itms.size()>0) {
                            /*
                            NickWu modified to disable the selected record type
                            */
                            if(rti.getName()==Label.Library_RecordType_Book){
                                //for fixing browser back issue
                                //this.selectedRecordType = Label.Library_RecordType_Book_Label;
                                if(this.selectedRecordType!='' && this.selectedRecordType !=recordTypeDeveloperName )                        
                                    listRecordTypes.add(new SelectOption(recordTypeDeveloperName, tempStr));
                                else{
                                    SelectOption so = new SelectOption(recordTypeDeveloperName, tempStr);
                                    so.setDisabled(true);
                                    listRecordTypes.add(so);
                                }
                            }else{
                                
                                if(this.selectedRecordType!='' && this.selectedRecordType !=recordTypeDeveloperName )                        
                                    listRecordTypes.add(new SelectOption(recordTypeDeveloperName, rti.getName()));
                                else{
                                    SelectOption so = new SelectOption(recordTypeDeveloperName, rti.getName());
                                    so.setDisabled(true);
                                    listRecordTypes.add(so);
                                }
                            }
                        //}
                        recordTypeNametoId.put(recordTypeDeveloperName, rti.getRecordTypeId());
                    }
                }
                
                this.availableRecordTypes = listRecordTypes;

            }
            
            /*
                Added by nickwu 20141223
                reset all filters
            */
            public void resetFilters(){
                this.searchResults.clear();
                this.sow = new SearchSObjectWrapper('Library_Item__c');
                this.libInvSow = new SearchSObjectWrapper('Library_Inventory__c');
                this.sow.obj.put('RecordTypeId', recordTypeNametoId.get(this.selectedRecordType));
                this.libSourceLocalRepo = new LibrarySourceLocalRepository();
                inventoryForFabricItem ='';
                QRCodeNumber='';
            }
            
            //Perform reset all filters
            public PageReference clearFilters() {

                resetFilters();
                return null;
            }
            
            //add new field in the list
            private List<String> selectFields {
                get {
                    List<String> resultFieldList = new List<String>();
                    resultFieldList.add('Tech_Selected__c');
                    
                    for(Schema.FieldSetMember f : this.getFieldSearchResultSet()) 
                    {
                        resultFieldList.add(f.getFieldPath());
                    }
                    return resultFieldList;
                
                        }
                set;
            }
            
            public String inventoryForFabricItem{get;set;}
            
            //check if search fabric QR code number
            public Boolean isSearchInventoryItemsFabric(){
                boolean b = true;
                SObject sObjInventory = this.libInvSow.obj;
                List<Library_Item__c> itemList;
                
                if(QRCodeNumber!=null && QRCodeNumber!=''){
                    sObjInventory.put('Serial_Number__c',QRCodeNumber);
                    String libInvId = QRCodeNumber;
                    if(selectedRecordType ==Label.Library_RecordType_Fabric){   
                        if(libInvId!=null && libInvId!=''){
                            itemList = [select id, Fabric_ID__c from Library_Item__c where 
                            ID IN (select Library_Item_Master__c from Library_Inventory__c where serial_Number__c =: libInvId) limit 1
                            ];
                            
                            if(itemList!=null && !itemList.isEmpty()){
                                this.sow.obj.put('Fabric_ID__c',itemList[0].Fabric_ID__c);
                                inventoryForFabricItem = itemList[0].id;
                                b= true;
                            }else{
                                b= false;
                            }
                        }
                    }
                }
                return b;
            }
            
            //check if search other categories QR code number
            public Set<Id> searchInventoryItems() {
                SObject sObjInventory = this.libInvSow.obj;
                Set<Id> libraryMasterItems = new Set<Id>();
                
                if(QRCodeNumber!=null && QRCodeNumber!=''){
                    sObjInventory.put('Serial_Number__c',QRCodeNumber);
                }
                
                // Just do the Inventory Serial Number field
                if(sObjInventory.get('Serial_Number__c') != null && sObjInventory.get('Serial_Number__c') != '') {
                    
                    if(selectedRecordType!=Label.Library_RecordType_Fabric){
                        String libInvId = (String) sObjInventory.get('Serial_Number__c');
                        libInvId = '%' + libInvId + '%';
                        for(Library_Inventory__c lii : [SELECT Id, Library_Item_Master__c FROM Library_Inventory__c WHERE Serial_Number__c LIKE :libInvId]) {
                            libraryMasterItems.add(lii.Library_Item_Master__c);
                        }
                    }
                } else {
                    
                    return null;
                }
                
                return libraryMasterItems;
            }
            
            /*
             * @return Set of IDs if they exist, null if empty
             * 2014-12-22 Change fabric to Sobject
             */
            public Set<Id> searchFabricItems(String rt) {
                Set<Id> resultSet = new Set<Id>();        
                if(this.sow.fabric != null) {
                    String query = 'SELECT Id, Fabric__c, Sample__c FROM Sample_Fabric__c WHERE ';      
                         
                        List<String> conditions = new List<String>();
                        
                        
                        
                        /*
                            NickWu added condition for createddate searching for samplesTGA
                         */                 
                        if(this.sow.dateWrapperMap.get('CreatedDate') != null) {
                              
                              Date startDate = Date.valueOf(this.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c);
                              Date endDate = Date.valueOf(this.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_End_Date_Proxy__c);
                              
                           
                            if(startDate !=null & endDate!=null) {
                                                       
                                conditions.add('(Fabric__r.CreatedDate >= ' + Datetime.newInstance(startDate , Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+'T00:00:00Z'  );
                                conditions.add(' Fabric__r.CreatedDate <= ' + Datetime.newInstance(endDate , Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')+ 'T00:00:00Z)');
                            }
                        }
                        
                      
                        
                        if(this.sow.fabric.get('Sample_Fabric_ID_1__c') != null) {
                                conditions.add(' Fabric__r.Sample_Fabric_ID_1__c = \'' + this.sow.fabric.get('Sample_Fabric_ID_1__c') + '\' ');
                        }
                        if(this.sow.fabric.get('Color_ID_1__c') != null) {
                                conditions.add(' Fabric__r.Color_ID_1__c = \'' + this.sow.fabric.get('Color_ID_1__c') + '\' ');
                        }
                        if(this.sow.fabric.get('Fls_Content__c') != null) {
                                
                                List<String> orclause = new List<String>();
                                orclause.add('( Fabric__r.Fls_Content__c = \'' + this.sow.fabric.get('Fls_Content__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_2__c = \'' + this.sow.fabric.get('Fls_Content__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_3__c = \'' + this.sow.fabric.get('Fls_Content__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_4__c = \'' + this.sow.fabric.get('Fls_Content__c') + '\') ');
                                
                                conditions.add(
                                        String.format('{0}',
                                                new List<String>{ String.join(orclause, ' OR ') })
                                );
                                if(this.sow.numberWrapperMap.get('Content_Percent__c') != null) {

                                    LibraryNumberWrapper lnw = this.sow.numberWrapperMap.get('Content_Percent__c');
                                    Double min = lnw.min;
                                    Double max = lnw.max;
                                    
                                    if((min == null || min == 0) && (max != null && max != 0)) {
                                        conditions.add( ' Fabric__r.Content_Percent__c <= ' + max + ' ');
                                        
                                    } else if((min != null && min != 0) && (max == null || max == 0)) {
                                        conditions.add( ' Fabric__r.Content_Percent__c >= ' + min + ' ');
                                        
                                    } else if(min != null && max != null && min != 0 && max != 0) {
                                        conditions.add( ' Fabric__r.Content_Percent__c >= ' + min + ' ');
                                        conditions.add( ' Fabric__r.Content_Percent__c <= ' + max + ' ');
                                    }
                                }
                        }
                        if(this.sow.fabric.get('Fls_Content_2__c') != null) {
                                List<String> orclause = new List<String>();
                                orclause.add('( Fabric__r.Fls_Content__c = \'' + this.sow.fabric.get('Fls_Content_2__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_2__c = \'' + this.sow.fabric.get('Fls_Content_2__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_3__c = \'' + this.sow.fabric.get('Fls_Content_2__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_4__c = \'' + this.sow.fabric.get('Fls_Content_2__c') + '\') ');
                                
                                conditions.add(
                                        String.format('{0}',
                                                new List<String>{ String.join(orclause, ' OR ') }));

                                if(this.sow.numberWrapperMap.get('Content_Percent_2__c') != null) {

                                    LibraryNumberWrapper lnw = this.sow.numberWrapperMap.get('Content_Percent_2__c');
                                    Double min = lnw.min;
                                    Double max = lnw.max;

                                    if((min == null || min == 0) && (max != null && max != 0)) {
                                        conditions.add( ' Fabric__r.Content_Percent_2__c <= ' + max + ' ');
                                        
                                    } else if((min != null && min != 0) && (max == null || max == 0)) {
                                        conditions.add( ' Fabric__r.Content_Percent_2__c >= ' + min + ' ');
                                        
                                    } else if(min != null && max != null && min != 0 && max != 0) {
                                        conditions.add( ' Fabric__r.Content_Percent_2__c >= ' + min + ' ');
                                        conditions.add( ' Fabric__r.Content_Percent_2__c <= ' + max + ' ');
                                    }
                                }
                        }
                        if(this.sow.fabric.get('Fls_Content_3__c') != null) {
                                List<String> orclause = new List<String>();
                                orclause.add('( Fabric__r.Fls_Content__c = \'' + this.sow.fabric.get('Fls_Content_3__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_2__c = \'' + this.sow.fabric.get('Fls_Content_3__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_3__c = \'' + this.sow.fabric.get('Fls_Content_3__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_4__c = \'' + this.sow.fabric.get('Fls_Content_3__c') + '\') ');
                                
                                conditions.add(
                                        String.format('{0}',
                                                new List<String>{ String.join(orclause, ' OR ') }));

                                if(this.sow.numberWrapperMap.get('Content_Percent_3__c') != null) {

                                    LibraryNumberWrapper lnw = this.sow.numberWrapperMap.get('Content_Percent_3__c');
                                    Double min = lnw.min;
                                    Double max = lnw.max;
                                    
                                    if((min == null || min == 0) && (max != null && max != 0)) {
                                        conditions.add( ' Fabric__r.Content_Percent_3__c <= ' + max + ' ');
                                        
                                    } else if((min != null && min != 0) && (max == null || max == 0)) {
                                        conditions.add( ' Fabric__r.Content_Percent_3__c >= ' + min + ' ');
                                        
                                    } else if(min != null && max != null && min != 0 && max != 0) {
                                        conditions.add( ' Fabric__r.Content_Percent_3__c >= ' + min + ' ');
                                        conditions.add( ' Fabric__r.Content_Percent_3__c <= ' + max + ' ');
                                    }
                                }
                        }
                        if(this.sow.fabric.get('Fls_Content_4__c') != null) {
                                List<String> orclause = new List<String>();
                                orclause.add('( Fabric__r.Fls_Content__c = \'' + this.sow.fabric.get('Fls_Content_4__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_2__c = \'' + this.sow.fabric.get('Fls_Content_4__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_3__c = \'' + this.sow.fabric.get('Fls_Content_4__c') + '\' ');
                                orclause.add(' Fabric__r.Fls_Content_4__c = \'' + this.sow.fabric.get('Fls_Content_4__c') + '\') ');
                                
                                conditions.add(
                                        String.format('{0}',
                                                new List<String>{ String.join(orclause, ' OR ') }));
                                
                                if(this.sow.numberWrapperMap.get('Content_Percent_4__c') != null) {

                                    LibraryNumberWrapper lnw = this.sow.numberWrapperMap.get('Content_Percent_4__c');
                                    Double min = lnw.min;
                                    Double max = lnw.max;
                                    if((min == null || min == 0) && (max != null && max != 0)) {
                                        conditions.add( ' Fabric__r.Content_Percent_4__c <= ' + max + ' ');
                                        
                                    } else if((min != null && min != 0) && (max == null || max == 0)) {
                                        conditions.add( ' Fabric__r.Content_Percent_4__c >= ' + min + ' ');
                                        
                                    } else if(min != null && max != null && min != 0 && max != 0) {
                                        conditions.add( ' Fabric__r.Content_Percent_4__c >= ' + min + ' ');
                                        conditions.add( ' Fabric__r.Content_Percent_4__c <= ' + max + ' ');
                                    }
                                }
                        }
                        if(this.sow.numberWrapperMap.get('Density_Warp__c') != null) {

                            LibraryNumberWrapper lnw = this.sow.numberWrapperMap.get('Density_Warp__c');
                            Double min = lnw.min;
                            Double max = lnw.max;
                            
                            if((min == null || min == 0) && (max != null && max != 0)) {
                                conditions.add( ' Fabric__r.Density_Warp__c <= ' + max + ' ');
                                
                            } else if((min != null && min != 0) && (max == null || max == 0)) {
                                conditions.add( ' Fabric__r.Density_Warp__c >= ' + min + ' ');
                                
                            } else if(min != null && max != null && min != 0 && max != 0) {
                                conditions.add( ' Fabric__r.Density_Warp__c >= ' + min + ' ');
                                conditions.add( ' Fabric__r.Density_Warp__c <= ' + max + ' ');
                            }
                        }
                        if(this.sow.numberWrapperMap.get('Density_Weft__c') != null) {

                            LibraryNumberWrapper lnw = this.sow.numberWrapperMap.get('Density_Weft__c');
                            Double min = lnw.min;
                            Double max = lnw.max;
                            if((min == null || min == 0) && (max != null && max != 0)) {
                                conditions.add( ' Fabric__r.Density_Weft__c <= ' + max + ' ');
                                
                            } else if((min != null && min != 0) && (max == null || max == 0)) {
                                conditions.add( ' Fabric__r.Density_Weft__c >= ' + min + ' ');
                                
                            } else if(min != null && max != null && min != 0 && max != 0) {
                                conditions.add( ' Fabric__r.Density_Weft__c >= ' + min + ' ');
                                conditions.add( ' Fabric__r.Density_Weft__c <= ' + max + ' ');
                            }
                        }
                        if(this.sow.fabric.get('Warp_Yarn_Size__c') != null) {
                                conditions.add(' Fabric__r.Warp_Yarn_Size__c = \'' + this.sow.fabric.get('Warp_Yarn_Size__c') + '\' ');
                        }
                        if(this.sow.fabric.get('Yarn_Type_Warp__c') != null) {
                                conditions.add(' Fabric__r.Yarn_Type_Warp__c = \'' + this.sow.fabric.get('Yarn_Type_Warp__c') + '\' ');
                        }
                        if(this.sow.fabric.get('Weft_Yarn_Size__c') != null) {
                                conditions.add(' Fabric__r.Weft_Yarn_Size__c = \'' + this.sow.fabric.get('Weft_Yarn_Size__c') + '\' ');
                        }
                        if(this.sow.fabric.get('Yarn_Type_Weft__c') != null) {
                                conditions.add(' Fabric__r.Yarn_Type_Weft__c = \'' + this.sow.fabric.get('Yarn_Type_Weft__c') + '\' ');
                        }
                        
                        
                        /*
                            NickWu added SamplesTGA search by Weave knit type(TGA) field
                        */
                        if(this.sow.multiSelectWrapperMap.get('Weave_Knit_Type_TGA__c')!=null && rt == 'SamplesTGA'){
                        
                             if(this.sow.multiSelectWrapperMap.get('Weave_Knit_Type_TGA__c') != null) {
                                String splitSelections = '';
                                List<String> selectedValues = (List<String>) this.sow.multiSelectWrapperMap.get('Weave_Knit_Type_TGA__c').selectedValues;                        
                                System.debug('here we are: ' + selectedValues);
                                 
                                for(String s: selectedValues){
                                    splitSelections += s + '\',\'';
                                    
                                }                       
                                splitSelections = '(\'' + splitSelections + '\')';
                                splitSelections = splitSelections.replace(',\'\'',''); 
                                
                                if(splitSelections != '(\'\')') {
                                    conditions.add( ' Fabric__r.Weave_Knit_Type_TGA__c IN ' + splitSelections + ' ' );
                                }       
                            }
                        }
                        
                        
                        if(this.sow.multiSelectWrapperMap.get('Fls_Woven_Type__c') != null) {
                            if(this.sow.multiSelectWrapperMap.get('Fls_Woven_Type__c') != null) {
                                String splitSelections = '';
                                List<String> selectedValues = (List<String>) this.sow.multiSelectWrapperMap.get('Fls_Woven_Type__c').selectedValues;                        
                                for(String s: selectedValues){
                                    splitSelections += s + '\',\'';
                                }                       
                                splitSelections = '(\'' + splitSelections + '\')';
                                splitSelections = splitSelections.replace(',\'\'','');
                                if(splitSelections != '(\'\')') {
                                    conditions.add( ' Fabric__r.Fls_Woven_Type__c INCLUDES ' + splitSelections + ' ' );
                                }       
                            }
                        }
                        if(this.sow.multiSelectWrapperMap.get('Fls_Fabric_Finish__c') != null) {
                            if(this.sow.multiSelectWrapperMap.get('Fls_Fabric_Finish__c') != null) {
                                String splitSelections = '';
                                List<String> selectedValues = (List<String>) this.sow.multiSelectWrapperMap.get('Fls_Fabric_Finish__c').selectedValues;                     
                                for(String s: selectedValues){
                                    splitSelections += s + '\',\'';
                                }                       
                                splitSelections = '(\'' + splitSelections + '\')';
                                splitSelections = splitSelections.replace(',\'\'',''); 
                                if(splitSelections != '(\'\')') {
                                    conditions.add( ' Fabric__r.Fls_Fabric_Finish__c INCLUDES ' + splitSelections + ' ' );
                                }       
                            }
                        }
                        if(this.sow.multiSelectWrapperMap.get('Fls_Color__c') != null) {
                            if(this.sow.multiSelectWrapperMap.get('Fls_Color__c') != null) {
                                String splitSelections = '';
                                List<String> selectedValues = (List<String>) this.sow.multiSelectWrapperMap.get('Fls_Color__c').selectedValues;                     
                                for(String s: selectedValues){
                                    splitSelections += s + '\',\'';
                                }                       
                                splitSelections = '(\'' + splitSelections + '\')';
                                splitSelections = splitSelections.replace(',\'\'','');
                                if(splitSelections != '(\'\')') {
                                    conditions.add( ' Fabric__r.Fls_Color__c INCLUDES ' + splitSelections + ' ' );
                                }       
                            }
                        }
                        if(this.sow.multiSelectWrapperMap.get('Fls_Pattern__c') != null) {
                            if(this.sow.multiSelectWrapperMap.get('Fls_Pattern__c') != null) {
                                String splitSelections = '';
                                List<String> selectedValues = (List<String>) this.sow.multiSelectWrapperMap.get('Fls_Pattern__c').selectedValues;                       
                                for(String s: selectedValues){
                                    splitSelections += s + '\',\'';
                                }                       
                                splitSelections = '(\'' + splitSelections + '\')';
                                splitSelections = splitSelections.replace(',\'\'','');
                                if(splitSelections != '(\'\')') {
                                    conditions.add( ' Fabric__r.Fls_Pattern__c INCLUDES ' + splitSelections + ' ' );
                                }       
                            }
                        }
                        

                        if(!conditions.isEmpty()) {
                                query = query + String.format(' {0}',
                                        new List<String>{ String.join(conditions, ' AND ') });
                                system.debug('## check here @@ ' + query);
                                List<Sample_Fabric__c> itemResultSet = (List<Sample_Fabric__c>) SystemUtil.query(query);
                                if(!ErrorUtils.isEmpty(itemResultSet)) {
                                        for(Sample_Fabric__c si : itemResultSet) {
                                                resultSet.add(si.Sample__c);
                                        }
                                } else {
                                        resultSet = null; // Set it to NULL so that we know nothing was found
                                }
                        } 
                    system.debug('## onions @@ ' + query);
                }
                
                
                system.debug('## resultset @@ ' + resultSet);
                return resultSet;
                
            }
            
            /*
                Added by Nick Wu 20141225
                To Validate input fields are all make senses, otherwise will popup err msg
            */
            public boolean SearchObjValidation(){
                
                /*
                    Created Date handler
                    Error when 1. only just have Start or End date
                               2. Start date > End date
                */
                if(this.sow !=null && this.sow.dateWrapperMap != null && this.sow.dateWrapperMap.get('CreatedDate') !=null){
                    
                    if(this.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c==null && 
                       this.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_End_Date_Proxy__c !=null){
                       
                           ApexPages.Message msNoItemsFound = new ApexPages.Message(ApexPages.Severity.INFO, 'Created date(From) Empty');
                           ApexPages.addMessage(msNoItemsFound);
                           return false;
                       
                    }else if(this.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c!=null && 
                             this.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_End_Date_Proxy__c ==null){
                             
                           ApexPages.Message msNoItemsFound = new ApexPages.Message(ApexPages.Severity.INFO, 'Created date(To) Empty');
                           ApexPages.addMessage(msNoItemsFound);
                           return false;
                             
                    }else if(this.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c >
                             this.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_End_Date_Proxy__c ){
                           
                           ApexPages.Message msNoItemsFound = new ApexPages.Message(ApexPages.Severity.INFO, 'Created date(From) > Create date(To)');
                           ApexPages.addMessage(msNoItemsFound);
                           return false;
                    }
                    return true;
                }
                
                return true;
                   
                
            }
            //Commented by DTT 20170418
          /*
          //Add by DTT
            public Set<Library_Item__c> finResult(List<String> allIds, List<Library_Item__c> oriResult){

               set<Library_Item__c> finallAllItems=new set<Library_Item__c>();
               Map <id,String> resultMap=new Map <id,String>();
               List<Library_Item__c> allItems =[select Id, Fabric_ID__c,FMP__c from Library_Item__c where id in: allIds and FMP__c=:FMP];
               List<String> finId=new List<String>();

               for(Library_Item__c aItem : allItems){
                    resultMap.put(aItem.id,'1');
                }
                if(resultMap==null || resultMap.isEmpty())
                {
                    return finallAllItems;
                }

               for(Library_Item__c reader:oriResult)
                {
                    if(resultMap.get(reader.id)!=null)
                    {
                         finallAllItems.add(reader);
                    }

                }
            
               return finallAllItems;
            }
            */
            //Add by DTT End
            //Commented by DTT 20170418 End


            //Added by DTT 20170405
            Public List<Library_Item__c> searchFMPRecord() {
                
                List<Library_Item__c> results = new List<Library_Item__c>();
                List<String> resultIds = new List<String> ();
                String query = '';
                
                //Query library item records in SFDC instead of using Webservice from FLS
                query += 'SELECT Id From Library_Item__c WHERE ';           
                
                //get the search criteria from field set
                for(Schema.FieldSetMember f : this.getFieldSetMaster()) {
                    if(this.sow.getLibraryItem().get(f.getFieldPath()) != null) {
                        
                        query += f.getFieldPath() + ' = ';
                        if(f.getType() != Schema.DisplayType.double) {
                            query += '\'';
                        }
                        query += this.sow.getLibraryItem().get(f.getFieldPath());
                        if(f.getType() != Schema.DisplayType.double) {
                            query += '\'';
                        }
                        
                        query += ' AND ';
                    }
                }
                
                query += 'FMP__c = true';
                
                results = Database.query(query);
                
                
                for(Library_Item__c li : results) {
                    resultIds.add(li.Id);
                }
                
                //Query the Library Item again to display the results with expecting fields 
                query = 'SELECT ';
                for(String f : selectFields) {
                    query += f + ', ';
                }
                query += 'Id, Name FROM Library_Item__c WHERE Id in (';
                
                for(Integer i=0; i < resultIds.size(); i++) {
                    query += '\'' + resultIds.get(i) +'\'';
                    if(i != resultIds.size() -1 ) {
                        query += ', ';
                    }
                }
                query += ' )';
                results = Database.query(query);
                
                return results ;
            }
            /*
            Public List<Library_Item__c> searchFMPRecord(List<Library_Item__c> beforeResult) {
                Set<Id> libraryItemIdSet = new Set<Id> ();
                List<Library_Item__c> results = new List<Library_Item__c>();
                List<Library_Item__c> tempSearchResults = new List<Library_Item__c>();
                
                results = beforeResult;
                for(Library_Item__c reader : results) {
                    libraryItemIdSet.add(reader.Id);
                }
                if(!libraryItemIdSet.isEmpty()) {
                    List<Library_Item__c> fmpLibraryItemList = [Select Id, Tech_Selected__c from Library_Item__c where id in :libraryItemIdSet and FMP__c = true];
                    
                    for(Library_Item__c srReader: results ) {
                        for(Library_Item__c fmpReader : fmpLibraryItemList) {
                            if(srReader.Id == fmpReader.Id) {
                            
                                tempSearchResults.add(srReader);
                            }
                        }
                    }

                }
                if(!tempSearchResults.isEmpty()) {
                    results = tempSearchResults;
                }
                else {
                    results.clear();
                }
                
                return results;
            }
            
            */

            /**
             * Search for Library Items
             */
            public PageReference searchRecord(){
                        
                // Search on Inventory level
                Set<Id> libInvItems;
                boolean isSearchInventoryItemsFabric =false;
                this.searchResults.clear();
                inventoryForFabricItem='';
                
                this.libSourceLocalRepo =  new LibrarySourceLocalRepository();
                
                if(selectedRecordType == Label.Library_RecordType_Fabric){
                    isSearchInventoryItemsFabric = isSearchInventoryItemsFabric();
                
                }else{
                    libInvItems = searchInventoryItems();
                }
                
                Set<Id> sampleIds = new Set<Id>();
                
                if(selectedRecordType == Label.Library_RecordType_SamplesTGA || selectedRecordType == Label.Library_RecordType_SamplesPD) {
                        sampleIds = this.searchFabricItems(selectedRecordType);
                }
                
                if(!SearchObjValidation()){
                    return null;
                }
                
                //FIXME: Why?
                if(selectedRecordType!=Label.Library_RecordType_Fabric && libInvItems != null && libInvItems.isEmpty()) {
                    ApexPages.Message msNoItemsFound = new ApexPages.Message(ApexPages.Severity.INFO, Label.Library_Msg_NoItemFound);
                    ApexPages.addMessage(msNoItemsFound);
                    return null;
                }else if(selectedRecordType==Label.Library_RecordType_Fabric && !isSearchInventoryItemsFabric){


                    ApexPages.Message msNoItemsFound = new ApexPages.Message(ApexPages.Severity.INFO, Label.Library_Msg_NoItemFound);
                    ApexPages.addMessage(msNoItemsFound);
                    return null;
                }
                
                
                /*
                    NickWu added if statement 
                */
                if(selectedRecordType != Label.Library_RecordType_Fabric) {
                
                    this.libSourceLocalRepo.setConditionCriteria( selectedRecordType , sampleIds, libInvItems, this.sow.obj, 
                            this.getFieldSet('Library_Item__c', false), this.sow.numberWrapperMap, this.sow.multiSelectWrapperMap,
                            this.sow.dateWrapperMap);
                            this.libSourceLocalRepo.setSelectionCriteria(selectFields);
                }
                        String recordType = selectedRecordType;
                
                try {
                    if(selectedRecordType == Label.Library_RecordType_Fabric) {
                        
                        //Edited by DTT 20170418
                        if(this.FMP) {
                            searchResults = searchFMPRecord();
                        }                        
                        else {
                            searchResults = this.libSourceFabricRepo.getAllFabricItems(inventoryForFabricItem, libSourceFabricRepo.currentPage, this.sow);
                        }
                        //Edited by DTT 20170418 End 
                        
                        // Setup the Json
                        setupLibIdToFabricInventoryJson(searchResults);
                        
                    } else {
                            searchResults = this.libSourceLocalRepo.getItems(selectedRecordType);
                    }
                     
                    if(searchResults.isEmpty()) {
                        ErrorUtils.outputInfoMessage(Label.Library_Msg_NoItemFound);
                    }                
                
                    /*Commented by DTT 20170405
                        //Add by DTT
                        if(selectedRecordType == Label.Library_RecordType_Fabric) {
                            searchResults = this.libSourceFabricRepo.getAllFabricItems(inventoryForFabricItem, libSourceFabricRepo.currentPage, this.sow);
                            
                            List<String> allId=new List<String>();

                            for(Library_Item__c anItem : searchResults){
                                    
                                    allId.add(anItem.id);
                            }
                                
                            List<Library_Item__c> finallyResult=new List<Library_Item__c>();
                            Set<Library_Item__c> tempSet=finResult(allId,searchResults);
                            if(tempSet!=null && tempSet.isEmpty()==false)
                            {
                                finallyResult.addAll(tempSet);
                            }

                            searchResults=new List<Library_Item__c>();
                            searchResults.addAll(finallyResult);
                            
                            setupLibIdToFabricInventoryJson(searchResults);
                           
                        //Add by DTT     
                        } else {
                                searchResults = this.libSourceLocalRepo.getItems(selectedRecordType);
                        }
                         
                        if(searchResults.isEmpty()) {
                            ErrorUtils.outputInfoMessage(Label.Library_Msg_NoItemFound);
                        }
                     */   
                } catch(Exception e) {
                        if(Boolean.valueOf(Label.Tech_Display_Full_Exception)) {
                                ErrorUtils.outputInfoMessage(e.getMessage() + ': ' + e.getStackTraceString());  
                        } else {
                                ErrorUtils.outputInfoMessage(e.getMessage());
                        }
                }

                return null;
            }
           
            
            //Perform next page searching, search next 10 items per time
            public PageReference nextPage() {
                try {
                    if(selectedRecordType == Label.Library_RecordType_Fabric) {
                        if(this.libSourceFabricRepo.getHasNextPage()) {
                            searchResults = this.libSourceFabricRepo.getItemsNextPage(inventoryForFabricItem, this.sow);
                                                setupLibIdToFabricInventoryJson(searchResults);
                        }
                            
                    } else {
                        if(this.libSourceLocalRepo.getHasNextPage()) {
                            searchResults = this.libSourceLocalRepo.getItemsNextPage();
                        }
                    }
                        
                } catch(Exception e) {
                    if(Boolean.valueOf(Label.Tech_Display_Full_Exception)) {
                            ErrorUtils.outputInfoMessage(e.getMessage() + ': ' + e.getStackTraceString());  
                    } else {
                            ErrorUtils.outputInfoMessage(e.getMessage());
                    }
                }
                
                return null;
            }
            
            //Perform prev page searching, search prev 10 items per time
            public PageReference prevPage() {
                try {  
                    if(selectedRecordType == Label.Library_RecordType_Fabric) {
                        if(this.libSourceFabricRepo.getHasPrevPage()) {
                            searchResults = this.libSourceFabricRepo.getItemsPrevPage(inventoryForFabricItem, this.sow);
                            setupLibIdToFabricInventoryJson(searchResults);
                        }
                            
                    } else {
                        if(this.libSourceLocalRepo.getHasPrevPage()) {
                            searchResults = this.libSourceLocalRepo.getItemsPrevPage();
                        }
                    }   
                } catch(Exception e) {
                    if(Boolean.valueOf(Label.Tech_Display_Full_Exception)) {
                            ErrorUtils.outputInfoMessage(e.getMessage() + ': ' + e.getStackTraceString());  
                    } else {
                            ErrorUtils.outputInfoMessage(e.getMessage());
                    }
                }
                
                return null;
            }
            
            //check selectedRecordType whether is empty or null
            public boolean getIsCategorySelected() {
                boolean result = false;
                if(this.selectedRecordType != null && selectedRecordType != '' && selectedRecordType != Label.Library_select) {
                    result = true;
                }
                
                return result;
            }
            
            //reset filters
            public PageReference purgeSearchResults() {

                resetFilters();
                return null;    
            }
            
            //return the number of overdue items
            public Integer libraryOverdueItemCount {get;set;}{
                libraryOverdueItemCount=0;
                libraryOverdueItemCount = LibraryUtil.libraryOverdueItemCount;
            }
            
            //return a warning message for overdue items
            public String libraryOverdueWarningMessage{get;set;}{
                libraryOverdueWarningMessage='';
                libraryOverdueWarningMessage = LibraryUtil.libraryOverdueWarningMessage;
            }
            
            //create valided requests for borrowed library items
            @RemoteAction
            public static String borrowSelectedAction(String itemIds) {
                String s = '';
                String[] itmIdslist = itemIds.split(';');
                String libItemId = null;
                String multiLibItemId = null;
                if(itmIdslist.size()>1) {
                        multiLibItemId = itemIds;
                } else {
                        libItemId = itemIds;
                }
                
                LibraryItemRequestViewCtrl cart = new LibraryItemRequestViewCtrl();
                Id libraryCart = cart.getLibraryCart();    
                
                //Check if the user has the permission to create a library request
                Schema.DescribeSObjectResult sobj = Library_Item_Request__c.sObjectType.getDescribe();   
                if(sobj.isCreateable()) {
                       
                        if(libItemId != null && libraryCart != null) {
                            //Check if it was already added:
                            List<Library_Item_Request__c> existingLir = [SELECT Id FROM LIbrary_Item_Request__c WHERE Status__c = :Label.Library_Request_Status_Not_Submitted AND Library_Item__c = :libItemId AND Bulk_Request__c = :libraryCart];
                            
                            if(existingLir == null || existingLir.isEmpty()) {
                                                
                                Library_Item_Request__c lir = new Library_Item_Request__c(Status__c =Label.Library_Request_Status_Not_Submitted, Library_Item__c = libItemId, Bulk_Request__c = libraryCart);
                                
                                try {
                                    insert lir;
                                    s = libraryCart;
                                } catch(DmlException ex) {
                                    throw ex;
                                }
                            } else {
                                throw new TalException(Label.Library_MSG_Aready_In_Cart);   
                            }               
                        } else if(multiLibItemId != null && libraryCart != null) { 
                            //Check if it was already added:
                            String[] libItemIds = multiLibItemId.split(';');
                            
                            addedMsg = '';
                            existedMsg ='';
                            
                            if(libItemIds != null && !libItemIds.isEmpty()) {
                                List<Library_Item_Request__c> lirToInsert = new List<Library_Item_Request__c>();
                                
                                // check which items are existed in the Cart
                                List<Library_Item_Request__c> existingLir = [SELECT Id, Library_Item__c, Bulk_Request__c, Library_Item__r.Item_Name__c FROM LIbrary_Item_Request__c WHERE 
                                                                                                                           Library_Item__c IN :libItemIds AND 
                                                                                                                           Bulk_Request__c = :libraryCart];
                                
                                 
                                Map<String, Library_Item_Request__c> validItemMap = new Map<String, Library_Item_Request__c>();
                                
                                
                                //Added all selected items into Map Library_Item__c as key, Library_Item_Request__c as value
                                for(Integer i =0;i<libItemIds.size();i++){
                                    if(!validItemMap.containsKey(libItemIds[i])){
                                        Library_Item_Request__c lir = new Library_Item_Request__c(Status__c =Label.Library_Request_Status_Not_Submitted, 
                                                                                                  Library_Item__c = libItemIds[i], Bulk_Request__c = libraryCart);
                                        validItemMap.put(libItemIds[i],lir);
                                    }
                                }
                                
                                //compare with the existingLir to check if there are any existing items in the map, if yes, remove
                                for(Integer i=0;i<existingLir.size();i++){
                                    String strId = existingLir.get(i).Library_Item__c;
                                    if(validItemMap.containsKey(strId)){
                                        validItemMap.remove(strId);
                                    }
                                }
                                
                                
                                try {
                                    insert validItemMap.values();
                                    s= libraryCart;
                                    
                                } catch(DmlException ex) {
                                        throw ex;
                                }         
                            }            
                        }                     
                } else {                
                        throw new TalException(Label.Library_MSG_Cannot_Complete);
                }
                return s;
            }
            
            private void setupLibIdToFabricInventoryJson(List<Library_Item__c> searchResults) {
                libIdToFabricInventoryJson.clear();
                for(Library_Item__c li : [SELECT Id, Fabric_Inventory_Json__c FROM Library_Item__c WHERE Id IN: searchResults]) {
                    
                    if(li.Fabric_Inventory_Json__c != null) {
                        List<LibraryFlsFabricSearchWs.fabricInventory> inventoryList = 
                            (List<LibraryFlsFabricSearchWs.fabricInventory>) JSON.deserialize(li.Fabric_Inventory_Json__c, List<LibraryFlsFabricSearchWs.fabricInventory>.class);
                        
                        List<FabricInventoryVO> fiVOList = new List<FabricInventoryVO>();
                        for(LibraryFlsFabricSearchWs.fabricInventory fi : inventoryList) {
                                System.debug('>>>>> setupLibIdToFabricInventoryJson >>>>> ' + fi.reservedQty);
                            System.debug('>>>>> setupLibIdToFabricInventoryJson >>>>> ' + fi.availableQty);
                            System.debug('>>>>> setupLibIdToFabricInventoryJson >>>>> ' + fi.unit);
                            System.debug('>>>>> setupLibIdToFabricInventoryJson >>>>> ' + fi.facility);
                            
                            FabricInventoryVO inv = new FabricInventoryVO();
                            inv.reservedQty = fi.reservedQty;
                            inv.availableQty = fi.availableQty;
                            inv.unit = fi.unit;
                            inv.facility = fi.facility;
                            fiVOList.add(inv);
                        }
                        
                        libIdToFabricInventoryJson.put(li.Id, fiVOList);
                    } else {
                        libIdToFabricInventoryJson.put(li.Id, new List<FabricInventoryVO>());
                    }
                }
            }
            
            public class FabricInventoryVO {
                public Decimal availableQty {get;set;}
                public String facility {get;set;}
                public Decimal reservedQty {get;set;}
                public String unit {get;set;}
                
                public fabricInventoryVO() {
                    
                }
            }

        }