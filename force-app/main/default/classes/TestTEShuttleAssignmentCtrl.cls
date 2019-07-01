@isTest 
public class TestTEShuttleAssignmentCtrl{
    @isTest 
    public static void shuttleBatch() {
        PageReference prf = null;    
        List<SelectOption> opt = null;    
        
        Route__c r = new Route__c();
        insert r;
        Car_Journey__c cj = new Car_Journey__c();
        cj.Date__c = System.Today().addDays(5);
        cj.Route__c = r.Id;
        insert cj;
        Test.setCurrentPage(Page.TEShuttleAssignmentVFP);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cj);
        TEShuttleAssignmentCtrl ctrl = new TEShuttleAssignmentCtrl(sc);
        opt = ctrl.getListViews();
        system.assertNotEquals(null,opt); 
        
        prf = ctrl.newShuttleSchedule();
        system.assertNotEquals(null,prf);
    }
}