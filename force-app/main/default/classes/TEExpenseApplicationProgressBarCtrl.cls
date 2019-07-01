/**
 * TEExpenseApplicationProgressBarCtrl
 * @description show progress bar of Expense Application
 */
public class TEExpenseApplicationProgressBarCtrl {
    
    /**
     * @description status label to show
     */
    public Expense_Application__c MyRequest {get; set;}
    
    /**
     * @description step number of the current progress
     */
    public Integer Step {get; set;}
    
    public Integer numOfAttachment {get; set;}

    /**
     * @description constructor with StandardController
     */
    public TEExpenseApplicationProgressBarCtrl(ApexPages.StandardController stdController) {
        this.numOfAttachment = 0;
        this.MyRequest = (Expense_Application__c) stdController.getRecord();
        this.MyRequest = [select Id, toLabel(Status__c), Currency__c,
                          (select id from expense_details__r where (status__c != 'DF' and status__c != 'NS')),
                          Amount_Applied_display__c, Amount_Approved_Display__c, Actual_Total_Amount_Display__c, Reimbursement_Amount_Display__c
                          from Expense_Application__c where Id =: MyRequest.Id];
        Expense_Application__c MyRequest2 = [select Status__c from Expense_Application__c where Id =: MyRequest.Id];
        Step = TEConstant.getExpenseStep(MyRequest2.Status__c);
        //if ( this.MyRequest.expense_details__r != null && !this.MyRequest.expense_details__r.isEmpty()){
            this.numOfAttachment = 0;
            for(AggregateResult ar :[select count(id) id  from attachment where ParentId = :MyRequest.Id group by ParentId]){
                this.numOfAttachment += Integer.valueOf(ar.get('id'));            
            }
            
            for(AggregateResult ar :[select count(id) id from Expense_Application__Feed where type = 'ContentPost' and  ParentId = :MyRequest.Id ]){
                this.numOfAttachment += Integer.valueOf(ar.get('id'));
            }
        //}
    }
}