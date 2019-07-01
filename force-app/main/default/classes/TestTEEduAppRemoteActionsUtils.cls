@isTest 
public class TestTEEduAppRemoteActionsUtils{
//*
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
    //Scenario 1: cannot be recalled
    public static void cannotBeRecalled() {
        PageReference prf = null;  
        Map<String, User> UserMap = null; 
        String result; 
        
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        Test.startTest();  
            Education_Application__c ta = new Education_Application__c(
                On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id,
                Education__c = TEPreparation.generateRandomString(5),
                Start_Date__c = System.Today().adddays(5),
                End_Date__c = System.Today().adddays(15),
                Tuition_Fee__c = 1000
            );
            
            insert ta;
            TEEducationApplicationRemoteActionsUtils ctrl = new TEEducationApplicationRemoteActionsUtils(null);
            try{
                result = TEEducationApplicationRemoteActionsUtils.recallApprovalProcess(ta.Id);      
                system.assertNotEquals(null, result);
            }
            catch(Exception ex){
            }
        Test.stopTest();
    }
    
    @isTest 
    //Scenario 2: can be recalled
    public static void canBeRecalled() {
        String result; 
        
        Map<String, User> UserMap = null;
        PageReference prf = null; 
        preparation(false);
        UserMap = TEPreparation.UserMap;
        System.runAs(UserMap.get(userName)) {
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            TEEducationApplicationCtrl eda = new TEEducationApplicationCtrl(null);
            eda.ea.On_Behalf_Of__c = EmployeeAdministrator.get(userName).id;
            eda.ea.Couse_Type__c = 'sc';
            eda.ea.Education__c = TEPreparation.generateRandomString(5);
            eda.ea.Program_Course_Title__c = TEPreparation.generateRandomString(5);
            eda.ea.Start_Date__c = System.Today().adddays(5);
            eda.ea.End_Date__c = System.Today().adddays(15);
            eda.ea.Course_URL__c = TEPreparation.generateRandomString(5);
            eda.ea.Tuition_Fee_Recommended_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            eda.ea.Tuition_Fee__c = 1000;
            eda.ea.Payment_Method__c = 'o';
            eda.ea.Reason_of_Studying__c = TEPreparation.generateRandomString(5);
            
            prf = eda.saveAndSubmit(); 
            System.assertNotEquals(eda.ea.Id, null); 
            
            try{
                result = TEEducationApplicationRemoteActionsUtils.recallApprovalProcess(eda.ea.Id);      
                system.assertNotEquals(null, result);
            }
            catch(Exception ex){
            }
            
            Test.stopTest();
        }
    }
//*/
}