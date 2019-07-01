/**
 * TEExpenseAppOverwriteNewController
 * @description to overwrite new button of Expense Application(s)
 * @author Kelvin Wong
 */
public without sharing class TEExpenseAppOverwriteNewController 
{    
    String recordTypeId;
    Map<Id, String> recordtype = new Map<Id, String> ();
    public boolean isSalesforceOne{get;set;} {isSalesforceOne = SystemUtil.isMobileDevice();}
    public String selectedRecordType{get;set;}
    
    /**
     * @description get prefix of each object
     */
    public String preFix{get;set;}{
        preFix = '';
        Schema.DescribeSObjectResult r = Expense_Application__c.sObjectType.getDescribe();
        preFix  = r.getKeyPrefix();
    }
    
    /**
     * constructor of StandardController
     * @param  controller Controller of Expense Application(s)
     */
    public TEExpenseAppOverwriteNewController (ApexPages.StandardController controller) {
         recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
         for ( RecordType rt : [SELECT Id, DeveloperName FROM RecordType where SobjectType = :TEConstant.EXPENSE_APPLICATION_OBJECT_NAME and IsActive = true] )
         {
             recordtype.put ( rt.id , rt.DeveloperName );
             
             if(rt.DeveloperName == TEConstant.EXPENSE_APPLICATION_EXPENSE_APPLICATION) {
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
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{TEConstant.EXPENSE_APPLICATION_OBJECT_NAME});
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
     * redirect the user right away if the user is on Web and has a single record type assigned
     * @return the URL to redirect
     */
    public PageReference redirectIfOnlySingleRecordType() {
       
        PageReference p;
        String returnURL = '';
        String keyPrefix = this.preFix;
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{TEConstant.EXPENSE_APPLICATION_OBJECT_NAME});
        Schema.DescribeSObjectResult schemaResults = descResult[0];
        
        List<String> avaiList = new List<String>();
        List<Schema.RecordTypeInfo> recordTypeInfos = schemaResults.getRecordTypeInfos();
        
        for(Schema.RecordTypeInfo sr : schemaResults.getRecordTypeInfos()) {
            if(sr.isAvailable() && sr.getName()!= Label.Library_RecordType_Master) {
                avaiList.add(sr.getRecordTypeId());
            }
        }

        if (avaiList.isEmpty() || avaiList.size() == 1) {

            for (Employee__c employee : [ SELECT Name FROM Employee__c WHERE User__r.id = :UserInfo.getUserId() LIMIT 1]) {
                returnURL = '/apex/' + Label.ExpenseApplicationVFP;
            }           
            return new PageReference(returnURL);
            
        } else {
            return null;
        }
    }
    
    /**
     * @description if the user has available record types, isRedirect should be true, false otherwise
     */
    public boolean isRedirect{get;set;}{
        if(SystemUtil.availRecordTypes(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME, true) != null && 
               !SystemUtil.availRecordTypes(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME, true).isEmpty()) {
               isRedirect = true;
           } else {
               isRedirect = false;
           }
    }
    
    /**
     * redirect the user appropriately according to web/mobile and record type selection
     * @return the URL to redirect
     */
    public PageReference GoBtn() {
        String url = Label.Library_JavaScriptName;
        PageReference pr;
        String returnURL = '';
        /**
        if(isSalesforceOne){
            if(!isRedirect){
                // User can't create records
                url += Label.Library_Mobile_Alert+ '(\''+Label.Library_item_creation_msg+'\');';
                url += Label.Library_Mobile_NavigateURL + '(\'/'+preFix+'/o\');';
            } else {
                
                url += Label.Library_Mobile_CreateRecord + '(\''+TEConstant.EXPENSE_APPLICATION_OBJECT_NAME+'\',\''+ selectedRecordType +'\');';
            }
            pr = new PageReference(url);
        } else {
        
            Schema.DescribeSObjectResult r = Expense_Application__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            List<String> tempList = SystemUtil.availRecordTypes(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME,false);
            
            if(tempList == null && tempList.isEmpty()) {
                // User can't create records
                return new PageReference(Label.Library_JavaScriptName+ Label.Library_Mobile_Alert+'(\''+Label.Library_item_creation_msg+'\');'+Label.Library_window_location_href+'=\'/' + keyPrefix +'/o\'');
            } else {
                
                if(tempList.size() == 1) {
                    recordTypeId = tempList[0];
                }
                
                returnURL = '/' + keyPrefix + '/e?retURL=/' + keyPrefix + '/o&RecordType='+ selectedRecordType +'&nooverride=1';
                for (Employee__c employee : [ SELECT Name FROM Employee__c WHERE User__r.id = :UserInfo.getUserId() LIMIT 1]) {
                    returnURL = '/' + keyPrefix + '/e?retURL=/' + keyPrefix + '/o&RecordType='+ selectedRecordType +'&'+Label.Expenseapp_On_Behalf_of_FieldID+'='+employee.Name+'&nooverride=1';
                }

                PageReference p = new PageReference(returnURL);
                return p;
            }
        }
        */
        for ( RecordType rt : [SELECT Id, DeveloperName FROM RecordType where SobjectType = :TEConstant.EXPENSE_APPLICATION_OBJECT_NAME and IsActive = true and Id = :selectedRecordType] )
         {
             
             if(rt.DeveloperName == TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_EDUCATION_EXPENSES ) {
                 returnURL = '/apex/' + Label.ExpenseApplicationVFP + '?rt=education';
             }
             else if(rt.DeveloperName == TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES ) {
                 returnURL = '/apex/' + Label.ExpenseApplicationVFP + '?rt=general';
             }
             else if(rt.DeveloperName == TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_TRAVEL_EXPENSES ) {
                 returnURL = '/apex/' + Label.ExpenseApplicationVFP + '?rt=travel';
             }
             pr = new PageReference(returnURL);
         }
        return pr;
    }
    
    /**
     * redirect the user appropriately according to web/mobile
     * @return the URL to redirect
     */
    public PageReference CancelBtn() {
        String url = Label.Library_JavaScriptName;
        if(isSalesforceOne) {
            url += 'sforce.one.back(true);';            
        } else {
            url += Label.Library_window_location_href+'=\'/'+preFix+'/o\' ';
        }
        PageReference pr = new PageReference(url);
        return pr;
    }
}