/**
 * TEExpenseAppRemoteActionsUtils
 * @description Recall approval process of Expense Detail(s)
 */

global without sharing class TEExpenseAppRemoteActionsUtils {
    
    /**
    * @description constructor with StandardController
    * @param ctrl Controller of Expense Detail(s)
    */    
    global TEExpenseAppRemoteActionsUtils (ApexPages.StandardController ctrl) {
        
    }
    
    /**
    * @description Recall approval process given the Expense Detail record ID
    * @param recordId ID to recall approval process
    * @return the record ID that has been recalled
    */
    @RemoteAction
    public static String recallApprovalProcess(String recordId) {
       
        Expense_Application__c ea = null;
        
        for ( Expense_Application__c reader : [select id, status__c from Expense_Application__c where id = :recordId ]){
            ea = reader;
        }
        
        List<ProcessInstance> procIns = new List<ProcessInstance>(
            [SELECT Id FROM ProcessInstance WHERE Status = 'Pending' and TargetObjectId = :recordId]);
        
        if( (procIns != null && !procIns.isEmpty() ) && ( ea.status__c == TEConstant.STATUS_PENDING_APPROVAL || ea.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation || ea.status__c == TEConstant.STATUS_PENDING_site_approval || ea.status__c == TEConstant.STATUS_PENDING_hcm_approval )  ) {
            List<ProcessInstanceWorkitem>  workItem = new List<ProcessInstanceWorkitem>(
                [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :procIns[0].id]);
            
            if(workItem != null && !workItem.isEmpty()) {
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction('Removed');
                pwr.setWorkitemId(workItem[0].Id);
                Approval.ProcessResult result =  Approval.process(pwr);
            } else {
                throw new TalException(Label.TE_Expense_Application_Unable_To_Recall);
            }
            
        } else {
            throw new TalException(Label.TE_Expense_Application_Unable_To_Recall);
        }
        
        return recordId;
    }
}