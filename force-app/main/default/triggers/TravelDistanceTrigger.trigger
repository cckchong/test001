trigger TravelDistanceTrigger on Travel_Distance__c (before insert, before update, after insert) {

    if((Trigger.isinsert || Trigger.isupdate) && Trigger.isbefore){
        TravelDistanceTriggerHandler.checkFlightTypeWithDistance(Trigger.oldMap, Trigger.new, Trigger.isInsert);
    }
    
    if((Trigger.isinsert) && Trigger.isafter){
        TravelDistanceTriggerHandler.createCarbonEmission(Trigger.newMap);
    }
}