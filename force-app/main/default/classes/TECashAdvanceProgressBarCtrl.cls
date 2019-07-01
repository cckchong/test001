/**
 * TECashAdvanceProgressBarCtrl
 * @author Kelvin Wong
 * @description show progress bar of Cash Advance
 */
public class TECashAdvanceProgressBarCtrl {
    
    /**
     * @description status label to show
     */
    public Cash_Advance__c MyRequest {get; set;}

    /**
     * @description step number of the current progress
     */
    public Integer Step {get; set;}

    /**
     * @description constructor with StandardController
     * @param stdController controller of Cash Advance(s)
     */
    public TECashAdvanceProgressBarCtrl(ApexPages.StandardController stdController) {
        this.MyRequest = (Cash_Advance__c) stdController.getRecord();
        this.MyRequest = [select Id, toLabel(Status__c) from Cash_Advance__c where Id =: MyRequest.Id];
        Cash_Advance__c MyRequest2 = [select Status__c from Cash_Advance__c where Id =: MyRequest.Id];
        Step = TEConstant.getCashAdvanceStep(MyRequest2.Status__c);
    }

}