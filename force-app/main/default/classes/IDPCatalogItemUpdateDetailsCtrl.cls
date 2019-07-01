public without sharing class IDPCatalogItemUpdateDetailsCtrl{

   //Copy the best price in Supplier_Item__c record to Catalog_Item__c record
   @future
    public static void processUpdate(List <id> catalogItemList){
        List<Supplier_Item__c> siList = new List<Supplier_Item__c>();
        List<Catalog_Item__c> updateCatalogItemList = new List<Catalog_Item__c>();
        Map<String, Exchange_Rate__c> FromToCurrencyIdExchangeRateMap = new Map<String, Exchange_Rate__c >();
        Map<Id, Supplier_Item__c> allSupplierItemMap = new Map<Id, Supplier_Item__c>();
        Map<Id, Supplier_Item__c> catalogItemIdBestPriceSupplierItemMap = new Map<Id, Supplier_Item__c>();
        Set<String> catalogItemFromToCurrencyIdSet = new Set<String> ();
        String FromToCurrencyId = '';
        
        //query all the Supplier_Item__c records where Is_Best_Price__c = true
        Currency__c standardCurrency = [SELECT Id, Is_Standard_Currency__c FROM Currency__c WHERE Is_Standard_Currency__c = true LIMIT 1 ];
        if(standardCurrency != null) {
            if(catalogItemList != null){
                for(Supplier_Item__c siReader : [SELECT Id, Catalog_Item__c, 
                                                        Catalog_Item__r.Currency__c, Catalog_Item__r.Reference_Price__c, 
                                                        Currency__c, Price__c, 
                                                        Std_Currency__c , Std_Price__c,
                                                        Supplier__c, Minimum_Order_Quantity__c,
                                                        Expiry_Date__c,
                                                        Lead_Time_Days__c, Lead_Time_Format__c
                                                FROM Supplier_Item__c
                                                where Catalog_Item__c in :catalogItemList
                                                ]){
                    siList.add(siReader);
                }
            }            
            for(Supplier_Item__c siReader : siList) {
                if(siReader.Currency__c != null) {
                    siReader.Std_Currency__c = standardCurrency.Id;
                    FromToCurrencyId = string.valueOf(siReader.Currency__c).substring(0,15) + string.valueOf(siReader.Std_Currency__c).substring(0,15);
                    catalogItemFromToCurrencyIdSet.add(FromToCurrencyId);
                    allSupplierItemMap.put(siReader.Id, siReader);
                }
            }
            for(Exchange_Rate__c erReader : [SELECT Id, Tech_From_To_Currency_ID__c, Rate__c
                                                        FROM Exchange_Rate__c 
                                                        WHERE Is_Latest__c = true and Is_Book_Rate__c = true 
                                                        AND Tech_From_To_Currency_ID__c in :catalogItemFromToCurrencyIdSet] ) {
                FromToCurrencyIdExchangeRateMap.put(erReader.Tech_From_To_Currency_ID__c, erReader);                                                                                                     
            }
            
            for(Supplier_Item__c siReader : allSupplierItemMap.values()) {
                if(siReader.Currency__c != null) {
                    FromToCurrencyId = string.valueOf(siReader.Currency__c).substring(0,15) + string.valueOf(siReader.Std_Currency__c).substring(0,15);
                    if(FromToCurrencyIdExchangeRateMap.containsKey(FromToCurrencyId)) {
                        siReader.Std_Price__c =  siReader.Price__c *FromToCurrencyIdExchangeRateMap.get(FromToCurrencyId).Rate__c;
                    }
                    else {
                        siReader.Std_Currency__c = null;
                        siReader.Std_Price__c = 0;
                    }
                }
            }            
            update allSupplierItemMap.values();
            for(Supplier_Item__c siReader : [SELECT Id, Catalog_Item__c, 
                                                    Catalog_Item__r.Currency__c, Catalog_Item__r.Reference_Price__c, 
                                                    Currency__c, Price__c, 
                                                    Std_Currency__c , Std_Price__c,
                                                    Supplier__c, Minimum_Order_Quantity__c,
                                                    Expiry_Date__c, 
                                                    Lead_Time_Days__c, Lead_Time_Format__c
                                            FROM Supplier_Item__c
                                            WHERE Is_Best_Price__c = true
                                            and Catalog_Item__c in :catalogItemList
                                            //id in :allSupplierItemMap.keyset()
                                            ORDER BY Catalog_Item__c ASC, Price_Last_Modified_Date__c desc]) {
                catalogItemIdBestPriceSupplierItemMap.put(siReader.Catalog_Item__c, siReader);
                system.debug('===========================' + siReader.Catalog_Item__c +' '+ siReader );
                system.debug(catalogItemIdBestPriceSupplierItemMap);
            }
            //update update all the related Catalog_Item__c 's Reference_Price__c field according the Supplier_Item__c record's Price__c
            for(Catalog_Item__c ciReader: [SELECT Id, Reference_Price__c, Currency__c FROM Catalog_Item__c WHERE Id in :catalogItemIdBestPriceSupplierItemMap.keySet()]) {
                ciReader.Currency__c = catalogItemIdBestPriceSupplierItemMap.get(ciReader.Id).Currency__c;
                ciReader.Reference_Price__c = catalogItemIdBestPriceSupplierItemMap.get(ciReader.Id).Price__c;
                ciReader.Last_Supplier__c = catalogItemIdBestPriceSupplierItemMap.get(ciReader.Id).Supplier__c;
                ciReader.Minimum_Order_Quantity__c = catalogItemIdBestPriceSupplierItemMap.get(ciReader.Id).Minimum_Order_Quantity__c;
                ciReader.Expiry_Date__c = catalogItemIdBestPriceSupplierItemMap.get(ciReader.Id).Expiry_Date__c;
                ciReader.Lead_Time_Format__c = catalogItemIdBestPriceSupplierItemMap.get(ciReader.Id).Lead_Time_Format__c;
                ciReader.Lead_Time_Days__c = catalogItemIdBestPriceSupplierItemMap.get(ciReader.Id).Lead_Time_Days__c;
                ciReader.Supplier_Source__c = catalogItemIdBestPriceSupplierItemMap.get(ciReader.Id).id;
                updateCatalogItemList.add(ciReader);
            }
            update updateCatalogItemList;
        }
    }

}