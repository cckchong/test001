@istest
public class TestTEPolicyTypePreparation {
    
    public Map<String, Site__c> NewSiteMap {get; set;}
    public Map<String, Expense_Policy__c> ExpensePolicyMap {get; set;}
    public Map<String, Expense_Type__c> ExpenseTypeMap {get; set;}
    public Map<String, Travel_Policy__c> TravelPolicyMap {get; set;}
    public Map<String, Expense_Category__c> ExpenseCategoryMap{get; set;}
    //public Map<String, Travel_Application_Type__c> TravelApplicationTypeMap {get; set;}
    public Map<String, Education_Policy__c> EducationPolicyMap {get; set;}
    public Map<String, Currency__c> CurrencyMap {get; set;}
    public Map<String, RecordType> RecordTypeMap {get; set;}
    public boolean isSeeAllData;
    
    public TestTEPolicyTypePreparation(boolean isSeeAllData, Map<String, Currency__c> CurrencyMap) {
        this.isSeeAllData = isSeeAllData;
        NewSiteMap = new Map<String, Site__c>();
        ExpensePolicyMap = new Map<String, Expense_Policy__c>();
        ExpenseTypeMap = new Map<String, Expense_Type__c>();
        TravelPolicyMap = new Map<String, Travel_Policy__c>();
        //TravelApplicationTypeMap = new Map<String, Travel_Application_Type__c>();
        EducationPolicyMap = new Map<String, Education_Policy__c>();
        this.CurrencyMap = CurrencyMap;
        RecordTypeMap = new Map<String, RecordType>();
        ExpenseCategoryMap = new Map<String, Expense_Category__c>();
    }
    
    public void basicSetting() {
        
        // init record type. Key: [Expense_Application__c_Education_Expenses, Expense_Application__c_Travel_Expenses, Expense_Application__c_General_Expenses, 
        // Expense_Detail__c_Education_Expenses, Expense_Detail__c_Travel_Expenses, Expense_Detail__c_General_Expenses, 
        // Education_Application__c_Education, Education_Application__c_Child_Education, 
        // Journey__c_Air, Journey__c_Surface, Journey__c_Company_Car]
        List<String> RecordTypeList = new List<String>(), RecordTypeObjectList = new List<String>();
        RecordTypeList.add(TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_EDUCATION_EXPENSES);
        RecordTypeObjectList.add(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME);
        RecordTypeList.add(TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_TRAVEL_EXPENSES);
        RecordTypeObjectList.add(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME);
        RecordTypeList.add(TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES);
        RecordTypeObjectList.add(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME);
        RecordTypeList.add(TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_EDUCATION_EXPENSES);
        RecordTypeObjectList.add(TEConstant.EXPENSE_DETAIL_OBJECT_NAME);
        RecordTypeList.add(TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_TRAVEL_EXPENSES);
        RecordTypeObjectList.add(TEConstant.EXPENSE_DETAIL_OBJECT_NAME);
        RecordTypeList.add(TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES);
        RecordTypeObjectList.add(TEConstant.EXPENSE_DETAIL_OBJECT_NAME);
        RecordTypeList.add(TEConstant.EDUCATION_APPLICATION_EDUCATION);
        RecordTypeObjectList.add(TEConstant.EDUCATION_APPLICATION_OBJECT_NAME);
        RecordTypeList.add(TEConstant.EDUCATION_APPLICATION_CHILD_EDUCATION);
        RecordTypeObjectList.add(TEConstant.EDUCATION_APPLICATION_OBJECT_NAME);
        RecordTypeList.add(TEConstant.JOURNEY_AIR_DEVELOPERNAME);
        RecordTypeObjectList.add(TEConstant.JOURNEY_APPLICATION_OBJECT_NAME);
        RecordTypeList.add(TEConstant.JOURNEY_SURFACE_DEVELOPERNAME);
        RecordTypeObjectList.add(TEConstant.JOURNEY_APPLICATION_OBJECT_NAME);
        RecordTypeList.add(TEConstant.JOURNEY_COMPANYCAR_DEVELOPERNAME);
        RecordTypeObjectList.add(TEConstant.JOURNEY_APPLICATION_OBJECT_NAME);
        
        for (RecordType rt : [SELECT Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, IsPersonType FROM RecordType WHERE DeveloperName IN :RecordTypeList and SobjectType IN :RecordTypeObjectList]) {
            RecordTypeMap.put(rt.SobjectType + '_' + rt.DeveloperName, rt);
        }
        
        // init site. Key: [HKO, TGA]
        List<Site__c> NewSiteList = new List<Site__c>();
        Site__c site1 = new Site__c (
            Name = 'HKO',
            Site_ID__c = 'HKO'
        );
        NewSiteList.add(site1);
        Site__c site2 = new Site__c (
            Name = 'TGA',
            Site_ID__c = 'TGA'
        );
        NewSiteList.add(site2);
        insert NewSiteList;
        List<ID> NewSiteIDList = new List<ID>();
        for (Site__c s : NewSiteList) {
            NewSiteIDList.add(s.Id);
        }
        for (Site__c s : [SELECT Id, Name, Site_ID__c, Admin_Email__c, keyword__c FROM Site__c where Id IN :NewSiteIDList]) {
            NewSiteMap.put(s.Name, s);
        }
        
        // init expense policy. Key: [HKO]
        List<Expense_Policy__c> ExpensePolicyList = new List<Expense_Policy__c>();
        Expense_Policy__c ep1 = new Expense_Policy__c(
            Name = 'HKO',
            keyword__c = 'all',
            Local_Currency__c = CurrencyMap.get('HKD').Id,
            //new
            Allowance_Currency__c = CurrencyMap.get('HKD').Id,
            Cash_Advance_Late_Application_Threshold__c = 5,
            Maximum_of_fitness_expense_currency__c = CurrencyMap.get('HKD').Id,
            Hotel_Allowance_Currency__c = CurrencyMap.get('HKD').Id,
            Maximum_of_fitness_expense__c = 6000,
            Meal_Allowance_Currency__c = CurrencyMap.get('HKD').Id
        );
        ExpensePolicyList.add(ep1);
        insert ExpensePolicyList;
        List<ID> NewExpensePolicyIDList = new List<ID>();
        for (Expense_Policy__c ep : ExpensePolicyList) {
            NewExpensePolicyIDList.add(ep.Id);
        }
        for (Expense_Policy__c ep : [SELECT Id, Name, keyword__c, Local_Currency__c,
                                            Allowance_Currency__c, Cash_Advance_Late_Application_Threshold__c, Maximum_of_fitness_expense_currency__c,
                                            Hotel_Allowance_Currency__c, Maximum_of_fitness_expense__c, Meal_Allowance_Currency__c
                                    FROM Expense_Policy__c 
                                    where Id IN :NewExpensePolicyIDList]) {
            ExpensePolicyMap.put(ep.Name, ep);
        }
        
        /* init expense policy. Key: [Child Education, Entertainment, Health Club Expenses,
                                      Petty Cash, Staff Education, Training, Travelling
                                     ]
        */
        List<Expense_Category__c> expenseCategoryList = new List<Expense_Category__c>();
        expenseCategoryList.add(new Expense_Category__c(name = 'Child Education'));
        expenseCategoryList.add(new Expense_Category__c(name = 'Entertainment'));
        expenseCategoryList.add(new Expense_Category__c(name = 'Health Club Expenses'));
        expenseCategoryList.add(new Expense_Category__c(name = 'Petty Cash'));
        expenseCategoryList.add(new Expense_Category__c(name = 'Staff Education'));
        expenseCategoryList.add(new Expense_Category__c(name = 'Training'));
        expenseCategoryList.add(new Expense_Category__c(name = 'Travelling'));
        upsert expenseCategoryList;
        for(Expense_Category__c reader :[select id, Name from Expense_Category__c where id in :expenseCategoryList]){
            ExpenseCategoryMap.put(reader.Name, reader);
        }
        
        List<Budget__c> BudgetList = new List<Budget__c>();
        for(Expense_Category__c reader :ExpenseCategoryMap.values()){
            Budget__c Budget = new Budget__c();
            Budget.Budget__c = 10000;
            Budget.Currency__c = CurrencyMap.get('HKD').Id;
            Budget.Department__c = 'IT';
            Budget.Year__c = '2015';
            Budget.Site__c = NewSiteMap.get('HKO').id;
            Budget.Expense_Category__c = reader.id;
            Budget.Effective_Start_Date__c = Date.newInstance(Integer.valueof(Budget.Year__c), 1, 1);
            Budget.Effective_End_Date__c = Date.newInstance(Integer.valueof(Budget.Year__c), 1, 1).addyears(1).adddays(-1);
            BudgetList.add(Budget);
            
            Budget = new Budget__c();
            Budget.Budget__c = 10000;
            Budget.Currency__c = CurrencyMap.get('HKD').Id;
            Budget.Department__c = 'IT';
            Budget.Year__c = '2016';
            Budget.Site__c = NewSiteMap.get('HKO').id;
            Budget.Expense_Category__c = reader.id;
            Budget.Effective_Start_Date__c = Date.newInstance(Integer.valueof(Budget.Year__c), 1, 1);
            Budget.Effective_End_Date__c = Date.newInstance(Integer.valueof(Budget.Year__c), 1, 1).addyears(1).adddays(-1);
            BudgetList.add(Budget);
            
            Budget = new Budget__c();
            Budget.Budget__c = 10000;
            Budget.Currency__c = CurrencyMap.get('HKD').Id;
            Budget.Department__c = 'IT';
            Budget.Year__c = '2017';
            Budget.Site__c = NewSiteMap.get('HKO').id;
            Budget.Expense_Category__c = reader.id;
            Budget.Effective_Start_Date__c = Date.newInstance(Integer.valueof(Budget.Year__c), 1, 1);
            Budget.Effective_End_Date__c = Date.newInstance(Integer.valueof(Budget.Year__c), 1, 1).addyears(1).adddays(-1);
            BudgetList.add(Budget);
        }
        insert BudgetList;
        
        
        // init Expense Type. Key: { H: [Travel Expenses, Education Expenses, General Expenses], L: [Tuition fee, Entertainment & Gifts, Visa] }
        List<Expense_Type__c> ExpenseTypeList = new List<Expense_Type__c>();
        Expense_Type__c et1 = new Expense_Type__c (
            Name = 'System generated',
            Approval_Workflow__c = 'Application_Approval_Workflows_Type_1',
            Type__c = 'H',
            Expense_Type__c = 'Travel Expenses',
            Expense_Policy__c = ExpensePolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Expense_Claims__c = 'Travel_Expenses',
            Expense_Category__c = ExpenseCategoryMap.get('Travelling').id,
            Min_Applicable_Grade__c = '0'
            
        );
        ExpenseTypeList.add(et1);
        Expense_Type__c et2 = new Expense_Type__c (
            Name = 'System generated',
            Approval_Workflow__c = 'Application_Approval_Workflows_Type_1',
            Type__c = 'H',
            Expense_Type__c = 'Education Expenses',
            Expense_Policy__c = ExpensePolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Expense_Claims__c = 'Education_Expenses',
            Expense_Category__c = ExpenseCategoryMap.get('Staff Education').id,
            Min_Applicable_Grade__c = '0'
        );
        ExpenseTypeList.add(et2);
        Expense_Type__c et3 = new Expense_Type__c (
            Name = 'System generated',
            Approval_Workflow__c = 'Application_Approval_Workflows_Type_1',
            Type__c = 'H',
            Expense_Type__c = 'General Expenses',
            Expense_Policy__c = ExpensePolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Expense_Claims__c = 'General_Expenses',
            Expense_Category__c = ExpenseCategoryMap.get('Petty Cash').id,
            Min_Applicable_Grade__c = '0'
        );
        ExpenseTypeList.add(et3);
        Expense_Type__c et4 = new Expense_Type__c (
            Name = 'System generated',
            Approval_Workflow__c = 'Approval_Workflows_Type_1',
            Type__c = 'L',
            Expense_Type__c = 'Tuition fee',
            Expense_Policy__c = ExpensePolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Expense_Claims__c = 'Education_Expenses',
            Expense_Category__c = ExpenseCategoryMap.get('Staff Education').id,
            Min_Applicable_Grade__c = '0'
        );
        ExpenseTypeList.add(et4);
        Expense_Type__c et5 = new Expense_Type__c (
            Name = 'System generated',
            Approval_Workflow__c = 'Approval_Workflows_Type_1',
            Type__c = 'L',
            Expense_Type__c = 'Entertainment & Gifts',
            Expense_Policy__c = ExpensePolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Expense_Claims__c = 'General_Expenses',
            Expense_Category__c = ExpenseCategoryMap.get('Petty Cash').id,
            Min_Applicable_Grade__c = '0'
        );
        ExpenseTypeList.add(et5);
        Expense_Type__c et6 = new Expense_Type__c (
            Name = 'System generated',
            Approval_Workflow__c = 'Approval_Workflows_Type_1',
            Type__c = 'L',
            Expense_Type__c = 'Visa',
            Expense_Policy__c = ExpensePolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Expense_Claims__c = 'Travel_Expenses',
            Expense_Category__c = ExpenseCategoryMap.get('Travelling').id,
            Min_Applicable_Grade__c = '0'
        );
        ExpenseTypeList.add(et6);
        
        Expense_Type__c et7 = new Expense_Type__c (
            Name = 'System generated',
            Approval_Workflow__c = 'Approval_Workflows_Type_1',
            Type__c = 'L',
            Expense_Type__c = 'Meal',
            Expense_Properties__c = 'Meal',
            Expense_Policy__c = ExpensePolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Expense_Claims__c = 'Travel_Expenses',
            Expense_Category__c = ExpenseCategoryMap.get('Travelling').id,
            Min_Applicable_Grade__c = '0'
        );
        ExpenseTypeList.add(et7);
        
        Expense_Type__c et8 = new Expense_Type__c (
            Name = 'System generated',
            Approval_Workflow__c = 'Approval_Workflows_Type_1',
            Type__c = 'L',
            Expense_Type__c = 'Hotel',
            Expense_Properties__c = 'Hotel',
            Expense_Policy__c = ExpensePolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Expense_Claims__c = 'Travel_Expenses',
            Expense_Category__c = ExpenseCategoryMap.get('Travelling').id,
            Min_Applicable_Grade__c = '0'
        );
        ExpenseTypeList.add(et8);
        
        Expense_Type__c et9 = new Expense_Type__c (
            Name = 'System generated',
            Approval_Workflow__c = 'Approval_Workflows_Type_1',
            Type__c = 'L',
            Expense_Type__c = 'Health',
            Expense_Properties__c = 'Health',
            Expense_Policy__c = ExpensePolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Expense_Claims__c = 'General_Expenses',
            Expense_Category__c = ExpenseCategoryMap.get('Travelling').id,
            Min_Applicable_Grade__c = '0'
        );
        ExpenseTypeList.add(et9);
        
        insert ExpenseTypeList;
        List<ID> ExpenseTypeIDList = new List<ID>();
        for (Expense_Type__c et : ExpenseTypeList) {
            ExpenseTypeIDList.add(et.Id);
        }
        for (Expense_Type__c et : [SELECT Id, Name, Approval_Workflow__c, Type__c, Expense_Type__c, Expense_Policy__c, keyword__c, Account_Info__c,  Expense_Claims__c, Min_Applicable_Grade__c 
                                   FROM Expense_Type__c where Id IN :ExpenseTypeIDList]) {
            ExpenseTypeMap.put(et.Name, et);
        }
        
        // init travel policy. Key: [HKO]
        List<Travel_Policy__c> TravelPolicyList = new List<Travel_Policy__c>();
        Travel_Policy__c tp1 = new Travel_Policy__c(
            Name = 'HKO',
            keyword__c = 'all' 
        );
        TravelPolicyList.add(tp1);
        insert TravelPolicyList;
        List<ID> NewTravelPolicyIDList = new List<ID>();
        for (Travel_Policy__c tp : TravelPolicyList) {
            NewTravelPolicyIDList.add(tp.Id);
        }
        for (Travel_Policy__c tp : [SELECT Id, Name, keyword__c FROM Travel_Policy__c where Id IN :NewTravelPolicyIDList]) {
            TravelPolicyMap.put(tp.Name, tp);
        }
        /*
        // init travel application type. Key: [General Travel, Shuttle to TAA]
        List<Travel_Application_Type__c> TravelApplicationTypeList = new List<Travel_Application_Type__c>();
        Travel_Application_Type__c tt1 = new Travel_Application_Type__c(
            Name = 'General Travel',
            Approval_Workflow__c = 'Approval_Workflows_Type_2',
            Journey_Type__c = 'Air;Surface',
            Travel_Policy__c = TravelPolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Site__c = NewSiteMap.get('HKO').Id
        );
        TravelApplicationTypeList.add(tt1);
        Travel_Application_Type__c tt2 = new Travel_Application_Type__c(
            Name = 'Shuttle to TAA',
            Approval_Workflow__c = 'Approval_Workflows_Type_1',
            Journey_Type__c = 'Company Car',
            Travel_Policy__c = TravelPolicyMap.get('HKO').Id,
            keyword__c = 'all',
            Site__c = NewSiteMap.get('HKO').Id

        );
        TravelApplicationTypeList.add(tt2);
        insert TravelApplicationTypeList;
        List<Id> TravelApplicationTypeIDList = new List<Id>();
        for (Travel_Application_Type__c tt : TravelApplicationTypeList) {
            TravelApplicationTypeIDList.add(tt.Id);
        }
        for (Travel_Application_Type__c tt : [select Id, Name, Approval_Workflow__c, Journey_Type__c, Travel_Policy__c, keyword__c, Default_To_Site__c from Travel_Application_Type__c where Id IN :TravelApplicationTypeIDList]) {
            TravelApplicationTypeMap.put(tt.Name, tt);
        }
        */
        // init education policy. Key: [HKO]
        List<Education_Policy__c> educationPolicyList = new List<Education_Policy__c>();
        Education_Policy__c edp1 = new Education_Policy__c(
            Name = 'HKO',
            Child_Education_Application_Max_Grade__c = 99,
            Child_Education_Application_Min_Grade__c = 1,
            Education_Application_Max_Grade__c = 99,
            Education_Application_Min_Grade__c =1,
            Education_Approval_Workflow__c = 'Approval_Workflows_Type_1',
            Child_Approval_Workflow__c = 'Approval_Workflows_Type_1',
            Admin_Email__c = 'tahcmuser@gmail.com'
        );
        educationPolicyList.add(edp1);
        insert educationPolicyList;
        List<Id> educationPolicyIDList = new List<Id>();
        for (Education_Policy__c edp : educationPolicyList) {
            educationPolicyIDList.add(edp.Id);
        }
        for (Education_Policy__c edp : [select Id, Name, Admin_Email__c, Child_Education_Application_Min_Grade__c, RecordTypeId from Education_Policy__c where Id IN :educationPolicyIDList]) {
            EducationPolicyMap.put(edp.Name, edp);
        }
    }
    
    public static void changeUserSite(Map<Id, Employee__c> empList, String siteName) {
        Id siteId = null;
        List<Employee__c> updateList = new List<Employee__c>();
        for (Site__c site : [select Id from Site__c where Name = :siteName]) {
            siteId = site.Id;
        }
        if (siteId == null) return;
        for (Employee__c emp : [select Id, Site__c from Employee__c where Id IN :empList.keySet()]) {
            emp.Site__c = siteId;
            updateList.add(emp);
        }
        update updateList;
    }
}