global class TENotificationSubmitExpenseReportBatch implements Database.Batchable<sObject>, Database.Stateful {

    /*
     * Method Name: Start
     * Description: Query All the Account for which tasks need to be created.
     * Return Type: Database.QueryLocator
     * Parameter: Database.BatchableContext
     */

    global Database.QueryLocator start(Database.BatchableContext BC){

        //prepare query to fetch account
        
        String queryStr = 'select id, Name, (select id from Expense_Applications__r), On_Behalf_of__r.employee__r.user__c, On_Behalf_of__r.Employee_Administrator__r.user__c, Return_Date__c from Travel_Application__c where Notif_Submit_Expense_Report__c = true';

        //System.debug('### queryStr ### ' + queryStr);

        return Database.getQueryLocator(queryStr);
        
    }


    /*
    * Method Name: Execute
    * Description:
    * Return Type: nil
    * Parameter: Database.BatchableContext, List<sObject>
    */

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List <Travel_Application__c> TravelApplicationList = new List <Travel_Application__c>();
        List <Expense_Application__c> expenseApplicationList = new List <Expense_Application__c>();
        String taskSubject = null;
        String taskType = null;
        String taskDescription = null;
        Date targetDate = null;
        Task theTask;
        List <Task> taskList = new List <Task>();
        Travel_Application__c ta = null;
        CS_Notification_Management__c teReminder = CS_Notification_Management__c.getInstance('TE_Notifi_Submit_Expense_Report');
       
        for (sObject s : scope){
            ta = (Travel_Application__c )s;
            expenseApplicationList = ta.Expense_Applications__r;
            if(expenseApplicationList.isempty()){
                 TravelApplicationList.add(ta);
             }
        }
        
        for (Travel_Application__c  reader : TravelApplicationList){
            if(!Test.isRunningTest()){ 
                //Modified by TAL (Twinkle LI) @20170713
                integer returnedDays = reader.Return_Date__c.daysBetween(Date.Today());
                system.debug(returnedDays);
                targetDate = Date.TODAY().addDays(60 - returnedDays); 
                    
                //targetDate = Date.TODAY().addDays(30);     
                //End by TAL (Twinkle LI) @20170713
                    
                taskSubject = teReminder.Activity_Subject__c;
                taskSubject = taskSubject.replace('@name', reader.Name);
                taskType = teReminder.Activity_Type__c;            
                taskDescription = teReminder.Activity_Description__c;
                taskDescription = taskDescription.replace('@name', reader.Name);
                taskDescription = taskDescription.replace('@date', targetDate.format());
                taskDescription +=  '\n\n' +'View your travel request: '+ Label.Server_URL+reader.id ;
            }
            
            
            theTask = new Task(
                OwnerId = (reader.On_Behalf_of__r.employee__r.user__c == null? reader.On_Behalf_of__r.Employee_Administrator__r.user__c : reader.On_Behalf_of__r.employee__r.user__c),
                ActivityDate = targetDate,
                Subject = taskSubject,
                Description = taskDescription,
                Type = taskType,
                Auto_Generated__c = true,
                WhatId = reader.id
            );
            taskList.add(theTask);            
        }
        if(!taskList.isEmpty()){
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