@isTest 
public class TestTECarbonEmissionOverwriteNewCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
    
        Carbon_Emission__c ce = new Carbon_Emission__c();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ce);
        TECarbonEmissionOverwriteNewCtrl ctrl = new TECarbonEmissionOverwriteNewCtrl(sc);

        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);
    }
}