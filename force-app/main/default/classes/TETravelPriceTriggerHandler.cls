public class TETravelPriceTriggerHandler {
    
    /** 
     * Update Cost Center
     */
    Public static Void updateCostCenter(List<Travel_Price__c> newList){
        Map<Id, Travel_Application__c> travelApplicationMap = new Map<Id, Travel_Application__c>();
        Map<String, Cost_Center__c> costCenterMap = new Map<String, Cost_Center__c>();
        FinanceUtil fu = new FinanceUtil();
        for(Travel_Price__c reader : newList){
            travelApplicationMap.put(reader.travel_application__c, null);
        }
        for(Travel_application__c reader :[select id, on_behalf_of__r.employee__r.Tech_Policy_Function_Department__c,
                                           on_behalf_of__r.employee__r.Tech_Policy_Function_Department_Section__c
                                           from Travel_application__c  
                                           where id in :travelApplicationMap.keyset()]){
            travelApplicationMap.put(reader.id, reader);
            costCenterMap.put(reader.on_behalf_of__r.employee__r.Tech_Policy_Function_Department__c, null);
            costCenterMap.put(reader.on_behalf_of__r.employee__r.Tech_Policy_Function_Department_Section__c, null);
        }
        costCenterMap = fu.CostCenterMap(new List<String>(costCenterMap.keyset()));
        System.debug(costCenterMap );
        if (!costCenterMap.isempty()){
            for(Travel_Price__c reader : newList){
                if (costCenterMap.containskey(travelApplicationMap.get(reader.travel_application__c).on_behalf_of__r.employee__r.Tech_Policy_Function_Department__c)){
                    reader.Cost_Center__c = costCenterMap.get(travelApplicationMap.get(reader.travel_application__c).on_behalf_of__r.employee__r.Tech_Policy_Function_Department__c).id;
                } 
                if (costCenterMap.containskey(travelApplicationMap.get(reader.travel_application__c).on_behalf_of__r.employee__r.Tech_Policy_Function_Department_Section__c)){
                    reader.Cost_Center__c = costCenterMap.get(travelApplicationMap.get(reader.travel_application__c).on_behalf_of__r.employee__r.Tech_Policy_Function_Department_Section__c).id;
                } 
            }
        }
    }
    
    
    /** 
     * Update Budget when inserting/deleting travel prices
     */
    Public static Void updateBudget(List<Travel_Price__c> oldList, List<Travel_Price__c> newList){
        Map<Integer, Travel_Price__c> IdPriceMap = new Map<Integer, Travel_Price__c>();
        Map<Integer, Id> tpIdtaIdMap = new Map<Integer, Id>();
        Map<Integer, String> tpErrorMap = new Map<Integer, String>();
        Map<Id, Travel_Application__c> taIdMap = new Map<Id, Travel_Application__c>();
        Map<Integer, String> priceIdentifierMap = new Map<Integer, String>();
        Map<String, Budget__c> identifierBudgetMap = new Map<String, Budget__c>();
        Map<String, Double> identifierAmountMap = new Map<String, Double>();
        Map<Integer, String> tpCurrencyIds = new Map<Integer, String>();
        Map<Integer, Exchange_Rate__c> tpExchangeRateMap = new Map<Integer, Exchange_Rate__c>();
        Map<Id, Travel_Price__c> oldTravelPriceMap = new Map<Id, Travel_Price__c>();
        Map<Id, Id> tpBudgetIdMap = new Map<Id, Id>();
        //Map<String, Cost_Center__c> costCenterMap = new Map<String, Cost_Center__c>();
        List<Budget__c> budgetToUpdate = new List<Budget__c>();
        List<String> siteList = new List<String>();
        List<String> departmentList = new List<String>();
        List<String> yearList = new List<String>();
        //Cost_Center__c cc = null;
        //FinanceUtil fu = new FinanceUtil();
        Boolean isBudget = false;        
        Integer count = 0;
        
        
        if(newList != null){
            //just inserted or updated (unchecked the error flag)            
            if(oldList != null){
                for(Travel_Price__c reader : oldList){
                    oldTravelPriceMap.put(reader.id, reader);
                }
            }
            for (Travel_Price__c reader : newList){
                if(oldList == null || (reader.is_error__c != oldTravelPriceMap.get(reader.id).is_error__c)){
                    IdPriceMap.put(count, reader);
                    tpIdtaIdMap.put(count, reader.Travel_Application__c);
                    yearList.add(String.valueOf(reader.Invoice_Date__c.year()));
                    //costCenterMap.put(reader.Tech_Policy_Function_Department_Section__c, null);
                    count++;
                }
            }
            for(currency__c reader : [select id from currency__c where Is_Budget_Currency__c = true]){
                isBudget = true;
            }        
        }
        
        //costCenterMap.keyset()
        /*
        costCenterMap = fu.CostCenterMap(new List<String>(costCenterMap.keyset()));
        for(String reader : costCenterMap.keyset()){
            cc = costCenterMap.get(reader);
        }
        */
        if(!tpIdtaIdMap.isEmpty() && isBudget)
        {
            for (Travel_Application__c ta: [Select Id, On_Behalf_of__r.Employee__r.Site__r.Name, 
                                             On_Behalf_of__r.Employee__r.Department__c
                                      From Travel_Application__c Where Id =: tpIdtaIdMap.values()]){
                taIdMap.put(ta.Id, ta);
                siteList.add(ta.On_Behalf_of__r.Employee__r.Site__r.Name);
                departmentList.add(ta.On_Behalf_of__r.Employee__r.Department__c);
            }
            
            Travel_Application__c temp;
            for (Integer tpId : IdPriceMap.keySet()){
                temp = taIdMap.get(tpIdtaIdMap.get(tpId));
                if (temp != null){
                    priceIdentifierMap.put(tpId, temp.On_Behalf_of__r.Employee__r.Site__r.Name + 
                                                 temp.On_Behalf_of__r.Employee__r.Department__c +
                                                 String.valueOf(IdPriceMap.get(tpId).Invoice_Date__c.year()));
                }
            }
            
            if (!priceIdentifierMap.isEmpty()){
                for (Budget__c budget : [Select Id, Budget__c, Currency__c, Currency__r.Name, 
                                                Expense_Amount__c, Site__r.Name, Department__c, Year__c 
                                         From Budget__c
                                         Where Site__r.Name =: siteList AND Department__c =: departmentList
                                         AND Expense_Category__r.Is_Travel__c =: True AND Year__c =: yearList]){
                    identifierBudgetMap.put(budget.Site__r.Name + budget.Department__c + budget.Year__c, budget);
                }
            }

            for (Integer tpId : IdPriceMap.keySet()){
                if (identifierBudgetMap.containsKey(priceIdentifierMap.get(tpId))){
                    tpCurrencyIds.put(tpId, String.valueOf(IdPriceMap.get(tpId).Currency__c).substring(0, 15) 
                                            + String.valueOf(identifierBudgetMap.get(priceIdentifierMap.get(tpId)).Currency__c).substring(0, 15));
                }
                else{
                    // budget not found
                    tpErrorMap.put(tpId, Label.TE_Travel_Price_Budget_Not_Found);
                }
            }
            
            if (!tpCurrencyIds.isEmpty()){
                Date tempDate;
                for (Exchange_Rate__c er : [Select Id, Is_Budget_Rate__c, Tech_From_To_Currency__c, Tech_From_To_Currency_ID__c,
                                                   Rate__c, Date__c
                                            From Exchange_Rate__c 
                                            Where Tech_From_To_Currency_ID__c =: tpCurrencyIds.values()
                                            AND Is_Budget_Rate__c =: True
                                            ]){
                    for (Integer tpId : IdPriceMap.keySet()){
                        if (tpCurrencyIds.get(tpId) == er.Tech_From_To_Currency_ID__c){
                            if (!tpExchangeRateMap.containsKey(tpId)){
                                tpExchangeRateMap.put(tpId, er);
                            }
                            else{
                                tempDate = tpExchangeRateMap.get(tpId).Date__c;
                                if (math.abs(IdPriceMap.get(tpId).Invoice_Date__c.daysBetween(er.Date__c))
                                    < math.abs(IdPriceMap.get(tpId).Invoice_Date__c.daysBetween(tempDate))){
                                    tpExchangeRateMap.put(tpId, er);
                                }
                            }
                        }
                    }
                }
            }
            
            Double tempAmount;
            identifierAmountMap.clear();
            for (Integer tpId : IdPriceMap.keySet()){
                if (identifierBudgetMap.containsKey(priceIdentifierMap.get(tpId))){
                    IdPriceMap.get(tpId).Budget_Currency__c = identifierBudgetMap.get(priceIdentifierMap.get(tpId)).Currency__c;
                    IdPriceMap.get(tpId).Tech_Budget_ID__c = identifierBudgetMap.get(priceIdentifierMap.get(tpId)).Id;
                    if (tpExchangeRateMap.containsKey(tpId)){
                        
                        IdPriceMap.get(tpId).Exchange_Rate_to_Budget_Currency__c = tpExchangeRateMap.get(tpId).Rate__c;
                        IdPriceMap.get(tpId).Exchange_Rate_to_Budget_Date__c = tpExchangeRateMap.get(tpId).Date__c;
                        IdPriceMap.get(tpId).Budget_Amount__c = IdPriceMap.get(tpId).Amount__c * tpExchangeRateMap.get(tpId).Rate__c;
                        
                        if (identifierAmountMap.containsKey(priceIdentifierMap.get(tpId))){
                            tempAmount = identifierAmountMap.get(priceIdentifierMap.get(tpId));
                            tempAmount += IdPriceMap.get(tpId).Budget_Amount__c;
                            identifierAmountMap.put(priceIdentifierMap.get(tpId), tempAmount);
                        }
                        else{
                            identifierAmountMap.put(priceIdentifierMap.get(tpId), IdPriceMap.get(tpId).Budget_Amount__c);
                        }
                    }
                    else{
                        //exchange rate not found
                        tpErrorMap.put(tpId, Label.TE_Travel_Price_Exchange_Rate_Not_Found);
                    }
                }
            }
            
            for (Integer tpId : tpErrorMap.keySet()){
                IdPriceMap.get(tpId).Is_Error__c = True;
                IdPriceMap.get(tpId).Error_Message__c = tpErrorMap.get(tpId);
            }
            
            for (String id : identifierAmountMap.keySet()){
                identifierBudgetMap.get(id).Expense_Amount__c += identifierAmountMap.get(id);
                budgetToUpdate.add(identifierBudgetMap.get(id));
            }
            
            if (!budgetToUpdate.isEmpty()){
                upsert budgetToUpdate;
            }
            
        }
        
        if(oldList != null && newList == null){
            //just deleted
            
            Double tempAmount;
            identifierAmountMap.clear();
            budgetToUpdate.clear();
            for (Travel_Price__c reader : oldList){
                tpBudgetIdMap.put(reader.Id, reader.Tech_Budget_ID__c);
                
                if (identifierAmountMap.containsKey(reader.Tech_Budget_ID__c)){
                    tempAmount = identifierAmountMap.get(reader.Tech_Budget_ID__c);
                    tempAmount += reader.Budget_Amount__c;
                    identifierAmountMap.put(reader.Tech_Budget_ID__c, tempAmount);
                }
                else{
                    identifierAmountMap.put(reader.Tech_Budget_ID__c, reader.Budget_Amount__c);
                }
            }
            
            if (!tpBudgetIdMap.isEmpty()){
                for (Budget__c bg : [Select Id, Expense_Amount__c From Budget__c Where Id =: tpBudgetIdMap.values()]){
                    if (identifierAmountMap.containsKey(bg.Id)){
                        bg.Expense_Amount__c -= identifierAmountMap.get(bg.Id);
                        budgetToUpdate.add(bg);
                    }
                }
                
                if (!budgetToUpdate.isEmpty()){
                    upsert budgetToUpdate;
                }
            }
        }
    }
}