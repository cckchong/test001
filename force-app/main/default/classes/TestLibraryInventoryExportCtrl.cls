@IsTest
public class TestLibraryInventoryExportCtrl {
    @isTest
    public static void testExportInv() {
        List<RecordType> bba = [SELECT Id FROM RecordType WHERE Name = 'Burberry Archive' AND SObjectType = 'Library_Item__c'];
        List<RecordType> detailRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Detail_Location' AND SObjectType = 'Location__c'];
        List<RecordType> generalRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'General_Location' AND SObjectType = 'Location__c'];
        System.assertNotEquals(null, bba);
        System.assertNotEquals(true, bba.isEmpty());
        
        Location__c genLoc = new Location__c(Name = 'GEN1', RecordTypeId = generalRt[0].Id);
        insert genLoc;
        
        Location__c detLoc = new Location__c(Name = 'DET1', RecordTypeId = detailRt[0].Id, Parent_Location__c = genLoc.Id);
        
        insert detLoc;
        
        Library_Item__c li = new Library_Item__c(Item_Name__c = 'BBA', RecordTypeId = bba[0].Id);
        insert li;
        
        Library_Inventory__c linv = new Library_Inventory__c(Library_Item_Master__c = li.Id);
        insert linv;
        
        PageReference pageRef = Page.LibraryInventoryExportVFP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('nameInclude', 'Burberry');
        
        LibraryInventoryExportCtrl ctrl = new LibraryInventoryExportCtrl();
        System.assertEquals(2, ctrl.invList.size());
        
        
        
    }
}