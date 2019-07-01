public without sharing  class IDPPurchaseOrderTriggerHandler{

   
    public static void poManualSharing(Map<Id, Purchase_Order__c> newPurchaseOrderMap, Map<Id, Purchase_Order__c> oldPurchaseOrderMap) {
        
        Map<Id, Purchase_Order__c> purchaseOrderSharingMap = new Map<Id, Purchase_Order__c> ();
        Decimal poiNewCount = 0;
        Decimal poiOldCount = 0;
        for(Purchase_Order__c reader : newPurchaseOrderMap.values()) {
            if(reader.Status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_DRAFT) {
                poiNewCount = reader.PO_Item_Count__c;
                if(reader.Id != null) {
                    if(oldPurchaseOrderMap.containsKey(reader.Id)) {
                        poiOldCount = oldPurchaseOrderMap.get(reader.Id).PO_Item_Count__c;
                    }
                }
                
                if(poiNewCount != poiOldCount) {
                    purchaseOrderSharingMap.put(reader.Id, reader);
                }
            }
        }

        IDPManualSharingCtrl.IDPPurchaseOrderSharing(purchaseOrderSharingMap, true);
    }
    
    Public static void recalculateBudget(Map<Id, Purchase_Order__c> newPurchaseOrderMap, Map<Id, Purchase_Order__c> oldPurchaseOrderMap) {
        //Set<String> budgetSet = new Set<String>();
        Map<Id, Purchase_Order__c> poMap = new Map<Id, Purchase_Order__c>();
        //List<Purchase_Order__c> priList = new List< Purchase_Order__c>();
        Map<String, String> poBudgetMap = new Map<String, String>();
        Map<String, IDP_Budget__c> budgetMap = new Map<String, IDP_Budget__c>();
        Map<String, IDP_Budget__c> extIDbudgetMap = new Map<String, IDP_Budget__c>();
        Map<String, List<String>> POtargerBudgetMap = new Map<String, List<String>>();
        List<Purchase_Request_Item__c> priList = new List<Purchase_Request_Item__c>();
        String siteFunctionDepartmentSectionCatalogYear = '';
        String siteFunctionDepartmentCatalogYear = '';
        String siteFunctionDepartmentSectionYear = '';
        String siteFunctionDepartmentYear = '';
        String budgetId = '';
        String siteID = '';
        String catalogID = '';
        String function = '';
        String department = '';
        String section = '';
        String year = String.valueOf(System.Today().year());
        Set <String> targetBudgetKey = new Set <String>();
        IDP_Budget__c idpbudget = null;
        
        for(Purchase_Order__c reader : newPurchaseOrderMap.values()){
            if(reader.status__c != oldPurchaseOrderMap.get(reader.id).status__c && (reader.status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CLOSED || reader.status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CANCEL)){
               poMap.put(reader.id, reader);
              
            }   
        }
        if(!poMap.isEmpty()){
            for(Purchase_Order_Item__c poi : [select id, Purchase_Order__c,Budget_Actual_Paid_Amount__c,
                                              (select id, 
                                               Purchase_Request__r.IDP_Budget__c, Purchase_Request__r.Budget_Date__c,
                                               Purchase_Order_Item__r.Received_Quantity__c ,
                                               Purchase_Order_Item__r.Budget_Exchange_Rate__c,
                                               Purchase_Request__r.On_Behalf_of__r.employee__r.Function__c,
                                               Purchase_Request__r.On_Behalf_of__r.employee__r.Department__c,
                                               Purchase_Request__r.On_Behalf_of__r.employee__r.Section__c,
                                               Purchase_Request__r.On_Behalf_of__r.employee__r.Site__r.Site_ID_18__c,
                                               Purchase_Request__r.Catalog__r.Catalog_ID_18__c,Budget_Sub_Total__c
                                               from Purchase_Request_Items__r
                                              )
                                              from Purchase_Order_Item__c
                                              where Purchase_Order__c in :poMap.keySet()
                                             ]){
                priList.add(poi.Purchase_Request_Items__r);
                for(Purchase_Request_Item__c pri : poi.Purchase_Request_Items__r){
                    poBudgetMap.put(poi.Purchase_Order__c, pri.Purchase_Request__r.IDP_Budget__c);
                    siteID = pri.Purchase_Request__r.On_Behalf_of__r.employee__r.Site__r.Site_ID_18__c;
                    catalogID = pri.Purchase_Request__r.Catalog__r.Catalog_ID_18__c;
                    function = pri.Purchase_Request__r.On_Behalf_of__r.employee__r.Function__c;
                    department = pri.Purchase_Request__r.On_Behalf_of__r.employee__r.Department__c;
                    section = pri.Purchase_Request__r.On_Behalf_of__r.employee__r.Section__c;
                    siteFunctionDepartmentSectionCatalogYear = siteID +'_'+ function +'_'+ department +'_'+ section +'_'+ catalogID +'_'+ year;
                    siteFunctionDepartmentCatalogYear = siteID +'_'+ function +'_'+ department +'_'+ catalogID +'_'+ year;
                    siteFunctionDepartmentSectionYear = siteID +'_'+ function +'_'+ department +'_'+ section +'_'+ year;
                    siteFunctionDepartmentYear = siteID +'_'+ function +'_'+ department +'_'+ year;
                    POtargerBudgetMap.put(poi.Purchase_Order__c, new List<String>{siteFunctionDepartmentSectionCatalogYear, siteFunctionDepartmentCatalogYear, siteFunctionDepartmentSectionYear, siteFunctionDepartmentYear});
                    targetBudgetKey.add(siteFunctionDepartmentSectionCatalogYear);
                    targetBudgetKey.add(siteFunctionDepartmentCatalogYear);
                    targetBudgetKey.add(siteFunctionDepartmentSectionYear);
                    targetBudgetKey.add(siteFunctionDepartmentYear); 
                }
            }
            if(!poBudgetMap.isEmpty()){
                 for(IDP_Budget__c reader :[select id,  
                                           Department_Code__c, Function_Code__c, Section_Code__c, 
                                           Site__c, year__c,
                                           Jan_Reserve_Budget__c, Feb_Reserve_Budget__c, Mar_Reserve_Budget__c,
                                           Apr_Reserve_Budget__c, May_Reserve_Budget__c, Jun_Reserve_Budget__c,
                                           Jul_Reserve_Budget__c, Aug_Reserve_Budget__c, Sept_Reserve_Budget__c,
                                           Oct_Reserve_Budget__c, Nov_Reserve_Budget__c, Dec_Reserve_Budget__c,
                                           Jan_used_Budget__c, Feb_used_Budget__c, Mar_used_Budget__c,
                                           Apr_used_Budget__c, May_used_Budget__c, Jun_used_Budget__c,
                                           Jul_used_Budget__c, Aug_used_Budget__c, Sept_used_Budget__c,
                                           Oct_used_Budget__c, Nov_used_Budget__c, Dec_used_Budget__c,Ext_ID__c
                                           from IDP_Budget__c 
                                           where Id in :poBudgetMap.values()
                                           or (
                                               year__c = :String.valueof(System.Today().year())
                                               and Ext_ID__c  in :targetBudgetKey
                                           )
                                          ]){
                    budgetMap.put(reader.Id, reader);
                    extIDbudgetMap.put(reader.Ext_ID__c, reader);
                }
            }
            
            idpbudget = null;
            for(Purchase_Order__c reader : newPurchaseOrderMap.values()){
                budgetId = poBudgetMap.get(reader.id);
                if(budgetMap.containsKey(budgetId)){
                    if(budgetMap.get(budgetId).year__c == String.valueof(System.Today().year())){
                        idpbudget = budgetMap.get(budgetId);
                    }
                    else{
                        if(POtargerBudgetMap.containskey(reader.id)){
                            for(String targetReader : POtargerBudgetMap.get(reader.id)){                                
                                 if(budgetMap.containsKey(targetReader)
                                    && budgetMap.get(targetReader).year__c == String.valueof(System.Today().year())
                                    && idpbudget == null){
                                   idpbudget = budgetMap.get(targetReader);
                                }    
                            }
                        }
                    }
                    if(IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CLOSED == reader.status__c && idpbudget != null){
                        if(System.Today().month() == 1){                        
                            idpbudget.Jan_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 2){                        
                            idpbudget.Feb_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 3){                        
                            idpbudget.Mar_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 4){                        
                            idpbudget.Apr_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 5){                        
                            idpbudget.May_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 6){                        
                            idpbudget.Jun_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 7){                        
                            idpbudget.Jul_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 8){   
                            idpbudget.Aug_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 9){                        
                            idpbudget.Sept_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 10){                        
                            idpbudget.Oct_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 11){                        
                            idpbudget.Nov_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                        if(System.Today().month() == 12){                        
                            idpbudget.Dec_Used_Budget__c += reader.Budget_Exchange_Rate__c * (reader.Total_Actual_Paid_Amount__c + reader.Total_Addition_Cost__c);
                        }
                    }
                }
            }
            
            for(Purchase_Request_Item__c pri : priList){
                
                if (budgetMap.containsKey(pri.Purchase_Request__r.IDP_Budget__c)){                
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
            if(!budgetMap.isEmpty()){
                update budgetMap.values();
            }
        }
    }
    
    /*
    
     Public static void initFieldValue(Map<Id, Purchase_Order__c> newPurchaseOrderMap, Map<Id, Purchase_Order__c> oldPurchaseOrderMap) {
        Map<Id, Purchase_Order__c> POMap = new Map<Id, Purchase_Order__c>();
        List<Purchase_Order_item__c> poi = new List<Purchase_Order_item__c>();
        for(Purchase_Order__c reader : newPurchaseOrderMap.values()) {
            if(reader.M3_PO_NO__c  != oldPurchaseOrderMap.get(reader.id).M3_PO_NO__c){
                POMap.put(reader.id, reader);
            }
        }
        if(!POMap.isempty()){
            for(Purchase_Order_item__c reader : [select id, M3_PO_NO__c, Purchase_Order__c 
                                                 from Purchase_Order_item__c 
                                                 where Purchase_Order__c in :POMap.keyset()]){
                   reader.M3_PO_NO__c = POMap.get(reader.Purchase_Order__c).M3_PO_NO__c;
                   poi.add(reader);
            }
        }
        if(!poi.isempty()){
            update poi;
        }        
    }
    */
    
    /*
    moved to recalculateBudget on each POI, i.e. IDPPurchaseOrderItemTriggerHandler
    Public static void recalculateBudget(Map<Id, Purchase_Order__c> newPurchaseOrderMap, Map<Id, Purchase_Order__c> oldPurchaseOrderMap) {
        
        Map<Id, Purchase_Order__c> targetPOMap = new Map<Id, Purchase_Order__c> ();
        //Map<Id,Purchase_Order_Item__c> relatedPOIMap = new Map<Id, Purchase_Order_Item__c> ();
        Map<Id,Purchase_Request_Item__c> relatedPRIMap = new Map<Id, Purchase_Request_Item__c> ();
        Map<String, Budget__c> techKeyBudgetMap = new Map<String, Budget__c> ();
        Map<String, Exchange_Rate__c> fromToCurrIdERMap = new Map<String, Exchange_Rate__c> ();
        Set<String> techKeySet = new Set<String> (); //Budget's Tech_Policy_Function_Department_Section__c
        Set<String> fromToCurrencyIdSet = new Set<String> ();
        String techKey = '';
        String catalog = '';
        String site = '';
        String function = '';
        String department = '';
        String section = '';
        String fromCurrencyId = '';
        String toCurrencyId = '';
        String fromToCurrencyId = '';
        Double recoveredAmount = 0;
        Double actualDeductedAmount = 0;
        //get targetPOMap
        for(Id poId: newPurchaseOrderMap.keySet() ) {
        
            if(newPurchaseOrderMap.get(poId).Status__c != oldPurchaseOrderMap.get(poId).Status__c) { 
            
                if(newPurchaseOrderMap.get(poId).Status__c == IDPConstant.PURCHASE_ORDER_STATUS_CLOSED) {
                    targetPOMap.put(poId, newPurchaseOrderMap.get(poId));
                }
            }
        }
        
        
        //get relatedPRIMap
        for(Purchase_Request_item__c reader : [select id, Purchase_Request__r.Catalog__c, Purchase_Request__r.On_Behalf_of__r.employee__r.Site__r.Name, 
                                                    Purchase_Request__r.On_Behalf_of__r.employee__r.Function__c, Purchase_Request__r.On_Behalf_of__r.employee__r.Department__c,
                                                    Purchase_Request__r.On_Behalf_of__r.employee__r.Section__c, Budget_Amount__c,
                                                    Purchase_Order_Item__r.Received_Quantity__c, Purchase_Order_Item__r.Price__c,
                                                    Purchase_Order_Item__r.Currency__c
                                                FROM Purchase_Request_Item__c 
                                                WHERE Purchase_Order_Item__r.Purchase_Order__c in : targetPOMap.keySet()] ) {
                                            //WHERE Purchase_Order_Item__r.Purchase_Order__c in : relatedPOIMap.keySet()] ) {
            
            catalog = reader.Purchase_Request__r.Catalog__c;
            site = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Site__r.Name;
            function = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Function__c;
            department = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Department__c;
            section = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Section__c;
            
            //Budget's Tech_Policy_Function_Department_Section__c
            techKey = '';
            techKey += catalog.subString(0,15) + '_';
            techKey += site + '_';
            techKey += function + '_';
            techKey += department;
            
            if(!String.isBlank(section)) {
                techKey += '_' + section; 
            }  
            
            system.debug(section);
            system.debug(techKey);                         
            relatedPRIMap.put(reader.Id, reader);
            techKeySet.add(techKey);
        }
        
        system.debug(techKeySet);
        //get the techKeyBudgetMap 
        techKeyBudgetMap = getBudgets(techKeySet);
        
        
        //per related budget, Expense Amount =   Expense Amount + budgetIdPRIBudgetAmount - budgetIdPOIBudgetAmount
        for(Purchase_Request_Item__c reader : relatedPRIMap.values()) {
        
            catalog = reader.Purchase_Request__r.Catalog__c;
            site = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Site__r.Name;
            function = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Function__c;
            department = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Department__c;
            section = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Section__c;
            
            techKey = '';
            techKey += catalog.subString(0,15) + '_';
            techKey += site + '_';
            techKey += function + '_';
            techKey += department;
            if(!String.isBlank(section)) {
                techKey += '_' + section; 
            }
            

            fromCurrencyId = '';
            toCurrencyId = '';                                        
            if(techKeyBudgetMap.containsKey(techKey)) {
                fromCurrencyId = String.valueOf(reader.Purchase_Order_Item__r.Currency__c).subString(0,15);
                toCurrencyId =  + String.valueOf(techKeyBudgetMap.get(techKey).Currency__c).subString(0,15);
                fromToCurrencyId = fromCurrencyId + toCurrencyId;
                fromToCurrencyIdSet.add(fromToCurrencyId);
            }
        
        }
        
        fromToCurrIdERMap = getfromToCurrIdERMap(fromToCurrencyIdSet);
        
        for(Purchase_Request_Item__c reader : relatedPRIMap.values()) {
        
            catalog = reader.Purchase_Request__r.Catalog__c;
            site = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Site__r.Name;
            function = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Function__c;
            department = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Department__c;
            section = reader.Purchase_Request__r.On_Behalf_of__r.employee__r.Section__c;
            
            techKey = '';
            techKey += catalog.subString(0,15) + '_';
            techKey += site + '_';
            techKey += function + '_';
            techKey += department;
            if(!String.isBlank(section)) {
                techKey += '_' + section; 
            }
            
            recoveredAmount = 0;
            actualDeductedAmount = 0;
                                        
            if(techKeyBudgetMap.containsKey(techKey)) {
                fromCurrencyId = String.valueOf(reader.Purchase_Order_Item__r.Currency__c).subString(0,15);
                toCurrencyId =  + String.valueOf(techKeyBudgetMap.get(techKey).Currency__c).subString(0,15);
                fromToCurrencyId = fromCurrencyId + toCurrencyId;
                
                if(fromToCurrIdERMap.containsKey(fromToCurrencyId)) {
                    //recoveredAmount = 0;//reader.Budget_Amount__c;
                    actualDeductedAmount = reader.Purchase_Order_Item__r.Price__c *  fromToCurrIdERMap.get(fromToCurrencyId).Rate__c * reader.Purchase_Order_Item__r.Received_Quantity__c;            
                    techKeyBudgetMap.get(techKey).Expense_Amount__c = techKeyBudgetMap.get(techKey).Expense_Amount__c + actualDeductedAmount;            
                
                }

            }
        
        }        
        system.debug(fromToCurrIdERMap);
        system.debug(techKeyBudgetMap);
        
        update techKeyBudgetMap.values();
    }
    
    //String catId, String site, String function, String department, String section
    private static Map<String, Budget__c> getBudgets(Set<String> pTechKeyList){
        
        Map<String, Budget__c> tempBudgetMap = new Map<String, Budget__c> ();
        
        for(Budget__c reader : [SELECT Id, Currency__c, Expense_Amount__c, Tech_Catalog_Policy_Function_Dep_Section__c
                                FROM Budget__c
                                WHERE Effective_Start_Date__c < :system.today()
                                AND Effective_end_Date__c > :system.today()
                                AND Tech_Catalog_Policy_Function_Dep_Section__c in : pTechKeyList]) {
                                
            tempBudgetMap.put(reader.Tech_Catalog_Policy_Function_Dep_Section__c , reader);                        
        
        }
        return tempBudgetMap;
    }
    
    private static Map<String, Exchange_Rate__c> getfromToCurrIdERMap(Set<String> pfromToCurrencyIdSet) {
        
        Map<String, Exchange_Rate__c> tempERMap = new Map<String, Exchange_Rate__c>();
        
        for(Exchange_rate__c reader : [select From_Currency__c, To_Currency__c, Rate__c, Tech_From_To_Currency_ID__c
                                       from Exchange_rate__c 
                                       where Is_Latest__c = true
                                       and Tech_From_To_Currency_ID__c in :pfromToCurrencyIdSet
                                       and type__c = :TEConstant.EXCHANGE_RATE_TYPE_BUDGET_RATE
                                       and To_Currency__r.Is_Budget_Currency__c = true
                                      ]){ 
                                      
          tempERMap.put(reader.Tech_From_To_Currency_ID__c, reader);
        }
               
        return tempERMap;
    }
    */
}