global class LeaveRequestNotificationBatch implements Database.Batchable<sObject>, Database.Stateful {

    global Map<String, Id> userMap;
    global Map<String, Id> accountRecordTypeMap;
    
    /*
     * Method Name: Start
     * Description: Query All the Account for which tasks need to be created.
     * Return Type: Database.QueryLocator
     * Parameter: Database.BatchableContext
     */

    global Database.QueryLocator start(Database.BatchableContext BC){

        //prepare query to fetch account
        String queryStr = 'SELECT Id, Notif_Pending_Approval__c ' +
                                 'FROM Leave_Request__c ' +
                                 'WHERE Notif_Pending_Approval__c = true';

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
        CS_Notification_Management__c leaveApprovalReminder = CS_Notification_Management__c.getInstance('Leave_Pending_Approval');

        Date todayDate = System.today();

        String taskSubject = null;
        String taskType = null;
        String taskDescription = null;
        Date targetDate = null;

        Map<String, ProcessInstance> targetObjIdToProcessInstance = new Map<String, ProcessInstance>();
        Map<Id, Task> taskOwnerToTaskMap = new Map<Id, Task>(); // We only want 1 task per owner
        
        for(ProcessInstance pi : 
            [
                SELECT Id, TargetObjectId, (SELECT Id, ActorId, ProcessInstanceId FROM Workitems)
                FROM ProcessInstance
                WHERE TargetObjectId IN: scope
            ]) {
            
            targetObjIdToProcessInstance.put(pi.TargetObjectId, pi);
        }
        
        for (sObject s : scope){
            Leave_Request__c leave = (Leave_Request__c) s;

            if( Test.isRunningTest() || leave.Notif_Pending_Approval__c == true) {
                taskSubject = leaveApprovalReminder.Activity_Subject__c;
                taskType = leaveApprovalReminder.Activity_Type__c;
                targetDate = todayDate;
                taskDescription = leaveApprovalReminder.Activity_Description__c;
            }


            //Now determine who should be assigned the task:
            if (targetObjIdToProcessInstance.get(leave.Id) != null &&
                    targetObjIdToProcessInstance.get(leave.Id).Workitems != null &&
                    !targetObjIdToProcessInstance.get(leave.Id).Workitems.isEmpty()) {
                
                for(ProcessInstanceWorkitem piwi : targetObjIdToProcessInstance.get(leave.Id).Workitems) {
                    if(piwi.ActorId != null) {
                        
                        //We only need to append the Items to Approve link once, so just check if we've already
                        //done it
                        /*if(taskOwnerToTaskMap.get(piwi.ActorId) != null) {
                            Task theTask = taskOwnerToTaskMap.get(piwi.ActorId);
                            theTask.Description = theTask.Description + '\n\n' +
                                Label.Server_URL + leave.Id;
                            
                            taskOwnerToTaskMap.put(piwi.ActorId, theTask);
                        } */
                        if(taskOwnerToTaskMap.get(piwi.ActorId) == null) {
                            System.debug('#### Actor = ' + piwi.ActorId);
                            Task theTask = new Task(
                                OwnerId = piwi.ActorId,
                                ActivityDate = targetDate,
                                Subject = taskSubject + ' ' + Date.TODAY().format(),
                                Description = taskDescription + '\n\n' + Label.Server_URL + Label.ELeave_General_Items_To_Approve_URL,
                                Type = taskType,
                                Auto_Generated__c = true
                            );
                            taskOwnerToTaskMap.put(piwi.ActorId, theTask);
                            
                        }
                    }
                }
                
            }
        }

        if(!taskOwnerToTaskMap.isEmpty()){
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = true;
            Database.insert(taskOwnerToTaskMap.values(), dmlo);
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