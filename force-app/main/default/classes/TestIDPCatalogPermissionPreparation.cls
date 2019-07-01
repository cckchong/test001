@isTest
Public class TestIDPCatalogPermissionPreparation {
	
    Public Map<String, Catalog_Item_Permission__c> catalogPermissionMap {get;set;}
    Public Map<String, Catalog__c> catalogAllMap {get;set;}
    Public Map<String, IDP_Policy__c> idpPolicyMap {get;set;}

    Public boolean isSeeAllData;

    Public TestIDPCatalogPermissionPreparation (boolean isSeeAllData, Map<String, Catalog__c> catalogAllMap, Map<String, IDP_Policy__c> idpPolicyMap) {
        this.isSeeAllData = isSeeAllData;
        initVariable(catalogAllMap, idpPolicyMap);

    }
        
    Public void initVariable(Map<String, catalog__c> catalogAllMap,Map<String, IDP_Policy__c> idpPolicyMap) {
        this.catalogPermissionMap = new Map<String, Catalog_Item_Permission__c> ();
        this.catalogAllMap = catalogAllMap;
        this.idpPolicyMap = idpPolicyMap;
    }
    
    Public void basicSetting() {
        prepareDepartmentCatalogPermissionTestData();
    }
    
    
    Public void prepareDepartmentCatalogPermissionTestData() {

        List<Catalog_Item_Permission__c> toBeInsertedCIPList = new List<Catalog_Item_Permission__c> ();

        Catalog_Item_Permission__c cip1 = new Catalog_Item_Permission__c(
            Catalog__c = this.catalogAllMap.get('Administration').Id,
            IDP_Policy__c = this.idpPolicyMap.get('HKO').Id,
            isCatalogLevel__c = true,
            isDepartmentLevel__c = true, 
            Function__c = 'IT',
            Department__c = 'IT'
        );

        Catalog_Item_Permission__c cip2 = new Catalog_Item_Permission__c(
            Catalog__c = this.catalogAllMap.get('Machinery').Id,
            IDP_Policy__c = this.idpPolicyMap.get('TAA').Id,
            isCatalogLevel__c = true,
            isDepartmentLevel__c = true, 
            Function__c = 'IT',
            Department__c = 'IT'
        );

        Catalog_Item_Permission__c cip3 = new Catalog_Item_Permission__c(
            Catalog__c = this.catalogAllMap.get('TAA Local Catalog').Id,
            IDP_Policy__c = this.idpPolicyMap.get('TAA').Id,
            isCatalogLevel__c = true,
            isDepartmentLevel__c = true, 
            Function__c = 'IT',
            Department__c = 'IT'
        );

        toBeInsertedCIPList.add(cip1);
        toBeInsertedCIPList.add(cip2);
        toBeInsertedCIPList.add(cip3);
        system.debug(LoggingLevel.ERROR, ('before catalog item permission executed queries:'+Limits.getQueries())); 

        insert toBeInsertedCIPList;
        system.debug(LoggingLevel.ERROR, ('after catalog item permission executed queries'+Limits.getQueries())); 

        this.catalogPermissionMap.put('cip1', cip1);
        this.catalogPermissionMap.put('cip2', cip2);
        this.catalogPermissionMap.put('cip3', cip3);

    }
    
}