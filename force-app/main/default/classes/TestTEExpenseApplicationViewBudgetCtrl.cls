@isTest
public class TestTEExpenseApplicationViewBudgetCtrl {

    @isTest 
    public static void test() {  
        TestTEPreparation   tp = new TestTEPreparation (false);
        tp.Preparation(false);
        Map<String, User> UserMap = tp.UserMap;
        Test.startTest();
        expense_policy__c ep = new expense_policy__c();
        ep.name = 'Test';
        insert ep;        
        
        Site__c site = new Site__c();
        site.Name = 'Test';
        insert site;  
        
        User usr = UserMap.get('user1');
        Employee__c employee =  tp.EmployeeMap.get('user1'); 
        Employee_Administrator__c employeeAdmin = tp.EmployeeAdministratorMap.get('user1'); 
        /*
        insert usr;        
                
        Employee__c employee = new Employee__c();
        employee.expense_policy__c = ep.Id;   
        employee.User__c = usr.id;        
        employee.Site__c = site.Id;         
        insert employee;
        
        Employee_Administrator__c employeeAdmin = new Employee_Administrator__c();
        employeeAdmin.Employee_Administrator__c = employee.Id;
        employeeAdmin.Employee__c = employee.Id;
        insert employeeAdmin;
        */         
        Expense_Application__c ea = new Expense_Application__c();
        ea.on_behalf_of__c = employeeAdmin.Id; 
        ea.Actual_Approver_1__c = usr.Id;   
        ea.Apply_Date__c = date.newInstance(2016,5,18);
        insert ea;
        
        Expense_Application__c e =  [select id,on_behalf_of__r.employee__r.expense_policy__r.name,
                                    on_behalf_of__r.employee__r.Department__c, 
                                    on_behalf_of__r.employee__r.Site__r.Name,
                                    Year__c,
                                    Actual_Approver_1__c
                                    from Expense_Application__c
                                    where id =:ea.id];
        
        Expense_Category__c ec = new Expense_Category__c();
        /*
        ec.name = 'Child Education';
        insert ec; 
        */
        for(Expense_Category__c  reader : [select id from Expense_Category__c  where name = 'Child Education']){
            ec.id = reader.id;
        }
        Currency__c hkd =  new Currency__c();
        for(Currency__c reader : [select id from Currency__c where name = 'HKD']){
            hkd.id = reader.id;
            hkd.Description__c = 'HKD Test';
            hkd.Is_Budget_Currency__c = true;
        }    
        
        /*
        hkd.Name = 'HKD';
        
        insert hkd;
        */
        Budget__c b = new Budget__c();           
        b.Department__c = e.on_behalf_of__r.employee__r.Department__c;
        b.Site__c = e.on_behalf_of__r.employee__r.Site__r.id;
        b.Year__c = e.Year__c;
        b.Expense_Category__c = ec.Id;
        b.Currency__c = hkd.Id;
        insert b;
        
        Test.setCurrentPage(Page.TEExpenseApplicationViewBudgetVFP);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
        ApexPages.currentPage().getParameters().put('id', ea.Id );
        TEExpenseApplicationViewBudgetCtrl ctrl = new TEExpenseApplicationViewBudgetCtrl(sc);
                
        String bugetMessage = ctrl.budgetMsg;
        system.debug(bugetMessage);
        
        ctrl.clear();
        Test.stopTest();      
    }
    
}