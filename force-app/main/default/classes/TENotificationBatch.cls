/**
 * NotificationSchedulableBatch
 * @description Schedulable batch to send scheduled notifications based on Object criteria
 *
 */
global class TENotificationBatch implements Schedulable{
    
   /**
    * @description Execute all the notification batches. The scope of each batch is set to 200.
    * @return null
    * @param SchedulableContext    
    */
    global void execute(SchedulableContext sc) {
        // Execute notifications    
        TENotificationSubmitExpenseReportBatch TENotificationSubmitExpenseReport = new TENotificationSubmitExpenseReportBatch();
        ID serRequestBatchId = Database.executeBatch(TENotificationSubmitExpenseReport , 1500);
        
        TENotificationConfirmAirTicketBatch TENotificationConfirmAirTicketBatch = new TENotificationConfirmAirTicketBatch();
        ID catRequestBatchId = Database.executeBatch(TENotificationConfirmAirTicketBatch , 1500);
    }
    
}