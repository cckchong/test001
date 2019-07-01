trigger LeaveRequestTrigger  on Leave_Request__c (   before update, before insert , after update) 
{
    LeaveRequestTriggerHandler lrt = null;
    if(Trigger.isUpdate && Trigger.isBefore)
    {
        lrt = new LeaveRequestTriggerHandler (Trigger.new , Trigger.oldMap);
        lrt.runupdate();
    }
    
    if (Trigger.isUpdate && Trigger.isAfter) {       
        ELeaveMeetingRequestHandler.process(Trigger.oldMap, Trigger.newMap);
        LeaveRequestTriggerHandler.chatterPost(Trigger.newMap, Trigger.oldMap);
    }
    
    if(Trigger.isinsert)
    {
        lrt = new LeaveRequestTriggerHandler (Trigger.new , Trigger.oldMap);
        lrt.runinsert();        
    }

}