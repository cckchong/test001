trigger TEEducationApplicationTrigger on Education_Application__c (before insert, before update) {
    
    if (trigger.isinsert&& trigger.isBefore){
        //TEEducationApplicationTriggerHandler.defValues(Trigger.new);
        TEValidationsController.checkOverlappedEducationApplication(Trigger.new, Trigger.oldMap);
    }
    
    if (trigger.isUpdate && trigger.isBefore){
        TEEducationApplicationTriggerHandler.sendHCMAfterApproval(Trigger.new, Trigger.oldMap);
        TEEducationApplicationTriggerHandler.initFieldValues(Trigger.newMap, Trigger.oldMap);
        TEValidationsController.checkOverlappedEducationApplication(Trigger.new, Trigger.oldMap);

    }

}