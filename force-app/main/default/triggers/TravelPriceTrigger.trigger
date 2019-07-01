trigger TravelPriceTrigger on Travel_Price__c (before insert, before update, before delete) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {
        if(Trigger.isInsert){
            TETravelPriceTriggerHandler.updateCostCenter(Trigger.new);
        }
        TETravelPriceTriggerHandler.updateBudget(Trigger.old, Trigger.new);
    }
}