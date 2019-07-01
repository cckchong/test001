trigger EmployeeAdministratorTrigger  on Employee_Administrator__c  (After update, After insert )  {
 
     EmployeeAdministratorTriggerHandler employeeAdministratorTrigger = new EmployeeAdministratorTriggerHandler ();
     
      if (Trigger.isAfter){
         if (Trigger.isUpdate){
             employeeAdministratorTrigger.afterUpdate (Trigger.newMap, Trigger.oldMap);
         }
         if (Trigger.isInsert){
             employeeAdministratorTrigger.afterInsert (Trigger.new);
         }
     }
}