@isTest 
public class TestTETravelApplicationCancellation{
    
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
        PageReference prf = null;        
        Travel_Application__c ta = new Travel_Application__c();
        insert ta;
        Test.setCurrentPage(Page.TETravelApplicationCancellationSingleVFP);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
        ApexPages.currentPage().getParameters().put('id', ta.Id );
        TETravelApplicationCancellationCtrl ctrl = new TETravelApplicationCancellationCtrl(sc);
        prf = ctrl.clear();
        system.assertNotEquals(null,prf);
        
        Test.setCurrentPage(Page.TETravelApplicationCancellationSingleVFP);
        ApexPages.currentPage().getParameters().put('id', ta.Id );
        ctrl = new TETravelApplicationCancellationCtrl(sc);
        prf = ctrl.cancel();
        system.assertNotEquals(null,prf); 
    }
    
    
    @isTest 
    //Scenario 2: confirmed, can be cancelled
    public static void CancelledconfirmedTA () {
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        PageReference prf = null;
        
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        
        System.runAs(UserMap.get(userName)){     
        Test.startTest();  
            Travel_Application__c ta2 = new Travel_Application__c();
            ta2.Status__c = TEConstant.STATUS_CONFIRMED;
            ta2.Selected_Passport__c = employee.passport_type_1__c;
            ta2.On_Behalf_of__c = EmployeeAdministrator.get(userName).id;            
            Travel_Detail__c td2 = new Travel_Detail__c();
            insert ta2;
            td2.Travel_Application__c = ta2.Id;
            td2.Preferred_Departure_dt__c = System.Today();
            td2.Preferred_Return_dt__c = System.Today();
            insert td2;
            Test.setCurrentPage(Page.TETravelApplicationCancellationSingleVFP);
            ApexPages.currentPage().getParameters().put('id', ta2.Id );
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ta2);
            TETravelApplicationCancellationCtrl ctrl2 = new TETravelApplicationCancellationCtrl(sc2);
            
            ctrl2.cancel();
            Travel_Application__c  ta =  [SELECT    Id, Status__c, allow_cancel__c, recordTypeId, Mine__c
                    FROM Travel_Application__c where Id = :ta2.Id  ];
            system.assertEquals(ta.status__c, TEConstant.STATUS_CANCELLED); 
         Test.stopTest();
        }
         
    }
    
   @isTest 
   //Scenario 3: pending, can be recalled
    public static void RecallPendingTA () {
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        PageReference prf = null;
        
        preparation(false);
        UserMap = TEPreparation.UserMap;
        recordTypeMap = TEPreparation.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        
        System.runAs(UserMap.get(userName)){       
            Test.startTest();
            Travel_Application__c ta2 = new Travel_Application__c();
            ta2.Status__c = TEConstant.STATUS_PENDING;
            ta2.Selected_Passport__c = employee.passport_type_1__c;
            ta2.On_Behalf_of__c = EmployeeAdministrator.get(userName).id;
            
            insert ta2; 
            Test.setCurrentPage(Page.TETravelApplicationRecallSingleVFP);
            ApexPages.currentPage().getParameters().put('id', ta2.Id );
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ta2);
            TETravelApplicationCancellationCtrl ctrl2 = new TETravelApplicationCancellationCtrl(sc2);
            
            ctrl2.recall();
            Travel_Application__c  ta =  [SELECT    Id, Status__c, allow_cancel__c, recordTypeId, Mine__c
                    FROM Travel_Application__c where Id = :ta2.Id  ];
            system.assertEquals(ta.status__c, TEConstant.STATUS_NOT_SUBMITTED ); 
            Test.stopTest();
        }
    }
    
    @isTest 
   //Scenario 4: draft, cannot be recalled
    public static void RecallDraftTA () {
        PageReference prf = null;        
        Travel_Application__c ta3 = new Travel_Application__c();
        insert ta3;
        Test.setCurrentPage(Page.TETravelApplicationRecallSingleVFP);
        ApexPages.Standardcontroller sc3 = new ApexPages.Standardcontroller(ta3);
        ApexPages.currentPage().getParameters().put('id', ta3.Id );
        TETravelApplicationCancellationCtrl ctrl3 = new TETravelApplicationCancellationCtrl(sc3);
        
        prf = ctrl3.recall();
        system.assertNotEquals(null,prf); 
    }
}