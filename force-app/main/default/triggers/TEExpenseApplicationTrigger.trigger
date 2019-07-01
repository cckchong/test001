trigger TEExpenseApplicationTrigger on Expense_Application__c (before update, after update, after insert, before insert, before delete) {
    
    
    if (Trigger.Isafter && Trigger.isUpdate) {
        TEValidationsController.checkOneExpenseToOneTravelApplication(Trigger.newMap, Trigger.oldMap);
        TEExpenseApplicationTriggerHandler.updateTechExpenseApp(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.Isbefore && (Trigger.isUpdate || Trigger.isInsert  ) ) {
        TEExpenseApplicationTriggerHandler.synupRecordTypeWithExpenseType(Trigger.new, Trigger.oldMap);
        if (Trigger.isUpdate){
            TEExpenseApplicationTriggerHandler.initFieldValuesForBatch(Trigger.new, Trigger.oldMap, 'U');
        }
        
        if (Trigger.isInsert){
            TEExpenseApplicationTriggerHandler.initFieldValuesForBatch(Trigger.new, Trigger.oldMap, 'I');
        }
    }
    
    
    if (Trigger.Isbefore && Trigger.isUpdate) {
        TEExpenseApplicationTriggerHandler.initFieldValues(Trigger.newMap , Trigger.oldMap);
        TEValidationsController.blockApplicantRecallExpenseApplicationWhenPAC(Trigger.newMap , Trigger.oldMap);
        TEExpenseApplicationTriggerHandler.closeRelatedCashAdvance(Trigger.newMap , Trigger.oldMap);        
        TEValidationsController.checkExistingExpenseDetail(Trigger.newMap, Trigger.oldMap);
    }
    if (Trigger.IsAfter && Trigger.isUpdate ) {
        
        TEExpenseApplicationTriggerHandler.synupApplicationStatusWithDetailStatus(Trigger.newMap , Trigger.oldMap );
        //TEValidationsController.blockApplicantModifyExpenseApplicationWhenPAC(Trigger.newMap , Trigger.oldMap);
    }
    
}