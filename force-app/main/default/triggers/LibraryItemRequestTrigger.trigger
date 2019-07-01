trigger LibraryItemRequestTrigger on Library_Item_Request__c (before insert, before update, after insert, after update) {

    //Check and Update Blacklist User
    LibraryItemRequestTriggerHandler.updateBlacklistUsers(Trigger.new);
    if(Trigger.isBefore) {  
        if(Trigger.isInsert) {
            LibraryItemRequestTriggerHandler.isBeforeInsert(Trigger.new);
        } else if(Trigger.IsUpdate) {
            LibraryItemRequestTriggerHandler.isBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }   
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            LibraryItemRequestTriggerHandler.isAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            LibraryItemRequestTriggerHandler.isAfterUpdate(Trigger.new);
        }
    }
}