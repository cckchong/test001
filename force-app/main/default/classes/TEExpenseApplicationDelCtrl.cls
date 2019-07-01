/**
 * TEExpenseApplicationDelCtrl
 * @description Applicant to Delete Expense Application(s)
 * @author kong
 */
public without sharing class TEExpenseApplicationDelCtrl{
    private Expense_Application__c ea {get; set;}
    
    /**
     * @description constructor with StandardController
     */
    public TEExpenseApplicationDelCtrl (ApexPages.StandardController controller){
        this.ea=(Expense_Application__c)controller.getRecord();
        for(Expense_Application__c reader : [select id, status__c from Expense_Application__c where id = :this.ea.id ]){
            this.ea = reader;
        }
        
    }
    
    public PageReference action() {
        String path = '';
        if (this.ea.status__c != null && this.ea.status__c != TEConstant.STATUS_DRAFT){
            path = 'javascript: alert(\''+ Label.TE_General_Del_Error +'\');window.history.back();';             
        }
        else{
            if (this.ea.status__c == null){
                for (Expense_Detail__c ed : [Select Id, Status__c From Expense_Detail__c Where Expense_Application__c = :this.ea.id]){
                    if (ed.Status__c != TEConstant.STATUS_DRAFT){
                        path = 'javascript: alert(\''+ Label.TE_General_Del_Error +'\');window.history.back();';  
                        return new PageReference(path); 
                    }
                }
            }
            delete ea;
            path = '/'+Expense_Application__c.sObjectType.getDescribe().getKeyPrefix();
        }
        return new PageReference(path);        
    }
    
}