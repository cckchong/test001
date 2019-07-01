@isTest
public class TestCaseTriggerHandler {
    private static String CASE_TYPE_DEVELOPER_NAME = 'Return_Exchange_Authorization_Request_USA';

    public static Case prepareCase() {
        RecordType returnExchangeRecordType = [Select id, developerName from RecordType where developerName = :CASE_TYPE_DEVELOPER_NAME];
        Case c = new Case(recordTypeId = returnExchangeRecordType.id);

        return c;
    }
    
    public static Account prepareAccount() {
        Account account = new Account(Name = 'Dummy Account');
        return account;
    }
    
    public static Entitlement prepareEntitlement(Id accountId) {
        Entitlement entitlement = new Entitlement(
                                    Name = 'Dummy Entitlement'
                                    , AccountId = accountId
                                    , Case_Type_Developer_Name__c = CASE_TYPE_DEVELOPER_NAME
                                );

        return entitlement;
    }

    @isTest
    public static void shouldSetDefaultEntitlementOnInsertWhenAvailable() {
        // Prepare data
        Account account = prepareAccount();
        insert account;
        
        Entitlement entitlement = prepareEntitlement(account.id);
        insert entitlement;
        
        // Test
        Case c = prepareCase();
        insert c;
        
        c = [Select entitlementId from Case where id = :c.id];
        
        // Verify
        System.assertEquals(entitlement.id, c.entitlementId);
    }
    
    @isTest
    public static void shouldSetDefaultEntitlementOnUpdateWhenAvailable() {
        // Prepare data
        Case c = prepareCase();
        insert c;
        System.assertEquals(null, c.entitlementId);
        
        Account account = prepareAccount();
        insert account;
        
        Entitlement entitlement = prepareEntitlement(account.id);
        insert entitlement;
        
        // Test
        update c;
        
        c = [Select entitlementId from Case where id = :c.id];
        
        // Verify
        System.assertEquals(entitlement.id, c.entitlementId);
    }
    
    
    @isTest
    public static void shouldNotSetDefaultEntitlementOnUpdateWhenNotAvailable() {
        // Prepare data
        Case c = prepareCase();
        insert c;
        System.assertEquals(null, c.entitlementId);
        
        Account account = prepareAccount();
        insert account;
        
        Entitlement premiumEntitlement = new Entitlement(
                            Name = 'Premium Entitlement'
                            , AccountId = account.id
                        );
        insert premiumEntitlement;
        
        // Test
        update c;
        
        c = [Select entitlementId from Case where id = :c.id];
        
        // Verify
        System.assertEquals(null, c.entitlementId);
    }
    
    @isTest
    public static void shouldSetLatestDefaultEntitlementOnInsertWhenMultipleAvailable() {
        // Prepare data
        Account account = prepareAccount();
        insert account;
        
        Entitlement entitlement = prepareEntitlement(account.id);
        insert entitlement;
        
        Entitlement entitlement2 = prepareEntitlement(account.id);
        insert entitlement2;
        
        // Test
        Case c = prepareCase();
        insert c;
        
        c = [Select entitlementId from Case where id = :c.id];
        
        // Verify
        System.assertEquals(entitlement2.id, c.entitlementId);
    }
    
    @isTest
    public static void shouldNotSetDefaultEntitlementAlreadySet() {
        // Prepare data
        Account account = prepareAccount();
        insert account;
        
        Entitlement entitlement = prepareEntitlement(account.id);
        insert entitlement;
        
        Entitlement premiumEntitlement = new Entitlement(
                            Name = 'Premium Entitlement'
                            , AccountId = account.id
                        );
        insert premiumEntitlement;
        
        // Test
        Case c = prepareCase();
        c.entitlementId = premiumEntitlement.id;
        insert c;
        
        c = [Select entitlementId from Case where id = :c.id];
        
        // Verify
        System.assertEquals(premiumEntitlement.id, c.entitlementId);
    }
    

    @isTest
    public static void shouldMarkClosedByOnClose() {
        // Prepare Data
        Account account = prepareAccount();
        insert account;

        Case c = prepareCase();
        insert c;
        
        // Test
        c.status = 'Closed';
        update c;
        
        // Verify
        c = [Select isclosed, closed_by__c from Case where id = :c.id];
        System.assertEquals(true, c.isclosed);
        System.assertEquals(UserInfo.getUserId(), c.closed_by__c);
    }
}