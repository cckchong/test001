@isTest
public class TestCaseFIFOController {

    public static void prepare() {
        Brand_to_Email_Template__c brandtoEmailTemplate = new Brand_to_Email_Template__c(name = '3PL', Email_Template__c = 'TALG_Assigned_Owner_Template');
        insert brandtoEmailTemplate;
    }

    @isTest
    public static void shouldClaimTheCase() {
        // Setup
        prepare();
        Contact contact = new Contact(email = 'a@b.com'
                                     , LastName = 'Last');
        insert contact;
            
        Case c = new Case(brand_USA__c = '3PL'
                         , contactId = contact.id);
        insert c;
        
        c = [Select brand_USA__c, contactId from Case where id = :c.id];
    
        ApexPages.StandardController standardController = new ApexPages.StandardController(c);
    
        CaseFIFOController caseFIFOController = new CaseFIFOController(standardController);
        
        // Test
        caseFIFOController.execute();
        
        // Verify
        c = [Select brand_USA__c, contactId, assignment_timestamp_USA__c, First_Acknowledge_by_USA__c, OwnerId from Case where id = :c.id];
        System.assertNotEquals(null, c.assignment_timestamp_USA__c);
        System.assertEquals(UserInfo.getUserId(), c.First_Acknowledge_by_USA__c);
    }
    
    @isTest
    public static void shouldNotClaimTheCaseMoreThanOneTime() {
        // Setup
        prepare();
        Contact contact = new Contact(email = 'a@b.com'
                                     , LastName = 'Last');
        insert contact;
            
        Case c = new Case(brand_USA__c = '3PL'
                         , contactId = contact.id);
        insert c;
        
        c = [Select brand_USA__c, contactId from Case where id = :c.id];
    
        ApexPages.StandardController standardController = new ApexPages.StandardController(c);
    
        CaseFIFOController caseFIFOController = new CaseFIFOController(standardController);
        caseFIFOController.execute();
        
        // Test
        PageReference pageReference = caseFIFOController.execute();
        
        // Verify
        System.assertEquals('/' + c.id, pageReference.getURL());
    }
    
    @isTest
    public static void shouldNotClaimTheCaseWhenNoBrand() {
        // Setup
        prepare();
        Contact contact = new Contact(email = 'a@b.com'
                                     , LastName = 'Last');
        insert contact;
            
        Case c = new Case(contactId = contact.id);
        insert c;
        
        c = [Select brand_USA__c, contactId from Case where id = :c.id];
    
        ApexPages.StandardController standardController = new ApexPages.StandardController(c);
    
        CaseFIFOController caseFIFOController = new CaseFIFOController(standardController);
        
        // Test
        caseFIFOController.execute();
        
        // Verify
        c = [Select brand_USA__c, contactId, assignment_timestamp_USA__c, First_Acknowledge_by_USA__c, OwnerId from Case where id = :c.id];
        System.assertEquals(null, c.assignment_timestamp_USA__c);
    }
    
    @isTest
    public static void shouldNotClaimTheCaseWhenNoContact() {
        // Setup
        prepare();
        Case c = new Case(brand_USA__c = '3PL');
        insert c;
        
        c = [Select brand_USA__c, contactId from Case where id = :c.id];
    
        ApexPages.StandardController standardController = new ApexPages.StandardController(c);
    
        CaseFIFOController caseFIFOController = new CaseFIFOController(standardController);
        
        // Test
        caseFIFOController.execute();
        
        // Verify
        c = [Select brand_USA__c, contactId, assignment_timestamp_USA__c, First_Acknowledge_by_USA__c, OwnerId from Case where id = :c.id];
        System.assertEquals(null, c.assignment_timestamp_USA__c);
    }
    
    @isTest
    public static void shouldNotClaimTheCaseWhenContactNoEmail() {
        // Setup
        prepare();
        Contact contact = new Contact(LastName = 'Last');
        insert contact;
            
        Case c = new Case(brand_USA__c = '3PL'
                         , contactId = contact.id);
        insert c;
        
        c = [Select brand_USA__c, contactId from Case where id = :c.id];
    
        ApexPages.StandardController standardController = new ApexPages.StandardController(c);
    
        CaseFIFOController caseFIFOController = new CaseFIFOController(standardController);
        
        // Test
        PageReference pageReference = caseFIFOController.execute();
        
        // Verify
        c = [Select brand_USA__c, contactId, assignment_timestamp_USA__c, First_Acknowledge_by_USA__c, OwnerId from Case where id = :c.id];
        System.assertEquals(null, c.assignment_timestamp_USA__c);
    }
}