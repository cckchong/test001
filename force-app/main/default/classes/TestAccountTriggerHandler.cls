@isTest
public without sharing class TestAccountTriggerHandler {
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
                            , Physical_Delivery_Address__c = 'UnitTest-Site'
                            , Username_External_ID__c = 'unit_test_user@talgroup.com');
        insert user;
        return user;
    }
    
    @isTest
    public static void bypassSalesperson() {
        User user = prepareUser();
        
        List<Account> listAccount = new  List<Account>();
        listAccount.add(new Account (
            Name = 'Testing Account 1',
            Source__c = 'M3',
            Salesperson_External_Id__c = 'unit_test_user@talgroup.com')
        );
        listAccount.add(new Account (
            Name = 'Testing Account 2',
            Source__c = 'M3',
            Salesperson_External_Id__c = 'no_such_user@talgroup.com')
        );
        insert listAccount;
    }
    
}