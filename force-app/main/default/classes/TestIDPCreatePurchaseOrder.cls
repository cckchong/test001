@isTest
private class TestIDPCreatePurchaseOrder {
    
    public static IDPCreatePurchaseOrderCtrl createPOCtrl;

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
        Purchase_Request__c pr_1 = new Purchase_Request__c(
                                 //RecordTypeId='012p00000008u9FAAQ',
                                 Status__c='AP',
                                 On_Behalf_of__c=preparedMap.get('employeeAdministratorMap').get('Testing (HKOCOUser)').Id,
                                 IDP_Policy__c=preparedMap.get('idpPolicyMap').get('HKO').Id,
                                 Catalog__c=preparedMap.get('catalogAllMap').get('Administration').Id,
                                 Delivery_Site__c=preparedMap.get('siteMap').get('HKO').Id,
                                 Catalog_Name__c='Administration',
                                 Budget_Forecast__c='Within Budget',
                                 Need_by_Date__c=Date.today().adddays(10),
                                 IDP_Budget__c=preparedMap.get('budgetMap').get('HKO_IT_IT_General').Id
                                );

        Purchase_Request__c pr_2 = new Purchase_Request__c(
                                 //RecordTypeId='012p00000008u9FAAQ',
                                 Status__c='AP',
                                 On_Behalf_of__c=preparedMap.get('employeeAdministratorMap').get('Testing (HKOCOUser)').Id,
                                 IDP_Policy__c=preparedMap.get('idpPolicyMap').get('HKO').Id,
                                 Catalog__c=preparedMap.get('catalogAllMap').get('Administration').Id,
                                 Delivery_Site__c=preparedMap.get('siteMap').get('HKO').Id,
                                 Catalog_Name__c='Administration',
                                 Budget_Forecast__c='Within Budget',
                                 Need_by_Date__c=Date.today().adddays(10),
                                 IDP_Budget__c=preparedMap.get('budgetMap').get('HKO_IT_IT_General').Id
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
                                             Supplier__c=preparedMap.get('supplierMap').get('SUPPLIER1').Id,
                                             Price__c=500,
                                             Currency__c=supplierMap.get('SUPPLIER1').Currency__c
                                            );

        Purchase_Request_Item__c pri_2 = new Purchase_Request_Item__c(
                                             //RecordTypeId='012p00000008t4YAAQ',
                                             Status__c='AP',
                                             Catalog_Item__c=preparedMap.get('catalogItemMap').get('Administration_Motor Vehicles_Item_1').Id,
                                             Purchase_Request__c=pr_2.Id,
                                             Unit_of_Measure__c='EA',
                                             Quantity__c=1,
                                             Is_Direct_fulfillment__c=false,
                                             Number__c=1,
                                             Budget_Exchange_Rate__c=0,
                                             Supplier__c=preparedMap.get('supplierMap').get('SUPPLIER1').Id,
                                             Price__c=500,
                                             Currency__c=supplierMap.get('SUPPLIER1').Currency__c
                                            );

        insertPriList.add(pri_1);
        insertPriList.add(pri_2);
        insert insertPriList;
        
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
        
        String userid = UserInfo.getUserId();
        system.runAs(userMap.get('admin')){
            for (Group gp : [ SELECT Id, Name, DeveloperName, type  FROM Group
                 where DeveloperName  = 'IDP_Catalog_Administration'  and  type = 'Regular'] ) {
                 insert new GroupMember(GroupId = gp.id, UserOrGroupId = userid  );
            }
        }
    }

    @isTest
    public static void testSearchNotOrderedPurchaseRequestItemMap() {

        prepareMap();
         
        createPOCtrl = new IDPCreatePurchaseOrderCtrl();
        String siteId = siteMap.get('HKO').Id;
        siteId = siteId.substring(0, 15);
        createPOCtrl.selectedDeliverySite = '['+siteId+']';
        createPOCtrl.selectedSupplier = supplierMap.get('SUPPLIER1').Id;
        createPOCtrl.searchFromDate = Date.newInstance(1900, 1, 1);
        createPOCtrl.searchToDate = Date.newInstance(2099, 12, 31);

        createPOCtrl.searchNotOrderedPurchaseRequestItemMap();
        List<IDPCreatePurchaseOrderLineCtrl> cpoLineList = createPOCtrl.cpoLineList;

        system.assert(cpoLineList.size() > 0);
    }

    @isTest
    public static void testCreateAndAddToExisting() {

        prepareMap();
        Test.startTest();
        createPOCtrl = new IDPCreatePurchaseOrderCtrl();
        List<IDPCreatePurchaseOrderLineCtrl> cpoLineList;

        String siteId = siteMap.get('HKO').Id;
        siteId = siteId.substring(0, 15);
        createPOCtrl.selectedDeliverySite = '['+siteId+']';
        createPOCtrl.selectedSupplier = supplierMap.get('SUPPLIER1').Id;

        createPOCtrl.searchNotOrderedPurchaseRequestItemMap();
        cpoLineList = createPOCtrl.cpoLineList;

        cpoLineList.get(0).isChecked = true;

        poList = showPOStatus('Before Create draft');
        poiList = showPOIStatus('Before Create draft');

        Integer befPOListSize = poList.size();
        Integer befPOIListSize = poiList.size();
        createPOCtrl.createDraftPurchaseOrderAction();

        poList = showPOStatus('After Create draft');
        poiList = showPOIStatus('After Create draft');

        system.assertEquals(befPOListSize+1, poList.size());
        system.assertEquals(befPOIListSize+1, poiList.size());

        createPOCtrl.searchNotOrderedPurchaseRequestItemMap();
        createPOCtrl.updateDraftPurchaseOrderSelectOptionListAction();
        cpoLineList = createPOCtrl.cpoLineList;
        cpoLineList.get(0).isChecked = true;

        createPOCtrl.selectedPurchaseOrder = poList.get(0).Id;
        createPOCtrl.addToExistingPurchaseOrderAction();

        poList = showPOStatus('After Add to Existing');
        poiList = showPOIStatus('After Add to Existing');

        system.assertEquals(befPOListSize+1, poList.size());
        system.assertEquals(befPOIListSize+2, poiList.size());

        createPOCtrl.viewExistingPurchaseOrder();
        Test.stopTest();
    }

    @isTest
    public static void testCancelItem() {

        prepareMap();
        Test.startTest();
        createPOCtrl = new IDPCreatePurchaseOrderCtrl();
        List<IDPCreatePurchaseOrderLineCtrl> cpoLineList;
        IDPCreatePurchaseOrderLineCtrl cpoLine;
        Purchase_Request_Item__c pri;

        String siteId = siteMap.get('HKO').Id;
        siteId = siteId.substring(0, 15);
        createPOCtrl.selectedDeliverySite = '['+siteId+']';
        createPOCtrl.selectedSupplier = supplierMap.get('SUPPLIER1').Id;
        
        createPOCtrl.searchNotOrderedPurchaseRequestItemMap();
        cpoLineList = createPOCtrl.cpoLineList;

        cpoLine = cpoLineList.get(0);
        pri = cpoLine.pri;
        putParam('priId', pri.Id);

        createPOCtrl.cancelPurchaseRequestItemAction();
        pri = [Select Id, Status__c From Purchase_Request_Item__c WHERE Id =:pri.Id LIMIT 1];

        system.assertEquals('CN', pri.Status__c);

        createPOCtrl.searchNotOrderedPurchaseRequestItemMap();
        cpoLineList = createPOCtrl.cpoLineList;
        cpoLine = cpoLineList.get(0);
        pri = cpoLine.pri;

        cpoLine.cancelPurchaseRequestItemAction();
        pri = [Select Id, Status__c From Purchase_Request_Item__c WHERE Id =:pri.Id LIMIT 1];

        system.assertEquals('CN', pri.Status__c);
        Test.stopTest();

    }

    @isTest
    public static void testUpdateAndViewMethod() {
        prepareMap();
        Test.startTest();
        createPOCtrl = new IDPCreatePurchaseOrderCtrl();
        createPOCtrl.updateSupplierSelectOptionListAction();
        createPOCtrl.updateDraftPurchaseOrderSelectOptionListAction();
        createPOCtrl.clearSearchCriteria();
        Test.stopTest();

    }

 //   searchNotOrderedPurchaseRequestItemMap
    //createDraftPurchaseOrderAction
    //addToExistingPurchaseOrderAction
    //updateSupplierSelectOptionListAction
    //updateDraftPurchaseOrderSelectOptionListAction
    //
    //
    private static List<Purchase_Order__c> showPOStatus(String remark) {
        poList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,   Estimated_Total_Price__c, Est_Tot_Price_Incl_Tax_Ship__c, Applicant__c, Submitted_Date__c, Supplier__c, Status__c, Delivery_Site__c, Currency__c,   Tech_PO_Num_To_M3__c, Delivery_To__c, Delivery_Date__c, PO_Item_Count__c, Original_Total_Shipping_Cost__c, Original_Total_Tax__c, Total_Tax__c, Total_Shipping_Cost__c, Number_of_Draft__c, Number_of_Ordered__c, Number_of_Delivered__c, Number_of_Partial_Delivered__c, Number_of_Closed__c, Number_of_Canceled__c, Delivery_Method__c, Payment_Method__c, Payment_Terms__c, Tech_PO_Item_Total_Unit_Price__c, Delivery_Terms__c, M3_PO_NO__c, Is_All_Delivered__c, Payment_Remark__c, Total_Other_Cost__c, Original_Total_Other_Cost__c, Original_Total_Amount__c FROM Purchase_Order__c];
        log(remark + ' poList:'+poList);
        return poList;

    }

    private static List<Purchase_Order_Item__c> showPOIStatus(String remark) {
        poiList = [SELECT Id, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,   Purchase_Order__c, Catalog_Item__c, Catalog__c, Quantity__c, Tech_PO_Num_To_M3__c, Price__c,   Status__c,   Delivery_Date__c, Subtotal__c, Delivery_Address__c, Currency__c, Item_Description__c, Received_Quantity__c, Supplier__c, Unit_of_Measure__c, Buyer_Remark__c, Tech_PO_Currency_PRI_Other_Cost__c, Tech_PO_Currency_Other_Cost__c, Tech_PRI_Create_Date__c, Tech_PO_Currency_PRI_Shipping__c, Tech_PO_Currency_PRI_Tax__c, Tech_Price__c, Number__c, Tech_PO_Currency_PRI_Amount__c, Tech_PO_Currency_Shipping__c, Tech_PO_Currency_Tax__c, Tech_Budget_Exchange_Rate__c, Budget_Exchange_Rate__c FROM Purchase_Order_Item__c];
        log(remark + ' poiList:'+poiList);
        return poiList;
    }
    
    public static void putParam(String key, String val) {
        TestIDPUtility.putParam(key, val);
    }

    public static void log(String msg) {
        TestIDPUtility.log(msg);
    }
}