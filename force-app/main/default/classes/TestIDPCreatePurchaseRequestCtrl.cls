@isTest
public class TestIDPCreatePurchaseRequestCtrl {
    public static TestIDPPreparation idpPrepare;
    public static IDPAjaxDataTableCtrl ajaxDataTableCtrl;
    public static IDPBrowseCatalogVFPCtrl browseCatalogCtrl;
    public static IDPShoppingCartVFPCtrl shoppingCartCtrl;
    public static IDPPurchaseRequestCtrl purchaseReqestCtrl;

    public static Map<String, Catalog__c> catalogAllMap;
    public static Map<String, Catalog_Item__c> catalogItemMap;
    public static Map<String, User> userMap;
    public static Map<String, Site__c> siteMap;
    public static Map<String, Employee__c> employeeMap;
    public static Map<String, Employee_Administrator__c> employeeAdministratorMap;
    public static Map<String, IDP_Policy__c> idpPolicyMap;
    public static Map<String, Catalog_Policy_Setting__c> catalogPolicySettingMap;

    private static String catalogItemName = 'Administration_Motor Vehicles_Item_1';

    public static void prepare(boolean isSeeAllData) {
        idpPrepare = new TestIDPPreparation(isSeeAllData);
        
        idpPrepare.idpPreparation(isSeeAllData);    
        catalogAllMap = idpPrepare.catalogAllMap;

        catalogItemMap = idpPrepare.catalogItemMap;
        userMap = idpPrepare.userMap;
        siteMap = idpPrepare.siteMap;
        employeeMap = idpPrepare.employeeMap;
        employeeAdministratorMap = idpPrepare.employeeAdministratorMap;
        idpPolicyMap = idpPrepare.idpPolicyMap;
        catalogPolicySettingMap = idpPrepare.catalogPolicySettingMap;

        idpPrepare.prepareCatalogPermission();
        idpPrepare.idpInitSetting();
    }


    @isTest
    public static void createPurchaseRequest() {

        prepare(false);

        log('idpPolicyMap:'+idpPolicyMap);

        Purchase_Request__c pr = new Purchase_Request__c(
                                     //RecordTypeId='012p00000008u9FAAQ',
                                     Status__c='DF',
                                     On_Behalf_of__c=employeeAdministratorMap.get('Testing (HKOuser1)').Id,
                                     IDP_Policy__c=idpPolicyMap.get('HKO').Id,
                                     Catalog__c=catalogAllMap.get('Administration').Id,
                                     Delivery_Site__c=siteMap.get('HKO').Id,
                                     Catalog_Name__c='Administration',
                                     Budget_Forecast__c='Within Budget'
                                    );

        insert pr;

        log('catalogItemMap:'+catalogItemMap);

        Purchase_Request_Item__c pri = new Purchase_Request_Item__c(
                                             //RecordTypeId='012p00000008t4YAAQ',
                                             Catalog_Item__c=catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id,
                                             Purchase_Request__c=pr.Id,
                                             Unit_of_Measure__c='EA',
                                             Quantity__c=1,
                                             Is_Direct_fulfillment__c=false,
                                             Number__c=1,
                                             Budget_Exchange_Rate__c=0
                                            );

        insert pri;

        system.runAs(userMap.get('user1')) {



            //Purchase_Request__c pr = new Purchase_Request__c(
                        //               RecordTypeId='012p00000008u9FAAQ',
                        //               Status__c='DF',
                        //               On_Behalf_of__c='a0Ep0000003aMpFEAU',
                        //               IDP_Policy__c='a1Lp0000002g49sEAA',
                        //               Catalog__c='a19p0000001ZVRFAA4',
                        //               Delivery_Site__c='a0cp0000001Reu1AAC',
                        //               Is_Budget__c=true,
                        //               Catalog_Name__c='Administration',
                        //               Budget_Forecast__c='Within Budget'
            //                          );

            //insert pr;

        }
    }


































    //@isTest
    public static void testCreatePR() {

        PageReference pf;
        
        prepare(false);

        system.runAs(userMap.get('user1')) {

            List<Shopping_Cart_Item__c> modifiedShoppingCartItemList = addItemToCart();

            Test.startTest();
            
            String checkedCatalogItemIdQuantityJSON;
            List<Purchase_Request__c> prList;

            // Create PR
            shoppingCartCtrl = new IDPShoppingCartVFPCtrl();
            checkedCatalogItemIdQuantityJSON = '{"editedCatalogItemList":[{"catalogItemId":"'+catalogItemMap.get(catalogItemName).Id+'_Each","checked":true,"quantity":"1","unitOfMeasure":"Each"}]}';
            putParam('checkedCatalogItemIdQuantityJSON', checkedCatalogItemIdQuantityJSON);

            pf = shoppingCartCtrl.closeShoppingCartItems();
            prList = new List<Purchase_Request__c>([SELECT ID FROM Purchase_Request__c]);
            system.assertEquals(1, prList.size());


            Purchase_Request__c pr = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,  Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,  PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,   Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,  Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,  Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
            log('draft pr:'+pr);

            Purchase_Request_Item__c pri = [SELECT Id, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,   Shipping_Cost_Local_Total_Amount__c, Catalog_Item__c, Catalog__c, Purchase_Request__c, Price__c, Unit_of_Measure__c, Purchase_Order_Item__c, Status__c, Tax_Local_Total_Amount__c, Quantity__c, Amount__c, Local_Sub_Total__c, Supplier__c, Tech_Budget_Exchange_Rate__c, Supplier_Source__c, Currency__c, Other_Cost_Local_Total_Amount__c, POI_External_Id__c, Is_Direct_fulfillment__c, Remark__c, Cost_Item__c, Number__c, Catalog_Name__c, Catalog_Item_Name__c, Budget_Exchange_Rate__c, Budget_Amount__c, Standard_Exchange_Rate__c, Standard_Currency__c, Used_Standard_Exchange_Rate__c, Local_Currency__c, Local_Exchange_Rate__c, Used_Local_Exchange_Rate__c, Standard_Amount__c, Local_Amount__c, Other_Cost_Original_Total_Amount__c, Other_Cost_Standard_Total_Amount__c, Standard_Sub_Total__c, Budget_Other_Cost_Total_Amount__c, Shipping_Cost_Standard_Total_Amount__c, Tax_Standard_Total_Amount__c, Purchase_Order__c, Total_Requested_Qty__c, Total_Received_Qty__c, Received_Qty__c, POI_Status__c, Tax_Original_Total_Amount__c, Shipping_Cost_Original_Total_Amount__c, Budget_Tax_Total_Amount__c, Budget_Shipping_Cost_Amount__c, Budget_Sub_Total__c, Tech_POI_PO_Currency_Used_Budget_Amount__c FROM Purchase_Request_Item__c LIMIT 1];
            log('draft pri'+pri);


            putParam('mode', pf.getParameters().get('mode'));
            putParam('prid', pf.getParameters().get('prid'));

            // Save Action
            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            system.assertEquals(IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT, purchaseReqestCtrl.pr.Status__c);

            purchaseReqestCtrl.pr.Need_by_Date__c = Date.newInstance(2017, 12, 31);
            purchaseReqestCtrl.pr.Comment__c = 'Comment';

            pf = purchaseReqestCtrl.saveAction();

            system.assertEquals(Date.newInstance(2017, 12, 31), purchaseReqestCtrl.pr.Need_by_Date__c);
            system.assertEquals('Comment', purchaseReqestCtrl.pr.Comment__c);

            // Edit Action
            pf = purchaseReqestCtrl.editAction();

            // Submit Action
            purchaseReqestCtrl.pr.Need_by_Date__c = Date.newInstance(2017, 10, 1);
            pf = purchaseReqestCtrl.submitAction();

            system.assertEquals(Date.newInstance(2017, 10, 1), purchaseReqestCtrl.pr.Need_by_Date__c);


            Test.stopTest();

            
        }       
    }

    private static List<Shopping_Cart_Item__c> addItemToCart() {
        browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
                
        Map<String, Shopping_Cart_Item__c> existingShoppingCartItemMap = browseCatalogCtrl.existingShoppingCartItemMap;
        Map<String, Favourite_Item__c> existingFavouriteItemMap = browseCatalogCtrl.existingFavouriteItemMap;

        String checkedCatalogItemIdQuantityJSON = '{"editedCatalogItemList":[{"catalogItemId":"'+catalogItemMap.get(catalogItemName).Id+'","checked":true,"quantity":"1","unitOfMeasure":"Each"}]}';
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

         return modifiedShoppingCartItemList;                                                               
    }

    

    public static void log(String msg) {
        system.debug(logginglevel.ERROR, msg);
    }

    public static void putParam(String key, String val) {
        ApexPages.currentPage().getParameters().put(key, val);
    }
}