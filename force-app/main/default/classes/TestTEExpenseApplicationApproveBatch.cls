@isTest 
public class TestTEExpenseApplicationApproveBatch{
    
    Public Static TestTEPreparation TEPreparation; 
    Public static employee__c employee;
    Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    Public static String userName = 'user1';
    Public static String approverUserName = 'actapr1';
    
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
            Test.setCurrentPage(Page.TEExpenseApplicationApproveBatchVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
            ApexPages.currentPage().getParameters().put('id', ea.Id );
            TEExpenseApplicationApproveBatchCtrl ctrl = new TEExpenseApplicationApproveBatchCtrl(sc);
            prf = ctrl.approveAllexpenseApplication();
            system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: PA, can be approved (single)
    public static void approveEA() {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;

        System.runAs(UserMap.get(userName)){
            Expense_Application__c ea2 = new Expense_Application__c();
            ea2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea2.Status__c = TEConstant.STATUS_PENDING_APPROVAL;
            ea2.Current_Approver__c = String.Valueof(UserInfo.getUserId()).left(15);
            insert ea2;
            Test.setCurrentPage(Page.TEExpenseApplicationApproveBatchVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ea2);
            ApexPages.currentPage().getParameters().put('id', ea2.Id );
            system.assertNotEquals(ea2.Id, null); 
            TEExpenseApplicationApproveBatchCtrl ctrl2 = new TEExpenseApplicationApproveBatchCtrl(sc2);
    
            prf = ctrl2.approveAllexpenseApplication();
            for(Expense_Application__c reader: [SELECT Id,   Status__c, Current_Approver__c, I_Am_Approver__c FROM Expense_Application__c where Id = :ea2.Id]){
                System.assertEquals(True, reader.I_Am_Approver__c);
                System.assertEquals(TEConstant.STATUS_PENDING_FIN_Confirmation, reader.status__c);
            }
        }
    }
   
   @isTest 
   //Scenario 3: PA, can be approved (set)
    public static void approveSetEA () {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ea3 = new Expense_Application__c();
            ea3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea3.Status__c = TEConstant.STATUS_PENDING_APPROVAL;
            ea3.Current_Approver__c = String.Valueof(UserInfo.getUserId()).left(15);
            insert ea3;
            List<Expense_Application__c> cashList = new List<Expense_Application__c>();
            cashList.add(ea3);
            Test.setCurrentPage(Page.TEExpenseApplicationApproveBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseApplicationApproveBatchCtrl ctrl3 = new TEExpenseApplicationApproveBatchCtrl(stdSetController);
            prf = ctrl3.approveAllexpenseApplication();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseApplicationApproveBatchCtrl(stdSetController);
            prf = ctrl3.approveAllexpenseApplication();
            Expense_Application__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Application__c where Id = :ea3.Id];
            system.assertEquals(TEConstant.STATUS_PENDING_FIN_Confirmation, resultCA.status__c); 

         Test.stopTest();
        }
    }
    
    @isTest 
    //Scenario 4: general PA, can be approved (single)
    public static void approveGeneralEA() {
        Map<String, User> UserMap = null;    
        Map<String, RecordType> recordTypeMap = null;
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.RecordTypeMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ea4 = new Expense_Application__c();
            ea4.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea4.RecordTypeId = recordTypeMap.get(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME + '_' + TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES).Id;
            ea4.Current_Approver__c = String.Valueof(UserInfo.getUserId()).left(15);
            insert ea4;
            Expense_Detail__c ed4 = new Expense_Detail__c();
            ed4.Expense_Application__c = ea4.Id;
            ed4.Status__c = TEConstant.STATUS_PENDING_APPROVAL;
            ed4.Current_Approver__c = String.Valueof(UserInfo.getUserId()).left(15);
            ed4.Amount__c = 1;
            ed4.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed4;
            Test.setCurrentPage(Page.TEExpenseApplicationApproveBatchVFP);
            ApexPages.Standardcontroller sc4 = new ApexPages.Standardcontroller(ea4);
            ApexPages.currentPage().getParameters().put('id', ea4.Id );
            TEExpenseApplicationApproveBatchCtrl ctrl4 = new TEExpenseApplicationApproveBatchCtrl(sc4);
    
            prf = ctrl4.approveAllexpenseApplication();
            Expense_Detail__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Detail__c where Id = :ed4.Id  ];
            system.assertNotEquals(null,prf); 
         Test.stopTest();
        }
    }
}