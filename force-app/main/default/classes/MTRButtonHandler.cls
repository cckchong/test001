global with sharing class MTRButtonHandler {
    webservice static String handleSubmitClicked(String logId) {
        Movex_Task_Request__c log = new Movex_Task_Request__c();
        log.Id = Id.valueOf(logId);
        log.Is_Submit_Clicked__c = true;
        System.debug(log.put('Status__c', 'Submitted'));
        System.debug(log.Status__c); 
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }
    
        webservice static String handleWIPClicked(String logId) {
        Movex_Task_Request__c log = new Movex_Task_Request__c();
        log.Id = Id.valueOf(logId);
        log.Is_WIP_Clicked__c = true;
        System.debug(log.put('Status__c', 'Working in progress'));
        System.debug(log.Status__c); 
      
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }
    
     webservice static String handleCompleteClicked(String logId) {
        Movex_Task_Request__c log = new Movex_Task_Request__c();
        log.Id = Id.valueOf(logId);
        log.Is_Case_Completed__c = true;
        System.debug(log.put('Status__c', 'Completed'));
        System.debug(log.Status__c); 
      
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }
    
     webservice static String handleCancelClicked(String logId) {
        Movex_Task_Request__c log = new Movex_Task_Request__c();
        log.Id = Id.valueOf(logId);
        log.Is_Cancel_Clicked__c = true;
        log.Is_Submit_Clicked__c = false;
        log.Is_WIP_Clicked__c = false;
        log.Is_Case_Completed__c = false;
        System.debug(log.put('Status__c', 'Cancelled'));
        System.debug(log.Status__c); 
      
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }    
/*
     webservice static String handleRecallClicked(String logId) {
        Movex_Task_Request__c log = new Movex_Task_Request__c();
        log.Id = Id.valueOf(logId);
        log.Is_Submit_Clicked__c = false;
        log.Is_WIP_Clicked__c = false;
        log.Is_Recall_Clicked__c = true;
        System.debug(log.put('Status__c', 'Open'));
        System.debug(log.Status__c); 
      
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }
*/    
}