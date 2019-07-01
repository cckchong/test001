@isTest
public without sharing class TestELeaveUserTriggerHandler {

    static User prepareUser() {
        User user = new User(username = 'unit_test_user@talgroup.com'
                            , email = 'servicenowdev@weavenow.com'
                            , Firstname = 'FirstName'
                            , Lastname = 'LastName'
                            , Alias = 'UnitTest'
                            , TimeZoneSidKey = UserInfo.getTimeZone().getId()
                            , LocaleSidKey = UserInfo.getLocale()
                            , EmailEncodingKey = 'UTF-8'
                            , ProfileId = UserInfo.getProfileId()
                            , LanguageLocaleKey = UserInfo.getLanguage()
                            , EmployeeNumber = 'UnitTest-Employee'
                            , Physical_Delivery_Address__c = 'UnitTest-Site');
        insert user;
        return user;
    }
    
    @isTest
    public static void shouldHandleInsertUserCase() {
        // Setup
        Site__c site = new Site__c(Name = 'UnitTest-Site', Site_ID__c = 'UnitTest-Site');
        insert site;
        
        Employee__c employee = new Employee__c();
        employee.original_employee_id__c = 'UnitTest-Employee';
        employee.site__c = site.id;
        employee.employee_id__c = 'UnitTest-SiteUnitTest-Employee';
        insert employee;
        
        // Test
        User user = prepareUser();

        // Verify
        employee = [Select name, employee_id__c, user__c from employee__c where id = :employee.id];
        System.assertEquals('UnitTest-SiteUnitTest-Employee', employee.employee_id__c);
        System.assertEquals('FirstName LastName (UnitTest-SiteUnitTest-Employee)', employee.name);
        System.assertEquals(user.id, employee.user__c);
    }
    
    @isTest
    public static void shouldHandleUpdateUserCase() {
        // Setup
        Site__c site = new Site__c(Name = 'UnitTest-Site', Site_ID__c = 'UnitTest-Site');
        insert site;
        
        Employee__c employee = new Employee__c();
        employee.original_employee_id__c = 'UnitTest-Employee';
        employee.site__c = site.id;
        employee.employee_id__c = 'UnitTest-SiteUnitTest-Employee';
        insert employee;
        
        // Test
        User user = prepareUser();
        user.firstName = 'FirstName updated';
        update user;

        // Verify
        employee = [Select name, employee_id__c, user__c from employee__c where id = :employee.id];
        System.assertEquals('UnitTest-SiteUnitTest-Employee', employee.employee_id__c);
        System.assertEquals('FirstName updated LastName (UnitTest-SiteUnitTest-Employee)', employee.name);
        System.assertEquals(user.id, employee.user__c);
    }
}