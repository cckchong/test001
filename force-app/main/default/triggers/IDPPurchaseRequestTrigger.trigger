trigger IDPPurchaseRequestTrigger on Purchase_Request__c (before insert, After insert, before update, after update) {
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        IDPPurchaseRequestTriggerHandler.initFieldValues(Trigger.newMap, Trigger.oldMap);
        IDPPurchaseRequestTriggerHandler.isBlockApproval = IDPPurchaseRequestTriggerHandler.validatePurchaseRequestLineItem(Trigger.newMap, Trigger.oldMap);
        IDPPurchaseRequestTriggerHandler.updatePRCostCenter(Trigger.newMap, Trigger.oldMap);        
        if (!IDPPurchaseRequestTriggerHandler.isBlockApproval) {
            IDPPurchaseRequestTriggerHandler.updateCurrentApprover(Trigger.newMap, Trigger.oldMap);
            IDPPurchaseRequestTriggerHandler.updatePRBudget(Trigger.newMap, Trigger.oldMap);
            //IDPPurchaseRequestTriggerHandler.updateExchangeRate(Trigger.newMap, Trigger.oldMap);            
            //IDPPurchaseRequestTriggerHandler.deductBudget(Trigger.newMap, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        IDPPurchaseRequestTriggerHandler.deductBudget(Trigger.newMap, Trigger.oldMap);
        IDPPurchaseRequestTriggerHandler.prManualSharing(Trigger.newMap, Trigger.oldMap);
        IDPPurchaseRequestTriggerHandler.updatePurchaseRequestItemStatus(Trigger.newMap, Trigger.oldMap);
        
        
        
        //IDPPurchaseRequestTriggerHandler.updatePRIPCStandardLocalCurrencyExchangeRate(Trigger.newMap, Trigger.oldMap);
        
    }
}