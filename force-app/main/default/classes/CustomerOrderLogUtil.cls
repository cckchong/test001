public class CustomerOrderLogUtil {
    // returns a set of userIds with the given developerName of the custom permission
    public static Set<Id> getUsersWithCustomPermission(String customPermissionName) {
        Set<Id> parentIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        
        for (SetupEntityAccess sea : [
                    SELECT ParentId FROM SetupEntityAccess 
                    WHERE SetupEntityType = 'CustomPermission' 
                    AND SetupEntityId IN 
                        (SELECT ID FROM CustomPermission
                        WHERE DeveloperName = :customPermissionName)]) {
                        
            parentIds.add(sea.ParentId);
        }
        
        for (PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment
                                 WHERE PermissionSetId IN :parentIds AND Assignee.IsActive = True]) {
                                    
            userIds.add(psa.AssigneeId);
        }
        
        return userIds;
        
    }
    
    // calculate the working days excluding the holidays specified in Custom Setting
    public static integer getWorkingDays(Date startDate, Date endDate) {
        Date refMonday = Date.newInstance(1970, 1, 5);  // it was a Monday
        
        Integer startDiff = refMonday.daysBetween(startDate);
        Integer endDiff = refMonday.daysBetween(endDate);
        
        Integer startWorkingDays = 0;
        Integer endWorkingDays = 0;
        
        if (Math.mod(startDiff, 7) == 5) {
            // startDate is Sat
            startWorkingDays = startDiff - (startDiff / 7) * 2 - 1;
            
        } else if (Math.mod(startDiff, 7) == 6) {
            // startDate is Sun
            startWorkingDays = startDiff - (startDiff / 7) * 2 - 2;
            
        } else {
            startWorkingDays = startDiff - (startDiff / 7) * 2;
        
        }
        
        if (Math.mod(endDiff, 7) == 5) {
            // startDate is Sat
            endWorkingDays = endDiff - (endDiff / 7) * 2 - 1;
            
        } else if (Math.mod(endDiff, 7) == 6) {
            // endDate is Sun
            endWorkingDays = endDiff - (endDiff / 7) * 2 - 2;
            
        } else {
            endWorkingDays = endDiff - (endDiff / 7) * 2;
        
        }
    
        Integer workingDays = endWorkingDays - startWorkingDays;
        
        for (Customer_Order_Log_Holidays__c h: [SELECT Date__c FROM Customer_Order_Log_Holidays__c]) {
        
            if (Math.mod(refMonday.daysBetween(h.Date__c), 7) >= 5) {
                // holiday is a Sat/Sun
                continue;
                
            }
        
            if (h.Date__c >= startDate && h.Date__c <= endDate) {
                workingDays = workingDays - 1;
            
            }
        
        }
        
        return workingDays;
        
    }
}