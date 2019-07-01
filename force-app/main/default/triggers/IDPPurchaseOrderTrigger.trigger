trigger IDPPurchaseOrderTrigger on Purchase_Order__c (before insert, after insert, before update, after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        //IDPPurchaseOrderTriggerHandler.initFieldValue(Trigger.NewMap, Trigger.OldMap);
        IDPPurchaseOrderTriggerHandler.poManualSharing(Trigger.NewMap, Trigger.OldMap);
        IDPPurchaseOrderTriggerHandler.recalculateBudget(Trigger.NewMap, Trigger.OldMap);
    }
    
}