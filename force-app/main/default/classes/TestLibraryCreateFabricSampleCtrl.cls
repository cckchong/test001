/**
 * Test class of LibraryCreateFabricSampleCtrl
 */
@isTest
private class TestLibraryCreateFabricSampleCtrl {

    static testMethod void myUnitTest() {
        Library_Item__c item = LibraryTestDataUtility.insertLibraryItem();
        Sample_Fabric__c sf = new Sample_Fabric__c(Sample__c =item.id, Fabric__c=item.id);
        insert sf;
        ApexPages.StandardController sc = new ApexPages.StandardController(sf);
        
        LibraryCreateFabricSampleCtrl sampleCtrl = new LibraryCreateFabricSampleCtrl(sc);
        item.Fls_Content__c = 'abc';
        item.Content_Percent__c = 100;
        
        item.Fls_Content_2__c = 'abc';
        item.Content_Percent_2__c = 100;
        
        item.Fls_Content_3__c='abc';
        item.Content_Percent_3__c=100;
        
        sampleCtrl.fabric = item;
        sampleCtrl.sf = sf;
        
        PageReference p1 = sampleCtrl.createNewButton();
        p1 = sampleCtrl.saveAndNewButton();
        p1 = sampleCtrl.cancelButton();
        p1 = sampleCtrl.editButton();
        
        sampleCtrl.fabric = new Library_Item__c();
        p1 =sampleCtrl.saveAndNewButton();
        
        sc = new ApexPages.StandardController(new Sample_Fabric__c(Sample__c =item.id, Fabric__c=item.id));
        sampleCtrl = new LibraryCreateFabricSampleCtrl(sc);
        
        system.assertNotEquals(sampleCtrl, null);
    }
}