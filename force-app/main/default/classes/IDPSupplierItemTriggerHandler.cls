public without sharing  class IDPSupplierItemTriggerHandler{

   public static void updateUpdatePriceModifiedDate(Map<Id, Supplier_Item__c> oldSIMap, Map<Id, Supplier_Item__c> newSIMap){
       for(Supplier_Item__c si : oldSIMap.values()){
           if(si.Price__c != newSIMap.get(si.id).price__c){
               newSIMap.get(si.id).Price_Last_Modified_Date__c = System.now();
           }
       }
   }
   
   public static void updateUpdatePriceForBestSupplier(Map<Id, Supplier_Item__c> oldSIMap, Map<Id, Supplier_Item__c> newSIMap){
       List<Supplier_Item__c> siList = new List<Supplier_Item__c>();
       for(Supplier_Item__c si : oldSIMap.values()){
           if(si.Price__c != newSIMap.get(si.id).price__c){
               siList.add(si);
           }
       }
       if(!siList.isEmpty()){
           updateBestSupplier(siList);
       }
   }
   
   public static void updateBestSupplier(List<Supplier_Item__c> newSupplierItemList) {
       List<id> ciList = new List<id>();
       for(Supplier_Item__c si :newSupplierItemList){
           ciList.add(si.Catalog_Item__c);
       }
       IDPCatalogItemUpdateDetailsCtrl.processUpdate(ciList);
       
   }
   public static void updateSupplierItemCurrency(List<Supplier_Item__c> newSupplierItemList) {
       
       Set<Id> supplierIdSet = new Set<Id> ();
       Map<String, Supplier__c> supplierMap = new Map<String, Supplier__c> ();
       
       for(Supplier_Item__c reader : newSupplierItemList) {
           supplierIdSet.add(reader.Supplier__c);
       }
       if(!supplierIdSet.isempty()) {
           for(Supplier__c reader : [SELECT Id, Currency__c FROM Supplier__c WHERE Id in : supplierIdSet]) {           
               supplierMap.put(reader.Id, reader);
           }       
    
    
           for(Supplier_Item__c reader : newSupplierItemList) {
               if(supplierMap.containsKey(reader.Supplier__c)) {
                  reader.Currency__c = supplierMap.get(reader.Supplier__c).Currency__c;
               }
           }
       }
   }
   
}