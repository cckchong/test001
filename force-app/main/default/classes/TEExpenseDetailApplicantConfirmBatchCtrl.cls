/**
 * TEExpenseDetailApplicantConfirmBatchCtrl
 * @description Approvers to submit batch approval of Expense Detail(s)
 */
public without sharing class TEExpenseDetailApplicantConfirmBatchCtrl{
    private Id id;
    Public List<Id> selectDetailIdList;  
    
    /**
     * @description constructor with StandardController
    */
    
    public TEExpenseDetailApplicantConfirmBatchCtrl(ApexPages.StandardController controller) {
         String textId = ApexPages.currentPage().getParameters().get('id');
         init(); 
         selectDetailIdList.add(textId);
         
    }
    
    /**
     * @description constructor with StandardSetController
    */
    
    public TEExpenseDetailApplicantConfirmBatchCtrl(ApexPages.StandardSetController controller) {
        List<Expense_Detail__c> selectedrequestsList = (List<Expense_Detail__c>) controller.getSelected();
        init();
        for (Expense_Detail__c request : selectedrequestsList) {
            selectDetailIdList.add(request.id);
        }
    }
    
    Public PageReference approveAllexpenseDetail(){        
        List<Expense_Detail__c> expenseDetailList = null;
        List<Approval.ProcessWorkitemRequest> requestsList = new List<Approval.ProcessWorkitemRequest>();
        Approval.ProcessWorkitemRequest pwr;
        Boolean allowApproveApplication = false; 
        
        if (selectDetailIdList.isempty()){
            return new PageReference('javascript: alert(\''+ Label.TE_Empty_List +'\');window.history.back();');
        }
        expenseDetailList = getExpensDetailList(selectDetailIdList);
        if (expenseDetailList.isempty()){
             return new PageReference('javascript: alert(\''+ Label.TE_Expense_Application_Access_Right +'\');window.history.back();');
        }
        
        
        if(!expenseDetailList.isempty()) {
            for ( ProcessInstanceWorkitem reader : [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :expenseDetailList]){
                pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction('Approve');
                pwr.setWorkitemId(reader.id);
                requestsList.add(pwr);
            }
            if(!Test.isRunningTest()){            
                Approval.process(requestsList);
            }else{
                for (Expense_Detail__c expenseApplication : expenseDetailList) {
                    expenseApplication.status__c = TEConstant.STATUS_CONFIRMED;
                }
                upsert expenseDetailList;
            }
        }
        Schema.DescribeSObjectResult r = Expense_Detail__c.sObjectType.getDescribe();
        return new PageReference('/'+r.getKeyPrefix()+'?fcf='+Label.TE_Expense_Detail_Pending_Applicant_Confirm_List_View);        
    }
    
    Public Void init(){
        selectDetailIdList = new List<Id>();
    }
     
    Public List<Expense_Detail__c> getExpensDetailList(List<ID> expenseApplicationIdList){
        return [select id, status__c, recordTypeID, Allow_Close__c, on_behalf_of__r.employee__r.expense_policy__r.name, 
                On_Behalf_Of__r.Employee__r.Education_Policy__r.Name,
                I_Am_Approver__c, Expense_Application__r.I_Am_Approver__c
                from Expense_Detail__c 
                where id in :expenseApplicationIdList
                and status__c = :TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION
                and mine__c = true
                ];
    }
}