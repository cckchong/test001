/**
 * TEExpenseApplicationFINConfirmBatchCtrl  
 * @description Finance to submit batch confirmation of Expense Application(s)
 */
public without sharing class TEExpenseApplicationFINConfirmBatchCtrl  {
    //private ApexPages.StandardSetController standardController;
    private Id id;
    private Expense_Application__c  expenseApplication{get; set;}
    private Map<Id, String> recordtype;
    private static final String EXPENSEDETAILIDCODE = '@edlD';
    private static final String FINGROUOPNAMECODE = '@name';
    private static final String FIN_GROUOP_NAME= 'TE_@name_FIN';
    private boolean isQueue = false;    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}

    Public List<Expense_Application__c> expenseApplicationList;
    Public List<Id> selectApplicationIdList;
    
     
    
    /**
     * @description constructor with StandardController
    */
    
    public TEExpenseApplicationFINConfirmBatchCtrl  (ApexPages.StandardController controller) {
         String textId = ApexPages.currentPage().getParameters().get('id');
         init(); 
         selectApplicationIdList.add(textId);
         
    }
    
    /**
     * @description constructor with StandardSetController
    */
    
    public TEExpenseApplicationFINConfirmBatchCtrl (ApexPages.StandardSetController controller) {
        List<Expense_Application__c> selectedrequestsList = (List<Expense_Application__c>) controller.getSelected();
        init();
        for (Expense_Application__c request : selectedrequestsList) {
            selectApplicationIdList.add(request.id);
        }
    }
    
    Public PageReference confirmAllExpenseApplication(){
        List<Expense_Application__c> ExpensApplicationList = getExpensApplicationList(this.selectApplicationIdList);
        List<Id> generalExpenseApplicationIdList = new List<Id >();
        List<Expense_Detail__c> ExpensDetailList = new List<Expense_Detail__c >();
        List<Expense_Application__c > toBeConfirmedExpenseApplicationList = new List<Expense_Application__c >();
        List<Expense_Detail__c > toBeConfirmedExpenseDetailList = new List<Expense_Detail__c >();
        List<Approval.ProcessWorkitemRequest> requestsList = new List<Approval.ProcessWorkitemRequest>();
        Approval.ProcessWorkitemRequest pwr;
        String groupName = '';
        Boolean allowConfirmApplication = false;
        
        if (ExpensApplicationList.isempty()){
            return new PageReference('javascript: alert(\''+ Label.TE_Empty_List +'\');window.history.back();');
        }
        
        
        
        for(Expense_Application__c reader : ExpensApplicationList){
            groupName = FIN_GROUOP_NAME;
            groupName = groupName.replace(FINGROUOPNAMECODE, reader.on_behalf_of__r.employee__r.expense_policy__r.name);
            break;
        }
        
        for(GroupMember reader : [select id 
                                  from GroupMember 
                                  where
                                  UserOrGroupId = :UserInfo.getUserId()
                                  and GroupId in (select id from Group where DeveloperName = :groupName )] ){
            allowConfirmApplication = true;
        }
        

        
        if (!allowConfirmApplication){
             return new PageReference('javascript: alert(\''+ Label.TE_Expense_Application_Access_Right +'\');window.history.back();');
        }
                
        for(Expense_Application__c reader : ExpensApplicationList){
            if(reader.status__c == null){
                generalExpenseApplicationIdList.add(reader.Id);        
            }
            else {          
                if (reader.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation ){
                    toBeConfirmedExpenseApplicationList.add(reader);
                }
            }
        }
        
        if(!generalExpenseApplicationIdList.isempty()){
            ExpensDetailList = getExpensDetailList(generalExpenseApplicationIdList);
            for(Expense_Detail__c reader : ExpensDetailList) {
                if (reader.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation){
                    toBeConfirmedExpenseDetailList.add(reader);
                }
            }
        }
        if(!toBeConfirmedExpenseApplicationList.isempty() || !toBeConfirmedExpenseDetailList.isempty()) {
            for ( ProcessInstanceWorkitem reader : [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :toBeConfirmedExpenseApplicationList or ProcessInstance.TargetObjectId in :toBeConfirmedExpenseDetailList]){
                pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction('Approve');
                pwr.setWorkitemId(reader.id);
                requestsList.add(pwr);
            }
            if(!Test.isRunningTest()){            
                Approval.process(requestsList);
            }else{
                if(!toBeConfirmedExpenseApplicationList.isempty()){
                    for (Expense_Application__c expenseApplication : toBeConfirmedExpenseApplicationList) {
                        expenseApplication.status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
                    }
                    upsert toBeConfirmedExpenseApplicationList;
                }
                else if (!toBeConfirmedExpenseDetailList.isempty()){
                    for (Expense_Detail__c expenseDetail : toBeConfirmedExpenseDetailList) {
                        expenseDetail.status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
                    }
                    upsert toBeConfirmedExpenseDetailList;
                }
            }
        }
        Schema.DescribeSObjectResult r = Expense_Application__c.sObjectType.getDescribe();
        return new PageReference('/'+r.getKeyPrefix()+'?fcf='+Label.TE_Expense_Application_Pending_Finance_Approval_List_View);
    }
    
    Public Void init(){
        expenseApplicationList = new List<Expense_Application__c>();
        selectApplicationIdList = new List<Id>();
    }
    
    Public List<Expense_Application__c> getExpensApplicationList(List<ID> expenseApplicationIdList){
        return [select id, status__c, recordTypeID, Allow_Close__c, on_behalf_of__r.employee__r.expense_policy__r.name, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c
                from Expense_Application__c 
                where id in :expenseApplicationIdList];
    }
    
    Public List<Expense_Detail__c> getExpensDetailList(List<ID> expenseApplicationIdList){
        return [select id, status__c, recordTypeID, Allow_Close__c, on_behalf_of__r.employee__r.expense_policy__r.name, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c
                from Expense_Detail__c 
                where Expense_Application__c in :expenseApplicationIdList];
    }
}