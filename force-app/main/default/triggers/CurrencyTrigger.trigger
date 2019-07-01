trigger CurrencyTrigger  on Currency__c  (after insert,  before delete ) {

    if (Trigger.isAfter && Trigger.isInsert) {
        TECurrencyTriggerHandler.exchangeRateCreation(Trigger.new);
    }
    
    if (Trigger.isBefore && Trigger.isDelete) {
        TECurrencyTriggerHandler.delExchangeRate(Trigger.old);
    }
}