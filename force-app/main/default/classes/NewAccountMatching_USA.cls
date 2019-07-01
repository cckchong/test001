global class NewAccountMatching_USA implements Schedulable {
    global static void execute(SchedulableContext schedulableContext) {
        // Find all new account case without associated account
        List<Case> cases = [Select Id
                                , Account_Number_USA__c
                                , Temp_Contact_Salutation_USA__c
                                , Temp_Contact_First_Name_USA__c
                                , Temp_Contact_Last_Name_USA__c
                                , Temp_Contact_Phone_USA__c
                                , Temp_Contact_Email_USA__c
                            from Case where RecordType.DeveloperName = 'New_Account_USA' and AccountId = null and Account_Number_USA__c != '' and Account_Number_USA__c != null];
        
        Set<String> caseAccountNumberSet = new Set<String>();
        
        for (Case c : cases) {
            caseAccountNumberSet.add(c.Account_Number_USA__c);
        }
        
        // Find all related Accounts
        List<Account> accounts = [Select Id, AccountNumber from Account where AccountNumber in :caseAccountNumberSet];
        
        Map<String, Id> accountNumberIdMap = new Map<String, Id>();
        
        for (Account account : accounts) {
            accountNumberIdMap.put(account.AccountNumber, account.Id);
        }
        
        Map<String, Contact> accountNumberContactMap = new Map<String, Contact>();
        
        // Match accounts to case and create contact
        for (Case c : cases) {
            c.accountId = accountNumberIdMap.get(c.Account_Number_USA__c);
            
            if (c.accountId != null) {
                Contact contact = new Contact(
                                        accountId = c.accountId
                                        , Salutation = c.Temp_Contact_Salutation_USA__c
                                        , FirstName = c.Temp_Contact_First_Name_USA__c
                                        , LastName = c.Temp_Contact_Last_Name_USA__c
                                        , Phone = c.Temp_Contact_Phone_USA__c
                                        , Email = c.Temp_Contact_Email_USA__c
                                    );
                
                accountNumberContactMap.put(c.Account_Number_USA__c, contact);
            }
        }
        
        // Update
        insert accountNumberContactMap.values();
        
        for (Case c : cases) {
            if (c.accountId != null) {
                c.contactId = accountNumberContactMap.get(c.Account_Number_USA__c).id;
            }
        }
        
        update cases;
    }
}