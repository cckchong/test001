@isTest 
public class TestTEEducationApplicationDelCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
        Employee__c emp = new Employee__c();
        insert emp;
    
        Employee_Administrator__c empAdm = new Employee_Administrator__c();
        empAdm.Employee_Administrator__c = emp.Id;
        insert empAdm;
        
        //Scenario 1: cannot be deleted
        Education_Application__c ea = new Education_Application__c();
        ea.Education__c = 'test';
        ea.On_Behalf_Of__c = empAdm.Id;
        ea.Start_Date__c = Date.Today();
        ea.End_Date__c = Date.Today();
        ea.Tuition_Fee__c = 1;
        
        ea.Status__c = TEConstant.STATUS_PENDING_APPROVAL;
        insert ea;

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ea);
        TEEducationApplicationDelCtrl ctrl = new TEEducationApplicationDelCtrl(sc);

        prf  = ctrl.action();      
        system.assertNotEquals(null,prf);
        
        //Scenario 2: can be deleted  
        ea.Status__c = TEConstant.STATUS_DRAFT;
        upsert ea;
        sc = new ApexPages.Standardcontroller(ea);
        ctrl = new TEEducationApplicationDelCtrl(sc);
        
        prf = ctrl.action(); 
        system.assertNotEquals(null,prf);
        
        
    }
}