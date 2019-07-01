trigger Portal_ContentTrigger on Portal_Content__c (before insert, before update, after insert, after update) {
    /*
    RecordType rtRichText = [Select Id, Name From RecordType Where Developername = 'Rich_Text' limit 1];
    if(Trigger.IsBefore)
    {
        if(Trigger.isInsert)
        {
            //Store the created date and last modified date to custom field
            Portal_ContentTriggerHandler.storeCreatedDateAndLastModdate(Trigger.new, rtRichText);
            //Insert two tech fields for List view security
            Portal_ContentTriggerHandler.insertFieldsforListViewSecurity(Trigger.new);
        }
        if(Trigger.isUpdate)
        {
            //Add [REVISED] to the title of article announcement
            Portal_ContentTriggerHandler.addReviseWord(Trigger.new, Trigger.oldMap, rtRichText);
            //Store the created date and last modified date to custom field
            Portal_ContentTriggerHandler.storeCreatedDateAndLastModdate(Trigger.new, rtRichText);
            //Ensure Distribution Site is defined
            Portal_ContentTriggerHandler.ensureSubCatIsDefined(Trigger.new, rtRichText);
            //Update two tech fields for List view security
            Portal_ContentTriggerHandler.updateFieldsforListViewSecurity(Trigger.oldMap, Trigger.newMap);
        }
    } else {
        Portal_ContentTriggerHandler.calculateSharing(Trigger.oldMap, Trigger.newMap);
    }
    */
}