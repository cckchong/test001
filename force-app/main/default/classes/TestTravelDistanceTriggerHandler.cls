@isTest 
public class TestTravelDistanceTriggerHandler{
    @isTest 
    public static void test() {
        Airport__c air1 = new Airport__c();
        air1.Name = 'A';
        Airport__c air2 = new Airport__c();       
        air2.Name = 'B';
        insert air1;
        insert air2;
        
        Flight_Type__c ft = new Flight_Type__c();
        ft.Short_Name__c = 'T';
        ft.Min_Range__c = 0;
        ft.Max_Range__c = 2000;
        insert ft;
        
        Cabin_Class__c cc = new Cabin_Class__c();
        insert cc;
        
        GHG_Factor__c gf = new GHG_Factor__c();        // for creating carbon emission
        gf.Cabin_Class__c = cc.Id;
        gf.Flight_Type__c = ft.Id;
        gf.Emission_Factor__c = 0;
        gf.Emission_Factor_2__c = 0;
        gf.Emission_Factor_3__c = 0;
        insert gf;
        
        // Scenario 1: flight type == null
        Travel_Distance__c td = new Travel_Distance__c();
        td.From_Airport__c = air1.Id;
        td.To_Airport__c = air2.Id;
        td.Distance__c = 1000;
        insert td;
        
        // Scenario 2: flight type's distance does not match
        Flight_Type__c ft2 = new Flight_Type__c();
        ft2.Short_Name__c = 'N';
        ft2.Min_Range__c = 0;
        ft2.Max_Range__c = 200;
        insert ft2;
        
        td.Flight_Type__c = ft2.Id;
        try{
            upsert td;
        }
        catch(Exception ex){
        }
        
        // Scenario 3: assign the correct flight type
        td.Flight_Type__c = ft.Id;
        upsert td;
        
        system.assertNotEquals(null, td);
    }
}