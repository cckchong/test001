@isTest
public class TestLibraryDetailedLocationExportCtrl {
	
    @isTest
    public static void testExportLocations() {
        List<RecordType> detailRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Detail_Location' AND SObjectType = 'Location__c'];
        List<RecordType> generalRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'General_Location' AND SObjectType = 'Location__c'];
        
        PageReference pageRef = Page.LibraryDetailedLocationExportVFP;
    	Test.setCurrentPage(pageRef);
    	
            
        Location__c genLoc = new Location__c(Name = 'GEN1', RecordTypeId = generalRt[0].Id);
        insert genLoc;
        
        Location__c detLoc = new Location__c(Name = 'DET1', RecordTypeId = detailRt[0].Id, Parent_Location__c = genLoc.Id);
        
        insert detLoc;
        
        LibraryDetailedLocationExportCtrl ctrl = new LibraryDetailedLocationExportCtrl();
        System.assertEquals(1, ctrl.locationList.size());
        
        pageRef.getParameters().put('nameExclude', 'BBA');
        
        LibraryDetailedLocationExportCtrl ctrl2 = new LibraryDetailedLocationExportCtrl();
        System.assertEquals(1, ctrl2.locationList.size());
        
        pageRef.getParameters().put('nameExclude', null);
        pageRef.getParameters().put('nameInclude', 'BLAH');
        
        LibraryDetailedLocationExportCtrl ctrl3 = new LibraryDetailedLocationExportCtrl();
        System.assertEquals(0, ctrl3.locationList.size());
        
        pageRef.getParameters().put('nameExclude', 'BBA');
       
        LibraryDetailedLocationExportCtrl ctrl4 = new LibraryDetailedLocationExportCtrl();
        System.assertEquals(0, ctrl4.locationList.size());
    }
}