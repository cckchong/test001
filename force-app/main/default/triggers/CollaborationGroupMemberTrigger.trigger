trigger CollaborationGroupMemberTrigger on CollaborationGroupMember (before insert, before update, before delete) {
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert || Trigger.isDelete)) {
		   CollaborationGroupMemberTriggerHandler.validateOnlyOwnerCanUpdateGroup(Trigger.oldMap, Trigger.newMap, Trigger.new);
    }
}