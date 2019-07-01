/*
	LibraryFabricSamplePreviewCtrl Class
	
	@Author: AN, WG
	@Object: Library_Item__c
	@Description: Used to preview fabric sample
*/
public class LibraryFabricSamplePreviewCtrl {
    public List<Schema.FieldSetMember> fieldSet {get;set;}
    public List<Library_Item__c> fabricItemList {get;set;}
    
    //Constructor
    public LibraryFabricSamplePreviewCtrl(ApexPages.StandardController ctrl) {
        String recordId = ctrl.getRecord().Id;
        this.fieldSet = Schema.SObjectType.Library_Item__c.fieldSets.getMap().get(Label.Library_FabricSampleFieldSet).getFields();
        this.fabricItemList = LibrarySourceFabricRepository.getDummyFabricItemFields();
    }
}