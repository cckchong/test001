/**
 * TEExpenseDetailProgressBarCtrl
 * @author Kelvin Wong
 * @description show progress bar of Expense Detail
 */
public class TEExpenseDetailProgressBarCtrl {
    
    /**
     * @description status label to show
     */
    public Expense_Detail__c MyRequest {get; set;}
    /**
     * @description step number of the current progress
     */
    public Integer Step {get; set;}

    /**
     * @description constructor with StandardController
     * @param stdController controller of Expense Detail(s)
     */
    public TEExpenseDetailProgressBarCtrl(ApexPages.StandardController stdController) {
        this.MyRequest = (Expense_Detail__c) stdController.getRecord();
        this.MyRequest = [select Id, toLabel(Status__c),
                          Amount__c, Amount_Adjustment__c, Receipt_Currency__c, Receipt_Currency__r.Name
                          from Expense_Detail__c where Id =: MyRequest.Id];
        Expense_Detail__c MyRequest2 = [select Status__c from Expense_Detail__c where Id =: MyRequest.Id];
        Step = TEConstant.getExpenseStep(MyRequest2.Status__c);
    }

}