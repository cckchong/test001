@isTest
public class TestIDPPurchaseRequestCtrl{

    public static IDPAjaxDataTableCtrl ajaxDataTableCtrl;
    public static IDPBrowseCatalogVFPCtrl browseCatalogCtrl;
    public static IDPShoppingCartVFPCtrl shoppingCartCtrl;
    public static IDPPurchaseRequestCtrl purchaseReqestCtrl;
    public static IDPPurchaseRequestOverwriteEditCtrl prOverwriteEditCtrl;
    public static IDPPurchaseRequestOverwriteNewCtrl prOverwriteNewCtrl;
    public static IDPPurchaseRequestOverwriteViewCtrl prOverwriteViewCtrl;
    public static IDPPurchaseRequestItemOverwriteViewCtrl priOverwriteViewCtrl;
    public static IDPPurchaseCostOverwriteViewCtrl pcOverwriteViewCtrl;

    public static Map<String, User> userMap;
    public static Map<String, Catalog__c> catalogAllMap;
    public static Map<String, Catalog_Item__c> catalogItemMap;
    public static Map<String, Employee_Administrator__c> employeeAdministratorMap;
    public static Map<String, IDP_Policy__c> idpPolicyMap;
    public static Map<String, Site__c> siteMap;
    public static Map<String, Supplier__c> supplierMap;

    private static String catalogItemName = 'Administration_Motor Vehicles_Item_1';

    @testSetup
    public static void testSetup() {
        Map<String, Map<String, sObject>> preparedMap = TestIDPUtility.prepare(false);

        supplierMap = new Map<String, Supplier__c>();
        for (String key : preparedMap.get('supplierMap').keySet()) {
            supplierMap.put(key, (Supplier__c)preparedMap.get('supplierMap').get(key));
        }

        Purchase_Request__c pr = new Purchase_Request__c(
                                     //RecordTypeId='012p00000008u9FAAQ',
                                     Status__c='DF',
                                     On_Behalf_of__c=preparedMap.get('employeeAdministratorMap').get('Testing (HKOuser1)').Id,
                                     IDP_Policy__c=preparedMap.get('idpPolicyMap').get('HKO').Id,
                                     Catalog__c=preparedMap.get('catalogAllMap').get('Administration').Id,
                                     Delivery_Site__c=preparedMap.get('siteMap').get('HKO').Id,
                                     Catalog_Name__c='Administration',
                                     Budget_Forecast__c='Within Budget',
                                     Need_by_Date__c=Date.today().adddays(10)
                                    );

        insert pr;

        Purchase_Request_Item__c pri = new Purchase_Request_Item__c(
                                             //RecordTypeId='012p00000008t4YAAQ',
                                             Catalog_Item__c=preparedMap.get('catalogItemMap').get('Administration_Motor Vehicles_Item_1').Id,
                                             Purchase_Request__c=pr.Id,
                                             Unit_of_Measure__c='EA',
                                             Quantity__c=1,
                                             Is_Direct_fulfillment__c=false,
                                             Number__c=1,
                                             Budget_Exchange_Rate__c=0,
                                             Supplier__c=preparedMap.get('supplierMap').get('SUPPLIER1').Id,
                                             Price__c=500,
                                             Currency__c=supplierMap.get('SUPPLIER1').Currency__c
                                            );

        insert pri;

        Purchase_Cost__c pc = new Purchase_Cost__c(
                                        //RecordTypeId='012p00000008u90AAA',
                                        Type__c='SHIP',
                                        Currency__c=preparedMap.get('currencyMap').get('HKD').Id,
                                        Price__c=10,
                                        Purchase_Request_Item__c=pri.Id
                                        );

        insert pc;
    }

    public static void prepareMap() {
        userMap = TestIDPUtility.getUserMap();
        catalogItemMap = TestIDPUtility.getCatalogItemMap();
        employeeAdministratorMap = TestIDPUtility.getEmployeeAdministratorMap();
        idpPolicyMap = TestIDPUtility.getIdpPolicyMap();
        catalogAllMap = TestIDPUtility.getCatalogAllMap();
        siteMap = TestIDPUtility.getSiteMap();
        supplierMap = TestIDPUtility.getSupplierMap();
    }

    // ===============================================================================================================================

    @isTest
    public static void testCreatePR() {

        PageReference pf;
        String checkedCatalogItemIdQuantityJSON;
        List<Purchase_Request__c> prList;
        prepareMap();
        system.runAs(userMap.get('user1')) {

            List<Shopping_Cart_Item__c> modifiedShoppingCartItemList = addItemToCart();

            Test.startTest();

            // Create PR
            shoppingCartCtrl = new IDPShoppingCartVFPCtrl();
            checkedCatalogItemIdQuantityJSON = '{"editedCatalogItemList":[{"catalogItemId":"'+catalogItemMap.get(catalogItemName).Id+'_EA","checked":true,"quantity":"1","unitOfMeasure":"EA"}]}';
            putParam('checkedCatalogItemIdQuantityJSON', checkedCatalogItemIdQuantityJSON);

            pf = shoppingCartCtrl.closeShoppingCartItems();
            prList = new List<Purchase_Request__c>([SELECT ID FROM Purchase_Request__c]);
            system.assertEquals(1, prList.size());


            putParam('mode', pf.getParameters().get('mode'));
            putParam('prid', pf.getParameters().get('prid'));

            // Save Action
            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            system.assertEquals(IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT, purchaseReqestCtrl.pr.Status__c);

            purchaseReqestCtrl.pr.Need_by_Date__c = Date.today().adddays(10);
            purchaseReqestCtrl.pr.Comment__c = 'Comment';

            String emailList = '';
            for (String userKey : userMap.keySet()) {
                if (emailList != '') 
                    emailList += ',';

                emailList += userMap.get(userKey).Id;
            }
            purchaseReqestCtrl.emailList = emailList;
            

            pf = purchaseReqestCtrl.saveAction();

            system.assertEquals(Date.today().adddays(10), purchaseReqestCtrl.pr.Need_by_Date__c);
            system.assertEquals('Comment', purchaseReqestCtrl.pr.Comment__c);

            // Edit Action
            pf = purchaseReqestCtrl.editAction();
            List<IDPPurchaseRequestLineCtrl> PRLineList = purchaseReqestCtrl.PRLineList;
            system.assertEquals(1, PRLineList.size());

            IDPPurchaseRequestLineCtrl prLine = PRLineList.get(0);
            Purchase_Request_Item__c pri = prLine.pri;
            pri.Quantity__c = 1;
            pri.Price__c = 500;

            putParam('PRItemID', prLine.PRItemID);
            purchaseReqestCtrl.updateEmployee();
            purchaseReqestCtrl.changeSite();
            purchaseReqestCtrl.changeSupplierAction();
            purchaseReqestCtrl.prAction.changeItemDetails(prLine.PRItemID);

            // Submit Action
            purchaseReqestCtrl.pr.Need_by_Date__c = Date.today().adddays(10);
            pf = purchaseReqestCtrl.submitAction();

            system.assertEquals(Date.today().adddays(10), purchaseReqestCtrl.pr.Need_by_Date__c);


            Test.stopTest();

            
        }       
    }

    private static List<Shopping_Cart_Item__c> addItemToCart() {
        browseCatalogCtrl = new IDPBrowseCatalogVFPCtrl();
                
        Map<String, Shopping_Cart_Item__c> existingShoppingCartItemMap = browseCatalogCtrl.existingShoppingCartItemMap;
        Map<String, Favourite_Item__c> existingFavouriteItemMap = browseCatalogCtrl.existingFavouriteItemMap;

        String checkedCatalogItemIdQuantityJSON = '{"editedCatalogItemList":[{"catalogItemId":"'+catalogItemMap.get(catalogItemName).Id+'","checked":true,"quantity":"1","unitOfMeasure":"EA"}]}';
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



    // ===============================================================================================================================

    @isTest
    public static void testApproval() {

        prepareMap();   

        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, 
                                            CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,   
                                            Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, 
                                            Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, 
                                            Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, 
                                            Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, 
                                            Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, 
                                            Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, 
                                            Current_Approver__c, comment__c, Is_mine__c,  PR_Item_Count__c, Standard_Exchange_Rate__c, 
                                            Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,   
                                            Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, 
                                            PR_Item_Closed_Count__c,   Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, 
                                            PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, 
                                            PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, 
                                            Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, 
                                            Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,  Catalog_Name__c, 
                                            Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, 
                                            Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, 
                                            Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        Purchase_Request__c prResult;
        Purchase_Request_Item__c priResult;

        showExecutedQueries('After prepare');
        system.runAs(userMap.get('user1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            Test.startTest();
            purchaseReqestCtrl.submitAction();
        }
        /*
        showExecutedQueries('After user1');
        prResult = showPRStatus('After user1');
        priResult = showPRIStatus('After user1');
        system.assertEquals(IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION, prResult.Status__c);
        */
        
        
        system.runAs(userMap.get('COUser')){
            putParam('mode', 's');
            putParam('prid', pr.Id);
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Approve');
            req.setWorkitemId(getWorkItemId(pr.Id));
            req.setComments('');
            Approval.process(req);
            
        }
        

        /*
        showExecutedQueries('After COUser');
        prResult = showPRStatus('After COUser');
        priResult = showPRIStatus('After COUser');
        system.assertEquals(IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL, prResult.Status__c);
        */
        system.runAs(userMap.get('apr1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            //purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            //purchaseReqestCtrl.approveAction();
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Approve');
            req.setWorkitemId(getWorkItemId(pr.Id));
            req.setComments('');
            Approval.process(req);
            
        }
        //*
        showExecutedQueries('After apr1');
        prResult = showPRStatus('After apr1');
        priResult = showPRIStatus('After apr1');
        system.assertEquals(IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL, prResult.Status__c);
        //*/
        system.runAs(userMap.get('apr2')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            purchaseReqestCtrl.approveAction();
        }
        
        showExecutedQueries('After apr2');
        prResult = showPRStatus('After apr2');
        priResult = showPRIStatus('After apr2');
        system.assertEquals(IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED, prResult.Status__c);
        
        /*
        List<Purchase_Request__c> prtList = [SELECT id, Tech_Applicant_Site_Id__c, On_Behalf_of__c, On_Behalf_of__r.Employee__c, On_Behalf_of__r.Employee__r.Site__c FROM Purchase_Request__c];
        List<Purchase_Request_Item__c> pritList = [SELECT Id, Purchase_Request__r.Tech_Applicant_Site_Id__c, Purchase_Request__r.On_Behalf_of__c, Purchase_Request__r.On_Behalf_of__r.Employee__c, Purchase_Request__r.On_Behalf_of__r.Employee__r.Site__c FROM Purchase_Request_Item__c];

        log('TEST PR prList:'+prtList);
        log('TEST PR priList:'+pritList);
        */
        
        Test.stopTest();
    }

    private static Id getWorkItemId(Id targetObjectId){
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select Id from ProcessInstanceWorkitem
            where ProcessInstance.TargetObjectId =: targetObjectId]){
            retVal  =  workItem.Id;
        }
        return retVal;
    }


    // ===============================================================================================================================

    @isTest
    public static void testBackAction() {

        prepareMap();   

        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,   PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,   Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,   Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,  Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        Purchase_Request__c prResult;
        Purchase_Request_Item__c priResult;

        system.runAs(userMap.get('user1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            purchaseReqestCtrl.backAction();
        }
    }

    @isTest
    public static void testCancelAction() {

        prepareMap();   

        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,  PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,   Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,   Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,  Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        Purchase_Request__c prResult;
        Purchase_Request_Item__c priResult;

        system.runAs(userMap.get('user1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            purchaseReqestCtrl.editAction();

            purchaseReqestCtrl.cancelAction();
        }
    }

    @isTest
    public static void testRejectAction() {
        prepareMap();
        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,   PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,   Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,  Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,   Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        Purchase_Request__c prResult;
        Purchase_Request_Item__c priResult;
        
        system.runAs(userMap.get('user1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            Test.startTest();
            purchaseReqestCtrl.submitAction();
        }        
        system.runAs(userMap.get('COUser')){
            putParam('mode', 's');
            putParam('prid', pr.Id);
            //purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            //purchaseReqestCtrl.rejectAction();
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Reject');
            req.setWorkitemId(getWorkItemId(pr.Id));
            req.setComments('');
            Approval.process(req);
        }
        //prResult = showPRStatus('After Reject');
        //priResult = showPRIStatus('After Reject');
        //system.assertEquals(IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED, prResult.Status__c);
        system.runAs(userMap.get('user1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);
            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            purchaseReqestCtrl.cloneAction();
        }
        prList = [SELECT Id, Name FROM Purchase_Request__c];
        system.assertEquals(2, prList.size());
        Test.stopTest();
    }

    @isTest
    public static void testRecallAction() {

        prepareMap();   

        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,   PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,  Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,   Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,   Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        Purchase_Request__c prResult;
        Purchase_Request_Item__c priResult;

        Test.startTest();
        
        system.runAs(userMap.get('user1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            purchaseReqestCtrl.submitAction();

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            purchaseReqestCtrl.recallAction();
        }

        prResult = showPRStatus('After Recall');
        priResult = showPRIStatus('After Recall');

        system.assertEquals(IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED, prResult.Status__c);

        Test.stopTest();
    }

    // ===============================================================================================================================

    @isTest
    public static void testRowAction() {

        prepareMap();   

        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,   PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,   Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,  Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,   Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        Purchase_Request__c prResult;
        Purchase_Request_Item__c priResult;

        Test.startTest();
        
        system.runAs(userMap.get('user1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();

            List<IDPPurchaseRequestLineCtrl> PRLineList = purchaseReqestCtrl.PRLineList;
            IDPPurchaseRequestLineCtrl prLine = PRLineList.get(0);
            IDPPurchaseRequestLineCtrl pcLine;
            Purchase_Request_Item__c pri = prLine.pri;
            Purchase_Cost__c pc;

            // Insert Purchase Cost
            prLine.addRow();
            prLine.addRow();
            purchaseReqestCtrl.saveAction();
            system.assertEquals(4, PRLineList.size());

            // Open PR again after insert Purchase Cost
            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            PRLineList = purchaseReqestCtrl.PRLineList;
            prLine = PRLineList.get(0);
            pcLine = PRLineList.get(1);

            // Delete Purchase Cost
            pcLine.delPCRow();
            system.assertEquals(3, PRLineList.size());

            // Delete Purchase Item
            prLine.delRow();
            system.assertEquals(0, PRLineList.size());
        }
    }

    @isTest
    public static void testChangeFulfillmentAction() {

        prepareMap();   

        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,   PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,  Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,  Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,  Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        Purchase_Request__c prResult;
        Purchase_Request_Item__c priResult;

        Test.startTest();
        
        system.runAs(userMap.get('user1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();

            List<IDPPurchaseRequestLineCtrl> PRLineList = purchaseReqestCtrl.PRLineList;
            IDPPurchaseRequestLineCtrl prLine = PRLineList.get(0);
            Purchase_Request_Item__c pri = prLine.pri;

            // Insert Purchase Cost
            prLine.addRow();
            prLine.addRow();
            purchaseReqestCtrl.saveAction();
            system.assertEquals(4, PRLineList.size());

            // Open PR again after insert Purchase Cost
            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            PRLineList = purchaseReqestCtrl.PRLineList;
            prLine = PRLineList.get(0);

            // Change to fulfillment
            prLine.changefulfillment();
            system.assertEquals(1, PRLineList.size());

            // Change to non-fulfillment
            prLine.pri.Is_Direct_fulfillment__c = true;
            prLine.changefulfillment();
            system.assertEquals(1, PRLineList.size());

        }
    }

    
    @isTest
    public static void testGetSetMethod() {

        prepareMap();   

        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,  PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,  Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,  Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,   Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        Purchase_Request__c prResult;
        Purchase_Request_Item__c priResult;

        showExecutedQueries('After prepare');

        system.runAs(userMap.get('user1')){
            putParam('prid', pr.Id);
            Test.startTest();
            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();
            callGetSetMethod(purchaseReqestCtrl);

            purchaseReqestCtrl.pr.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION;
            callGetSetMethod(purchaseReqestCtrl);

            purchaseReqestCtrl.pr.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL;
            callGetSetMethod(purchaseReqestCtrl);

            purchaseReqestCtrl.pr.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED;
            callGetSetMethod(purchaseReqestCtrl);

            purchaseReqestCtrl.pr.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED;
            callGetSetMethod(purchaseReqestCtrl);

            purchaseReqestCtrl.pr.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED;
            callGetSetMethod(purchaseReqestCtrl);

            purchaseReqestCtrl.pr.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_CANCELLED;
            callGetSetMethod(purchaseReqestCtrl);

            purchaseReqestCtrl.pr.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_SUBMITTED;
            callGetSetMethod(purchaseReqestCtrl);
            Test.stopTest();
        }
    }

    private static void callGetSetMethod(IDPPurchaseRequestCtrl purchaseReqestCtrl) {
        Boolean isEdit = purchaseReqestCtrl.getisEdit();
        Boolean isView = purchaseReqestCtrl.getisView();
        Boolean isSave = purchaseReqestCtrl.getisSave();
        Boolean isShowStatus = purchaseReqestCtrl.getisShowStatus();
        Boolean isSaveReceived = purchaseReqestCtrl.getisSaveReceived();
        Boolean isEditReceived = purchaseReqestCtrl.getisEditReceived();
        Boolean isSubmit = purchaseReqestCtrl.getisSubmit();
        Boolean isRecall = purchaseReqestCtrl.getisRecall();
        Boolean isApproval = purchaseReqestCtrl.getisApproval();
        DateTime applyDate = purchaseReqestCtrl.getApplyDate();
        purchaseReqestCtrl.refreshPRAttachment();

        purchaseReqestCtrl.isEdit = false;
        purchaseReqestCtrl.isSave = false;
        purchaseReqestCtrl.isSaveReceived  = false;
        purchaseReqestCtrl.isEditReceived  = false;
        purchaseReqestCtrl.showSaveReceivedSave  = false;
        purchaseReqestCtrl.isSubmit   = false;
        purchaseReqestCtrl.isSubmitted  = false;
        purchaseReqestCtrl.isView  = false;
        purchaseReqestCtrl.isRecall   = false;
        purchaseReqestCtrl.tmp = '';
    }
    
    @isTest
    public static void testLineGetSetMethod() {

        prepareMap();   

        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,   PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,   Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,  Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,  Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        Purchase_Request__c prResult;
        Purchase_Request_Item__c priResult;

        Test.startTest();
        
        system.runAs(userMap.get('user1')){
            putParam('mode', 's');
            putParam('prid', pr.Id);

            purchaseReqestCtrl = new IDPPurchaseRequestCtrl();

            List<IDPPurchaseRequestLineCtrl> PRLineList = purchaseReqestCtrl.PRLineList;
            IDPPurchaseRequestLineCtrl prLine = PRLineList.get(0);

            Boolean isAddAction = prLine.getisAddAction();
            Boolean isDelAction = prLine.getisDelAction();
            Boolean isValidReceivedQuantity  = prLine.getisValidReceivedQuantity ();
            Boolean isTax = prLine.getisTax();
            Decimal priAmount = prLine.priAmount;
            Decimal moq = prLine.getMoq();
            Set<String> last3OrderedSupplier = prLine.getLast3OrderedSupplier();
            String supplierId = prLine.getsupplierId();
            IDPPurchaseRequestLineCtrl priCtrl = prLine.getPriCtrl(prLine.PRItemID);


            prLine.isAddAction = false;
            prLine.isDelAction = false;
            prLine.isLessThanMOQ = false;
            prLine.isValidReceivedQuantity = false;
            prLine.isTax = false;
            prLine.priAmount = 0;
            prLine.last3OrderedSupplier = new Set<String>();
            prLine.preInputReceivedQtyAction();
            prLine.calculateTax();


            prLine.addRow();

            IDPPurchaseRequestLineCtrl pcLine = PRLineList.get(1);
            pcLine.calculateTax();
            pcLine.getsupplierId();
            pcLine.getMoq();

        }
    }

    @isTest
    public static void testOverwritePage() {
        

        Purchase_Request__c pr = showPRStatus('Test overwrite');

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(pr);
        putParam('id', pr.id);
        prOverwriteViewCtrl = new IDPPurchaseRequestOverwriteViewCtrl(sc);
        prOverwriteViewCtrl.redirect();

        prOverwriteEditCtrl = new IDPPurchaseRequestOverwriteEditCtrl(sc);
        prOverwriteEditCtrl.redirect();

        prOverwriteNewCtrl = new IDPPurchaseRequestOverwriteNewCtrl(sc);
        prOverwriteNewCtrl.redirect();

        Purchase_Request_Item__c pri = showPRIStatus('Test overwrite');
        sc = new ApexPages.Standardcontroller(pri);
        putParam('id', pri.id);
        priOverwriteViewCtrl = new IDPPurchaseRequestItemOverwriteViewCtrl(sc);
        priOverwriteViewCtrl.redirect();

        Purchase_Cost__c pc = [SELECT id FROM Purchase_Cost__c LIMIT 1];
        sc = new ApexPages.Standardcontroller(pc);
        putParam('id', pc.id);
        pcOverwriteViewCtrl = new IDPPurchaseCostOverwriteViewCtrl(sc);
        pcOverwriteViewCtrl.redirect();

    }
    
    @isTest
    public static void testProgressBar() {
        String status ='';
        IDPPurchaseRequestProgressBarCtrl prBar = null; 
        prepareMap();
        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c, Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,  PR_Item_Count__c, Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, Tech_Is_Approver__c,   Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, PR_Item_Closed_Count__c,   Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,  Catalog_Name__c, Closed_Date__c, PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        Purchase_Request__c pr = prList.get(0);
        putParam('prid', pr.Id);
        Test.startTest();
        prBar = new IDPPurchaseRequestProgressBarCtrl ();
        status = IDPPurchaseRequestProgressBarCtrl.stepLabel1;
        status = IDPPurchaseRequestProgressBarCtrl.stepLabel2;
        status = IDPPurchaseRequestProgressBarCtrl.stepLabel3;
        status = IDPPurchaseRequestProgressBarCtrl.stepLabel4;
        status = IDPPurchaseRequestProgressBarCtrl.stepLabel5;
        status = IDPPurchaseRequestProgressBarCtrl.stepLabel6;
        status = IDPPurchaseRequestProgressBarCtrl.stepLabel7;
        status = IDPPurchaseRequestProgressBarCtrl.stepLabel8;
        status = IDPPurchaseRequestProgressBarCtrl.stepLabel9;
        status = IDPPurchaseRequestProgressBarCtrl.isStepActive1;
        status = IDPPurchaseRequestProgressBarCtrl.isStepActive2;
        status = IDPPurchaseRequestProgressBarCtrl.isStepActive3;
        status = IDPPurchaseRequestProgressBarCtrl.isStepActive4;
        status = IDPPurchaseRequestProgressBarCtrl.isStepActive5;
        status = IDPPurchaseRequestProgressBarCtrl.isStepActive6;
        status = IDPPurchaseRequestProgressBarCtrl.isStepActive7;
        status = IDPPurchaseRequestProgressBarCtrl.isStepActive8;
        status = IDPPurchaseRequestProgressBarCtrl.isStepActive9;        
        Test.stopTest();
    }
    
    private static Purchase_Request__c showPRStatus(String remark) {
        List<Purchase_Request__c> prList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, 
                                            LastModifiedDate, LastModifiedById, SystemModstamp,   Estimated_Total_Price__c, 
                                            Status__c, Delivery_To__c, On_Behalf_of__c, Need_by_Date__c, Apply_Date__c, 
                                            IDP_Policy__c, Catalog_Policy_Setting__c, Actual_Approver_1__c, Actual_Approver_2__c,
                                            Actual_Approver_3__c, Actual_Approver_4__c, Tech_Catalog_Owner_Queue_Name__c, Catalog__c,
                                            Estimated_Local_Total_Price__c, Tech_IDP_Policy_Name__c, Tech_C_Level_Approver__c, 
                                            Tech_ROI_Approver__c, Tech_Current_Approver__c, Last_Approval_Action_Date__c, 
                                            Submission_Date__c, Current_Approver__c, comment__c, Is_mine__c,   PR_Item_Count__c, 
                                            Standard_Exchange_Rate__c, Tech_On_Behalf_Of_Email__c, Tech_Applicant_Email__c, 
                                            Tech_Is_Approver__c,   Delivery_Site__c, PR_Item_Ordered_Count__c, PR_Item_Delivered_Count__c, 
                                            PR_Item_Closed_Count__c,  Applicant_Full_Name__c, PR_Item_Budget_Sub_Total__c, 
                                            PR_Item_Partial_Delivered_Count__c, PR_Item_Cancelled_Count__c, PR_Item_Excluding_Cancelled_Count__c, 
                                            Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c, Copy_to_6__c, 
                                            Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, Tech_Applicant_Site_Id__c, 
                                            Tech_Applicant_Site_Name__c, Delivery_Site_Name__c,   Catalog_Name__c, Closed_Date__c, 
                                            PR_Closed_Lead_Time__c, Budget_Forecast__c, Prev_Purchase_Request__c, Applicant_Function__c, 
                                            Applicant_Department__c, Applicant_Section__c, PR_Item_Approved_Count__c, 
                                            Tech_Is_Pending_Ordered__c FROM Purchase_Request__c LIMIT 1];
        log(remark + ' pr:'+prList);
        return prList.get(0);

    }

    private static Purchase_Request_Item__c showPRIStatus(String remark) {
        List<Purchase_Request_Item__c> priList = [SELECT Id, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, 
                                                  LastModifiedDate, LastModifiedById, SystemModstamp,  
                                                  Shipping_Cost_Local_Total_Amount__c, Catalog_Item__c, Catalog__c, 
                                                  Purchase_Request__c, Price__c, Unit_of_Measure__c, Purchase_Order_Item__c, 
                                                  Status__c, Tax_Local_Total_Amount__c, Quantity__c, Amount__c, Local_Sub_Total__c, 
                                                  Supplier__c, Tech_Budget_Exchange_Rate__c, Supplier_Source__c, Currency__c, 
                                                  Other_Cost_Local_Total_Amount__c, POI_External_Id__c, Is_Direct_fulfillment__c, 
                                                  Remark__c, Cost_Item__c, Number__c, Catalog_Name__c, Catalog_Item_Name__c, 
                                                  Budget_Exchange_Rate__c, Budget_Amount__c, Standard_Exchange_Rate__c, 
                                                  Standard_Currency__c, Used_Standard_Exchange_Rate__c, Local_Currency__c, 
                                                  Local_Exchange_Rate__c, Used_Local_Exchange_Rate__c, Standard_Amount__c, 
                                                  Local_Amount__c, Other_Cost_Original_Total_Amount__c, Other_Cost_Standard_Total_Amount__c, 
                                                  Standard_Sub_Total__c, Budget_Other_Cost_Total_Amount__c, 
                                                  Shipping_Cost_Standard_Total_Amount__c, Tax_Standard_Total_Amount__c, 
                                                  Purchase_Order__c, Total_Requested_Qty__c, Total_Received_Qty__c, Received_Qty__c, 
                                                  POI_Status__c, Tax_Original_Total_Amount__c, Shipping_Cost_Original_Total_Amount__c, 
                                                  Budget_Tax_Total_Amount__c, Budget_Shipping_Cost_Amount__c, Budget_Sub_Total__c, 
                                                  Tech_POI_PO_Currency_Used_Budget_Amount__c FROM Purchase_Request_Item__c LIMIT 1];
        log(remark + ' pri:'+priList);
        return priList.get(0);
    }

    private static void showExecutedQueries(String remark) {
        log(remark + ' executed queries:' + Limits.getQueries());
    }

    public static void log(String msg) {
        TestIDPUtility.log(msg);
    }

    public static void putParam(String key, String val) {
        TestIDPUtility.putParam(key, val);
    }
}