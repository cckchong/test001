@isTest 
public class TestTETravelApplicationOverwriteNewCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
        
        Travel_Application__c ta = new Travel_Application__c();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
        TETravelApplicationOverwriteNewCtrl ctrl = new TETravelApplicationOverwriteNewCtrl(sc);

        prf = ctrl.redirectNewTETravelAppplication();
        system.assertNotEquals(null,prf);
    }
}