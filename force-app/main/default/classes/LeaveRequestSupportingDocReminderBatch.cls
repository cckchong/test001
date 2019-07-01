global class LeaveRequestSupportingDocReminderBatch implements Database.Batchable<sObject>, Database.Stateful {
 
    /*
     * Method Name: Start
     * Description: Query All the Account for which tasks need to be created.
     * Return Type: Database.QueryLocator
     * Parameter: Database.BatchableContext
     */

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryStr = 'Select name , Leave_Application__r.Employee_ID__r.user__r.id, Employee_ID__r.user__r.id, Notif_Supporting_Doc_Submit__c  from Leave_Request__c where Notif_Supporting_Doc_Submit__c = true ';
        return Database.getQueryLocator(queryStr);  
    }


    /*
    * Method Name: Execute
    * Description:
    * Return Type: nil
    * Parameter: Database.BatchableContext, List<sObject>
    */
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Id uid = null;
        String taskSubject = null;
        String taskType = null;
        String taskDescription = null;
        Date targetDate = null;
        Task theTask = null;
        List <Task> taskList = new List <Task>();
        Map<String, ProcessInstance> targetObjIdToProcessInstance = new Map<String, ProcessInstance>();
        CS_Notification_Management__c leaveApprovalReminder = CS_Notification_Management__c.getInstance('Leave_Missing_Doc');
        Date todayDate = System.today();
        
        for (sObject s : scope){
            Leave_Request__c leave = (Leave_Request__c) s;
            
            if ( leave.Employee_ID__r.user__c != null ){
                uid = leave.Employee_ID__r.user__r.id;
            }
            else{
                uid = leave.Leave_Application__r.Employee_ID__r.user__r.id;
            }
            
            if(leave.Notif_Supporting_Doc_Submit__c == true) {
                taskSubject = leaveApprovalReminder.Activity_Subject__c;
                taskType = leaveApprovalReminder.Activity_Type__c;
                targetDate = todayDate;
                taskDescription = leaveApprovalReminder.Activity_Description__c;
            
                theTask = new Task(
                      OwnerId = uid,
                      ActivityDate = targetDate,
                      Subject = taskSubject + ' ' + Date.TODAY().format(),
                      Description = taskDescription + '\n\n' + Label.Server_URL + Label.ELeave_Leave_Request_Support_Doc_URL,
                      Type = taskType,
                      Auto_Generated__c = true
                );
            }
            taskList.add(theTask);
        }
        
        if(!taskList.isEmpty()){
          Database.DMLOptions dmlo = new Database.DMLOptions();
          dmlo.EmailHeader.triggerUserEmail = true;
          Database.insert(taskList, dmlo);
        } 
    }
    
    /*
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Id> usersToMention = new List<Id>();
        String uid = '';
        for (sObject s : scope)
        {
            Leave_Request__c leave = (Leave_Request__c) s;
            if ( leave.Employee_ID__r.user__c != null )
            {
                uid = leave.Employee_ID__r.user__r.id;
            }
            else
            {
                uid = leave.Leave_Application__r.Employee_ID__r.user__r.id;
            }
            usersToMention.add(uid);            
            ChatterUtil.simpleTextPostWithMultipleMentions(uid,usersToMention, Label.ELeave_Supporting_Doc_Reminder + ' (' + leave.name + ')'  );
        }
    }
    */

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