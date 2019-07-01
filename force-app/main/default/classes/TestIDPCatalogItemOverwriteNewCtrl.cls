@isTest
public class TestIDPCatalogItemOverwriteNewCtrl {
	
	public static Map<String, User> userMap;

	@testSetup
    public static void testSetup() {
        TestIDPUtility.prepare(false);
    }

    public static void prepareMap() {
    	userMap = TestIDPUtility.getUserMap();
    }

	@isTest
	public static void testRedirect(){

		prepareMap();

		IDPCatalogItemOverwriteNewCtrl ctrl;
		PageReference pf;
		
		system.runAs(userMap.get('user1')) {
			ctrl = new IDPCatalogItemOverwriteNewCtrl();
			pf = ctrl.redirect();
			system.assertEquals('NonCatalogItem', pf.getParameters().get('mode'));
		}

		system.runAs(userMap.get('COUser')) {
			ctrl = new IDPCatalogItemOverwriteNewCtrl();
			pf = ctrl.redirect();
			system.assertEquals('Standard', pf.getParameters().get('mode'));
		}
	}

	private static void log(String msg) {
		TestIDPUtility.log(msg);
	}
}