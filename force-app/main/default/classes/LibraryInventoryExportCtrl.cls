public class LibraryInventoryExportCtrl {
    public List<Library_Inventory__c> invList {get;set;} {invList = new List<Library_Inventory__c>();}
    public boolean stickyMode {get;set;} {stickyMode = false;}
    
    public LibraryInventoryExportCtrl() {
        //String orderBy = ApexPages.currentPage().getParameters().get('orderBy');
        //String nameExclude = ApexPages.currentPage().getParameters().get('nameExclude');
        String nameInclude = ApexPages.currentPage().getParameters().get('nameInclude');
        String sticky = ApexPages.currentPage().getParameters().get('sticky');
        
        if(!String.isEmpty(sticky) && sticky == 'true') {
            this.stickyMode = true;
        }
        
        List<Library_Inventory__c> invList;
        
        if(!String.isEmpty(nameInclude)) {
            nameInclude = '%' + nameInclude + '%';
            invList =
                [
                    
                    SELECT Id, Name, QR_Code__c, Serial_Number__c, Item_Category__c, Library_Item_Master__r.Item_Name__c
                    FROM Library_Inventory__c
                    WHERE Item_Category__c LIKE :nameInclude
                    ORDER BY Serial_Number__c ASC
                    LIMIT 10000
                ];
            
        } 
        
        if(invList != null) {
            this.invList = invList;
        }
    }
}