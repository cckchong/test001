@IsTest
public class TestEmailMessageTrigger {

    static User prepareUser() {
        User user = new User(username = 'unit_test_user@talgroup.com'
                            , email = 'servicenowdev@weavenow.com'
                            , Lastname = 'UnitTest'
                            , Alias = 'UnitTest'
                            , TimeZoneSidKey = UserInfo.getTimeZone().getId()
                            , LocaleSidKey = UserInfo.getLocale()
                            , EmailEncodingKey = 'UTF-8'
                            , ProfileId = UserInfo.getProfileId()
                            , LanguageLocaleKey = UserInfo.getLanguage());
        insert user;
        return user;
    }

    @IsTest
    public static void shouldNotCreateCaseForEmailToNonClosedCase() {
// Setup
        List<RecordType> recordTypes = [Select id from RecordType where SobjectType = 'Case' and developerName like '%_USA'];
        
        Account account = new Account(Name = 'Unit Test Account Name');
        insert account;
        
        Contact contact = new Contact(LastName = 'Unit Test Last Name');
        insert contact;
        
        User user = prepareUser();
    
        Case c = new Case(recordTypeId = recordTypes.get(0).id
                            , status = 'New'
                            , Subject = 'Unit Test Subject'
                            , AccountId = account.id
                            , Priority = 'High'
                            , Description = 'Unit Test Description'
                            , ContactId = contact.id
                            , OwnerId = user.id
                        );
        insert c;

        EmailMessage emailMessage = new EmailMessage(incoming = true, parentId = c.id);
        
        // Test
        insert emailMessage;
        
        RecordType unclassifiedCaseRecordType = [Select id from RecordType where SobjectType = 'Case' and developerName = 'Unclassified_Case_USA' limit 1];
        
        // Verify
        List<Case> cases = [Select id, Subject, AccountId, Priority, Description, ContactId, OwnerId, Status, Origin, IsEscalated, ParentId, RecordTypeId, Created_from_Email_to_Closed_Case_USA__c from Case where ParentId = :c.id];
        
        System.assertEquals(0, cases.size());
    }

    @IsTest
    public static void shouldCreateCaseForEmailToClosedCase() {
        // Setup
        List<RecordType> recordTypes = [Select id from RecordType where SobjectType = 'Case' and developerName like '%_USA'];
        
        Account account = new Account(Name = 'Unit Test Account Name');
        insert account;
        
        Contact contact = new Contact(LastName = 'Unit Test Last Name');
        insert contact;
        
        User user = prepareUser();
    
        Case c = new Case(recordTypeId = recordTypes.get(0).id
                            , status = 'Closed'
                            , Subject = 'Unit Test Subject'
                            , AccountId = account.id
                            , Priority = 'High'
                            , Description = 'Unit Test Description'
                            , ContactId = contact.id
                            , OwnerId = user.id
                        );
        insert c;

        EmailMessage emailMessage = new EmailMessage(incoming = true, parentId = c.id, Subject = 'Email Subject', TextBody = 'Email text body');
        
        // Test
        insert emailMessage;
        
        RecordType unclassifiedCaseRecordType = [Select id from RecordType where SobjectType = 'Case' and developerName = 'Unclassified_Case_USA' limit 1];
        
        // Verify
        List<Case> cases = [Select id, Subject, AccountId, Priority, Description, ContactId, OwnerId, Status, Origin, IsEscalated, ParentId, RecordTypeId, Created_from_Email_to_Closed_Case_USA__c from Case where ParentId = :c.id];
        
        System.assertEquals(1, cases.size());
        System.assertEquals('[CC] ' + emailMessage.Subject, cases.get(0).Subject);
        System.assertEquals(account.id, cases.get(0).AccountId);
        System.assertEquals('High', cases.get(0).Priority);
        System.assertEquals(emailMessage.TextBody, cases.get(0).Description);
        System.assertEquals(contact.id, cases.get(0).ContactId);
        System.assertEquals(user.id, cases.get(0).OwnerId);
        System.assertEquals('New', cases.get(0).Status);
        System.assertEquals('Email', cases.get(0).Origin);
        System.assertEquals(False, cases.get(0).IsEscalated);
        System.assertEquals(c.id, cases.get(0).ParentId);
        System.assertEquals(unclassifiedCaseRecordType.id, cases.get(0).recordTypeId);
        System.assertEquals(True, cases.get(0).Created_from_Email_to_Closed_Case_USA__c);
    }
    
    @IsTest
    public static void shouldHandleIncomingTagCaseEmail() {
        // Setup
        List<RecordType> recordTypes = [Select id from RecordType where SobjectType = 'Case' and developerName like '%_USA'];
    
        Case c = new Case(recordTypeId = recordTypes.get(0).id);
        insert c;

        EmailMessage emailMessage = new EmailMessage(incoming = true, parentId = c.id);
        
        // Test
        insert emailMessage;
        
        // Assert
        c = [Select id, Last_Inbound_Email_Time__c, First_Outgoing_Email_Timestamp__c from case where id = :c.id];
        
        System.assertNotEquals(null, c.Last_Inbound_Email_Time__c);
        System.assertEquals(null, c.First_Outgoing_Email_Timestamp__c);
    }
    
    @IsTest
    public static void shouldHandleOutGoingTagCaseEmail() {
        // Setup
        List<RecordType> recordTypes = [Select id from RecordType where SobjectType = 'Case' and developerName like '%_USA'];
    
        Case c = new Case(recordTypeId = recordTypes.get(0).id);
        insert c;

        EmailMessage emailMessage = new EmailMessage(incoming = false, parentId = c.id);
        
        // Test
        insert emailMessage;
        
        // Assert
        c = [Select id, Last_Inbound_Email_Time__c, First_Outgoing_Email_Timestamp__c from case where id = :c.id];
        
        System.assertEquals(null, c.Last_Inbound_Email_Time__c);
        System.assertNotEquals(null, c.First_Outgoing_Email_Timestamp__c);
    }
}