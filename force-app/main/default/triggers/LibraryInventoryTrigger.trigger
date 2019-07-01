/**
 * @description Trigger for Library Inventory
 */
trigger LibraryInventoryTrigger on Library_Inventory__c (before update, after insert, after update) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            
        }
        else if(Trigger.IsUpdate) {
            LibraryInventoryTriggerHandler.preventUpdateStatus(Trigger.new, Trigger.oldMap);
            LibraryInventoryTriggerHandler.preventUpdateLocation(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            LibraryInventoryTriggerHandler.isAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            LibraryInventoryTriggerHandler.isAfterUpdate(Trigger.newMap, Trigger.oldMap);   
        }
    }
}