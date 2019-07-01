/**
 * TEExchangeRateTriggerHandler
 * @description Exchange Rate Trigger Handler
 */

public class TEExchangeRateTriggerHandler {

      public static Boolean isRun = false;
      
      public static void updateFromToCurrencyType(List<Exchange_Rate__c> newList){
          for(Exchange_Rate__c reader : newList) {
              reader.Tech_From_To_Currency_Type__c = exchangeRateKey(reader);
              reader.Tech_From_To_Currency_Type_Date__c = exchangeRateKey(reader) + ((DateTime)reader.Date__c).format('yyyyMMdd');              
          } 
      }
     
      public static void updateIsLatest(Map<Id, Exchange_Rate__c> oldMap, List<Exchange_Rate__c> newList){
        
        Map<String, List<Exchange_Rate__c >> erKeyToExchangeRate = new Map<String, List<Exchange_Rate__c >>();
        Map<String, Exchange_Rate__c> wasLatestER = new Map<String, Exchange_Rate__c>();
        List<String> exchangeRateDateKeys = new List<String>();
        List<Exchange_Rate__c> erList = null;
        String key = '';
          
        for(Exchange_Rate__c reader : newList){
            // Check if the records actually need to be processed on update.
            if(Trigger.isUpdate){
                if(oldMap.get(reader.Id).Is_Latest__c != reader.Is_Latest__c) {
                    System.debug('>>>>> Exchange_Rate__c  record is ignored as the Latest flag changed >>>>>> ' + reader.Id + ' - ' + reader.from_currency__c + ' - ' + reader.To_currency__c + reader.Date__c);
                    continue;
                } else if(oldMap.get(reader.Id).From_currency__c == reader.From_currency__c && 
                          oldMap.get(reader.Id).To_currency__c == reader.To_currency__c && 
                          oldMap.get(reader.Id).Date__c  == reader.Date__c
                         ){
                    continue;
                }
            }
            
            key = exchangeRateKey(reader);
            
            if(erKeyToExchangeRate.get(Key) == null) {
                erList = new List<Exchange_Rate__c>();                
            } else {
                erList = erKeyToExchangeRate.get(Key);                
            }
            erList.add(reader);
            erKeyToExchangeRate.put(Key, erList);
        }
        System.debug('>>>>> erKeyToExchangeRate = ' + erKeyToExchangeRate);
        if(!erKeyToExchangeRate.isEmpty()) {
            Map<Id, Exchange_Rate__c> ersMarked = new Map<Id, Exchange_Rate__c>();
            for(Exchange_Rate__c reader: 
                [
                    SELECT Id, Is_Latest__c, Tech_From_To_Currency_Type__c
                    FROM Exchange_Rate__c
                    WHERE Is_Latest__c = True
                    AND Tech_From_To_Currency_Type__c IN: erKeyToExchangeRate.keyset()
                ]) {
                    reader.Is_Latest__c = False;
                    ersMarked.put(reader.Id, reader);
                    wasLatestER.put(reader.Tech_From_To_Currency_ID__c, reader);
            }
            
            if(!ersMarked.isEmpty()) {
                update ersMarked.values();
                ersMarked.clear();
            }
            
            // Query out the ones we must mark as latest
            List<AggregateResult> arList = 
               [
                   SELECT Tech_From_To_Currency_Type__c,  MAX(Date__c) max_date
                   FROM Exchange_Rate__c
                   WHERE Tech_From_To_Currency_Type__c  IN: erKeyToExchangeRate.keyset()
                   GROUP BY Tech_From_To_Currency_Type__c  
               ];
            DateTime theDate;
            for(AggregateResult ar : arList) {
                // Build the key as formatted in the Tech_From_To_Currency_Type__c formula field:
                theDate = (DateTime)ar.get('max_date');
                Key = (String) ar.get('Tech_From_To_Currency_Type__c') + theDate.format('yyyyMMdd');
                exchangeRateDateKeys.add(key);
                
                System.debug('--------------------------');
                System.debug('>>> This key will be marked = ' + Key);
                System.debug('--------------------------');
            }
            
            // Now re-query out the records we need to mark as latest
            for(Exchange_Rate__c er : [
                SELECT Id, Is_Latest__c, Tech_From_To_Currency_Type__c, From_currency__c, To_currency__c, type__C
                FROM Exchange_Rate__c
                WHERE Tech_From_To_Currency_Type_Date__c IN: exchangeRateDateKeys
            ]) {
                
                System.debug('--------------------------');
                System.debug('>>> Marking as Latest = ' + er.Id + ' - ' + er.from_currency__c+ ' - '+er.to_currency__c+' - ' + er.Type__c+ ' - ' + er.Tech_From_To_Currency_Type__c);
                System.debug('--------------------------');                
                er.Is_Latest__c = true;
                ersMarked.put(er.Id, er);
            }
            update ersMarked.values();
        } 
      }
      private static String exchangeRateKey(Exchange_Rate__c exchangeRate){
          return String.Valueof(exchangeRate.from_currency__c) + String.Valueof(exchangeRate.to_currency__c) + String.Valueof(exchangeRate.type__c);
      }      
        /**
        * @description update the Is_Latest__c field to indicate the lastest record when insert or update records
        */
      /*  
      public static void updateIsLatest1(Map<ID, Exchange_Rate__c> newExchangeRateMap){          
          if ( isRun ){
              return;
          }
          
          Set <String> fromToCurrencySet = new Set <String>();
          Set <String> fromTobudgetCurrencySet = new Set <String>();          
          Set <String> fromToCurrencyDateSet = new Set <String>();
          Set <String> fromTobudgetCurrencyDateSet = new Set <String>();          
          Map <Id, Exchange_Rate__c> exchangeRateMap = new Map <Id, Exchange_Rate__c>();
          Map <Id, Exchange_Rate__c> budgetexchangeRateMap = new Map <Id, Exchange_Rate__c>();
          List <Exchange_Rate__c> exchangeRateList = new List <Exchange_Rate__c> ();
          
          isRun = true;          
          for ( Exchange_Rate__c reader : newExchangeRateMap.values() ){
              if (reader.Is_Book_Rate__c){
                  fromToCurrencySet.add(reader.Tech_From_To_Currency__c);
              }
              if (reader.Is_budget_Rate__c){
                  fromTobudgetCurrencySet.add(reader.Tech_From_To_Currency__c);
              }
              
          }          
          if(!fromToCurrencySet.isEmpty()){
              for ( Exchange_Rate__c reader : [select id, Is_Latest__c from Exchange_Rate__c where Tech_From_To_Currency__c in :fromToCurrencySet and Is_Latest__c = true and Is_Book_Rate__c = true ] ){
                  reader.Is_Latest__c = false;
                  exchangeRateMap.put(reader.id, reader);
              }
              for( AggregateResult reader : [select From_Currency__c, To_Currency__c, Max(Tech_From_To_Currency_Date__c) CurrencyDate from Exchange_Rate__c where Tech_From_To_Currency__c in :fromToCurrencySet and Is_Book_Rate__c = true group by From_Currency__c, To_Currency__c ]) {
                  fromToCurrencyDateSet.add( (String)reader.get('CurrencyDate') );
              }
              for ( Exchange_Rate__c reader : [select id, Is_Latest__c from Exchange_Rate__c where Tech_From_To_Currency_Date__c in :fromToCurrencyDateSet and Is_Book_Rate__c = true ] ){
                  reader.Is_Latest__c = true;
                  exchangeRateMap.put(reader.id, reader);
              }
              exchangeRateList.addAll(exchangeRateMap.values());
          }
          
          if(!fromTobudgetCurrencySet.isEmpty()){
              for ( Exchange_Rate__c reader : [select id, Is_Latest__c from Exchange_Rate__c where Tech_From_To_Currency__c in :fromTobudgetCurrencySet and Is_Latest__c = true and Is_Budget_Rate__c = true ] ){
                  reader.Is_Latest__c = false;
                  budgetexchangeRateMap.put(reader.id, reader);
              }
              for( AggregateResult reader : [select From_Currency__c, To_Currency__c, Max(Tech_From_To_Currency_Date__c) CurrencyDate from Exchange_Rate__c where Tech_From_To_Currency__c in :fromToBudgetCurrencySet and Is_Budget_Rate__c = true group by From_Currency__c, To_Currency__c ]) {
                  fromTobudgetCurrencyDateSet.add( (String)reader.get('CurrencyDate') );
              }
              for ( Exchange_Rate__c reader : [select id, Is_Latest__c from Exchange_Rate__c where Tech_From_To_Currency_Date__c in :fromTobudgetCurrencyDateSet and Is_Budget_Rate__c = true ] ){
                  reader.Is_Latest__c = true;
                  budgetexchangeRateMap .put(reader.id, reader);
              }
              exchangeRateList.addAll(budgetexchangeRateMap.values());
          }
          
          if(!exchangeRateList.isEmpty()){
              update exchangeRateList;
          }

      }
      */
    
}