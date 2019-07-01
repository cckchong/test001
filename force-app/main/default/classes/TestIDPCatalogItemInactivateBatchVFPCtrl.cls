@isTest
public class TestIDPCatalogItemInactivateBatchVFPCtrl {

	public static Map<String, User> userMap;
	public static Map<String, Supplier__c> supplierMap;
	public static Map<String, Catalog_Item__c> catalogItemMap;

	private static ApexPages.StandardController sc;
    private static ApexPages.StandardSetController ssc;
    private static IDPCatalogItemInactivateBatchVFPCtrl ctrl;
	private static String catalogItemName = 'Administration_Motor Vehicles_Item_1';

	@testSetup
    public static void testSetup() {
        TestIDPUtility.prepare(false);
    }

    public static void prepareMap() {
    	userMap = TestIDPUtility.getUserMap();
    	supplierMap = TestIDPUtility.getSupplierMap();
    	catalogItemMap = TestIDPUtility.getCatalogItemMap();
    }

    @isTest
    public static void testExecute() {

    	prepareMap();

    	Catalog_Item__c befCi = catalogItemMap.get(catalogItemName);
    	Catalog_Item__c aftCi;
    	

    	system.runAs(userMap.get('user1')) {
    		putParam('id', befCi.Id);
			sc = new ApexPages.StandardController(befCi);
	    	ctrl = new IDPCatalogItemInactivateBatchVFPCtrl(sc);
	    	ctrl.inactivateCatalogItems();
	    	aftCi = [SELECT Id, Status__c FROM Catalog_Item__c WHERE Id = :befCi.Id];
	    	system.assertEquals(IDPConstant.CATALOG_ITEM_STATUS_ACTIVE, aftCi.Status__c);
    	}


    	system.runAs(userMap.get('COUser')) {
    		putParam('id', befCi.Id);

    		List<Catalog_Item__c> ciList = new List<Catalog_Item__c>();
    		ciList.add(befCi);
			ssc = new ApexPages.StandardSetController(ciList);
	    	ssc.setSelected(ciList);

	    	ctrl = new IDPCatalogItemInactivateBatchVFPCtrl(ssc);
	    	ctrl.inactivateCatalogItems();
	    	aftCi = [SELECT Id, Status__c FROM Catalog_Item__c WHERE Id = :befCi.Id];
	    	system.assertEquals(IDPConstant.CATALOG_ITEM_STATUS_INACTIVE, aftCi.Status__c);
    	}
    }

    public static void log(String msg) {
    	TestIDPUtility.log(msg);
    }

    public static void putParam(String key, String val) {
    	TestIDPUtility.putParam(key, val);
    }
}