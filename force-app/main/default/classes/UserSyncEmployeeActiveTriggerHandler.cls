public without sharing class UserSyncEmployeeActiveTriggerHandler
{
    
    public static void syncStatus(Map<Id, User> oldUserMap, List<User> newUserMap)
    {
        Map<Id, Boolean> uMap = new Map<Id, Boolean>();
        
        for (User u : newUserMap)
        {
            if (oldUserMap.get(u.Id).isActive != u.isActive)
            {
                uMap.put(u.Id, u.isActive);
                System.debug('### u ' + u);
            }
        }
        
        updateEmployeeStatus(uMap);
    }
    
    @future
    private static void updateEmployeeStatus(Map<Id, Boolean> uMap)
    {
        List<Employee__c> es = [
            SELECT Id, Is_Active__c, user__c
            FROM Employee__c
            WHERE user__c IN :uMap.keySet()
        ];
        
        System.debug('### es ' + es);
        
        for (Employee__c e : es)
        {
            e.Is_Active__c = uMap.get(e.user__c);
        }
        
        update es;
    }
    
}