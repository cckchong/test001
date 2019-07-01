/*
    SystemUtil Class
    Provide general utilties for apps
*/
public without sharing class SystemUtil {
    
    public static User getCurrentUserInfo()
    {
        List<User> uList = new List<User>();
        uList= 
            [
                Select Id, Name, //Grade__c, 
                    Location_Global__c, Location_Local__c, Location_Region__c, Portal_Language__c, 
                    Administrative_Regions__c, Administrative_Department__c, 
                    Department__c, Function__c, Create_Portal_Page__c, Convert_ACG_Page_Layout__c, Library_Is_Blacklisted__c,
                    Administrative_Category__c, Administrative_Target__c, Default_Landing_Page__c
                From User 
                Where Id = :UserInfo.getUserId() 
                limit 1
            ];
        if(!uList.isEmpty())
            return uList[0];
        else{
            return null;  
        }      
    }
    
    //Added by Nick Wu
    public  String getProfileName(String UserId){
        List<Profile> pList = new List<Profile>();
        pList = [ Select Id, Name from Profile where id in (select profileId from User where id =: UserId  ) limit 1 ];
        if(!pList.isEmpty()){
            return pList[0].name;
        }else{
            return '';
        }
    }

    //Added by Nick Wu
    public static Profile getCurrentUserProfile(){
        List<Profile> pList = new List<Profile>();
        pList = [Select Id, Name from Profile where id =:UserInfo.getProfileId() limit 1];
        if(!pList.isEmpty()){
            return pList[0];
        }else{
            return null;
        }
    }
    
    /*
        Stub for exception handler
    */
    public static void handleException(Exception ex){
        System.debug(' $exception ' + ex.getMessage());
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (User user : [Select id from User where Profile.Name = 'System Administrator']) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        
            email.setTargetObjectId(user.id);
            email.setSaveAsActivity(false);
            email.setSubject('Exception captured by Exception Handler');
            
            String textBody = 'OrgId : ' + UserInfo.getOrganizationId() + '\n';
            textBody += 'OrgName : ' + UserInfo.getOrganizationName() + '\n';
            textBody += 'UserId : ' + UserInfo.getUserId() + '\n';
            textBody += 'Username : ' + UserInfo.getUserName() + '\n';
            textBody += 'Message : ' + ex.getMessage() + '\n';
            textBody += '\n';
            textBody += 'Stack Trace : ' + ex.getStackTraceString();
            
            email.setPlainTextBody(textBody);
            
            emails.add(email);
        }
        
        Messaging.sendEmail(emails);
    }
    
    /*
        Stub for update list
        created by Nick Wu
    */
    public static void SafeUpdate(List<SObject> UpdateList){
        try{
            update (UpdateList);
        }
        catch (Exception e){
            handleException(e);
        }
    }
    
    /*
        Stub for update object
        created by Nick Wu
    */
    public static void SafeUpdate(SObject UpdateObj){
        List<SObject> UpdateList = new List<SObject>();
        UpdateList.add(UpdateObj);
        SafeUpdate(UpdateList);
    }
    
    /*
        Stub for insert list
        created by Nick Wu
    */
    public static void SafeInsert(List<SObject> InsertList){
        try{
            insert (InsertList);
        }
        catch (Exception e){
            handleException(e);
        }
    }
    
    /*
        Stub for insert object
        created by Nick Wu
    */
    public static void SafeInsert(SObject InsertObj){
        List<SObject> InsertList = new List<SObject>();
        InsertList.add(InsertObj);
        SafeInsert(InsertList);
    }
    
    //Query by dynamic SOQL, return list of SObject
    public static sObject[] query(String str){
        return Database.query(str);
    }
    /*
        Stub for Upsert list
        created by Nick Wu
    
    public static void SafeUpsert(List<SObject> UpsertList){
        
    }*/
    
    /*
        Stub for Upsert object
        created by Nick Wu
    
    public static void SafeUpsert(SObject UpsertObj){
        
    }*/
    
    /*
        Stub for Delete list
        created by Nick Wu
    */
    public static void SafeDelete(List<SObject> DeleteList){
        try{ 
            delete (DeleteList);
        }
        catch (Exception e){
            handleException(e);
        }
    }
    
    /*
        Stub for Delete object
        created by Nick Wu
    */
    public static void SafeDelete(SObject DeleteObj){
        List<SObject> DeleteList = new List<SObject>();
        DeleteList.add(DeleteObj);
        SafeDelete(DeleteList);
    }

    public static String DMLUpdate(List<SObject> UpdateList)
    {
        String strError = '';
        try
        {
            update (UpdateList);
        }
        catch (DMLException e)
        {
            strError = e.getDmlMessage(0);
        }
        return strError;
    }
    
    public static String DMLUpdate(SObject UpdateObj)  
    {
        List<SObject> UpdateList = new List<SObject>();
        UpdateList.add(UpdateObj);
        return DMLUpdate(UpdateList);
    }
    
    public static String getSiteMapId()  
    {
        List<Portal_Content__c> siteMap = [Select Id From Portal_Content__c Where RecordType.DeveloperName='HTML' And System_Setting__c ='SiteMap' limit 1];
        String strId = siteMap.size()>0?siteMap.get(0).Id:'';
        return strId;
    }
    
    private static String theBlankHTMLId;
    
    public static String getBlankHTMLId()  
    {
        if(theBlankHTMLId == null) {
            List<Portal_Content__c> BlankHTML = [Select Id From Portal_Content__c Where RecordType.DeveloperName='HTML' And System_Setting__c ='BlankHTML' limit 1];
            theBlankHTMLId = BlankHTML.size()>0?BlankHTML.get(0).Id:'';
            
        }
        
        return theBlankHTMLId;
    }
    
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name)
    {
        List<String> lstPickvals = new List<String>();
        //From the Object Api name retrieving the SObject
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        //grab the sobject that was passed
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); 
        //describe the sobject
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); 
        //get a map of fields for the passed sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();      
        //grab the list of picklist values for the passed field on the sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry a : pick_list_values) 
        { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value to our final list
        }
        return lstPickvals;
    }
    
    public static Map<String, String> getPicklistValues2Label(String ObjectApi_name,String Field_name)
    {
        Map<String, String> lstPickvals = new Map<String, String>();
        //From the Object Api name retrieving the SObject
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        //grab the sobject that was passed
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); 
        //describe the sobject
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); 
        //get a map of fields for the passed sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();      
        //grab the list of picklist values for the passed field on the sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry a : pick_list_values) 
        { //for all values in the picklist list
            lstPickvals.put(a.getValue(), a.getLabel());//add the value to our final list
        }
        return lstPickvals;
    }
    
    public static Portal_Content__c PortalContentDetermineLang(Portal_Content__c pc, String userPreferLang)
    {   
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Portal_Content__c');
        SObject sObj = (SObject) pc;
        for(String lang: getPicklistValues('Portal_Content__c', 'Language__c'))
        {
            if(lang == userPreferLang)
            {
                sObj.put('Title__c', sObj.get('Title_' + lang + '__c') != null? sObj.get('Title_' + lang + '__c'):sObj.get('Title_en__c'));
                sObj.put('Summary__c', sObj.get('Summary_' + lang + '__c') != null? sObj.get('Summary_' + lang + '__c'):sObj.get('Summary_en__c'));
                sObj.put('Contents__c', sObj.get('Contents_' + lang + '__c') != null? sObj.get('Contents_' + lang + '__c'):sObj.get('Contents_en__c'));
                sObj.put('Revised__c', sObj.get('Title_' + lang + '__c') != null? sObj.get('Revised_' + lang + '__c'):sObj.get('Revised_en__c'));
            }
        }
        return (Portal_Content__c) sObj;
    }
    
    //get chatter feeds 
    public static Map<Id, List<FeedItem>> getChatterFeeds(Set<Id> setIds)
    {
        Map<Id, List<FeedItem>> mapId2ChatterFeeds = new Map<Id, List<FeedItem>>();
        for(FeedItem chatterFeeds : [Select Type, Title, ParentId, LinkUrl, LikeCount, Id, CreatedBy.Name, CreatedById, Body, CreatedDate, LastModifiedDate
                            From FeedItem                           
                            Where ParentId IN :setIds
                            And (type='TextPost' or type ='LinkType' or type = 'ContentPost' or type ='PollPost')
                            ])
        {
            if(!mapId2ChatterFeeds.containsKey(chatterFeeds.ParentId))
            {
                List<FeedItem> tmpList = new List<FeedItem>();
                tmpList.add(chatterFeeds);
                mapId2ChatterFeeds.put(chatterFeeds.ParentId, tmpList);
            }
            else
            {
                mapId2ChatterFeeds.get(chatterFeeds.ParentId).add(chatterFeeds);
            }
        }
        return mapId2ChatterFeeds;
    }
    
    //get chatter feeds 
    public static Map<Id, Integer> getCommentCount(List<Portal_Content__c> pcList)
    {
        List<Id> feedItemIds = new List<Id>();
        Map<String, Id> feedItemIdToAcgId = new Map<String, Id>();
        Map<Id, Integer> acgIdToCommentCount = new Map<Id, Integer>();
        
        for(Portal_Content__c pc : pcList) {
            if(pc.Tech_Feed_Item_Id__c != '') {
                feedItemIds.add(pc.Tech_Feed_Item_Id__c);
                feedItemIdToAcgId.put(pc.Tech_Feed_Item_Id__c, pc.Id);
            }
        }
        
        for(FeedItem fi : [SELECT Id, ParentId, CommentCount FROM FeedItem WHERE Id IN: feedItemIds]) {
            if(feedItemIdToAcgId.get(fi.Id) != null) {
                acgIdToCommentCount.put(feedItemIdToAcgId.get(fi.Id), fi.CommentCount);
            }
        }
        
        return acgIdToCommentCount;
    }
    
    //get thumbnail
    public static Map<Id, String> getArticleThumbnail(Set<Id> setIds)
    {
        Map<Id, String> mapResult = new Map<Id, String>();
        for(Attachment atts : [Select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.Body From Attachment a
                                Where ParentId In :setIds
                                And a.ContentType like 'image%'
                                order by CreatedDate desc]
                                )
        {
            mapResult.put(atts.ParentId, atts.Id);
        }
        return mapResult;
    }
    
    public static Boolean getIsMobile() {
        return SystemUtil.isMobileDevice();
    }
    /*
        NickWu
        Check the login env via mobile or browser
    */
    public Static Boolean isMobileDevice(){
        Boolean b = false;
        
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getHeaders() != null) {
            /** Added by Andrew 27/01/2015 */
            String userAgent = ApexPages.currentPage().getHeaders().get(Label.General_User_Agent);
            if(userAgent != null) {
                if(userAgent.contains(Label.General_SalesforceMobile)||userAgent.contains(Label.General_Salesforce1)){
                    b= true;
                }
            }
            if(!b) {
                 String retUrl = ApexPages.currentPage().getParameters().get('retURL');
     
                 b = String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
                        String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
                        ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
                        (String.isNotBlank(retUrl) && retURL.contains('projectone'));
            }
        }
        
        return b;
    }
   
    
    /*
        NickWu
        @objStr: object name
        Return back SelectOption list of record types
    */
    public static List<SelectOption> availRecordTypesSO(String objStr){
    
        List<SelectOption> soList = new List<SelectOption>();
        
        if(objStr==null || objStr==''){
            return null;
        }
        try{
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{objStr});
            Schema.DescribeSObjectResult schemaResults = descResult[0];
            List<Schema.RecordTypeInfo> recordTypeInfos = schemaResults.getRecordTypeInfos();
            
            Map<String, Schema.RecordTypeInfo> mapRecordTypeInfos = schemaResults.getRecordTypeInfosByName();
            
            //Check record types availability
            for(Schema.RecordTypeInfo rti: mapRecordTypeInfos.values()) {
                if(rti.getName() != Label.Library_RecordType_Master && rti.isAvailable()) {
                    soList.add( new SelectOption(rti.getRecordTypeId(), rti.getName()));
                }
            }
            soList.sort();
        }catch(Exception ex){
            return null;
        }
        
        return soList;
    }
    
    /*
        NickWu
        @objStr: object name that need to retrieve the record types
        @isName: return record type name  list or ID list
        Return back the list of available recordtype objects
    */
    public static List<String> availRecordTypes (String objStr, Boolean isName){
        
        Map<Id, String> availRecTypeMap = new Map<Id, String>();
        List<String> li = new List<String>();
        
        if(objStr==null || objStr==''){
            return null;
        }
        if(isName == null){
            isName = true;
        }  
        try{
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{objStr});
            Schema.DescribeSObjectResult schemaResults = descResult[0];
            List<Schema.RecordTypeInfo> recordTypeInfos = schemaResults.getRecordTypeInfos();
            
            Map<String, Schema.RecordTypeInfo> mapRecordTypeInfos = schemaResults.getRecordTypeInfosByName();
            
            //Check record types availability
            for(Schema.RecordTypeInfo rti: mapRecordTypeInfos.values()) {
                if(rti.getName() != Label.Library_RecordType_Master && rti.isAvailable()) {
                    if(isName && !availRecTypeMap.containsKey(rti.getRecordTypeId())){
                        availRecTypeMap.put(rti.getRecordTypeId(), rti.getName());
                    }else{
                        if(!availRecTypeMap.containsKey(rti.getRecordTypeId()))
                            availRecTypeMap.put(rti.getRecordTypeId(), rti.getRecordTypeId());
                    }
                }
            }
            li = availRecTypeMap.values();
            li.sort();
        }catch(Exception ex){
            return null;
        }
        
        return li;
    }
    
    public static boolean getUserEmployeeMatch() {
        boolean result = false;
        // Get the current user's details
        List<User> userList = [SELECT Id, EmployeeNumber, Physical_Delivery_Address__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(userList != null && !userList.isEmpty()) {
            List<Employee__c> employeeList = [SELECT Id FROM Employee__c WHERE Original_Employee_ID__c =: userList[0].EmployeeNumber AND Site__r.Name =: userList[0].Physical_Delivery_Address__c];
            
            if(employeeList != null && !employeeList.isEmpty()) {
                result = true;
            }
        }
        
        
        return result;
    }
    
}