@isTest
public class TestUserSyncEmployeeActiveTriggerHandler
{
    public static testMethod void testSync()
    {
        // Get profile.
        Profile p = [
            SELECT id
            FROM Profile
            WHERE name = 'System Administrator'
        ];
        
        // Test User.
        User u1 = new User(
            Username = 'test@talapparel.com',
            Email = 'test@talapparel.com',
            Lastname = 'test',
            Firstname = 'test',
            Alias = 'test',
            
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            
            isActive = true
        );
        insert u1;
        
        // RunAs user.
        User u2 = new User(
            Username = 'update@talapparel.com',
            Email = 'update@talapparel.com',
            Lastname = 'update',
            Firstname = 'update',
            Alias = 'update',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u2;
        
        // Create user employee.
        Employee__c e = new Employee__c(
            name = u1.Firstname + ' ' + u1.LastName,
            user__c = u1.Id
        );
        insert e;
        
        
        Test.startTest();
        
        u1.isActive = false;
        System.runas(u2) { update u1; }        
        
        Test.stopTest();
    }
    
}