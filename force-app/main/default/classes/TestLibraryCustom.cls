/*
* Test Class of LibraryUtility
*/
@isTest
private class TestLibraryCustom {

    static testMethod void unitTestLibraryUtility() {
        
        Integer num = [Select count() From Library_Item_Request__c Where Deadline__c<:System.today() AND Overdue__c = true And OwnerId =:userInfo.getUserId()];
        System.assertEquals(LibraryUtil.libraryOverdueItemCount, num);
        
        System.assertNotEquals(LibraryUtil.libraryOverdueWarningMessage,'');
       
        String hello = LibraryUtil.jsAlert('hello');
        String navHello = LibraryUtil.jsNavSObject('hello');
        
        List<String> inventoryIds = new List<String>();
        
        for(Library_Inventory__c li : [SELECT Id, name, Return_Date_Time__c,Lending_Status__c, Item_Category__c, Library_Item_Master__c, Library_Item_Master__r.ownerId, Original_Address__c FROM Library_Inventory__c WHERE 
        Lending_Status__c =:Label.Library_Inventory_Lending_Status_available]){
            inventoryIds.add(li.id);
        }
        
        LibraryUtil.invList(inventoryIds);
        LibraryUtil.availableList(inventoryIds);
        LibraryUtil.notAvailableList(inventoryIds);
        
        LibraryUtil.invList(null);
        LibraryUtil.availableList(null);
        LibraryUtil.notAvailableList(null);
        
        System.assertEquals(LibraryUtil.invList(null), null);
        System.assertEquals(LibraryUtil.availableList(null), null);
        System.assertEquals(LibraryUtil.notAvailableList(null), null);
        
        System.assertEquals(LibraryUtil.archiveCheckOutBtn, true);
        System.assertEquals(LibraryUtil.confirmReceivedBtn, true);
        System.assertEquals(LibraryUtil.borrowBtn, true);
        System.assertEquals(LibraryUtil.initialCheckInBtn, true);
        System.assertEquals(LibraryUtil.warehouseCheckOutBtn, true);
        System.assertEquals(LibraryUtil.MailingRoomCheckinOutBtn, true);
        System.assertEquals(LibraryUtil.MailingRoomCheckinInBtn, true);
        System.assertEquals(LibraryUtil.returnBtn, true);
        
        User u2 = LibraryTestDataUtility.createUser('Standard User');
        System.runAs(u2){
            Boolean b1 = LibraryUtil.archiveCheckOutBtn      ;
            Boolean b2 = LibraryUtil.confirmReceivedBtn      ;
            Boolean b3 = LibraryUtil.borrowBtn               ;
            Boolean b4 = LibraryUtil.initialCheckInBtn       ;
            Boolean b5 = LibraryUtil.warehouseCheckOutBtn    ;
            Boolean b6 = LibraryUtil.MailingRoomCheckinOutBtn;
            Boolean b7 = LibraryUtil.MailingRoomCheckinInBtn ;
            Boolean b8 = LibraryUtil.returnBtn               ;
        }
    }
}