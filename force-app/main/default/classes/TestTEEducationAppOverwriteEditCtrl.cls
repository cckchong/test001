@isTest 
public class TestTEEducationAppOverwriteEditCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
    
        Employee__c Applicantemployee = new Employee__c();
        insert Applicantemployee;
        
        Employee_Administrator__c Applicant = new Employee_Administrator__c();
        Applicant.Employee_Administrator__c = Applicantemployee.Id;
        insert Applicant;
        
        Education_Application__c ea = new Education_Application__c ();

        ea.On_Behalf_Of__c = Applicant.Id;
        ea.Education__c = 'Test';
        ea.Start_Date__c = date.newInstance(2020,5,1);
        ea.End_Date__c = date.newInstance(2020,5,2);
        ea.Tuition_Fee__c = 100;
        
        insert ea;

        Test.setCurrentPage(Page.TEEducationApplicationOverwriteEdit);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
        ApexPages.currentPage().getParameters().put('id', ea.Id );
        TEEducationApplicationOverwriteEditCtrl ctrl = new TEEducationApplicationOverwriteEditCtrl(sc);

        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);
    }
}