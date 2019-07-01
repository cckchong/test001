@isTest 
public class TestTECashAdvanceRejectCtrl{
    
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
    //Scenario 1: cannot be rejected (single)
    public static void cannotBeRejected() {
        preparation(false);
        PageReference prf = null;        
        Travel_Application__c ta = new Travel_Application__c();
        insert ta;
        Cash_Advance__c ca = new Cash_Advance__c();
        ca.Travel_Application__c = ta.Id;
        ca.Currency__c = TEPreparation.currencyMap.get('HKD').id;
        insert ca;
        Test.setCurrentPage(Page.TECashAdvanceRejectSingleVFP);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ca);
        ApexPages.currentPage().getParameters().put('id', ca.Id );
        TECashAdvanceRejectCtrl ctrl = new TECashAdvanceRejectCtrl(sc);

        prf = ctrl.reject();
        system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: open, can be rejected (single)
    public static void RejectOpenCA () {
        Map<String, User> UserMap = null;
        Map<String, Expense_Policy__c> ExpensePolicyMap;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        ExpensePolicyMap = TEPreparation.ExpensePolicyMap;
        
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
            for(Expense_Policy__c reader : ExpensePolicyMap.values()){
                if(reader.id == employee.Expense_Policy__c){
                    ca2.Tech_Expense_Policy_Name__c = reader.Name;    
                }
            }
            insert ca2;
            Test.setCurrentPage(Page.TECashAdvanceRejectSingleVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ca2);
            ApexPages.currentPage().getParameters().put('id', ca2.Id );
            TECashAdvanceRejectCtrl ctrl2 = new TECashAdvanceRejectCtrl(sc2);
    
            prf = ctrl2.reject();
            Cash_Advance__c resultCA =  [SELECT Id, Status__c
                    FROM Cash_Advance__c where Id = :ca2.Id  ];
            system.assertEquals(TEConstant.STATUS_REJECT, resultCA.status__c); 

         Test.stopTest();
        }
    }
     
   @isTest 
   //Scenario 3: open, can be rejected (set)
    public static void rejectOpenSetCA () {
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
            for(Expense_Policy__c reader : ExpensePolicyMap.values()){
                if(reader.id == employee.Expense_Policy__c){
                    ca3.Tech_Expense_Policy_Name__c = reader.Name;    
                }
            }
            insert ca3;
            
            List<Cash_Advance__c> cashList = new List<Cash_Advance__c>();
            cashList.add(ca3);
            Test.setCurrentPage(Page.TECashAdvanceRejectBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TECashAdvanceRejectCtrl ctrl3 = new TECashAdvanceRejectCtrl(stdSetController);
            prf = ctrl3.reject();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TECashAdvanceRejectCtrl(stdSetController);
            prf = ctrl3.reject();
            Cash_Advance__c resultCA =  [SELECT Id, Status__c, Allow_Cancel__c, Travel_Application__r.Mine__c 
                    FROM Cash_Advance__c where Id = :ca3.Id  ];
            system.assertEquals(TEConstant.STATUS_REJECT, resultCA.status__c); 

         Test.stopTest();
        }
        
    }
}