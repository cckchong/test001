Public class TECurrencyTriggerHandler {

     public static void exchangeRateCreation(List<Currency__c> newTriggerList){
         List <Exchange_Rate__c> exchangeRateList = new List <Exchange_Rate__c>();
         for(Currency__c reader : newTriggerList){
             exchangeRateList.add(new Exchange_Rate__c(From_Currency__c = reader.id, to_Currency__c = reader.id, Date__c = System.today(), Rate__c = 1, Type__c = TEConstant.EXCHANGE_RATE_TYPE_BOOK_RATE));
             exchangeRateList.add(new Exchange_Rate__c(From_Currency__c = reader.id, to_Currency__c = reader.id, Date__c = System.today(), Rate__c = 1, Type__c = TEConstant.EXCHANGE_RATE_TYPE_BUDGET_RATE));
         }
         if (!exchangeRateList.isempty()){
             insert exchangeRateList;
         }
     }
     
     public static void delExchangeRate(List<Currency__c> oldTriggerList){

         String currencyName = '';
         List <String> currencyList = new List <String>();
         List <Exchange_Rate__c> exchangeRateList = null;
         for (Currency__c reader : oldTriggerList){
             currencyName = '';
             currencyName = String.Valueof(reader.name).touppercase();
             currencyName = currencyName.replaceAll(' ','');
             currencyList.add(currencyName +currencyName);
         }
         
         exchangeRateList = new List <Exchange_Rate__c> ([select id from Exchange_Rate__c where Tech_From_To_Currency__c = :currencyList]);
         if (!exchangeRateList.isempty()){
             delete exchangeRateList;
         }
     }
     

}