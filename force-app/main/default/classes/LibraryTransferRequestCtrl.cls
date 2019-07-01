/*
	LibraryTransferRequestCtrl Class
	Transfer the status of library item request 
*/
public class LibraryTransferRequestCtrl {

    public Library_Item_Request__c originalRequest {get;set;}
    public Library_Item_Request__c eligibleTransfer {get;set;}
    public boolean displayTransferButton {get;set;}
    
    //Constructor
    public LibraryTransferRequestCtrl(ApexPages.StandardController ctrl) {
        String theId = ApexPages.currentPage().getParameters().get('id');
        List<Library_Item_Request__c> lir = [
            SELECT Id, Name, Library_Item__c, Library_Item__r.Item_Name__c, Status__c, Requester__c, Item_Category__c, 
            	Library_Request_Inventory__r.Target_Address__r.Name, Library_Request_Inventory__r.Target_Address__r.Site__c
            FROM Library_Item_Request__c
        	WHERE Id =: theId
        ];
        if(!ErrorUtils.isEmpty(lir)) {
            this.originalRequest = lir[0];
        }
        this.initEligibleTransfers();
        this.displayTransferButton = true;
    }
    
    //initial requests where location is same as others
    public void initEligibleTransfers() {
        
        List<Library_Item_Request__c> lir = [
            SELECT Id, Name, Library_Item__c, Library_Item__r.Item_Name__c, Status__c, Requester__c, Item_Category__c, Library_Request_Inventory__r.Target_Address__r.Name,
            Target_Location__r.Name, CreatedDate, Target_Location__r.Site__c
            FROM Library_Item_Request__c
        	WHERE 	Library_Item__c =: originalRequest.Library_Item__c
            AND		Status__c =: Label.Library_Request_Status_Waitlist
            AND 	Target_Location__r.Site__c =: originalRequest.Library_Request_Inventory__r.Target_Address__r.Site__c
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];
        
        if(!ErrorUtils.isEmpty(lir) && this.originalRequest.Status__c == Label.Library_Request_Status_Inbound) {
            this.eligibleTransfer = lir[0];
        }
    }
    
    //Perform transfer action
    public PageReference transfer() {
        originalRequest.Status__c = Label.Library_Request_Status_Returned;
        eligibleTransfer.Status__c = Label.Library_Request_Status_Arrived;
        eligibleTransfer.Library_Request_Inventory__c = originalRequest.Library_Request_Inventory__c;
            
        SystemUtil.SafeUpdate(originalRequest);
        SystemUtil.SafeUpdate(eligibleTransfer);
        
        ErrorUtils.outputInfoMessage(Label.Library_Transfer_Successful);
        this.displayTransferButton = false;
        return null;
    }
}