@isTest 
public class TestTEExpenseDetailHCMApproveBatchCtrl{
    
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
            Expense_Detail__c ed = new Expense_Detail__c();
            ed.Expense_Application__c = ea.Id;
            ed.Amount__c = 1;
            ed.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed;
            Test.setCurrentPage(Page.TEExpenseDetailHCMApproveBatchVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ed);
            ApexPages.currentPage().getParameters().put('id', ed.Id );
            TEExpenseDetailHCMApproveBatchCtrl ctrl = new TEExpenseDetailHCMApproveBatchCtrl(sc);
            prf = ctrl.approveAllexpenseDetail();
            system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: PA, can be approved (single)
    public static void approveED() {
        Map<String, User> UserMap = null;   
        Map<String, RecordType> recordTypeMap = null;     
        PageReference prf = null;
        Expense_Detail__c ed2;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.RecordTypeMap;
        
        employee.Grade__c = '7';
        upsert employee;
        Test.startTest();
        System.runAs(UserMap.get(userName)) {
            Expense_Application__c ea2 = new Expense_Application__c();
            ea2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea2.RecordTypeId = recordTypeMap.get(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME + '_' + TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES).Id;
            insert ea2;
            ed2 = new Expense_Detail__c();
            ed2.Expense_Application__c = ea2.Id;
            ed2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ed2.Status__c = TEConstant.STATUS_PENDING_HCM_APPROVAL;
            ed2.Current_Approver__c = String.Valueof(UserInfo.getUserId()).left(15);
            ed2.Amount__c = 1;
            ed2.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed2;
        }
        System.runAs(UserMap.get('actapr1')){
            System.assertNotEquals(ed2.id, null); 
            Test.setCurrentPage(Page.TEExpenseDetailHCMApproveBatchVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ed2);
            ApexPages.currentPage().getParameters().put('id', ed2.Id );
            TEExpenseDetailHCMApproveBatchCtrl ctrl2 = new TEExpenseDetailHCMApproveBatchCtrl(sc2);
    
            prf = ctrl2.approveAllexpenseDetail();
            System.assertNotEquals(prf, null);
            for(Expense_Detail__c reader : [SELECT Id, Status__c, Mine__c FROM Expense_Detail__c where Id = :ed2.Id ]){
                System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING_FIN_Confirmation);
            }
        }
        Test.stopTest();
    }
  
   @isTest 
   //Scenario 3: PA, can be approved(set)
    public static void approveSetED () {
                
        Map<String, User> UserMap = null;   
        Map<String, RecordType> recordTypeMap = null;     
        PageReference prf = null;
        Expense_Detail__c ed3;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.RecordTypeMap;
        
        employee.Grade__c = '7';
        upsert employee;
        Test.startTest();
        System.runAs(UserMap.get(userName)) {
            Expense_Application__c ea3 = new Expense_Application__c();
            ea3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea3.RecordTypeId = recordTypeMap.get(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME + '_' + TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES).Id;
            insert ea3;
            ed3 = new Expense_Detail__c();
            ed3.Expense_Application__c = ea3.Id;
            ed3.Status__c = TEConstant.STATUS_PENDING_HCM_APPROVAL;
            ed3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ed3.Current_Approver__c = String.Valueof(UserInfo.getUserId()).left(15);
            ed3.Amount__c = 1;
            ed3.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed3;
        }
        System.runAs(UserMap.get('actapr1')){
            
            List<Expense_Detail__c> cashList = new List<Expense_Detail__c>();
            cashList.add(ed3);
            Test.setCurrentPage(Page.TEExpenseDetailHCMApproveBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseDetailHCMApproveBatchCtrl ctrl3 = new TEExpenseDetailHCMApproveBatchCtrl(stdSetController);
            prf = ctrl3.approveAllexpenseDetail();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseDetailHCMApproveBatchCtrl(stdSetController);
            prf = ctrl3.approveAllexpenseDetail();
            system.assertNotEquals(null,prf);
        }
        Test.stopTest();
    }
}