@isTest 
public class TestTEExpenseApplicationHCMApproveBatch{
    
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
    //Scenario 1: cannot be approved (single)
    public static void cannotBeApproved() {
        PageReference prf = null;        
        Map<String, User> UserMap = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
            Expense_Application__c ea = new Expense_Application__c();
            ea.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            insert ea;
            Test.setCurrentPage(Page.TEExpenseApplicationHCMApproveBatchVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
            ApexPages.currentPage().getParameters().put('id', ea.Id );
            TEExpenseApplicationHCMApproveBatchCtrl ctrl = new TEExpenseApplicationHCMApproveBatchCtrl(sc);
            prf = ctrl.ApproveAllExpenseApplication();
            system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: PHCM, can be approved (single)
    public static void hcmApproveEA() {
        
        Map<String, User> UserMap = null;
        PageReference prf = null; 
        Expense_Application__c ea2;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        employee.Grade__c = '7';
        upsert employee;
        Test.startTest();
        System.runAs(UserMap.get(userName)) {
            ea2 = new Expense_Application__c();
            ea2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea2.Status__c = TEConstant.STATUS_PENDING_HCM_APPROVAL;
            insert ea2;
        }
        System.runAs(UserMap.get('actapr1')){
            System.assertNotEquals(ea2.id, null); 
            Test.setCurrentPage(Page.TEExpenseApplicationHCMApproveBatchVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ea2);
            ApexPages.currentPage().getParameters().put('id', ea2.Id );
            TEExpenseApplicationHCMApproveBatchCtrl ctrl2 = new TEExpenseApplicationHCMApproveBatchCtrl(sc2);
    
            prf = ctrl2.ApproveAllExpenseApplication();
            System.assertNotEquals(prf, null);
            for(Expense_Application__c reader: [SELECT Id, Status__c FROM Expense_Application__c where Id = :ea2.Id]){
                System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING_FIN_Confirmation);
            }
        }
        Test.stopTest();
        
    }
  
   @isTest 
   //Scenario 3: PHCM, can be approved (set)
    public static void hcmApproveSetCA () {
                
        Map<String, User> UserMap = null;
        PageReference prf = null; 
        Expense_Application__c ea3;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        employee.Grade__c = '7';
        upsert employee;
        Test.startTest();
        System.runAs(UserMap.get(userName)) {
            ea3 = new Expense_Application__c();
            ea3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea3.Status__c = TEConstant.STATUS_PENDING_HCM_APPROVAL ;
            insert ea3;
        }
        System.runAs(UserMap.get('actapr1')){
            System.assertNotEquals(ea3.id, null); 
            List<Expense_Application__c> cashList = new List<Expense_Application__c>();
            cashList.add(ea3);
            Test.setCurrentPage(Page.TEExpenseApplicationHCMApproveBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseApplicationHCMApproveBatchCtrl ctrl3 = new TEExpenseApplicationHCMApproveBatchCtrl(stdSetController);
    
            prf = ctrl3.ApproveAllExpenseApplication();
            System.assertNotEquals(prf, null);
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseApplicationHCMApproveBatchCtrl(stdSetController);
            prf = ctrl3.ApproveAllExpenseApplication();
            for(Expense_Application__c reader: [SELECT Id, Status__c FROM Expense_Application__c where Id = :ea3.Id]){
                System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING_FIN_Confirmation);
            }
        }
        Test.stopTest();
    }
    
    @isTest 
    //Scenario 4: general PHCM, can be approved (single)
    public static void hcmGeneralEA() {
        
        Map<String, User> UserMap = null;
        Map<String, RecordType> recordTypeMap = null;
        PageReference prf = null; 
        Expense_Application__c ea4;
        Expense_Detail__c ed4;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.RecordTypeMap;
        
        employee.Grade__c = '7';
        upsert employee;
        Test.startTest();
        System.runAs(UserMap.get(userName)) {
            ea4 = new Expense_Application__c();
            ea4.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea4.RecordTypeId = recordTypeMap.get(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME + '_' + TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES).Id;
            insert ea4;
            ed4 = new Expense_Detail__c();
            ed4.Expense_Application__c = ea4.Id;
            ed4.Status__c = TEConstant.STATUS_PENDING_HCM_APPROVAL ;
            ed4.Amount__c = 1;
            ed4.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed4;
        }
        System.runAs(UserMap.get('actapr1')){
            System.assertNotEquals(ea4.id, null); 
            Test.setCurrentPage(Page.TEExpenseApplicationHCMApproveBatchVFP);
            ApexPages.Standardcontroller sc4 = new ApexPages.Standardcontroller(ea4);
            ApexPages.currentPage().getParameters().put('id', ea4.Id );
            TEExpenseApplicationHCMApproveBatchCtrl ctrl4 = new TEExpenseApplicationHCMApproveBatchCtrl(sc4);
    
            prf = ctrl4.ApproveAllExpenseApplication();
            System.assertNotEquals(prf, null);
        }
        Test.stopTest();
    }
}