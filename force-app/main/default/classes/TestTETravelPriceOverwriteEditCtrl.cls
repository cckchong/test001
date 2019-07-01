@isTest 
public class TestTETravelPriceOverwriteEditCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
        
        Travel_Application__c ta = new Travel_Application__c();
        insert ta;

        Travel_Price__c tp = new Travel_Price__c();
        tp.Invoice_Date__c = date.newInstance(2016, 5, 1);
        tp.Travel_Application__c = ta.Id;
        insert tp;

        Test.setCurrentPage(Page.TETravelPriceOverwriteEdit);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
        ApexPages.currentPage().getParameters().put('id', tp.Id );
        TETravelPriceOverwriteEditCtrl ctrl = new TETravelPriceOverwriteEditCtrl(sc);

        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);
    }
}