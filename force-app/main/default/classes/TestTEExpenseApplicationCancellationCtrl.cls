@isTest 
public class TestTEExpenseApplicationCancellationCtrl{
    
    Public Static TestTEPreparation TEPreparation; 
    Public static Map<String, Travel_Location__c> travelLocationMap;
    Public static employee__c employee;
    Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    Public static String userName = 'user1';
    
    
    Public static void preparation(Boolean isSeeAllData){
        TEPreparation = new TestTEPreparation (isSeeAllData);
        TEPreparation.Preparation(isSeeAllData);
        travelLocationMap = TEPreparation.travelLocationMap;
        employee = TEPreparation.getEmployeefromOriginalEmployeeID(userName);
        EmployeeAdministrator = TEPreparation.EmployeeAdministratorMap;
    }
    
    @isTest 
    //Scenario 1: cannot be cancelled
    public static void cannotBeCancelled() {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){ 
            Expense_Application__c ta = new Expense_Application__c();
            ta.Status__c = TEConstant.STATUS_DRAFT;
            ta.On_Behalf_of__c = EmployeeAdministrator.get(userName).id;  
            insert ta;
            Test.setCurrentPage(Page.TEExpenseAppCancellationSingleVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
            ApexPages.currentPage().getParameters().put('id', ta.Id );
            TEExpenseApplicationCancellationCtrl ctrl = new TEExpenseApplicationCancellationCtrl(sc);
            
            prf = ctrl.cancel();
            system.assertNotEquals(null,prf); 
        }
    }
    
    
    @isTest 
    //Scenario 2: confirmed, can be cancelled
    public static void CancelledconfirmedTA () {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Expense_Application__c ta2 = new Expense_Application__c();
            ta2.Status__c = TEConstant.STATUS_CONFIRMED;
            ta2.On_Behalf_of__c = EmployeeAdministrator.get(userName).id;  
            insert ta2;
            Test.setCurrentPage(Page.TEExpenseAppCancellationSingleVFP);
            ApexPages.currentPage().getParameters().put('id', ta2.Id );
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ta2);
            TEExpenseApplicationCancellationCtrl ctrl2 = new TEExpenseApplicationCancellationCtrl(sc2);
            
            ctrl2.cancel();
            Expense_Application__c ta =  [SELECT Id, Status__c
                    FROM Expense_Application__c where Id = :ta2.Id  ];
            system.assertEquals(ta.status__c, TEConstant.STATUS_CANCELLED); 
         Test.stopTest();
        }
         
    }
    
    @isTest 
   //Scenario 3: confirmed, can be cancelled (set)
    public static void cancelSetEA () {
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
            Test.setCurrentPage(Page.TEExpenseAppCancellationSingleVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseApplicationCancellationCtrl ctrl3 = new TEExpenseApplicationCancellationCtrl(stdSetController);
            ctrl3.cancel();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseApplicationCancellationCtrl(stdSetController);
            ctrl3.cancel();
            Expense_Application__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Application__c where Id = :ea3.Id  ];
            system.assertEquals(TEConstant.STATUS_CANCELLED, resultCA.status__c); 

         Test.stopTest();
        }
    }
}