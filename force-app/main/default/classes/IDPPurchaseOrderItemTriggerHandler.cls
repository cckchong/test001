public without sharing  class IDPPurchaseOrderItemTriggerHandler{

    public static void PObudget(Map<Id, Purchase_Order_Item__c> newPurchaseOrderItemMap, Map<Id, Purchase_Order_Item__c> oldPurchaseOrderItemMap) { 
        Map<Id, Purchase_Order_Item__c> poiMap = new Map<Id, Purchase_Order_Item__c>();
        Set <String> fromCurrency = new Set <String>();
        Map<String, Exchange_rate__c> exchangeRateMap = null;
            for(Purchase_Order_Item__c reader : newPurchaseOrderItemMap.values()){
                if(reader.status__c != oldPurchaseOrderItemMap.get(reader.id).status__c && reader.status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED){
                    poiMap.put(reader.id, reader);
                    fromCurrency.add(reader.currency__c);
                    //fromToCurrency.add(String.valueof(reader.currency__c).subString(0,15) + String.valueof(budgetCurrency.id).subString(0,15));
                }            
            }
        if(!fromCurrency.isEmpty()){
            exchangeRateMap =  getExchangeRate(fromCurrency);
            for(Purchase_Order_Item__c reader : newPurchaseOrderItemMap.values()){
                //reader.Budget_Exchange_Rate__c = exchangeRateMap.get(String.valueof(reader.currency__c).subString(0,15) + String.valueof(budgetCurrency.id).subString(0,15)).Rate__c;
                reader.Budget_Exchange_Rate__c = exchangeRateMap.get(reader.currency__c).Rate__c;
            }
        }
    }
    
    /*
    public static void deductBudget(Map<Id, Purchase_Order_Item__c> newPurchaseOrderItemMap, Map<Id, Purchase_Order_Item__c> oldPurchaseOrderItemMap) {
        Set<String> budgetSet = new Set<String>();
        Map<Id, Purchase_Order_Item__c> poiMap = new Map<Id, Purchase_Order_Item__c>();
        List<Purchase_Request_Item__c> priList = new List< Purchase_Request_Item__c>();
        Map<String, IDP_Budget__c> budgetMap = new Map<String, IDP_Budget__c>();
        Double totalQTY = 0;
        for(Purchase_Order_Item__c reader : newPurchaseOrderItemMap.values()){
            if(reader.status__c != oldPurchaseOrderItemMap.get(reader.id).status__c && reader.status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CLOSED){
               poiMap.put(reader.id, reader);
            }        
        }
        if(!poiMap.isempty()){
            for(Purchase_Request_Item__c pri : [select id, Purchase_Request__r.IDP_Budget__c, Purchase_Request__r.Budget_Date__c, 
                                                //Purchase_Request__r.Budget__r.Expense_Amount__c,
                                                Quantity__c, Budget_Sub_Total__c, Purchase_Order_Item__c,
                                                Purchase_Order_Item__r.Quantity__c, Purchase_Order__c,
                                                Purchase_Order_Item__r.Received_Quantity__c ,
                                                Purchase_Order_Item__r.Budget_Exchange_Rate__c ,
                                                Price__c , Purchase_Order_Item__r.Price__c,
                                                Purchase_Order__r.Total_Received_Qty__c,
                                                Purchase_Order_Item__r.Tech_PO_Currency_Shipping__c,
                                                Purchase_Order__r.Number_of_Closed__c,
                                                Purchase_Order_Item__r.Tech_PO_Currency_Tax__c,
                                                Purchase_Order_Item__r.Tech_PO_Currency_Other_Cost__c 
                                                from Purchase_Request_Item__c 
                                                where Purchase_Order_Item__c in :poiMap.keySet()
                                                order by Purchase_Order__c, Purchase_Request__r.Submission_Date__c desc
                                                ]){
                
                budgetSet.add(pri.Purchase_Request__r.IDP_Budget__c);
                priList.add(pri);
            }
            if(!budgetSet.isempty()){
                for(IDP_Budget__c reader :[select id,  
                                           Department_Code__c, Function_Code__c, Section_Code__c, Site__c 
                                           
                                           from IDP_Budget__c 
                                           where Id in : budgetSet
                                          ]){
                    budgetMap.put(reader.Id, reader);
                }
               //budgetMap.get(reader.Purchase_Request__r.Budget__c).Expense_Amount__c 
                for(Purchase_Request_Item__c pri : priList){
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 1){
                       budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Jan_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 2){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Feb_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 3){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Mar_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 4){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Apr_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 5){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).May_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 6){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Jun_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 7){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Jul_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 8){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Aug_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 9){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Sept_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 10){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Oct_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 11){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Nov_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(pri.Purchase_Request__r.Budget_Date__c.month() == 12){
                        budgetMap.get(pri.Purchase_Request__r.IDP_Budget__c).Dec_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    } 
                }
                
                
               
                
            }
            
        }
    }
   */
   /*
    public static void deductBudget_bk1(Map<Id, Purchase_Order_Item__c> newPurchaseOrderItemMap, Map<Id, Purchase_Order_Item__c> oldPurchaseOrderItemMap) {
        Set<String> budgetSet = new Set<String>();
        Map<Id, Purchase_Order_Item__c> poiMap = new Map<Id, Purchase_Order_Item__c>();
        List<Purchase_Request_Item__c> priList = new List< Purchase_Request_Item__c>();
        Map<String, Budget__c> budgetMap = new Map<String, Budget__c>();
        Double totalQTY = 0;
        for(Purchase_Order_Item__c reader : newPurchaseOrderItemMap.values()){
            if(reader.status__c != oldPurchaseOrderItemMap.get(reader.id).status__c && reader.status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CLOSED){
               poiMap.put(reader.id, reader);
            }        
        }
        
        if(!poiMap.isempty()){
            for(Purchase_Request_Item__c pri : [select id, Purchase_Request__r.Budget__c, 
                                                Purchase_Request__r.Budget__r.Expense_Amount__c,
                                                Quantity__c, Budget_Sub_Total__c, Purchase_Order_Item__c,
                                                Purchase_Order_Item__r.Quantity__c, Purchase_Order__c,
                                                Purchase_Order_Item__r.Received_Quantity__c ,
                                                Purchase_Order_Item__r.Budget_Exchange_Rate__c ,
                                                Price__c , Purchase_Order_Item__r.Price__c,
                                                Purchase_Order__r.Total_Received_Qty__c,
                                                Purchase_Order_Item__r.Tech_PO_Currency_Shipping__c,
                                                Purchase_Order__r.Number_of_Closed__c,
                                                Purchase_Order_Item__r.Tech_PO_Currency_Tax__c,
                                                Purchase_Order_Item__r.Tech_PO_Currency_Other_Cost__c 
                                                from Purchase_Request_Item__c 
                                                where Purchase_Order_Item__c in :poiMap.keySet()
                                                order by Purchase_Order__c, Purchase_Request__r.Submission_Date__c desc
                                                ]){
                budgetSet.add(pri.Purchase_Request__r.Budget__c);
                priList.add(pri);
            }
            if(!budgetSet.isempty()){
                budgetMap = getWithheldBudget(budgetSet);
                for(Purchase_Request_Item__c  pri : priList ){
                    if(budgetMap.containsKey(pri.Purchase_Request__r.Budget__c)){
                        budgetMap.get(pri.Purchase_Request__r.Budget__c).Withheld_Amount__c -= pri.Budget_Sub_Total__c;
                    }
                }
            }
            
            
            String poid = null;
            for(Purchase_Request_Item__c reader : priList){
                if(reader.Purchase_Order_Item__r.Received_Quantity__c == reader.Purchase_Order_Item__r.Quantity__c){
                    budgetMap.get(reader.Purchase_Request__r.Budget__c).Expense_Amount__c += 
                                 (reader.Quantity__c * reader.Purchase_Order_Item__r.Price__c +
                                  (reader.Purchase_Order_Item__r.Tech_PO_Currency_Shipping__c +
                                   reader.Purchase_Order_Item__r.Tech_PO_Currency_Tax__c +
                                   reader.Purchase_Order_Item__r.Tech_PO_Currency_Other_Cost__c                                  
                                  ) * reader.Purchase_Order_Item__r.Quantity__c /reader.Purchase_Order__r.Total_Received_Qty__c
                                 ) * reader.Purchase_Order_Item__r.Budget_Exchange_Rate__c;
                    totalQTY = 0;
                }else{
                    if(poid != reader.Purchase_Order__c){
                       poid = reader.Purchase_Order__c;
                       totalQTY = 0; 
                    }
                    if(totalQTY <= reader.Purchase_Order_Item__r.Received_Quantity__c){
                        if(totalQTY + reader.Quantity__c <= reader.Purchase_Order_Item__r.Received_Quantity__c){
                            budgetMap.get(reader.Purchase_Request__r.Budget__c).Expense_Amount__c += 
                                (reader.Quantity__c * reader.Purchase_Order_Item__r.Price__c +
                                  (reader.Purchase_Order_Item__r.Tech_PO_Currency_Shipping__c +
                                   reader.Purchase_Order_Item__r.Tech_PO_Currency_Tax__c +
                                   reader.Purchase_Order_Item__r.Tech_PO_Currency_Other_Cost__c                                  
                                  ) * reader.Purchase_Order_Item__r.Quantity__c /reader.Purchase_Order__r.Total_Received_Qty__c                                
                                )* reader.Purchase_Order_Item__r.Budget_Exchange_Rate__c;
                        }
                        else{
                            budgetMap.get(reader.Purchase_Request__r.Budget__c).Expense_Amount__c += 
                            ( (reader.Purchase_Order_Item__r.Received_Quantity__c - totalQTY) * reader.Purchase_Order_Item__r.Price__c +
                              (reader.Purchase_Order_Item__r.Tech_PO_Currency_Shipping__c +
                                   reader.Purchase_Order_Item__r.Tech_PO_Currency_Tax__c +
                                   reader.Purchase_Order_Item__r.Tech_PO_Currency_Other_Cost__c                                  
                              ) * ((reader.Purchase_Order__r.Number_of_Closed__c == 1)? 1 : reader.Purchase_Order_Item__r.Received_Quantity__c - totalQTY) /reader.Purchase_Order__r.Total_Received_Qty__c
                            ) * reader.Purchase_Order_Item__r.Budget_Exchange_Rate__c;
                        }
                    }
                    totalQTY += reader.Quantity__c;
                }
            }
            if(!budgetMap.isempty()){
                upsert budgetMap.values();
            }
            
        }
        
        
    
    }
    */
    /*
    public static void deductBudget_bk(Map<Id, Purchase_Order_Item__c> newPurchaseOrderItemMap, Map<Id, Purchase_Order_Item__c> oldPurchaseOrderItemMap) {
    
        //get all related PRIs
        //Query PRI by POI Ids
        //form Map<PRI, budget__c's key>
        //get all related budgets
        //Query budgets by forming the key from PRI
        //form Map<Key, Budget__c> 
        //loop Map<PRI, budget__c's key> and get related budget from Map<Key, Budget__c> 
        //deduct the budget amount = POI updated price * PR Quantity
        Map<String, Purchase_Request_Item__c> prIdPRMap = new Map<String, Purchase_Request_Item__c> ();
        Map<String, String> prIdBudgetKeyMap = new Map<String, String> ();
        Map<String, String> prIdBugetKeyWithSectionMap = new Map<String, String> ();
        Map<String, Budget__c> withheldBudgetIdBudgetMap = new Map<String, Budget__c> ();
        Map<String, Budget__c> toBeUsedBudgetIdBudgetMap = new Map<String, Budget__c> ();
        Map<String, Budget__c> toBeUpdatedBudgetMap = new Map<String, Budget__c> ();
        Map<String, Exchange_Rate__c> fromToCurrencyERmap = new Map<String, Exchange_Rate__c>();
        Set<String> targetedWithheldBudgetSet = new Set<String> ();
        Set<String> targetedPOIIDSet = new Set <String>();
        Set<String> targetedToBeUsedBudgetKeySet = new Set <String>();
        Set<String> fromToCurrencyIdSet = new Set<String> ();
        String fromCurrencyId = '';
        String toCurrencyId = '';
        String siteName = '';
        String function = '';
        String department = '';
        String section = '';
        String catalog = '';
        String catalogPolicyFunctionDepartmentSection = '';
        Double usedBudget = 0;
        for(Purchase_Order_Item__c reader : newPurchaseOrderItemMap.values()) {
            if(reader.Status__c != oldPurchaseOrderItemMap.get(reader.Id).Status__c) {
                if(reader.Status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CLOSED) { //IDPConstant.PURCHASE_ORDER_ITEM_STATUS_INOVICED) {
                    targetedPOIIDSet.add(reader.Id);
                }
            }
        }

        prIdPRMap = getPurchaseRequestItemMap(targetedPOIIDSet);

        for(Purchase_Request_Item__c reader : prIdPRMap.values()) {
            fromCurrencyId = reader.Purchase_Order_Item__r.Currency__c;
            toCurrencyId = reader.Purchase_Request__r.Budget__r.Currency__c;
            
            fromCurrencyId = fromCurrencyId.subString(0,15);
            toCurrencyId = toCurrencyId.subString(0,15);
            
            fromToCurrencyIdSet.add(fromCurrencyId + toCurrencyId);
            targetedWithheldBudgetSet.add(reader.Purchase_Request__r.Budget__c);
            targetedToBeUsedBudgetKeySet.add(reader.Purchase_Request__r.Budget__r.Tech_Cat_Policy_Function_Dep_Section__c);
            //targetedToBeUsedBudgetKeySet.add(reader.Purchase_Request__r.Budget__r.Tech_Catalog_Policy_Function_Dep_Section__c);
        
        }
        
        withheldBudgetIdBudgetMap = getWithheldBudget(targetedWithheldBudgetSet);
        toBeUsedBudgetIdBudgetMap = getToBeUsedBudget(targetedToBeUsedBudgetKeySet);
        
        for(Budget__c reader : withheldBudgetIdBudgetMap.values()) {
            toBeUpdatedBudgetMap.put(reader.Id, reader);
        }
        for(Budget__c reader : toBeUsedBudgetIdBudgetMap.values()) {
            toBeUpdatedBudgetMap.put(reader.Id, reader);
        }        
        
        fromToCurrencyERmap = getExchangeRate(fromToCurrencyIdSet);
        
        system.debug(targetedPOIIDSet);
        system.debug(prIdPRMap);
        system.debug(targetedToBeUsedBudgetKeySet);
        system.debug(toBeUsedBudgetIdBudgetMap);
        
        for(Purchase_Request_Item__c priReader : prIdPRMap.values()) {
            usedBudget = 0;
            usedBudget = priReader.Tech_POI_PO_Currency_Used_Budget_Amount__c;
            
            //usedBudget +=priReader.Purchase_Order_item__r.Price__c * priReader.Quantity__c;
            //usedBudget +=priReader.Purchase_Order_item__r.Tech_PO_Currency_Tax__c;
            //usedBudget +=priReader.Purchase_Order_item__r.Tech_PO_Currency_Shipping__c;
            
            
            fromCurrencyId = priReader.Purchase_Order_item__r.Currency__c;
            toCurrencyId = priReader.Purchase_Request__r.Budget__r.Currency__c;
            
            fromCurrencyId = fromCurrencyId.subString(0,15);
            toCurrencyId = toCurrencyId.subString(0,15);            
            
            
            if(fromToCurrencyERmap.containsKey(fromCurrencyId + toCurrencyId)){
                usedBudget = usedBudget * fromToCurrencyERmap.get(fromCurrencyId + toCurrencyId).Rate__c;
            
            }
            else {
                priReader.AddError(Label.IDP_PO_Exhcange_Rate_is_not_found_Message);
            }
            
            
            
            for(Budget__c budgetReader : toBeUpdatedBudgetMap.values()) {
                if(budgetReader.Tech_Cat_Policy_Function_Dep_Section__c == priReader.Purchase_Request__r.Budget__r.Tech_Cat_Policy_Function_Dep_Section__c) {
                //if(budgetReader.Tech_Catalog_Policy_Function_Dep_Section__c == priReader.Purchase_Request__r.Budget__r.Tech_Catalog_Policy_Function_Dep_Section__c) {
                    budgetReader.Expense_Amount__c += usedBudget;
                   
                    break;
                }
            } 
            toBeUpdatedBudgetMap.get(priReader.Purchase_Request__r.Budget__c).Withheld_Amount__c -= priReader.Budget_Sub_Total__c;

        }
        if(!toBeUpdatedBudgetMap.isEmpty()) {
            update toBeUpdatedBudgetMap.values();
        }        
        
        
        //if(!withheldBudgetIdBudgetMap.isEmpty()) {
        //    update toBeUpdatedBudgetMap.values();
        //}
        
        //if(!toBeUsedBudgetIdBudgetMap.isEmpty()){
        //    update toBeUsedBudgetIdBudgetMap.values();
        //}
   }
   */
   /*
    private static Map<String, Purchase_Request_Item__c> getPurchaseRequestItemMap (Set<String> pPOIIdSet) {
        
        Map<String, Purchase_Request_Item__c> temp = new Map<String, Purchase_Request_Item__c> ();
    
        for(Purchase_Request_Item__c reader : [select id, Purchase_Request__r.Catalog__c, Purchase_Request__r.On_Behalf_of__r.employee__r.Site__r.Name, 
                                                   Purchase_Request__r.On_Behalf_of__r.employee__r.Function__c, Purchase_Request__r.On_Behalf_of__r.employee__r.Department__c,
                                                   Purchase_Request__r.On_Behalf_of__r.employee__r.Section__c, Budget_Sub_Total__c, 
                                                   Purchase_Order_Item__r.Price__c, Purchase_Order_Item__r.Quantity__c,
                                                   Purchase_Order_Item__r.Tech_PO_Currency_Shipping__c, Purchase_Order_Item__r.Tech_PO_Currency_Tax__c, Purchase_Order_Item__r.Tech_PO_Currency_Other_Cost__c,
                                                   //Purchase_Request__r.Budget__c, Purchase_Request__r.Budget__r.Tech_Cat_Policy_Function_Dep_Section__c,
                                                   Quantity__c, Purchase_Order_Item__r.Currency__c, //Purchase_Request__r.Budget__r.Currency__c, 
                                                   Tech_POI_PO_Currency_Used_Budget_Amount__c                                                   
                                                   from Purchase_Request_Item__c
                                                   where Purchase_Order_Item__c in :pPOIIdSet
                                                ]) {
            temp.put(reader.Id, reader);
        }
        
        return temp;
    }
    */
    /*
    private static Map<String, Budget__c> getToBeUsedBudget(Set<String> pKeySet){
        Map<String, Budget__c> temp = new Map<String, Budget__c> ();
        
        for(Budget__c reader :[select id, Remaining_Amount__c, Budget__c, Expense_Amount__c, Withheld_Amount__c,
                               Department_Code__c, Function_Code__c, Section_Code__c, Site__c,
                               Tech_Cat_Policy_Function_Dep_Section__c
                               
                               from Budget__c 
                               where Effective_Start_Date__c < :system.today()
                               and Effective_end_Date__c > :system.today()
                               and Tech_Cat_Policy_Function_Dep_Section__c in :pKeySet
                               ORDER BY Section_Code__c DESC NULLS LAST
                              ]){
            temp.put(reader.Id, reader);
        }
        
        return temp;
    }
    
    private static Map<String, Budget__c> getWithheldBudget(Set<String> pBudgetIdSet){
    
        Map<String, Budget__c> temp = new Map<String, Budget__c> ();
        
        for(Budget__c reader :[select id, Remaining_Amount__c, Budget__c, Expense_Amount__c, Withheld_Amount__c,
                               Department_Code__c, Function_Code__c, Section_Code__c, Site__c,
                               Tech_Cat_Policy_Function_Dep_Section__c
                               
                               from Budget__c 
                               where Id in : pBudgetIdSet
                              ]){
            temp.put(reader.Id, reader);
        }
        
        return temp;
        
    }
    */
    private static Map<String, Exchange_rate__c> getExchangeRate(Set<String> fromCurrencyIdSet) {
        Map<String,Exchange_rate__c> temp = new Map<String, Exchange_rate__c > ();
        
        for(Exchange_rate__c reader : [select From_Currency__c, To_Currency__c, rate__c,Tech_From_To_Currency_ID__c
                                       from Exchange_rate__c 
                                       where Is_Latest__c = true
                                       and From_Currency__c in :fromCurrencyIdSet
                                       and is_book_rate__c = true
                                       and To_Currency__r.Is_IDP_Budget_Currency__c = true
                                      ]){
            temp.put(reader.From_Currency__c, reader);
        }
        
        return temp;
    
    }
    
    public static void updateReceiving(Map<Id, Purchase_Order_Item__c> newPurchaseOrderItemMap, Map<Id, Purchase_Order_Item__c> oldPurchaseOrderItemMap) { 
        Map<Id, Purchase_Order_Item__c> targetedNewPOIMap = new Map<Id, Purchase_Order_Item__c>();
        //Map<Id, Purchase_Order_Item__c> toBeUpdatedPOIMap = new Map<Id, Purchase_Order_Item__c>();
        List <Receiving_History__c> tobeInsertReceivingHistoryList = new List <Receiving_History__c> ();
        Set<Id> targetedPOIIdSet = new Set<Id> ();
        Double receivedQuantityChanges  = 0;
        Receiving_History__c tempReceivingHistory = null;        
    
        for(Id poiId : newPurchaseOrderItemMap.keySet() ) {
        
            if(newPurchaseOrderItemMap.get(poiId).status__c == oldPurchaseOrderItemMap.get(poiId).status__c ) {
        
                if(newPurchaseOrderItemMap.get(poiId).Received_Quantity__c != oldPurchaseOrderItemMap.get(poiId).Received_Quantity__c) {
                    receivedQuantityChanges  = 0;
                    receivedQuantityChanges = newPurchaseOrderItemMap.get(poiId).Received_Quantity__c - oldPurchaseOrderItemMap.get(poiId).Received_Quantity__c;
                    
                    tempReceivingHistory = new Receiving_History__c ();
                    tempReceivingHistory.Purchase_Order_item__c = poiId;
                    tempReceivingHistory.quantity__c = receivedQuantityChanges;
                    tobeInsertReceivingHistoryList.add(tempReceivingHistory);                    
                }   
            }
        }  
              
        if(!tobeInsertReceivingHistoryList.isEmpty()) {
            insert tobeInsertReceivingHistoryList;
        }        
    }
 
     public static void updatePRIStatusWhenUpdatePOI(Map<Id, Purchase_Order_Item__c> newPurchaseOrderItemMap, Map<Id, Purchase_Order_Item__c> oldPurchaseOrderItemMap) { 
        
        Set<id> needToChangeStatusIdSet = new Set<id>();
        Map<string,Purchase_Order_Item__c> idPurchaseOrderItemMap = new Map<string,Purchase_Order_Item__c>();
        
        for(String reader : newPurchaseOrderItemMap.keyset()) {
            if(newPurchaseOrderItemMap.get(reader).status__c != oldPurchaseOrderItemMap.get(reader).status__c){
               idPurchaseOrderItemMap.put(reader,newPurchaseOrderItemMap.get(reader));
               needToChangeStatusIdSet.add(reader);
            }
        }         
        
        List<Purchase_Request_Item__c> canUpdateStatusPRIList = [select id,status__c,Purchase_Order_Item__c from Purchase_Request_Item__c where Purchase_Order_Item__c in:needToChangeStatusIdSet];
        
        if(canUpdateStatusPRIList.size()>0){
            for(Purchase_Request_Item__c canUpdateStatusPRI:canUpdateStatusPRIList){
                canUpdateStatusPRI.status__c = idPurchaseOrderItemMap.get(canUpdateStatusPRI.Purchase_Order_Item__c).status__c;
            }
            update canUpdateStatusPRIList; 
        }
     }
 
    

    /* 
    public static void updatePOIPrice(Map<Id, Purchase_Order_Item__c> newPurchaseOrderItemMap, Map<Id, Purchase_Order__c> oldPurchaseOrderItemMap) {
        
        Set<String> fromToCurrencyIdSet = new Set<String> ();
        Map<String, Exchange_Rate__c> fromToCurrencyIdExchangeRateMap = new Map<String, Exchange_Rate__c> ();
        String fromToCurrencyId = null;
        String newCurrencyId = null;
        String oldCurrencyId = null;
        Decimal exchangerate = null;
        
        for(Id poiId : newPurchaseOrderItemMap.keySet()) {
            newCurrencyId = newPurchaseOrderItemMap.get(poiId).Currency__c;
            oldCurrencyId = oldPurchaseOrderItemMap.get(poiId).Currency__c;
            
            if(newCurrencyId != null && oldCurrencyId != null) {
                fromToCurrencyId = newCurrencyId + oldCurrencyId;
                
                if(newCurrencyId != oldCurrencyId) {
                    fromToCurrencyIdSet.add(fromToCurrencyId);
                }
            }
        }
        
        if(!fromToCurrencyIdSet.isEmpty()) {
            for(Exchange_Rate__c reader :[SELECT Tech_From_To_Currency_ID__c, Rate__c, From_Currency__c, To_Currency__c, To_Currency__r.Name 
                                                        FROM Exchange_Rate__c 
                                                        WHERE Is_Latest__c = true and Is_Book_Rate__c = true 
                                                        AND Tech_From_To_Currency_ID__c in :fromToCurrencyIdSet]) {
                
                fromToCurrencyIdExchangeRateMap.put(reader.Tech_From_To_Currency_ID__c, reader);                                           
            }
            
            if(!fromToCurrencyIdExchangeRateMap.isEmpty()) {
                for(Id poiId : newPurchaseOrderItemMap.keySet()) {
                    newCurrencyId = newPurchaseOrderItemMap.get(poiId).Currency__c;
                    oldCurrencyId = oldPurchaseOrderItemMap.get(poiId).Currency__c;
                    
                    
                    
                    if(newCurrencyId != null && oldCurrencyId != null) {
                        fromToCurrencyId = newCurrencyId + oldCurrencyId;
                        if(fromToCurrencyIdExchangeRateMap.containsKey(fromToCurrencyId)) {
                            exchangerate = fromToCurrencyIdExchangeRateMap.get(fromToCurrencyId).Rate__c;
                            newPurchaseOrderItemMap.get(poiId).Price__c = newPurchaseOrderItemMap.get(poiId).Price__c * exchangerate;
                        }
                    }    
                }
            }
        }                                           
    }
    
    */
}