public without sharing class AccountTriggerHandler {

    //Set Salesperson to EMPTY if no matching user found for Account integrated from M3
    public static void bypassSalesperson (List<Account> accountList) {
        Set<String> setSalespersonExternalId = new Set<String>();
        Map<String, User> mapSalesperson = new Map<String, User>();
    
        for(Account acc : accountList){
            if(acc.Salesperson_External_Id__c != null)
                setSalespersonExternalId.add(acc.Salesperson_External_Id__c.toLowerCase());
        }
        
        for(User u : [SELECT id, Username_External_ID__c FROM User WHERE Username_External_ID__c IN: setSalespersonExternalId]){
            mapSalesperson.put(u.Username_External_ID__c, u);
        }
        
        for(Account acc : accountList){
            //apply only when record is synced from M3
            if(acc.Source__c == 'M3'){
                if(!mapSalesperson.containsKey(acc.Salesperson_External_Id__c.toLowerCase()))
                    acc.Salesperson_USA__c = null;
                else
                    acc.Salesperson_USA__c = mapSalesperson.get(acc.Salesperson_External_Id__c.toLowerCase()).id;
            }
        }
        
    }
}