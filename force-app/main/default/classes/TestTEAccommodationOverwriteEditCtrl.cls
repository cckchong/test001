@isTest 
public class TestTEAccommodationOverwriteEditCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
    
        Travel_Application__c ta = new Travel_Application__c();
        Accommodation__c ac = new Accommodation__c();
        insert ta;
        ac.Travel_Application__c = ta.Id;
        insert ac;

        Test.setCurrentPage(Page.TEAccommodationOverwriteEdit);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta );
        ApexPages.currentPage().getParameters().put('id', ac.Id );
        TEAccommodationOverwriteEditCtrl ctrl = new TEAccommodationOverwriteEditCtrl(sc);
        
        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);
    }
}