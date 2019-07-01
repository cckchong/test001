/**
 * Test Class of LibraryItemRequestViewCtrl
 */
@isTest
private class TestLibraryItemRequestViewCtrl {

    static testMethod void myUnitTest() {
        
        LibraryItemRequestViewCtrl reqView = new LibraryItemRequestViewCtrl();
        
        Request__c req = LibraryTestDataUtility.insertRequest('O');
        Library_Item_Request__c itemReq = LibraryTestDataUtility.insertLibraryRequestNotSubmitted();
        itemReq.Bulk_Request__c = req.id;
        update itemReq;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(req);
        PageReference pageRef = Page.LibraryItemRequestAddVFPage;
        pageRef.getParameters().put('id', req.id);
        Test.setCurrentPage(pageRef);
        reqView = new LibraryItemRequestViewCtrl(sc);
        
        pageReference pr = reqView.initial();
        pr = reqView.onload();
        pr = reqView.cancelButton();
        pr = reqView.viewRequest();
        pr = reqView.overrrideNewRequestAction();
        reqView.outputMessage('abc');
        String historyBack = reqView.historyBack();
        reqView.isSalesforceOne =true;
        historyBack = reqView.historyBack();
        
        List<Fls_Search_Params__c> fspList = new List<Fls_Search_Params__c>();
        
        Fls_Search_Params__c fsp = new Fls_Search_Params__c();
        
        fsp.name = 'BRAND_CUSTOMER425501';
        fsp.Field_Name__c = 'BRAND_CUSTOMER425501';
        fsp.Key__c ='425501';
        fsp.Value__c='R&D1';
        
        fspList.add(fsp);
        
        Fls_Search_Params__c fsp1 = new Fls_Search_Params__c();
        
        fsp1.name = 'brand_customer';
        fsp1.Field_Name__c = 'brand_customer';
        fsp1.Key__c ='425502';
        fsp1.Value__c='R&D2';
        
        
        fspList.add(fsp1);
        
        upsert fspList;
        
        List<SelectOption> sList = reqView.BrandCustomerList;
        
        
        
    }
    
    static testMethod void unitTestSubmitCart(){
        
        Map<Id, String> mapProfile = new Map<Id, String>();
        for(Profile p: [SELECT Name, Id FROM Profile]) {
            mapProfile.put(p.Id, P.Name);
        }
        
        Request__c req = LibraryTestDataUtility.insertRequest('O');
        Library_Item__c fabricItem = LibraryTestDataUtility.insertLibItem('Fabric');
        fabricItem.Require_Approval__c = true;
        update fabricItem;
        
        //Added by TAL (Twinkle LI) @20170727 - Testclss coverage issue
        LibraryItemTriggerHandler.upsertSampleFabric2(fabricItem.id, fabricItem.id, fabricItem.id, '');
        //End
        
        Library_Inventory__c fabricInv = LibraryTestDataUtility.insertBookInventory(fabricItem);
        Library_Item_Request__c fabricReq = LibraryTestDataUtility.insertLibRequest(fabricItem.id, fabricInv.id ,'Not Submitted');
        
        fabricReq.Bulk_Request__c = req.id;
        update fabricReq;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(req);
        PageReference pageRef = Page.LibraryItemRequestAddVFPage;
        pageRef.getParameters().put('id', req.id);
        pageRef.getParameters().put('libItemId', fabricItem.id);
        pageRef.getParameters().put('multiLibItemId', fabricItem.id);
        pageRef.getParameters().put('barcode', fabricItem.id);
        
        Test.setCurrentPage(pageRef);
        LibraryItemRequestViewCtrl reqView = new LibraryItemRequestViewCtrl(sc);
        Location__c genLoc = LibraryTestDataUtility.insertGenLocation('HKO');
        reqView.isSalesforceOne =true;
        User u = LibraryTestDataUtility.createUser(Label.Library_Profile_TFEWA);
        System.runAs(u){
            pageRef = reqView.addToLibraryCart();
            pageRef = reqView.submitCart();
        }
    }
    
    static testMethod void unitTestSubmitBook(){
        Map<Id, String> mapProfile = new Map<Id, String>();
        for(Profile p: [SELECT Name, Id FROM Profile]) {
            mapProfile.put(p.Id, P.Name);
        }
        
        Request__c req = LibraryTestDataUtility.insertRequest('O');
        Library_Item__c bookItem = LibraryTestDataUtility.insertLibItem('Book');
        Library_Inventory__c bookInv = [select id from Library_Inventory__c limit 1];
        Library_Item_Request__c bookReq = LibraryTestDataUtility.insertLibRequest(bookItem.id, bookInv.id ,'Not Submitted');
        
        bookReq.Bulk_Request__c = req.id;
        update bookReq;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(req);
        PageReference pageRef = Page.LibraryItemRequestAddVFPage;
        pageRef.getParameters().put('id', req.id);
        pageRef.getParameters().put('libItemId', bookItem.id);
        pageRef.getParameters().put('multiLibItemId', bookItem.id);
        pageRef.getParameters().put('barcode', bookItem.id);
        pageRef.getParameters().put('book', 'Book');
        
        Test.setCurrentPage(pageRef);
        LibraryItemRequestViewCtrl reqView = new LibraryItemRequestViewCtrl(sc);
        Location__c genLoc = LibraryTestDataUtility.insertGenLocation('HKO');
        pageRef = reqView.addToLibraryCart();
        pageRef = reqView.submitCart();
    }
    
    static testMethod void unitTestSubmitFabric(){
        
        Map<Id, String> mapProfile = new Map<Id, String>();
        for(Profile p: [SELECT Name, Id FROM Profile]) {
            mapProfile.put(p.Id, P.Name);
        }
        
        Request__c req = LibraryTestDataUtility.insertRequest('O');
        req.Brand_Customer__c ='aaa';
        update req;
        Library_Item__c fabricItem = LibraryTestDataUtility.insertLibItem('Fabric');
        fabricItem.Require_Approval__c = true;
        update fabricItem;
        
        Library_Inventory__c fabricInv = LibraryTestDataUtility.insertBookInventory(fabricItem);
        Library_Item_Request__c fabricReq = LibraryTestDataUtility.insertLibRequest(fabricItem.id, fabricInv.id ,'Not Submitted');
        
        fabricReq.Bulk_Request__c = req.id;
        update fabricReq;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(req);
        PageReference pageRef = Page.LibraryItemRequestAddVFPage;
        pageRef.getParameters().put('id', req.id);
        pageRef.getParameters().put('libItemId', fabricItem.id);
        pageRef.getParameters().put('multiLibItemId', fabricItem.id);
        pageRef.getParameters().put('barcode', fabricItem.id);
        pageRef.getParameters().put('book', '');
        
        Test.setCurrentPage(pageRef);
        LibraryItemRequestViewCtrl reqView = new LibraryItemRequestViewCtrl(sc);
        pageRef = reqView.addToLibraryCart();
        pageRef = reqView.submitCart();
    }
    
    static testMethod void unitTestSubmitWarehouse(){
        Map<Id, String> mapProfile = new Map<Id, String>();
        for(Profile p: [SELECT Name, Id FROM Profile]) {
            mapProfile.put(p.Id, P.Name);
        }
        
        Request__c req = LibraryTestDataUtility.insertRequest('O');
        
        
        Library_Item__c warehouseItem = LibraryTestDataUtility.insertLibItem('Warehouse');
        Library_Inventory__c warehouseInv = LibraryTestDataUtility.insertBookInventory(warehouseItem);
        Library_Item_Request__c warehouseReq = LibraryTestDataUtility.insertLibRequest(warehouseItem.id, warehouseInv.id ,'Not Submitted');
        
        warehouseReq.Bulk_Request__c = req.id;
        update warehouseReq;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(req);
        PageReference pageRef = Page.LibraryItemRequestAddVFPage;
        pageRef.getParameters().put('id', req.id);
        pageRef.getParameters().put('libItemId', null);
        pageRef.getParameters().put('multiLibItemId', warehouseItem.id);
        pageRef.getParameters().put('barcode', warehouseItem.id);
        pageRef.getParameters().put('book', '');
        
        Test.setCurrentPage(pageRef);
        LibraryItemRequestViewCtrl reqView = new LibraryItemRequestViewCtrl(sc);
        
        User u = LibraryTestDataUtility.createUser(Label.Library_Profile_TFEWA);
        System.runAs(u){
            pageRef = reqView.addToLibraryCart();
            pageRef = reqView.submitCart();
        }
    }
    
    static testMethod void unitTestSubmitPD(){
        Map<Id, String> mapProfile = new Map<Id, String>();
        for(Profile p: [SELECT Name, Id FROM Profile]) {
            mapProfile.put(p.Id, P.Name);
        }
        
        Request__c req = LibraryTestDataUtility.insertRequest('O');
        Library_Item__c pdItem = LibraryTestDataUtility.insertLibItem('Samples PD');
        User u = LibraryTestDataUtility.createUser(Label.Library_Profile_TFEWA);
        
        //Added by TAL (Twinkle LI) @20170727 - Testclss coverage issue
        pdItem.Sample_Fabric_ID_1__c = 'ID1';
        pdItem.Sample_Fabric_ID_2__c = 'ID2';
        pdItem.Sample_Fabric_ID_3__c = 'ID3';
        pdItem.Sample_Fabric_ID_4__c = 'ID4';
        update pdItem;
        //End
        
        Library_Inventory__c pdInv = LibraryTestDataUtility.insertBookInventory(pdItem);
        Library_Item_Request__c pdReq = LibraryTestDataUtility.insertLibRequest(pdItem.id, pdInv.id ,'Not Submitted');
        
        pdReq.Bulk_Request__c = req.id;
        update pdReq;
        
        //Added by TAL (Twinkle LI) @20170727 - Testclss coverage issue
        pdItem.OwnerId = u.id;
        pdItem.Owner_2__c = u.id;
        pdItem.Owner_3__c = u.id;
        pdItem.Owner_4__c = u.id;
        pdItem.Sample_Fabric_ID_1__c = '';
        pdItem.Sample_Fabric_ID_2__c = '';
        pdItem.Sample_Fabric_ID_3__c = '';
        pdItem.Sample_Fabric_ID_4__c = '';
        update pdItem;
        //End
        
        ApexPages.StandardController sc = new ApexPages.StandardController(req);
        PageReference pageRef = Page.LibraryItemRequestAddVFPage;
        pageRef.getParameters().put('id', req.id);
        pageRef.getParameters().put('libItemId', pdReq.id);
        pageRef.getParameters().put('multiLibItemId', pdReq.id);
        pageRef.getParameters().put('barcode', pdReq.id);
        pageRef.getParameters().put('book', '');
        
        Test.setCurrentPage(pageRef);
        LibraryItemRequestViewCtrl reqView = new LibraryItemRequestViewCtrl(sc);
        pageRef = reqView.addToLibraryCart();
        pageRef = reqView.submitCart();
    }
    
    static testMethod void unitTestSubmitTGA(){
        Map<Id, String> mapProfile = new Map<Id, String>();
        for(Profile p: [SELECT Name, Id FROM Profile]) {
            mapProfile.put(p.Id, P.Name);
        }
        
        Request__c req = LibraryTestDataUtility.insertRequest('O');
        
        Library_Item__c tgaItem = LibraryTestDataUtility.insertLibItem('Samples TGA');
        Library_Inventory__c tgaInv = LibraryTestDataUtility.insertBookInventory(tgaItem);
        Library_Item_Request__c tgaReq = LibraryTestDataUtility.insertLibRequest(tgaItem.id, tgaInv.id ,'Not Submitted');
        
        tgaReq.Bulk_Request__c = req.id;
        update tgaReq;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(req);
        PageReference pageRef = Page.LibraryItemRequestAddVFPage;
        pageRef.getParameters().put('id', req.id);
        pageRef.getParameters().put('libItemId', tgaReq.id);
        pageRef.getParameters().put('multiLibItemId', tgaReq.id);
        pageRef.getParameters().put('barcode', tgaReq.id);
        pageRef.getParameters().put('book', '');
        
        Test.setCurrentPage(pageRef);
        LibraryItemRequestViewCtrl reqView = new LibraryItemRequestViewCtrl(sc);
        pageRef = reqView.addToLibraryCart();
        pageRef = reqView.submitCart();
    }
    
    //@IsTest(SeeAllData=true)
    static void unitTestBulkTGA(){
        
        LibraryTestDataUtility.insertLibraryCategorySettings();
        
        Map<Id, String> mapProfile = new Map<Id, String>();
        for(Profile p: [SELECT Name, Id FROM Profile]) {
            mapProfile.put(p.Id, P.Name);
        }
        
        Request__c req = LibraryTestDataUtility.insertRequest('O');
        
        Library_Item__c tgaItem = LibraryTestDataUtility.insertLibItem('Samples TGA');
        Library_Inventory__c tgaInv = [select id from Library_Inventory__c where Library_Item_Master__c =: tgaItem.id limit 1];
        Library_Item__c tgaItem1 = LibraryTestDataUtility.insertLibItem('Samples TGA');
        Library_Inventory__c tgaInv1 = [select id from Library_Inventory__c where Library_Item_Master__c =: tgaItem.id limit 1];
        Library_Item_Request__c tgaReq = LibraryTestDataUtility.insertLibRequest(tgaItem.id, tgaInv.id ,Label.Library_Request_Status_Reserved);
        
        
        Location__c genLoc = LibraryTestDataUtility.insertGenLocation('HKO');
        Location__c deLoc = LibraryTestDataUtility.insertDetailLocation('HKO-PD',genLoc.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(req);
        PageReference pageRef = Page.LibraryItemRequestAddVFPage;
        
        pageRef.getParameters().put(Label.Library_actionType, Label.Library_checkout);
        pageRef.getParameters().put(Label.Library_multiLibItemId, tgaInv.id);
        pageRef.getParameters().put(Label.Library_redirect, '');
        pageRef.getParameters().put(Label.Library_locationId, deLoc.id);
        Test.setCurrentPage(pageRef);
        LibraryItemRequestViewCtrl reqView = new LibraryItemRequestViewCtrl(sc);
        pageRef = reqView.bulkActions();
        
        
        tgaReq.Status__c = Label.Library_Request_Status_Outbound;
        update tgaReq;
        
        PageReference pageMailOut = Page.LibraryItemRequestAddVFPage;
        pageMailOut.getParameters().put(Label.Library_actionType, Label.Library_mail_out);
        pageMailOut.getParameters().put(Label.Library_multiLibItemId, tgaInv.id);
        pageMailOut.getParameters().put(Label.Library_redirect, '');
        pageMailOut.getParameters().put(Label.Library_locationId, deLoc.id);
        Test.setCurrentPage(pageMailOut);
        reqView = new LibraryItemRequestViewCtrl(sc);
        pageMailOut = reqView.bulkActions();
        
        
        tgaReq.Status__c = Label.Library_Request_Status_Arrived;
        update tgaReq;
        PageReference pageRec = Page.LibraryItemRequestAddVFPage;
        pageRec.getParameters().put(Label.Library_actionType, Label.Library_received);
        pageRec.getParameters().put(Label.Library_multiLibItemId, tgaInv.id);
        pageRec.getParameters().put(Label.Library_redirect, '');
        pageRec.getParameters().put(Label.Library_locationId, deLoc.id);
        Test.setCurrentPage(pageRec);
        reqView = new LibraryItemRequestViewCtrl(sc);
        pageRec = reqView.bulkActions();
        
    }
    
}