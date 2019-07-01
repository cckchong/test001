@isTest
public class TestIDPCommonUtils {

	public static TestIDPPreparation idpPrepare;
    public static IDPAjaxDataTableCtrl ajaxDataTableCtrl;
    public static IDPBrowseCatalogVFPCtrl browseCatalogCtrl;
    public static IDPCatalogPermissonCtrl catalogPermissionCtrl;

    public static Map<String, Catalog__c> catalogAllMap;
    public static Map<String, Catalog_Item__c> catalogItemMap;
    public static Map<String, User> userMap;
    public static Map<String, Employee__c> employeeMap;
    public static Map<String, IDP_Policy__c> idpPolicyMap;
    public static Map<String, Currency__c> currencyMap;

    private static IDPAjaxDataTableCtrl.DataTableWrapper wrapper;
    private static IDPAjaxDataTableCtrl.CatalogItemWrapper ciWrapper;

    private static String lv1CatalogName = 'Administration';
    private static String lv2CatalogName = 'Motor Vehicles';
    private static String catalogItemName = 'Administration_Motor Vehicles_Item_1';

    @testSetup
    public static void testSetup() {
        TestIDPUtility.prepare(false);
    }
    
    public static void prepareMap() {
        catalogAllMap = TestIDPUtility.getCatalogAllMap();
        catalogItemMap = TestIDPUtility.getCatalogItemMap();
        userMap = TestIDPUtility.getUserMap();
        employeeMap = TestIDPUtility.getEmployeeMap();
        idpPolicyMap = TestIDPUtility.getIdpPolicyMap();
        currencyMap = TestIDPUtility.getCurrencyMap();
    }

    @isTest
    public static void testGetUserCatalogs() {

    	prepareMap();

    	Set<Id> userIdSet = new Set<Id>();
    	userIdSet.add(userMap.get('user1').Id);
    	userIdSet.add(userMap.get('COUser').Id);
    	Map<Id, Set<Id>> result = IDPCommonUtils.getUserCatalogs(userIdSet);
    }

    @isTest
    public static void testGetUserCatalogItems() {

    	prepareMap();

    	Set<Id> userIdSet = new Set<Id>();
    	userIdSet.add(userMap.get('user1').Id);
    	userIdSet.add(userMap.get('COUser').Id);

    	Map<Id, Map<Id, Catalog_Item_Permission__c>> result = IDPCommonUtils.getUserCatalogItems(userIdSet, null);
    }

    @isTest
    public static void testGetUserAllPermission() {

    	prepareMap();

    	List<Catalog_Item_Permission__c> result = IDPCommonUtils.getUserAllPermission(userMap.get('user1').Id);

    }

    @isTest
    public static void testfindPurchaseRequestToApproveList() {

    	prepareMap();

    	List<Purchase_Request__c> result = IDPCommonUtils.findPurchaseRequestToApproveList(userMap.get('user1').Id, null);
    }

    @isTest
    public static void testfindPurchaseOrderList() {

    	prepareMap();

    	List<Purchase_Order__c> result = IDPCommonUtils.findPurchaseOrderList(null);
    }

    @isTest
    public static void testfindRecentPurchaseRequestList() {

    	prepareMap();

    	List<Purchase_Request__c> result = IDPCommonUtils.findRecentPurchaseRequestList(userMap.get('user1').Id, null);
    }

    @isTest
    public static void testLoadSortingSelectOptionList() {

    	prepareMap();

    	List<SelectOption> result = IDPCommonUtils.loadSortingSelectOptionList();
    }

    @isTest
    public static void testloadDisplayCurrencySelectOptionList() {

    	prepareMap();

    	List<SelectOption> result = IDPCommonUtils.loadDisplayCurrencySelectOptionList();
    }

    @isTest
    public static void testloadExchangeRateMap() {

    	prepareMap();

    	Set<String> pFromCurrencyIdSet = new Set<String>();
    	pFromCurrencyIdSet.add(currencyMap.get('HKD').Id);


    	Map<String, Exchange_Rate__c> result = IDPCommonUtils.loadExchangeRateMap(pFromCurrencyIdSet, 'USD');
    }

    @isTest
    public static void testDependPickListValue() {

    	prepareMap();

    	Map<String,List<String>> result = IDPCommonUtils.dependPickListValue('Employee__c', 'Function_Code__c', 'Department_Code__c');
    }

    @isTest
    public static void testpicklistWithTranslation() {

    	prepareMap();

    	Map<String,String> result = IDPCommonUtils.picklistWithTranslation('Employee__c', 'Function_Code__c', 'Department_Code__c');
    }

    @isTest
    public static void testloadPhotoNameUrlMap() {

    	prepareMap();

    	Map<String, String> result = IDPCommonUtils.loadPhotoNameUrlMap(new Set<String>());
    }

    @isTest
    public static void testloadIsQueueMemeberQueueIdSet () {

    	prepareMap();

    	Set<String> result = IDPCommonUtils.loadIsQueueMemeberQueueIdSet (userMap.get('user1').Id);
    }

    @isTest
    public static void testcreateDepartmentPermissions() {

    	prepareMap();

    	Set<String> departmentStringSet = new Set<String>();
    	Set<Id> catalogIdSet = new Set<Id>();

    	departmentStringSet.add('IT');
    	catalogIdSet.add(catalogAllMap.get('Administration').Id);

    	List<Catalog_Item_Permission__c> result = IDPCommonUtils.createDepartmentPermissions(departmentStringSet, catalogIdSet);
    }

    @isTest
    public static void testcreateCatalogPermissions () {

    	prepareMap();

    	Set<String> userIdSet = new Set<String>();
    	Set<Id> catalogIdSet = new Set<Id>();

    	userIdSet.add(userMap.get('user1').Id);
    	catalogIdSet.add(catalogAllMap.get('Administration').Id);

    	List<Catalog_Item_Permission__c> result = IDPCommonUtils.createDepartmentPermissions(userIdSet, catalogIdSet);
    }

    @isTest
    public static void testcreateCatalogItemPermissions  () {

    	prepareMap();

    	Set<String> userIdSet = new Set<String>();
    	Set<Id> catalogItemIdSet = new Set<Id>();

    	userIdSet.add(userMap.get('user1').Id);
    	catalogItemIdSet.add(catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id);

    	List<Catalog_Item_Permission__c> result = IDPCommonUtils.createDepartmentPermissions(userIdSet, catalogItemIdSet);
    }

    public static void putParam(String key, String val) {
    	TestIDPUtility.putParam(key, val);
    }

    public static void log(String msg) {
    	TestIDPUtility.log(msg);
    }

}