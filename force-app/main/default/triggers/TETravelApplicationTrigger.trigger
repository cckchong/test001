trigger TETravelApplicationTrigger on Travel_Application__c (before insert, before delete, before update, after update, after insert) {


    if(Trigger.isUpdate && Trigger.isBefore) {
        TETravelApplicationTriggerHandler.initFieldValues(Trigger.new, Trigger.oldMap);
        TETravelApplicationTriggerHandler.taSharing(Trigger.newMap , Trigger.oldMap);
        TETravelApplicationTriggerHandler.chatterPost(Trigger.newMap, Trigger.oldMap);
        TETravelApplicationTriggerHandler.compensationLeavecalculation(Trigger.new, Trigger.oldMap);
    } 
    
    
    if(Trigger.isUpdate && Trigger.isAfter) {
        TETravelApplicationTriggerHandler.synupTravelApplicationStatusWithCashAdvanceStatus(Trigger.newMap , Trigger.oldMap);        
        TETravelApplicationTriggerHandler.SendEmail(Trigger.newMap , Trigger.oldMap);
        TEMeetingRequestHandler.process(Trigger.oldMap, Trigger.newMap);
    } 
    
}