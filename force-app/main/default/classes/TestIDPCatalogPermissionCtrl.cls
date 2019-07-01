@isTest
public class TestIDPCatalogPermissionCtrl {

	public static TestIDPPreparation idpPrepare;
	public static IDPCatalogPermissonCtrl ctrl;

	public static Map<String, User> userMap;
	public static Map<String, IDP_Policy__c> idpPolicyMap;
	public static Map<String, Catalog__c> catalogAllMap;
	public static Map<String, Catalog_Item__c> catalogItemMap;

	private static String catalogName = 'Administration';
	
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
	public static void testSearchByDeptCatalog() {
		
		prepareMap();
	
		// Testing Data
		String testDepSelect 		= 'IT-IT';
		String testPolicySelect 	= idpPolicyMap.get('HKO').Id;
		String testCatalogSelect 	= catalogAllMap.get(catalogName).Id;

		ctrl = new IDPCatalogPermissonCtrl();
		
		// Run Search Result
		Map <String, Map<String, Boolean>> result = searchByDeptCatalog(testDepSelect, testPolicySelect, testCatalogSelect);
		
		// Checking
		system.assertEquals(1, result.keySet().size());
		
		for (String dept : result.keySet()) {
			system.assertEquals(testDepSelect, dept);
			
			Map<String, Boolean> catResult = result.get(dept);
			for (String cat : catResult.keySet()) {
				system.assertEquals(testCatalogSelect, cat);
				system.assertEquals(false, catResult.get(cat));
			}
		}
	}

	@isTest
	public static void testUpdatePermissionByDeptCatalog() {

		prepareMap();
		
		String testDepSelect 		= 'IT-IT';
		String testPolicySelect 	= idpPolicyMap.get('HKO').Id;
		String testCatalogSelect 	= catalogAllMap.get(catalogName).Id;

		ctrl = new IDPCatalogPermissonCtrl();

		Map <String, Map<String, Boolean>> oldResult = searchByDeptCatalog(testDepSelect, testPolicySelect, testCatalogSelect);

		for (String dept : oldResult.keySet()) {
			
			Map<String, Boolean> catResult = oldResult.get(dept);
			for (String cat : catResult.keySet()) {
				catResult.put(cat, true);
			}
		}

		ctrl.permissionMatrixSelect = 'opt1';
		ctrl.tableMap = oldResult;
		ctrl.save();
		ctrl.result();

		Map <String, Map<String, Boolean>> newResult = searchByDeptCatalog(testDepSelect, testPolicySelect, testCatalogSelect);

		for (String dept : newResult.keySet()) {
			system.assertEquals(testDepSelect, dept);
			
			Map<String, Boolean> catResult = newResult.get(dept);
			for (String cat : catResult.keySet()) {
				system.assertEquals(testCatalogSelect, cat);
				system.assertEquals(true, catResult.get(cat));
			}
		}
	}

	@isTest
	public static void testSearchByAllDeptCatalog() {
		
		prepareMap();
	
		// Testing Data
		String testDepSelect 		= 'all';
		String testPolicySelect 	= idpPolicyMap.get('HKO').Id;
		String testCatalogSelect 	= catalogAllMap.get(catalogName).Id;

		ctrl = new IDPCatalogPermissonCtrl();
		
		// Run Search Result
		Map <String, Map<String, Boolean>> result = searchByDeptCatalog(testDepSelect, testPolicySelect, testCatalogSelect);
		
		// Checking
		system.assert(result.keySet().size() > 0);
	}

	private static Map <String, Map<String, Boolean>> searchByDeptCatalog(String deptSelect, String policySelect, String catalogSelect) {
		
		ctrl.permissionMatrixSelect = 'opt1';
		ctrl.depSelect 				= deptSelect;
		ctrl.policySelect 			= policySelect;		
		ctrl.catalogSelect 			= catalogSelect;
		ctrl.result();		
		return ctrl.tableMap;
	}




	@isTest
	public static void testSearchByUserCatalog() {

		prepareMap();
	
		// Testing Data
		String testUserSelect 		= userMap.get('user1').Id;
		String testCatalogSelect 	= catalogAllMap.get(catalogName).Id;

		ctrl = new IDPCatalogPermissonCtrl();
		
		// Run Search Result
		Map <String, Map<String, Boolean>> result = searchByUserCatalog(testUserSelect, testCatalogSelect);
		
		// Checking
		system.assertEquals(1, result.keySet().size());
		
		for (String userId : result.keySet()) {
			system.assertEquals(testUserSelect, userId);
			
			Map<String, Boolean> catResult = result.get(userId);
			for (String cat : catResult.keySet()) {
				system.assertEquals(testCatalogSelect, cat);
				system.assertEquals(false, catResult.get(cat));
			}
		}
	}

	@isTest
	public static void testUpdateByUserCatalog() {

		prepareMap();

		// Testing Data
		String testUserSelect 		= userMap.get('user1').Id;
		String testCatalogSelect 	= catalogAllMap.get(catalogName).Id;

		ctrl = new IDPCatalogPermissonCtrl();

		Map <String, Map<String, Boolean>> oldResult = searchByUserCatalog(testUserSelect, testCatalogSelect);

		for (String userId : oldResult.keySet()) {
			
			Map<String, Boolean> catResult = oldResult.get(userId);
			for (String cat : catResult.keySet()) {
				catResult.put(cat, true);
			}
		}

		
		ctrl.tableMap = oldResult;
		ctrl.save();
		ctrl.result();

		Map <String, Map<String, Boolean>> newResult = searchByUserCatalog(testUserSelect, testCatalogSelect);

		for (String userId : newResult.keySet()) {
			system.assertEquals(testUserSelect, userId);
			
			Map<String, Boolean> catResult = newResult.get(userId);
			for (String cat : catResult.keySet()) {
				system.assertEquals(testCatalogSelect, cat);
				system.assertEquals(true, catResult.get(cat));
			}
		}
	}

	private static Map <String, Map<String, Boolean>> searchByUserCatalog(String userSelect, String catalogSelect) {
		
		ctrl.permissionMatrixSelect = 'opt2';
		ctrl.userSelect 			= userSelect;	
		ctrl.catalogSelect 			= catalogSelect;
		ctrl.result();		
		return ctrl.tableMap;
	}






	@isTest
	public static void testSearchByUserCatalogItem() {

		prepareMap();
		
		// Testing Data
		String testUserSelect 			= userMap.get('user1').Id;
		String testCatalogItemSelect 	= catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id;

		ctrl = new IDPCatalogPermissonCtrl();
		
		// Run Search Result
		Map <String, Map<String, Boolean>> result = searchByUserCatalogItem(testUserSelect, testCatalogItemSelect);
		
		// Checking
		system.assertEquals(1, result.keySet().size());
		
		for (String userId : result.keySet()) {
			system.assertEquals(testUserSelect, userId);
			
			Map<String, Boolean> catItemResult = result.get(userId);
			for (String catItem : catItemResult.keySet()) {
				system.assertEquals(testCatalogItemSelect, catItem);
				system.assertEquals(false, catItemResult.get(catItem));
			}
		}
	}

	@isTest
	public static void testUpdateByUserCatalogItem() {

		prepareMap();

		// Testing Data
		String testUserSelect 			= userMap.get('user1').Id;
		String testCatalogItemSelect 	= catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id;

		ctrl = new IDPCatalogPermissonCtrl();

		Map <String, Map<String, Boolean>> oldResult = searchByUserCatalogItem(testUserSelect, testCatalogItemSelect);

		for (String userId : oldResult.keySet()) {
			
			Map<String, Boolean> catItemResult = oldResult.get(userId);
			for (String catItem : catItemResult.keySet()) {
				catItemResult.put(catItem, true);
			}
		}

		
		ctrl.tableMap = oldResult;
		ctrl.save();
		ctrl.result();

		Map <String, Map<String, Boolean>> newResult = searchByUserCatalogItem(testUserSelect, testCatalogItemSelect);

		for (String userId : newResult.keySet()) {
			system.assertEquals(testUserSelect, userId);
			
			Map<String, Boolean> catItemResult = newResult.get(userId);
			for (String catItem : catItemResult.keySet()) {
				system.assertEquals(testCatalogItemSelect, catItem);
				system.assertEquals(true, catItemResult.get(catItem));
			}
		}
	}


	private static Map <String, Map<String, Boolean>> searchByUserCatalogItem(String userSelect, String catalogItemSelect) {
		
		ctrl.permissionMatrixSelect = 'opt3';
		ctrl.userSelect 			= userSelect;	
		ctrl.catalogItemSelect 		= catalogItemSelect;
		ctrl.result();		
		return ctrl.tableMap;
	}



	@isTest
	public static void testValidate() {

		prepareMap();

		ctrl = new IDPCatalogPermissonCtrl();
		ctrl.permissionMatrixSelect = 'opt1';
		system.assertEquals(false, ctrl.validation());

		ctrl.permissionMatrixSelect = 'opt2';
		system.assertEquals(false, ctrl.validation());

		ctrl.permissionMatrixSelect = 'opt3';
		system.assertEquals(false, ctrl.validation());

	}
	
	public static void log(String msg){
		TestIDPUtility.log(msg);
	}
}