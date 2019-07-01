/*
    This class is implemented for handling the button clicks (e.g. TGA Submit, PPC Submit etc.).
    
    The JavaScript code of each button will make a request to the webservice methods in this class,
    and JSON strings should be returned back to the JavaScript.
    
    For most of the methods in this class, they turn the Is_xxx_Clicked_c flags to True and update the record.
    The flags will then invoke corresponding workflow rules for RecordType transitions/email alerts

*/

// "with sharing" is needed as the sharing rule applies on the record
global with sharing class CustomerOrderLogButtonHandler {
    webservice static String handleTGASubmitClicked(String logId) {
        Customer_Order_Log__c log = new Customer_Order_Log__c();
        log.Id = Id.valueOf(logId);
        log.From_TGA_to_HK_PPC__c = Datetime.now();
        log.Is_TGA_Submit_Clicked__c = true;
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }
    
    webservice static String handlePPCSubmitClicked(String logId) {
        Customer_Order_Log__c log = new Customer_Order_Log__c();
        log.Id = Id.valueOf(logId);
        log.From_HK_PPC__c = Datetime.now();
        log.Is_PPC_Submit_Clicked__c = true;
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }
    
    // check if Meet_Customer_Requirement__c/Remarks__c/Remark_2__c upon the using clicking the PPC Submit(Impact) button
    // return true if no changes on all 3 fields
    webservice static Boolean showWarningMsgForPPCImpact(String logId) {
        Customer_Order_Log__c log = [SELECT Id, Meet_Customer_Requirement__c, From_HK_PPC__c
                FROM Customer_Order_Log__c WHERE Id = :Id.valueOf(logId)];
        
        // if meet customer requirement, no need to show warning msg
        if (log.Meet_Customer_Requirement__c == 'NO') {
            
            // check if there are any changes in Meet_Customer_Requirement__c/Remarks__c/Remark_2__c
            Boolean isMeet = false;
            Boolean isRemark1 = false;
            Boolean isRemark2 = false;
            Map<String, SobjectField> fieldMap = Customer_Order_Log__c.getsObjectType().getDescribe().Fields.getMap();
            
            for (Customer_Order_Log_Track_History__c h: [SELECT Field__c, Customer_Order_Log__c FROM Customer_Order_Log_Track_History__c 
                    WHERE CreatedDate > :log.From_HK_PPC__c AND Customer_Order_Log__c = :log.Id]) {
                        
                if (h.Field__c == fieldMap.get('Meet_Customer_Requirement__c').getDescribe().getLabel()) {
                    isMeet = true;
                    
                } else if (h.Field__c == fieldMap.get('Remarks__c').getDescribe().getLabel()) {
                    isRemark1 = true;
                    
                } else if (h.Field__c == fieldMap.get('Remark_2__c').getDescribe().getLabel()) {
                    isRemark2 = true;
                    
                }
            }
            
            // return true only if all booleans are false (i.e. no changes on the 3 fields)
            return (!isMeet && !isRemark1 && !isRemark2);
        } 
        
        return false;   
    }
    
    webservice static String handlePPCImpact(String logId) {
        Customer_Order_Log__c log = new Customer_Order_Log__c();
        log.Id = Id.valueOf(logId);
        log.From_HK_PPC__c = Datetime.now();
        log.Is_PPC_Impact_Clicked__c = true;
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }

    webservice static String handleCaseCompletedClicked(String logId) {
        Customer_Order_Log__c log = new Customer_Order_Log__c();
        log.Id = Id.valueOf(logId);
        log.Is_Case_Complete_Clicked__c = true;
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }
    
    webservice static String handleDeleteClicked(String logId) {
        Customer_Order_Log__c log = new Customer_Order_Log__c();
        log.Id = Id.valueOf(logId);
        log.Is_Delete_Clicked__c = true;
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    }
}