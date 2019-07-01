/**
 * TEExpenseApplicationTriggerHandler
 * @description Expense Application Trigger Handler
 */
 
public without sharing class TEExpenseApplicationTriggerHandler {
    
    
    /**
     * @description update Tech Expense Application in Travel Application
     */
    public static void updateTechExpenseApp(List<Expense_Application__c> newExpenseApplicationList, Map<Id, Expense_Application__c> oldExpenseApplicationMap) {
        
        List<Id> travelApplicationIdAddList = new List<Id>(), travelApplicationIdRemoveList = new List<Id>();
        List<Travel_Application__c> travelApplicationList = new List<Travel_Application__c>();
        

        for (Expense_Application__c expApp : newExpenseApplicationList) {
            if (expApp.Travel_Application__c != null && 
               (expApp.status__c != oldExpenseApplicationMap.get(expApp.id).status__c) && 
               (expApp.Status__c == TEConstant.STATUS_DRAFT || expApp.Status__c == TEConstant.STATUS_NOT_SUBMITTED || expApp.Status__c == TEConstant.STATUS_CANCELLED || expApp.Status__c == TEConstant.STATUS_REJECT)) {
                   travelApplicationList.add(new Travel_Application__c(id=expApp.Travel_Application__c, Tech_Is_Expense_Application__c = FALSE));
            }
            if (expApp.Travel_Application__c != null && 
               (expApp.status__c != oldExpenseApplicationMap.get(expApp.id).status__c) && 
               (expApp.Status__c == TEConstant.STATUS_PENDING_APPROVAL)) {
                   travelApplicationList.add(new Travel_Application__c(id=expApp.Travel_Application__c, Tech_Is_Expense_Application__c = TRUE));
            }
            
        }
        if (!travelApplicationList.isEmpty()){
            update travelApplicationList;
        }
        
    }

    /**
     * @description Expense Type synchronizes with Record Type and Expense Type
    */
    
    public static void synupRecordTypeWithExpenseType(List<Expense_Application__c > newExpenseApplicationList, Map<ID,Expense_Application__c > oldExpenseApplicationMap ) {
        
        List <String> recordTypeList = new List <String>();
        Map <String, String> recordTypeExpenseTypeMap = new Map <String, String> ();
        Map <String, Expense_Type__c> expenseTypeRecordTypeMap = new Map <String, Expense_Type__c> ();
        
        for (Expense_Application__c reader : newExpenseApplicationList ){
            if (oldExpenseApplicationMap == null ){
                recordTypeExpenseTypeMap.put(reader.RecordTypeId, '');
            }
            else{
                if ((reader.RecordTypeId != oldExpenseApplicationMap.get(reader.id).RecordTypeId) || (reader.Status__c == TEConstant.STATUS_DRAFT || reader.Status__c == TEConstant.STATUS_NOT_SUBMITTED)){
                    recordTypeExpenseTypeMap.put(reader.RecordTypeId, '');
                }
            }    
        }
        
        List <ID> EmployeeAdministratorIDList = new List <ID>();
        Map <ID, ID> employeeExpPolicyMap = new Map <ID, ID>();
        if (!recordTypeExpenseTypeMap.keyset().isempty()){
            for (Expense_Application__c reader : newExpenseApplicationList ){
                EmployeeAdministratorIDList.add(reader.on_behalf_of__c);
            }
            for (Employee_Administrator__c reader: [select id, Employee__r.Expense_Policy__c from Employee_Administrator__c  where id in :EmployeeAdministratorIDList]){
                employeeExpPolicyMap.put(reader.id, reader.Employee__r.Expense_Policy__c);
            }
            
            for (RecordType reader : [select id, Developername from RecordType where id in :recordTypeExpenseTypeMap.keyset()]){
                recordTypeExpenseTypeMap.put(reader.id, reader.Developername );
            }
            for (Expense_Type__c reader : [select id, Expense_Claims__c, Expense_Policy__c   from Expense_Type__c where type__c = 'H' and Expense_Policy__c = :employeeExpPolicyMap.values()]){
                expenseTypeRecordTypeMap.put (reader.Expense_Policy__c+reader.Expense_Claims__c, reader); 
            }
            for (Expense_Application__c reader : newExpenseApplicationList ){
                if ( expenseTypeRecordTypeMap.containskey(employeeExpPolicyMap.get(reader.on_behalf_of__c)+recordTypeExpenseTypeMap.get(reader.RecordTypeId)) ){
                    reader.Expense_Type__c = expenseTypeRecordTypeMap.get(employeeExpPolicyMap.get(reader.on_behalf_of__c)+recordTypeExpenseTypeMap.get(reader.RecordTypeId)).Id;
                    reader.Tech_Expense_Claims__c = expenseTypeRecordTypeMap.get(employeeExpPolicyMap.get(reader.on_behalf_of__c)+recordTypeExpenseTypeMap.get(reader.RecordTypeId)).Expense_Claims__c;

                }
            }
        }
    }
    
    
    /**
    * @description sync up Expense Application Status with Expense Detail Status
    */        
    public static void synupApplicationStatusWithDetailStatus(Map<ID, Expense_Application__c > newExpenseApplicationMap, Map<ID,Expense_Application__c > oldExpenseApplicationMap ) {
        
        List <Expense_Detail__c> expenseDetailList = new List <Expense_Detail__c>();
        Map <ID, String> expenseApplicationStatusMap = new Map <ID, String>();
        for (Expense_Application__c reader : newExpenseApplicationMap.values()){
            if ( reader.status__c != oldExpenseApplicationMap.get(reader.id).status__c ){
                expenseApplicationStatusMap.put(reader.id, reader.status__c);
            }
        }
        if (!expenseApplicationStatusMap.values().isEmpty()){
            for (Expense_Detail__c reader : [select id, Expense_Application__c, status__c from Expense_Detail__c where Expense_Application__c in :expenseApplicationStatusMap.keySet()]){
                reader.status__c = expenseApplicationStatusMap.get(reader.Expense_Application__c);
                expenseDetailList.add(reader);
            }
        }
        if ( !expenseDetailList.isempty()){
            update expenseDetailList;
        }
    }
    /**
    * @description Close related Cash Advance when Expense Application status is Closed
    */           
    public static void closeRelatedCashAdvance(Map <Id, Expense_Application__c> newExpenseApplicationMap, Map <Id, Expense_Application__c> oldExpenseApplicationMap) {
        Set<Id> setTravelApplicationId = new Set<Id> ();
        Set<Id> setClosedExpenseApplicationId = new Set<Id> ();
        List<Cash_Advance__c> relatedCashAdvanceList = new List<Cash_Advance__c> ();
        for (Expense_Application__c expenseApplication : newExpenseApplicationMap.values()) {
            if (expenseApplication.Travel_Application__c != null) {
                if(expenseApplication.Status__c == TEConstant.STATUS_CLOSED) {
                   setTravelApplicationId.add(expenseApplication.Travel_Application__c);                
                }
            }
        }
        if(!setTravelApplicationId.isEmpty()) {
            for (Cash_Advance__c cashAdvance : [ select id, Travel_Application__c, Status__c from Cash_Advance__c where Travel_Application__c in :setTravelApplicationId ]) {
                if (cashAdvance.Status__c == TEConstant.STATUS_PAID_OUT) {
                    cashAdvance.Status__c = TEConstant.STATUS_CLOSED;
                    relatedCashAdvanceList.add(cashAdvance);
                }              
            }
            update relatedCashAdvanceList;           
        }
    }
    

    Public Static Void initFieldValuesForBatch(List<Expense_Application__c> newExpenseApplicationList, Map <Id, Expense_Application__c> oldExpenseApplicationMap, String type){
        List <ID> onBehalfOfIdList = new List <ID>();
        Map <Id, employee_Administrator__C> employeeAdministratorMap = null;
        if(type == 'I'){
            for(Expense_Application__c reader : newExpenseApplicationList){
                if (reader.status__c == null ){
                    onBehalfOfIdList.add(reader.on_behalf_of__c);
                }    
            }
        }
        
        if(type == 'U'){
            for(Expense_Application__c reader : newExpenseApplicationList){
                if (reader.status__c == null && (reader.on_behalf_of__c != oldExpenseApplicationMap.get(reader.id).on_behalf_of__c)){
                    onBehalfOfIdList.add(reader.on_behalf_of__c);
                }    
            }
        }
        
        if(!onBehalfOfIdList.isEmpty()){
            employeeAdministratorMap = new Map <Id, employee_Administrator__C>([select id, employee__r.expense_policy__c, employee__r.expense_policy__r.name
                                                    from employee_Administrator__C  where id in :onBehalfOfIdList]);
             for(Expense_Application__c reader : newExpenseApplicationList){
                 reader.Tech_Expense_Policy__c = employeeAdministratorMap.get(reader.on_behalf_of__c).employee__r.expense_policy__r.name;
             }
        }
    }
 
    /**
    * @description Initialize the field values when expense application's status is Pending Approval
    */        
    public static void initFieldValues(Map <Id, Expense_Application__c> newExpenseApplicationMap, Map <Id, Expense_Application__c> oldExpenseApplicationMap){
    
        Map <Id, Expense_Application__c > employeeAdministratorMap = new Map <Id, Expense_Application__c >();        
        List <ID> expenseApplicationIdList = new List <ID>();
        List <Expense_Application__c> expenseApplicationList = new List <Expense_Application__c>();
        
        for (Expense_Application__c reader : newExpenseApplicationMap.values() ){
            if (reader.status__c == TEConstant.STATUS_NOT_SUBMITTED || reader.status__c == TEConstant.STATUS_DRAFT){
                reader.Actual_Approver_1__c = NULL;
                reader.Actual_Approver_2__c = NULL;
                reader.Actual_Approver_3__c = NULL;
                reader.Actual_Approver_4__c = NULL;
                reader.Tech_Expense_Policy__c = '';
                reader.Tech_Applicant__c = NULL;
                reader.Tech_Expense_Policy_Finance_Email__c = '';
                reader.Tech_Applicant_Email__c = '';
                reader.Tech_On_Behalf_of_Email__c = '';
                reader.Tech_Approver_1_Email__c = '';
                reader.Tech_Approver_2_Email__c = '';
                reader.Tech_Approver_3_Email__c = '';
                reader.Tech_Approver_4_Email__c = '';
            }
            if ( reader.status__c != oldExpenseApplicationMap.get(reader.id).status__c && (reader.status__c == TEConstant.STATUS_PENDING_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation)
                && (reader.Actual_Approver_1__c == NULL && reader.Actual_Approver_2__c == NULL && reader.Actual_Approver_3__c == NULL && reader.Actual_Approver_4__c == NULL && reader.Tech_Expense_Policy__c == NULL)
               ){
                expenseApplicationIdList.add(reader.id);
                expenseApplicationList.add(reader);
            }
        }
        
        if (!expenseApplicationIdList.isEmpty()){
            for (Expense_Application__c reader : [
                select id, status__c,
                On_Behalf_Of__r.Employee__r.Approver_1__c, On_Behalf_Of__r.Employee__r.Approver_2__c,
                On_Behalf_Of__r.Employee__r.Approver_3__c, On_Behalf_Of__r.Employee__r.Approver_4__c,
                On_Behalf_Of__r.Employee__r.Acting_Approver_1__c, On_Behalf_Of__r.Employee__r.Acting_Approver_2__c,
                On_Behalf_Of__r.Employee__r.Acting_Approver_3__c, On_Behalf_Of__r.Employee__r.Acting_Approver_4__c,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Name,
                On_Behalf_Of__r.Employee_Administrator__r.User__c,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Finance_Email__c,
                On_Behalf_Of__r.Employee_Administrator__r.User__r.Email,
                On_Behalf_Of__r.Employee__r.User__r.Email
                from Expense_Application__c where id in :expenseApplicationIdList]){
                    employeeAdministratorMap.put(reader.id, reader);                
            }
        }
        
        for (Expense_Application__c reader : expenseApplicationList){
            //if ( reader.status__c != oldExpenseApplicationMap.get(reader.id).status__c && reader.status__c == TEConstant.STATUS_PENDING_APPROVAL){
                reader.Actual_Approver_1__c = (employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_1__c == null)? employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Approver_1__c : employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_1__c ;
                reader.Actual_Approver_2__c = (employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_2__c == null)? employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Approver_2__c : employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_2__c ;
                reader.Actual_Approver_3__c = (employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_3__c == null)? employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Approver_3__c : employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_3__c ;
                reader.Actual_Approver_4__c = (employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_4__c == null)? employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Approver_4__c : employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_4__c ;
                reader.Tech_Expense_Policy__c = employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Expense_Policy__r.Name;
                reader.Tech_Applicant__c = employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee_Administrator__r.User__c;
                reader.Tech_Expense_Policy_Finance_Email__c = employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Expense_Policy__r.Finance_Email__c;
                reader.Tech_Applicant_Email__c = employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee_Administrator__r.User__r.Email ;
                reader.Tech_On_Behalf_of_Email__c = employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.User__r.Email ;
            //}
        }
        if (!expenseApplicationList.isEmpty()){
            TEManualSharingCtrl.TEExpenseApplicationSharing(expenseApplicationList, true);
        }
        
    }
    
    
}