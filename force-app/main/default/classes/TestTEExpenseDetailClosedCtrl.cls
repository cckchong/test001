@isTest 
public class TestTEExpenseDetailClosedCtrl{
    
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
    //Scenario 1: cannot be Closed (single)
    public static void cannotBeClosed() {
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
            Test.setCurrentPage(Page.TEExpenseDetailClosedVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ed);
            ApexPages.currentPage().getParameters().put('id', ed.Id );
            TEExpenseDetailClosedCtrl ctrl = new TEExpenseDetailClosedCtrl(sc);
            prf = ctrl.close();
            system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: CON, can be closed (single)
    public static void closeED() {
        Map<String, User> UserMap = null;   
        Map<String, RecordType> recordTypeMap = null;     
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.RecordTypeMap;
        Test.startTest(); 
        System.runAs(UserMap.get(userName)){   
            Expense_Application__c ea2 = new Expense_Application__c();
            ea2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea2.RecordTypeId = recordTypeMap.get(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME + '_' + TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES).Id;
            insert ea2;
            Expense_Detail__c ed2 = new Expense_Detail__c();
            ed2.Expense_Application__c = ea2.Id;
            ed2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ed2.Status__c = TEConstant.STATUS_CONFIRMED;
            ed2.Amount__c = 1;
            ed2.expense_type__c = TEPreparation.ExpenseTypeMap.get('HKO - Health').id;
            ed2.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed2;
            Test.setCurrentPage(Page.TEExpenseDetailClosedVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ed2);
            ApexPages.currentPage().getParameters().put('id', ed2.Id );
            TEExpenseDetailClosedCtrl ctrl2 = new TEExpenseDetailClosedCtrl(sc2);
    
            prf = ctrl2.close();
            Expense_Detail__c resultCA =  [SELECT Id, Status__c, Mine__c
                    FROM Expense_Detail__c where Id = :ed2.Id  ];
            system.assertEquals(TEConstant.STATUS_CLOSED, resultCA.status__c); 
        }
        Test.stopTest();
        
    }
  
   @isTest 
   //Scenario 3: CON, can be closed (set)
    public static void closeSetED () {
        Map<String, User> UserMap = null; 
        Map<String, RecordType> recordTypeMap = null;       
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.RecordTypeMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ea3 = new Expense_Application__c();
            ea3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea3.RecordTypeId = recordTypeMap.get(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME + '_' + TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES).Id;
            insert ea3;
            Expense_Detail__c ed3 = new Expense_Detail__c();
            ed3.Expense_Application__c = ea3.Id;
            ed3.Status__c = TEConstant.STATUS_CONFIRMED;
            ed3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ed3.Amount__c = 1;
            ed3.expense_type__c = TEPreparation.ExpenseTypeMap.get('HKO - Health').id;
            ed3.receipt_Currency__c = TEPreparation.currencyMap.get('USD').id;
            insert ed3;
            List<Expense_Detail__c> cashList = new List<Expense_Detail__c>();
            cashList.add(ed3);
            Test.setCurrentPage(Page.TEExpenseDetailClosedVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseDetailClosedCtrl ctrl3 = new TEExpenseDetailClosedCtrl(stdSetController);
            prf = ctrl3.close();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseDetailClosedCtrl(stdSetController);
            prf = ctrl3.close();
            Expense_Detail__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Detail__c where Id = :ed3.Id];
            system.assertEquals(TEConstant.STATUS_CLOSED, resultCA.status__c); 

         Test.stopTest();
        }
    }
}