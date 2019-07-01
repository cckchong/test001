/**
 * TEExpenseDetailClosedCtrl
 * @description FIN to close Expense Detail(s)
 */
public without sharing class TEExpenseApplicationClosedCtrl  {
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
    
    public TEExpenseApplicationClosedCtrl (ApexPages.StandardController controller) {
         String textId = ApexPages.currentPage().getParameters().get('id');
         init(); 
         selectApplicationIdList.add(textId);
         
    }
    
    /**
     * @description constructor with StandardSetController
    */
    
    public TEExpenseApplicationClosedCtrl (ApexPages.StandardSetController controller) {
        List<Expense_Application__c> selectedRequests = (List<Expense_Application__c>) controller.getSelected();
        init();
        for (Expense_Application__c request : selectedRequests) {
            selectApplicationIdList.add(request.id);
        }
    }
    
    Public PageReference closeAllexpenseApplication(){
        List<Expense_Application__c> ExpensApplicationList = getExpensApplicationList(this.selectApplicationIdList);
        List<Id> generalExpenseApplicationIdList = new List<Id >();
        List<Expense_Detail__c> ExpensDetailList = new List<Expense_Detail__c >();
        List<Expense_Application__c > toBeClosedExpenseApplicationList = new List<Expense_Application__c >();
        List<Expense_Detail__c > toBeClosedExpenseDetailList = new List<Expense_Detail__c >();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest psr;
        String groupName = '';
        Boolean allowCloseApplication = false;
        
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
            allowCloseApplication = true;
        }
        if (!allowCloseApplication){
             return new PageReference('javascript: alert(\''+ Label.TE_Expense_Application_Access_Right +'\');window.history.back();');
        }
        
        for(Expense_Application__c reader : ExpensApplicationList){
            if(reader.status__c == null){
                generalExpenseApplicationIdList.add(reader.Id);        
            }
            else {          
                if (reader.Allow_Close__c){
                    reader.status__c = TEConstant.STATUS_CLOSED_NOT_SUBMITTED;
                    toBeClosedExpenseApplicationList.add(reader);
                }
            }

        }
        
        if(!generalExpenseApplicationIdList.isempty()){
            ExpensDetailList = getExpensDetailList(generalExpenseApplicationIdList);
            for(Expense_Detail__c reader : ExpensDetailList) {
                if (reader.Allow_Close__c){
                    reader.status__c = TEConstant.STATUS_CLOSED_NOT_SUBMITTED;
                    toBeClosedExpenseDetailList.add(reader);
                }
            }
        }
        
        if (!toBeClosedExpenseApplicationList.isempty()){
            update toBeClosedExpenseApplicationList;
            for(Expense_Application__c reader : toBeClosedExpenseApplicationList){
                psr = new Approval.ProcessSubmitRequest();
                psr.setObjectId(reader.id);
                requests.add(psr);
            }
            if(!Test.isRunningTest()){            
                Approval.process(requests);
            }else{
                for (Expense_Application__c expenseApplication : toBeClosedExpenseApplicationList) {
                    expenseApplication.status__c = TEConstant.STATUS_CLOSED;
                }
                upsert toBeClosedExpenseApplicationList;
            }
        }
        
        requests = new List<Approval.ProcessSubmitRequest>();

        if (!toBeClosedExpenseDetailList.isempty()){
            update toBeClosedExpenseDetailList;
            for(Expense_Detail__c reader : toBeClosedExpenseDetailList){
                psr = new Approval.ProcessSubmitRequest();
                psr.setObjectId(reader.id);
                requests.add(psr);
            }
            
            if(!Test.isRunningTest()){            
                Approval.process(requests);
            }else{
                for (Expense_Detail__c expenseDetail : toBeClosedExpenseDetailList) {
                    expenseDetail.status__c = TEConstant.STATUS_CLOSED;
                }
                upsert toBeClosedExpenseDetailList;
            }
        }
       
        
        Schema.DescribeSObjectResult r = Expense_Application__c.sObjectType.getDescribe();
        return new PageReference('/'+r.getKeyPrefix()+'?fcf='+Label.TE_Pending_Closed_Expense_Application_List_View);
    }
    
    
    Public Void init(){
        expenseApplicationList = new List<Expense_Application__c>();
        selectApplicationIdList = new List<Id>();
    }
    
    Public List<Expense_Application__c> getExpensApplicationList(List<ID> expenseApplicationIdList){
        return [select id, status__c, recordTypeID, Allow_Close__c, on_behalf_of__r.employee__r.expense_policy__r.name
                from Expense_Application__c 
                where id in :expenseApplicationIdList];
    }
    
    Public List<Expense_Detail__c> getExpensDetailList(List<ID> expenseApplicationIdList){
        return [select id, status__c, recordTypeID, Allow_Close__c, on_behalf_of__r.employee__r.expense_policy__r.name
                from Expense_Detail__c 
                where Expense_Application__c in :expenseApplicationIdList];
    }
}