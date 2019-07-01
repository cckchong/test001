global with sharing class QTRButtonHandler {
    webservice static String handleSubmitClicked(String logId) {
        Quotation_System_Task_Request__c log = new Quotation_System_Task_Request__c();
        log.Id = Id.valueOf(logId);
        log.Is_Submit_Clicked__c = true;
        System.debug(log.put('Status__c', 'Submitted'));
        System.debug(log.Status__c); 
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }

     webservice static String handleCompleteClicked(String logId) {
        Quotation_System_Task_Request__c log = new Quotation_System_Task_Request__c();
        log.Id = Id.valueOf(logId);
        log.Is_Case_Completed__c = true;
        System.debug(log.put('Status__c', 'Completed'));
        System.debug(log.Status__c); 
      
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }
    
     webservice static String handleCancelClicked(String logId) {
        Quotation_System_Task_Request__c log = new Quotation_System_Task_Request__c();
        log.Id = Id.valueOf(logId);
        log.Is_Cancel_Clicked__c = true;
        log.Is_Submit_Clicked__c = false;
        log.Is_Case_Completed__c = false;
        System.debug(log.put('Status__c', 'Cancelled'));
        System.debug(log.Status__c); 
      
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }    

}