/**
 * TECashAdvanceCancellationCtrl
 * @description Applicant to Cancel Cash Advance(s)
 * @author Kelvin Wong
 */
public without sharing class TECashAdvanceCancellationCtrl  {
    private ApexPages.StandardSetController standardController;
    private Id id;
    private Cash_Advance__c r {get; set;}
    private Map<Id, String> recordtype;
    private static final String CASHADVANCEIDCODE = '@adID';
    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}
    
    /**
     * @description constructor with StandardController
     */
    public TECashAdvanceCancellationCtrl (ApexPages.StandardController controller) {
        
        recordtype = new Map<Id, String> ();

        String textId = ApexPages.currentPage().getParameters().get('id');
        
        if (textId != null) {
            id = textId;
        }
        
        for ( RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SObjectType  = :TEConstant.CASH_ADVANCE_OBJECT_NAME 
                AND IsActive = true
            ] ) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description constructor with StandardSetController
     */
    public TECashAdvanceCancellationCtrl (ApexPages.StandardSetController controller) {
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
                WHERE SobjectType  = :TEConstant.CASH_ADVANCE_OBJECT_NAME 
                AND IsActive = true
            ]) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
    
    /**
     * @description Get Cash Advances where cancellation is not allowed
     */
    private List<Cash_Advance__c> getBlockedRequests(List<Id> ids) {
        return [SELECT Name FROM Cash_Advance__c where Id = :ids and Allow_Cancel__c = false];
    }
    
    /**
     * @description Get the Cash Advance in scope
     */
    private List<Cash_Advance__c> getRequests(List<Id> ids) {
        return [SELECT 
                    Id, Name, RecordTypeId, Tech_Expense_Policy_Finance_Email__c, Applicant__c, Applicant_Function__c, Applicant_Grade__c, Travel_Application__c, 
                    Travel_Application_Status__c, Expected_Collection_Date__c, Travel_Application_Status_Label__c, On_Behalf_Of_Grade__c, 
                    On_Behalf_Of_Function__c, Allow_Cancel__c, Allow_Return__c, Allow_Paid_Out__c, Amount__c, Apply_Date__c, Currency__c, Late_Application__c, Status__c, 
                    On_Behalf_Of__c, Tech_Currency_Date__c,   Local_Amount__c
             
                 FROM Cash_Advance__c where Id = :ids and Allow_Cancel__c = true];
    }
    
    /**
     * @description cancel the Cash Advance
     * @return PageReference the navigation endpoint
     */
    public PageReference cancel() {
        boolean isSalesforceOne = SystemUtil.isMobileDevice();
        String labelcontext = '';
        List<Cash_Advance__c> requestsToBeCancel = new List<Cash_Advance__c>();
        List<Id> selectedRequestIds = new List<Id>();
        Map<Id, String> recordtype = new Map<Id, String>();
        
        for (RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SobjectType  = :TEConstant.CASH_ADVANCE_OBJECT_NAME   AND IsActive = true
            ]) {
             
             recordtype.put ( rt.id , rt.DeveloperName );
             
         }

        if (id != null) {
            // Cancel a single Cash Advance
            selectedRequestIds.add(id);
            requestsToBeCancel = getRequests(selectedRequestIds);
        } else if (standardController != null && standardController.getSelected() != null) {
            // Cancel multiple Cash Advance
            List<Cash_Advance__c> selectedRequests;
            selectedRequests = (List<Cash_Advance__c>) standardController.getSelected();

            for (Cash_Advance__c request : selectedRequests) {
                selectedRequestIds.add(request.id);
            }
            
            if (selectedRequestIds.size() == 0) {
                if(isSalesforceOne) {
                    this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                    this.mobileRoute.infoMessage = Label.TE_Cash_Advance_Select_One_Record;
                    return null;

                } else {
                    return new PageReference('javascript: alert(\''+ Label.TE_Cash_Advance_Select_One_Record +'\');window.history.back();');
                }
            }

            requestsToBeCancel = getRequests(selectedRequestIds);
        } else {
            // No Cash Advance for cancel
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = Label.TE_Cash_Advance_Cancel_Fail;
                return null;
            } else { 
                return new PageReference('javascript: window.history.back();');
            }
        }
        
        
        
        for (Cash_Advance__c cashAdvance : requestsToBeCancel) 
        {            
            cashAdvance.status__c = TEConstant.STATUS_CANCEL_NOT_SUBMITTED;
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
            
            for (Cash_Advance__c cashAdvance : requestsToBeCancel) {
                if (cashAdvance.Allow_Cancel__c) {
                    Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                    psr.setObjectId(cashAdvance.id);
                    requests.add(psr);
                    
                }
            }
            
            if(!Test.isRunningTest()){            
                Approval.process(requests);
            }else{
                for (Cash_Advance__c cashAdvance : requestsToBeCancel) {
                    cashAdvance.status__c = TEConstant.STATUS_CANCELLED;
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
    
        for (Cash_Advance__c request : getBlockedRequests(ids)) {
            if (message != '') {
                message += ', ';
            }
            message += request.name;
        }
        
        if (message != '') {
            message = Label.TE_Cash_Advance_Cannot_Cancel + ' ' + message;
        }
        
        return message;
    }
    
}