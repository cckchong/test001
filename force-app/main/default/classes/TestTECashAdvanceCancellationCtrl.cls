@isTest 
public class TestTECashAdvanceCancellationCtrl{
    
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
    //Scenario 1: cannot be cancelled (single)
    public static void cannotBeCancelled() {
        preparation(false);
        PageReference prf = null;        
        Travel_Application__c ta = new Travel_Application__c();
        insert ta;
        Cash_Advance__c ca = new Cash_Advance__c();
        ca.Travel_Application__c = ta.Id;
        ca.Currency__c = TEPreparation.currencyMap.get('HKD').id;
        insert ca;
        Test.setCurrentPage(Page.TECashAdvanceCancellationSingleVFP);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ca);
        ApexPages.currentPage().getParameters().put('id', ca.Id );
        TECashAdvanceCancellationCtrl ctrl = new TECashAdvanceCancellationCtrl(sc);

        prf = ctrl.cancel();
        system.assertNotEquals(null,prf); 
    }
    
    @isTest 
    //Scenario 2: open, can be cancelled (single)
    public static void CancelOpenCA () {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Travel_Application__c ta2 = new Travel_Application__c();
            ta2.Status__c = TEConstant.STATUS_CONFIRMED;
            ta2.Selected_Passport__c = employee.passport_type_1__c;
            ta2.On_Behalf_of__c = EmployeeAdministrator.get(userName).id;       
            Cash_Advance__c ca2 = new Cash_Advance__c();
            insert ta2;
            ca2.Travel_Application__c = ta2.Id;
            ca2.Status__c = TEConstant.STATUS_OPEN;
            ca2.Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ca2;
            Test.setCurrentPage(Page.TECashAdvanceCancellationSingleVFP);
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ca2);
            ApexPages.currentPage().getParameters().put('id', ca2.Id );
            TECashAdvanceCancellationCtrl ctrl2 = new TECashAdvanceCancellationCtrl(sc2);
    
            prf = ctrl2.cancel();
            Cash_Advance__c resultCA =  [SELECT Id, Status__c, Allow_Cancel__c, Travel_Application__r.Mine__c 
                    FROM Cash_Advance__c where Id = :ca2.Id  ];
            system.assertEquals(TEConstant.STATUS_CANCELLED, resultCA.status__c); 

         Test.stopTest();
        }
    }
     
   @isTest 
   //Scenario 3: open, can be cancelled (set)
    public static void CancelOpenSetCA () {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Travel_Application__c ta3 = new Travel_Application__c();
            ta3.Status__c = TEConstant.STATUS_CONFIRMED;
            ta3.Selected_Passport__c = employee.passport_type_1__c;
            ta3.On_Behalf_of__c = EmployeeAdministrator.get(userName).id;       
            insert ta3;
            Cash_Advance__c ca3 = new Cash_Advance__c();
            ca3.Travel_Application__c = ta3.Id;
            ca3.Status__c = TEConstant.STATUS_OPEN;
            ca3.Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ca3;
            
            List<Cash_Advance__c> cashList = new List<Cash_Advance__c>();
            cashList.add(ca3);
            Test.setCurrentPage(Page.TECashAdvanceCancellationBatchVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(cashList);
            TECashAdvanceCancellationCtrl ctrl3 = new TECashAdvanceCancellationCtrl(stdSetController);
            prf = ctrl3.cancel();
            
            stdSetController.setSelected(cashList);
            ctrl3 = new TECashAdvanceCancellationCtrl(stdSetController);
            prf = ctrl3.cancel();
            Cash_Advance__c resultCA =  [SELECT Id, Status__c, Allow_Cancel__c, Travel_Application__r.Mine__c 
                    FROM Cash_Advance__c where Id = :ca3.Id  ];
            system.assertEquals(TEConstant.STATUS_CANCELLED, resultCA.status__c); 

         Test.stopTest();
        }
        
    }
}