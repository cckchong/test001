@isTest 
public class TestTETravelApplicationViewBudgetCtrl{
    
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
    //Scenario 1: no expense policy
    public static void failTest() {
        Map<String, User> UserMap = null;   
        Map<String, RecordType> recordTypeMap = null;     
        PageReference prf = null;
        String budget;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.RecordTypeMap;
        Test.startTest(); 
        System.runAs(UserMap.get('actapr1')){   
            Travel_Application__c ta = new Travel_Application__c();
            insert ta;
    
            Test.setCurrentPage(Page.TETravelApplicationViewBudgetVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta );
            ApexPages.currentPage().getParameters().put('id', ta.Id );
            TETravelApplicationViewBudgetCtrl ctrl = new TETravelApplicationViewBudgetCtrl(sc);
    
            budget = ctrl.budgetMsg;
            prf = ctrl.clear();
            system.assertNotEquals(null,prf); 
        }
        Test.stopTest();
        
    }
    
    @isTest 
    //Scenario 1: has expense policy
    public static void successTest() {
        Map<String, User> UserMap = null;   
        Map<String, RecordType> recordTypeMap = null;     
        PageReference prf = null;
        String budget;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.RecordTypeMap;
        Test.startTest(); 
        Travel_Application__c ta2;
        
        System.runAs(UserMap.get(userName)){   
            ta2 = new Travel_Application__c();
            ta2.Status__c = TEConstant.STATUS_CONFIRMED;
            ta2.Selected_Passport__c = employee.passport_type_1__c;
            ta2.On_Behalf_of__c = EmployeeAdministrator.get(userName).id;       
            insert ta2;
        }
        
        System.runAs(UserMap.get('actapr1')){ 
            Test.setCurrentPage(Page.TETravelApplicationViewBudgetVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta2 );
            ApexPages.currentPage().getParameters().put('id', ta2.Id );
            TETravelApplicationViewBudgetCtrl ctrl = new TETravelApplicationViewBudgetCtrl(sc);
    
            budget = ctrl.budgetMsg;
            //prf = ctrl.clear();
            system.assertNotEquals(null,budget); 
        }
        Test.stopTest();
        
    }
  
   //@isTest 
   //Scenario 3: PA, can be approved(set)
    public static void approveSetED () {
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
            ed3.Status__c = TEConstant.STATUS_PENDING_APPROVAL;
            ed3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ed3.Current_Approver__c = String.Valueof(UserInfo.getUserId()).left(15);
            ed3.Amount__c = 1;
            ed3.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed3;
            List<Expense_Detail__c> cashList = new List<Expense_Detail__c>();
            cashList.add(ed3);
            Test.setCurrentPage(Page.TEExpenseDetailApproveBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseDetailApproveBatchCtrl ctrl3 = new TEExpenseDetailApproveBatchCtrl(stdSetController);
            prf = ctrl3.approveAllexpenseDetail();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseDetailApproveBatchCtrl(stdSetController);
            prf = ctrl3.approveAllexpenseDetail();
            Expense_Detail__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Detail__c where Id = :ed3.Id];
            system.assertEquals(TEConstant.STATUS_PENDING_FIN_Confirmation, resultCA.status__c); 

         Test.stopTest();
        }
    }
}