@isTest 
public class TestTEExpenseDetailSiteAdminApprove{
    
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
            Test.setCurrentPage(Page.TEExpenseDetailSiteApproveBatchVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ed);
            ApexPages.currentPage().getParameters().put('id', ed.Id );
            TEExpenseDetailSiteAdminApproveBatchCtrl ctrl = new TEExpenseDetailSiteAdminApproveBatchCtrl(sc);
            prf = ctrl.approveAllexpenseDetail();
            system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: PS, can be approved (single)
    public static void approveED() {
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
            ed2.Status__c = TEConstant.STATUS_PENDING_SITE_APPROVAL;
            ed2.Amount__c = 1;
            ed2.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed2;
            Test.setCurrentPage(Page.TEExpenseDetailSiteApproveBatchVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ed2);
            ApexPages.currentPage().getParameters().put('id', ed2.Id );
            TEExpenseDetailSiteAdminApproveBatchCtrl ctrl2 = new TEExpenseDetailSiteAdminApproveBatchCtrl(sc2);
    
            prf = ctrl2.approveAllexpenseDetail();
            Expense_Detail__c resultCA =  [SELECT Id, Status__c, Mine__c
                    FROM Expense_Detail__c where Id = :ed2.Id  ];
            system.assertEquals(TEConstant.STATUS_PENDING_FIN_Confirmation, resultCA.status__c); 
        }
        Test.stopTest();
        
    }
  
   @isTest 
   //Scenario 3: PS, can be approved(set)
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
            ed3.Status__c = TEConstant.STATUS_PENDING_SITE_APPROVAL;
            ed3.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ed3.Amount__c = 1;
            ed3.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed3;
            List<Expense_Detail__c> cashList = new List<Expense_Detail__c>();
            cashList.add(ed3);
            Test.setCurrentPage(Page.TEExpenseDetailSiteApproveBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TEExpenseDetailSiteAdminApproveBatchCtrl ctrl3 = new TEExpenseDetailSiteAdminApproveBatchCtrl(stdSetController);
            prf = ctrl3.approveAllexpenseDetail();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TEExpenseDetailSiteAdminApproveBatchCtrl(stdSetController);
            prf = ctrl3.approveAllexpenseDetail();
            Expense_Detail__c resultCA =  [SELECT Id, Status__c
                    FROM Expense_Detail__c where Id = :ed3.Id];
            system.assertEquals(TEConstant.STATUS_PENDING_FIN_Confirmation, resultCA.status__c); 

         Test.stopTest();
        }
    }
}