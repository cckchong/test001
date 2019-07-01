@isTest 
public class TestTEExpenseApplicationFINConfirmBatc{
    
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
    //Scenario 1: cannot be confirmed (single)
    public static void cannotBeCon() {
        PageReference prf = null;        
        Map<String, User> UserMap = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
            Expense_Application__c ea = new Expense_Application__c();
            ea.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            insert ea;
            Test.setCurrentPage(Page.TEExpenseApplicationFINConfirmBatchVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
            ApexPages.currentPage().getParameters().put('id', ea.Id );
            TEExpenseApplicationFINConfirmBatchCtrl ctrl = new TEExpenseApplicationFINConfirmBatchCtrl(sc);
            prf = ctrl.confirmAllExpenseApplication();
            system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: PF, can be approved (single)
    public static void finApproveEA() {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ea2 = new Expense_Application__c();
            ea2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea2.Status__c = TEConstant.STATUS_PENDING_FIN_Confirmation;
            insert ea2;
            Test.setCurrentPage(Page.TEExpenseApplicationFINConfirmBatchVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ea2);
            ApexPages.currentPage().getParameters().put('id', ea2.Id );
            TEExpenseApplicationFINConfirmBatchCtrl ctrl2 = new TEExpenseApplicationFINConfirmBatchCtrl(sc2);
    
            prf = ctrl2.confirmAllExpenseApplication();
            Expense_Application__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Application__c where Id = :ea2.Id  ];
            system.assertEquals(TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION, resultCA.status__c); 

         Test.stopTest();
        }
    }
  
   @isTest 
   //Scenario 3: PF, can be approved (set)
    public static void finApproveSetCA () {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ea3 = new Expense_Application__c();
            ea3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea3.Status__c = TEConstant.STATUS_PENDING_FIN_Confirmation ;
            insert ea3;
            List<Expense_Application__c> cashList = new List<Expense_Application__c>();
            cashList.add(ea3);
            Test.setCurrentPage(Page.TEExpenseApplicationFINConfirmBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseApplicationFINConfirmBatchCtrl ctrl3 = new TEExpenseApplicationFINConfirmBatchCtrl(stdSetController);
            prf = ctrl3.confirmAllExpenseApplication();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseApplicationFINConfirmBatchCtrl(stdSetController);
            prf = ctrl3.confirmAllExpenseApplication();
            Expense_Application__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Application__c where Id = :ea3.Id  ];
            system.assertEquals(TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION, resultCA.status__c); 

         Test.stopTest();
        }
    }
    
    @isTest 
    //Scenario 4: general PF, can be approved (single)
    public static void closeGeneralEA() {
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
            insert ea4;
            Expense_Detail__c ed4 = new Expense_Detail__c();
            ed4.Expense_Application__c = ea4.Id;
            ed4.Status__c = TEConstant.STATUS_PENDING_FIN_Confirmation ;
            ed4.Amount__c = 1;
            ed4.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed4;
            Test.setCurrentPage(Page.TEExpenseApplicationFINConfirmBatchVFP);
            ApexPages.Standardcontroller sc4 = new ApexPages.Standardcontroller(ea4);
            ApexPages.currentPage().getParameters().put('id', ea4.Id );
            TEExpenseApplicationFINConfirmBatchCtrl ctrl4 = new TEExpenseApplicationFINConfirmBatchCtrl(sc4);
    
            prf = ctrl4.confirmAllExpenseApplication();
            Expense_Detail__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Detail__c where Id = :ed4.Id  ];
            system.assertNotEquals(null,prf); 
         Test.stopTest();
        }
    }
}