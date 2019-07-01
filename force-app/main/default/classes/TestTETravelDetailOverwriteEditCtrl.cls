@isTest 
public class TestTETravelDetailOverwriteEditCtrl{
    @isTest 
    public static void test() {
        PageReference prf = null;
        
        Travel_Application__c ta = new Travel_Application__c();
        Travel_Detail__c td = new Travel_Detail__c();
        
        insert ta;
        td.Travel_Application__c = ta.Id;
        insert td;

        Test.setCurrentPage(Page.TETravelDetailOverwriteEdit);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
        ApexPages.currentPage().getParameters().put('id', td.Id );
        TETravelDetailOverwriteEditCtrl ctrl = new TETravelDetailOverwriteEditCtrl(sc);

        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);
    }
}