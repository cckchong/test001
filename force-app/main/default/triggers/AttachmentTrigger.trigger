trigger AttachmentTrigger on Attachment (before delete, after insert, after update) {
    if(Trigger.IsBefore)
    {
        if(Trigger.isDelete)
        {
            AttachmentTriggerHandler.updateThumbnailId(Trigger.old, 'Delete');
            EleaveAttachmentTriggerHandler.updateSupportingDoc (Trigger.old, 'Delete');
            AttachmentTriggerHandler.checkIsAttachment(Trigger.oldMap, Trigger.new, Trigger.isDelete);
        }
    }
    else if(Trigger.IsAfter)
    {
        if(Trigger.isInsert)
        {
            AttachmentTriggerHandler.updateThumbnailId(Trigger.new, 'Insert');
            EleaveAttachmentTriggerHandler.updateSupportingDoc (Trigger.new, 'Insert');
            TETravelRequestAttachmentTriggerHandler.InsertItinerary(Trigger.new); 
            AttachmentTriggerHandler.checkIsAttachment(Trigger.oldMap, Trigger.new, Trigger.isDelete);
        }
        else if(Trigger.isUpdate)
        {
            AttachmentTriggerHandler.updateThumbnailId(Trigger.new, 'Update');
            EleaveAttachmentTriggerHandler.updateSupportingDoc (Trigger.new, 'Update');
        }
    }
}