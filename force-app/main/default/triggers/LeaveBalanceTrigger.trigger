trigger LeaveBalanceTrigger on Leave_Balance__c (after insert, after update, before insert, before update) {
    
    // Setup additional surrogate keys
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        LeaveBalanceTriggerHandler.setEmployeeIdLeaveTypeKey(Trigger.new);
    }
    
    if(Trigger.isInsert && Trigger.isAfter) {
        
        LeaveBalanceTriggerHandler.markLatestRecordNew(null, Trigger.new);
        //LeaveBalanceTriggerHandler.indexLatestRecord(null, Trigger.new);
        
    } else if(Trigger.isUpdate && Trigger.isBefore) {
        
        LeaveBalanceTriggerHandler.preventUpdateOfCoreFields(Trigger.oldMap, Trigger.new);
        
    } else if(Trigger.isUpdate && Trigger.isAfter) {
        LeaveBalanceTriggerHandler.markLatestRecordNew(Trigger.oldMap, Trigger.new);
        //LeaveBalanceTriggerHandler.indexLatestRecord(Trigger.oldMap, Trigger.new);
        
    }
}