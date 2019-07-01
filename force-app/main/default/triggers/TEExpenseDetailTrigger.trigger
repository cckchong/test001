trigger TEExpenseDetailTrigger on Expense_Detail__c (before insert, before update, after update) {
    
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        TEExpenseDetailTriggerHandler.checkAmountPositive(trigger.new);
    }
    
    if (Trigger.isUpdate && Trigger.isBefore) {
        TEExpenseDetailTriggerHandler.initFieldValues(trigger.newMap, trigger.oldMap);
        TEValidationsController.blockApplicantRecallExpenseDetailWhenPAC(Trigger.newMap , Trigger.oldMap);
        TEExpenseDetailTriggerHandler.updateExchangeRate(trigger.newMap, trigger.oldMap);
        TEExpenseDetailTriggerHandler.uncheckAllowtoExceedMaxCap(trigger.newMap, trigger.oldMap);
        
    }

  
    if (Trigger.isUpdate && Trigger.isAfter) {
        //TEValidationsController.blockApplicantModifyExpenseDetailWhenPAC(Trigger.newMap , Trigger.oldMap);
        TEExpenseDetailTriggerHandler.deductBudget(Trigger.newMap , Trigger.oldMap);
        TEExpenseDetailTriggerHandler.addExpenseDetailLogUponUpdate(Trigger.newMap , Trigger.oldMap);
    }
    

}