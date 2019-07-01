trigger TECashAdvanceTrigger on Cash_Advance__c (Before insert,After insert,Before update,after update, After Delete) {
   
    if (Trigger.isInsert && Trigger.isBefore) {
        TECashAdvanceTriggerHandler.defaultStatus(Trigger.new, Trigger.oldMap);
    }    
    if (Trigger.isInsert && Trigger.isAfter) {
        TECashAdvanceTriggerHandler.addExpenseDetailLogUponUpdate(Trigger.newMap, Trigger.oldMap);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        TECashAdvanceTriggerHandler.updateExchangeRate(Trigger.newMap, Trigger.oldMap);
        TECashAdvanceTriggerHandler.accountNumberSetup(Trigger.newMap, Trigger.oldMap);
        
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        TECashAdvanceTriggerHandler.updateCashAdvContent(Trigger.newMap, Trigger.oldMap);
        TECashAdvanceTriggerHandler.addExpenseDetailLogUponUpdate(Trigger.newMap, Trigger.oldMap);
    }
}