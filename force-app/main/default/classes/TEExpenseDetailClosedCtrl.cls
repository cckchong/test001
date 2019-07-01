/**
 * TEExpenseDetailClosedCtrl
 * @description FIN to close Expense Detail(s)
 */
public without sharing class TEExpenseDetailClosedCtrl  {
    private ApexPages.StandardSetController standardController;
    private Id id;
    private Expense_Detail__c r {get; set;}
    private Map<Id, String> recordtype;
    private static final String EXPENSEDETAILIDCODE = '@edlD';
    private boolean isQueue = false;
    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}
    
    /**
     * @description constructor with StandardController
     */
    public TEExpenseDetailClosedCtrl (ApexPages.StandardController controller) {
        
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
    public TEExpenseDetailClosedCtrl (ApexPages.StandardSetController controller) {
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
     * @description Get Expense Details where closed is not allowed
     */
    private List<Expense_Detail__c> getBlockedRequests(List<Id> ids) {
        if (!isQueue){
            return [SELECT Name FROM Expense_Detail__c where Id = :ids];
        } else {
            return [SELECT Name FROM Expense_Detail__c where Id = :ids and Allow_Close__c = false];
        }
    }
    
    /**
     * @description Get the Expense Details in scope
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
                    , Description__c
                    , Status__c
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
                    , Allow_Close__c
                    , On_behalf_of__r.employee__r.expense_policy__r.name                    
                    FROM Expense_Detail__c where Id = :ids and Allow_Close__c = true];
    }
    

    /**
     * @description close the Expense Detail
     * @return PageReference the navigation endpoint
     */
    public PageReference close() {

        boolean isSalesforceOne = SystemUtil.isMobileDevice();
        String labelcontext = '';
        String policyName = '';
        List<Expense_Detail__c> requestsToBeClose = new List<Expense_Detail__c>();
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
            // Close a single Expense Detail
            selectedRequestIds.add(id);
            requestsToBeClose = getRequests(selectedRequestIds);
        } else if (standardController != null && standardController.getSelected() != null) {
            // Close multiple Expense Details
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

            requestsToBeClose = getRequests(selectedRequestIds);
        } else {
            // No Expense Detail for close
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = Label.TE_Expense_Detail_Close_Fail;
                return null;
            } else { 
                return new PageReference('javascript: window.history.back();');
            }
        }
        
        for (Expense_Detail__c expenseDetail : requestsToBeClose) 
        {           
            expenseDetail.status__c = TEConstant.STATUS_CLOSED_NOT_SUBMITTED;
            policyName = expenseDetail.On_behalf_of__r.employee__r.expense_policy__r.name;
        }
        isQueue = TEValidationsController.isQueueUser(policyName);
        String message = prepareMessage(selectedRequestIds);
        if (message != '') {
            // Some Expense Details cannot be closed.
            if(isSalesforceOne) {

                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = message;
                return null;
                
            } else {
                return new PageReference('javascript: alert(\'' + message + '\');window.history.back();' );
            }
        } else {
            // All Expense Details can be closed.            
            update requestsToBeClose;            
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();            
            for (Expense_Detail__c expenseDetail : requestsToBeClose) {
                if (expenseDetail.Allow_Close__c) {
                    Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                    psr.setObjectId(expenseDetail.id);
                    requests.add(psr);
                }
            }
            
            if(!Test.isRunningTest()){            
                Approval.process(requests);
            }else{
                for (Expense_Detail__c expenseApplication : requestsToBeClose) {
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
                    return new PageReference('/'+Expense_Detail__c.sObjectType.getDescribe().getKeyPrefix()+'?fcf='+ Label.TE_Expense_Detail_Pending_To_Close_List_View_ID);
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
        
        if (message != ''|| !isQueue) {
            message = (Label.TE_Expense_Detail_NOT_Close).replace( EXPENSEDETAILIDCODE, message);
            
        }
        
        return message;
    }
    
}