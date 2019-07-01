/**
 * TETravelPriceLogBatch 
 * @description Schedulable batch to automatically generation the Travel Price Log by default
  *
 */
global class TETravelPriceLogBatch implements Schedulable{
    
   /**
    * @description Execute all the automatically generation
    * @return null
    * @param SchedulableContext    
    */
    global void execute(SchedulableContext sc) {
        // Execute auto generation
        TETravelPriceErrorCtrl.processErrorTravelPrices();
    }
}