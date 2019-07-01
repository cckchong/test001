trigger IDPCatalogItemTrigger on Catalog_Item__c (before insert) {

    if(Trigger.isInsert && Trigger.isbefore) {
        //IDPCatalogItemTriggerHandler.defaultSetOwner(Trigger.new);
        
    }


}