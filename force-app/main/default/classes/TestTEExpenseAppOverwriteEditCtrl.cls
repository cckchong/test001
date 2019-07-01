@isTest 
public class TestTEExpenseAppOverwriteEditCtrl{
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
        
        Expense_Application__c ea = new Expense_Application__c ();
        ea.on_behalf_of__c = employeeAdmin.Id;  
        insert ea;
        
        Test.setCurrentPage(Page.TEExpenseApplicationOverwriteEdit);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
        ApexPages.currentPage().getParameters().put('id', ea.Id );
        TEExpenseApplicationOverwriteEditCtrl ctrl = new TEExpenseApplicationOverwriteEditCtrl (sc);
        
        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);

    }
}