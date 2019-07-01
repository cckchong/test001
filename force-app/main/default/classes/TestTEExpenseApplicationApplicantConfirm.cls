@isTest 
public class TestTEExpenseApplicationApplicantConfirm{
    
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
    public static void cannotBeConfirmed() {
        PageReference prf = null;        
        Map<String, User> UserMap = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
            Expense_Application__c ea = new Expense_Application__c();
            ea.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            insert ea;
            Test.setCurrentPage(Page.TEExpenseAppApplicantConfirmBatchVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
            ApexPages.currentPage().getParameters().put('id', ea.Id );
            TEExpenseApplicationApplicantConfirmCtrl ctrl = new TEExpenseApplicationApplicantConfirmCtrl(sc);
            prf = ctrl.applicantConfirmAllexpenseApplication();
            system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: PAC, can be confirmed (single)
    public static void ConfirmEA() {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ea2 = new Expense_Application__c();
            ea2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea2.Status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
            insert ea2;
            Test.setCurrentPage(Page.TEExpenseAppApplicantConfirmBatchVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ea2);
            ApexPages.currentPage().getParameters().put('id', ea2.Id );
            TEExpenseApplicationApplicantConfirmCtrl ctrl2 = new TEExpenseApplicationApplicantConfirmCtrl(sc2);
    
            prf = ctrl2.applicantConfirmAllexpenseApplication();
            Expense_Application__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Application__c where Id = :ea2.Id  ];
            system.assertEquals(TEConstant.STATUS_CONFIRMED, resultCA.status__c); 

         Test.stopTest();
        }
    }
  
   @isTest 
   //Scenario 3: open, can be rejected (set)
    public static void rejectOpenSetCA () {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ea3 = new Expense_Application__c();
            ea3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea3.Status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
            insert ea3;
            List<Expense_Application__c> cashList = new List<Expense_Application__c>();
            cashList.add(ea3);
            Test.setCurrentPage(Page.TEExpenseAppApplicantConfirmBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseApplicationApplicantConfirmCtrl ctrl3 = new TEExpenseApplicationApplicantConfirmCtrl(stdSetController);
            prf = ctrl3.applicantConfirmAllexpenseApplication();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseApplicationApplicantConfirmCtrl(stdSetController);
            prf = ctrl3.applicantConfirmAllexpenseApplication();
            Expense_Application__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Application__c where Id = :ea3.Id  ];
            system.assertEquals(TEConstant.STATUS_CONFIRMED, resultCA.status__c); 

         Test.stopTest();
        }
    }
    
    @isTest 
    //Scenario 4: general PAC, can be confirmed (single)
    public static void ConfirmGeneralEA() {
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
            ed4.Status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
            ed4.Amount__c = 1;
            ed4.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed4;
            Test.setCurrentPage(Page.TEExpenseAppApplicantConfirmBatchVFP);
            ApexPages.Standardcontroller sc4 = new ApexPages.Standardcontroller(ea4);
            ApexPages.currentPage().getParameters().put('id', ea4.Id );
            TEExpenseApplicationApplicantConfirmCtrl ctrl4 = new TEExpenseApplicationApplicantConfirmCtrl(sc4);
    
            prf = ctrl4.applicantConfirmAllexpenseApplication();
            Expense_Detail__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Detail__c where Id = :ed4.Id  ];
            system.assertNotEquals(null,prf); 
         Test.stopTest();
        }
    }
}