/**
 * NotificationSchedulableBatch
 * @description Schedulable batch to send scheduled notifications based on Object criteria
 *
 */
global class NotificationSchedulableBatch implements Schedulable{
    
   /**
    * @description Execute all the notification batches. The scope of each batch is set to 200.
    * @return null
    * @param SchedulableContext
    */
    global void execute(SchedulableContext sc) {
        // Execute notifications
        LeaveRequestNotificationBatch leaveRequestBatch = new LeaveRequestNotificationBatch();
        ID leaveRequestBatchId = Database.executeBatch(leaveRequestBatch, 1500);
        
        EmployeeNotificationBatch employeeBatch = new EmployeeNotificationBatch();
        ID employeeBatchId = Database.executeBatch(employeeBatch, 1500);
        
        LeaveRequestSupportingDocReminderBatch LeaveRequestSupportingDocReminder= new LeaveRequestSupportingDocReminderBatch ();
        ID supportingDocId = Database.executeBatch(LeaveRequestSupportingDocReminder, 1500);
        
    }
    
}