trigger TECarbonEmissionTrigger on Carbon_Emission__c (before insert, before update) {
    TECarbonEmissionTriggerHandler.checkDistanceWithGHGFactor(Trigger.oldMap, Trigger.new, Trigger.isInsert);
}