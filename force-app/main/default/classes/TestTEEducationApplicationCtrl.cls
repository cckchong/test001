@isTest  
public class TestTEEducationApplicationCtrl{
    
    Public static TestTEPreparation TEPreparation ;
    Public static employee__c employee;
    Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    Public static String userName = 'user1';
    
    Public static void preparation(Boolean isSeeAllData){
        TEPreparation = new TestTEPreparation(isSeeAllData);
        TEPreparation.preparation(isSeeAllData);
        employee = TEPreparation.getEmployeefromOriginalEmployeeID(userName);
        EmployeeAdministrator = TEPreparation.EmployeeAdministratorMap;
    }
    
    
    @isTest
    public static void saveEducationApplication(){
        Map<String, User> UserMap = null; 
        PageReference prf = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        System.runAs(UserMap.get(userName)) {
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            TEEducationApplicationCtrl eda = createEducateionApplication(EmployeeAdministrator, userName);
            prf = eda.saveAndRedirect();
            System.assertNotEquals(prf, null); 
            Test.stopTest();
        }
         
    }
    
    @isTest
    public static void submitEducationApplication(){
        Map<String, User> UserMap = null;
        PageReference prf = null; 
        preparation(false);
        UserMap = TEPreparation.UserMap;
        System.runAs(UserMap.get(userName)) {
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            TEEducationApplicationCtrl eda = createEducateionApplication(EmployeeAdministrator, userName);
            prf = eda.saveAndSubmit();
            System.assertEquals(eda.tmp, null); 
            System.assertNotEquals(prf, null); 
            Test.stopTest();
        }
         
    }
    
    @isTest
    public static void ApproverApproveEducationApplication(){
        Map<String, User> UserMap = null;
        PageReference prf = null; 
        TEEducationApplicationCtrl eda;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        employee.Grade__c = '7';
        upsert employee;
        Test.startTest();
        System.runAs(UserMap.get(userName)) {
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            eda = createEducateionApplication(EmployeeAdministrator, userName);
            prf = eda.saveAndSubmit();
            System.assertNotEquals(prf, null); 
        }
        System.runAs(UserMap.get('actapr1')){
            System.assertNotEquals(eda.ea.id, null); 
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            ApexPages.currentPage().getParameters().put('id', eda.ea.id );
            eda = new TEEducationApplicationCtrl(null);
            eda.redirect();
            prf = eda.saveAndApprove();
            System.assertNotEquals(prf, null);
            for(Education_Application__c reader: [select id, status__c from Education_Application__c where id = :eda.ea.id]){
                System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING_HCM_APPROVAL );
            }

        }
        Test.stopTest();
         
    }
    
    @isTest
    public static void HCMApproveEducationApplication(){
        Map<String, User> UserMap = null;
        PageReference prf = null; 
        TEEducationApplicationCtrl eda;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        employee.Grade__c = '7';
        upsert employee;
        Test.startTest();
        System.runAs(UserMap.get(userName)) {
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            eda = createEducateionApplication(EmployeeAdministrator, userName);
            eda.redirect();
            prf = eda.saveAndSubmit();
            eda.redirect();
            System.assertNotEquals(prf, null); 
        }
        System.runAs(UserMap.get('actapr1')){
            System.assertNotEquals(eda.ea.id, null); 
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            ApexPages.currentPage().getParameters().put('id', eda.ea.id );
            eda = new TEEducationApplicationCtrl(null);
            prf = eda.saveAndApprove();
            System.assertNotEquals(prf, null);
            for(Education_Application__c reader: [select id, status__c from Education_Application__c where id = :eda.ea.id]){
                System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING_HCM_APPROVAL );
            }

        }
        System.runAs(UserMap.get('actapr1')){
            System.assertNotEquals(eda.ea.id, null); 
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            ApexPages.currentPage().getParameters().put('id', eda.ea.id );
            eda = new TEEducationApplicationCtrl(null);
            eda.ea.Reliability_of_Course_Institute__c = TEPreparation.generateRandomString(5);
            eda.ea.Relevancy_to_work__c = TEPreparation.generateRandomString(5);
            eda.ea.Tuition_Fee_Recommended__c = 500;
            eda.ea.Tuition_Fee_Recommended_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            eda.ea.Remarks__c = TEPreparation.generateRandomString(5);            
            prf = eda.saveAndApprove();
            System.assertEquals(eda.tmp, null);
            System.assertNotEquals(prf, null);
            for(Education_Application__c reader: [select id, status__c from Education_Application__c where id = :eda.ea.id]){
                System.assertEquals(reader.status__c, TEConstant.STATUS_APPROVED);
            }

        }
        Test.stopTest();
         
    }
     
    
    @isTest
    public static void CancelEducationApplication(){
        Map<String, User> UserMap = null;
        PageReference prf = null; 
        TEEducationApplicationCtrl eda;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        Test.startTest();
        System.runAs(UserMap.get(userName)) {
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            eda = createEducateionApplication(EmployeeAdministrator, userName);
            eda.cancel();
            eda.getCurrencies();
            prf = eda.saveAndSubmit();
            
            eda.cancel();
            System.assertNotEquals(prf, null); 
        } 
        Test.stopTest();
         
    }
    
    private static TEEducationApplicationCtrl createEducateionApplication( Map<String, Employee_Administrator__c> ea, String uname){
        TEEducationApplicationCtrl eda = new TEEducationApplicationCtrl(null);
        eda.ea.On_Behalf_Of__c = ea.get(uname).id;
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
        
        return eda;
    }
    
    
}