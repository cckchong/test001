trigger EmployeeTrigger on Employee__c (before update, after update, after insert, before insert) {

    String[] right = Label.Employee_trigger.split(',');
    
    if (Trigger.isAfter&& (Trigger.isUpdate || Trigger.isInsert  ) ) {
        if (right[0] == '1')
        EmployeeTriggerHandler.validationRule ( Trigger.newMap, Trigger.oldMap );
    }
    
    if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert  ) ) {
        if (right[1] == '1')
        EmployeeTriggerHandler.mapUserRecord( Trigger.oldMap, Trigger.new );
    }

    if (Trigger.isBefore && Trigger.isUpdate && !EmployeeTriggerHandler.beforeTriggerEecuted) {
        //EmployeeTrigger.delegateApprovalRight(Trigger.oldMap, Trigger.newMap);
        
        EmployeeTriggerHandler.beforeTriggerEecuted = true;
    }
    
    if (Trigger.isAfter && Trigger.isUpdate && !EmployeeTriggerHandler.afterTriggerEecuted) {
        //System.debug('Will 1');
        //EmployeeTrigger.delegationApproval(Trigger.oldMap, Trigger.newMap);        
        EmployeeTriggerHandler.afterTriggerEecuted = true;
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        if (right[2] == '1')
        EmployeeTriggerHandler.createEmployeeAdministrator(Trigger.oldMap, Trigger.newMap);
    }
}