/**
 * TEExpenseDetailRemoteActionsUtils
 * @description remote action utility for expense detail
 */

global without sharing class TEExpenseDetailRemoteActionsUtils {
    /**
	* @description constructor with StandardController
	*/
    global TEExpenseDetailRemoteActionsUtils (ApexPages.StandardController ctrl) {
        
    }
    /**
    * @description recall button in approval process
    */    
    @RemoteAction
    public static String recallApprovalProcess(String recordId) {
        
        List<ProcessInstance> procIns = new List<ProcessInstance>(
            [SELECT Id FROM ProcessInstance WHERE Status = 'Pending' and TargetObjectId = :recordId]);
        
        if(procIns != null && !procIns.isEmpty()) {
            List<ProcessInstanceWorkitem>  workItem = new List<ProcessInstanceWorkitem>(
                [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :procIns[0].id]);
            
            if(workItem != null && !workItem.isEmpty()) {
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction('Removed');
                pwr.setWorkitemId(workItem[0].Id);
                Approval.ProcessResult result =  Approval.process(pwr);
            } else {
                throw new TalException(Label.TE_Expense_Detail_Unable_To_Recall);
            }
            
        } else {
            throw new TalException(Label.TE_Expense_Detail_Unable_To_Recall);
        }
        
        return recordId;
    }
}