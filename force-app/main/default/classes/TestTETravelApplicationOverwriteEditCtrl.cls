@isTest 
public class TestTETravelApplicationOverwriteEditCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
        
        Travel_Application__c ta = new Travel_Application__c();
        insert ta;

        Test.setCurrentPage(Page.TETravelApplicationOverwriteEdit);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
        ApexPages.currentPage().getParameters().put('id', ta.Id );
        TETravelApplicationOverwriteEditCtrl ctrl = new TETravelApplicationOverwriteEditCtrl(sc);

        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);
    }
}