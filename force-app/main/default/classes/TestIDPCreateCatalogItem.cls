@isTest
public class TestIDPCreateCatalogItem {

    public static TestIDPPreparation idpPrepare;
    public static IDPAjaxDataTableCtrl ajaxDataTableCtrl;
    public static IDPBrowseCatalogVFPCtrl browseCatalogCtrl;
    public static IDPCreateCatalogItemVFPCtrl createCatalogItemCtrl;

    public static Map<String, Supplier__c> supplierMap;
    public static Map<String, Catalog__c> catalogAllMap;
    public static Map<String, Catalog_Item__c> catalogItemMap;
    public static Map<String, User> userMap;
    public static Map<String, Employee__c> employeeMap;
    public static Map<String, IDP_Policy__c> idpPolicyMap;

    private static String catalogName = 'Administration';
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
        supplierMap = TestIDPUtility.getSupplierMap();
    }

    @isTest
    public static void testCreateCatalogItem() {

        prepareMap();

        putParam('mode', IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD);

        createCatalogItemCtrl = new IDPCreateCatalogItemVFPCtrl();

        // [00, 01, 02, ...]
        Map<String, Catalog_Item__c> keyCatalogItemListMap = createCatalogItemCtrl.keyCatalogItemListMap;

        Catalog_Item__c ci_1 = keyCatalogItemListMap.get('00');
        ci_1.Catalog__c = catalogAllMap.get(catalogName).Id;
        ci_1.Item_Name__c = 'Test Administration Item 1';
        ci_1.Description__c = 'Test Descirption';
        ci_1.Unit_Of_Measure__c = 'EA';
        ci_1.Last_Supplier__c = supplierMap.get('SUPPLIER1').Id;
        ci_1.Reference_Price__c = 100;
        ci_1.Expiry_Date__c = Date.newInstance(2018, 12, 31);
        ci_1.Minimum_Order_Quantity__c = 10;
        ci_1.Lead_Time_Format__c = 'WD';
        ci_1.Lead_Time_Days__c = 5;

        createCatalogItemCtrl.createCatalogItem();

        Catalog_Item__c final_ci_1 = [SELECT Id, Catalog__c, Item_Name__c, Is_Catalog__c, Description__c, Unit_Of_Measure__c, Last_Supplier__c, Reference_Price__c, Expiry_Date__c, Minimum_Order_Quantity__c, Lead_Time_Format__c, Lead_Time_Days__c FROM Catalog_Item__c WHERE Item_Name__c = 'Test Administration Item 1' LIMIT 1];
        system.assertEquals('Test Administration Item 1', final_ci_1.Item_Name__c);
        system.assertEquals(true, final_ci_1.Is_Catalog__c);
    }

    @isTest
    public static void testCreateNonCatalogItem() {

        prepareMap();

        system.runAs(userMap.get('COUser')) {

            putParam('mode', IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM);

            createCatalogItemCtrl = new IDPCreateCatalogItemVFPCtrl();

            // [00, 01, 02, ...]
            Map<String, Catalog_Item__c> keyCatalogItemListMap = createCatalogItemCtrl.keyCatalogItemListMap;
            Map<String, Shopping_Cart_Item__c> keyShoppingCartItemMap = createCatalogItemCtrl.keyShoppingCartItemMap;

            Catalog_Item__c ci_1 = keyCatalogItemListMap.get('00');
            Shopping_Cart_Item__c sci_1 = keyShoppingCartItemMap.get('00');
            ci_1.Catalog__c = catalogAllMap.get(catalogName).Id;
            ci_1.Item_Name__c = 'Test Administration Item 1';
            ci_1.Description__c = 'Test Descirption';
            ci_1.Unit_Of_Measure__c = 'EA';
            ci_1.Last_Supplier__c = supplierMap.get('SUPPLIER1').Id;
            ci_1.Reference_Price__c = 100;
            ci_1.Expiry_Date__c = Date.newInstance(2018, 12, 31);
            ci_1.Minimum_Order_Quantity__c = 10;
            ci_1.Lead_Time_Format__c = 'WD';
            ci_1.Lead_Time_Days__c = 5;
            sci_1.Quantity__c = 10;

            createCatalogItemCtrl.mode = IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM;
            createCatalogItemCtrl.createCatalogItem();

            Catalog_Item__c final_ci_1 = [SELECT Id, Catalog__c, Item_Name__c, Is_Catalog__c, Description__c, Unit_Of_Measure__c, Last_Supplier__c, Reference_Price__c, Expiry_Date__c, Minimum_Order_Quantity__c, Lead_Time_Format__c, Lead_Time_Days__c FROM Catalog_Item__c WHERE Item_Name__c = 'Test Administration Item 1' LIMIT 1];
            system.assertEquals('Test Administration Item 1', final_ci_1.Item_Name__c);
            system.assertEquals(false, final_ci_1.Is_Catalog__c);
        }
    }

    @isTest
    public static void testValidateCatalogItem() {

        prepareMap();

        putParam('mode', IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD);

        createCatalogItemCtrl = new IDPCreateCatalogItemVFPCtrl();

        // [00, 01, 02, ...]
        Map<String, Catalog_Item__c> keyCatalogItemListMap = createCatalogItemCtrl.keyCatalogItemListMap;

        Catalog_Item__c ci_1 = keyCatalogItemListMap.get('00');
        ci_1.Item_Name__c = 'Test Administration Item 1';
        ci_1.Last_Supplier__c = supplierMap.get('SUPPLIER1').Id;
        ci_1.Lead_Time_Format__c = 'WD';
        ci_1.Reference_Price__c = 10;

        createCatalogItemCtrl.createCatalogItem();

        Catalog_Item__c ci_2 = keyCatalogItemListMap.get('01');
        ci_2.Catalog__c = catalogAllMap.get(catalogName).Id;
        ci_2.Description__c = 'Test';
        ci_2.Minimum_Order_Quantity__c = 5;
        ci_2.Lead_Time_Days__c = 5;
        ci_2.Expiry_Date__c = Date.newInstance(2018, 12, 31);


        createCatalogItemCtrl.createCatalogItem();

        String message = createCatalogItemCtrl.message;
        List<Catalog_Item__c> final_ci_list = [SELECT Id, Catalog__c, Item_Name__c, Is_Catalog__c, Description__c, Unit_Of_Measure__c, Last_Supplier__c, Reference_Price__c, Expiry_Date__c, Minimum_Order_Quantity__c, Lead_Time_Format__c, Lead_Time_Days__c FROM Catalog_Item__c WHERE Item_Name__c = 'Test Administration Item 1' LIMIT 1];
        system.assertEquals(0, final_ci_list.size());

    }

    @isTest
    public static void testValidateNonCatalogItem() {

        prepareMap();

        system.runAs(userMap.get('COUser')) {

            putParam('mode', IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM);

            createCatalogItemCtrl = new IDPCreateCatalogItemVFPCtrl();

            // [00, 01, 02, ...]
            Map<String, Catalog_Item__c> keyCatalogItemListMap = createCatalogItemCtrl.keyCatalogItemListMap;
            Map<String, Shopping_Cart_Item__c> keyShoppingCartItemMap = createCatalogItemCtrl.keyShoppingCartItemMap;
            Map<String, Supplier_Item__c> keySupplierItemMap = createCatalogItemCtrl.keySupplierItemMap;

            Catalog_Item__c ci_1 = keyCatalogItemListMap.get('00');
            Shopping_Cart_Item__c sci_1 = keyShoppingCartItemMap.get('00');
            ci_1.Item_Name__c = 'Test Administration Item 1';
            ci_1.Last_Supplier__c = supplierMap.get('SUPPLIER1').Id;
            ci_1.Lead_Time_Format__c = 'WD';

            Supplier_Item__c si_1 = keySupplierItemMap.get('00');
            si_1.Supplier__c = supplierMap.get('SUPPLIER1').Id;
            si_1.Expiry_Date__c = Date.newInstance(2017, 12, 31);
            si_1.Lead_Time_Format__c = 'WD';

            Catalog_Item__c ci_2 = keyCatalogItemListMap.get('01');
            ci_2.Description__c = 'Test';
            ci_2.Reference_Price__c = 10;
            ci_2.Lead_Time_Days__c = 5;

            Supplier_Item__c si_2 = keySupplierItemMap.get('01');
            si_2.Minimum_Order_Quantity__c = 5;
            si_2.Price__c = 10;
            si_2.Lead_Time_Days__c = 5;
            
            createCatalogItemCtrl.mode = IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM;
            createCatalogItemCtrl.createCatalogItem();

            String message = createCatalogItemCtrl.message;
            List<Catalog_Item__c> final_ci_list = [SELECT Id, Catalog__c, Item_Name__c, Is_Catalog__c, Description__c, Unit_Of_Measure__c, Last_Supplier__c, Reference_Price__c, Expiry_Date__c, Minimum_Order_Quantity__c, Lead_Time_Format__c, Lead_Time_Days__c FROM Catalog_Item__c WHERE Item_Name__c = 'Test Administration Item 1' LIMIT 1];
            system.assertEquals(0, final_ci_list.size());
        }
    }

    @isTest
    public static void testRowAction() {

        prepareMap();

        createCatalogItemCtrl = new IDPCreateCatalogItemVFPCtrl();

        // [00, 01, 02, ...]
        Map<String, Catalog_Item__c> keyCatalogItemListMap = createCatalogItemCtrl.keyCatalogItemListMap;
        Map<String, Supplier_Item__c> keySupplierItemMap = createCatalogItemCtrl.keySupplierItemMap;

        // Create Catalog Item
        Catalog_Item__c ci_1 = keyCatalogItemListMap.get('00');
        ci_1.Catalog__c = catalogAllMap.get(catalogName).Id;
        ci_1.Item_Name__c = 'Test Administration Item 1';
        ci_1.Description__c = 'Test Descirption';
        ci_1.Unit_Of_Measure__c = 'EA';
        ci_1.Last_Supplier__c = supplierMap.get('SUPPLIER1').Id;
        ci_1.Reference_Price__c = 100;
        ci_1.Expiry_Date__c = Date.newInstance(2018, 12, 31);
        ci_1.Minimum_Order_Quantity__c = 10;
        ci_1.Lead_Time_Format__c = 'Working Day';
        ci_1.Lead_Time_Days__c = 5;

        Supplier_Item__c si_1 = keySupplierItemMap.get('00');
        si_1.Supplier__c = supplierMap.get('SUPPLIER1').Id;

        // Copy Row
        putParam('rowNumber', '0');
        createCatalogItemCtrl.copyRow();

        keyCatalogItemListMap = createCatalogItemCtrl.keyCatalogItemListMap;

        Catalog_Item__c ci_2 = keyCatalogItemListMap.get('01');
        system.assertEquals(ci_1.Catalog__c, ci_2.Catalog__c);
        system.assertEquals(ci_1.Item_Name__c, ci_2.Item_Name__c);
        system.assertEquals(ci_1.Description__c, ci_2.Description__c);
        system.assertEquals(ci_1.Unit_Of_Measure__c, ci_2.Unit_Of_Measure__c);
        system.assertEquals(ci_1.Last_Supplier__c, ci_2.Last_Supplier__c);
        system.assertEquals(ci_1.Reference_Price__c, ci_2.Reference_Price__c);
        system.assertEquals(ci_1.Expiry_Date__c, ci_2.Expiry_Date__c);
        system.assertEquals(ci_1.Minimum_Order_Quantity__c, ci_2.Minimum_Order_Quantity__c);
        system.assertEquals(ci_1.Lead_Time_Format__c, ci_2.Lead_Time_Format__c);
        system.assertEquals(ci_1.Lead_Time_Days__c, ci_2.Lead_Time_Days__c);

        // Clear Row
        putParam('rowNumber', '1');
        createCatalogItemCtrl.clearRow();

        keyCatalogItemListMap = createCatalogItemCtrl.keyCatalogItemListMap;
        ci_2 = keyCatalogItemListMap.get('01');
        system.assertEquals(null, ci_2.Catalog__c);
        system.assertEquals(null, ci_2.Item_Name__c);

        putParam('supplierKey', '00');
        createCatalogItemCtrl.supplierOnChnageAction();
    }

    // createTempRow
    // clearRow
    // copyRow
    // createCatalogItem
    // validateInput
    // validateInput_before_lead_Time
    // validateInput_beforeSupplier

    public static void log(String msg) {
        TestIDPUtility.log(msg);
    }

    public static void putParam(String key, String val) {
        TestIDPUtility.putParam(key, val);
    }

}