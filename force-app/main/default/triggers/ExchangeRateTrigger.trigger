trigger ExchangeRateTrigger  on Exchange_Rate__c ( before insert, after insert, after update, before update ) {
    
    if ( trigger.isbefore && (trigger.isinsert || trigger.isupdate) ){
        TEExchangeRateTriggerHandler.updateFromToCurrencyType(Trigger.new);
    }
    
    
    if ( trigger.isafter && trigger.isinsert ){
        TEExchangeRateTriggerHandler.updateIsLatest(null, Trigger.new);
    }
    
    if ( trigger.isafter && trigger.isupdate ){
        TEExchangeRateTriggerHandler.updateIsLatest(Trigger.oldMap, Trigger.New);
    }

}