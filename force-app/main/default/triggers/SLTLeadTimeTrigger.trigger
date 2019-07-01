trigger SLTLeadTimeTrigger on Lead_Time__c (before update, before delete) {

    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isDelete)) {
        SLTLeadTimeTriggerHandler.blockUpdateDeleteRecord(Trigger.NewMap, Trigger.OldMap);
    
    }
}