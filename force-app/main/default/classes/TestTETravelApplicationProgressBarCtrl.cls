@isTest
public class TestTETravelApplicationProgressBarCtrl {
    
    @isTest
    public static void test(){
        Travel_Application__c ta = new Travel_Application__c();
        insert ta;
        
        Test.setCurrentPage(Page.TETravelApplicationProgressBarVFPage);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
        ApexPages.currentPage().getParameters().put('id', ta.id );
        TETravelApplicationProgressBarCtrl ctrl = new TETravelApplicationProgressBarCtrl(sc);
    }
    

}