public without sharing class IDPPurchaseRequestItemTriggerHandler {
    
    Public static void updateExchangeRate(List <Purchase_Request_item__c> newpriList, Map<id,Purchase_Request_item__c> newPRItemMap, Map<id,Purchase_Request_item__c> oldPRItemMap,  String type){
        List <Purchase_Request_item__c> priList = new List <Purchase_Request_item__c>();
        if(type == 'I'){
            exchangeRateCalculation(newpriList);
        }
        if(type == 'U'){
            for(String prId : newPRItemMap.KeySet()){
                if(newPRItemMap.get(prid).currency__c != oldPRItemMap.get(prid).currency__c){
                    priList.add(newPRItemMap.get(prid));
                }
            }
            if(!priList.isEmpty()){
                exchangeRateCalculation(priList);
            }
        }
    }
    
    Public static void exchangeRateCalculation(List<Purchase_Request_item__c> newPRItem){
        Map <String, Exchange_Rate__c > localCurrencyEx = new Map <String, Exchange_Rate__c >();
        Map <String, Exchange_Rate__c > stdCurrencyEx = new Map <String, Exchange_Rate__c >();
        Map <String, Exchange_Rate__c > budgetCurrencyEx = new Map <String, Exchange_Rate__c >();
        Map <String, String> prLocalCurrencyIdMap = new Map<String, String>();
        List<String> currencyList = new List<String>();
        Set <String> PRIds = new Set<String>();        
        for(Purchase_Request_item__c pr : newPRItem){
            currencyList.add(pr.currency__c);
            PRIds.add(pr.Purchase_Request__c);
        }
        for(Purchase_Request__c pr: [SELECT Id, On_Behalf_of__r.Employee__r.Expense_Policy__r.Local_Currency__c 
                                        FROM Purchase_Request__c
                                        WHERE Id in : PRIds]) {
            //currencyList.add(pr.On_Behalf_of__r.Employee__r.Expense_Policy__r.Local_Currency__c);
            prLocalCurrencyIdMap.put(pr.Id, pr.On_Behalf_of__r.Employee__r.Expense_Policy__r.Local_Currency__c); 
        }
        for(Exchange_Rate__c er : [select id, rate__c, Is_Book_Rate__c, Is_Budget_Rate__c,
                                   To_Currency__r.Is_Standard_Currency__c, To_Currency__r.Is_IDP_Budget_Currency__c,
                                   from_currency__c, To_Currency__c
                                   from Exchange_Rate__c
                                   where from_currency__c in :currencyList
                                   and is_latest__c = true
                                   and Is_Book_Rate__c = true 
                                   and  (To_Currency__r.Is_Standard_Currency__c = true or 
                                        To_Currency__c in :prLocalCurrencyIdMap.values() or 
                                        To_Currency__r.Is_IDP_Budget_Currency__c = true)
                                  ]){
            if(er.To_Currency__r.Is_Standard_Currency__c){
                stdcurrencyEx.put(er.from_currency__c, er);
            }
            if(er.To_Currency__r.Is_IDP_Budget_Currency__c){
                budgetCurrencyEx.put(er.from_currency__c, er);
            }
            if(prLocalCurrencyIdMap.values().contains(er.To_currency__c)){
                localCurrencyEx.put(er.from_currency__c, er);
            }
        }
        for(Purchase_Request_item__c pr : newPRItem){
            if(stdCurrencyEx.containsKey(pr.currency__c)){
                if(stdCurrencyEx.get(pr.currency__c).To_Currency__r.Is_Standard_Currency__c 
                   && stdCurrencyEx.get(pr.currency__c).Is_Book_Rate__c){
                    pr.Standard_Currency__c = stdCurrencyEx.get(pr.currency__c).To_Currency__c;
                    pr.Standard_Exchange_Rate__c = stdCurrencyEx.get(pr.currency__c).id;
                    pr.Used_Standard_Exchange_Rate__c = stdCurrencyEx.get(pr.currency__c).Rate__c;
                }
                if(localCurrencyEx.containsKey(pr.currency__c) && localCurrencyEx.get(pr.currency__c).To_Currency__c == prLocalCurrencyIdMap.get(pr.Purchase_Request__c)){
                    pr.Local_Currency__c = localCurrencyEx.get(pr.currency__c).To_Currency__c;
                    pr.Local_Exchange_Rate__c = localCurrencyEx.get(pr.currency__c).id;
                    pr.Used_Local_Exchange_Rate__c= localCurrencyEx.get(pr.currency__c).Rate__c;
                }
                if(budgetCurrencyEx.get(pr.currency__c).To_Currency__r.Is_IDP_Budget_Currency__c
                   && budgetCurrencyEx.get(pr.currency__c).Is_Book_Rate__c){
                    pr.Budget_Exchange_Rate__c = budgetCurrencyEx.get(pr.currency__c).rate__c;
                    pr.Tech_Budget_Exchange_Rate__c = budgetCurrencyEx.get(pr.currency__c).id;
                }
            }
        }       
    }
    
    Public static void pendingPRBudget(List<Purchase_Request_item__c> newPRItems){
        Set<Id> PRIds = new Set<Id>();
        for(Purchase_Request_item__c reader : newPRItems){
            PRIds.add(reader.Purchase_Request__c );
        }
        updatePRBudget(PRIds);
    }
    
     private static void updatePRBudget(Set<Id> PRIds){
        Map <String, Purchase_Request__c> targetedPRMap = new Map <String, Purchase_Request__c> ();
        Map <String, IDP_Budget__c> budgetMap = new Map<String, IDP_Budget__c>();
        List <Purchase_Request__c> updatePRs = new List<Purchase_Request__c>();
        Set <String> targetBudgetKey = new Set <String>();
        String siteID = '';
        String catalogID = '';
        String function = '';
        String department = '';
        String section = '';
        String year = String.valueOf(System.Today().year());
        String siteFunctionDepartmentSectionCatalogYear = '';
        String siteFunctionDepartmentCatalogYear = '';
        String siteFunctionDepartmentSectionYear = '';
        String siteFunctionDepartmentYear = '';
        String budgetKey = '';
        
        targetedPRMap = getTargetedPR(PRIds);
        for(Purchase_Request__c reader : targetedPRMap.values()){
            siteID = reader.On_Behalf_of__r.employee__r.Site__r.Site_ID_18__c;
            catalogID = reader.Catalog__r.Catalog_ID_18__c;
            function = reader.On_Behalf_of__r.employee__r.Function__c;
            department = reader.On_Behalf_of__r.employee__r.Department__c;
            section = reader.On_Behalf_of__r.employee__r.Section__c;
            siteFunctionDepartmentSectionCatalogYear = siteID +'_'+ function +'_'+ department +'_'+ section +'_'+ catalogID +'_'+ year;
            siteFunctionDepartmentCatalogYear = siteID +'_'+ function +'_'+ department +'_'+ catalogID +'_'+ year;
            siteFunctionDepartmentSectionYear = siteID +'_'+ function +'_'+ department +'_'+ section +'_'+ year;
            siteFunctionDepartmentYear = siteID +'_'+ function +'_'+ department +'_'+ year;
            targetBudgetKey.add(siteFunctionDepartmentSectionCatalogYear);
            targetBudgetKey.add(siteFunctionDepartmentCatalogYear);
            targetBudgetKey.add(siteFunctionDepartmentSectionYear);
            targetBudgetKey.add(siteFunctionDepartmentYear); 
        }
        System.debug(targetBudgetKey);
        budgetMap = getBudget(targetBudgetKey);
        System.debug(budgetMap);
        for(Purchase_Request__c reader : targetedPRMap.values()){
            siteID = reader.On_Behalf_of__r.employee__r.Site__r.Site_ID_18__c;
            catalogID = reader.Catalog__r.Catalog_ID_18__c;
            function = reader.On_Behalf_of__r.employee__r.Function__c;
            department = reader.On_Behalf_of__r.employee__r.Department__c;
            section = reader.On_Behalf_of__r.employee__r.Section__c;
            siteFunctionDepartmentSectionCatalogYear = siteID +'_'+ function +'_'+ department +'_'+ section +'_'+ catalogID +'_'+ year;
            siteFunctionDepartmentCatalogYear = siteID +'_'+ function +'_'+ department +'_'+ catalogID +'_'+ year;
            siteFunctionDepartmentSectionYear = siteID +'_'+ function +'_'+ department +'_'+ section +'_'+ year;
            siteFunctionDepartmentYear = siteID +'_'+ function +'_'+ department +'_'+ year;
            reader.IDP_Budget__c = null;
            budgetKey = '';
            if(budgetMap.containsKey(siteFunctionDepartmentSectionCatalogYear)){
                budgetKey = siteFunctionDepartmentSectionCatalogYear;
            }else
            if(budgetMap.containsKey(siteFunctionDepartmentCatalogYear)){
                budgetKey = siteFunctionDepartmentCatalogYear;
            }else
            if(budgetMap.containsKey(siteFunctionDepartmentSectionYear)){
                budgetKey = siteFunctionDepartmentSectionYear;
            }else
            if(budgetMap.containsKey(siteFunctionDepartmentYear)){
                budgetKey = siteFunctionDepartmentYear;
            }
            System.debug(budgetKey);
            if(!String.isBlank(budgetKey)){ 
                updatePRs.add(new Purchase_Request__c(id = reader.id, IDP_Budget__c = budgetMap.get(budgetKey).id, Budget_Date__c = System.Today()));
            }
       }
       if(!updatePRs.isEmpty()){
           update updatePRs;
       }
    }
    
    private static Map<String, IDP_Budget__c> getBudget(Set<String> pKeySet){
        Map<String, IDP_Budget__c> temp = new Map<String, IDP_Budget__c> ();        
        for(IDP_Budget__c reader :[select id, Department_Code__c, Function_Code__c, Section_Code__c, Site__c, 
                                   Jan_Reserve_Budget__c, Feb_Reserve_Budget__c, Mar_Reserve_Budget__c,
                                   Apr_Reserve_Budget__c, May_Reserve_Budget__c, Jun_Reserve_Budget__c,
                                   Jul_Reserve_Budget__c, Aug_Reserve_Budget__c, Sept_Reserve_Budget__c,
                                   Oct_Reserve_Budget__c, Nov_Reserve_Budget__c, Dec_Reserve_Budget__c,
                                   Jan_Pending_PR_Budget__c, Feb_Pending_PR_Budget__c, Mar_Pending_PR_Budget__c,
                                   Apr_Pending_PR_Budget__c, May_Pending_PR_Budget__c, Jun_Pending_PR_Budget__c,
                                   Jul_Pending_PR_Budget__c, Aug_Pending_PR_Budget__c, Sept_Pending_PR_Budget__c,
                                   Oct_Pending_PR_Budget__c, Nov_Pending_PR_Budget__c, Dec_Pending_PR_Budget__c,
                                   Ext_ID__c
                                   from IDP_Budget__c 
                                   where Ext_ID__c in :pKeySet
                                   ORDER BY Section_Code__c DESC NULLS LAST 
                                  ]){
            temp.put(reader.Ext_ID__c, reader);
        }
        return temp;
    }
    
    private static Map<String, Purchase_Request__c> getTargetedPR(Set<Id> pPRIdSet) {
        Map<String, Purchase_Request__c> temp = new Map<String, Purchase_Request__c> ();        
        for(Purchase_Request__c reader :[select id, Catalog__c, Catalog__r.Catalog_ID_18__c, IDP_Budget__c,
                                           On_Behalf_of__r.employee__r.Site__r.Name, 
                                           On_Behalf_of__r.employee__r.Function__c, On_Behalf_of__r.employee__r.Department__c,
                                           On_Behalf_of__r.employee__r.Section__c, Catalog_Name__c, 
                                           On_Behalf_of__r.employee__r.Site__r.Site_ID_18__c,
                                           On_Behalf_Of__r.employee__r.Tech_Policy_Function_Department_Section__c,
                                           On_Behalf_Of__r.employee__r.Tech_Policy_Function_Department__c,
                                           On_Behalf_Of__r.employee__r.Tech_IDP_Policy_Function_Department__c,
                                           On_Behalf_Of__r.employee__r.Tech_IDP_Function_Department_Section__c,
                                           On_Behalf_Of__r.employee__r.User__r.Function__c,
                                           On_Behalf_Of__r.employee__r.User__r.Department__c,
                                           On_Behalf_Of__r.employee__r.User__r.Section__c,
                                           (Select Id, Budget_Sub_Total__c  from Purchase_Request_Items__r)
                                           from Purchase_Request__c
                                           where Id in : pPRIdSet]) {                                           
            temp.put(reader.Id, reader);                                  
        }        
        return temp;
    }
    
    Public static void updateReceiving(Map<Id, Purchase_Request_item__c> newPurchaseRequestMap, Map<Id, Purchase_Request_item__c> oldPurchaseRequestMap) {       
        Map<Id, Purchase_Request_Item__c> targetedNewPRIMap = new Map<Id, Purchase_Request_Item__c>();
        Map<Id, Purchase_Order_Item__c> toBeUpdatedPOIMap = new Map<Id, Purchase_Order_Item__c>();
        List <Receiving_History__c> tobeInsertReceivingHistoryList = new List <Receiving_History__c> ();
        Set<Id> targetedPOIIdSet = new Set<Id> ();
        Double receivedQuantityChanges  = 0;
        Receiving_History__c tempReceivingHistory = null;        
        for(Id priId : newPurchaseRequestMap.keySet() ) {
            if(newPurchaseRequestMap.get(priId).Purchase_Order_item__c != null) {
                if(oldPurchaseRequestMap.get(priId).Received_Qty__c != newPurchaseRequestMap.get(priId).Received_Qty__c) {
                    targetedNewPRIMap.put(priId, newPurchaseRequestMap.get(priId));
                    targetedPOIIdSet.add(newPurchaseRequestMap.get(priId).Purchase_Order_item__c);
                }
            }
        }
        if(!targetedPOIIdSet.isEmpty()) {
            for(Purchase_Order_Item__c poi : [SELECT Id, Received_Quantity__c FROM Purchase_Order_Item__c WHERE Id in :targetedPOIIdSet]) {
                toBeUpdatedPOIMap.put(poi.Id, poi);
            }
            for(Purchase_Request_Item__c reader : targetedNewPRIMap.values()) {
                receivedQuantityChanges  = 0;
                               
                if(toBeUpdatedPOIMap.containsKey(reader.Purchase_Order_Item__c)) {
                    receivedQuantityChanges = reader.Received_Qty__c - oldPurchaseRequestMap.get(reader.Id).Received_Qty__c;   
                    toBeUpdatedPOIMap.get(reader.Purchase_Order_Item__c).Received_Quantity__c += receivedQuantityChanges;                    
                    tempReceivingHistory = new Receiving_History__c ();
                    tempReceivingHistory.Purchase_Order_item__c = reader.Purchase_Order_item__c;
                    tempReceivingHistory.quantity__c = receivedQuantityChanges;
                    tobeInsertReceivingHistoryList.add(tempReceivingHistory);
                }               
            }            
            if(!toBeUpdatedPOIMap.isEmpty() && !tobeInsertReceivingHistoryList.isEmpty()) {
                update toBeUpdatedPOIMap.values();
                insert tobeInsertReceivingHistoryList;
            }
        }
    }
    /*
    Public static void clearSubTotal(Map<Id, Purchase_Request_item__c> newPurchaseRequestMap, Map<Id, Purchase_Request_item__c> oldPurchaseRequestMap) {       
        Map<Id, Purchase_Request_item__c> toBeUpdatedPRIMap = new Map<Id, Purchase_Request_item__c>();
        Set<Id> targetedPRIIdSet = new Set<Id> ();        
        for(Id priId : newPurchaseRequestMap.keySet() ) {
            if(oldPurchaseRequestMap.get(priId).Status__c != newPurchaseRequestMap.get(priId).Status__c) {
                if(newPurchaseRequestMap.get(priId).Status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_NOT_SUBMITTED) {
                    targetedPRIIdSet.add(priId);
                }   
            }
        }        
        if(!targetedPRIIdSet.isEmpty()) {
            for (Purchase_Request_Item__c pri : [SELECT Id, Budget_Exchange_Rate__c, Used_Local_Exchange_Rate__c, Used_Standard_Exchange_Rate__c,
                                                        Standard_Exchange_Rate__c, Standard_Currency__c,
                                                        Local_Exchange_Rate__c, Local_Currency__c
                                                 FROM Purchase_Request_Item__c 
                                                 WHERE Id in :targetedPRIIdSet]) {
                                                    
                pri.Budget_Exchange_Rate__c         = null;
                pri.Used_Local_Exchange_Rate__c     = null;
                pri.Used_Standard_Exchange_Rate__c  = null;
                pri.Standard_Exchange_Rate__c       = null;
                pri.Standard_Currency__c            = null;
                pri.Local_Exchange_Rate__c          = null;
                pri.Local_Currency__c               = null;                
                toBeUpdatedPRIMap.put(pri.Id, pri);
            }
        }
        if (!toBeUpdatedPRIMap.isEmpty())
            update toBeUpdatedPRIMap.values();
    }
    */
    /*
    Public static void resumeBudget(Map<Id, Purchase_Request_item__c> newPurchaseRequestMap, Map<Id, Purchase_Request_item__c> oldPurchaseRequestMap) {       
        Map<Id, IDP_Budget__c> toBeUpdatedBudgetMap = new Map<Id, IDP_Budget__c>();
        Map<Id, Purchase_Request__c> prMap = new Map<Id, Purchase_Request__c>();
        List<Purchase_Request_item__c> priList = new List<Purchase_Request_item__c>();
        Set<Id> targetedBudgetSet = new Set<Id> ();
        Set<Id> targetedPRset = new Set<Id> ();
        
        for(Id priId : newPurchaseRequestMap.keySet() ) {
            if(oldPurchaseRequestMap.get(priId).Status__c != newPurchaseRequestMap.get(priId).Status__c) {
                if(newPurchaseRequestMap.get(priId).Status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_CANCELLED) {
                    priList.add(newPurchaseRequestMap.get(priId));
                    targetedPRset.add(newPurchaseRequestMap.get(priId).Purchase_Request__c);
                }   
            }
        }
        if (!targetedPRset.isEmpty()) {
            for (Purchase_Request__c pr : [select id, IDP_Budget__c, Budget_Date__c
                                           from Purchase_Request__c
                                           where id in :targetedPRset]) {                
                prMap.put(pr.Id, pr);                           
                targetedBudgetSet.add(pr.IDP_Budget__c);                            
            }
            toBeUpdatedBudgetMap = getBudgetMap(targetedBudgetSet);            
        }
        for (Purchase_Request_item__c pri : priList) {
                Purchase_Request__c pr = prMap.get(pri.Purchase_Request__c);
                IDP_Budget__c budget = toBeUpdatedBudgetMap.get(pr.IDP_Budget__c);
                Date BudgetDate = pr.Budget_Date__c;
                if(BudgetDate != null){             
                    if(BudgetDate.Month() == 1){
                        budget.Jan_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 2){
                        budget.Feb_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 3){
                        budget.Mar_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 4){
                        budget.Apr_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 5){
                        budget.May_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 6){
                        budget.Jun_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 7){
                        budget.Jul_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 8){
                        budget.Aug_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 9){
                        budget.Sept_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 10){
                        budget.Oct_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 11){
                        budget.Nov_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                    if(BudgetDate.Month() == 12){
                        budget.Dec_Reserve_Budget__c -= pri.Budget_Sub_Total__c;
                    }
                }
        }
        
        if (!toBeUpdatedBudgetMap.isEmpty()){
            update toBeUpdatedBudgetMap.values();
        }
    }
    public static Map<Id, IDP_Budget__c> getBudgetMap(Set<Id> budgetIds) {
        Map<Id, IDP_Budget__c> budgetMap = new Map<Id, IDP_Budget__c>();
        
        for (IDP_Budget__c budget : [Select Id, 
                                     Jan_Reserve_Budget__c, Feb_Reserve_Budget__c, Mar_Reserve_Budget__c,
                                     Apr_Reserve_Budget__c, May_Reserve_Budget__c, Jun_Reserve_Budget__c,
                                     Jul_Reserve_Budget__c, Aug_Reserve_Budget__c, Sept_Reserve_Budget__c,
                                     Oct_Reserve_Budget__c, Nov_Reserve_Budget__c, Dec_Reserve_Budget__c, ext_ID__c
                                     From IDP_Budget__c
                                     Where Id in :budgetIds]) {
        
            budgetMap.put(budget.Id, budget);                           
        }
        
        return budgetMap;
    }
    */
    public static void setFullfillment(Map<Id, Purchase_Request_item__c> newPurchaseRequestMap,Map<Id, Purchase_Request_item__c> oldPurchaseRequestMap){
        Set<ID> idset=new Set<ID>();
        list<Purchase_Request__c> prlis=new list<Purchase_Request__c>();
        Map<id,Boolean> prmap=new Map<id,Boolean>();
        Boolean d;
        for(Purchase_Request_item__c item:newPurchaseRequestMap.values()){   
           if(item.Purchase_Request__c!=null){
              if(prmap.containskey(item.Purchase_Request__c)){
                  if(item.Is_Direct_fulfillment__c==false){
                      prmap.put(item.Purchase_Request__c,false);
                  }
              }
              else{
                  prmap.put(item.Purchase_Request__c,item.Is_Direct_fulfillment__c);
              }
           }   
           d=oldPurchaseRequestMap.get(item.Id).Is_Direct_fulfillment__c;
           if(d!=item.Is_Direct_fulfillment__c){
               idset.add(item.Purchase_Request__c);
           }
        }        
        for(Purchase_Request__c pr:[select id,Is_Direct_Fullfillment__c from Purchase_Request__c where id in :idset ]){
            if(prmap.containskey(pr.Id)){
                pr.Is_Direct_Fullfillment__c=prmap.get(pr.Id);
                prlis.add(pr);
            }
        }
        update prlis;
    }
}
    /*
    Public static void resumeBudget(Map<Id, Purchase_Request_item__c> newPurchaseRequestMap, Map<Id, Purchase_Request_item__c> oldPurchaseRequestMap) {       
        Map<Id, Budget__c> toBeUpdatedBudgetMap = new Map<Id, Budget__c>();
        Map<Id, Purchase_Request__c> prMap = new Map<Id, Purchase_Request__c>();
        List<Purchase_Request_item__c> priList = new List<Purchase_Request_item__c>();
        Set<Id> targetedBudgetSet = new Set<Id> ();
        Set<Id> targetedPRset = new Set<Id> ();
        
        for(Id priId : newPurchaseRequestMap.keySet() ) {
            if(oldPurchaseRequestMap.get(priId).Status__c != newPurchaseRequestMap.get(priId).Status__c) {
                if(newPurchaseRequestMap.get(priId).Status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_CANCELLED) {
                    priList.add(newPurchaseRequestMap.get(priId));
                    targetedPRset.add(newPurchaseRequestMap.get(priId).Purchase_Request__c);
                }   
            }
        }
        
        if (!targetedPRset.isEmpty()) {
            for (Purchase_Request__c pr : [select id, Budget__c
                                           from Purchase_Request__c
                                           where id in :targetedPRset]) {
                
                prMap.put(pr.Id, pr);                           
                targetedBudgetSet.add(pr.Budget__c);                            
            }

            
            toBeUpdatedBudgetMap = getBudgetMap(targetedBudgetSet);
            
            for (Purchase_Request_item__c pri : priList) {
                Purchase_Request__c pr = prMap.get(pri.Purchase_Request__c);
                Budget__c budget = toBeUpdatedBudgetMap.get(pr.Budget__c);
                budget.Withheld_Amount__c -= pri.Budget_Sub_Total__c;
            }
            
            if (!toBeUpdatedBudgetMap.isEmpty())
                update toBeUpdatedBudgetMap.values();

        }       
    }
    //*/