@isTest 
public class TestTEExpenseDetailOverwriteEditCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
        
        expense_policy__c ep = new expense_policy__c();
        ep.name = 'Test';
        insert ep;
               
        Employee__c employee = new Employee__c();
        employee.expense_policy__c = ep.Id;

        insert employee;
        
        Employee_Administrator__c employeeAdmin = new Employee_Administrator__c();
        employeeAdmin.Employee_Administrator__c = employee.Id;
        employeeAdmin.Employee__c = employee.Id;
        insert employeeAdmin;
    
        Expense_Application__c ea = new Expense_Application__c();
        ea.on_behalf_of__c = employeeAdmin.Id;  
        insert ea;
        
        Expense_Detail__c ed = new Expense_Detail__c ();
        ed.Expense_Application__c = ea.Id;
        ed.Amount__c = 100;
        insert ed;
        
        Test.setCurrentPage(Page.TEExpenseDetailOverwriteEdit);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ed);
        ApexPages.currentPage().getParameters().put('id', ed.Id );
        TEExpenseDetailOverwriteEditCtrl ctrl = new TEExpenseDetailOverwriteEditCtrl(sc);
        
        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);

    }
}