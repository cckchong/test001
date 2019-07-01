/**
 * @description 
 */
public class LibraryDetailedLocationExportCtrl {

    public List<Location__c> locationList {get;set;} {locationList = new List<Location__c>();}
    public boolean stickyMode {get;set;} {stickyMode = false;}
    
    public LibraryDetailedLocationExportCtrl() {
        String orderBy = ApexPages.currentPage().getParameters().get('orderBy');
        String nameExclude = ApexPages.currentPage().getParameters().get('nameExclude');
        String nameInclude = ApexPages.currentPage().getParameters().get('nameInclude');
        String sticky = ApexPages.currentPage().getParameters().get('sticky');
        
        if(!String.isEmpty(sticky) && sticky == 'true') {
            this.stickyMode = true;
        }
        
        List<Location__c> locationList;
        
        if(String.isEmpty(nameExclude) && String.isEmpty(nameInclude)) {
            locationList =
                [
                    
                    SELECT Id, Name, QR_Code__c, Site__c, Country__c
                    FROM Location__c
                    WHERE RecordType.DeveloperName = 'Detail_Location'
                    ORDER BY Name ASC
                    LIMIT 10000
                ];
        } else if(!String.isEmpty(nameExclude) && String.isEmpty(nameInclude)) {
            nameExclude = '%' + nameExclude + '%';
            locationList =
                [
                    
                    SELECT Id, Name, QR_Code__c, Site__c, Country__c
                    FROM Location__c
                    WHERE RecordType.DeveloperName = 'Detail_Location'
                    AND (NOT(Name LIKE :nameExclude))
                    ORDER BY Name ASC
                    LIMIT 10000
                ];
        } else if(String.isEmpty(nameExclude) && !String.isEmpty(nameInclude)) {
        	nameInclude = '%' + nameInclude + '%';
            locationList =
                [
                    
                    SELECT Id, Name, QR_Code__c, Site__c, Country__c
                    FROM Location__c
                    WHERE RecordType.DeveloperName = 'Detail_Location'
                    AND (Name LIKE :nameInclude)
                    ORDER BY Name ASC
                    LIMIT 10000
                ];
        } else {
			nameExclude = '%' + nameExclude + '%';
            nameInclude = '%' + nameInclude + '%';
            locationList =
                [
                    
                    SELECT Id, Name, QR_Code__c, Site__c, Country__c
                    FROM Location__c
                    WHERE RecordType.DeveloperName = 'Detail_Location'
                    AND (Name LIKE :nameInclude)
                    AND (NOT(Name LIKE :nameExclude))
                    ORDER BY Name ASC
                    LIMIT 10000
                ];            
        }
        
        if(locationList != null) {
            this.locationList = locationList;
        }
    }
}