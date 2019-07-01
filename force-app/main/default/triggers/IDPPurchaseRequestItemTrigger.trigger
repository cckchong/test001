trigger IDPPurchaseRequestItemTrigger on Purchase_Request_Item__c (after Update, before Update, before insert) {
    
    if(trigger.isBefore && trigger.isInsert) {
        IDPPurchaseRequestItemTriggerHandler.updateExchangeRate(Trigger.new, Trigger.newMap, null, 'I');
        IDPPurchaseRequestItemTriggerHandler.pendingPRBudget(Trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate) {
        IDPPurchaseRequestItemTriggerHandler.updateExchangeRate(Trigger.new, Trigger.newMap, Trigger.oldMap, 'U');
    }
    
    if(trigger.isAfter && trigger.isUpdate) {
        IDPPurchaseRequestItemTriggerHandler.updateReceiving(Trigger.newMap, Trigger.oldMap);
        //IDPPurchaseRequestItemTriggerHandler.clearSubTotal(Trigger.newMap, Trigger.oldMap);
        //IDPPurchaseRequestItemTriggerHandler.resumeBudget(Trigger.newMap, Trigger.oldMap);
        IDPPurchaseRequestItemTriggerHandler.setFullfillment(Trigger.newMap,Trigger.oldMap);
    }

}