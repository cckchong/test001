/**
 * TEExpenseAppClosedCtrl
 * @description FIN to close Expense Application(s)
 */
public without sharing class TEExpenseAppClosedCtrl  {
    private ApexPages.StandardSetController standardController;
    private Id id;
    private Expense_Application__c r {get; set;}
    private Map<Id, String> recordtype;
    private static final String EXPENSEDETAILIDCODE = '@ealD';
    private boolean isQueue = false;
    
    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}
    
    /**
     * @description constructor with StandardController
     */
    
    public TEExpenseAppClosedCtrl (ApexPages.StandardController controller) {
        
        recordtype = new Map<Id, String> ();

        String textId = ApexPages.currentPage().getParameters().get('id');
        
        if (textId != null) {
            id = textId;
        }
        else{ 
            Expense_Application__c a = (Expense_Application__c)controller.getRecord();
            id  = a.id;
            
        }
        
        for ( RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SObjectType  = :TEConstant.EXPENSE_DETAIL_OBJECT_NAME 
                AND IsActive = true
            ] ) {
            recordtype.put (rt.id, rt.DeveloperName );
        }
    }
    
    /**
     * @description constructor with StandardSetController
     */
    public TEExpenseAppClosedCtrl (ApexPages.StandardSetController controller) {
        this.standardController = controller;
        
        recordtype = new Map<Id, String> ();

        String textId = ApexPages.currentPage().getParameters().get('id');
        
        if (textId != null) {
            id = textId;
        }
        
        /*
        for ( RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SobjectType  = :TEConstant.EXPENSE_DETAIL_OBJECT_NAME 
                AND IsActive = true
            ]) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
        */
    }
    
    /**
     * @description Get Expense Application where closed is not allowed
     */
    private List<Expense_Application__c> getBlockedRequests(List<Id> ids) {
        if (!isQueue){
            return [SELECT Name FROM Expense_Application__c where Id = :ids];
        } else {
            return [SELECT Name FROM Expense_Application__c where Id = :ids and Allow_Close__c = false];
        }
    }
    /**
     * @description Get the Expense Application in scope
     */
    private List<Expense_Application__c> getRequests(List<Id> ids) {
        return [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate,
                CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,
                LastViewedDate, LastReferencedDate, Apply_Date__c, On_Behalf_Of__c,
                Remarks__c, Applicant_Function__c, On_Behalf_Of_Function__c, Copy_to_1__c,
                Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c,
                Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Status__c,
                Education_Application__c, Travel_Application__c, Mine__c, Applicant__c,
                Education_Application_Status__c, Travel_Application_Status__c, Actual_Approver_1__c,
                Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Last_Approval_Action_Date__c,
                Current_Approver__c, Actual_Total_Amount_to_Reimburse__c, Tech_Expense_Policy_Finance_Email__c,
                Tech_Expense_Policy__c, Tech_Applicant__c, Total_Cash_Advance__c, 
                Currency__c, Expense_Type__c, Allow_Cancel__c, Allow_Close__c,
                Actual_Total_Amount__c, Total_Amount__c,
                On_behalf_of__r.employee__r.expense_policy__r.name
                FROM Expense_Application__c where Id = :ids and Allow_Close__c = true];
        //}
    }
    /**
     * @description Close the Expense Application
     * @return PageReference the navigation endpoint
     */
    public PageReference close() {
        String policyName;
        boolean isSalesforceOne = SystemUtil.isMobileDevice();
        String labelcontext = '';
        List<Expense_Application__c> requestsToBeClose = new List<Expense_Application__c>();
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
            // Close a single Expense Application
            selectedRequestIds.add(id);
            requestsToBeClose = getRequests(selectedRequestIds);
        } else if (standardController != null && standardController.getSelected() != null) {
            // Close multiple Expense Application
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

            requestsToBeClose = getRequests(selectedRequestIds);
        } else {
            // No Expense Application for close
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = Label.TE_Expense_Application_Close_Fail;
                return null;
            } else { 
                return new PageReference('javascript: window.history.back();');
            }
        }
        policyName = '';
        for (Expense_Application__c expenseDetail : requestsToBeClose){     
            expenseDetail.status__c = TEConstant.STATUS_CLOSED_NOT_SUBMITTED;
            policyName = expenseDetail.On_behalf_of__r.employee__r.expense_policy__r.name;
        }
        isQueue = TEValidationsController.isQueueUser(policyName);
        String message = prepareMessage(selectedRequestIds);
                
        if (message != '') {
            // Some Expense Applications cannot be closed.
            if(isSalesforceOne) {

                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = message;
                return null;
                
            } else {
                return new PageReference('javascript: alert(\'' + message + '\');window.history.back();' );
            }
        } else {
            // All Expense Applications can be cancelled.
            update requestsToBeClose;
            
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            
            for (Expense_Application__c expenseDetail : requestsToBeClose) {
                if (expenseDetail.Allow_Close__c) {
                    Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                    psr.setObjectId(expenseDetail.id);
                    requests.add(psr);
                }
            }
            
            if(!Test.isRunningTest()){            
                Approval.process(requests);
            }else{
                for (Expense_Application__c expenseApplication : requestsToBeClose) {
                    expenseApplication.status__c = TEConstant.STATUS_CLOSED;
                }
                upsert requestsToBeClose;
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
        
        if (message != ''|| !isQueue) {
            message = (Label.TE_Expense_Application_NOT_Close).replace( EXPENSEDETAILIDCODE, message );
        }
        
        return message;
    }

}