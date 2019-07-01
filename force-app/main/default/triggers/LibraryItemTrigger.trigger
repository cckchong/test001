trigger LibraryItemTrigger on Library_Item__c (before insert, after insert, after update, before update) {
        
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert) {
            //LibraryItemTriggerHandler.preventCloneNullItem(Trigger.new);  
            //Added by TAL (Twinkle LI) @20170718
            LibraryItemTriggerHandler.updateRequireApproval(Trigger.new);  
        }
        LibraryItemTriggerHandler.updateWarehouseTechOwner(Trigger.new);
        LibraryItemTriggerHandler.concatenateContent(Trigger.new);
        LibraryItemTriggerHandler.updateFabricFinishingText(Trigger.new);    
    }
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert) {
            LibraryItemTriggerHandler.createInventory(Trigger.new);
        }
        if(Trigger.isUpdate)
        {
            LibraryItemTriggerHandler.updateRequestApprovers(Trigger.newMap, Trigger.OldMap);
            LibraryItemTriggerHandler.getFlsFabricRecords(Trigger.newMap, Trigger.oldMap);
            LibraryItemTriggerHandler.updateRelatedInventory(Trigger.newMap, Trigger.oldMap);           
        } else if(Trigger.isInsert) {
            LibraryItemTriggerHandler.getFlsFabricRecords(Trigger.newMap, null);
        }
    }
}