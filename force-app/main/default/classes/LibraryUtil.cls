/*
    @Author: Nick Wu
    @Description: utility class to check the securities for each profile whether have access to those buttons
                  calculate overdue items.
*/
public without sharing class LibraryUtil {
    
    //check how many over due items
    public static Integer libraryOverdueItemCount {get{
        return [Select count() From Library_Item_Request__c Where Deadline__c<:System.today() AND Overdue__c = true And OwnerId =:userInfo.getUserId()];
    }set;}
    
    //display the error messages of over due items
    public static String libraryOverdueWarningMessage{get{
                String returnString = Label.Library_Overdue_Message.replace('<number>', libraryOverdueItemCount.format());
                if(libraryOverdueItemCount == 1){
                        returnString = returnString.replace('items', 'item');
                }
        return returnString;
    }set;}
    
    //javascript alert
    public static String jsAlert(String msg){
        String result='';
        if(msg!=null && msg!=''){
            result = Label.Library_Mobile_Alert + '(\''+msg+'\');';
        }
        return result;
    }
    
    //javascript navigate Sobject
    public static String jsNavSObject(String theId){
        String result = '';
        if(theId==null || theId==''){
            return result;
        }
        if(SystemUtil.isMobileDevice()){
            result = Label.Library_Mobile_NavigateObject + +'(\'' + theId + '\');';
        }else{
            result = Label.Library_window_location_href + +'=\'/' + theId + '\';';
        }
        return result;
    }
    
    //javascript navigate Sobject
    public static String jsNavURL(String url){
        String result = '';
        if(url==null || url==''){
            return result;
        }
        if(SystemUtil.isMobileDevice()){
            result = Label.Library_Mobile_NavigateToURL + +'(\'/' + url + '\');';
        }else{
            result = Label.Library_window_location_href + +'=\'/' + url + '\';';
        }
        return result;
    }
    
    //javascript back
    public static String jsBack(){
    	String result = '';
        if(SystemUtil.isMobileDevice()){
            result = Label.Library_SF_back;
        }else{
            result = Label.Library_windows_back;
        }
        return result;
    }
    
    //for book scan use
    public static List<Library_Inventory__c> invList(List<String> inventoryIds ){
        if(inventoryIds!=null && !inventoryIds.isEmpty()){
            return [SELECT Id, name, Return_Date_Time__c,Lending_Status__c, Item_Category__c, Library_Item_Master__c, Library_Item_Master__r.ownerId, Original_Address__c FROM Library_Inventory__c WHERE 
                    Lending_Status__c =:Label.Library_Inventory_Lending_Status_available AND ID IN: inventoryIds];
        }else
            return null;   
    }
    
    //for book scan use
    public static List<Library_Item_Request__c> availableList(List<String> inventoryIds ){
        if(inventoryIds!=null && !inventoryIds.isEmpty()){
            return [Select id, Item_Category__c, name, Library_Request_Inventory__c FROM Library_Item_Request__c Where Status__c =:Label.Library_Request_Status_Reserved AND
                    OwnerId =: UserInfo.getUserId() AND Library_Request_Inventory__c IN 
                    (SELECT Id FROM Library_Inventory__c WHERE Lending_Status__c =:Label.Library_Inventory_Lending_Status_unavailable AND ID IN: inventoryIds) ];
        }else
            return null;
    }
    
    //for book scan use
    public static List<Library_Item_Request__c> notAvailableList( List<String> inventoryIds ){
        if(inventoryIds!=null && !inventoryIds.isEmpty()){
            return [Select id, Requester__c,Library_Request_Inventory__c FROM Library_Item_Request__c Where 
                                                                  OwnerId !=: UserInfo.getUserId() AND Library_Request_Inventory__c IN 
                                                                  (SELECT Id FROM Library_Inventory__c WHERE Lending_Status__c =:Label.Library_Inventory_Lending_Status_unavailable AND ID IN: inventoryIds) ];
        }else
            return null;
    }
    
    /********************************************************
        Nick Wu
        buttons visiblity privilege mapping
    *********************************************************/
    //equal to burberry archive admin
    public static boolean archiveCheckOutBtn{get{
        Boolean b = false;
        List<profile> pList = [select id, Name from profile where id =: UserInfo.getProfileId() limit 1];
        Map<ID,profile> rMap = new Map<ID,profile>();
        if(pList!=null && !pList.isEmpty()){
            for(profile p : pList){
                if(p.Name == Label.Library_Profile_TFEBAA ||
                   p.Name == Label.Library_Profile_SA){
                    rMap.put(p.id,p);
                }
            }
        }
       if(rMap.size()>0) {
         b = true;
       }else{
         b = false;
       }
       return b;
    }set;}

    //not equal to Warehouse Librarian and Mail Room Staff
    public static boolean confirmReceivedBtn{get{
        Boolean b =false;
        List<profile> pList = [select id, Name from profile where id =: UserInfo.getProfileId() limit 1];
        Map<ID,profile> rMap = new Map<ID,profile>();
        if(pList!=null && !pList.isEmpty()){
            for(profile p : pList){
                if(p.Name != Label.Library_Profile_TFEWL &&
                   p.Name != Label.Library_Profile_TFEMRS){
                    rMap.put(p.id,p);
                }
            }
        }
        if(rMap.size()>0) {
           b = true;
        }else{
           b = false;
        }
        return b;
    }set;}
    
    //not equal to Warehouse Librarian and Mail Room Staff
    public static boolean borrowBtn{get{
        Boolean b =false;
        List<profile> pList = [select id, Name from profile where id =: UserInfo.getProfileId() limit 1];
        Map<ID,profile> rMap = new Map<ID,profile>();
        if(pList!=null && !pList.isEmpty()){
            for(profile p : pList){
                if(p.Name != Label.Library_Profile_TFEWL &&
                   p.Name != Label.Library_Profile_TFEMRS){
                    rMap.put(p.id,p);
                }
            }
        }
        if(rMap.size()>0) {
           b = true;
        }else{
           b = false;
        }
        return b;
    }set;}

    //Warehouse admin, warehouse librarian, fabric admin, fabric standard user, PD admin, burberry Admin &  book admin
    public static boolean initialCheckInBtn{get{
        Boolean b =false;
        List<profile> pList = [select id, Name from profile where id =: UserInfo.getProfileId() limit 1];
        Map<ID,profile> rMap = new Map<ID,profile>();
        if(pList!=null && !pList.isEmpty()){
            for(profile p : pList){
                if(p.Name == Label.Library_Profile_TFEWA ||
                   p.Name == Label.Library_Profile_TFEWL ||
                   p.Name == Label.Library_Profile_TFEFA ||
                   p.Name == Label.Library_Profile_TFEFSU ||
                   p.Name == Label.Library_Profile_TFEPA ||
                   p.Name == Label.Library_Profile_TFEBAA ||
                   p.Name == Label.Library_Profile_SA){
                    rMap.put(p.id,p);
                }
            }
        }
        if(rMap.size()>0) {
           b = true;
        }else{
           b = false;
        }
        return b;
    }set;}
    
    //Warehouse admin, Warehouse librarian, fabric admin, PD admin, 
    public static boolean warehouseCheckOutBtn{get{
        Boolean b =false;
        List<profile> pList = [select id, Name from profile where id =: UserInfo.getProfileId() limit 1];
        Map<ID,profile> rMap = new Map<ID,profile>();
        if(pList!=null && !pList.isEmpty()){
            for(profile p : pList){
                if(p.Name == Label.Library_Profile_TFEWA ||
                   p.Name == Label.Library_Profile_TFEWL ||
                   p.Name == Label.Library_Profile_TFEFA ||
                   p.Name == Label.Library_Profile_TFEPA ||
                   p.Name == Label.Library_Profile_SA ){
                    rMap.put(p.id,p);
                }
            }
        }
        if(rMap.size()>0) {
           b = true;
        }else{
           b = false;
        }
        return b;
    }set;}
    
    //Warehouse Admin, Fabric Admin,PD Admin,Mail Room Staff
    public static boolean MailingRoomCheckinOutBtn{get{
        Boolean b =false;
        List<profile> pList = [select id, Name from profile where id =: UserInfo.getProfileId()  limit 1];
        Map<ID,profile> rMap = new Map<ID,profile>();
        if(pList!=null && !pList.isEmpty()){
            for(profile p : pList){
                if(p.Name == Label.Library_Profile_TFEWA ||
                   p.Name == Label.Library_Profile_TFEFA ||
                   p.Name == Label.Library_Profile_TFEPA ||
                   p.Name == Label.Library_Profile_TFEMRS ||
                   p.Name == Label.Library_Profile_SA){
                    rMap.put(p.id,p);
                }
            }
        }
        if(rMap.size()>0) {
           b = true;
        }else{
           b = false;
        }
        return b;
    }set;}
    
    //Warehouse Admin, PD Admin,Mail Room Staff
    public static boolean MailingRoomCheckinInBtn{get{
        Boolean b =false;
        List<profile> pList = [select id, Name from profile where id =: UserInfo.getProfileId()  limit 1];
        Map<ID,profile> rMap = new Map<ID,profile>();
        if(pList!=null && !pList.isEmpty()){
            for(profile p : pList){
                if(p.Name == Label.Library_Profile_TFEWA ||
                   p.Name == Label.Library_Profile_TFEFA ||
                   p.Name == Label.Library_Profile_TFEPA ||
                   p.Name == Label.Library_Profile_TFEMRS ||
                   p.Name == Label.Library_Profile_SA){
                    rMap.put(p.id,p);
                }
            }
        }
        if(rMap.size()>0) {
           b = true;
        }else{
           b = false;
        }
        return b;
    }set;}
    
    // warehouse admin, warehouse librarian, fabric admin, PD admin, burberry standard user, burberry admin, warehouse standard user, system admin
    public static boolean returnBtn{get{
        Boolean b  =false;
        List<profile> pList = [select id, Name from profile where id =: UserInfo.getProfileId()  limit 1];
        Map<ID,profile> rMap = new Map<ID,profile>();
        if(pList!=null && !pList.isEmpty()){
            for(profile p : pList){
                if(p.Name == Label.Library_Profile_TFEWA ||
                   p.Name == Label.Library_Profile_TFEWL ||
                   p.Name == Label.Library_Profile_TFEFA ||
                   p.Name == Label.Library_Profile_TFEPA ||
                   p.Name == Label.Library_Profile_TFEBAA ||
                   p.Name == Label.Library_Profile_SA){
                    rMap.put(p.id,p);
                }
            }
        }
        if(rMap.size()>0) {
           b = true;
        }else{
           b = false;
        }
        return b;
    }set;}
    
    //return a list of fieldset
    public static List<Schema.FieldSetMember> getFieldSet(Map<String, List<SelectOption>> fabricSelectionMap, SearchSObjectWrapper sow, String selectedRecordType, String sObjectName, Boolean bSampleFabric) { 
        if(selectedRecordType == Label.Library_select) {
            return null;

        } else {    
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
                        if(sow.numberWrapperMap.get(fs.getFieldPath()) == null) {
                            sow.numberWrapperMap.put(fs.getFieldPath(), new LibraryNumberWrapper(0,0));
                        }
                        
                    } else if(fs.getType() == DisplayType.MultiPicklist || fs.getType() == DisplayType.Picklist) {
                        if(selectedRecordType == Label.Library_RecordType_Fabric) {
                            if(sow.multiSelectWrapperMap.get(fs.getFieldPath()) == null) {
                                String fieldPath = fs.getFieldPath().toLowerCase();
                                    
                                fieldPath = fieldPath.replace('fls_content_2__c', 'fls_content__c');
                                fieldPath = fieldPath.replace('fls_content_3__c', 'fls_content__c');
                                    
                                List<SelectOption> soList = fabricSelectionMap.get(fieldPath);
                                
                                /*Nick Wu added Sorting*/
                                if(soList != null && soList.size()>0)
                                    SelectOptionUtil.doSortByFieldPath(soList,SelectOptionUtil.FieldToSort.Label, fieldPath);
                                
                                sow.multiSelectWrapperMap.put(fs.getFieldPath(), new MultiSelectWrapper(soList));
                                 
                            }
                        } else {
                            if(sow.multiSelectWrapperMap.get(fs.getFieldPath()) == null) {
                                    
                                List<Schema.PicklistEntry> picklistValues = sObjResult.fields.getMap().get(fs.getFieldPath()).getDescribe().getPicklistValues();
                                sow.multiSelectWrapperMap.put(fs.getFieldPath(), new MultiSelectWrapper(picklistValues));
                            }
                        }
                        
                    } else if(fs.getType() == DisplayType.datetime) {
                        
                        /*
                            Nick Wu 20141225
                            To solve created date is ersed every Search
                            Added if statement to check whether the LibraryDateWrapper obj is null, if yes, new it.
                        */                    
                        if(sow.dateWrapperMap.get(fs.getFieldPath()) == null)
                            sow.dateWrapperMap.put(fs.getFieldPath(), new LibraryDateWrapper());
                        
                    }
                }
            }
            return filterFields;
        }
    }
    
    

}