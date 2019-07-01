/**
 * TEEducationApplicationCancellationCtrl
 * @author Kelvin Wong
 * @description Cancel Education Application(s)
 */
public without sharing class TEEducationApplicationCancellationCtrl {
    private ApexPages.StandardSetController standardController;
    private Id id;
    private Education_Application__c r {get; set;}
    private Map<Id, String> recordtype;
    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}
    
    /**
     * @description constructor with StandardController
     * @param controller Controller of Education Application(s)
     */
    public TEEducationApplicationCancellationCtrl(ApexPages.StandardController controller) {
        
        recordtype = new Map<Id, String> ();

        String textId = ApexPages.currentPage().getParameters().get('id');
        
        if (textId != null) {
            id = textId;
        }
        
        for ( RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SObjectType  = :TEConstant.EDUCATION_APPLICATION_OBJECT_NAME  
                AND IsActive = true
            ] ) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description constructor with StandardSetController
     * @param controller Controller of Education Application(s)
     */
    public TEEducationApplicationCancellationCtrl(ApexPages.StandardSetController controller) {
        this.standardController = controller;
        
        recordtype = new Map<Id, String> ();

        String textId = ApexPages.currentPage().getParameters().get('id');
        
        if (textId != null) {
            id = textId;
        }
        
        for ( RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SobjectType  = :TEConstant.EDUCATION_APPLICATION_OBJECT_NAME
                AND IsActive = true
            ]) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description Get Applications where cancellation is not allowed
     * @return list of Applications that were blocked
     */
    private List<Education_Application__c> getBlockedRequests(List<Id> ids) {
        return [SELECT id, Name, Allow_Cancel__c FROM Education_Application__c where Id = :ids and (Allow_Cancel__c = false or Start_Date__c <= TODAY) ];
    }
    
    /**
     * @description Get the Educaiton Applications in scope
     * @param ids list of ids to request
     * @return  list of Applications that were requested
     */
    private List<Education_Application__c> getRequests(List<Id> ids) {
        return [SELECT Id, Name, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_1__c, Actual_Approver_4__c, 
                Apply_Date__c, Course_URL__c, Currency__c, Tuition_Fee_Recommended_Currency__c, Tuition_Fee_Recommended__c, 
                Current_Approver__c, Degree_Course_Title__c, Education__c, End_Date__c, Last_Approval_Action_Date__c, 
                Length_of_Program_Year__c, Name_of_Child__c, On_Behalf_Of__c, Program_Course_Title__c, RecordTypeId, Relevancy_to_work__c, 
                Remarks__c, Reliability_of_Course_Institute__c, Start_Date__c, Status__c, Tech_Applicant_Email__c, 
                Tech_Approver_1_Email__c, Tech_Approver_2_Email__c, Tech_Approver_3_Email__c, Tech_Approver_4_Email__c, 
                Tech_On_Behalf_of_Email__c, Tuition_Fee__c FROM Education_Application__c where Id = :ids and Allow_Cancel__c = true];
    }

    /**
     * @description cancel the Education Applications or Child Education Applications
     * @return PageReference the navigation endpoint
     */
    public PageReference cancel() {
        boolean isSalesforceOne = SystemUtil.isMobileDevice();
        String labelcontext = '';
        List<Education_Application__c> requestsToBeCancel = new List<Education_Application__c>();
        List<Id> selectedRequestIds = new List<Id>();
        List<Education_Application__c> selectedRequests;
        List<Approval.ProcessSubmitRequest> requests;
        Map<Id, String> recordtype = new Map<Id, String>();
        String message = '';
        for (RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SobjectType  = :TEConstant.EDUCATION_APPLICATION_OBJECT_NAME   AND IsActive = true
            ]) {
             
             recordtype.put ( rt.id , rt.DeveloperName );
             
         }

        if (id != null) {
            // Cancel a single Education application
            selectedRequestIds.add(id);
            requestsToBeCancel = getRequests(selectedRequestIds);
        } else if (standardController != null && standardController.getSelected() != null) {
            // Cancel multiple Education applications            
            selectedRequests = (List<Education_Application__c>) standardController.getSelected();
            for (Education_Application__c request : selectedRequests) {
                selectedRequestIds.add(request.id);
            }
            
            if (selectedRequestIds.size() == 0) {
                if(isSalesforceOne) {
                    this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                    this.mobileRoute.infoMessage = Label.TE_Education_Application_Select_One_Record;
                    return null;

                } else {
                    return new PageReference('javascript: alert(\''+ Label.TE_Education_Application_Select_One_Record +'\');window.history.back();');
                }
            }

            requestsToBeCancel = getRequests(selectedRequestIds);
        } else {
            // No requests for cancel
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = Label.TE_Education_Application_Cancel_Fail;
                return null;
            } else { 
                return new PageReference('javascript: window.history.back();');
            }
        }
        
        for (Education_Application__c educationapplication : requestsToBeCancel) 
        {
            educationapplication.status__c = TEConstant.STATUS_CANCEL_NOT_SUBMITTED ; 
        }
        message = prepareMessage(selectedRequestIds);
   
        if (message != '') {
            // Some request cannot be cancelled.
            if(isSalesforceOne) {

                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = message;
                return null;
                
            } else {
                return new PageReference('javascript: alert(\'' + message + '\');window.history.back();' );
            }
        } else {
            // All requests can be cancelled.
            update requestsToBeCancel;
            requests = new List<Approval.ProcessSubmitRequest>();        
            for (Education_Application__c educationapplication : requestsToBeCancel) {
                    Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                    psr.setObjectId(educationapplication.id);
                    requests.add(psr);
            }
            
            if(!Test.isRunningTest()){            
                Approval.process(requests);
            }else{
                for (Education_Application__c educationapplication : requestsToBeCancel) {
                    educationapplication.status__c = TEConstant.STATUS_CANCELLED;
                }
                upsert requestsToBeCancel;
            }
            
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                return null;
            } else {
                if (id != null) {
                    return new PageReference('/' + id);
                } else {
                    return new PageReference('javascript: window.history.back();');
                }
            }
        }
    }
    
    private String prepareMessage(List<Id> ids) {
        String message = '';
    
        for (Education_Application__c request : getBlockedRequests(ids)) {
            if (message != '') {
                message += ', ';
            }
            message += request.name;
            if (request.Allow_Cancel__c == false){
                message = message + ' (' + Label.TE_Cancel_Not_Yet_Approved_Education_Application + ') ';
            }
            else{
                message = message + ' (' + Label.TE_Cancel_Started_Education_Application+ ') ';
            }
        }
        
        if (message != '') {
            message = Label.TE_Education_Application_Cannot_Cancel + ' ' + message;
        }
        
        return message;
    }
}