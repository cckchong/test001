@isTest
public class TestIDPBrowseCatalogCtrl {

    public static TestIDPPreparation idpPrepare;
    public static IDPAjaxDataTableCtrl ajaxDataTableCtrl;
    public static IDPBrowseCatalogVFPCtrl browseCatalogCtrl;
    public static IDPCatalogPermissonCtrl catalogPermissionCtrl;

    public static Map<String, Catalog__c> catalogAllMap;
    public static Map<String, Catalog_Item__c> catalogItemMap;
    public static Map<String, User> userMap;
    public static Map<String, Employee__c> employeeMap;
    public static Map<String, IDP_Policy__c> idpPolicyMap;

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
    }

    // =======================================================================================================

    private static IDPAjaxDataTableCtrl.DataTableWrapper search(String queryCatalogId, String queryInput) {
        ajaxDataTableCtrl = new IDPAjaxDataTableCtrl();
        browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
        
        putParam('queryCatalogId', queryCatalogId);
        putParam('queryInput', queryInput);
        putParam('start', '0');
        putParam('length', '10');

        ajaxDataTableCtrl.processData();
        log('dataTableJson:'+ajaxDataTableCtrl.dataTableJson);

        IDPAjaxDataTableCtrl.DataTableWrapper wrapper = (IDPAjaxDataTableCtrl.DataTableWrapper)JSON.deserialize(ajaxDataTableCtrl.dataTableJson, IDPAjaxDataTableCtrl.DataTableWrapper.class);
        
        return wrapper;    
    }

    public static void updatePermissionByUserCatalogItem(String userName, String catalogItemName, boolean isAccess) {

        prepareMap();

        // Testing Data
        String testUserSelect           = userMap.get(userName).Id;
        String testCatalogItemSelect    = catalogItemMap.get(catalogItemName).Id;

        catalogPermissionCtrl = new IDPCatalogPermissonCtrl();

        Map <String, Map<String, Boolean>> oldResult = searchPermissionByUserCatalogItem(testUserSelect, testCatalogItemSelect);

        for (String userId : oldResult.keySet()) {
            
            Map<String, Boolean> catItemResult = oldResult.get(userId);
            for (String catItem : catItemResult.keySet()) {
                catItemResult.put(catItem, isAccess);
            }
        }
        
        catalogPermissionCtrl.tableMap = oldResult;
        catalogPermissionCtrl.save();
        catalogPermissionCtrl.result();
    }

    private static void updatePermissionByUserCatalog(String userName, String catalog, boolean isAccess) {

        prepareMap();

        // Testing Data
        String testUserSelect       = userMap.get(userName).Id;
        String testCatalogSelect    = catalogAllMap.get(catalog).Id;

        catalogPermissionCtrl = new IDPCatalogPermissonCtrl();

        Map <String, Map<String, Boolean>> oldResult = searchPermissionByUserCatalog(testUserSelect, testCatalogSelect);

        for (String userId : oldResult.keySet()) {
            
            Map<String, Boolean> catResult = oldResult.get(userId);
            for (String cat : catResult.keySet()) {
                catResult.put(cat, isAccess);
            }
        }
        
        catalogPermissionCtrl.tableMap = oldResult;
        catalogPermissionCtrl.save();
        catalogPermissionCtrl.result();
    }

    private static Map <String, Map<String, Boolean>> searchPermissionByUserCatalog(String userSelect, String catalogSelect) {
        catalogPermissionCtrl.permissionMatrixSelect = 'opt2';
        catalogPermissionCtrl.userSelect             = userSelect;   
        catalogPermissionCtrl.catalogSelect          = catalogSelect;
        catalogPermissionCtrl.result();      
        return catalogPermissionCtrl.tableMap;
    }

    private static Map <String, Map<String, Boolean>> searchPermissionByUserCatalogItem(String userSelect, String catalogItemSelect) {
        catalogPermissionCtrl.permissionMatrixSelect = 'opt3';
        catalogPermissionCtrl.userSelect             = userSelect;   
        catalogPermissionCtrl.catalogItemSelect      = catalogItemSelect;
        catalogPermissionCtrl.result();      
        return catalogPermissionCtrl.tableMap;
    }

    private static void removeAllPermission() {
        List<Catalog_Item_Permission__c> cip = [SELECT Id, Name FROM Catalog_Item_Permission__c];
        delete cip;
    }

    private static void defaultChecking(IDPAjaxDataTableCtrl.DataTableWrapper pWrapper) {
        system.assertEquals(1, pWrapper.recordsTotal);

        IDPAjaxDataTableCtrl.CatalogItemWrapper pCiWrapper = pWrapper.data.get(0);
        Catalog_Item__c ci = pCiWrapper.itemData;
        system.assertEquals(catalogItemName, ci.Item_Name__c);
    }

    // =======================================================================================================

    @isTest
    public static void testSearchByCatalog() {

        prepareMap();

        system.runAs(userMap.get('user1')) {
            wrapper = search(catalogAllMap.get(lv1CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }

        system.runAs(userMap.get('COUser')) {
            wrapper = search(catalogAllMap.get(lv1CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }
    }

    @isTest
    public static void testSearchByCatalogWithNoQueryInput() {

        prepareMap();

        system.runAs(userMap.get('user1')) {

            wrapper = search(catalogAllMap.get(lv1CatalogName).Id, null);
            //system.assertEquals(1, wrapper.recordsTotal);

            ciWrapper = wrapper.data.get(0);
            Catalog_Item__c ci = ciWrapper.itemData;
            //system.assertEquals(catalogItemName, ci.Item_Name__c);
        }

        system.runAs(userMap.get('COUser')) {

            wrapper = search(catalogAllMap.get(lv1CatalogName).Id, null);
            //system.assertEquals(1, wrapper.recordsTotal);

            ciWrapper = wrapper.data.get(0);
            Catalog_Item__c ci = ciWrapper.itemData;
            //system.assertEquals(catalogItemName, ci.Item_Name__c);
        }
    }

    @isTest
    public static void testSearchByLv2CatalogWithNoQueryInput() {

        prepareMap();

        system.runAs(userMap.get('user1')) {

            wrapper = search(catalogAllMap.get(lv2CatalogName).Id, null);
            //system.assertEquals(1, wrapper.recordsTotal);

            ciWrapper = wrapper.data.get(0);
            Catalog_Item__c ci = ciWrapper.itemData;
            //system.assertEquals(catalogItemName, ci.Item_Name__c);
        }

        system.runAs(userMap.get('COUser')) {

            wrapper = search(catalogAllMap.get(lv2CatalogName).Id, null);
            //system.assertEquals(1, wrapper.recordsTotal);

            ciWrapper = wrapper.data.get(0);
            Catalog_Item__c ci = ciWrapper.itemData;
            //system.assertEquals(catalogItemName, ci.Item_Name__c);
        }
    }


    @isTest
    public static void testRequesterSearchBylv2CatalogWithlv2Permission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();

        updatePermissionByUserCatalog('user1', lv2CatalogName, true);

        system.runAs(userMap.get('user1')) {
            wrapper = search(catalogAllMap.get(lv2CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCatalogOwnerSearchBylv2CatalogWithlv2Permission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalog('COUser', lv2CatalogName, true);

        system.runAs(userMap.get('COUser')) {
            wrapper = search(catalogAllMap.get(lv2CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }


    @isTest
    public static void testRequesterSearchBylv2CatalogWithCatalogItemPermission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalogItem('user1', catalogItemName, true);

        system.runAs(userMap.get('user1')) {
            wrapper = search(catalogAllMap.get(lv2CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCatalogOwnerSearchBylv2CatalogWithCatalogItemPermission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalogItem('COUser', catalogItemName, true);

        system.runAs(userMap.get('COUser')) {
            wrapper = search(catalogAllMap.get(lv2CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }

    @isTest
    public static void testRequesterSearchBylv1CatalogWithlv2Permission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalog('user1', lv2CatalogName, true);

        system.runAs(userMap.get('user1')) {
            wrapper = search(catalogAllMap.get(lv1CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCatalogOwnerSearchBylv1CatalogWithlv2Permission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalog('COUser', lv2CatalogName, true);

        system.runAs(userMap.get('COUser')) {
            wrapper = search(catalogAllMap.get(lv1CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }

    @isTest
    public static void testRequesterSearchBylv1CatalogWithCatalogItemPermission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalogItem('user1', catalogItemName, true);

        system.runAs(userMap.get('user1')) {
            wrapper = search(catalogAllMap.get(lv1CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCatalogOwnerSearchBylv1CatalogWithCatalogItemPermission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalogItem('COUser', catalogItemName, true);

        system.runAs(userMap.get('COUser')) {
            wrapper = search(catalogAllMap.get(lv1CatalogName).Id, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }

    @isTest
    public static void testSearchByAllCatalog() {

        prepareMap();

        system.runAs(userMap.get('user1')) {
            wrapper = search(Label.IDP_Shopping_Catalog_Search_Catalog_All, catalogItemName);
            defaultChecking(wrapper);
        }

        system.runAs(userMap.get('COUser')) {
            wrapper = search(Label.IDP_Shopping_Catalog_Search_Catalog_All, catalogItemName);
            defaultChecking(wrapper);
        }
    }

    @isTest
    public static void testRequesterSearchByAllCatalogWithlv2Permission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalog('user1', lv2CatalogName, true);

        system.runAs(userMap.get('user1')) {
            wrapper = search(Label.IDP_Shopping_Catalog_Search_Catalog_All, catalogItemName);
            defaultChecking(wrapper);
        }

        Test.stopTest();
    }

    @isTest
    public static void testCatalogOwnerSearchByAllCatalogWithlv2Permission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalog('COUser', lv2CatalogName, true);

        system.runAs(userMap.get('COUser')) {
            wrapper = search(Label.IDP_Shopping_Catalog_Search_Catalog_All, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }

    @isTest
    public static void testRequesterSearchByAllCatalogWithCatalogItemPermission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalogItem('user1', catalogItemName, true);

        system.runAs(userMap.get('user1')) {
            wrapper = search(Label.IDP_Shopping_Catalog_Search_Catalog_All, catalogItemName);
            defaultChecking(wrapper);
        }

        Test.stopTest();
    }

    @isTest
    public static void testCatalogOwnerSearchByAllCatalogWithCatalogItemPermission() {

        prepareMap();
        removeAllPermission();

        Test.startTest();
        updatePermissionByUserCatalogItem('COUser', catalogItemName, true);

        system.runAs(userMap.get('COUser')) {
            wrapper = search(Label.IDP_Shopping_Catalog_Search_Catalog_All, catalogItemName);
            defaultChecking(wrapper);
        }
        Test.stopTest();
    }

    

    @isTest
    public static void testSingleAddtoCart(){

        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();

            putParam('addToCartCatalogItemId', catalogItemMap.get(catalogItemName).Id);
            putParam('addToCartQuantity', '1');
            putParam('addToCartCItemUOM', '');

            browseCatalogCtrl.singleAddtoCart();

            List<Shopping_Cart_Item__c> modifiedShoppingCartItemList = [SELECT Id, Name, User__c, Catalog_Item__c, Unit_Of_Measure__c, Catalog_Item__r.Item_Name__c, Quantity__c
                                                                        FROM Shopping_Cart_Item__c 
                                                                        WHERE User__c = :UserInfo.getUserId() 
                                                                        AND Status__c = :IDPConstant.SHOPPING_CART_STATUS_OPEN];

            log('modifiedShoppingCartItemList.get(0).Catalog_Item__c:'+modifiedShoppingCartItemList.get(0).Catalog_Item__c);
            log('catalogItemMap:'+catalogItemMap);
            
            system.assertEquals(1, modifiedShoppingCartItemList.size());
            system.assertEquals(catalogItemMap.get(catalogItemName).Id, modifiedShoppingCartItemList.get(0).Catalog_Item__c);
        }
    }

    @isTest
    public static void testAddToCart(){

        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
                
            Map<String, Shopping_Cart_Item__c> existingShoppingCartItemMap = browseCatalogCtrl.existingShoppingCartItemMap;
            Map<String, Favourite_Item__c> existingFavouriteItemMap = browseCatalogCtrl.existingFavouriteItemMap;

            String checkedCatalogItemIdQuantityJSON = '{"editedCatalogItemList":[{"catalogItemId":"'+catalogItemMap.get(catalogItemName).Id+'","checked":true,"quantity":"1","unitOfMeasure":""}]}';
            String mMode = Label.IDP_Mass_Add_Mode_Add_To_Cart;
            putParam('checkedCatalogItemIdQuantityJSON', checkedCatalogItemIdQuantityJSON);
            putParam('mMode', mMode);

            browseCatalogCtrl.massAction();
            String message = browseCatalogCtrl.message;
            system.assertEquals(Label.IDP_Mass_Add_to_Cart_Message, message);

            List<Shopping_Cart_Item__c> modifiedShoppingCartItemList = [SELECT Id, Name, User__c, Catalog_Item__c, Unit_Of_Measure__c, Catalog_Item__r.Item_Name__c, Quantity__c
                                                                        FROM Shopping_Cart_Item__c 
                                                                        WHERE User__c = :UserInfo.getUserId() 
                                                                        AND Status__c = :IDPConstant.SHOPPING_CART_STATUS_OPEN];

            system.assertEquals(1, modifiedShoppingCartItemList.size());
            system.assertEquals(catalogItemMap.get(catalogItemName).Id, modifiedShoppingCartItemList.get(0).Catalog_Item__c);


            //public void massAction() {
            //    String jsonString = Apexpages.currentPage().getParameters().get('checkedCatalogItemIdQuantityJSON');
            //    String massMode= Apexpages.currentPage().getParameters().get('mMode');
            //    message = IDPCommonUtils.massAction(existingShoppingCartItemMap, existingFavouriteItemMap, jsonString, massMode);    
            //}
            //
            //
        }
    }

    @isTest
    public static void testSingleAddtoFavourite(){

        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();

            putParam('addToFavouriteCatalogItemId', catalogItemMap.get(catalogItemName).Id);

            browseCatalogCtrl.singleAddRemoveFavouriteItem();

            List<Favourite_Item__c> modifiedFavouriteItemList = [SELECT Id, Name, User__c, Catalog_Item__c
                                                                        FROM Favourite_Item__c 
                                                                        WHERE User__c = :UserInfo.getUserId()];

            system.assertEquals(1, modifiedFavouriteItemList.size());
            system.assertEquals(catalogItemMap.get(catalogItemName).Id, modifiedFavouriteItemList.get(0).Catalog_Item__c);
        }
    }
    
    @isTest
    public static void testAddToFavourite(){

        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
                
            Map<String, Shopping_Cart_Item__c> existingShoppingCartItemMap = browseCatalogCtrl.existingShoppingCartItemMap;
            Map<String, Favourite_Item__c> existingFavouriteItemMap = browseCatalogCtrl.existingFavouriteItemMap;
            String checkedCatalogItemIdQuantityJSON = '{"editedCatalogItemList":[{"catalogItemId":"'+catalogItemMap.get(catalogItemName).Id+'","checked":true,"quantity":"1","unitOfMeasure":""}]}';
            String mMode = Label.IDP_Mass_Add_Mode_Add_To_Favourite_List;
            putParam('checkedCatalogItemIdQuantityJSON', checkedCatalogItemIdQuantityJSON);
            putParam('mMode', mMode);

            browseCatalogCtrl.massAction();
            String message = browseCatalogCtrl.message;
            system.assertEquals(Label.IDP_Mass_Add_to_Favourite_List_Message, message);

            List<Favourite_Item__c> modifiedFavouriteItemList = [SELECT Id, Name, User__c, Catalog_Item__c
                                                                        FROM Favourite_Item__c 
                                                                        WHERE User__c = :UserInfo.getUserId()];

            system.assertEquals(1, modifiedFavouriteItemList.size());
            system.assertEquals(catalogItemMap.get(catalogItemName).Id, modifiedFavouriteItemList.get(0).Catalog_Item__c);
            
            Map<String, Favourite_Item__c> favMap = browseCatalogCtrl.getExistingFavouriteItemMap();
            system.assertEquals(1, favMap.keySet().size());

        }
    }

    @isTest
    public static void testSingleInactivateCatalogItem() {

        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
            
            Catalog_Item__c firstCI = catalogItemMap.get(catalogItemMap.keySet().iterator().next());

            putParam('inactivateCatalogItemId', firstCI.Id);
            browseCatalogCtrl.singleInactivateCatalogItem();

            List<Catalog_Item__c> inactiveCatalogItemList = [SELECT Name, Id, Status__c FROM Catalog_Item__c WHERE Id = :firstCI.Id Limit 1];

            system.assertEquals(IDPConstant.CATALOG_ITEM_STATUS_INACTIVE, inactiveCatalogItemList.get(0).Status__c);
        }
    }

    @isTest
    public static void testGetMethod() {
       
        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
                
            Map<String, Exchange_Rate__c> fromToCurrencyIdExchangeRateMap = browseCatalogCtrl.fromToCurrencyIdExchangeRateMap;
            String debugString = browseCatalogCtrl.debugString ;
            String fromToCurrencyIdExchangeRateMapJSON = browseCatalogCtrl.fromToCurrencyIdExchangeRateMapJSON ;
            String catalogPermissionJSON = browseCatalogCtrl.catalogPermissionJSON ;
        }
    }

    @isTest
    public static void testRedirectToCreateCatalogItem() {
        
        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
            browseCatalogCtrl.redirectToCreateCatalogItem();    
        }
    }

    @isTest
    public static void testRedirectToCreateNonCatalogItem() {
        
        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
            browseCatalogCtrl.redirectToCreateNonCatalogItem();    
        }
    }

    @isTest
    public static void testRedirectPage() {
        
        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
            browseCatalogCtrl.redirectPage = Label.IDP_Path_IDPShoppingCartVFP;
            browseCatalogCtrl.selectedQueryCatalogId = catalogAllMap.get(lv1CatalogName).Id;
            browseCatalogCtrl.queryInput = catalogAllMap.get(lv1CatalogName).Id;
            browseCatalogCtrl.selectedDisplayCurrencyName = 'USD';
            browseCatalogCtrl.selectedSortingFieldName = 'Item_Name__c Asc';
            browseCatalogCtrl.dataTablePageNumber = 1;
            browseCatalogCtrl.dataTablePageLength = 1;
            browseCatalogCtrl.savedIsSearch = true;
            browseCatalogCtrl.breadcrumbs = '/';
            browseCatalogCtrl.redirectToPage();    
            
            browseCatalogCtrl.redirectPage = Label.IDP_Path_IDPFavouriteListVFP;
            browseCatalogCtrl.redirectToPage();    
        }
    }

    @isTest
    public static void testInitial() {

        prepareMap();

        system.runAs(userMap.get('user1')) {

            browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
            putParam(Label.IDP_Parameter_Name_Catalog, catalogAllMap.get(lv1CatalogName).Id);
            putParam(Label.IDP_Parameter_Name_Input, catalogAllMap.get(lv1CatalogName).Id);
            putParam(Label.IDP_Parameter_Name_Display_Currency, 'USD');
            putParam(Label.IDP_Parameter_Name_Sorting_Field, 'Item_Name__c Asc');
            putParam(Label.IDP_Parameter_Name_DataTable_Page_Number, '1');
            putParam(Label.IDP_Parameter_Name_DataTable_Page_Length, '1');
            putParam(Label.IDP_Parameter_Name_Is_Search, 'true');
            putParam(Label.IDP_Parameter_Name_Breadcrumbs, '/');
            
            browseCatalogCtrl.initial();
        }
    }

    public static void putParam(String key, String val) {
        TestIDPUtility.putParam(key, val);
    }

    public static void log(String msg) {
        TestIDPUtility.log(msg);
    }
}