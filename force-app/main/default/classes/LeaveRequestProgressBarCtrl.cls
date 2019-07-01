public class LeaveRequestProgressBarCtrl{

    public Leave_Request__c MyRequest {get; set;}

    public LeaveRequestProgressBarCtrl(ApexPages.StandardController stdController) {
        this.MyRequest = (Leave_Request__c) stdController.getRecord();
        this.MyRequest = [select Id, toLabel(Status__c), Step__c from Leave_Request__c where Id =: MyRequest.Id];
    }

}