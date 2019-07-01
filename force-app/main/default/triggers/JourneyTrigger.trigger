trigger JourneyTrigger on Journey__c (before insert, after insert, before update, after update, before delete, after delete) {
    if(Trigger.isInsert && Trigger.isAfter) {
        TEJourneyTriggerHandler.addEmptyJourneyLog(Trigger.new);
    } 
    if(Trigger.isDelete && Trigger.isAfter) {
        TEJourneyTriggerHandler.addOffsetJourneyLog(Trigger.old, 'D'); //D: Deleted
    } 
    if(Trigger.isUpdate && Trigger.isAfter) {
        TEJourneyTriggerHandler.updateJourneyLog(Trigger.new, Trigger.oldMap);
    } 

/*
    if(Trigger.isInsert && Trigger.isAfter) {
        TEJourneyTriggerHandler.addJourneyLog(Trigger.new);
    } 
    
    
*/  
    
    //==========================================
    
    /*  
    if(Trigger.isbefore && Trigger.isDelete) {
        TEJourneyTriggerHandler.carAssignmentUpdate(Trigger.old);
    } else {
        TEJourneyTriggerHandler.carAssignmentUpdate(Trigger.new);
    }
    
    if (Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)){
        if(Trigger.isInsert){
            TEJourneyTriggerHandler.checkGHGSetting(Trigger.new, Trigger.oldMap, 'I');
        }
        if(Trigger.isUpdate){
            TEJourneyTriggerHandler.checkGHGSetting(Trigger.new, Trigger.oldMap, 'U');
        }
    }
    
    if (Trigger.isafter && (Trigger.isInsert || Trigger.isUpdate)){
        TEJourneyTriggerHandler.checkTripDetailsIfPlaceIsOthers(Trigger.new);
        TEJourneyTriggerHandler.checkdate(Trigger.new);
    }
    */
}