/*
    This class is implemented for handling "Drop" button click ONLY.
    It is separated from another class because it needs to ignore sharing rules.
*/


// "without sharing" as it ignores all the sharing rules
global without sharing class CustomerOrderLogDropButtonHandler {

    webservice static Boolean isUserPpcOrAdmin(String userId) {
        // checks if user is PPC/Admin
        User u = [SELECT Id, ProfileId FROM User WHERE Id = :Id.valueOf(userId)];
        
        Set<Id> ppcUserIds = CustomerOrderLogUtil.getUsersWithCustomPermission('CEL_PPC_Edit_Right');
        Set<Id> superAdminIds = CustomerOrderLogUtil.getUsersWithCustomPermission('CEL_Super_Admin_Right');
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        return ppcUserIds.contains(u.Id) || superAdminIds.contains(u.Id) || u.ProfileId == sysAdminProfile.Id;
        
    }
    
    // return false if Record Type = Completed AND Customer Confirmation = Accept
    webservice static Boolean isCaseCompletedAccepted(String logId) {
        Customer_Order_Log__c log = [SELECT Id, Customer_Confirmation__c, RecordType.DeveloperName FROM Customer_Order_Log__c WHERE Id = :Id.valueOf(logId)];
        
        if (log.RecordType.DeveloperName == 'Completed') {
            return (log.Customer_Confirmation__c == 'Accept');
        
        } else {
            return true;
            
        }
    
    }

    webservice static String handleDrop(String logId, String dropMsg) {
        Customer_Order_Log__c log = new Customer_Order_Log__c();
        log.Id = Id.valueOf(logId);
        log.Is_Drop_Clicked__c = true;
        log.Drop_Message__c = dropMsg;
        
        Database.SaveResult sr = Database.update(log, false);

        return JSON.serialize(sr);
    
    }

}