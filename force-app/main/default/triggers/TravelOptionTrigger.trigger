trigger TravelOptionTrigger on TravelOption__c (after insert, after update, after delete) {

    if(Trigger.isinsert && Trigger.isAfter) {
        TETravelOptionTriggerHandler.chatterPost(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter) {
        TETravelOptionTriggerHandler.chatterPost(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isDelete && Trigger.isAfter) {
        TETravelOptionTriggerHandler.chatterPost(Trigger.old);
    }
}