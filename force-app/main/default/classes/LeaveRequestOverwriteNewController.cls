/**
 * LeaveRequestOverwriteNewController
 * @description override new button of Leave Request
 */
public without sharing class LeaveRequestOverwriteNewController 
{    
    String recordTypeId;
    Map<Id, String> recordtype = new Map<Id, String> ();
    public boolean isSalesforceOne{get;set;} {isSalesforceOne = SystemUtil.isMobileDevice();}
    public String selectedRecordType{get;set;}
    public String url{get;set;}
    /**
     * @description get the prefix identifier of the object
     */
    public String preFix{get;set;}{
        preFix = '';
        Schema.DescribeSObjectResult r = Leave_Request__c.sObjectType.getDescribe();
        preFix  = r.getKeyPrefix();
    }
    
    /**
     * @description contructor with StandardController
     */
    public LeaveRequestOverwriteNewController (ApexPages.StandardController controller) {
         recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
         url = '';
         for ( RecordType rt : [SELECT Id,   DeveloperName FROM RecordType   where SobjectType = :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME and IsActive = true] )
         {
             recordtype.put ( rt.id , rt.DeveloperName );
             
             if(rt.DeveloperName == LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST) {
                 selectedRecordType = rt.id;
             }
         }
    }
    
    /**
     * @description get available record types
     */
    public List<SelectOption> availableRecordTypes{get;set;}{
 
        availableRecordTypes = new List<SelectOption>();

        try {
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME});
            Schema.DescribeSObjectResult schemaResults = descResult[0];
            List<Schema.RecordTypeInfo> recordTypeInfos = schemaResults.getRecordTypeInfos();
            
            Map<String, Schema.RecordTypeInfo> mapRecordTypeInfos = schemaResults.getRecordTypeInfosByName();
            
            //Check record types availability
            for(Schema.RecordTypeInfo rti: mapRecordTypeInfos.values()) {
                if(rti.getName() != Label.Library_RecordType_Master && rti.isAvailable()) {            
                    availableRecordTypes.add( new SelectOption(rti.getRecordTypeId(), rti.getName()));
                }
            }
            availableRecordTypes.sort();
            
        } catch(Exception ex) { 
            //die silently 
        }
        
        SelectOptionUtil.doSort(availableRecordTypes,SelectOptionUtil.FieldToSort.Label);
        if(availableRecordTypes == null) {
            availableRecordTypes = new List<SelectOption>();
        }
    }
    
    /**
     * @description redirect the user right away if the user is on Web and has a single record type assigned
     */ 
    public PageReference redirectIfOnlySingleRecordType() {
       
        PageReference p;
        String returnURL = '';
        String keyPrefix = this.preFix;
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME});
        Schema.DescribeSObjectResult schemaResults = descResult[0];
        
        List<String> avaiList = new List<String>();
        List<Schema.RecordTypeInfo> recordTypeInfos = schemaResults.getRecordTypeInfos();
        
        for(Schema.RecordTypeInfo sr : schemaResults.getRecordTypeInfos()) {
            if(sr.isAvailable() && sr.getName()!= Label.Library_RecordType_Master) {
                avaiList.add(sr.getRecordTypeId());
            }
        }

        if (avaiList.isEmpty()) {
            // Not allowed to create anything
            returnURL = Label.Library_JavaScriptName+ Label.Library_Mobile_Alert+'(\''+Label.Library_not_allowed_createRecords+'\');'+Label.Library_window_location_href+'=\'/' + preFix +'/o\'';
            p = new PageReference(returnURL);
            return p;
            
        } else if(avaiList.size() == 1) {

            if (recordtype.get(avaiList[0])  ==  LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST) {
                
                returnURL =  Label.ELeave_App_Path+'?sfdc.tabName='+Label.ELeave_Leave_Request_TabnameID+'&nooverride=1';
                
            } else if (recordtype.get(avaiList[0]).contains(LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST)) {
                
                for (Employee__c employee : [ SELECT Name FROM Employee__c WHERE User__r.id = :UserInfo.getUserId() LIMIT 1]) {
                    returnURL = '/' + keyPrefix + '/e?retURL=/' + keyPrefix + '/o&RecordType='+ avaiList[0] +'&'+Label.ELeave_FT_Employee_FieldID+'='+employee.Name+'&'+Label.ELeave_FT_On_Behalf_of_FieldID+'='+employee.Name+'&nooverride=1';
                }
                
            }
            
            if(!isSalesforceOne) {
                p = new PageReference(returnURL);
            } else {
                // Must be some issue auto forwarding people on mobile
                p = null;
            }
            
            return p;
            
        } else {
            return null;
        }
    }
    
    /**
     * @description if the user has available record types, isRedirect should be true, false otherwise
     */
    public boolean isRedirect{get;set;}{
        if(SystemUtil.availRecordTypes(LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME, true) != null && 
               !SystemUtil.availRecordTypes(LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME, true).isEmpty()) {
               isRedirect = true;
           } else {
               isRedirect = false;
           }
    }
    
    /**
     * @description redirect the user appropriately according to web/mobile and record type selection
     */
    public PageReference GoBtn() {
        url = Label.Library_JavaScriptName;
        PageReference pr = null;
        String returnURL = '';
        
        if(isSalesforceOne){
            if(!isRedirect){
                // User can't create records
                url += Label.Library_Mobile_Alert+ '(\''+Label.Library_item_creation_msg+'\');';
                url += Label.Library_Mobile_NavigateURL + '(\'/'+preFix+'/o\');';
            } else {
                
                if (recordtype.get(selectedRecordType)  ==  LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST) {
                    
                    url += Label.Library_Mobile_NavigateURL + '(\''+ Label.ELeave_App_Path +'\');';
                    
                } else if (recordtype.get(selectedRecordType).contains(LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST)) {                    
                    url += Label.Library_Mobile_CreateRecord + '(\''+LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME+'\',\''+ selectedRecordType +'\');';
                }
            }
        
        } else {
            Schema.DescribeSObjectResult r = Leave_Request__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            List<String> tempList = SystemUtil.availRecordTypes(LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME,false);
            
            if(tempList == null && tempList.isEmpty()) {
                // User can't create records
                return new PageReference(Label.Library_JavaScriptName+ Label.Library_Mobile_Alert+'(\''+Label.Library_item_creation_msg+'\');'+Label.Library_window_location_href+'=\'/' + keyPrefix +'/o\'');
            } else {
                
                if(tempList.size() == 1) {
                    recordTypeId = tempList[0];
                }
                
                if (recordtype.get(selectedRecordType)  ==  LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST) {
                    returnURL =  Label.ELeave_App_Path+'?sfdc.tabName='+Label.ELeave_Leave_Request_TabnameID+'&nooverride=1';
                    
                } else if (recordtype.get(selectedRecordType).contains(LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST)) {
                    returnURL = '/' + keyPrefix + '/e?retURL=/' + keyPrefix + '/o&RecordType='+ selectedRecordType +'&nooverride=1';
                    for (Employee__c employee : [ SELECT Name FROM Employee__c WHERE User__r.id = :UserInfo.getUserId() LIMIT 1]) {
                        returnURL = '/' + keyPrefix + '/e?retURL=/' + keyPrefix + '/o&RecordType='+ selectedRecordType +'&'+Label.ELeave_FT_Employee_FieldID+'='+employee.Name+'&'+Label.ELeave_FT_On_Behalf_of_FieldID+'='+employee.Name+'&nooverride=1';
                    }
                }

                PageReference p = new PageReference(returnURL);
                return p;
            }
        }
        return pr;
    }
    
    /**
     * @description redirect the user appropriately according to web/mobile
     */
    public PageReference CancelBtn() {
        String url = Label.Library_JavaScriptName;
        if(isSalesforceOne) {
            url += 'sforce.one.back();';
        } else {
            url += Label.Library_window_location_href+'=\'/'+preFix+'/o\' ';
        }
        PageReference pr = new PageReference(url);
        return pr;
    }
}