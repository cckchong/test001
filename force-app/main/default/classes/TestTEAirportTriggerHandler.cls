@isTest 
public class TestTEAirportTriggerHandler{
    @isTest 
    public static void test() {
        List<AirPort__c> airPortList = new List<AirPort__c>();
        AirPort__c ap = new AirPort__c();
        insert ap;
        airPortList.add(ap);
        TEAirportTriggerHandler.addTravelDistance(airPortList);
        

        system.assertNotEquals(null,ap.Id);
    }
}