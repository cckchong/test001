/**
 * TEShuttleArrangementBatch 
 * @description Schedulable batch to automatically generation the shuttle arrangement based on route and company car by default
  *
 */
global class TEShuttleArrangementBatch implements Schedulable{
    
   /**
    * @description Execute all the automatically generation
    * @return null
    * @param SchedulableContext    
    */
    global void execute(SchedulableContext sc) {
        // Execute auto generation
        TEShuttleArrangementAutoGenerationCtrl.autoGeneration();
    }
    
}