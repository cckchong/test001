trigger IDPSupplierItemTrigger on Supplier_Item__c (before insert, after insert, before update, after update, after delete) {

    if(Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)) {
        IDPSupplierItemTriggerHandler.updateSupplierItemCurrency(Trigger.new);
    }
    
    if(Trigger.isbefore && Trigger.isUpdate) {
        IDPSupplierItemTriggerHandler.updateUpdatePriceModifiedDate(Trigger.oldMap, Trigger.newMap);
    }
    
    if(Trigger.isafter && Trigger.isUpdate) {
        IDPSupplierItemTriggerHandler.updateUpdatePriceForBestSupplier(Trigger.oldMap, Trigger.newMap);
    }
    
    if(Trigger.isafter && Trigger.isInsert) {
        IDPSupplierItemTriggerHandler.updateBestSupplier(Trigger.new);
    }
    
    if(Trigger.isafter && Trigger.isDelete) {
        IDPSupplierItemTriggerHandler.updateBestSupplier(Trigger.old);
    }
}