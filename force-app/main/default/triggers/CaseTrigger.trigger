trigger CaseTrigger on Case (before insert, before update, after update) {

    if (trigger.isBefore && trigger.isInsert) {
        CaseTriggerHandler.handleBeforeInsert(trigger.new);
    }
    
    if (trigger.isBefore && trigger.isUpdate) {
        CaseTriggerHandler.handleBeforeUpdate(trigger.new);
    }
    
    if (trigger.isAfter && trigger.isUpdate) {
        CaseTriggerHandler.markClose(trigger.oldMap, trigger.newMap);
    }
}