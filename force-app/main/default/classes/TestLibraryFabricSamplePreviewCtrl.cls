/*
* Test class of LibraryFabricSamplePreviewCtrl
*/
@isTest
public class TestLibraryFabricSamplePreviewCtrl {
    
    @isTest
    public static void doTestLibraryFabricSamplePreviewCtrl() {
    
        ApexPages.StandardController sc = new ApexPages.StandardController(new Library_Item__c());
        
        LibraryFabricSamplePreviewCtrl le = new LibraryFabricSamplePreviewCtrl(sc);
        //System.assertEquals(le.fieldSet , Schema.SObjectType.Library_Item__c.fieldSets.getMap().get(Label.Library_FabricSampleFieldSet).getFields());
        System.assertEquals(le.fabricItemList  , LibrarySourceFabricRepository.getDummyFabricItemFields());
    }
}