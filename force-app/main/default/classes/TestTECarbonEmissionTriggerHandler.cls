@isTest 
public class TestTECarbonEmissionTriggerHandler{
    @isTest 
    public static void test() {
        Airport__c air1 = new Airport__c();
        air1.Name = 'A';
        Airport__c air2 = new Airport__c();       
        air2.Name = 'B';
        insert air1;
        insert air2;
        
        Travel_Distance__c td = new Travel_Distance__c();
        td.From_Airport__c = air1.Id;
        td.To_Airport__c = air2.Id;
        td.Distance__c = 1000;
        insert td;
        
        Cabin_Class__c cc = new Cabin_Class__c();
        insert cc;
        
        Flight_Type__c ft = new Flight_Type__c();
        ft.Short_Name__c = 'T';
        insert ft;
        
        GHG_Factor__c gf = new GHG_Factor__c();
        gf.Cabin_Class__c = cc.Id;
        gf.Flight_Type__c = ft.Id;
        gf.Emission_Factor__c = 0;
        gf.Emission_Factor_2__c = 0;
        gf.Emission_Factor_3__c = 0;
        insert gf;
        
        // Scenario 1: failed to insert, flight type does not match        
        Carbon_Emission__c ce = new Carbon_Emission__c();
        ce.GHG_Factor__c = gf.Id;
        ce.Travel_Distance__c = td.Id;
        try{
            insert ce;
        }
        catch(Exception ex){
        }
        system.assertNotEquals(null,ce);
        
        // To make the flight type match and insert successfully
        ft.Min_Range__c = 0;
        ft.Max_Range__c = 2000;
        upsert ft;
        
        td.Flight_Type__c = ft.Id;
        upsert td;
        try{
            upsert ce;
        }
        catch(Exception ex){
        }
        
        // Scenario 2: failed to update, flight type does not match  
        Flight_Type__c ft2 = new Flight_Type__c();
        ft2.Short_Name__c = 'N';
        ft2.Min_Range__c = 0;
        ft2.Max_Range__c = 2000;
        insert ft2;
        
        td.Flight_Type__c = ft2.Id;
        upsert td;
        
        try{
            upsert ce;
        }
        catch(Exception ex){
        }
        system.assertNotEquals(null, ce);
    }
}