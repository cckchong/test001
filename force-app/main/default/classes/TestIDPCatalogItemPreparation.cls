@istest
Public class TestIDPCatalogItemPreparation {
    
    //format: [key, value]
    //[Catalog Item Name, Records]
    //Available key: 
    //[Administration_Motor Vehicles_Item_1, Administration_Motor Vehicles_Item_2, Administration_Motor Vehicles_Item_4, Administration_Motor Vehicles_Item_4]
    //[Machinery_Shirts - Cutting_Item_1, Machinery_Shirts - Cutting_Item_2, Machinery_Shirts - Cutting_Item_3, Machinery_Shirts - Cutting_Item_4]
    //[Machinery_Shirts - Cutting_Item_1, Machinery_Shirts - Cutting_Item_2, Machinery_Shirts - Cutting_Item_3, Machinery_Shirts - Cutting_Item_4]
    //[TAA Local Catalog_General_Item_1,TAA Local Catalog_General_Item_2, TAA Local Catalog_General_Item_3, TAA Local Catalog_General_Item_4]
    Public Map<String, Catalog_Item__c> catalogItemMap {get;set;}
    Public Map<String, Supplier_Item__c> supplierItemMap {get;set;}
    private Map<String, Currency__c> currencyMap;
    Private Map<String, Catalog__c> catalogAllMap;
    Private Map<String, Supplier__c> supplierMap;
    Public boolean isSeeAllData;

    Public TestIDPCatalogItemPreparation (boolean isSeeAllData, Map<String, Currency__c> CurrencyMap, Map<String, Catalog__c> catalogAllMap, Map<String, Supplier__c> supplierMap) {
        this.isSeeAllData = isSeeAllData;
        initVariable(CurrencyMap, catalogAllMap, supplierMap);

    }
        
    Public void initVariable(Map<String, Currency__c> currencyMap, Map<String, Catalog__c> catalogAllMap, Map<String, supplier__c> supplierMap) {
        this.catalogItemMap = new Map<String, Catalog_Item__c> ();
        this.supplierItemMap = new Map<String, Supplier_Item__c> ();
        this.currencyMap = currencyMap;
        this.catalogAllMap = catalogAllMap;
        this.supplierMap = supplierMap;
    }
    
    Public void basicSetting() {
        prepareCatalogItemTestData();
        prepareSupplierItemTestData(true);
    }
    
    
    Public void prepareCatalogItemTestData() {
        List<Catalog_Item__c> toBeInsertedCatalog = new List<Catalog_Item__c>();
        Catalog_item__c tempCatalogItem = null;
        
        /*
        for(Catalog__c reader : [SELECT Id, Catalog_Name__c, Parent_Catalog__r.Catalog_Name__c
                                FROM Catalog__c
                                WHERE Parent_Catalog__c != null]) {
        */
        
        for(Catalog__c reader : this.catalogAllMap.values()) {
        
            if(reader.Parent_Catalog__c != null) { 
                for(Integer i = 1; i < 4; i++) {
                    tempCatalogItem = new Catalog_Item__c();
                    tempCatalogItem.Item_Name__c = reader.Parent_Catalog__r.Catalog_Name__c;
                    tempCatalogItem.Item_Name__c +='_';
                    tempCatalogItem.Item_Name__c +=reader.Catalog_Name__c;
                    tempCatalogItem.Item_Name__c +='_Item_' + string.valueOf(i);
                    tempCatalogItem.Catalog__c = reader.Id;
                    tempCatalogItem.Description__c = 'testing' + string.valueOf(Integer.valueOf(Math.random() * 100));
                    tempCatalogItem.Is_Catalog__c = true;
                    tempCatalogItem.Status__c = 'ACT';
                    tempCatalogItem.Last_Supplier__c = supplierMap.get('SUPPLIER1').Id;
                    tempCatalogItem.Reference_Price__c = 700;
                    tempCatalogItem.Currency__c = supplierMap.get('SUPPLIER1').Currency__c; // HKD
                    tempCatalogItem.Lead_Time_Format__c = 'WD';
                    tempCatalogItem.Lead_Time_Days__c = 10;
                    tempCatalogItem.Minimum_Order_Quantity__c = 10;
                    tempCatalogItem.Expiry_Date__c = Date.newInstance(2017, 11, 11);
                    tempCatalogItem.Unit_Of_Measure__c = 'EA';
                    toBeInsertedCatalog.add(tempCatalogItem);   
                }
                
                tempCatalogItem = new Catalog_Item__c();
                tempCatalogItem.Item_Name__c = reader.Parent_Catalog__r.Catalog_Name__c;
                tempCatalogItem.Item_Name__c +='_';
                tempCatalogItem.Item_Name__c +=reader.Catalog_Name__c;
                tempCatalogItem.Item_Name__c +='_Item_' + 4;
                tempCatalogItem.Catalog__c = reader.Id;
                tempCatalogItem.Description__c = 'testing' + string.valueOf(Integer.valueOf(Math.random() * 100));
                tempCatalogItem.Is_Catalog__c = true;
                tempCatalogItem.Status__c = 'INACT';
                tempCatalogItem.Last_Supplier__c = supplierMap.get('SUPPLIER1').Id;
                tempCatalogItem.Reference_Price__c = 700;
                tempCatalogItem.Currency__c = supplierMap.get('SUPPLIER1').Currency__c; // HKD
                tempCatalogItem.Lead_Time_Format__c = 'WD';
                tempCatalogItem.Lead_Time_Days__c = 10;
                tempCatalogItem.Minimum_Order_Quantity__c = 10;
                tempCatalogItem.Expiry_Date__c = Date.newInstance(2017, 11, 11);
                tempCatalogItem.Unit_Of_Measure__c = 'EA';
                toBeInsertedCatalog.add(tempCatalogItem);  
                
            }                                  
        }
        
        
        insert toBeInsertedCatalog;
        
        for(Catalog_Item__c reader : toBeInsertedCatalog ) {
            this.catalogItemMap.put(reader.Item_Name__c, reader);
        }
    }
    
    Public void prepareSupplierItemTestData(Boolean twoBestPrice) {
        List<Supplier_item__c> toBeInsertedSupplierItemList = new List<Supplier_Item__c> ();
        Supplier_item__c tempSupplierItem1 = null;
        Supplier_item__c tempSupplierItem2 = null;
        Supplier_item__c tempSupplierItem3 = null;
        Supplier_item__c tempSupplierItem4 = null;
        string key = '';
        
        for(Catalog_Item__c reader : this.catalogItemMap.values()) {
                
            tempSupplierItem1 = new Supplier_Item__c (
                   
                Supplier__c = supplierMap.get('SUPPLIER1').Id,
                Catalog_Item__c = reader.Id,
                Currency__c = supplierMap.get('SUPPLIER1').Currency__c, // HKD
                Price__c = 700,
                Lead_Time_Format__c = 'WD',
                Lead_Time_Days__c = 10,
                Minimum_Order_Quantity__c = 10,
                Expiry_Date__c = Date.newInstance(2017, 11, 11)
            );

            tempSupplierItem2 = new Supplier_Item__c (
                Supplier__c = supplierMap.get('SUPPLIER2').Id,
                Catalog_Item__c = reader.Id,
                Currency__c = supplierMap.get('SUPPLIER2').Currency__c, //USD
                Price__c = 100,
                Lead_Time_Format__c = 'WD',
                Lead_Time_Days__c = 10,
                Minimum_Order_Quantity__c = 10,
                Expiry_Date__c = Date.newInstance(2017, 2, 2)
            );
            
            tempSupplierItem3 = new Supplier_Item__c (
                Supplier__c = supplierMap.get('SUPPLIER3').Id,
                Catalog_Item__c = reader.Id,
                Currency__c = supplierMap.get('SUPPLIER3').Currency__c, //USD
                Price__c = 100,
                Lead_Time_Format__c = 'WD',
                Lead_Time_Days__c = 10,
                Minimum_Order_Quantity__c = 10,
                Expiry_Date__c = Date.newInstance(2017, 3, 3)
            );
                        
            tempSupplierItem4 = new Supplier_Item__c (
                Supplier__c = supplierMap.get('SUPPLIER4').Id,
                Catalog_Item__c = reader.Id,
                Currency__c = supplierMap.get('SUPPLIER4').Currency__c, //CAD
                Price__c = 140,
                Lead_Time_Format__c = 'WD',
                Lead_Time_Days__c = 10,
                Minimum_Order_Quantity__c = 10,
                Expiry_Date__c = Date.newInstance(2017, 4, 4)
            );

        
            toBeInsertedSupplierItemList.add(tempSupplierItem1);
            toBeInsertedSupplierItemList.add(tempSupplierItem2);
            toBeInsertedSupplierItemList.add(tempSupplierItem3);
            toBeInsertedSupplierItemList.add(tempSupplierItem4);
        }
        
        insert toBeInsertedSupplierItemList;
        
        
        for(Catalog_Item__c ciReader : catalogItemMap.values()) {
            for(Supplier_Item__c siReader : toBeInsertedSupplierItemList) {
                
                if(siReader.Catalog_Item__c == ciReader.Id) {
                    if(siReader.Supplier__c == supplierMap.get('SUPPLIER1').Id) {
                        key = ciReader.Item_Name__c + '_' + 'SI1';
                        this.supplierItemMap.put(key, siReader); 
                    }
                    else if(siReader.Supplier__c == supplierMap.get('SUPPLIER2').Id) {
                        key = ciReader.Item_Name__c + '_' + 'SI2';
                        this.supplierItemMap.put(key, siReader); 
                    }                    
                    else if(siReader.Supplier__c == supplierMap.get('SUPPLIER3').Id) {
                        key = ciReader.Item_Name__c + '_' + 'SI3';
                        this.supplierItemMap.put(key, siReader); 
                    }                    
                    else if(siReader.Supplier__c == supplierMap.get('SUPPLIER4').Id) {
                        key = ciReader.Item_Name__c + '_' + 'SI4';
                        this.supplierItemMap.put(key, siReader); 
                    }
                }
                
            }
        }
    }
}