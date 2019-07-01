public virtual class TestIDPPreparation  extends TestTEPreparation{
   
    //User, Employee, Employee Admin 
    public TestIDPUserPreparation testIDPUserPrep;
    
    
    //Currency and Exchange Rate Data Set
    public TestTEExchangeRatePreparation testTEExchangeRatePrep;
    public Map<String, Currency__c> currencyMap {get;set;}
    public Map<String, Exchange_Rate__c> exchangeRateMap {get;set;}
    
    //Site Data Set
    public TestIDPSitePreparation testIDPSitePrep;
    Public Map<String, Site__c> siteMap {get;set;}
    
    //Supplier Data Set
    Public TestIDPSupplierPreparation testIDPSupplierPrep;
    Public Map<String, Supplier__c> supplierMap {get;set;}
    Public Map<String, Supplier_Contact__c> supplierContactMap {get;set;}    
    
    //IDP Policy Data Set
    Public TestIDPPolicyPreparation TestIDPPolicyPrep;
    Public Map<String, IDP_Policy__c> idpPolicyMap {get;set;}
    
    //Budget Data Set
    Public TestIDPBudgetPreparation testIDPBudgetPrep;
    Public Map<String, IDP_Budget__c> budgetMap {get;set;}
    //Public Map<String, Expense_Category__c> expenseCategoryMap {get;set;}    
    
    //Catalog Data Set
    Public TestIDPCatalogPreparation testIDPCatalogPrep;
    Public Map<String, Catalog__c> catalogAllMap {get;set;}
    Public Map<String, Catalog_Policy_Setting__c> catalogPolicySettingMap {get;set;}

    //Catalog Item Data Set
    Public TestIDPCatalogItemPreparation testIDPCatalogItemPrep;
    Public Map<String, Catalog_Item__c> catalogItemMap {get;set;}

    //Catalog Permission Set
    Public TestIDPCatalogPermissionPreparation testIDPCatalogPermissionPrep;
    Public Map<String, Catalog_Item_Permission__c> catalogPermissionMap {get;set;}

    public TestIDPPreparation ( Boolean isSeeAllData ){
        super(isSeeAllData);
    }

    public void idpPreparation(Boolean isSeeAllData) {
        
        //Setup Site
        prepareSite();
        limit1('site');
        //IDP Policy Data Set
        preparePolicy();
        limit1('policy');
        //Setup User

        //Setup Currency and Exchange Rate
        prepareCurrency();
        update (new Currency__c(Id=currencyMap.get('USD').Id, Is_Budget_Currency__c = true,Is_IDP_Budget_Currency__c =true, Is_Standard_Currency__c = true));
        limit1('currency');

       
        prepareUser();
        limit1('user');
        
        //Setup Supplier
        prepareSupplier();
        limit1('supplier');

        
        //Catalog Data Set
        prepareCatalog();
        limit1('catalog');
        
        //Catalog Item Data Set
        prepareCatalogItem();
        limit1('catalogItem');

        //Budget Data Set
        prepareBudget();
        limit1('budget');

        //this.currencyMap.get('USD').Is_Budget_Currency__c = true;
        //update this.currencyMap.get('USD');

        //Catalog Permission Data Set
        //prepareCatalogPermission();
        //idpInitSetting();

    }

    public void limit1(String remark) {
        system.debug(LoggingLevel.ERROR, (remark+' executed queries:'+Limits.getQueries())); 
    }
    
    public void prepareCurrency() {
        this.testTEExchangeRatePrep = new TestTEExchangeRatePreparation(isSeeAllData);
        this.testTEExchangeRatePrep.basicSetting();
        this.currencyMap = this.testTEExchangeRatePrep.currencyMap;
        this.exchangeRateMap = this.testTEExchangeRatePrep.exchangeRateMap;   

        insert (new Exchange_Rate__c(
            Date__c = Date.newInstance(2015, 8, 10),
            From_Currency__c = currencyMap.get('USD').Id,
            To_Currency__c = currencyMap.get('USD').Id,
            Type__c = 'BK',
            Rate__c = 1
        ));
    }
    
    public void prepareUser() {
        this.testIDPUserPrep = new TestIDPUserPreparation(isSeeAllData, this.siteMap, this.idpPolicyMap, this.currencyMap);
        this.testIDPUserPrep.idpBasicSetting();
        this.UserMap = this.testIDPUserPrep.userMap;
        this.EmployeeMap = this.testIDPUserPrep.EmployeeMap;
        this.EmployeeAdministratorMap = this.testIDPUserPrep.EmployeeAdministratorMap;

        system.debug(logginglevel.ERROR, 'prepartion userMap:'+this.userMap);
    }
    
    public void prepareSite() {
        this.testIDPSitePrep = new TestIDPSitePreparation(isSeeAllData);
        this.testIDPSitePrep.basicSetting();
        this.siteMap = this.testIDPSitePrep.siteMap;
    }
    
    public void prepareSupplier() {
        this.testIDPSupplierPrep = new TestIDPSupplierPreparation(isSeeAllData,this.currencyMap);
        this.testIDPSupplierPrep.basicSetting();
        this.supplierMap = this.testIDPSupplierPrep.supplierMap;
        this.supplierContactMap = this.testIDPSupplierPrep.supplierContactMap;
    }
    
    public void preparePolicy() {
        this.TestIDPPolicyPrep = new TestIDPPolicyPreparation(isSeeAllData);
        this.TestIDPPolicyPrep.basicSetting();
        this.idpPolicyMap = this.TestIDPPolicyPrep.idpPolicyMap;
    }
    
    public void prepareBudget() {
        this.testIDPBudgetPrep = new TestIDPBudgetPreparation(isSeeAllData, this.currencyMap, this.siteMap);
        this.testIDPBudgetPrep.basicSetting();
        this.budgetMap = this.testIDPBudgetPrep.budgetMap;
        system.debug('budgetMap:'+budgetMap);
        //this.expenseCategoryMap = this.testIDPBudgetPrep.expenseCategoryMap;
    }
    
    public void prepareCatalog() {
        this.testIDPCatalogPrep = new TestIDPCatalogPreparation(isSeeAllData, this.currencyMap, this.idpPolicyMap, this.userMap);
        this.testIDPCatalogPrep.basicSetting();
        this.catalogAllMap = this.testIDPCatalogPrep.catalogAllMap;
        this.catalogPolicySettingMap = this.testIDPCatalogPrep.catalogPolicySettingMap;
    }
    
    public void prepareCatalogItem() {
        //Catalog Item Data Set
        this.testIDPCatalogItemPrep = new TestIDPCatalogItemPreparation(isSeeAllData, this.currencyMap, this.catalogAllMap, this.supplierMap);
        this.testIDPCatalogItemPrep.basicSetting();
        this.catalogItemMap = this.testIDPCatalogItemPrep.catalogItemMap;
    }
    
    public void prepareCatalogPermission(){
        this.testIDPCatalogPermissionPrep = new TestIDPCatalogPermissionPreparation(isSeeAllData, this.catalogAllMap, this.idpPolicyMap);
        this.testIDPCatalogPermissionPrep.basicSetting();
        this.catalogPermissionMap = this.testIDPCatalogPermissionPrep.catalogPermissionMap;
    }
    public void idpInitSetting() {
        List<Id> empIDList1 = new List<Id>();
        List<Id> empIDList2 = new List<Id>();
        for (Employee__c emp : EmployeeMap.values()) {
            if ((emp.Original_Employee_ID__c).equals('user1')) {
                empIDList1.add(emp.Id);
            }
            if ((emp.Original_Employee_ID__c).equals('user2')) {
                empIDList2.add(emp.Id);
            }            
        }
        
        idpSetProperties(this.idpPolicyMap.get('HKO').Id, empIDList1 );
        
        idpSetProperties(this.idpPolicyMap.get('TAA').Id, empIDList2 );
    }
    
    public void idpSetProperties(String idpPolicyId, List<Id> employeeIdList){
        
        
        List<Employee__c> toBeUpdatedEmployeeList = new List<Employee__c>();
        
        for(Employee__c reader : [SELECT Id, IDP_Policy__c FROM Employee__c WHERE Id in : employeeIdList]) {
            reader.IDP_Policy__c = idpPolicyId;
            toBeUpdatedEmployeeList.add(reader);
        }
        
        
        if (!toBeUpdatedEmployeeList.isEmpty()){
            update toBeUpdatedEmployeeList;
            EmployeeMap.clear();
            for ( Employee__c reader : 
                [
                    select id, Name, First_Name__c, Last_Name__c,
                    IDP_Policy__c, Education_Policy__c, Travel_Policy__c, Expense_Policy__c, 
                    Leave_Policy__c, Timeset__c, user__c, Notif_Leave_Forfeiture__c,
                    Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c,
                    Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c,
                    Original_Employee_ID__c 
                    from Employee__c
                    where Original_Employee_ID__c in ( 'user1', 'user2' )
            ]){
                EmployeeMap.put (reader.name, reader);
            }
        }        
    }
}