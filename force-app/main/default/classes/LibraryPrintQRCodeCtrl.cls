/*
	LibraryPrintQRCodeCtrl Class
	Used to assign the value to Library_Inventory__c
*/
public with sharing class LibraryPrintQRCodeCtrl{
    public Library_Inventory__c inv {get;set;}
    
    //Constructor, get the inventory
    public LibraryPrintQRCodeCtrl(ApexPages.StandardController controller) {
        String theId = controller.getRecord().Id;
        if(theId != '' && theId != null) {
            List<Library_Inventory__c> li = [Select Id, Name, QR_Code__c, QR_Code_Number__c, FLS_QR_Code_Suffix__c, Serial_Number__c, Library_Item_Master__r.RecordType.Name, Library_Item_Master__r.RecordType.DeveloperName
                                             From Library_Inventory__c Where Id = :theId limit 1];
        	if(li!=null && !li.isEmpty()){
        		inv = li.get(0);
        	} else {
        		inv = new Library_Inventory__c();
        	}
        }
    }    
}