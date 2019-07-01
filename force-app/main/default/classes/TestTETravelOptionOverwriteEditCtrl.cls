@isTest 
public class TestTETravelOptionOverwriteEditCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
        
        Travel_Application__c ta = new Travel_Application__c();
        TravelOption__c to = new TravelOption__c();
        insert ta;
        to.Travel_Application__c = ta.Id;
        insert to;

        Test.setCurrentPage(Page.TETravelOptionOverwriteEdit);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta );
        ApexPages.currentPage().getParameters().put('id', to.Id );
        TETravelOptionOverwriteEditCtrl ctrl = new TETravelOptionOverwriteEditCtrl(sc);

        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);
    }
}