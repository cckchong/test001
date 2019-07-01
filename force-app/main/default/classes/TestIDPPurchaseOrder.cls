@isTest
private class TestIDPPurchaseOrder {
    
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
        Test.setMock(HttpCalloutMock.class, new TestIDPMockHttpResponseGenerator());
    }
    
    @isTest
    public static void testSaveAction() {
        prepareMap();        
        poList = showPOStatus('Before Save');
        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        purchaseOrderCtrl.po.Delivery_Terms__c = 'TT';
        purchaseOrderCtrl.saveAction();

        poList = showPOStatus('After Save');
        system.assertEquals('TT', poList.get(0).Delivery_Terms__c);
        Test.stopTest();
    }
   
    
    @isTest
    public static void testSubmitAction() {
        prepareMap();
        poList = showPOStatus('Before Save');
        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        //********************************        
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        purchaseOrderCtrl.submitAction();
        poList = showPOStatus('After Submit');
        system.assertEquals('ORD', poList.get(0).Status__c);
        Test.stopTest();
    }

    @isTest
    public static void testCancelAction() {

        prepareMap();

        poList = showPOStatus('Before Save');
        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        purchaseOrderCtrl.cancelAction();
        Test.stopTest();
    }

    @isTest
    public static void testBackAction() {

        prepareMap();

        poList = showPOStatus('Before Save');
        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        purchaseOrderCtrl.backAction();
        Test.stopTest();
    }

    @isTest
    public static void testEditAction() {

        prepareMap();

        poList = showPOStatus('Before Save');
        putParam('poId', poList.get(0).Id);
        putParam('mode', 'v');
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        purchaseOrderCtrl.editAction();
        purchaseOrderCtrl.changeSite();
        purchaseOrderCtrl.calculateTax();
        purchaseOrderCtrl.refreshTotalTaxAndCost();
        Test.stopTest();
    }

    @isTest
    public static void testRemovePOIAction() {

        prepareMap();

        poList = showPOStatus('Before Save');
        poiList = showPOIStatus('Before Save');
        Integer befPoiListSize = poiList.size();

        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        
        List<IDPPurchaseOrderLineCtrl> poLineList = purchaseOrderCtrl.pOLineList;
        IDPPurchaseOrderLineCtrl poLine = pOLineList.get(0);
        poLine.isChecked = true;
        purchaseOrderCtrl.removePOIAction();

        poiList = showPOIStatus('After remove');
        system.assertEquals(befPoiListSize-1, poiList.size());
        Test.stopTest();
    }

    @isTest
    public static void testRemoveSinglePOIAction() {

        prepareMap();

        poList = showPOStatus('Before Save');
        poiList = showPOIStatus('Before Save');
        Integer befPoiListSize = poiList.size();

        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        List<IDPPurchaseOrderLineCtrl> poLineList = purchaseOrderCtrl.pOLineList;
        IDPPurchaseOrderLineCtrl poLine = pOLineList.get(0);
        poLine.applyDeliveredDate();
        poLine.removeSinglePOIAction();

        poiList = showPOIStatus('After remove');
        system.assertEquals(befPoiListSize-1, poiList.size());
        Test.stopTest();
    }

    @isTest
    public static void testRemoveSinglePOIAction2() {

        prepareMap();

        poList = showPOStatus('Before Save');
        poiList = showPOIStatus('Before Save');
        Integer befPoiListSize = poiList.size();

        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        List<IDPPurchaseOrderLineCtrl> poLineList = purchaseOrderCtrl.pOLineList;
        IDPPurchaseOrderLineCtrl poLine = pOLineList.get(0);
        poLine.isChecked = true;

        purchaseOrderCtrl.poAction.removeSinglePOIAction(poLine);

        poiList = showPOIStatus('After remove');
        system.assertEquals(befPoiListSize-1, poiList.size());
        Test.stopTest();

    }

    @isTest
    public static void testMergePOIAction() {

        prepareMap();

        poList = showPOStatus('Before Save');
        poiList = showPOIStatus('Before Save');
        Integer befPoiListSize = poiList.size();

        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        List<IDPPurchaseOrderLineCtrl> poLineList = purchaseOrderCtrl.pOLineList;
        pOLineList.get(0).isChecked = true;
        pOLineList.get(1).isChecked = true;
        
        purchaseOrderCtrl.mergePOIAction();
        log('POCtrl msg:'+purchaseOrderCtrl.message);

        poiList = showPOIStatus('After merge');
        system.assertEquals(befPoiListSize-1, poiList.size());
        Test.stopTest();
    }

    @isTest
    public static void testReceiving() {
        List<Purchase_Order_Item__c> pois = new List<Purchase_Order_Item__c>();
        Purchase_Order__c po = null;
        List<IDPPurchaseOrderLineCtrl> poLineList = null;
        prepareMap();
        poList = showPOStatus('Before Save');
        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();        
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        purchaseOrderCtrl.submitAction();
        poLineList = purchaseOrderCtrl.poLineList;
        poLineList.get(0).preInputReceivedQtyAction();
        poLineList.get(1).preInputReceivedQtyAction();
        
        poList = showPOStatus('After Submit');
        system.assertEquals('ORD', poList.get(0).Status__c);
        
        pois = new List<Purchase_Order_Item__c>();
        for(Purchase_Order_Item__c poi : [select id, Quantity__c , Received_Quantity__c, M3_Status__c, Purchase_Order__c  
                                          from Purchase_Order_Item__c
                                          where Purchase_Order__c  = :poList.get(0).Id 
                                         ]){
            poi.Received_Quantity__c = poi.Quantity__c;
            poi.M3_Status__c = 75;
            pois.add(poi);
        }
        if(!pois.isEmpty()){
            update pois;
            po = new Purchase_Order__c (id = pois.get(0).Purchase_Order__c , status__c = 'DEL');
            upsert po;
            purchaseOrderCtrl.poAction.validateReceivedQuantity();
            poList = showPOStatus('After update receiving');
            poiList = showPOIStatus('After update receiving');
            system.assertEquals('DEL', poList.get(0).Status__c);
            system.assertEquals('DEL', poiList.get(1).Status__c);            
            system.assertEquals('DEL', poList.get(0).Status__c);
            
            for(Purchase_Order_Item__c poi : pois){
                poi.M3_Status__c = 85;
            }
            update pois;
            po = new Purchase_Order__c (id = pois.get(0).Purchase_Order__c , status__c = 'CL');
            upsert po;
            poList = showPOStatus('After close');
            poiList = showPOIStatus('After close');
            system.assertEquals('CL', poList.get(0).Status__c);
            system.assertEquals('CL', poiList.get(1).Status__c);
            system.assertEquals('CL', poList.get(0).Status__c);
        }
        Test.stopTest();
        
    }

    @isTest
    public static void testGetSetMethod() {

        prepareMap();

        poList = showPOStatus('Before Save');
        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();
        IDPPurchaseOrderCtrl poCtrl = new IDPPurchaseOrderCtrl();

        Employee__c emp = poCtrl.emp;
        Budget__c budget = poCtrl.budget;
        Map<id, Supplier__c> supplierMap = poCtrl.supplierMap;
        Map<Id, List<Supplier_Item__c>> supplierItemMap = poCtrl.supplierItemMap;
        Map<id, Map<id, double>> supplierCost = poCtrl.supplierCost;
        String tmp = poCtrl.tmp;
        Double withheldAmount = poCtrl.withheldAmount;
        
        Boolean isSave = poCtrl.getisSave();
        Boolean isSubmit = poCtrl.getIsSubmit();
        Boolean isView = poCtrl.getIsView();
        Boolean isClosed = poCtrl.getIsClosed();
        Boolean isSubmitted  = poCtrl.getisSubmitted ();
        Boolean isBeforePartialDelivered  = poCtrl.getisBeforePartialDelivered ();
        Boolean isDeliveryAddressBlank  = poCtrl.getisDeliveryAddressBlank ();
        Boolean isShippingAddressBlank  = poCtrl.getisShippingAddressBlank ();
        Purchase_Order_Item__c poi = poCtrl.poi;
        List<Purchase_Order_Item__c> poiList = poCtrl.poiList;
        List <selectOption> currencyOptList = poCtrl.currencyOptList;
        Boolean isEdit = poCtrl.getIsEdit();
        List<Purchase_Request_Item__c> relatedPriList = poCtrl.getrelatedPRIList();
        DateTime submittedDate = poCtrl.getSubmittedDate();
        Double priStandardAmount = poCtrl.getpriStandardAmount();
        Boolean isFullyReceived = poCtrl.getIsFullyReceived();

        poCtrl.isRecall = false;
        poCtrl.isSave = false;
        poCtrl.isSubmit = false;
        poCtrl.isView = false;
        poCtrl.isClosed = false;
        poCtrl.isSubmitted = false;
        poCtrl.isBeforePartialDelivered = false;
        poCtrl.isDeliveryAddressBlank = false;
        poCtrl.isShippingAddressBlank  = false;
        poCtrl.EarliestDeliDate = Date.newInstance(2017, 12, 31);
        poCtrl.priStandardAmount = 0;
        poCtrl.totalPrice = 0;
        poCtrl.tototPriceInclTaxShip = 0;
        Test.stopTest();

    }


    @isTest
    public static void testLineGetSetMethod() {

        prepareMap();

        poList = showPOStatus('Before Save');
        putParam('poId', poList.get(0).Id);
        putParam('mode', 's');
        Test.startTest();
        purchaseOrderCtrl = new IDPPurchaseOrderCtrl();
        List<IDPPurchaseOrderLineCtrl> poLineList = purchaseOrderCtrl.pOLineList;
        IDPPurchaseOrderLineCtrl poLine = poLineList.get(0);

        Boolean isDelivered = poLine.getisDelivered();
        Decimal moq = poLine.getMoq();
        Boolean isLessThanMoq = poLine.getIsLessThanMoq();


        poLine.isDelivered = false;
        poLine.isExceededOrderedQuantity = false;
        poLine.isReduceReceivedQuantity = false;
        poLine.isLessThanMoq  = false;
        poLine.moq = 0;
        Test.stopTest();
    }


    @isTest
    public static void testOverwritePage() {
        Purchase_Order__c po = showPOStatus('Test overwrite').get(0);
        Purchase_Order_Item__c poi = showPOIStatus('Test overwrite').get(0);

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(po);
        putParam('id', po.id);
        poOverwriteViewCtrl = new IDPPurchaseOrderOverwriteViewCtrl(sc);
        poOverwriteViewCtrl.redirect();

        poOverwriteNewCtrl = new IDPPurchaseOrderOverwriteNewCtrl(sc);
        poOverwriteNewCtrl.redirect();

        sc = new ApexPages.Standardcontroller(poi);
        putParam('id', poi.id);
        poiOverwriteViewCtrl = new IDPPurchaseOrderItemOverwriteViewCtrl(sc);
        poiOverwriteViewCtrl.redirect();

    }
    
    @isTest
    public static void testProgressBar() {
        String status ='';
        IDPPurchaseOrderProgressBarCtrl poBar = null;        
        prepareMap();        
        poList = showPOStatus('Before Save');
        putParam('poId', poList.get(0).Id);
        Test.startTest();
        poBar = new IDPPurchaseOrderProgressBarCtrl();
        status = IDPPurchaseOrderProgressBarCtrl.stepLabel1;
        status = IDPPurchaseOrderProgressBarCtrl.stepLabel2;
        status = IDPPurchaseOrderProgressBarCtrl.stepLabel3;
        status = IDPPurchaseOrderProgressBarCtrl.stepLabel4;
        status = IDPPurchaseOrderProgressBarCtrl.stepLabel5;
        status = IDPPurchaseOrderProgressBarCtrl.stepLabel6;
        
        status = IDPPurchaseOrderProgressBarCtrl.isStepActive1;
        status = IDPPurchaseOrderProgressBarCtrl.isStepActive2;
        status = IDPPurchaseOrderProgressBarCtrl.isStepActive3;
        status = IDPPurchaseOrderProgressBarCtrl.isStepActive4;
        status = IDPPurchaseOrderProgressBarCtrl.isStepActive5;
        status = IDPPurchaseOrderProgressBarCtrl.isStepActive6;
        IDPPurchaseOrderProgressBarCtrl.getIsDelivered();
        IDPPurchaseOrderProgressBarCtrl.getIsPartialDelivered();
        
        Test.stopTest();
    }
    
    private static List<Purchase_Order__c> showPOStatus(String remark) {
        poList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,   Estimated_Total_Price__c, Est_Tot_Price_Incl_Tax_Ship__c, Applicant__c, Submitted_Date__c, Supplier__c, Status__c, Delivery_Site__c, Currency__c,  Tech_PO_Num_To_M3__c, Delivery_To__c, Delivery_Date__c, PO_Item_Count__c, Original_Total_Shipping_Cost__c, Original_Total_Tax__c, Total_Tax__c, Total_Shipping_Cost__c, Number_of_Draft__c, Number_of_Ordered__c, Number_of_Delivered__c, Number_of_Partial_Delivered__c, Number_of_Closed__c, Number_of_Canceled__c, Delivery_Method__c, Payment_Method__c, Payment_Terms__c, Tech_PO_Item_Total_Unit_Price__c, Delivery_Terms__c, M3_PO_NO__c, Is_All_Delivered__c, Payment_Remark__c, Total_Other_Cost__c, Original_Total_Other_Cost__c, Original_Total_Amount__c FROM Purchase_Order__c];
        log(remark + ' poList:'+poList);
        return poList;

    }

    private static List<Purchase_Order_Item__c> showPOIStatus(String remark) {
        poiList = [SELECT Id, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,  Purchase_Order__c, Catalog_Item__c, Catalog__c, Quantity__c, Tech_PO_Num_To_M3__c, Price__c,  Status__c,  Delivery_Date__c, Subtotal__c, Delivery_Address__c, Currency__c, Item_Description__c, Received_Quantity__c, Supplier__c, Unit_of_Measure__c, Buyer_Remark__c, Tech_PO_Currency_PRI_Other_Cost__c, Tech_PO_Currency_Other_Cost__c, Tech_PRI_Create_Date__c, Tech_PO_Currency_PRI_Shipping__c, Tech_PO_Currency_PRI_Tax__c, Tech_Price__c, Number__c, Tech_PO_Currency_PRI_Amount__c, Tech_PO_Currency_Shipping__c, Tech_PO_Currency_Tax__c, Tech_Budget_Exchange_Rate__c, Budget_Exchange_Rate__c FROM Purchase_Order_Item__c];
        log(remark + ' poiList:'+poiList);
        return poiList;
    }

    public static void putParam(String key, String val) {
        TestIDPUtility.putParam(key, val);
    }

    public static void log(String msg) {
        TestIDPUtility.log(msg);
    }

    // removePOIAction
    // mergePOIAction
    // saveAction
    // submitAction
    // massClosedPOPOI
    // cancelAction
    // editAction
    // backAction
    // changeSite
}