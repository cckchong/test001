@isTest 
public class TestTravelLocationOverwriteNewController{
    @isTest 
    public static void test() {
        PageReference prf = null;
    
        Travel_Location__c ce = new Travel_Location__c();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ce);
        TravelLocationOverwriteNewController ctrl = new TravelLocationOverwriteNewController(sc);

        prf = ctrl.redirectIfOnlySingleRecordType();
        system.assertNotEquals(null,prf);
    }
}