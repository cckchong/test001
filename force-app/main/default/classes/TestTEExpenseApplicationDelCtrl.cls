@isTest
public with sharing class TestTEExpenseApplicationDelCtrl
{

    Public Static TestTEPreparation TEPreparation; 
    Public static employee__c employee;
    Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    Public static String userName = 'user1';
    
    Public static void preparation(Boolean isSeeAllData){
        TEPreparation = new TestTEPreparation (isSeeAllData);
        TEPreparation.Preparation(isSeeAllData);
        employee = TEPreparation.getEmployeefromOriginalEmployeeID(userName);
        EmployeeAdministrator = TEPreparation.EmployeeAdministratorMap;
    }
    
    @isTest
    public static void generalDel() { 
        PageReference prf = null;        
        Map<String, User> UserMap = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        Expense_Application__c ea = new Expense_Application__c();
        ea.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
        ea.RecordTypeId = TEPreparation.RecordTypeMap.get(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME + '_' + TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES).Id;
        insert ea;
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
        TEExpenseApplicationDelCtrl ctrl = new TEExpenseApplicationDelCtrl(sc);
        prf = ctrl.action();
        system.assertNotEquals(null,prf);
    }
    
    @isTest
    public static void generalFailToDel() { 
        PageReference prf = null;        
        Map<String, User> UserMap = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        Expense_Application__c ea2 = new Expense_Application__c();
        ea2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
        ea2.RecordTypeId = TEPreparation.RecordTypeMap.get(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME + '_' + TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES).Id;
        insert ea2;
        Expense_Detail__c ed2 = new Expense_Detail__c();
        ed2.Expense_Application__c = ea2.Id;
        ed2.Expense_Type__c = TEPreparation.ExpenseTypeMap.get('HKO - Health').id;
        ed2.Status__c = TEConstant.STATUS_CONFIRMED;
        ed2.Amount__c = 1;
        ed2.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
        ed2.Receipt_Date__c = Date.today();
        insert ed2;
        ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ea2);
        TEExpenseApplicationDelCtrl ctrl2 = new TEExpenseApplicationDelCtrl(sc2);
        prf = ctrl2.action();
        system.assertNotEquals(null,prf);
    }
      
}