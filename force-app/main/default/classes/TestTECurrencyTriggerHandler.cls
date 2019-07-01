@isTest 
public class TestTECurrencyTriggerHandler{
    @isTest 
    public static void test() {
        Currency__c curr = new Currency__c();
        curr.Name = 'TEST';
        insert curr;
        system.assertNotEquals(null,curr);
        
        delete curr;
        system.assertNotEquals(null,curr);
    }
}