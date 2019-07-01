public without sharing  class IDPPurchaseRequestTriggerHandler{

    Public static Boolean isBlockApproval;
    
    Public static void updatePRBudget(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap){
        Map <String, Purchase_Request__c> targetedPRMap = new Map <String, Purchase_Request__c> ();
        Map<String, IDP_Budget__c> budgetMap = new Map<String, IDP_Budget__c>();
        Map <String, String> PRBudgetKeyMap= new Map<String, String>();
        Map <String, String> BudgetIdExtIdMap = new Map<String, String>();
        List <Id> BudgetIds = new List <Id>();
        String budgetExtId = '';
        Double prBudgetSubTotal = 0;
        Purchase_Request__c tempPR = null;
        targetedPRMap = getTargetedPR(newPurchaseRequestMap.keySet());
        
        for(Purchase_Request__c reader : newPurchaseRequestMap.values()){
            if(
               reader.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT ||
               reader.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION ||
               reader.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED
              ){
                  prBudgetSubTotal = 0;
                  for(Purchase_Request_Item__c priReader : targetedPRMap.get(reader.id).Purchase_Request_Items__r){
                      if(priReader.Budget_Sub_Total__c != null){
                          prBudgetSubTotal += priReader.Budget_Sub_Total__c;
                      }
                  }                
                reader.PR_Item_Budget_Sub_Total__c = prBudgetSubTotal;
            }            
            reader.Budget_Date__c = Date.Today();
            if(oldPurchaseRequestMap.get(reader.id).IDP_Budget__c != null && 
               oldPurchaseRequestMap.get(reader.id).Budget_Date__c != null && 
               oldPurchaseRequestMap.get(reader.id).Budget_Date__c.Year() != Date.Today().Year()){
                PRBudgetKeyMap.put(reader.id, '');
                budgetIds.add(oldPurchaseRequestMap.get(reader.id).IDP_Budget__c);
            }
        }
        if(!budgetIds.isEmpty()){
            budgetMap = getBudget(budgetIds);
            for(Purchase_Request__c pr : oldPurchaseRequestMap.values()){
                if(PRBudgetKeyMap.containsKey(pr.id)){
                    budgetExtId = budgetMap.get(pr.IDP_Budget__c).Ext_ID__c;
                    budgetExtId = budgetExtId.replace('_'+String.valueof(pr.Budget_Date__c.year()), '_'+String.valueof(Date.today().year()));
                    PRBudgetKeyMap.put(pr.id, budgetExtId);
                }
            }            
            for(IDP_Budget__c idpBudget :[select id, Ext_ID__c from IDP_Budget__c where Ext_ID__c = :PRBudgetKeyMap.values()]){
                BudgetIdExtIdMap.put(idpBudget.Ext_ID__c, idpBudget.id);
            }
            for(String prid : PRBudgetKeyMap.keySet()){
                tempPR = newPurchaseRequestMap.get(prid);
                if(BudgetIdExtIdMap.containsKey(PRBudgetKeyMap.get(prid))){
                    tempPR.IDP_Budget__c = BudgetIdExtIdMap.get(PRBudgetKeyMap.get(prid));
                }
                else{
                    tempPR.IDP_Budget__c = null;
                }            
            }
        }
    } 
    
    Public static void deductBudget(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap) {
        Map<Id, Purchase_Request__c> approvalPRMap = new Map<Id, Purchase_Request__c>();
        Map<Id, Purchase_Request__c> updateBudgetPRMap = new Map<Id, Purchase_Request__c>();
        Map<String, IDP_Budget__c> budgetMap = new Map<String, IDP_Budget__c>();
        
        for(Purchase_Request__c reader : newPurchaseRequestMap.values()){
            if((reader.status__c != oldPurchaseRequestMap.get(reader.id).status__c && reader.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED) 
              ){
                if(reader.IDP_Budget__c != null){
                    approvalPRMap.put(reader.Id, reader);
                }
            }
        
            if(reader.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT ||
               reader.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION ||
               reader.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED
              ){
                if(reader.IDP_Budget__c != null){
                    updateBudgetPRMap.put(reader.Id, reader);
                }
            }
        }
        if(!updateBudgetPRMap.isEmpty()){
            budgetMap = BudgetCalculation(updateBudgetPRMap, oldPurchaseRequestMap, 'PendingPR');
        }
        if(!approvalPRMap.isEmpty()){
            budgetMap = BudgetCalculation(approvalPRMap, oldPurchaseRequestMap, 'Reserve');
        }
        if(!budgetMap.isEmpty()){
            upsert budgetMap.values();
        }
    }
    
    private static Map<String, IDP_Budget__c> budgetCalculation(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap, String type){
        Map <String, IDP_Budget__c> budgetMap = new Map<String, IDP_Budget__c>();
        List <Id> BudgetIds = new List <Id>();
        Double PRBudgetSubTotal = 0;
        Date BudgetMonth = null;
        for(Purchase_Request__c pr : oldPurchaseRequestMap.values()){
           budgetIds.add(pr.IDP_Budget__c);           
        }
        for(Purchase_Request__c pr : newPurchaseRequestMap.values()){
           budgetIds.add(pr.IDP_Budget__c);           
        }
        if(!budgetIds.isEmpty()){
            budgetMap = getBudget(budgetIds);
        }
        for(Purchase_Request__c pr : oldPurchaseRequestMap.values()){
            PRBudgetSubTotal = pr.PR_Item_Budget_Sub_Total__c;
            BudgetMonth = pr.Budget_Date__c;
            if(PRBudgetSubTotal == null){
                PRBudgetSubTotal = 0;
            }
            if(pr.IDP_Budget__c != null && BudgetMonth != null){
                budgetMap = pendingPRBudgetCalculation(budgetMap, pr.IDP_Budget__c, -1*PRBudgetSubTotal, BudgetMonth);
            }
        }  
        for(Purchase_Request__c pr : newPurchaseRequestMap.values()){
            PRBudgetSubTotal = pr.PR_Item_Budget_Sub_Total__c;
            BudgetMonth = pr.Budget_Date__c;
            if(PRBudgetSubTotal == null){
                PRBudgetSubTotal = 0;
            }
            if(pr.IDP_Budget__c != null && BudgetMonth != null){
                if(type == 'PendingPR'){  
                    budgetMap = pendingPRBudgetCalculation(budgetMap, pr.IDP_Budget__c, PRBudgetSubTotal, BudgetMonth);
                }
                if(type == 'Reserve'){
                    budgetMap = reservePRBudgetCalculation(budgetMap, pr.IDP_Budget__c, PRBudgetSubTotal, BudgetMonth);
                }
            }
        }        
        return budgetMap;
    }
    
   private static Map<String, IDP_Budget__c> reservePRBudgetCalculation(Map <String, IDP_Budget__c> budgetMap, String IDPBudgetId, Double budgetTotal, Date BudgetMonth){
       if(BudgetMonth.month() == 1){
                budgetMap.get(IDPBudgetId).Jan_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 2){
                budgetMap.get(IDPBudgetId).Feb_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 3){
                budgetMap.get(IDPBudgetId).Mar_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 4){
                budgetMap.get(IDPBudgetId).Apr_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 5){
                budgetMap.get(IDPBudgetId).May_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 6){
                budgetMap.get(IDPBudgetId).Jun_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 7){
                budgetMap.get(IDPBudgetId).Jul_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 8){
                budgetMap.get(IDPBudgetId).Aug_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 9){
                budgetMap.get(IDPBudgetId).Sept_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 10){
                budgetMap.get(IDPBudgetId).Oct_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 11){
                budgetMap.get(IDPBudgetId).Nov_Reserve_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 12){
                budgetMap.get(IDPBudgetId).Dec_Reserve_Budget__c += budgetTotal;
       }
       return budgetMap;
   }
   
   private static Map<String, IDP_Budget__c> pendingPRBudgetCalculation(Map <String, IDP_Budget__c> budgetMap, String IDPBudgetId, Double budgetTotal, Date BudgetMonth){
       if(BudgetMonth.month() == 1){
                budgetMap.get(IDPBudgetId).Jan_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 2){
                budgetMap.get(IDPBudgetId).Feb_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 3){
                budgetMap.get(IDPBudgetId).Mar_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 4){
                budgetMap.get(IDPBudgetId).Apr_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 5){
                budgetMap.get(IDPBudgetId).May_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 6){
                budgetMap.get(IDPBudgetId).Jun_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 7){
                budgetMap.get(IDPBudgetId).Jul_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 8){
                budgetMap.get(IDPBudgetId).Aug_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 9){
                budgetMap.get(IDPBudgetId).Sept_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 10){
                budgetMap.get(IDPBudgetId).Oct_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 11){
                budgetMap.get(IDPBudgetId).Nov_Pending_PR_Budget__c += budgetTotal;
       }
       if(BudgetMonth.month() == 12){
                budgetMap.get(IDPBudgetId).Dec_Pending_PR_Budget__c += budgetTotal;
       }
       return budgetMap;
   }
   
    private static Map<String, Purchase_Request__c> getTargetedPR(Set<Id> pPRIdSet) {
        Map<String, Purchase_Request__c> temp = new Map<String, Purchase_Request__c> ();        
        for(Purchase_Request__c reader :[select id, Catalog__c, Catalog__r.Catalog_ID_18__c, IDP_Budget__c, Budget_Date__c,
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

    private static Map<String, IDP_Budget__c> getBudget(List<Id> budgetIds){
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
                                   where id in :budgetIds
                                   ORDER BY Section_Code__c DESC NULLS LAST 
                                  ]){
            temp.put(reader.id, reader);
        }
        
        return temp;
    }
    
    /*
   //public static void updateExchangeRate(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap) {
   public static void updateExchangeRate(List<Purchase_Request__c> newPurchaseRequests) {
        List <String> budgetPIDList = new List <String>();
        List <String> currencyList = new List <String>();
        List <Purchase_Request_Item__c> PRItemList = new List <Purchase_Request_Item__c>();
        Map <String, Exchange_rate__c> exchangeRateMap = new Map <String, Exchange_rate__c>();
        
        for(Purchase_Request__c reader : newPurchaseRequests){
            budgetPIDList.add(reader.id);
        }
        system.debug(logginglevel.ERROR, 'updateExchangeRate1(): '+Limits.getQueries());
        if(!budgetPIDList.isEmpty()){
            for(Purchase_Request_Item__c reader : [select id, currency__c, Is_Direct_fulfillment__c
                                                   from Purchase_Request_Item__c
                                                   where Purchase_Request__c in :budgetPIDList
                                                  ]){
                PRItemList.add(reader);
                currencyList.add(reader.currency__c);
            }
            system.debug(logginglevel.ERROR, 'updateExchangeRate2(): '+Limits.getQueries());
            for(Exchange_rate__c reader : [select Id, From_Currency__c, To_Currency__c, rate__c
                                           from Exchange_rate__c 
                                           where Is_Latest__c = true
                                           and From_Currency__c in :currencyList
                                           and type__c = :TEConstant.EXCHANGE_RATE_TYPE_BUDGET_RATE
                                           and To_Currency__r.Is_IDP_Budget_Currency__c = true
                                          ]){
                exchangeRateMap.put(reader.From_Currency__c, reader);
            }
            system.debug(logginglevel.ERROR, 'updateExchangeRate3(): '+Limits.getQueries());
            for(Purchase_Request_Item__c reader : PRItemList){
              reader.Budget_Exchange_Rate__c = exchangeRateMap.get(reader.currency__c).rate__c;
              reader.Tech_Budget_Exchange_Rate__c = exchangeRateMap.get(reader.currency__c).Id;
            }
            system.debug(logginglevel.ERROR, 'updateExchangeRate4(): '+Limits.getQueries());
            if(!PRItemList.isEmpty()){
                upsert PRItemList;
            }
            system.debug(logginglevel.ERROR, 'updateExchangeRate5(): '+Limits.getQueries());            
        }
        
   }
   */
   public static void initFieldValues(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap) {
       Map <Id, Purchase_Request__c> prIdPRDetailedInformationMap = new Map <Id, Purchase_Request__c >(); 
       Map<String, Catalog_Policy_Setting__c> CatalogIDPolicyCPSMap = new Map<String, Catalog_Policy_Setting__c>();
       Set<Id> purchaseRequestIdSet = new Set<Id> ();
       Set<String> catalogIdset = new Set<String>();
       Set<String> idpPolicyIdset = new Set<String>();
       String SEPARATOR = '_';
       for(String prId : newPurchaseRequestMap.keySet()){          
           if(newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT || 
                newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED) {
                newPurchaseRequestMap.get(prId).Actual_Approver_1__c = null;
                newPurchaseRequestMap.get(prId).Actual_Approver_2__c = null;
                newPurchaseRequestMap.get(prId).Actual_Approver_3__c = null;
                newPurchaseRequestMap.get(prId).Actual_Approver_4__c = null;
                newPurchaseRequestMap.get(prId).Tech_ROI_Approver__c = null;
                newPurchaseRequestMap.get(prId).Tech_C_Level_Approver__c = null;
                //newPurchaseRequestMap.get(prId).IDP_Policy__c = null;
                //newPurchaseRequestMap.get(prId).Tech_IDP_Policy_Name__c = null;
                newPurchaseRequestMap.get(prId).Catalog_Policy_Setting__c = null;
                newPurchaseRequestMap.get(prId).Tech_Catalog_Owner_Queue_Name__c= null;
                newPurchaseRequestMap.get(prId).Tech_Applicant_Email__c = null;
                newPurchaseRequestMap.get(prId).Tech_On_Behalf_Of_Email__c = null;                    
           }
           
           if(newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_SUBMITTED ) {                   
               if(oldPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT || 
                   oldPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED) {                       
                   purchaseRequestIdSet.add(prId);                       
               }
           }
       }
       
       if(!purchaseRequestIdSet.isEmpty()) {
           for(Purchase_Request__c pr: [SELECT Id, 
                                                On_Behalf_Of__r.Employee__r.Approver_1__c, On_Behalf_Of__r.Employee__r.Approver_2__c,
                                                On_Behalf_Of__r.Employee__r.Approver_3__c, On_Behalf_Of__r.Employee__r.Approver_4__c,
                                                Catalog__r.ROI_Approver__c, Catalog__r.C_Level_Approver__c,
                                                Catalog__c, Catalog__r.Tech_Catalog_Owner_Queue_Name__c, 
                                                On_Behalf_Of__r.Employee__r.IDP_Policy__c, On_Behalf_Of__r.Employee__r.IDP_Policy__r.Name,
                                                On_Behalf_Of__r.Employee_Administrator__r.User__r.Email,
                                                On_Behalf_Of__r.Employee__r.User__r.Email,
                                                On_Behalf_Of__r.employee__r.User__r.Function__c,
                                                On_Behalf_Of__r.employee__r.User__r.Department__c,
                                                On_Behalf_Of__r.employee__r.User__r.Section__c
                                          FROM Purchase_Request__c 
                                          WHERE Id in : purchaseRequestIdSet] ) {
               prIdPRDetailedInformationMap.put(pr.Id, pr);
               catalogIdset.add(pr.Catalog__c);
               idpPolicyIdset.add(pr.On_Behalf_Of__r.Employee__r.IDP_Policy__c);
           }
       
           for(Catalog_Policy_Setting__c cps: [SELECT Id, Catalog__c, IDP_Policy__c
                                          FROM Catalog_Policy_Setting__c
                                          WHERE Catalog__c in :catalogIdset
                                          AND IDP_Policy__c in :idpPolicyIdset] ) {
               CatalogIDPolicyCPSMap.put(cps.Catalog__c + SEPARATOR + cps.IDP_Policy__c, cps);                               
           }
                  
           for(String prId : newPurchaseRequestMap.keySet()){
               if(newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_SUBMITTED ) {
                   
                   if(oldPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT || 
                       oldPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED) {
                            System.debug(catalogIdset);
                            System.debug(idpPolicyIdset);
                            System.debug(CatalogIDPolicyCPSMap);
                            String tempCPSKey = prIdPRDetailedInformationMap.get(prId).Catalog__c  + SEPARATOR + prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.Employee__r.IDP_Policy__c;                
                            newPurchaseRequestMap.get(prId).Actual_Approver_1__c = prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.Employee__r.Approver_1__c;
                            newPurchaseRequestMap.get(prId).Actual_Approver_2__c = prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.Employee__r.Approver_2__c;
                            newPurchaseRequestMap.get(prId).Actual_Approver_3__c = prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.Employee__r.Approver_3__c;
                            newPurchaseRequestMap.get(prId).Actual_Approver_4__c = prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.Employee__r.Approver_4__c;
                            newPurchaseRequestMap.get(prId).Tech_ROI_Approver__c = prIdPRDetailedInformationMap.get(prId).Catalog__r.ROI_Approver__c;
                            newPurchaseRequestMap.get(prId).Tech_C_Level_Approver__c = prIdPRDetailedInformationMap.get(prId).Catalog__r.C_Level_Approver__c;
                            newPurchaseRequestMap.get(prId).IDP_Policy__c = prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.Employee__r.IDP_Policy__c;
                            newPurchaseRequestMap.get(prId).Tech_IDP_Policy_Name__c = prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.Employee__r.IDP_Policy__r.Name;
                            newPurchaseRequestMap.get(prId).Catalog_Policy_Setting__c = CatalogIDPolicyCPSMap.get(tempCPSKey).Id;
                            newPurchaseRequestMap.get(prId).Tech_Catalog_Owner_Queue_Name__c = prIdPRDetailedInformationMap.get(prId).Catalog__r.Tech_Catalog_Owner_Queue_Name__c;
                            newPurchaseRequestMap.get(prId).Tech_Applicant_Email__c = prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.Employee_Administrator__r.User__r.Email ;
                            newPurchaseRequestMap.get(prId).Tech_On_Behalf_Of_Email__c = prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.Employee__r.User__r.Email;
                            newPurchaseRequestMap.get(prId).Department_info__c  = prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.employee__r.User__r.Function__c + ' / ';
                            newPurchaseRequestMap.get(prId).Department_info__c +=  prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.employee__r.User__r.Department__c + ' / ';
                            newPurchaseRequestMap.get(prId).Department_info__c +=  prIdPRDetailedInformationMap.get(prId).On_Behalf_Of__r.employee__r.User__r.Section__c;                           
                    }
                }
           }
       }
   }
   
    public static void updateCurrentApprover(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap) {
       for(String prId : newPurchaseRequestMap.keySet()){
           newPurchaseRequestMap.get(prId).Current_Approver__c = newPurchaseRequestMap.get(prId).Tech_Current_Approver__c;
       }
       
    }

    public static Boolean validatePurchaseRequestLineItem(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap) {
        
        Map<String, Purchase_Request__c> needsValudatiionPRMap = new Map<String, Purchase_Request__c>();
        Map<Id, SObject> pripcMap = new Map<Id, SObject> ();
        Map<String, Map<String, Boolean>> pripcIdFieldNameIsBlankMessageMap = new Map<String, Map<String, Boolean>>();
        Boolean isBlockApproval = false;
        
        Schema.sObjectType priObjectType = Schema.Purchase_Request_Item__c.getSObjectType();
        Schema.sObjectType pcObjectType= Schema.Purchase_Cost__c.getSObjectType();
        
        for(Id prId : newPurchaseRequestMap.keySet()) {
            if(newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL && 
                oldPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION ) { 
                needsValudatiionPRMap.put(prId, newPurchaseRequestMap.get(prId));
            }
        }
        if(!needsValudatiionPRMap.isEmpty()) {
          for(Purchase_Request_Item__c pri : [SELECT Id, Currency__c, Price__c, Quantity__c, Supplier__c, Purchase_Request__c, Is_Direct_fulfillment__c,
                                                  (SELECT ID, Type__c, Currency__c, Price__c, Supplier__c, Purchase_Request_Item__r.Purchase_Request__c
                                                      From Purchase_Costs__r)
                                              FROM Purchase_Request_Item__c
                                              WHERE Purchase_Request__c = : needsValudatiionPRMap.keySet()]) {
                                              
              pripcMap.put(pri.Id, pri);
              for(Purchase_Cost__c pc : pri.Purchase_Costs__r) {
                  pripcMap.put(pc.Id, pc);
              }
              
              pripcIdFieldNameIsBlankMessageMap = IDPPurchaseRequestValidationsController.validatePurchaseRequestItemInput(pripcMap);
          }
          
          for(String pripcId : pripcIdFieldNameIsBlankMessageMap.keySet() ){
              isBlockApproval = false;
              Map<String, Boolean> FieldNameIsBlankMessageMap = pripcIdFieldNameIsBlankMessageMap.get(pripcId);
              
              for(Boolean IsBlankreader : FieldNameIsBlankMessageMap.values() ) {
                  if(IsBlankreader) {
                      isBlockApproval = true;
                      break;
                  }
              }
              if(isBlockApproval) {
                  String prId = null;
                  if(pripcMap.get(pripcId).getSObjectType() == priObjectType) {
                      prId  = ((Purchase_Request_Item__c) pripcMap.get(pripcId)).Purchase_Request__c;
                  }
                  else if(pripcMap.get(pripcId).getSObjectType() == pcObjectType) {
                      prId  = ((Purchase_Cost__c) pripcMap.get(pripcId)).Purchase_Request_Item__r.Purchase_Request__c;
                  }
                  newPurchaseRequestMap.get(prId).addError(Label.IDP_Purchase_Request_Fill_in_Fields_Marked_In_Red_Message);
                  break;
              }
          }
        }
        return isBlockApproval;
    }
    
    public static void prManualSharing(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap) {
        
        Map<Id, Purchase_Request__c> purchaseRequestSharingMap = new Map<Id, Purchase_Request__c> ();
        Set<Id> purchaseRequestSharingIdSet = new Set<Id> ();
        for(Id prId : newPurchaseRequestMap.keySet()) {
            
            if(newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL) { 
                if(oldPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION) {        
                    purchaseRequestSharingIdSet.add(prId);
                }
            }
                   
            if(newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION ) { 
                if(oldPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_SUBMITTED) {                    
                    purchaseRequestSharingIdSet.add(prId);
                }
            }       
            
            if(newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED) { 
                purchaseRequestSharingIdSet.add(prId);
            }

            if(newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED) {
                purchaseRequestSharingIdSet.add(prId);
            }
        }
        
        for(Purchase_Request__c reader: [SELECT Id, OwnerId,
                                                Actual_Approver_1__c , Actual_Approver_2__c,
                                                Actual_Approver_3__c, Actual_Approver_4__c,            
                                                Catalog__c, Catalog__r.OwnerId, Assign_to_Local_Purchaser__c,
                                                Tech_C_Level_Approver__c, Tech_ROI_Approver__c,
                                                IDP_Policy__r.Name, IDP_Policy__r.Is_Group_Procurement__c,
                                                On_Behalf_of__r.Employee__r.User__c, Status__c,
                                                Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c,
                                                Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c  
                                        FROM Purchase_Request__c 
                                        where Id in :purchaseRequestSharingIdSet]) {
         purchaseRequestSharingMap.put(reader.Id, reader);
        }
                                        
        if(!purchaseRequestSharingMap.isEmpty()){
            IDPManualSharingCtrl.IDPPurchaseRequestSharing(purchaseRequestSharingMap, true);
        }
    }
    
    public static void updatePurchaseRequestItemStatus(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap) {

        Set<String> targetPurchaseRequestIdSet = new Set<String> ();
        Map<Id, Purchase_Request_Item__c> targetPurchaseRequestItemMap = new Map<Id, Purchase_Request_Item__c> ();
        
        
        for(Id prId : newPurchaseRequestMap.keySet()) {
            if(newPurchaseRequestMap.get(prId).Status__c != oldPurchaseRequestMap.get(prId).Status__c) {
                if(newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT ||
                   newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED ||
                   newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION ||
                   newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL ||
                   newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED ||
                   newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED ||
                   newPurchaseRequestMap.get(prId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_CANCELLED ) {
                   
                       targetPurchaseRequestIdSet.add(prId);
                }
            }
        }
        
        
        for(Purchase_Request_Item__c reader : [SELECT Id, Status__c, Purchase_Request__c  FROM Purchase_Request_Item__c WHERE Purchase_Request__c in :targetPurchaseRequestIdSet]) {
            
            reader.Status__c = newPurchaseRequestMap.get(reader.Purchase_Request__c).Status__c;
            targetPurchaseRequestItemMap.put(reader.Id, reader);
        }
        
        update targetPurchaseRequestItemMap.values();
    }
   
   public static void updatePRCostCenter(Map<Id, Purchase_Request__c> newPurchaseRequestMap, Map<Id, Purchase_Request__c> oldPurchaseRequestMap) {
       Map<String, Purchase_Request__c> tobeupdatePRMap = new Map<String, Purchase_Request__c>();
       Set<Id> PRIds = new Set<Id>();
       Map<String, Purchase_Request__c> PRMap = new Map<String, Purchase_Request__c>();
       Map <String, Cost_Center__c> costCenterMap = new Map <String, Cost_Center__c>();
       //FinanceUtil fu = new FinanceUtil();
       Set <String> costCeterKey = new Set <String>();
       
       for(Purchase_Request__c reader : newPurchaseRequestMap.values()){
           if(reader.status__c != oldPurchaseRequestMap.get(reader.id).status__c && reader.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED){
               tobeupdatePRMap.put(reader.id, reader);
               PRIds.add(reader.id);
           }
       }
       PRMap = getTargetedPR(PRIds);
       for(Purchase_Request__c reader : PRMap.values()){
           costCeterKey.add(reader.On_Behalf_Of__r.employee__r.Tech_IDP_Policy_Function_Department__c);
           costCeterKey.add(reader.On_Behalf_Of__r.employee__r.Tech_IDP_Function_Department_Section__c);
       }
       
       for(cost_center__c reader : [select id, Name, Tech_IDP_Function_Department_Section__c, GL_Account__c
                                     from cost_center__c 
                                     where Tech_IDP_Function_Department_Section__c in :costCeterKey
                                    ]){
            CostCenterMap.put(reader.Tech_IDP_Function_Department_Section__c , reader);
            
            
            
        }
       
       //costCenterMap = fu.CostCenterMap(new List<String>(costCeterKey));
       for(Purchase_Request__c reader : newPurchaseRequestMap.values()){
           if(PRMap.containskey(reader.id)){
               if(costCenterMap.containskey(PRMap.get(reader.id).On_Behalf_Of__r.employee__r.Tech_IDP_Function_Department_Section__c)){
                   reader.cost_center__c = costCenterMap.get(PRMap.get(reader.id).On_Behalf_Of__r.employee__r.Tech_IDP_Function_Department_Section__c).Name;
                   reader.GL_Account__c= costCenterMap.get(PRMap.get(reader.id).On_Behalf_Of__r.employee__r.Tech_IDP_Function_Department_Section__c).GL_Account__c;
                   
               } else
               if(costCenterMap.containsKey(PRMap.get(reader.id).On_Behalf_Of__r.employee__r.Tech_IDP_Policy_Function_Department__c)){
                   reader.cost_center__c = costCenterMap.get(PRMap.get(reader.id).On_Behalf_Of__r.employee__r.Tech_IDP_Policy_Function_Department__c).Name;                   
                   reader.cost_center__c = costCenterMap.get(PRMap.get(reader.id).On_Behalf_Of__r.employee__r.Tech_IDP_Policy_Function_Department__c).Name;
               }
           }
       }
   }
      
}