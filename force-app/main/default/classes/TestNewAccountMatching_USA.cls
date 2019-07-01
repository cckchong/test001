@isTest
public class TestNewAccountMatching_USA {

    @isTest
    public static void shouldNotMatchIfAccountNotExists() {
        // Setup
        Id newAccountRecordTypeId = [select id from RecordType where DeveloperName = 'New_Account_USA' and SobjectType = 'Case'].get(0).id;
        
        Case c = new Case(
                    RecordTypeId = newAccountRecordTypeId
                    , Account_Number_USA__c = 'Unit Test AN001'
                    , Temp_Contact_Salutation_USA__c = 'Unit Test Salutation'
                    , Temp_Contact_First_Name_USA__c = 'Unit Test First Name'
                    , Temp_Contact_Last_Name_USA__c = 'Unit Test Last Name'
                    , Temp_Contact_Phone_USA__c = 'Unit Test Phone'
                    , Temp_Contact_Email_USA__c = 'unit@test.com'
                );
                
        insert c;
        
        // Test
        Test.startTest();
        System.schedule('test NewAccountMatching_USA', '0 0 0 3 9 ? 2022', new NewAccountMatching_USA());
        Test.stopTest();
        
        // Assert
        c = [Select Id, AccountId, Temp_Contact_Salutation_USA__c, Temp_Contact_First_Name_USA__c, Temp_Contact_Last_Name_USA__c, Temp_Contact_Phone_USA__c, Temp_Contact_Email_USA__c, contactId from Case where Id = :c.id];
        System.assertEquals(null, c.accountId);

        List<Contact> contacts = [Select Id from Contact where Lastname = 'Unit Test Last Name'];

        System.assertEquals(0, contacts.size());
    }

    @isTest
    public static void shouldMatch() {
        // Setup
        Id newAccountRecordTypeId = [select id from RecordType where DeveloperName = 'New_Account_USA' and SobjectType = 'Case'].get(0).id;
        
        Case c = new Case(
                    RecordTypeId = newAccountRecordTypeId
                    , Account_Number_USA__c = 'Unit Test AN001'
                    , Temp_Contact_Salutation_USA__c = 'Unit Test Salutation'
                    , Temp_Contact_First_Name_USA__c = 'Unit Test First Name'
                    , Temp_Contact_Last_Name_USA__c = 'Unit Test Last Name'
                    , Temp_Contact_Phone_USA__c = 'Unit Test Phone'
                    , Temp_Contact_Email_USA__c = 'unit@test.com'
                );
                
        insert c;
        
        Account a = new Account(
                    Name = 'Unit Test'
                    , Account_Number_External_ID__c = 'Unit Test AN001'
                );
        
        insert a;
        
        // Test
        Test.startTest();
        System.schedule('test NewAccountMatching_USA', '0 0 0 3 9 ? 2022', new NewAccountMatching_USA());
        Test.stopTest();
        
        // Assert
        c = [Select Id, AccountId, Temp_Contact_Salutation_USA__c, Temp_Contact_First_Name_USA__c, Temp_Contact_Last_Name_USA__c, Temp_Contact_Phone_USA__c, Temp_Contact_Email_USA__c, contactId from Case where Id = :c.id];
        System.assertEquals(a.id, c.accountId);
        
        Contact contact = [Select Id from Contact where Account.Account_Number_External_ID__c = 'Unit Test AN001'];
        
        List<Contact> contacts = [Select Salutation, FirstName, LastName, Phone, Email from Contact where accountId = :a.id];
        System.assertEquals(a.id, c.accountId);
        System.assertEquals(contact.id, c.contactId);
        System.assertEquals(1, contacts.size());
        System.assertEquals(c.Temp_Contact_Salutation_USA__c, contacts.get(0).Salutation);
        System.assertEquals(c.Temp_Contact_First_Name_USA__c, contacts.get(0).FirstName);
        System.assertEquals(c.Temp_Contact_Last_Name_USA__c, contacts.get(0).LastName);
        System.assertEquals(c.Temp_Contact_Phone_USA__c, contacts.get(0).Phone);
        System.assertEquals(c.Temp_Contact_Email_USA__c, contacts.get(0).Email);
    }
}