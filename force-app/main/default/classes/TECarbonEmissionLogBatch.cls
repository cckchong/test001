/**
 * TECarbonEmissionLogBatch 
 * @description Schedulable batch to automatically generation the Carbon Emission Log by default
  *
 */
global class TECarbonEmissionLogBatch implements Schedulable{
    
   /**
    * @description Execute all the automatically generation
    * @return null
    * @param SchedulableContext    
    */
    global void execute(SchedulableContext sc) {
        // Execute auto generation
        TECarbonEmissionLogCtrl.testCO2Log();
    }
    
}