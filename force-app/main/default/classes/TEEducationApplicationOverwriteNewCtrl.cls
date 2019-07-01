/**
 * TEEducationApplicationOverwriteNewCtrl
 * @author Kelvin Wong
 * @description to overwrite new button of Education Application(s)
 */
public without sharing class TEEducationApplicationOverwriteNewCtrl 
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
        Schema.DescribeSObjectResult r = Education_Application__c.sObjectType.getDescribe();
        preFix  = r.getKeyPrefix();
    }
    
    /**
     * @description constructor of StandardController
     */
    public TEEducationApplicationOverwriteNewCtrl (ApexPages.StandardController controller) {
         recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
         selectedRecordType = '';
         for ( RecordType rt : [SELECT Id,   DeveloperName FROM RecordType   where SobjectType = :TEConstant.EDUCATION_APPLICATION_OBJECT_NAME and IsActive = true] )
         {
             recordtype.put ( rt.id , rt.DeveloperName );
             if (selectedRecordType == '' ){
                 selectedRecordType = rt.id;
             }
             /*
             if(rt.DeveloperName == TEConstant.EDUCATION_APPLICATION_EDUCATION) {
                 selectedRecordType = rt.id;
             }
             */
         }
    }
     
    /**
     * @description get available record types
     */
    public List<SelectOption> availableRecordTypes{get;set;}{
 
        availableRecordTypes = new List<SelectOption>();
        Boolean privilegedChildEducation = false; // indicates whether entitled to apply for child education
        Boolean privilegedEducation = false; // indicates whether entitled to apply for education

        for (Employee__c employee : [ SELECT Grade__c, Education_Policy__r.Child_Education_Application_Max_Grade__c, Education_Policy__r.Child_Education_Application_Min_Grade__c,Education_Policy__r.Education_Application_Max_Grade__c, Education_Policy__r.Education_Application_Min_Grade__c FROM Employee__c WHERE User__r.id = :UserInfo.getUserId() LIMIT 1]) {
            if (Integer.valueOf(employee.Grade__c) >= employee.Education_Policy__r.Child_Education_Application_Min_Grade__c &&
                Integer.valueOf(employee.Grade__c) <= employee.Education_Policy__r.Child_Education_Application_Max_Grade__c){
                privilegedChildEducation = true;
            }
            
            if (Integer.valueOf(employee.Grade__c) >= employee.Education_Policy__r.Education_Application_Min_Grade__c &&
                Integer.valueOf(employee.Grade__c) <= employee.Education_Policy__r.Education_Application_Max_Grade__c){
                privilegedEducation = true;
            }
            
        }
        
        try {
            for ( RecordType rt: [SELECT Id, Name, DeveloperName FROM RecordType where SObjectType = :TEConstant.EDUCATION_APPLICATION_OBJECT_NAME]){
                    if(privilegedChildEducation && rt.DeveloperName == TEConstant.EDUCATION_APPLICATION_CHILD_EDUCATION) {
                        availableRecordTypes.add( new SelectOption(rt.Id, rt.Name ));   
                    }
                    
                    if(privilegedEducation && rt.DeveloperName == TEConstant.EDUCATION_APPLICATION_EDUCATION ) {
                        availableRecordTypes.add( new SelectOption(rt.Id, rt.Name ));   
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
        
        if (availableRecordTypes.isEmpty()) {
            // Not allowed to create anything
            returnURL = Label.Library_JavaScriptName+ Label.Library_Mobile_Alert+'(\''+Label.TE_Education_Application_Not_Allowed_Create_Records+'\');'+Label.Library_window_location_href+'=\'/' + preFix +'/o\'';
            p = new PageReference(returnURL);
            return p;
        } else if(availableRecordTypes.size() == 1) {
            
            returnURL = '/apex/TEEducationApplicationVFP?rt=staff';
            /*
            for(SelectOption reader : availableRecordTypes) {
                selectedRecordType = reader.getValue();
            }
            for (Employee__c employee : [ SELECT Name FROM Employee__c WHERE User__r.id = :UserInfo.getUserId() LIMIT 1]) {
                returnURL = '/' + keyPrefix + '/e?retURL=/' + keyPrefix + '/o&RecordType='+ selectedRecordType +'&'+Label.TE_Eduapp_On_Behalf_of_FieldID+'='+employee.Name+'&nooverride=1';
            }
            
            if(!isSalesforceOne) {
                p = new PageReference(returnURL);
            } else {
                // Must be some issue auto forwarding people on mobile
                p = null;
            }
            */
            return new PageReference(returnURL);
            
        } else {
            return null;
        }
    }
    
    /**
     * @description if the user has available record types, isRedirect should be true, false otherwise
     */
    public boolean isRedirect{get;set;}{
        if(SystemUtil.availRecordTypes(TEConstant.EDUCATION_APPLICATION_OBJECT_NAME, true) != null && 
               !SystemUtil.availRecordTypes(TEConstant.EDUCATION_APPLICATION_OBJECT_NAME, true).isEmpty()) {
               isRedirect = true;
           } else {
               isRedirect = false;
           }
    }
    
    /**
     * @description redirect the user appropriately according to web/mobile and record type selection
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
                
                url += Label.Library_Mobile_CreateRecord + '(\''+TEConstant.EDUCATION_APPLICATION_OBJECT_NAME+'\',\''+ selectedRecordType +'\');';
            }
            pr = new PageReference(url);
        } else {
            Schema.DescribeSObjectResult r = Education_Application__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            List<String> tempList = SystemUtil.availRecordTypes(TEConstant.EDUCATION_APPLICATION_OBJECT_NAME,false);
            
            if(tempList == null && tempList.isEmpty()) {
                // User can't create records
                return new PageReference(Label.Library_JavaScriptName+ Label.Library_Mobile_Alert+'(\''+Label.Library_item_creation_msg+'\');'+Label.Library_window_location_href+'=\'/' + keyPrefix +'/o\'');
            } else {
                
                if(tempList.size() == 1) {
                    recordTypeId = tempList[0];
                }
                
                returnURL = '/' + keyPrefix + '/e?retURL=/' + keyPrefix + '/o&RecordType='+ selectedRecordType +'&nooverride=1';
                for (Employee__c employee : [ SELECT Name FROM Employee__c WHERE User__r.id = :UserInfo.getUserId() LIMIT 1]) {
                    returnURL = '/' + keyPrefix + '/e?retURL=/' + keyPrefix + '/o&RecordType='+ selectedRecordType +'&'+Label.TE_Eduapp_On_Behalf_of_FieldID+'='+employee.Name+'&nooverride=1';
                }

                PageReference p = new PageReference(returnURL);
                return p;
            }
        }
        */
        for ( RecordType rt : [SELECT Id, DeveloperName FROM RecordType where SobjectType = :TEConstant.EDUCATION_APPLICATION_OBJECT_NAME and IsActive = true and Id = :selectedRecordType] )
        {
             
             if(rt.DeveloperName == TEConstant.EDUCATION_APPLICATION_EDUCATION ) {
                 returnURL = '/apex/' + Label.EducationApplicationVFP + '?rt=staff';
             }
             else if(rt.DeveloperName == TEConstant.EDUCATION_APPLICATION_CHILD_EDUCATION ) {
                 returnURL = '/apex/' + Label.EducationApplicationVFP + '?rt=child';
             }
             pr = new PageReference(returnURL);
        }
        return pr;
    }
    
    /**
     * @description redirect the user appropriately according to web/mobile
     */
    public PageReference CancelBtn() {
        String url = Label.Library_JavaScriptName;
        /*
        if(isSalesforceOne) {
            url += 'sforce.one.back();';
        } else {
            url += Label.Library_window_location_href+'=\'/'+preFix+'/o\' ';
        }
        */
        url += Label.Library_window_location_href+'=\'/'+preFix+'/o\' ';
        PageReference pr = new PageReference(url);
        return pr;
    }
}