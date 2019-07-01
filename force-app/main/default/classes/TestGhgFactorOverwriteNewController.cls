@IsTest
public class TestGhgFactorOverwriteNewController {

    @IsTest
    public static void execute() {
        Test.setCurrentPage(Page.GhgFactorOverwriteNew);

        
        Flight_Type__c ft = new Flight_Type__c(Name = 'Long', Short_Name__c = 'L', Min_Range__c = 0, Max_Range__c = 10);
        insert ft;
        
        Cabin_Class__c cc = new Cabin_Class__c(Name = 'Economy');
        insert cc;
        
        Travel_Location__c tl1 = new Travel_Location__c(Name = 'Vancouver');
        Travel_Location__c tl2 = new Travel_Location__c(Name = 'Toronto');
        insert tl1;
        insert tl2;
        
        Airport__c air1 = new Airport__c(Name = 'YVR', Travel_Location__c = tl1.Id);
        Airport__c air2 = new Airport__c(Name = 'YYZ', Travel_Location__c = tl2.Id);
        insert air1;
        insert air2;
        
        
        Travel_Distance__c td = new Travel_Distance__c(From_Airport__c = air1.Id, To_Airport__c = air2.Id, Flight_Type__c = ft.Id, Distance__c = 5);
        insert td;
        
        GHG_Factor__c ef = new GHG_Factor__c(Flight_Type__c = ft.Id, Cabin_Class__c = cc.Id);
        insert ef;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ef);
        
        GhgFactorOverwriteNewController ctrl = new GhgFactorOverwriteNewController(sc);
        ctrl.redirect();
        System.assertNotEquals(null, ctrl);
    }
}