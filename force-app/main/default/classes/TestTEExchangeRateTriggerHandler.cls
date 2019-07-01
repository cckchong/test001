@isTest 
public class TestTEExchangeRateTriggerHandler{
    @isTest 
    public static void test() {
        Currency__c fromCurr = new Currency__c();
        fromCurr.Name = 'FROM';
        Currency__c toCurr = new Currency__c();
        toCurr.Name = 'TO';
        insert fromCurr;
        insert toCurr;
        
        //String fromTo = 'FROMTO';
        //Set <String> fromTobudgetCurrencySet = new Set <String>();
    
        Exchange_Rate__c er = new Exchange_Rate__c();
        er.Date__c = Date.today();
        er.From_Currency__c = fromCurr.Id;
        er.To_Currency__c = toCurr.Id;
        er.Is_Latest__c = True;
        
        insert er;
        system.assertNotEquals(null,er.Id);
        //system.assertEquals(er.Is_Latest__c ,True);
        
        /**
        Exchange_Rate__c er2 = new Exchange_Rate__c();
        er2.Date__c = er.Date__c.addDays(-100);
        er2.From_Currency__c = fromCurr.Id;
        er2.To_Currency__c = toCurr.Id;
        er2.Is_Latest__c = True;
        
        insert er2;
        fromTobudgetCurrencySet.add(er2.Tech_From_To_Currency__c);
        System.Debug('********er.Tech_From_To_Currency__c*********');
        System.Debug(er.Tech_From_To_Currency__c);
        System.Debug('********er2.Tech_From_To_Currency__c*********');
        System.Debug(er2.Tech_From_To_Currency__c);
        
        system.assertEquals(String.valueof(er),String.valueof([select id, Tech_From_To_Currency__c from Exchange_Rate__c ])); 

        
        System.Debug('********Exchange Rate1 ID*********');
        System.Debug(er.Id);
        System.Debug('********Exchange Rate2 ID*********');
        System.Debug(er2.Id);
        For (Exchange_Rate__c  reader : [select id, Is_Latest__c from Exchange_Rate__c where Tech_From_To_Currency__c in :fromTobudgetCurrencySet and Is_Latest__c = true and Is_Book_Rate__c = true ]){
            System.Debug('********Exchange Rate ID, Is_Latest__c *********');
            System.Debug(reader.Id + ' ' + reader.Is_Latest__c );
        }
        **/
    }
}