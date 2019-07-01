@isTest
private class TestIDPPhotoMappingCtrl {
	
	public static IDPPhotoMappingCtrl photoMappingCtrl;
	public static IDPPhotoMappingMainCtrl photoMappingMainCtrl;
	public static IDPPhotoMappingItemToPhotoCtrl photoMappingItemToPhotoCtrl;
	public static IDPPhotoMappingPhotoToItemCtrl photoMappingPhotoToItemCtrl;

	public static Map<String, User> userMap;
	public static Map<String, IDP_Policy__c> idpPolicyMap;
	public static Map<String, Catalog__c> catalogAllMap;
	public static Map<String, Catalog_Item__c> catalogItemMap;

	private static String catalogItemName = 'Administration_Motor Vehicles_Item_1';
	
	@testSetup
    public static void testSetup() {
        TestIDPUtility.prepare(false, false);
    }
    
    public static void prepareMap() {
        catalogAllMap = TestIDPUtility.getCatalogAllMap();
        catalogItemMap = TestIDPUtility.getCatalogItemMap();
        userMap = TestIDPUtility.getUserMap();
        idpPolicyMap = TestIDPUtility.getIdpPolicyMap();
    }


	@isTest 
	public static void testUploadAttachment() {

		prepareMap();

		IDPPhotoMappingCtrl.uploadFileAction('TestPhoto1.jpg', 'image/jpeg', Blob.valueOf('Unit Test Attachment Body').toString(), '');

		photoMappingCtrl = new IDPPhotoMappingCtrl();
		photoMappingCtrl.rerenderAllDocTables();

		List<Document> docs = photoMappingCtrl.attachments;
		System.assertEquals(1, docs.size());
	}

	@isTest
	public static void testMapItemToPhoto() {

		prepareMap();

		IDPPhotoMappingCtrl.uploadFileAction('TestPhoto1.jpg', 'image/jpeg', Blob.valueOf('Unit Test Attachment Body').toString(), '');
		photoMappingCtrl = new IDPPhotoMappingCtrl();
		photoMappingCtrl.rerenderAllDocTables();

		List<Document> docs = photoMappingCtrl.attachments;
		Document doc = docs.get(0);
		Catalog_Item__c ci;

		putParam('docId', doc.Id);
		putParam('cId', catalogItemMap.get(catalogItemName).Id);

		photoMappingItemToPhotoCtrl = new IDPPhotoMappingItemToPhotoCtrl();

		putParam('selected', doc.Id);
		photoMappingItemToPhotoCtrl.save();

		ci = [SELECT Id, Name, Photo_Doc_Id__c, Photo_Name__c FROM Catalog_Item__c WHERE Id =:catalogItemMap.get(catalogItemName).Id];
		system.assertEquals(doc.Id, ci.Photo_Doc_Id__c);
		system.assertEquals(doc.name, ci.Photo_Name__c);

		IDPPhotoMappingCtrl.uploadFileAction('default.jpg', 'image/jpeg', Blob.valueOf('Unit Test Attachment Body').toString(), '');
		photoMappingCtrl = new IDPPhotoMappingCtrl();
		photoMappingCtrl.rerenderAllDocTables();


		Document defImg = [SELECT id, Name, DeveloperName FROM Document WHERE DeveloperName LIKE '%default%' LIMIT 1];

		photoMappingItemToPhotoCtrl.defaultImgName = defImg.DeveloperName;
		photoMappingItemToPhotoCtrl.resumeToDefaultPic();

		ci = [SELECT Id, Name, Photo_Doc_Id__c, Photo_Name__c FROM Catalog_Item__c WHERE Id =:catalogItemMap.get(catalogItemName).Id];
		system.assertEquals(defImg.Id, ci.Photo_Doc_Id__c);
		system.assertEquals(defImg.name, ci.Photo_Name__c);

		
		
	}

	@isTest
	public static void testDeletePhoto() {

		prepareMap();

		IDPPhotoMappingCtrl.uploadFileAction('TestPhoto1.jpg', 'image/jpeg', Blob.valueOf('Unit Test Attachment Body').toString(), '');
		photoMappingCtrl = new IDPPhotoMappingCtrl();
		photoMappingCtrl.rerenderAllDocTables();

		List<Document> docs = photoMappingCtrl.attachments;
		Document doc = docs.get(0);
		Catalog_Item__c ci;

		putParam('docId', doc.Id);
		putParam('cId', catalogItemMap.get(catalogItemName).Id);

		photoMappingItemToPhotoCtrl = new IDPPhotoMappingItemToPhotoCtrl();

		putParam('selected', doc.Id);
		photoMappingItemToPhotoCtrl.save();

		ci = [SELECT Id, Name, Photo_Doc_Id__c, Photo_Name__c FROM Catalog_Item__c WHERE Id =:catalogItemMap.get(catalogItemName).Id];
		system.assertEquals(doc.Id, ci.Photo_Doc_Id__c);
		system.assertEquals(doc.name, ci.Photo_Name__c);


		IDPPhotoMappingCtrl.uploadFileAction('default.jpg', 'image/jpeg', Blob.valueOf('Unit Test Attachment Body').toString(), '');
		Document defImg = [SELECT id, Name, DeveloperName FROM Document WHERE DeveloperName LIKE '%default%' LIMIT 1];

		putParam('delPhotoId', doc.Id);
		photoMappingCtrl = new IDPPhotoMappingCtrl();
		photoMappingCtrl.defaultImgName = defImg.DeveloperName;
		photoMappingCtrl.deletePhoto();

		ci = [SELECT Id, Name, Photo_Doc_Id__c, Photo_Name__c FROM Catalog_Item__c WHERE Id =:catalogItemMap.get(catalogItemName).Id];
		system.assertEquals(defImg.Id, ci.Photo_Doc_Id__c);
		system.assertEquals(defImg.name, ci.Photo_Name__c);
	}

	@isTest
	public static void testMapPhotoToItem() {

		prepareMap();

		IDPPhotoMappingCtrl.uploadFileAction('TestPhoto1.jpg', 'image/jpeg', Blob.valueOf('Unit Test Attachment Body').toString(), '');
		photoMappingCtrl = new IDPPhotoMappingCtrl();
		photoMappingCtrl.rerenderAllDocTables();

		List<Document> docs = photoMappingCtrl.attachments;
		Document doc = docs.get(0);
		Catalog_Item__c ci;

		List<IDPPhotoMappingPhotoToItemCtrl.CatItemWrapper> wrapperList = new List<IDPPhotoMappingPhotoToItemCtrl.CatItemWrapper>();
		wrapperList.add(new IDPPhotoMappingPhotoToItemCtrl.CatItemWrapper(catalogItemMap.get(catalogItemName), true));

		putParam('cId', doc.Id);
		photoMappingPhotoToItemCtrl = new IDPPhotoMappingPhotoToItemCtrl();
		photoMappingPhotoToItemCtrl.catItemWrapperList = wrapperList;
		photoMappingPhotoToItemCtrl.save();

		ci = [SELECT Id, Name, Photo_Doc_Id__c, Photo_Name__c FROM Catalog_Item__c WHERE Id =:catalogItemMap.get(catalogItemName).Id];
		system.assertEquals(doc.Id, ci.Photo_Doc_Id__c);
		system.assertEquals(doc.name, ci.Photo_Name__c);


		IDPPhotoMappingPhotoToItemCtrl.CatItemWrapper wrapper = wrapperList.get(0);
		wrapper.isSelected = false;
		photoMappingPhotoToItemCtrl.save();

		ci = [SELECT Id, Name, Photo_Doc_Id__c, Photo_Name__c FROM Catalog_Item__c WHERE Id =:catalogItemMap.get(catalogItemName).Id];
		system.assertEquals(null, ci.Photo_Doc_Id__c);
		system.assertEquals(null, ci.Photo_Name__c);
	}

	@isTest
	public static void testGetSetMethod(){

		IDPPhotoMappingCtrl.uploadFileAction('TestPhoto1.jpg', 'image/jpeg', Blob.valueOf('Unit Test Attachment Body').toString(), '');
		photoMappingCtrl = new IDPPhotoMappingCtrl();
		photoMappingCtrl.rerenderAllDocTables();

		List<Document> docs = photoMappingCtrl.attachments;
		Document doc = docs.get(0);

		putParam('cId', doc.Id);
		photoMappingPhotoToItemCtrl = new IDPPhotoMappingPhotoToItemCtrl();

		photoMappingPhotoToItemCtrl.getCatalogOpt();
		photoMappingPhotoToItemCtrl.getCatalogItemList();

		Set<Id> catIDSet = photoMappingPhotoToItemCtrl.catIDSet;
		photoMappingPhotoToItemCtrl.catIDSet = null;
	}

	@isTest
	public static void testMain() {

		prepareMap();

		photoMappingMainCtrl = new IDPPhotoMappingMainCtrl();
		photoMappingMainCtrl.showUploadPhotoPage();
		photoMappingMainCtrl.getCatalogOpt();

		photoMappingMainCtrl.mode = 'Item to Photo';
		photoMappingMainCtrl.changeMode();
		photoMappingMainCtrl.mode = 'Photo to Item';
		photoMappingMainCtrl.changeMode();
		photoMappingMainCtrl.mode = '';
		photoMappingMainCtrl.changeMode();

		putParam('itemSelected', catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id + '');
		photoMappingMainCtrl.gotoPage();

		photoMappingMainCtrl.getCatItemToMap();
		photoMappingMainCtrl.getCatalogItemList();
		photoMappingMainCtrl.getPhotoToMap();

		putParam('cId', catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id + '');
		photoMappingMainCtrl.showSelectedItem();
	}

	public static void putParam(String key, String val) {
		TestIDPUtility.putParam(key, val);
	}


	public static void log(String msg){
		TestIDPUtility.log(msg);
	}
	
	
}