@isTest 
public class TestTEExpenseAppClosedCtrl{
    
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
    //Scenario 1: cannot be closed (single)
    public static void cannotBeClosed() {
        PageReference prf = null;        
        Map<String, User> UserMap = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
            Expense_Application__c ea = new Expense_Application__c();
            ea.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            insert ea;
            Test.setCurrentPage(Page.TEExpenseAppClosedSingleVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
            ApexPages.currentPage().getParameters().put('id', ea.Id );
            TEExpenseAppClosedCtrl ctrl = new TEExpenseAppClosedCtrl(sc);
            prf = ctrl.close();
            system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: CON, can be closed (single)
    public static void closeEA() {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ea2 = new Expense_Application__c();
            ea2.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea2.Status__c = TEConstant.STATUS_CONFIRMED;
            insert ea2;
            Test.setCurrentPage(Page.TEExpenseAppClosedSingleVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ea2);
            ApexPages.currentPage().getParameters().put('id', ea2.Id );
            TEExpenseAppClosedCtrl ctrl2 = new TEExpenseAppClosedCtrl(sc2);
    
            prf = ctrl2.close();
            Expense_Application__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Application__c where Id = :ea2.Id  ];
            system.assertEquals(TEConstant.STATUS_CLOSED, resultCA.status__c); 

         Test.stopTest();
        }
    }
  
   @isTest 
   //Scenario 3: CON, can be closed (set)
    public static void closeSetCA () {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ea3 = new Expense_Application__c();
            ea3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea3.Status__c = TEConstant.STATUS_CONFIRMED;
            insert ea3;
            List<Expense_Application__c> cashList = new List<Expense_Application__c>();
            cashList.add(ea3);
            Test.setCurrentPage(Page.TEExpenseAppClosedSingleVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseAppClosedCtrl ctrl3 = new TEExpenseAppClosedCtrl(stdSetController);
            prf = ctrl3.close();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseAppClosedCtrl(stdSetController);
            prf = ctrl3.close();
            Expense_Application__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Application__c where Id = :ea3.Id  ];
            system.assertEquals(TEConstant.STATUS_CLOSED, resultCA.status__c); 

         Test.stopTest();
        }
    }
    
    @isTest 
    //Scenario 4: general PAC, can be closed (single)
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
            ed4.Status__c = TEConstant.STATUS_CONFIRMED;
            ed4.Amount__c = 1;
            insert ed4;
            Test.setCurrentPage(Page.TEExpenseAppClosedSingleVFP);
            ApexPages.Standardcontroller sc4 = new ApexPages.Standardcontroller(ea4);
            ApexPages.currentPage().getParameters().put('id', ea4.Id );
            TEExpenseAppClosedCtrl ctrl4 = new TEExpenseAppClosedCtrl(sc4);
    
            prf = ctrl4.close();
            Expense_Detail__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Detail__c where Id = :ed4.Id  ];

         Test.stopTest();
        }
    }
}