trigger IDPCatalogTrigger on Catalog__c (before insert, before update, after insert, after update) {

/*
    if ( trigger.isbefore && (trigger.isinsert || trigger.isupdate) ){
        IDPCatalogTriggerHandler.setLevelOneCatalogOwner(Trigger.new);
    }
*/
    if ( trigger.isbefore && trigger.isinsert ){
        IDPCatalogTriggerHandler.setLevelTwoCatalogOwnerId(Trigger.new);
    }
    
    if ((trigger.isafter && trigger.isinsert) || (trigger.isafter && trigger.isUpdate)){
        IDPCatalogTriggerHandler.setLevelOneTwoCatalogOwnerSame(Trigger.new);
    }
        
}