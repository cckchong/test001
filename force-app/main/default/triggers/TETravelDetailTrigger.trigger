trigger TETravelDetailTrigger on Travel_Detail__c (before insert, after insert, before update, after update, before delete) {
    
    if(Trigger.isbefore && Trigger.isUpdate) {
        TETravelDetailTriggerHandler.shuttleAssignmentUpdate(Trigger.oldMap, Trigger.new);
    }
}