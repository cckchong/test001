@isTest
public class TestTEEducationApplicationProgressBCtrl {

    @isTest 
    public static void test() {        
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
        ea.Status__c = 'DF';       
        insert ea;
        
        Test.setCurrentPage(Page.TEEducationApplicationProgressBarVFPage);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
        ApexPages.currentPage().getParameters().put('id', ea.Id );
        TEEducationApplicationProgressBarCtrl ctrl = new TEEducationApplicationProgressBarCtrl(sc);
    }
}