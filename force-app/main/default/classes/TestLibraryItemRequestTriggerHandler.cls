/**
 * Test Class of LibraryItemRequestTriggerHandler
 */
@isTest
private class TestLibraryItemRequestTriggerHandler {
	
	@IsTest(SeeAllData=true)
    static  void myUnitTest() {
        Library_Item__c bookItem = LibraryTestDataUtility.insertLibItem('Book');
        Library_Inventory__c bookInv = [select id from Library_Inventory__c limit 1];
        
       //Library_Item_Request__c pendingReq = LibraryTestDataUtility.insertLibraryRequest('Pending Approval');
        Library_Item_Request__c resReq = LibraryTestDataUtility.insertLibRequest(bookItem.id, bookInv.id, 'Reserved');
    	Library_Item_Request__c resReq1 = LibraryTestDataUtility.insertLibRequest(bookItem.id, bookInv.id, 'Not Submitted');
    	
    	
    	Map<Id,Library_Item_Request__c> oldMap = new Map<Id,Library_Item_Request__c>();
    	oldMap.put(resReq.id,resReq);
    	oldMap.put(resReq1.id,resReq1);
    	
    	List<Library_Item_Request__c> reqList = new List<Library_Item_Request__c>();
    	reqList.add(resReq);
    	reqList.add(resReq1);
    	LibraryItemRequestTriggerHandler.updateStatusToInboundInTransit(reqList);
    	LibraryItemRequestTriggerHandler.updateStatusToReturned(reqList);
    	//LibraryItemRequestTriggerHandler.updateStatusToLost(reqList);
    	LibraryItemRequestTriggerHandler.cancelOrReturnProcessFlow(reqList, oldMap);
    	Library_Item_Request__c waitReq = LibraryTestDataUtility.insertLibRequest(bookItem.id, null, 'Waitlist');
    	LibraryItemRequestTriggerHandler.cancelOrReturnProcessFlow(reqList, oldMap);
    	
    }
    
    static testMethod void unitTestForBookReq() {
    	
    	LibraryTestDataUtility.insertLibraryCategorySettings();
    	Library_Item__c bookItem = LibraryTestDataUtility.insertLibItem('Book');
        Library_Inventory__c bookInv = [select id, Name, Return_Date_Time__c  from Library_Inventory__c limit 1];
        
        Library_Item_Request__c resReq = LibraryTestDataUtility.insertLibRequest(bookItem.id, bookInv.id, 'Not Submitted');
        resReq= [select id, Item_Category__c,Library_Request_Inventory__c from Library_Item_Request__c limit 1];
        
        List<Library_Item_Request__c> reqList = new List<Library_Item_Request__c>();
    	reqList.add(resReq);
 		LibraryItemRequestTriggerHandler.updateStatusToBorrowed(reqList);
        
    }
    
    
    static testMethod void unitTestUpdateWaitlistReqsToReserved() {
    	
    	Library_Item__c bookItem = LibraryTestDataUtility.insertLibItem('Book');
        Library_Inventory__c bookInv = [select id, Name, Return_Date_Time__c, Library_Item_Master__c  from Library_Inventory__c limit 1];
        
        Library_Item_Request__c resReq = LibraryTestDataUtility.insertLibRequest(bookItem.id, bookInv.id, 'Library_Request_Status_Waitlist');
        
        List<Library_Inventory__c> invList = new List<Library_Inventory__c>();
        invList.add(bookInv);
    	
    	LibraryInventoryTriggerHandler.updateWaitlistReqsToReserved(invList);
    }
}