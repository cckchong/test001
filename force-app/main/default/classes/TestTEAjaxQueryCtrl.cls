@IsTest
public class TestTEAjaxQueryCtrl {
    public static Flight_Type__c ft;
    public static Cabin_Class__c cc;
    public static Travel_Location__c tl1;
    public static Travel_Location__c tl2;
    public static Airport__c air1;
    public static Airport__c air2;
    public static Travel_Distance__c td;
    public static GHG_Factor__c ef;
    public static Travel_Application__c submittedTa;
    
    public static void prepareCarbonData() {
        ft = new Flight_Type__c(Name = 'Long', Short_Name__c = 'L', Min_Range__c = 0, Max_Range__c = 10);
        insert ft;
        
        cc = new Cabin_Class__c(Name = 'Economy');
        insert cc;
        
        tl1 = new Travel_Location__c(Name = 'Vancouver', city_code__c = 'van');
        tl2 = new Travel_Location__c(Name = 'Toronto', city_code__c = 'tor');
        insert tl1;
        insert tl2;
        
        air1 = new Airport__c(Name = 'YVR', Travel_Location__c = tl1.Id);
        air2 = new Airport__c(Name = 'YYZ', Travel_Location__c = tl2.Id);
        insert air1;
        insert air2;
        
        
        td = new Travel_Distance__c(From_Airport__c = air1.Id, To_Airport__c = air2.Id, Flight_Type__c = ft.Id, Distance__c = 5);
        insert td;
        
        ef = new GHG_Factor__c(Flight_Type__c = ft.Id, Cabin_Class__c = cc.Id);
        insert ef;
    }

    
    @IsTest
    public static void execute() {
        prepareCarbonData();
        Test.setCurrentPage(Page.TETravelApplication);
        ApexPages.currentPage().getParameters().put('type','location');
        ApexPages.currentPage().getParameters().put('q','van');
        TEAjaxQueryCtrl ctrl = new TEAjaxQueryCtrl();
        //System.assertNotEquals(null, ceBatch);
    }
}