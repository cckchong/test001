trigger SLTSampleTrigger on Sample__c (before insert, before update) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        SLTSampleTriggerHandler.updateTechSiteName(Trigger.New);
        SLTSampleTriggerHandler.retrieveLeadTimeMode(Trigger.New); //Added by TAL (Twinkle Li) @20170703
    }
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
//    if(Trigger.isBefore && Trigger.isInsert){
        SLTSampleTriggerHandler.updateTechSiteName(Trigger.New);
        SLTSampleTriggerHandler.getFactoryHoliday(Trigger.new);
        SLTSampleTriggerHandler.retrieveStandardLeadTime(Trigger.new); //Added by TAL (Twinkle Li) @20170818
    }
}