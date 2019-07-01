@isTest 
public class TestTETravelApplicationDelCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
        //Scenario 1: cannot be deleted
        Travel_Application__c ta = new Travel_Application__c();
        ta.Status__c = TEConstant.STATUS_PENDING;
        insert ta;

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
        TETravelApplicationDelCtrl ctrl = new TETravelApplicationDelCtrl(sc);

        prf = ctrl.action();      
        system.assertNotEquals(null,prf);
        
        //Scenario 2: can be deleted  
        ta.Status__c = TEConstant.STATUS_DRAFT;
        upsert ta;
        sc = new ApexPages.Standardcontroller(ta);
        ctrl = new TETravelApplicationDelCtrl(sc);
        
        prf = ctrl.action(); 
        system.assertNotEquals(null,prf);
    }
}