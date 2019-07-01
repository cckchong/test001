/**
 * TEExpenseApplicationCancellationCtrl
 * @description Applicant to Cancel Expense Application(s)
 * @author Ted Pang
 */
public without sharing class TEExpenseApplicationCancellationCtrl  {
    private ApexPages.StandardSetController standardController;
    private Id id;
    private Expense_Application__c r {get; set;}
    private Map<Id, String> recordtype;
    private static final String EXPENSEAPPLICATIONIDCODE = '@eaID';
    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}
    
    /**
     * @description constructor with StandardController
     */
    public TEExpenseApplicationCancellationCtrl (ApexPages.StandardController controller) {
        
        recordtype = new Map<Id, String> ();

        String textId = ApexPages.currentPage().getParameters().get('id');
        
        if (textId != null) {
            id = textId;
        }
        
        for ( RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SObjectType  = :TEConstant.EXPENSE_APPLICATION_OBJECT_NAME 
                AND IsActive = true
            ] ) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description constructor with StandardSetController
     */
    public TEExpenseApplicationCancellationCtrl (ApexPages.StandardSetController controller) {
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
                WHERE SobjectType  = :TEConstant.EXPENSE_APPLICATION_OBJECT_NAME 
                AND IsActive = true
            ]) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description Get Requests where cancellation is not allowed
     */
    private List<Expense_Application__c> getBlockedRequests(List<Id> ids) {
        return [SELECT Name FROM Expense_Application__c where Id = :ids and Allow_Cancel__c = false];
    }
    
    /**
     * @description Get the Expense Application in scope
     */
    private List<Expense_Application__c> getRequests(List<Id> ids) {
        return [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, 
                LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
                Apply_Date__c, On_Behalf_Of__c, Remarks__c, Applicant_Function__c, On_Behalf_Of_Function__c, 
                Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, 
                Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Status__c, Education_Application__c, Travel_Application__c, 
                Mine__c, Total_Amount__c, Applicant__c, Education_Application_Status__c, Travel_Application_Status__c, 
                Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Last_Approval_Action_Date__c, 
                Current_Approver__c, Actual_Total_Amount__c, Actual_Total_Amount_to_Reimburse__c, Tech_Expense_Policy_Finance_Email__c, Tech_Expense_Policy__c, 
                Tech_Applicant__c, Total_Cash_Advance__c,  Currency__c, 
                Allow_Cancel__c, Expense_Type__c
                FROM Expense_Application__c where Id = :ids and Allow_Cancel__c = true];
    }
    
    /**
     * @description cancel the Expense Application
     * @return PageReference the navigation endpoint
     */
    public PageReference cancel() {
        boolean isSalesforceOne = SystemUtil.isMobileDevice();
        String labelcontext = '';
        List<Expense_Application__c> requestsToBeCancel = new List<Expense_Application__c>();
        List<Id> selectedRequestIds = new List<Id>();
        Map<Id, String> recordtype = new Map<Id, String>();
        
        for (RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SobjectType  = :TEConstant.EXPENSE_APPLICATION_OBJECT_NAME   AND IsActive = true
            ]) {
             
             recordtype.put ( rt.id , rt.DeveloperName );
             
         }

        if (id != null) {
            // Cancel a single Expense Application
            selectedRequestIds.add(id);
            requestsToBeCancel = getRequests(selectedRequestIds);
        } else if (standardController != null && standardController.getSelected() != null) {
            // Cancel multiple Expense Application(s)
            List<Expense_Application__c> selectedRequests;
            selectedRequests = (List<Expense_Application__c>) standardController.getSelected();

            for (Expense_Application__c request : selectedRequests) {
                selectedRequestIds.add(request.id);
            }
            
            if (selectedRequestIds.size() == 0) {
                if(isSalesforceOne) {
                    this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                    this.mobileRoute.infoMessage = Label.TE_Expense_Application_Select_One_Record;
                    return null;

                } else {
                    return new PageReference('javascript: alert(\''+ Label.TE_Expense_Application_Select_One_Record +'\');window.history.back();');
                }
            }

            requestsToBeCancel = getRequests(selectedRequestIds);
        } else {
            // No requests for cancel
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = Label.TE_Expense_Application_Cancel_Fail;
                return null;
            } else { 
                return new PageReference('javascript: window.history.back();');
            }
        }
        
        
        
        for (Expense_Application__c expenseApplication : requestsToBeCancel) 
        {
            expenseApplication.status__c = TEConstant.STATUS_CANCEL_NOT_SUBMITTED ; 
        }

        String message = prepareMessage(selectedRequestIds);
       
      
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
            
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            
            for (Expense_Application__c expenseApplication : requestsToBeCancel) {
                if (expenseApplication.Allow_Cancel__c) {
                    Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                    psr.setObjectId(expenseApplication.id);
                    requests.add(psr);
                }
            }
            
            if(!Test.isRunningTest()){            
                Approval.process(requests);
            }else{
                for (Expense_Application__c expenseApplication : requestsToBeCancel) {
                    expenseApplication.status__c = TEConstant.STATUS_CANCELLED;
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
    
        for (Expense_Application__c request : getBlockedRequests(ids)) {
            if (message != '') {
                message += ', ';
            }
            message += request.name;
        }
        
        if (message != '') {
            message = Label.TE_Expense_Application_Cannot_Cancel + ' ' + message;
        }
        return message;
    }
}