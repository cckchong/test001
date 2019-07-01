@isTest 
public class TestTECashAdvanceOverwriteEditCtrl{
    Public Static TestTEPreparation TEPreparation; 
    
    @isTest 
    public static void test() {
        TEPreparation = new TestTEPreparation (false);
        TEPreparation.Preparation(false);
        
        PageReference prf = null;
    
        Travel_Application__c ta = new Travel_Application__c();
        Cash_Advance__c ca = new Cash_Advance__c();
        
        insert ta;
        ca.Travel_Application__c = ta.Id;
        ca.Currency__c = TEPreparation.currencyMap.get('HKD').id;
        insert ca;

        Test.setCurrentPage(Page.TECashAdvanceOverwriteEdit);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ta);
        ApexPages.currentPage().getParameters().put('id', ca.Id );
        TECashAdvanceOverwriteEditCtrl ctrl = new TECashAdvanceOverwriteEditCtrl(sc);

        prf = ctrl.redirect();
        system.assertNotEquals(null,prf);
    }
}