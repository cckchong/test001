/*
	LibraryItemRequestProgressBarCtrl Class
	
	@Author: AN, WG, NW
	@Object: Library_Item_Request__c
	@Description: Used to assign the current record id to Library_Item_Request__c object
*/
public class LibraryItemRequestProgressBarCtrl{
	public Library_Item_Request__c MyRequest {get; set;}
	
	//Constructor, get the current request to MyRequest, and then display for the progress bar
	public LibraryItemRequestProgressBarCtrl(ApexPages.StandardController stdController) {
		this.MyRequest = (Library_Item_Request__c)stdController.getRecord();
		this.MyRequest = [select Id, Request_Progress__c, Request_Progress_Book__c, Request_Progress_BBA__c, toLabel(Status__c), Item_Category__c from Library_Item_Request__c where Id =: MyRequest.Id];
	}
}