/*
    LibraryItemRequestOverwriteDeleteCtrl Class
    
    @Author: AN, WG, NW
	@Object: Library_Item_Request__c
    @Description: Used to override the Delete button for Library_Item_Request__c
*/
public with sharing class LibraryItemRequestOverwriteDeleteCtrl{
    
    public boolean isSalesforceOne{get;set;}{isSalesforceOne = SystemUtil.isMobileDevice();}
    public Library_Item_Request__c objLIR {get;set;}
	public boolean isError{get;set;}
    
    //Constructor, request only can be delete under Not submitted status
    public LibraryItemRequestOverwriteDeleteCtrl(ApexPages.StandardController controller) {
        isSalesforceOne = false;
        isError = false;
        Library_Item_Request__c lir = new Library_Item_Request__c();
        lir = (Library_Item_Request__c) controller.getRecord();
        this.objLIR = [Select Id, Name, Status__c, Bulk_Request__c From Library_Item_Request__c Where Id = :lir.Id];
        if(objLIR.status__c != Label.Library_Request_Status_Not_Submitted  && UserInfo.getProfileId() != Label.Library_Admin_Profile_Id){
            isError = true;
        }
    }
    
    //Perform delete action
    public PageReference onload() {
        if(objLIR.status__c != Label.Library_Request_Status_Not_Submitted  && UserInfo.getProfileId() != Label.Library_Admin_Profile_Id) {
            isError = true;
            return null;
        } else {           
            SystemUtil.SafeDelete(objLIR);
            return null;
        }
    }
}