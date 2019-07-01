@isTest
public class TestTEExpenseApplicationProgressBarCtrl {

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
        Expense_Detail__c ed = new Expense_Detail__c();
        ea.on_behalf_of__c = employeeAdmin.Id;  
        ea.Status__c = 'DF';
        insert ea;
        ed.expense_Application__c = ea.id;
        ed.Status__c = 'PA';
        ed.Amount__c = 100;
        insert ed;
        ea.Status__c = 'DF';
        upsert ea;
        System.assertNotEquals(ea.id,null);
        insert new attachment (ParentId = ea.id , Name = 'Test', Body =  Blob.valueOf('TEST') );
        Test.setCurrentPage(Page.TEExpenseApplicationProgressBarVFPage);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
        ApexPages.currentPage().getParameters().put('id', ea.Id );
        TEExpenseApplicationProgressBarCtrl ctrl = new TEExpenseApplicationProgressBarCtrl(sc);
        System.assertNotEquals(ea.id,null);
    }
    
    
}