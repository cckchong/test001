trigger IDPPurchaseOrderItemTrigger on Purchase_Order_Item__c (before insert, before update, after update) {
    if(trigger.isBefore && trigger.isUpdate) {
        IDPPurchaseOrderItemTriggerHandler.PObudget(Trigger.newMap, Trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate) {
        IDPPurchaseOrderItemTriggerHandler.updateReceiving(Trigger.newMap, Trigger.oldMap);
        IDPPurchaseOrderItemTriggerHandler.updatePRIStatusWhenUpdatePOI(Trigger.newMap , Trigger.oldMap);        
        //IDPPurchaseOrderItemTriggerHandler.deductBudget(Trigger.newMap, Trigger.oldMap);
    }
    
}