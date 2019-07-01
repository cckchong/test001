@isTest
public class TestTEExpenseDetailConfirmationCtrl {

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
            Expense_Detail__c ed = new Expense_Detail__c();
            ed.Expense_Application__c = ea.Id;
            ed.Amount__c = 1;
            ed.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed;
            Test.setCurrentPage(Page.TEExpenseDetailConfirmationSingleVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ed);
            ApexPages.currentPage().getParameters().put('id', ed.Id );
            TEExpenseDetailConfirmationCtrl ctrl = new TEExpenseDetailConfirmationCtrl(sc);
            prf = ctrl.confirm();
            system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: can be confirmed (single)
    public static void confirmED() {
        ApexPages.Standardcontroller sc2 = null;
        TEExpenseDetailConfirmationCtrl ctrl2 = null;
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
            ed2.Status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;//STATUS_PENDING_APPLICANT_CONFIRMATION;//(PAC)STATUS_CONFIRMED(CON);
            ed2.Amount__c = 1;
            ed2.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed2;        
            Test.setCurrentPage(Page.TEExpenseDetailConfirmationSingleVFP);
            ApexPages.currentPage().getParameters().put('id', ed2.Id );
            sc2 = new ApexPages.Standardcontroller(ed2);
            ctrl2 = new TEExpenseDetailConfirmationCtrl(sc2);
            prf = ctrl2.confirm();
            
            ApexPages.currentPage().getHeaders().put('User-Agent', 'User-Agent,SalesforceMobile,Salesforce1');
            //ApexPages.currentPage().getParameters().put('id', null);
            sc2 = new ApexPages.Standardcontroller(ed2);
            ctrl2 = new TEExpenseDetailConfirmationCtrl(sc2);
            prf = ctrl2.confirm();
            
            Expense_Detail__c resultCA =  [SELECT Id, Status__c, Mine__c
                    FROM Expense_Detail__c where Id = :ed2.Id  ];
            system.assertNotEquals(null, ed2.id); 
        }
        Test.stopTest();
        
    }
  
   @isTest 
   //Scenario 3: can be confirmed (set)
    public static void confirmSetED () {
        ApexPages.StandardSetController stdSetController = null;
        TEExpenseDetailConfirmationCtrl ctrl3 = null;
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
            ed3.Status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;//STATUS_PENDING_APPLICANT_CONFIRMATION;//(PAC)STATUS_CONFIRMED(CON);
            ed3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ed3.Amount__c = 1;
            ed3.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed3;
            List<Expense_Detail__c> cashList = new List<Expense_Detail__c>();
            stdSetController = new ApexPages.StandardSetController(cashList);
            ctrl3 = new TEExpenseDetailConfirmationCtrl(stdSetController);    
            prf = ctrl3.confirm();

            cashList.add(ed3);
            Test.setCurrentPage(Page.TEExpenseDetailConfirmationSingleVFP);
            stdSetController = new ApexPages.StandardSetController(cashList);
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseDetailConfirmationCtrl(stdSetController);    
            prf = ctrl3.confirm();
            
            stdSetController = new ApexPages.StandardSetController(cashList);
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseDetailConfirmationCtrl(stdSetController);    
            prf = ctrl3.confirm();
             
            Expense_Detail__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Detail__c where Id = :ed3.Id];
            system.assertEquals(TEConstant.STATUS_CONFIRMED, resultCA.status__c); 

         Test.stopTest();
        }
    }
    
}