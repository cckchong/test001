/**
 * Test Class of LibraryItemTriggerHandler
 */
@isTest
private class TestLibraryItemTriggerHandler {

    static testMethod void myUnitTestWarehouse() {
    	
    	Map<Id,Library_Item__c> NewItemMap = new Map<Id,Library_Item__c>();
    	Map<Id,Library_Item__c> OldItemMap = new Map<Id,Library_Item__c>();
    	
    	User u = LibraryTestDataUtility.createUser(Label.Library_Profile_TFEWA);
    	
        Library_Item__c warehouseItem = LibraryTestDataUtility.insertLibItem('Warehouse');
        Library_Inventory__c warehouseInv = [select id from Library_Inventory__c limit 1];
        LibraryTestDataUtility.insertLibRequest(warehouseItem.id,warehouseInv.id, 'Reserved');
        
        OldItemMap.put(warehouseItem.id, warehouseItem);
        
        warehouseItem.Owner_2__c = u.id;
        warehouseItem.Owner_3__c = u.id;
        warehouseItem.Owner_4__c = u.id;
        if(warehouseItem.Can_Be_Borrowed__c){
        	warehouseItem.Can_Be_Borrowed__c =false;
        }else{
        	warehouseItem.Can_Be_Borrowed__c =true;
        }
        
        
        NewItemMap.put(warehouseItem.id, warehouseItem);
        
        LibraryItemTriggerHandler.updateRequestApprovers(NewItemMap,OldItemMap);
        LibraryItemTriggerHandler.updateRelatedInventory(NewItemMap,OldItemMap);
    }
    
    
}