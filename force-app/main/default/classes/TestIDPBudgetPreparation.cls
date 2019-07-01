@istest
Public class TestIDPBudgetPreparation {
    

    Public String RANDOM_STRING = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    
    //Available key: [HKO-IT-IT-Administration-2016, HKO-IT-IT-Administration-2017, HKO-IT-IT-BA-Administration-2017, 
    //TAA-IT-IT-Machinery-2017, TAA-IT-IT-TAA Local Catalog-2017]   
    Public Map<String, IDP_Budget__c> budgetMap {get;set;}
    //Public Map<String, Expense_Category__c> expenseCategoryMap {get;set;}
    private Map<String, Currency__c> currencyMap;
    private Map<String, Site__c> siteMap;
    
    Public boolean isSeeAllData;

    
    Public TestIDPBudgetPreparation (boolean isSeeAllData,  Map<String, Currency__c> currencyMap, Map<String, Site__c> siteMap) {
        this.isSeeAllData = isSeeAllData;
        initVariable(currencyMap, siteMap);

    }
    
    Public void initVariable( Map<String, Currency__c> currencyMap, Map<String, Site__c> siteMap) {
        this.budgetMap = new Map<String, IDP_Budget__c> ();
        //this.expenseCategoryMap = new Map<String, Expense_Category__c> ();
        this.currencyMap = currencyMap;
        this.siteMap = siteMap;
    }
    
    Public void basicSetting() {
        //prepareExpenseCategoryData();
        prepareBudgetData();
    }
    
    /*
    Public void prepareExpenseCategoryData() {
        
        List<Expense_Category__c> toBeInsertedExpenseCategoryList = new List<Expense_Category__c> ();        
        Expense_Category__c ec1 = new Expense_Category__c(
            Name = 'Administration',
            Expense_Category_ID__c = generateRandomString(10)
        );        
        Expense_Category__c ec2 = new Expense_Category__c(
            Name = 'Machinery',
            Expense_Category_ID__c = generateRandomString(10)
        );        
        Expense_Category__c ec3 = new Expense_Category__c(
            Name = 'TAA Local Catalog',
            Expense_Category_ID__c = generateRandomString(10)
        );
        toBeInsertedExpenseCategoryList.add(ec1);
        toBeInsertedExpenseCategoryList.add(ec2);
        toBeInsertedExpenseCategoryList.add(ec3);
        insert toBeInsertedExpenseCategoryList;
        for(Expense_Category__c reader : toBeInsertedExpenseCategoryList) {
            this.expenseCategoryMap.put(reader.Name, reader);
        }
    }
    */
    
    Public void prepareBudgetData() {
    
        List<IDP_Budget__c> toBeInsertedBudgetList = new List<IDP_Budget__c> ();

        system.debug(logginglevel.ERROR, 'UDS.Id: '+this.currencyMap.get('USD').Id);
        //2016 HKO-IT-IT Administration Catalog Budget
        IDP_Budget__c tempbudget1 = new IDP_Budget__c (
            //Name = 'HKO-IT-IT-Administration-2016',
            Type__c= 'Yearly',
            Function_Code__c = 'IT',
            Department_Code__c = 'IT',
            Section_Code__c = '',
            Year_Reserve_Budget_by_Year__c = 99999999,
            Site__c = this.siteMap.get('HKO').Id,
            /*
            Budget__c = 1000000,
            Budget_ID__c = generateRandomString(10),
            Currency__c = this.currencyMap.get('USD').Id,
            Department__c = 'IT',
            Department_Code__c = 'IT',
            Description__c = generateRandomString(10),
            Effective_End_Date__c = Date.newInstance(2016, 12, 31),
            Effective_Start_Date__c= Date.newInstance(2016, 1, 1),
            Expense_Amount__c = 0,
            Expense_Category__c = this.expenseCategoryMap.get('Administration').Id,
            Function_Code__c = 'IT',
            keyword__c = generateRandomString(10),
            Section_Code__c = '',
            
            Withheld_Amount__c = 0,
            */
            Year__c = String.valueof(System.today().year())
        );
        
        /*
        //2016 HKO-IT-IT Administration Catalog Budget
        Budget__c tempbudget1 = new Budget__c (
            Name = 'HKO-IT-IT-Administration-2016',
            Budget__c = 1000000,
            Budget_ID__c = generateRandomString(10),
            Currency__c = this.currencyMap.get('USD').Id,
            Department__c = 'IT',
            Department_Code__c = 'IT',
            Description__c = generateRandomString(10),
            Effective_End_Date__c = Date.newInstance(2016, 12, 31),
            Effective_Start_Date__c= Date.newInstance(2016, 1, 1),
            Expense_Amount__c = 0,
            Expense_Category__c = this.expenseCategoryMap.get('Administration').Id,
            Function_Code__c = 'IT',
            keyword__c = generateRandomString(10),
            Section_Code__c = '',
            Site__c = this.siteMap.get('HKO').Id,
            Withheld_Amount__c = 0,
            Year__c = String.valueof(System.today.year())
        );

        //2017 HKO-IT-IT Administration Catalog Budget
        Budget__c tempbudget2 = new Budget__c (
             Name = 'HKO-IT-IT-Administration-2017',
            Budget__c = 1000000,
            Budget_ID__c = generateRandomString(10),
            Currency__c = this.currencyMap.get('USD').Id,
            Department__c = 'IT',
            Department_Code__c = 'IT',
            Description__c = generateRandomString(10),
            Effective_End_Date__c = Date.newInstance(2017, 12, 31),
            Effective_Start_Date__c= Date.newInstance(2017, 1, 1),
            Expense_Amount__c = 0,
            Expense_Category__c = this.expenseCategoryMap.get('Administration').Id,
            Function_Code__c = 'IT',
            keyword__c = generateRandomString(10),
            Section_Code__c = '',
            Site__c = this.siteMap.get('HKO').Id,
            Withheld_Amount__c = 0,
            Year__c = '2017'
        );


        //2017 HKO-IT-IT-BA Administration Catalog Budget
        Budget__c tempbudget3 = new Budget__c (
            Name = 'HKO-IT-IT-BA-Administration-2017',
            Budget__c = 1000000,
            Budget_ID__c = generateRandomString(10),
            Currency__c = this.currencyMap.get('USD').Id,
            Department__c = 'IT',
            Department_Code__c = 'IT',
            Description__c = generateRandomString(10),
            Effective_End_Date__c = Date.newInstance(2017, 12, 31),
            Effective_Start_Date__c= Date.newInstance(2017, 1, 1),
            Expense_Amount__c = 0,
            Expense_Category__c = this.expenseCategoryMap.get('Administration').Id,
            Function_Code__c = 'IT',
            keyword__c = generateRandomString(10),
            Section_Code__c = 'BA',
            Site__c = this.siteMap.get('TAA').Id,
            Withheld_Amount__c = 0,
            Year__c = '2017'
        );

        //2017 HKO-IT-IT Machinery Catalog Budget
        Budget__c tempbudget4 = new Budget__c (
            Name = 'TAA-IT-IT-Machinery-2017',
            Budget__c = 1000000,
            Budget_ID__c = generateRandomString(10),
            Currency__c = this.currencyMap.get('USD').Id,
            Department__c = 'IT',
            Department_Code__c = 'IT',
            Description__c = generateRandomString(10),
            Effective_End_Date__c = Date.newInstance(2017, 12, 31),
            Effective_Start_Date__c= Date.newInstance(2017, 1, 1),
            Expense_Amount__c = 0,
            Expense_Category__c = this.expenseCategoryMap.get('Machinery').Id,
            Function_Code__c = 'IT',
            keyword__c = generateRandomString(10),
            Section_Code__c = '',
            Site__c = this.siteMap.get('TAA').Id,
            Withheld_Amount__c = 0,
            Year__c = '2017'
        );
        
        //2017 HKO-IT-IT TAA Local Catalog Budget
        Budget__c tempbudget5 = new Budget__c (
            Name = 'TAA-IT-IT-TAA Local Catalog-2017',
            Budget__c = 1000000,
            Budget_ID__c = generateRandomString(10),
            Currency__c = this.currencyMap.get('USD').Id,
            Department__c = 'IT',
            Department_Code__c = 'IT',
            Description__c = generateRandomString(10),
            Effective_End_Date__c = Date.newInstance(2017, 12, 31),
            Effective_Start_Date__c= Date.newInstance(2017, 1, 1),
            Expense_Amount__c = 0,
            Expense_Category__c = this.expenseCategoryMap.get('TAA Local Catalog').Id,
            Function_Code__c = 'IT',
            keyword__c = generateRandomString(10),
            Section_Code__c = '',
            Site__c = this.siteMap.get('HKO').Id,
            Withheld_Amount__c = 0,
            Year__c = '2017'
        );
        */
        toBeInsertedBudgetList.add(tempBudget1);
        //toBeInsertedBudgetList.add(tempBudget2);
        //toBeInsertedBudgetList.add(tempBudget3);
        //toBeInsertedBudgetList.add(tempBudget4);        
        //toBeInsertedBudgetList.add(tempBudget5); 
                       
        insert toBeInsertedBudgetList;
        for(IDP_Budget__c reader: [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, 
                                   LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
                                   Type__c, Catalog_Name__c, Currency__c, is_Yearly_Budget__c, Ext_ID__c, Year__c, Catalog__c, 
                                   Site__c, Jan_Budget__c, Jan_Used_Budget__c, Jan_Reserve_Budget__c, Feb_Budget__c, 
                                   Feb_Reserve_Budget__c, Feb_Used_Budget__c, Section_Code__c, Department_Code__c, 
                                   Function_Code__c, Jan_Remaining_Budget__c, Feb_Remaining_Budget__c, 
                                   Year_Remaining_Budget__c, Current_Month_Remaining_Budget__c, Mar_Budget__c, 
                                   Apr_Budget__c, May_Budget__c, Jun_Budget__c, Jul_Budget__c, Aug_Budget__c, Sept_Budget__c, 
                                   Oct_Budget__c, Nov_Budget__c, Dec_Budget__c, Mar_Reserve_Budget__c, Apr_Reserve_Budget__c, 
                                   May_Reserve_Budget__c, Jun_Reserve_Budget__c, Jul_Reserve_Budget__c, Aug_Reserve_Budget__c, 
                                   Sept_Reserve_Budget__c, Oct_Reserve_Budget__c, Nov_Reserve_Budget__c, Dec_Reserve_Budget__c, 
                                   Mar_Used_Budget__c, Apr_Used_Budget__c, May_Used_Budget__c, Jun_Used_Budget__c, Jul_Used_Budget__c, 
                                   Aug_Used_Budget__c, Sept_Used_Budget__c, Oct_Used_Budget__c, Nov_Used_Budget__c, Dec_Used_Budget__c, 
                                   Mar_Remaining_Budget__c, Dec_Remaining_Budget__c, Apr_Remaining_Budget__c, May_Remaining_Budget__c, 
                                   Jun_Remaining_Budget__c, Jul_Remaining_Budget__c, Aug_Remaining_Budget__c, Sept_Remaining_Budget__c, 
                                   Oct_Remaining_Budget__c, Nov_Remaining_Budget__c, Current_Month_Budget__c, Current_Month_Used_Budget__c, 
                                   Current_Month_Reserve_Budget__c, Year_Budget__c, Year_Reserve_Budget__c, Year_Used_Budget__c, 
                                   Year_Budget_by_Year__c, Year_Reserve_Budget_by_Year__c, Year_Used_Budget_by_Year__c, 
                                   Year_Remaining_Budget_by_Year__c, Jan_Budget_by_Year__c, Feb_Budget_by_Year__c, Mar_Budget_by_Year__c, 
                                   Apr_Budget_by_Year__c, May_Budget_by_Year__c, Jun_Budget_by_Year__c, Jul_Budget_by_Year__c, 
                                   Aug_Budget_by_Year__c, Sept_Budget_by_Year__c, Oct_Budget_by_Year__c, Nov_Budget_by_Year__c, 
                                   Dec_Budget_by_Year__c
                                   from IDP_Budget__c  where id in: toBeInsertedBudgetList]) {
            this.budgetMap.put(reader.Name,reader);  
        }
        
    }
    
    
    public String generateRandomString(Integer len) {
       final String chars = RANDOM_STRING ;
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
   }
}