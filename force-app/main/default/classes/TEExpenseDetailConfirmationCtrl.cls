/**
 * TEExpenseDetailConfirmationCtrl
 * @description Applicant to Confirm Expense Detail(s)
 */
public without sharing class TEExpenseDetailConfirmationCtrl {
    private ApexPages.StandardSetController standardController;
    private Id id;
    private Expense_Detail__c r {get; set;}
    private Map<Id, String> recordtype;
    private static final String EXPENSEDETAILIDCODE = '@edID';
    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}
    
    /**
     * @description constructor with StandardController
     */
    public TEExpenseDetailConfirmationCtrl(ApexPages.StandardController controller) {
        
        recordtype = new Map<Id, String> ();

        String textId = ApexPages.currentPage().getParameters().get('id');
        
        if (textId != null) {
            id = textId;
        }
        
        for ( RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SObjectType  = :TEConstant.EXPENSE_DETAIL_OBJECT_NAME 
                AND IsActive = true
            ] ) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description constructor with StandardSetController
     */
    public TEExpenseDetailConfirmationCtrl(ApexPages.StandardSetController controller) {
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
                WHERE SobjectType  = :TEConstant.EXPENSE_DETAIL_OBJECT_NAME 
                AND IsActive = true
            ]) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description Get Requests where confirmation is not allowed
     */
    private List<Expense_Detail__c> getBlockedRequests(List<Id> ids) {
        return [SELECT Name FROM Expense_Detail__c where Id = :ids and Allow_Confirmation__c = false];
    }
    
    /**
     * @description Get the leave requests in scope
     */
    private List<Expense_Detail__c> getRequests(List<Id> ids) {
        return [SELECT 
                    Id
                    , IsDeleted
                    , Name
                    , RecordTypeId
                    , CreatedDate
                    , CreatedById
                    , LastModifiedDate
                    , LastModifiedById
                    , SystemModstamp
                    , Expense_Application__c
                    , Receipt_Date__c
                    , Amount__c
                    , Status__c
                    , Description__c
                    , Receipt_Currency__c
                    , Exchange_Rate__c
                    , Local_Amount__c
                    , Exchange_Request__c
                    , Expense_Type__c
                    , Actual_Approver_1__c
                    , On_Behalf_Of_Function__c
                    , Applicant__c
                    , Actual_Approver_2__c
                    , Actual_Approver_3__c
                    , Actual_Approver_4__c
                    , Applicant_Function__c
                    , Current_Approver__c
                    , Last_Approval_Action_Date__c
                    , Tech_Approver_1_Email__c
                    , Tech_Approver_2_Email__c
                    , Tech_Approver_3_Email__c
                    , Tech_Approver_4_Email__c
                    , On_Behalf_Of__c
                    , Allow_Confirmation__c
             
                 FROM Expense_Detail__c where Id = :ids and Allow_Confirmation__c = true];
    }
    
    /**
     * @description Post cancellation message to Chatter
     */
    /*private void postChatter(Expense_Detail__c leaveRequest) {
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
    public PageReference confirm() {
        boolean isSalesforceOne = SystemUtil.isMobileDevice();
        String labelcontext = '';
        List<Expense_Detail__c> requestsToBeConfirm = new List<Expense_Detail__c>();
        List<Id> selectedRequestIds = new List<Id>();
        Map<Id, String> recordtype = new Map<Id, String>();
        
        for (RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SobjectType  = :TEConstant.EXPENSE_DETAIL_OBJECT_NAME   AND IsActive = true
            ]) {
             
             recordtype.put ( rt.id , rt.DeveloperName );
             
         }

        if (id != null) {
            // Cancel a single leave
            selectedRequestIds.add(id);
            requestsToBeConfirm = getRequests(selectedRequestIds);
        } else if (standardController != null && standardController.getSelected() != null) {
            // Cancel multiple leave
            List<Expense_Detail__c> selectedRequests;
            selectedRequests = (List<Expense_Detail__c>) standardController.getSelected();

            for (Expense_Detail__c request : selectedRequests) {
                selectedRequestIds.add(request.id);
            }
            
            if (selectedRequestIds.size() == 0) {
                if(isSalesforceOne) {
                    this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                    this.mobileRoute.infoMessage = Label.TE_Expense_Detail_Select_One_Record;
                    return null;

                } else {
                    return new PageReference('javascript: alert(\''+ Label.TE_Expense_Detail_Select_One_Record +'\');window.history.back();');
                }
            }

            requestsToBeConfirm = getRequests(selectedRequestIds);
        } else {
            // No leave requests for cancel
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = Label.TE_Expense_Detail_Confirm_Fail;
                return null;
            } else { 
                return new PageReference('javascript: window.history.back();');
            }
        }
        
        
        
        for (Expense_Detail__c expenseDetail : requestsToBeConfirm) 
        {
            
//            if ( recordtype.get(expenseDetail.recordTypeId)  ==   LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST  )
//            {
//                if ( expenseDetail.Expense_Application__r.type__c ==  LeaveRequestConstant.LEAVE_APPLICATION_BATCH  )
//                {
                    if(isSalesforceOne) {
                        this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                        this.mobileRoute.infoMessage = (Label.TE_Expense_Detail_NOT_Confirm).replace( EXPENSEDETAILIDCODE  , expenseDetail.name);
                        return null;
                        
                    } 
/*                  else {
                        return new PageReference('javascript: alert(\''+  (Label.TE_Expense_Detail_NOT_Confirm).replace( EXPENSEDETAILIDCODE  , expenseDetail.name) + '\');window.history.back();' );
                    }

                }
*/        
                expenseDetail.status__c = TEConstant.STATUS_CONFIRMATION_NOT_SUBMITTED ; 
//            }
/*            
            else if ( recordtype.get(expenseDetail.recordTypeId).contains( LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST ) )
            {
                
                if ( expenseDetail.date__c > Date.today() )
                {
                    expenseDetail.status__c = LeaveRequestConstant.STATUS_CANCEL_NOT_SUBMITTED ; 
                }
            }
*/
        }

        String message = prepareMessage(selectedRequestIds);
       
        update requestsToBeConfirm;

        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        
        for (Expense_Detail__c expenseDetail : requestsToBeConfirm) {
            if (expenseDetail.Allow_Confirmation__c) {
                Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                psr.setObjectId(expenseDetail.id);
                requests.add(psr);
                //======It is ready for Chatter comments when Cancellation is requested========
                //postChatter(expenseDetail);
            }
        }
        if(!Test.isRunningTest()){
        	Approval.process(requests);
        }
        else{
        	 for (Expense_Detail__c expenseDetail : requestsToBeConfirm) {
                 expenseDetail.status__c = TEConstant.STATUS_CONFIRMED;
             }
            upsert requestsToBeConfirm;
        }
                
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
    
        for (Expense_Detail__c request : getBlockedRequests(ids)) {
            if (message != '') {
                message += ', ';
            }
            message += request.name;
        }
        
        if (message != '') {
            message = Label.TE_Expense_Detail_Cannot_Confirm + message;
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