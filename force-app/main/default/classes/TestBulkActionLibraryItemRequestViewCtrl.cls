/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestBulkActionLibraryItemRequestViewCtrl {
	
	private static ID testDetailLocationId;
	private static Set<ID> testInventoryIdSet = new Set<ID>();
	private static ID testLibRequestId;

    static void setup() {
    	// Intialize testing data
    	// TODO: Test more than one libraries
    	// LibraryTestDataUtility.insertLibraryCategorySettings();
    	Map<String, Schema.RecordTypeInfo> libItemRecordTypeInfosByName = Schema.SObjectType.Library_Item__c.getRecordTypeInfosByName();
        Library_Item__c libItem = LibraryTestDataUtility.insertLibItem(libItemRecordTypeInfosByName.get('Fabric').getName());
        Library_Inventory__c inventory = LibraryTestDataUtility.insertBookInventory(libItem);
        Library_Item_Request__c libRequest = LibraryTestDataUtility.insertLibRequest(libItem.Id, inventory.Id, Label.Library_Request_Status_Reserved);
        
        Location__c detailLocation = [select Id, Name, Parent_Location__c, RecordType.Name, CreatedDate from Location__c where Name = '3F' order by CreatedDate desc limit 1];
        testDetailLocationId = detailLocation.Id;
        testInventoryIdSet.add(inventory.Id);
        testLibRequestId = libRequest.Id;
    }
    
    /*
     * TestLibraryItemRequestViewCtrl.unitTestBulkTGA() test method is comment out by unknown reason
     * Rewrite the test method in order to cover LibraryItemRequestViewCtrl.bulkActions()
     * Use SeeAllData=true due to ChatterApi.ChatterFeeds.postFeedItem() method
     */
    @isTest(SeeAllData=true)
    static void testNormalFlow() {
    	setup();
    	
    	Library_Item_Request__c libRequest = [select Id from Library_Item_Request__c where Id = :testLibRequestId];
    	Set<ID> inventoryIds = new Set<ID>();
    	for (Library_Inventory__c inventory : [select Id from Library_Inventory__c where Id in :testInventoryIdSet]) {
    		inventoryIds.add(inventory.Id);
    	}
        
        Test.startTest();
        
        testCheckout(libRequest, inventoryIds);
        testMailOut(libRequest, inventoryIds);
        testReceive(libRequest, inventoryIds);
        testMailIn(libRequest, inventoryIds);
        testReturn(libRequest, inventoryIds, testDetailLocationId);
        testCheckin(libRequest, inventoryIds, testDetailLocationId);
        
        Test.stopTest();
    }
    
    private static void testCheckout(Library_Item_Request__c libRequest, Set<ID> inventoryIdSet) {
    	final String redirectLink = 'apex/LibraryQrCodeScanVFP';

        LibraryItemRequestViewCtrl libItemReqViewCtrl = setupController(libRequest, Label.Library_checkout, inventoryIdSet, redirectLink, null);
        
        PageReference resultPage = libItemReqViewCtrl.bulkActions();
        
        System.assert(resultPage != null, 'Some errors occur in library item request bulk action');
        System.assertEquals('/' + redirectLink, resultPage.getUrl());
        Library_Item_Request__c resultLibRequest = [select Id, Status__c from Library_Item_Request__c where Id = :libRequest.Id];
        System.assertEquals(Label.Library_Request_Status_Outbound, resultLibRequest.Status__c);
    }
    
    private static void testMailOut(Library_Item_Request__c libRequest, Set<ID> inventoryIdSet) {
    	final String redirectLink = 'apex/LibraryQrCodeScanVFP';

        LibraryItemRequestViewCtrl libItemReqViewCtrl = setupController(libRequest, Label.Library_mail_out, inventoryIdSet, redirectLink, null);
        
        PageReference resultPage = libItemReqViewCtrl.bulkActions();
        
        System.assert(resultPage != null, 'Some errors occur in library item request bulk action');
        System.assertEquals('/' + redirectLink, resultPage.getUrl());
        Library_Item_Request__c resultLibRequest = [select Id, Status__c from Library_Item_Request__c where Id = :libRequest.Id];
        System.assertEquals(Label.Library_Request_Status_Arrived, resultLibRequest.Status__c);
    }
    
    private static void testReceive(Library_Item_Request__c libRequest, Set<ID> inventoryIdSet) {
    	final String redirectLink = 'apex/LibraryQrCodeScanVFP';

        LibraryItemRequestViewCtrl libItemReqViewCtrl = setupController(libRequest, Label.Library_received, inventoryIdSet, redirectLink, null);
        
        PageReference resultPage = libItemReqViewCtrl.bulkActions();
        
        System.assert(resultPage != null, 'Some errors occur in library item request bulk action');
        System.assertEquals('/' + redirectLink, resultPage.getUrl());
        Library_Item_Request__c resultLibRequest = [select Id, Status__c from Library_Item_Request__c where Id = :libRequest.Id];
        System.assertEquals(Label.Library_Request_Status_Borrowed, resultLibRequest.Status__c);
    }
    
    private static void testMailIn(Library_Item_Request__c libRequest, Set<ID> inventoryIdSet) {
    	final String redirectLink = 'apex/LibraryQrCodeScanVFP';

        LibraryItemRequestViewCtrl libItemReqViewCtrl = setupController(libRequest, Label.Library_mail_in, inventoryIdSet, redirectLink, null);
        
        PageReference resultPage = libItemReqViewCtrl.bulkActions();
        
        System.assert(resultPage != null, 'Some errors occur in library item request bulk action');
        System.assertEquals('/' + redirectLink, resultPage.getUrl());
        Library_Item_Request__c resultLibRequest = [select Id, Status__c from Library_Item_Request__c where Id = :libRequest.Id];
        System.assertEquals(Label.Library_Request_Status_Inbound, resultLibRequest.Status__c);
    }
    
    private static void testReturn(Library_Item_Request__c libRequest, Set<ID> inventoryIdSet, Id locationId) {
    	final String redirectLink = 'apex/LibraryQrCodeScanVFP';

        LibraryItemRequestViewCtrl libItemReqViewCtrl = setupController(libRequest, Label.Library_Return, inventoryIdSet, redirectLink, locationId);
        
        PageReference resultPage = libItemReqViewCtrl.bulkActions();
        
        System.assert(resultPage != null, 'Some errors occur in library item request bulk action');
        System.assertEquals('/' + redirectLink, resultPage.getUrl());
        Library_Item_Request__c resultLibRequest = [select Id, Status__c from Library_Item_Request__c where Id = :libRequest.Id];
        System.assertEquals(Label.Library_Request_Status_Returned, resultLibRequest.Status__c);
    }
    
    private static void testCheckin(Library_Item_Request__c libRequest, Set<ID> inventoryIdSet, Id locationId) {
    	final String redirectLink = 'apex/LibraryQrCodeScanVFP';

        LibraryItemRequestViewCtrl libItemReqViewCtrl = setupController(libRequest, Label.Library_checkin, inventoryIdSet, redirectLink, locationId);
        
        PageReference resultPage = libItemReqViewCtrl.bulkActions();
        
        System.assert(resultPage != null, 'Some errors occur in library item request bulk action');
        System.assertEquals('/' + redirectLink, resultPage.getUrl());
        // Library_Item_Request__c resultLibRequest = [select Id, Status__c from Library_Item_Request__c where Id = :libRequest.Id];
        // System.assertEquals(Label.Library_Inventory_Lending_Status_available, resultLibRequest.Status__c);
    }
    
    private static LibraryItemRequestViewCtrl setupController(Library_Item_Request__c libRequest, String actionType, Set<ID> inventoryIdSet, String redirectLink, ID locationId) {
    	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(libRequest);
        LibraryItemRequestViewCtrl libItemReqViewCtrl = new LibraryItemRequestViewCtrl(stdCtrl);
        Test.setCurrentPage(Page.LibraryScanBulkActionsVFPage);
        
        PageReference currentPage = ApexPages.currentPage();
        currentPage.getParameters().put(Label.Library_actionType, actionType);
        String inventoryIdsStr = '';
        for (ID inventoryId : inventoryIdSet) {
        	inventoryIdsStr += inventoryId + ';';
        }
        currentPage.getParameters().put(Label.Library_multiLibItemId, inventoryIdsStr.substringBeforeLast(';'));
        if (redirectLink != null) {
        	currentPage.getParameters().put(Label.Library_redirect, redirectLink);
        }
        if (locationId != null) {
        	currentPage.getParameters().put(Label.Library_locationId, locationId);
        }
        
        return libItemReqViewCtrl;
    }
}