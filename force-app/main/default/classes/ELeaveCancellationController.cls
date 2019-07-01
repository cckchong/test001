/**
 * ELeaveCancellationController
 * @description Cancel leave request(s)
 */
public without sharing class ELeaveCancellationController {
    private ApexPages.StandardSetController standardController;
    private Id id;
    private Leave_Request__c r {get; set;}
    private Map<Id, String> recordtype;
    private static final String LEAVEREQUESTIDCODE = '@lrID';
    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}
    
    /**
     * @description constructor with StandardController
     */
    public ELeaveCancellationController(ApexPages.StandardController controller) {
        
        recordtype = new Map<Id, String> ();

        String textId = ApexPages.currentPage().getParameters().get('id');
        
        if (textId != null) {
            id = textId;
        }
        
        for ( RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SObjectType  = :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME 
                AND IsActive = true
            ] ) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description constructor with StandardSetController
     */
    public ELeaveCancellationController(ApexPages.StandardSetController controller) {
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
                WHERE SobjectType  = :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME 
                AND IsActive = true
            ]) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description Get Requests where cancellation is not allowed
     */
    private List<Leave_Request__c> getBlockedRequests(List<Id> ids) {
        return [SELECT Name FROM Leave_Request__c where Id = :ids and Allow_Cancel__c = false];
    }
    
    /**
     * @description Get the leave requests in scope
     */
    private List<Leave_Request__c> getRequests(List<Id> ids) {
        return [SELECT 
                    Id
                    , Date__c
                    , Employee_ID__c
                    , Applicant__c
                    , Leave_Application__c
                    , From__c
                    , To__c
                    , Employee_ID__r.User__c
                    , leave_application__r.CC_1__c
                    , leave_application__r.CC_2__c
                    , leave_application__r.CC_3__c
                    , leave_application__r.CC_4__c
                    , leave_application__r.CC_5__c
                    , leave_application__r.CC_6__c
                    , leave_application__r.CC_7__c
                    , leave_application__r.CC_8__c
                    , leave_application__r.CC_9__c
                    , leave_application__r.CC_10__c
                    , leave_application__r.type__c
                    , Name
                    , allow_cancel__c
                    , recordTypeId
                 FROM Leave_Request__c where Id = :ids and Allow_Cancel__c = true];
    }
    
    /**
     * @description Post cancellation message to Chatter
     */
    /*private void postChatter(Leave_Request__c leaveRequest) {
        String chatterText = leaveRequest.Applicant__c + ' ' + Label.ELeave_Chatter_CC_Cancel_Message + ' \n\n';
        chatterText = chatterText + leaveRequest.From__c + ' ' + Label.ELeave_General_To + ' ' + leaveRequest.To__c + '\n\n';
        
        List<Id> usersToMention = new List<Id>();
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_1__c);
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_2__c);
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_3__c);
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_4__c);
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_5__c);
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_6__c);
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_7__c);
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_8__c);
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_9__c);
        usersToMention = addIdToList(usersToMention, leaveRequest.leave_application__r.CC_10__c);
        
        if (  recordtype.get(leaveRequest.RecordTypeId)  == LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST ) 
        {
            ChatterUtil.simpleTextPostWithMultipleMentions(leaveRequest.employee_id__r.user__c != null ? leaveRequest.employee_id__r.user__c : leaveRequest.createdById, usersToMention, chatterText);
        }
       
    }*/

    /**
     * @description cancel the Flexible Time or Leave Request Transaction
     * @return PageReference the navigation endpoint
     */
    public PageReference cancel() {
        boolean isSalesforceOne = SystemUtil.isMobileDevice();
        String labelcontext = '';
        List<leave_Request__c> requestsToBeCancel = new List<Leave_Request__c>();
        List<Id> selectedRequestIds = new List<Id>();
        Map<Id, String> recordtype = new Map<Id, String>();
        
        for (RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SobjectType  = :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME  AND IsActive = true
            ]) {
             
             recordtype.put ( rt.id , rt.DeveloperName );
             
         }

        if (id != null) {
            // Cancel a single leave
            selectedRequestIds.add(id);
            requestsToBeCancel = getRequests(selectedRequestIds);
        } else if (standardController != null && standardController.getSelected() != null) {
            // Cancel multiple leave
            List<Leave_Request__c> selectedRequests;
            selectedRequests = (List<Leave_Request__c>) standardController.getSelected();

            for (Leave_Request__c request : selectedRequests) {
                selectedRequestIds.add(request.id);
            }
            
            if (selectedRequestIds.size() == 0) {
                if(isSalesforceOne) {
                    this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                    this.mobileRoute.infoMessage = Label.ELeave_Select_One_Record;
                    return null;

                } else {
                    return new PageReference('javascript: alert(\''+ Label.ELeave_Select_One_Record +'\');window.history.back();');
                }
            }

            requestsToBeCancel = getRequests(selectedRequestIds);
        } else {
            // No leave requests for cancel
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = Label.ELeave_Cancel_Fail;
                return null;
            } else { 
                return new PageReference('javascript: window.history.back();');
            }
        }
        
        
        
        for (Leave_Request__c leaveRequest : requestsToBeCancel) 
        {
            
            if ( recordtype.get(leaveRequest.recordTypeId)  ==   LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST  )
            {
                if ( leaveRequest.leave_application__r.type__c ==  LeaveRequestConstant.LEAVE_APPLICATION_BATCH  )
                {
                    if(isSalesforceOne) {
                        this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                        this.mobileRoute.infoMessage = (Label.ELeave_Leave_Request_NOT_Cancel).replace( LEAVEREQUESTIDCODE  , leaveRequest.name);
                        return null;
                        
                    } else {
                        return new PageReference('javascript: alert(\''+  (Label.ELeave_Leave_Request_NOT_Cancel).replace( LEAVEREQUESTIDCODE  , leaveRequest.name) + '\');window.history.back();' );
                    }
                }
                leaveRequest.status__c = LeaveRequestConstant.STATUS_CANCEL_NOT_SUBMITTED ; 
            }
            else if ( recordtype.get(leaveRequest.recordTypeId).contains( LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST ) )
            {
                
                if ( leaveRequest.date__c > Date.today() )
                {
                    leaveRequest.status__c = LeaveRequestConstant.STATUS_CANCEL_NOT_SUBMITTED ; 
                }
            }
        }
        String message = prepareMessage(selectedRequestIds);
       
        update requestsToBeCancel;

        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        
        for (Leave_Request__c leaveRequest : requestsToBeCancel) {
            if (leaveRequest.allow_cancel__c) {
                Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                psr.setObjectId(leaveRequest.id);
                requests.add(psr);
                //======It is ready for Chatter comments when Cancellation is requested========
                //postChatter(leaveRequest);
            }
        }
        
        Approval.process(requests);
                
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
    
        for (Leave_Request__c request : getBlockedRequests(ids)) {
            if (message != '') {
                message += ', ';
            }
            message += request.name;
        }
        
        if (message != '') {
            message = Label.ELeave_Cannot_Cancel + message;
        }
        
        return message;
    }
    
    /*private List<Id> addIdToList(List<Id> theList, Id theId) {
        if(theId != null) {
            theList.add(theId);
        }
        
        return theList;
    }*/

}