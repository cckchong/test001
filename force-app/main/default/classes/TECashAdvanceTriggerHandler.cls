/**
 * TECashAdvanceTriggerHandler
 * @author Ted Pang and Kelvin Wong
 * @description to get exchange rate for cash advance and default the status according to Travel Application
 */
public without sharing class TECashAdvanceTriggerHandler {
    
    /**
     * @desciption map cash advance to exchange rate date
     */
    //public static Map<Id, Date> exchangeDateMap = new Map<Id, Date>();
    
    /**
     * @description add value to the key of the map with currency
     */
     /*
    private static void setValue(Map<Id, Double> mapToAdd, Id key, Double value, Double curr) {
        if (curr != NULL){
            if (mapToAdd.containsKey(key)) {
                Double existingValue = mapToAdd.get(key);
                mapToAdd.remove(key);
                mapToAdd.put(key, value * curr + existingValue);
            } else {
                mapToAdd.put(key, value * curr);
            }
        }
    }
    */
    /**
     * @description get local currency from employee administrator ids
     */
     /*
    private static Map<Id, String> getLocalCurrency(Map<Id, Id> empAdminIds) {
        Map<Id, Id> expensePolicy = new Map<Id, Id>();
        Map<Id, String> expPolicyName = new Map<Id, String>(), empCurrName = new Map<Id, String>(), taCurrName = new Map<Id, String>();
        for (Employee_Administrator__c empAdmin : [select Id, Employee__r.Expense_Policy__c, 
                                                    Employee__r.Expense_Policy__r.Local_Currency__r.Name
                                                    from Employee_Administrator__c where Id IN :empAdminIds.values()]) {
            //expensePolicy.put(empAdmin.Id, empAdmin.Employee__r.Expense_Policy__c);
            empCurrName.put(empAdmin.Id, empAdmin.Employee__r.Expense_Policy__r.Local_Currency__r.Name);
        }
        //if (expensePolicy.size() == 0) return null;
        if (empCurrName.size() == 0) return null;
       
        for (Id ta : empAdminIds.keySet()) {
            taCurrName.put(ta, empCurrName.get(empAdminIds.get(ta)));
        }
        return taCurrName;
    }
    */
    
    /**
     * @description get exchange rate with existing and local currency names, e.g. 'USD', 'HKD' => 7.8
     */
     /*
    private static Map<Id, Double > getExchangeRate(Map<Id, String> existingCurrencyName, Map<Id, String> localCurrencyName, Map <ID, Cash_Advance__c> cashAdvanceMap) {
        Map<Id, String> currencyIdentifier = new Map<Id, String>();
        Map<Id, Double> exchangeRate = new Map<Id, Double>();
        Map<Id, exchange_rate__c> exchangeRateMap = new Map<Id, exchange_rate__c>();
        for (Id ta : existingCurrencyName.keySet()) {
            if (localCurrencyName.containsKey(ta)) {
                if ((existingCurrencyName.get(ta)).equals(localCurrencyName.get(ta))) {
                    exchangeRate.put(ta, 1);
                    exchangeDateMap.put(ta, System.today());
                } else {
                    currencyIdentifier.put(ta, existingCurrencyName.get(ta) + localCurrencyName.get(ta));
                }
            }
        }
        if (currencyIdentifier.size() > 0) {
            Map<String, Double> exchangeRateByIdentifier = new Map<String, Double>();
            Map<String, Date> exchangeDateByIdentifier = new Map<String, Date>();
            //for (Exchange_Rate__c er : [select Id, Date__c, Rate__c, Tech_From_To_Currency__c from Exchange_Rate__c where Tech_From_To_Currency__c = :currencyIdentifier.values() and Is_Latest__c = true and Is_Book_Rate__c = true order by Tech_From_To_Currency__c ]) {
            for (Exchange_Rate__c er : [select Id, Date__c, Rate__c, Tech_From_To_Currency__c from Exchange_Rate__c where Tech_From_To_Currency__c = :currencyIdentifier.values() and Is_Book_Rate__c = true order by Tech_From_To_Currency__c, Date__c]) {
                exchangeRateByIdentifier.put(er.Tech_From_To_Currency__c, er.Rate__c);
                exchangeDateByIdentifier.put(er.Tech_From_To_Currency__c, er.Date__c);
                exchangeRateMap.put(er.id, er);
            }
            for (Id ta : currencyIdentifier.keySet()) {
                for (Exchange_Rate__c reader : exchangeRateMap.values()){
                    if(cashAdvanceMap.get(ta).travel_application__r.submission_date__c >= reader.date__c && reader.Tech_From_To_Currency__c  == currencyIdentifier.get(ta)){
                        exchangeRate.put(ta,reader.rate__c);
                        exchangeDateMap.put(ta,reader.Date__c);
                    }
                }
            }
        }
        if (exchangeRate == null) return null;
        else return exchangeRate;
    }
    */
    /**
     * @description count Open and Paid Out cash advance number after insert , after update and after delete
     */
    /*
    public static void countOpenAndPaidOutCashAdvanceNumber(List <Cash_Advance__c>  newCashAdvanceList, Map <Id,Cash_Advance__c> oldCashAdvanceMap){
        
        // used for counting cash advance number
        List <Travel_Application__c> travelApplicationList = new List <Travel_Application__c> ();
        Set <ID> travelApplicationSetId = new Set <ID>(), cashAdvanceSetId = new set<ID>(), newCashAdvanceSetId = new set<ID>();
        Map <String, AggregateResult> TravelApplicationCashAdvanceCounterMap = new Map <String, AggregateResult>();
        Map <id, Cash_Advance__c> newCashAdvanceMap = new Map <id, Cash_Advance__c>();
        String key = '';
        
        // get travel application set id
        if ( oldCashAdvanceMap != null){            
            for(Cash_Advance__c ca : newCashAdvanceList){
                newCashAdvanceMap.put(ca.id , ca);
            }
            for(Cash_Advance__c ca : oldCashAdvanceMap.values()){
                if ( ca.status__c !=  newCashAdvanceMap.get(ca.id).status__c){
                travelApplicationSetId.add(ca.Travel_Application__c);
                }
            }
        }
        if ( newCashAdvanceList != null ){
            for(Cash_Advance__c ca : newCashAdvanceList){
                travelApplicationSetId.add(ca.Travel_Application__c);
                newCashAdvanceSetId.add(ca.Id);
            }
        }
        
        List <String> travelApplicationIDList = new List <String>();
        // get number of cash advance from related travel applications
        if(!travelApplicationSetId.isEmpty()) {
            for ( AggregateResult reader : [select Travel_Application__c, count(id) count_id, Status__c 
                                            from Cash_Advance__c 
                                            where (Status__c = :TEConstant.STATUS_OPEN or Status__c = :TEConstant.STATUS_PAID_OUT ) 
                                            and Travel_Application__c in :travelApplicationSetId and isDeleted = false  group by Travel_Application__c, Status__c ]  ){           
             key = (String)reader.get('Travel_Application__c');
             key = key.left(15);
             key += (String)reader.get('Status__c');
             TravelApplicationCashAdvanceCounterMap.put (key, reader);
             travelApplicationIDList.add((String)reader.get('Travel_Application__c'));
                                                                                       
            }
        }
        // insert into travel applications
        if(!travelApplicationIDList.isEmpty()) {
            for ( Travel_Application__c reader : [ select id, Number_Of_Open_Cash_Advance__c, Number_Of_Paid_Out_Cash_Advance__c
                                                  from Travel_Application__c where id in :travelApplicationIDList  ] ){
    
                reader.Number_Of_Open_Cash_Advance__c = 0;
                reader.Number_Of_Paid_Out_Cash_Advance__c = 0;
                key = (String)reader.id;
                key = key.left(15);
                key += TEConstant.STATUS_OPEN;                           
                if(TravelApplicationCashAdvanceCounterMap.containsKey(key)){                                          
                    if (TravelApplicationCashAdvanceCounterMap.get(key).get('Status__c') == TEConstant.STATUS_OPEN) {
                        reader.Number_Of_Open_Cash_Advance__c = (Integer) TravelApplicationCashAdvanceCounterMap.get(key).get('count_id');              
                    }
                }
                
                key = (String)reader.id;
                key = key.left(15);
                key += TEConstant.STATUS_PAID_OUT;
                if(TravelApplicationCashAdvanceCounterMap.containsKey(key)){                                          
                    if (TravelApplicationCashAdvanceCounterMap.get(key).get('Status__c') == TEConstant.STATUS_PAID_OUT) {
                        reader.Number_Of_Paid_Out_Cash_Advance__c = (Integer) TravelApplicationCashAdvanceCounterMap.get(key).get('count_id');              
                    }
                }    
                
                travelApplicationList.add(reader);  
            }
                
            update travelApplicationList;
        }
        
    }
    */
    
    Public Static Void updateExchangeRate (Map<id, Cash_Advance__c>  newCashAdvanceMap, Map <Id, Cash_Advance__c> oldCashAdvanceMap){
        Map< Id, Cash_Advance__c> cashAdvanceMap = new Map <Id, Cash_Advance__c>();
        Map<ID, ID> CashAdvanceTravelApplicationMap = new Map<ID, ID>();
        Map<ID, Travel_application__c> TravelApplicationMap = null; //new Map<ID, Travel_application__c>();
        Map<ID, String> localCurrencyMap = new Map<ID, String>();
        Map<String, Exchange_Rate__c> exchangeRateMap = new Map<String, Exchange_Rate__c>();
        Cash_Advance__c ca = null;
        String  travelApplicationId = null;
        
        for (Cash_Advance__c reader : newCashAdvanceMap.values()){
            if( (reader.status__c == TEConstant.STATUS_NOT_SUBMITTED || reader.status__c == TEConstant.STATUS_DRAFT) && reader.status__c != oldCashAdvanceMap.get(reader.id).status__c){
                reader.Tech_Exchange_Rate__c = 0;
                reader.Tech_Currency_Date__c = null;
            }
        }
        
        for (Cash_Advance__c reader : newCashAdvanceMap.values()){
            if(reader.status__c == TEConstant.STATUS_PAID_OUT && reader.status__c != oldCashAdvanceMap.get(reader.id).status__c){
                cashAdvanceMap.put(reader.id, reader);
                CashAdvanceTravelApplicationMap.put(reader.id, reader.travel_application__c);
            }
        }
    
        if(!cashAdvanceMap.isEmpty()){
            TravelApplicationMap = new Map<ID, Travel_application__c>
                                               ([
                                                    select id, on_behalf_of__c,
                                                    on_behalf_of__r.employee__r.expense_policy__r.local_currency__c
                                                    from travel_application__c 
                                                    where id in :CashAdvanceTravelApplicationMap.values()
                                               ]);            
            for(Id reader : TravelApplicationMap.keyset()){
                travelApplicationId = reader;
                for(Id key : CashAdvanceTravelApplicationMap.keyset()){
                    if(CashAdvanceTravelApplicationMap.get(key) == travelApplicationId){
                        localCurrencyMap.put(key, String.valueof(cashAdvanceMap.get(key).currency__c).left(15) + String.valueof(TravelApplicationMap.get(travelApplicationId).on_behalf_of__r.employee__r.expense_policy__r.local_currency__c).left(15));
                    }
                }
                
            }
            for(Exchange_Rate__c reader : [select id, Tech_From_To_Currency_ID__c, rate__c, date__c
                                           from Exchange_Rate__c 
                                           where Tech_From_To_Currency_ID__c in :localCurrencyMap.values()
                                           and Is_Book_Rate__c = true
                                           and Is_Latest__c = true
                                          ]){
                exchangeRateMap.put(reader.Tech_From_To_Currency_ID__c, reader);
            }
            String FromToCurrencyID = '';
            for(Id key : newCashAdvanceMap.keySet()){
                ca = newCashAdvanceMap.get(key);
                FromToCurrencyID = localCurrencyMap.get(key);
                ca.Tech_Exchange_Rate__c = exchangeRateMap.get(FromToCurrencyID).rate__c;
                ca.Tech_Currency_Date__c= exchangeRateMap.get(FromToCurrencyID).date__c;
            }
        }
    }
    

    /**
     * @description sum up cash advance before insert, before update and after delete
     */
    /* 
    public static void SumCashAdvance(List <Cash_Advance__c>  newCashAdvanceList, Map <Id,Cash_Advance__c> oldCashAdvanceMap){ 
          
        List <Travel_Application__c> travelApplicationList = new List <Travel_Application__c> ();
        Set <ID> travelApplicationSetId = new Set <ID>(), cashAdvanceSetId = new set<ID>();
        ExchangeDateMap = new Map<Id, Date>();
        List<Cash_Advance__c> updateCashAdvanceList = new List<Cash_Advance__c>();
        Map <ID, String> CashAdvanceExistingCurrencyNameMap = new Map<ID, String>(), CurrencyIdMap = new Map<Id, String>();
        Map <ID, Double> TravelApplicationCashAdvanceSumMap = new Map <ID, Double>(), CashAdvanceAmountMap = new Map <ID, Double>();
        Map <ID, ID> CashAdvanceCurrencyMap = new Map<ID, ID>(), CashAdvanceEmployeeAdminMap = new Map<ID, ID>();
        Map <ID, Cash_Advance__c> cashAdvanceMap = new Map <ID, Cash_Advance__c>();
        
        // get travel application set id
        if (oldCashAdvanceMap != null && newCashAdvanceList != null){
            for (Cash_Advance__c ca : newCashAdvanceList){
                //if (ca != oldCashAdvanceMap.get(ca.Id)){
                if (ca.Status__c != oldCashAdvanceMap.get(ca.Id).Status__c && (
                    ca.Status__c == TEConstant.STATUS_PAID_OUT ||
                    ca.Status__c == TEConstant.STATUS_OPEN ||
                    ca.Status__c == TEConstant.STATUS_RETURN )){
                    travelApplicationSetId.add(ca.Travel_Application__c);
                }
            }
        }
        else if ( oldCashAdvanceMap != null ){
            for(Cash_Advance__c ca : oldCashAdvanceMap.values()){
                travelApplicationSetId.add(ca.Travel_Application__c);
            }
        }
        
        // get all cash advance from related travel applications
        if( !travelApplicationSetId.isEmpty()) {
            for (Cash_Advance__c ca : [select Id, Amount__c, Currency__r.Name, Travel_Application__r.Submission_Date__c, Travel_Application__r.On_Behalf_Of__c from Cash_Advance__c where Travel_Application__c in :travelApplicationSetId and isDeleted = false]) {
                cashAdvanceSetId.add(ca.Id);
                CashAdvanceEmployeeAdminMap.put(ca.Id, ca.Travel_Application__r.On_Behalf_Of__c);
                CashAdvanceAmountMap.put(ca.Id, ca.Amount__c);
                CashAdvanceExistingCurrencyNameMap.put(ca.Id, ca.Currency__r.Name);
                cashAdvanceMap.put(ca.id, ca);
            }
           
            // get local currency for all cash advances from related travel applications
            Map<ID, String> localCurrencyMap = getLocalCurrency(CashAdvanceEmployeeAdminMap);
            // get exchange rate for all cash advances from related travel applications
            Map<ID, Double> ExchangeRateMap = getExchangeRate(CashAdvanceExistingCurrencyNameMap, localCurrencyMap, cashAdvanceMap);    
            // update currency date, local currency and local amount
            // remove updated or inserted cash advances
            if ( newCashAdvanceList != null ){
                for(Cash_Advance__c ca : newCashAdvanceList){
                    if (cashAdvanceSetId.contains(ca.Id)) {
                        cashAdvanceSetId.remove(ca.Id);
                    }
                }
          
                for (Cash_Advance__c ca : newCashAdvanceList) {
                    ca.Tech_Currency_Date__c = ExchangeDateMap.get(ca.Id);
                    ca.Tech_Exchange_Rate__c = ExchangeRateMap.get(ca.Id);
                    updateCashAdvanceList.add(ca);
                }
                newCashAdvanceList = updateCashAdvanceList;
            }
            // input the values for unchanged cash advances
            for (Travel_Application__c reader : [select id, Tech_Cash_Advance_Sum__c from Travel_Application__c where id in :travelApplicationSetId
                                                 and isDeleted = false]) {
                setValue(TravelApplicationCashAdvanceSumMap, (ID) reader.get('id'), (Double) reader.get('Tech_Cash_Advance_Sum__c'), 1);
            }
              
            // input the values for updated cash advances
            if (newCashAdvanceList != null && oldCashAdvanceMap != null) {
                String oldkey = '';
                String newkey = '';
                for (Cash_Advance__c reader : newCashAdvanceList) {
                    if (oldCashAdvanceMap.containsKey(reader.Id)) {
                        oldkey = (String) (oldCashAdvanceMap.get(reader.Id)).get('Status__c');
                        newkey = (String) reader.get('Status__c');
                        if (!(oldkey.equals(newkey))){
                            if (ExchangeRateMap.get(reader.Id) == null){
                                reader.addError(Label.TE_Expense_Detail_Cannot_Find_Exchange_Rate);
                            }
                            if ((newkey).equals(TEConstant.STATUS_RETURN)) {
                                setValue(TravelApplicationCashAdvanceSumMap, (ID) reader.get('Travel_Application__c'), -1 * (Double)reader.get('Amount__c'), (Double)ExchangeRateMap.get(reader.Id));
                            }
                            if ((newkey).equals(TEConstant.STATUS_PAID_OUT)) {
                                setValue(TravelApplicationCashAdvanceSumMap, (ID) reader.get('Travel_Application__c'), (Double)reader.get('Amount__c'), (Double)ExchangeRateMap.get(reader.Id));
                            }   
                        }
                    }
                }
            }
          
            // insert into travel applications
            for ( Travel_Application__c reader : [ select id, Tech_Cash_Advance_Sum__c from Travel_Application__c where id in :travelApplicationSetId  ]){
                if (TravelApplicationCashAdvanceSumMap.containsKey(reader.Id)) {
                    reader.Tech_Cash_Advance_Sum__c = TravelApplicationCashAdvanceSumMap.get(reader.Id);
                }
                travelApplicationList.add(reader);
            }


            update travelApplicationList;
           

        }
    
    }
    */
    /**
     * @description default the new Cash Advance Status to be Open when Travel Application Status is Approved before insert
     */
    public static void defaultStatus(List <Cash_Advance__c>  newCashAdvanceList, Map <Id,Cash_Advance__c> oldCashAdvanceMap){
        List<Id> travelApplicationIdList = new List<Id> ();
        Map<Id, Travel_Application__c> ApprovedtravelApplicationMap = new Map<Id, Travel_Application__c> ();
        Map<Id, Travel_Application__c> travelApplicationExpensePolicyMap = new Map<Id, Travel_Application__c> ();
        
        for (Cash_Advance__c cashAdvance : newCashAdvanceList) {
                travelApplicationIdList.add(cashAdvance.Travel_Application__c);
        }
        if(!travelApplicationIdList.isEmpty()){
            for(Travel_Application__c travelApplication  : [select Id, Status__c, on_behalf_of__r.employee__r.expense_policy__r.Name, actual_approver_1__c, actual_approver_2__c, actual_approver_3__c, actual_approver_4__c from Travel_Application__c where Id in: travelApplicationIdList]){
                travelApplicationExpensePolicyMap.put(travelApplication.Id, travelApplication);
                if ((travelApplication.Status__c == TEConstant.STATUS_CONFIRMED) || (travelApplication.Status__c == TEConstant.STATUS_PENDING)) {
                    ApprovedtravelApplicationMap.put(travelApplication.Id, travelApplication);
                }    
            }            
            for (Cash_Advance__c cashAdvance : newCashAdvanceList){
                cashAdvance.Tech_Expense_Policy_Name__c = travelApplicationExpensePolicyMap.get(cashAdvance.Travel_Application__c).on_behalf_of__r.employee__r.expense_policy__r.Name;
                if (ApprovedtravelApplicationMap.get(cashAdvance.Travel_Application__c) != null) {
                    if (ApprovedtravelApplicationMap.get(cashAdvance.Travel_Application__c).Status__c == TEConstant.STATUS_PENDING ) {
                        cashAdvance.Status__c = TEConstant.STATUS_PENDING;
                    }
                    else if (ApprovedtravelApplicationMap.get(cashAdvance.Travel_Application__c).Status__c == TEConstant.STATUS_CONFIRMED) {
                        cashAdvance.Status__c = TEConstant.STATUS_OPEN;
                    }
                                        
                } 
            }
        }
    }
    /*
    Public Static Void shareToApprover(Map<Id, Cash_Advance__c> newCashAdvanceMap){
            
            List<Cash_Advance__c> cashAdvanceList = new List<Cash_Advance__c>();            
            for(Cash_Advance__c reader :newCashAdvanceMap.values()){
                if(reader.status__c == TEConstant.STATUS_OPEN){
                    cashAdvanceList.add(reader);
                }
            }
            if(!cashAdvanceList.isEmpty()){
                TEManualSharingCtrl.TECashAdvanceSharing(cashAdvanceList , true);
            }
            
    }
    */
    Public Static Void accountNumberSetup(Map<Id, Cash_Advance__c> newCashAdvanceMap, Map<Id, Cash_Advance__c> oldCashAdvanceMap){
        List <Id> toBeUpdateCashAdvanceIdList = new List <Id>();
        List <Id> expensePolicyList = new List <Id>();
        List <Id> currencyList = new List <Id>();
        Map <Id, Cash_Advance__c> toBeUpdateCashAdvanceMap = new Map <Id, Cash_Advance__c>();
        Map <String, Account_info__c> AccountInfoMap = new Map <String, Account_info__c>();
        String key ='';
        
        for(Cash_Advance__c reader : newCashAdvanceMap.values()){
            if(reader.status__c == TEConstant.STATUS_PAID_OUT && (reader.status__c != oldCashAdvanceMap.get(reader.id).status__c)){
                toBeUpdateCashAdvanceIdList.add(reader.id);
            }
        }
        if (!toBeUpdateCashAdvanceIdList.isempty()){
            for(Cash_Advance__c reader :[select id, currency__c, Travel_Application__r.on_behalf_of__r.employee__r.expense_policy__c
                                         from Cash_Advance__c 
                                         where id in :toBeUpdateCashAdvanceIdList]){
                currencyList.add(reader.currency__c);
                expensePolicyList.add(reader.Travel_Application__r.on_behalf_of__r.employee__r.expense_policy__c);
                toBeUpdateCashAdvanceMap.put(reader.id, reader);
            }
            for(Account_info__c reader :[select id, expense_policy__c, currency__c, Name, type__c
                                         from account_info__c 
                                         where expense_policy__c in :expensePolicyList and currency__c in :currencyList]){
                key = String.ValueOf(reader.currency__c).left(15) + String.ValueOf(reader.expense_policy__c).left(15);
                AccountInfoMap.put(key, reader);
            }
            for(Id reader : toBeUpdateCashAdvanceIdList){
                if (toBeUpdateCashAdvanceMap.containsKey(reader) && toBeUpdateCashAdvanceMap.containsKey(reader)){
                    key = String.ValueOf(toBeUpdateCashAdvanceMap.get(reader).currency__c).left(15) + String.ValueOf(toBeUpdateCashAdvanceMap.get(reader).Travel_Application__r.on_behalf_of__r.employee__r.expense_policy__c).left(15);
                    if (AccountInfoMap.containsKey(key)){
                        newCashAdvanceMap.get(reader).Account_Number__c = AccountInfoMap.get(key).id;
                    }
                }
            }
        }
        
    }
    
    
    /**
    * @description Add Expense Detail Log after the Cash Advance is updated/inserted
    */ 
    public static void addExpenseDetailLogUponUpdate(Map <Id, Cash_Advance__c> newCashAdvanceMap, Map <Id, Cash_Advance__c> oldCashAdvanceMap){
        List<Expense_Detail_Log__c> logToInsertList = new List<Expense_Detail_Log__c>();
        List <ID> cashAdvanceIdList = new List <ID>();
        Map<Id, Cash_Advance__c> cashAdvanceMap = new Map<Id, Cash_Advance__c>();
        Map<String, String> typeMap = new Map <String, String>{
                TEConstant.STATUS_NOT_SUBMITTED => TEConstant.STATUS_CA_NOT_SUBMITTED,
                TEConstant.STATUS_PENDING_APPROVAL => TEConstant.STATUS_CA_PENDING_APPROVAL,
                TEConstant.STATUS_OPEN => TEConstant.STATUS_CA_OPEN,
                TEConstant.STATUS_PAID_OUT => TEConstant.STATUS_CA_PAID_OUT,
                TEConstant.STATUS_RETURN => TEConstant.STATUS_CA_TO_BE_RETURNED,
                TEConstant.STATUS_CANCELLED => TEConstant.STATUS_CA_CANCELLED,
                TEConstant.STATUS_CLOSED => TEConstant.STATUS_CA_CLOSED            
        };
        
        for (Cash_Advance__c reader : newCashAdvanceMap.values() ){       
            if (oldCashAdvanceMap == null || reader.status__c != oldCashAdvanceMap.get(reader.id).status__c){
                if (reader.Status__c == TEConstant.STATUS_NOT_SUBMITTED || 
                    reader.Status__c == TEConstant.STATUS_PENDING_APPROVAL ||
                    reader.Status__c == TEConstant.STATUS_OPEN || 
                    reader.Status__c == TEConstant.STATUS_PAID_OUT || 
                    reader.Status__c == TEConstant.STATUS_RETURN || 
                    reader.Status__c == TEConstant.STATUS_CANCELLED || 
                    reader.Status__c == TEConstant.STATUS_CLOSED  
                ){
                    cashAdvanceIdList.add(reader.id);
                }
            } 
        }
        
        if (cashAdvanceIdList.isEmpty()){
            return;
        } 
         
        for (Cash_Advance__c reader : [ select Id, 
                                        Amount__c, Currency__r.Name, Local_Amount__c, Tech_Exchange_Rate__c,
                                        Travel_Application__r.On_Behalf_of__r.Employee__r.Expense_Policy__r.Local_Currency__r.Name,
                                        Account_Number__r.Name, Travel_Application__c, Status__c,
                                        On_Behalf_Of__c, On_Behalf_Of_Function__c,
                                        Travel_Application__r.On_Behalf_of__r.Employee__c, Travel_Application__r.On_Behalf_of__r.Employee__r.Full_Name__c,
                                        Travel_Application__r.On_Behalf_Of__r.Employee__r.Employee_ID__c,
                                        Travel_Application__r.On_Behalf_Of__r.Employee__r.Original_Employee_ID__c,
                                        Travel_Application__r.On_Behalf_Of__r.Employee__r.Grade__c,
                                        Travel_Application__r.On_Behalf_Of__r.Employee__r.Division__c,
                                        Travel_Application__r.On_Behalf_Of__r.Employee__r.expense_policy__r.Name
                                        from Cash_Advance__c
                                        where Id in :cashAdvanceIdList]){
            cashAdvanceMap.put(reader.Id, reader);
        }
 
        //Datetime paidOutDate = null;
        // Build up expense detail log
        for (Id cashAdvanceId : cashAdvanceIdList){
            
            /*
            if (cashAdvanceMap.get(cashAdvanceId).Status__c == TEConstant.STATUS_PAID_OUT)
            {
                paidOutDate = Datetime.now();
            }
            */
            
            logToInsertList.add(new Expense_Detail_Log__c (
                //from cash advance
                Cash_Advance__c = cashAdvanceId,
                Amount__c = cashAdvanceMap.get(cashAdvanceId).Amount__c,
                Currency__c = cashAdvanceMap.get(cashAdvanceId).Currency__r.Name,
                Local_Amount__c = cashAdvanceMap.get(cashAdvanceId).Local_Amount__c,
                Local_Currency__c = cashAdvanceMap.get(cashAdvanceId).Travel_Application__r.On_Behalf_of__r.Employee__r.Expense_Policy__r.Local_Currency__r.Name,
                Exchange_Rate__c = cashAdvanceMap.get(cashAdvanceId).Tech_Exchange_Rate__c,
                Account_Number__c = cashAdvanceMap.get(cashAdvanceId).Account_Number__r.Name,
                           
                Employee__c = cashAdvanceMap.get(cashAdvanceId).Travel_Application__r.On_Behalf_of__r.Employee__c,
                Employee_Full_Name__c = cashAdvanceMap.get(cashAdvanceId).Travel_Application__r.On_Behalf_of__r.Employee__r.Full_Name__c,
                Employee_Department__c = cashAdvanceMap.get(cashAdvanceId).On_Behalf_Of_Function__c,
                Employee_ID__c = cashAdvanceMap.get(cashAdvanceId).Travel_Application__r.On_Behalf_Of__r.Employee__r.Employee_ID__c,
                Original_Employee_ID__c = cashAdvanceMap.get(cashAdvanceId).Travel_Application__r.On_Behalf_Of__r.Employee__r.Original_Employee_ID__c,
                Employee_Grade__c = cashAdvanceMap.get(cashAdvanceId).Travel_Application__r.On_Behalf_Of__r.Employee__r.Grade__c,
                Division__c = cashAdvanceMap.get(cashAdvanceId).Travel_Application__r.On_Behalf_Of__r.Employee__r.Division__c,
                Expense_Policy_Name__c = cashAdvanceMap.get(cashAdvanceId).Travel_Application__r.On_Behalf_Of__r.Employee__r.expense_policy__r.Name,
                //Paid_Out_Date__c = paidOutDate,
                Travel_Application__c = cashAdvanceMap.get(cashAdvanceId).Travel_Application__c,
                Expense_Type__c = 'Cash Advance',

                Type__c = typeMap.get(cashAdvanceMap.get(cashAdvanceId).Status__c)
            
            ));
        }
        if (!logToInsertList.isEmpty()){
            insert logToInsertList;
        }      
    }
    
    
    /**
    * @description Modify Cash Advance Content
    */ 
    public static void updateCashAdvContent(Map <Id, Cash_Advance__c> newCashAdvanceMap, Map <Id, Cash_Advance__c> oldCashAdvanceMap){
        Map<id, String> travelIdWithCAMap = new Map<id, String>();
        Map<id, List<id>> travelIdWithGroupUserMap = new Map<id, List<id>>();
        List<id> financeUserList = new List<id>();
        String content = '';
        String TEFinGroup = 'TE-@name-FIN';
        String applicantFinGroup = '';
        for(Cash_Advance__c reader : newCashAdvanceMap.values()){
            if(reader.status__c == 'PE'){
                if((reader.Currency__c != oldCashAdvanceMap.get(reader.id).Currency__c) || (reader.Amount__c != oldCashAdvanceMap.get(reader.id).Amount__c) || (reader.Expected_Collection_Date__c != oldCashAdvanceMap.get(reader.id).Expected_Collection_Date__c) ){
                    applicantFinGroup = '';
                    financeUserList = new List<id>();
                    if(travelIdWithCAMap.containsKey(reader.travel_Application__c)){
                        content  = travelIdWithCAMap.get(reader.travel_Application__c);
                        content += cashAdvanceContent(oldCashAdvanceMap.get(reader.id), reader);
                    }
                    else{
                        content = cashAdvanceContent(oldCashAdvanceMap.get(reader.id), reader);
                    }
                    applicantFinGroup = TEFinGroup.replace('@name', reader.Tech_Expense_Policy_Name__c);
                    for(GroupMember GMReader :[SELECT Id, GroupId, UserOrGroupId, SystemModstamp FROM GroupMember where Group.Name = :applicantFinGroup]){
                        financeUserList.add(GMReader.UserOrGroupId);
                    }
                    travelIdWithGroupUserMap.put(reader.travel_Application__c, financeUserList);                   
                    travelIdWithCAMap.put(reader.travel_Application__c, content);
                }
            }
        }
        if(!travelIdWithCAMap.isEmpty()){
            for(Id reader :travelIdWithCAMap.keySet()){
                if(!Test.isRunningTest()){
                    ChatterUtil.simpleTextPostWithMultipleMentions(reader, travelIdWithGroupUserMap.get(reader), travelIdWithCAMap.get(reader));
                }
            }
        }
    }
    
    private static String cashAdvanceContent(Cash_Advance__c oldCashAdvance, Cash_Advance__c newCashAdvance){
        String content = '';
        content += 'Cash Advance#: ' + newCashAdvance.Name + '\r\n';
        content += 'Currency: ' + oldCashAdvance.Currency_Name__c + ' ==> ' + newCashAdvance.Currency_Name__c + '\r\n';
        content += 'Amount: ' + oldCashAdvance.Amount__c + ' ==> ' + newCashAdvance.Amount__c + '\r\n';
        content += 'Expected Collection Date: ' + ((DateTime)oldCashAdvance.Expected_Collection_Date__c).format('dd MMM yyyy') + ' ==> ' + ((DateTime)newCashAdvance.Expected_Collection_Date__c).format('dd MMM yyyy') + '\r\n';
        return content;
    }
}