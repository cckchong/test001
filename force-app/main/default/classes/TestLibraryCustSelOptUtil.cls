/*
* Test Class of LibraryCustomSelectionOptionUtil
*/
@isTest
private class TestLibraryCustSelOptUtil {

    static testMethod void myUnitTest() {
        LibraryCustomSelectionOptionUtil lcsou = new LibraryCustomSelectionOptionUtil();
        LibraryCustomSelectionOptionUtil.getFabricSelectionOptionMap();
        
        List<Fls_Search_Params__c> fspList = new List<Fls_Search_Params__c>();
        
        Fls_Search_Params__c fsp = new Fls_Search_Params__c();
        
        fsp.name = 'BRAND_CUSTOMER425501';
        fsp.Field_Name__c = 'BRAND_CUSTOMER425501';
        fsp.Key__c ='425501';
        fsp.Value__c='R&D1';
        
        fspList.add(fsp);
        
        Fls_Search_Params__c fsp1 = new Fls_Search_Params__c();
        
        fsp1.name = 'BRAND_CUSTOMER425502';
        fsp1.Field_Name__c = 'BRAND_CUSTOMER425501';
        fsp1.Key__c ='425502';
        fsp1.Value__c='R&D2';
        
        
        fspList.add(fsp1);
        
        upsert fspList;
        
        LibraryCustomSelectionOptionUtil.getFabricSelectionOptionMap();
        system.assertNotEquals(null,LibraryCustomSelectionOptionUtil.getFabricSelectionOptionMap());
    }
}