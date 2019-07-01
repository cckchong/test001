trigger CollaborationGroupTrigger on CollaborationGroup (before update) {
	
    if(Trigger.isBefore && Trigger.isUpdate) {
        CollaborationGroupTriggerHandler.validateOnlyOwnerCanUpdateGroup(Trigger.oldMap, Trigger.newMap);
    }
}