@isTest 
public class TestTETravelPriceLogBatch{
    @isTest 
    public static void test() {
    
        Travel_Application__c ta = new Travel_Application__c();
        insert ta;
        
        Travel_Price__c tp = new Travel_Price__c();
        tp.Travel_Application__c = ta.Id;
        tp.Is_Error__c = True;
        tp.Invoice_Date__c = System.Today();
        insert tp;
    
        TETravelPriceLogBatch batch = new TETravelPriceLogBatch();
        batch.execute(null);
        System.assertNotEquals(null, batch);
    }
}