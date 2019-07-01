trigger CustomerOrderLogTrigger on Customer_Order_Log__c (before insert, before update, before delete, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
        	CustomerOrderLogTriggerHandler.handleBeforeUpdate(trigger.oldMap, trigger.newMap);
        }
        
        if (Trigger.isInsert) {
        	CustomerOrderLogTriggerHandler.handleBeforeInsert(trigger.new);
        
        }
        
        if (Trigger.isDelete) {
            CustomerOrderLogTriggerHandler.handleBeforeDelete(trigger.old);

        }
        
    } else if (Trigger.isAfter) {
    	CustomerOrderLogTriggerHandler.handleAfterUpdate(trigger.oldMap, trigger.newMap);
    	
    }
}