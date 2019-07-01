@isTest 
public class TestTECashAdvancePaidOutCtrl{
    
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
    //Scenario 1: cannot be paid out (single)
    public static void cannotBePaid() {
        preparation(false);
        PageReference prf = null;        
        Travel_Application__c ta = new Travel_Application__c();
        insert ta;
        Cash_Advance__c ca = new Cash_Advance__c();
        ca.Travel_Application__c = ta.Id;
        ca.Currency__c = TEPreparation.currencyMap.get('HKD').id;
        insert ca;
        Test.setCurrentPage(Page.TECashAdvancePaidOutSingleVFP);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ca);
        ApexPages.currentPage().getParameters().put('id', ca.Id );
        TECashAdvancePaidOutCtrl ctrl = new TECashAdvancePaidOutCtrl(sc);

        prf = ctrl.paidOut();
        system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: open, can be paid out (single)
    public static void payOpenCA () {
        Map<String, User> UserMap = null;
        Map<String, Expense_Policy__c> ExpensePolicyMap;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        ExpensePolicyMap = TEPreparation.ExpensePolicyMap;
        String expensePolicyName = '';
        for(employee__c e : [select id , Name , Expense_policy__c, Expense_policy__r.Name    from employee__c where id = :employee.id]){
            expensePolicyName = e.Expense_policy__r.Name ;
        } 
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Travel_Application__c ta2 = new Travel_Application__c();
            ta2.on_behalf_of__c = EmployeeAdministrator.get(userName).id;
            ta2.Status__c = TEConstant.STATUS_CONFIRMED;     
            Cash_Advance__c ca2 = new Cash_Advance__c();
            insert ta2;
            ca2.Travel_Application__c = ta2.Id;
            ca2.Status__c = TEConstant.STATUS_OPEN;
            ca2.Currency__c = TEPreparation.currencyMap.get('HKD').id;
            ca2.Tech_Expense_Policy_Name__c = expensePolicyName;
            
            insert ca2;
            ca2.Tech_Expense_Policy_Name__c = expensePolicyName;
            upsert ca2;
            Test.setCurrentPage(Page.TECashAdvancePaidOutSingleVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ca2);
            ApexPages.currentPage().getParameters().put('id', ca2.Id );
            TECashAdvancePaidOutCtrl ctrl2 = new TECashAdvancePaidOutCtrl(sc2);
            
            prf = ctrl2.paidOut();
            Cash_Advance__c resultCA =  [SELECT Id, Status__c, Allow_Cancel__c, Travel_Application__r.Mine__c 
                    FROM Cash_Advance__c where Id = :ca2.Id  ];
            system.assertEquals(TEConstant.STATUS_PAID_OUT, resultCA.status__c); 

         Test.stopTest();
        }
    }
     
   @isTest 
   //Scenario 3: open, can be paid out (set)
    public static void payOpenSetCA () {
        Map<String, User> UserMap = null;  
        Map<String, Expense_Policy__c> ExpensePolicyMap;       
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        ExpensePolicyMap = TEPreparation.ExpensePolicyMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Travel_Application__c ta3 = new Travel_Application__c();
            ta3.on_behalf_of__c = EmployeeAdministrator.get(userName).id;
            ta3.Status__c = TEConstant.STATUS_CONFIRMED;    
            insert ta3;
            Cash_Advance__c ca3 = new Cash_Advance__c();
            ca3.Travel_Application__c = ta3.Id;
            ca3.Status__c = TEConstant.STATUS_OPEN;
            ca3.Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ca3;
            
            List<Cash_Advance__c> cashList = new List<Cash_Advance__c>();
            cashList.add(ca3);
            Test.setCurrentPage(Page.TECashAdvancePaidOutBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TECashAdvancePaidOutCtrl ctrl3 = new TECashAdvancePaidOutCtrl(stdSetController);
            prf = ctrl3.paidOut();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TECashAdvancePaidOutCtrl(stdSetController);
            prf = ctrl3.paidOut();
            Cash_Advance__c resultCA =  [SELECT Id, Status__c, Allow_Cancel__c, Travel_Application__r.Mine__c 
                    FROM Cash_Advance__c where Id = :ca3.Id  ];
            system.assertEquals(TEConstant.STATUS_PAID_OUT, resultCA.status__c); 

         Test.stopTest();
        }
        
    }
}