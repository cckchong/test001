@isTest
public class TestIDPPurchaseOrderResultCtrl{
    
    public static IDPCreatePurchaseOrderCtrl createPOCtrl;
    public static IDPPurchaseOrderCtrl purchaseOrderCtrl;
    public static IDPPurchaseOrderOverwriteNewCtrl poOverwriteNewCtrl;
    public static IDPPurchaseOrderOverwriteViewCtrl poOverwriteViewCtrl;
    public static IDPPurchaseOrderItemOverwriteViewCtrl poiOverwriteViewCtrl;

    public static Map<String, User> userMap;
    public static Map<String, Catalog__c> catalogAllMap;
    public static Map<String, Catalog_Item__c> catalogItemMap;
    public static Map<String, Employee_Administrator__c> employeeAdministratorMap;
    public static Map<String, IDP_Policy__c> idpPolicyMap;
    public static Map<String, Site__c> siteMap;
    public static Map<String, Supplier__c> supplierMap;
    public static Map<String, IDP_Budget__c> budgetMap;

    private static String catalogItemName = 'Administration_Motor Vehicles_Item_1';
    private static List<Purchase_Order__c> poList;
    private static List<Purchase_Order_Item__c> poiList;
    
    @testSetup
    public static void testSetup() {
        Map<String, Map<String, sObject>> preparedMap = TestIDPUtility.prepare(false);

        supplierMap = new Map<String, Supplier__c>();
        for (String key : preparedMap.get('supplierMap').keySet()) {
            supplierMap.put(key, (Supplier__c)preparedMap.get('supplierMap').get(key));
        }

        List<Purchase_Request__c> insertPrList = new List<Purchase_Request__c>();
        List<Purchase_Request_Item__c> insertPriList = new List<Purchase_Request_Item__c>();
        IDP_Budget__c  a = preparedMap.get('budgetMap').values();
        Purchase_Request__c pr_1 = new Purchase_Request__c(
                                 //RecordTypeId='012p00000008u9FAAQ',
                                 Status__c='AP',
                                 On_Behalf_of__c=preparedMap.get('employeeAdministratorMap').get('Testing (HKOCOUser)').Id,
                                 IDP_Policy__c=preparedMap.get('idpPolicyMap').get('HKO').Id,
                                 Catalog__c=preparedMap.get('catalogAllMap').get('Administration').Id,
                                 Delivery_Site__c=preparedMap.get('siteMap').get('HKO').Id,
                                 //Is_Budget__c=true,
                                 Catalog_Name__c='Administration',
                                 Budget_Forecast__c='Within Budget',
                                 Need_by_Date__c= System.today().addDays(10),
                                 IDP_Budget__c =preparedMap.get('budgetMap').get('HKO_IT_IT_General').Id
                                );

        Purchase_Request__c pr_2 = new Purchase_Request__c(
                                 //RecordTypeId='012p00000008u9FAAQ',
                                 Status__c='AP',
                                 On_Behalf_of__c=preparedMap.get('employeeAdministratorMap').get('Testing (HKOCOUser)').Id,
                                 IDP_Policy__c=preparedMap.get('idpPolicyMap').get('HKO').Id,
                                 Catalog__c=preparedMap.get('catalogAllMap').get('Administration').Id,
                                 Delivery_Site__c=preparedMap.get('siteMap').get('HKO').Id,
                                 //Is_Budget__c=true,
                                 Catalog_Name__c='Administration',
                                 Budget_Forecast__c='Within Budget',
                                 Need_by_Date__c=Date.newInstance(2017,5,31),
                                 IDP_Budget__c =preparedMap.get('budgetMap').get('HKO_IT_IT_General').Id
                                );

        insertPrList.add(pr_1);
        insertPrList.add(pr_2);
        insert insertPrList;


        Purchase_Request_Item__c pri_1 = new Purchase_Request_Item__c(
                                             //RecordTypeId='012p00000008t4YAAQ',
                                             Status__c='AP',
                                             Catalog_Item__c=preparedMap.get('catalogItemMap').get('Administration_Motor Vehicles_Item_1').Id,
                                             Purchase_Request__c=pr_1.Id,
                                             Unit_of_Measure__c='EA',
                                             Quantity__c=1,
                                             Is_Direct_fulfillment__c=false,
                                             Number__c=1,
                                             Budget_Exchange_Rate__c=0,
                                             Supplier__c=preparedMap.get('supplierMap').get('SUPPLIER2').Id,
                                             Price__c=500,
                                             Currency__c=supplierMap.get('SUPPLIER2').Currency__c
                                            );

        Purchase_Request_Item__c pri_2 = new Purchase_Request_Item__c(
                                             //RecordTypeId='012p00000008t4YAAQ',
                                             Status__c='AP',
                                             Catalog_Item__c=preparedMap.get('catalogItemMap').get('Administration_Motor Vehicles_Item_1').Id,
                                             Purchase_Request__c=pr_2.Id,
                                             Unit_of_Measure__c='EA',
                                             Quantity__c=10,
                                             Is_Direct_fulfillment__c=false,
                                             Number__c=1,
                                             Budget_Exchange_Rate__c=0,
                                             Supplier__c=preparedMap.get('supplierMap').get('SUPPLIER2').Id,
                                             Price__c=500,
                                             Currency__c=supplierMap.get('SUPPLIER2').Currency__c
                                            );

        insertPriList.add(pri_1);
        insertPriList.add(pri_2);
        insert insertPriList;


        List<Purchase_Order__c> insertPoList = new List<Purchase_Order__c>();
        List<Purchase_Order_Item__c> insertPoiList = new List<Purchase_Order_Item__c>();
        Purchase_Order__c po_1 = new Purchase_Order__c(
                                             //RecordTypeId='012p00000008u95AAA',
                                             Supplier__c=preparedMap.get('supplierMap').get('SUPPLIER2').Id,
                                             Status__c='DF',
                                             Delivery_Site__c=preparedMap.get('siteMap').get('HKO').Id,
                                             Currency__c=supplierMap.get('SUPPLIER2').Currency__c,
                                             Delivery_Date__c=Date.Today().adddays(10),
                                             Total_Tax__c=0,
                                             Total_Shipping_Cost__c=0,
                                             Delivery_Method__c='015',
                                             Payment_Method__c='CA',
                                             Payment_Terms__c='10D',
                                             Delivery_Terms__c='FOB',
                                             Is_All_Delivered__c=false,
                                             Total_Other_Cost__c=0.00,
                                             Batch_ID__c = '1234',
                                             Delivery_To__c='HKO');

        insertPoList.add(po_1);
        insert insertPoList;

        Purchase_Order_Item__c poi_1 = new Purchase_Order_Item__c(
                                             //RecordTypeId='012p00000008u9AAAQ',
                                             Purchase_Order__c=po_1.Id,
                                             Catalog_Item__c=preparedMap.get('catalogItemMap').get('Administration_Motor Vehicles_Item_1').Id,
                                             Quantity__c=1,
                                             Price__c=500.00,
                                             Status__c='DF',
                                             Delivery_Date__c=Date.Today().adddays(10),
                                             Currency__c=supplierMap.get('SUPPLIER2').Currency__c,
                                             Item_Description__c='testing21',
                                             Received_Quantity__c=0,
                                             Supplier__c=preparedMap.get('supplierMap').get('SUPPLIER2').Id,
                                             Unit_of_Measure__c='EA',
                                             Tech_PO_Currency_PRI_Other_Cost__c=0.00,
                                             Tech_PO_Currency_PRI_Shipping__c=0.00,
                                             Tech_PO_Currency_PRI_Tax__c=0.00,
                                             Tech_Price__c=500.00,
                                             Number__c=1,
                                             Tech_PO_Currency_PRI_Amount__c=500.00);

        Purchase_Order_Item__c poi_2 = new Purchase_Order_Item__c(
                                             //RecordTypeId='012p00000008u9AAAQ',
                                             Purchase_Order__c=po_1.Id,
                                             Catalog_Item__c=preparedMap.get('catalogItemMap').get('Administration_Motor Vehicles_Item_1').Id,
                                             Quantity__c=10,
                                             Price__c=500.00,
                                             Status__c='DF',
                                             Delivery_Date__c=Date.today().adddays(10),
                                             Currency__c=supplierMap.get('SUPPLIER2').Currency__c,
                                             Item_Description__c='testing21',
                                             Received_Quantity__c=0,
                                             Supplier__c=preparedMap.get('supplierMap').get('SUPPLIER2').Id,
                                             Unit_of_Measure__c='EA',
                                             Tech_PO_Currency_PRI_Other_Cost__c=0.00,
                                             Tech_PO_Currency_PRI_Shipping__c=0.00,
                                             Tech_PO_Currency_PRI_Tax__c=0.00,
                                             Tech_Price__c=500.00,
                                             Number__c=2,
                                             Tech_PO_Currency_PRI_Amount__c=5000.00);

        insertPoiList.add(poi_1);
        insertPoiList.add(poi_2);
        insert insertPoiList;

        pri_1.Purchase_Order__c = po_1.Id;
        pri_1.Purchase_Order_Item__c = poi_1.Id;
        update pri_1;

        pri_2.Purchase_Order__c = po_1.Id;
        pri_2.Purchase_Order_Item__c = poi_2.Id;
        update pri_2;
    }
    
     public static void prepareMap() {
        userMap = TestIDPUtility.getUserMap();
        catalogItemMap = TestIDPUtility.getCatalogItemMap();
        employeeAdministratorMap = TestIDPUtility.getEmployeeAdministratorMap();
        idpPolicyMap = TestIDPUtility.getIdpPolicyMap();
        catalogAllMap = TestIDPUtility.getCatalogAllMap();
        siteMap = TestIDPUtility.getSiteMap();
        supplierMap = TestIDPUtility.getSupplierMap();
        budgetMap = TestIDPUtility.getBudgetMap();
    }

    @isTest
    public static void testSaveAction() {
        IDPPurchaseOrderResultCtrl POC =  new IDPPurchaseOrderResultCtrl ();
        putParam('bid', '1234');
        POC =  new IDPPurchaseOrderResultCtrl ();
        PageReference pr = POC.backAction();
        system.assertNotEquals(null, pr);
    }
    
    public static void putParam(String key, String val) {
        TestIDPUtility.putParam(key, val);
    }

}