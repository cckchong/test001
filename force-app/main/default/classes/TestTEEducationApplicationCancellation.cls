@isTest 
public class TestTEEducationApplicationCancellation{
    
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
    //Scenario 1: cannot be cancelled
    public static void cannotBeCancelled() {
        PageReference prf = null;  
        Map<String, User> UserMap = null;  
        
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        Test.startTest();  
            Education_Application__c ta = new Education_Application__c(
                On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id,
                Education__c = TEPreparation.generateRandomString(5),
                Start_Date__c = System.Today().adddays(5),
                End_Date__c = System.Today().adddays(15),
                Tuition_Fee__c = 1
            );
            
            insert ta;
            Test.setCurrentPage(Page.TEEducationApplicationCancellationVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
            ApexPages.currentPage().getParameters().put('id', ta.Id );
            TEEducationApplicationCancellationCtrl ctrl = new TEEducationApplicationCancellationCtrl(sc);
    
            prf = ctrl.cancel();
            system.assertNotEquals(null,prf); 
        Test.stopTest();
    }
    
    @isTest 
    //Scenario 2: approved, can be cancelled
    public static void CancelApprovedEA () {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        employee.user__c = UserInfo.getUserId();
        upsert employee;
   
        Test.startTest();  
            Education_Application__c ta2 = new Education_Application__c(
                On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id,
                Apply_Date__c = System.Today(),
                Program_Course_Title__c = TEPreparation.generateRandomString(5),
                Course_URL__c = TEPreparation.generateRandomString(5),
                Couse_Type__c = 'd',
                Currency__c = TEPreparation.currencyMap.get('HKD').id,
                Tuition_Fee_Recommended_Currency__c = TEPreparation.currencyMap.get('HKD').id,
                Degree_Course_Title__c = TEPreparation.generateRandomString(5),
                Education__c = TEPreparation.generateRandomString(5),
                Start_Date__c = System.Today().adddays(5),
                End_Date__c = System.Today().adddays(15),
                Length_of_Program_Year__c = 1,
                Payment_Method__c = 'a',
                Reason_of_Studying__c = TEPreparation.generateRandomString(5),
                Relevancy_to_work__c = TEPreparation.generateRandomString(5),
                Reliability_of_Course_Institute__c = TEPreparation.generateRandomString(5),
                Remarks__c = TEPreparation.generateRandomString(5),
                Status__c = TEConstant.STATUS_APPROVED,
                Tech_Applicant__c = UserMap.get(userName).id,
                Tuition_Fee__c = 100,
                Tuition_Fee_Recommended__c = 100
            );
            insert ta2;
            Test.setCurrentPage(Page.TEEducationApplicationCancellationVFP);
            ApexPages.currentPage().getParameters().put('id', ta2.Id );
            ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(ta2);
            TEEducationApplicationCancellationCtrl ctrl2 = new TEEducationApplicationCancellationCtrl(sc2);
            
            ctrl2.cancel();
            Education_Application__c ta =  [SELECT Id, Status__c
                    FROM Education_Application__c where Id = :ta2.Id  ];
            system.assertEquals(ta.status__c, TEConstant.STATUS_CANCELLED); 
         Test.stopTest();
         
    }
    
   @isTest 
   //Scenario 3: approved, can be cancelled (set)
    public static void rejectOpenSetCA () {
        Map<String, User> UserMap = null;        
        PageReference prf = null;
        
        preparation(false);
        UserMap = TEPreparation.UserMap;
        employee.user__c = UserInfo.getUserId();
        upsert employee;
   
   
        Test.startTest();  
            Education_Application__c ta3 = new Education_Application__c(
                On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id,
                Apply_Date__c = System.Today(),
                Program_Course_Title__c = TEPreparation.generateRandomString(5),
                Course_URL__c = TEPreparation.generateRandomString(5),
                Couse_Type__c = 'd',
                Currency__c = TEPreparation.currencyMap.get('HKD').id,
                Tuition_Fee_Recommended_Currency__c = TEPreparation.currencyMap.get('HKD').id,
                Degree_Course_Title__c = TEPreparation.generateRandomString(5),
                Education__c = TEPreparation.generateRandomString(5),
                Start_Date__c = System.Today().adddays(5),
                End_Date__c = System.Today().adddays(15),
                Length_of_Program_Year__c = 1,
                Payment_Method__c = 'a',
                Reason_of_Studying__c = TEPreparation.generateRandomString(5),
                Relevancy_to_work__c = TEPreparation.generateRandomString(5),
                Reliability_of_Course_Institute__c = TEPreparation.generateRandomString(5),
                Remarks__c = TEPreparation.generateRandomString(5),
                Status__c = TEConstant.STATUS_APPROVED,
                Tech_Applicant__c = UserMap.get(userName).id,
                Tuition_Fee__c = 100,
                Tuition_Fee_Recommended__c = 100
            );
            insert ta3;
            
            List<Education_Application__c > recordList = new List<Education_Application__c >();
            recordList.add(ta3);
            Test.setCurrentPage(Page.TEEducationApplicationCancellationVFP);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(recordList);
            TEEducationApplicationCancellationCtrl ctrl3 = new TEEducationApplicationCancellationCtrl(stdSetController);
            prf = ctrl3.cancel();
            
            stdSetController.setSelected(recordList);
            ctrl3 = new TEEducationApplicationCancellationCtrl(stdSetController);
            prf = ctrl3.cancel();
            Education_Application__c ta =  [SELECT Id, Status__c
                    FROM Education_Application__c where Id = :ta3.Id  ];
            system.assertEquals(ta.status__c, TEConstant.STATUS_CANCELLED); 

         Test.stopTest();
    }
}