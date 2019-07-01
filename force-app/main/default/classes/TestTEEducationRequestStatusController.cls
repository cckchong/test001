@IsTest
public class TestTEEducationRequestStatusController {
    
    
    Public static TestTEPreparation TEPreparation ;
    Public static employee__c employee;
    Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    Public static String userName = 'user1';
    Public static Map<String, User> UserMap = null;
    
    Public static void preparation(Boolean isSeeAllData){
        
        TEPreparation = new TestTEPreparation(isSeeAllData);
        TEPreparation.preparation(isSeeAllData);
        UserMap = TEPreparation.UserMap;
        employee = TEPreparation.getEmployeefromOriginalEmployeeID(userName);
        EmployeeAdministrator = TEPreparation.EmployeeAdministratorMap;
    }
    
    
    @IsTest
    public static void execute() {
        PageReference prf = null;
        preparation(false);
        System.runAs(UserMap.get(userName)){
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'staff' );
            TEEducationApplicationCtrl eda = createEducateionApplication(EmployeeAdministrator, userName);
            prf = eda.saveAndRedirect();
            ApexPages.currentPage().getParameters().put('id',eda.ea.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(eda.ea);
            TEEducationRequestStatusController ctrl = new TEEducationRequestStatusController(sc);
            ctrl.SaveAction();
            ctrl.SubmitAction();
            Test.stopTest();
        }
    
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