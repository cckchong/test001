/**
 * EmployeeNotificationBatch
 * @description Handle scheduled notificatoins on the Site object
 * @date 14/01/2015
 * @author Andrew Ng
 */
global class EmployeeNotificationBatch implements Database.Batchable<sObject>, Database.Stateful {

    /**
     * Method Name: Start
     * Description: Query All the Account for which tasks need to be created.
     * Return Type: Database.QueryLocator
     * Parameter: Database.BatchableContext
     */
    global Database.QueryLocator start(Database.BatchableContext BC){

        //prepare query to fetch account
        String queryStr =   ' SELECT Id, Name, Full_Name__c, Department__c, Notif_Leave_Forfeiture__c, User__c, ' +
                            ' (SELECT Id, Administrator__c, Employee__c FROM Employee_Administrators__r) ' +
                            ' FROM Employee__c ' +
                            ' WHERE Notif_Leave_Forfeiture__c = true';
                            //' Where id = \'a0EO0000009Qb8y\'';
                            
        
        System.debug('### queryStr ### ' + queryStr);

        return Database.getQueryLocator(queryStr);
    }


    /*
    * Method Name: Execute
    * Description:
    * Return Type: nil
    * Parameter: Database.BatchableContext, List<sObject>
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){

        List<Task> taskList = new List<Task>();

        //Fetch task information from Custom Settings
        CS_Notification_Management__c forfeitReminder = CS_Notification_Management__c.getInstance('Leave_Forfeit_Notification');
        Date todayDate =  Date.newInstance( System.today().Year(), System.today().Month(), 1).addMonths(1).addDays(-1); 

        String taskSubject = null;
        String taskSubjectEa = null;
        String taskType = null;
        Date targetDate = null;
        String taskDescription = null;
        
        // For all employees that need to be notified, first
        // query out all their Leave Balances where To_Be_Forfeited_Next_Period__c > 0
        // then create and assign a task to those individuals
        Map<Id, List<Leave_Balance__c>> employeeIdToLeaveBalances = new Map<Id, List<Leave_Balance__c>>();
        for(Leave_Balance__c lb : 
            [
                SELECT Id, To_Be_Forfeited_Next_Period_Display__c, Leave_Type_Label__c, Year__c, Month__c, Employee__c
                FROM Leave_Balance__c
                WHERE Employee__c IN :scope
                AND Is_Latest__c = true
                AND To_Be_Forfeited_Next_Period__c > 0
            ]) {
    
            if(employeeIdToLeaveBalances.get(lb.Employee__c) != null) {
                List<Leave_Balance__c> lbList = employeeIdToLeaveBalances.get(lb.Employee__c);
                lbList.add(lb);
                employeeIdToLeaveBalances.put(lb.Employee__c, lbList);
            } else {
                List<Leave_Balance__c> lbList = new List<Leave_Balance__c>();
                lbList.add(lb);
                employeeIdToLeaveBalances.put(lb.Employee__c, lbList);
            }
            
        }
        List<Employee__c> employeeList = (List<Employee__c>) scope;
        for(Employee__c emp : employeeList) {
            if( Test.isRunningtest() || emp.Notif_Leave_Forfeiture__c == true) {
                taskSubject = forfeitReminder.Activity_Subject__c;
                taskSubjectEa = forfeitReminder.Activity_Subject_2__c;
                taskType = forfeitReminder.Activity_Type__c;
                targetDate = todayDate;
                
                if(employeeIdToLeaveBalances.get(emp.Id) != null) {
                    List<Leave_Balance__c> lbList = employeeIdToLeaveBalances.get(emp.Id);
                    //taskDescription =  emp.Full_Name__c + ' (' + emp.Name + ', ' + emp.Department__c + ')\n\n';
                    taskDescription = '\t'+'\n';
                    taskDescription += forfeitReminder.Activity_Description__c + '\n';
                    //taskDescription += ', ' + Label.ELeave_Apply_Your_Balance ;
                    //Prepare the description
                    for(Leave_Balance__c lb : lbList) {
                        taskDescription = taskDescription + 
                            lb.Leave_Type_Label__c + ': ' + lb.To_Be_Forfeited_Next_Period_Display__c + ' ' + Label.ELeave_Days + '\n';
                            //lb.Leave_Type_Label__c + '(' + lb.Month__c + '/' + lb.Year__c + '): ' + lb.To_Be_Forfeited_Next_Period_Display__c + ' ' + Label.ELeave_Days + '\n';
                    }
                    taskDescription += '\n\n';                    
                    taskDescription += Label.ELeave_View_Your_Balance + ' ' + Label.ELeave_View_Balance;
                    //Populate the OwnerId
                    if(emp.User__c != null) {
                        // Only one Task needed
                        Task theTask = new Task(
                            OwnerId = emp.User__c,
                            ActivityDate = targetDate,
                            Subject = taskSubject,
                            Type = taskType,
                            Auto_Generated__c = true,
                            Description = taskDescription
                        );
                        taskList.add(theTask);
                        
                    }
                    
                    //Notify the employee administrators too
                    if(emp.Employee_Administrators__r != null && !emp.Employee_Administrators__r.isEmpty()) {
                        // Multiple tasks are needed
                        List<Employee_Administrator__c> empAdmins = emp.Employee_Administrators__r;
                        for(Employee_Administrator__c ea : empAdmins) {                            
                            if(ea.Administrator__c != null && ea.Employee__c != emp.Id) {
                                Task theTask = new Task(
                                    OwnerId = ea.Administrator__c,
                                    ActivityDate = targetDate,
                                    Subject = taskSubjectEa,
                                    Type = taskType,
                                    Auto_Generated__c = true,
                                    Description = taskDescription
                                );
                                
                                taskList.add(theTask);
                            }
                        }
                        
                    }
                    
                    //Done
                }
                
            }
        }
        
        if(taskList.size() > 0){
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = true;
            Database.insert(taskList, dmlo);
        }
    }


    /*
    * Method Name: finish
    * Description: Method executed at the end of the Batch.
                   Not used currently
    * Return Type: nil
    * Parameter: Database.BatchableContext

    */
    global void finish(Database.BatchableContext info){

    }

}