@isTest 
public class TestTravelDistanceOverwriteNewController{
    @isTest 
    public static void test() {
        PageReference prf = null;
    
        Travel_Distance__c ce = new Travel_Distance__c();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ce);
        TravelDistanceOverwriteNewController ctrl = new TravelDistanceOverwriteNewController(sc);

        prf = ctrl.redirectIfOnlySingleRecordType();
        system.assertNotEquals(null,prf);
    }
}