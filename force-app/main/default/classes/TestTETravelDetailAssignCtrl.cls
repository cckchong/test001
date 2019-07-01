@isTest 
public class TestTETravelDetailAssignCtrl{

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
    public static void test() {
        PageReference prf = null;    
        preparation(false);
        
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
        Test.setCurrentPage(Page.TETravelDetailAssign);
        ApexPages.currentPage().getParameters().put('type', 'd');
        ApexPages.currentPage().getParameters().put('tdid', td2.Id);
        TETravelDetailAssignCtrl ctrl = new TETravelDetailAssignCtrl();
        
        prf = ctrl.action();
        system.assertNotEquals(null,prf);
    }
}