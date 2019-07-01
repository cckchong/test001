@isTest
public class TestTEExpenseDetailProgressBarCtrl {

    @isTest 
    public static void test() {
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
        ea.Status__c = 'DF';
        insert ea;
        
        Expense_Detail__c ed = new Expense_Detail__c();
        ed.Expense_Application__c = ea.id;
        ed.Status__c = 'DF';
        ed.Amount__c = 100;
        insert ed;
        
        Test.setCurrentPage(Page.TEExpenseDetailProgressBarVFPage);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ed);
        ApexPages.currentPage().getParameters().put('id', ed.Id );
        TEExpenseDetailProgressBarCtrl ctrl = new TEExpenseDetailProgressBarCtrl(sc);
    }
}