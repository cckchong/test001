/**
 * TEExpenseDetailTriggerHandler
 * @author Kelvin Wong
 * @description to handle TE Expense Detail Trigger
 */
public without sharing class TEExpenseDetailTriggerHandler {

    public static Boolean isRun = false; 
    public Static Set<String> edlogSet = new Set<String>();
    /**
     * @description to check whether the input amount is larger than zero
     */
    public static void checkAmountPositive(List<Expense_Detail__c> newExpenseDetailList) {
        for (Expense_Detail__c expDetail : newExpenseDetailList) {
            if (expDetail.Amount__c <= 0) {
                expDetail.addError('Amount must be greater than zero.');
            }
        }
    }
    
    /**
     * @description update and calculate exchange rate, calculate with local currency and put into local amount field
     */
    public static void updateExchangeRate(Map<ID, Expense_Detail__c> newExpenseDetailMap, Map<ID, Expense_Detail__c> oldExpenseDetailMap ){
        
        Map <Id, Id> employeeLocalCurrencyMap = new Map <Id, Id>();
        Map <String, Exchange_Rate__c> exchangeRateMap = new Map <String, Exchange_Rate__c>();          
        List <Id> employeeAdministratorList = new List <Id> ();
        List <String> exchangeRateList = new List<String>();
        List <Expense_Detail__c> expenseDetailList = new List <Expense_Detail__c>(); 
        
        for (Expense_Detail__c newExpenseDetail : newExpenseDetailMap.values()){
            if ( (newExpenseDetail.status__c == TEConstant.STATUS_DRAFT || newExpenseDetail.status__c == TEConstant.STATUS_NOT_SUBMITTED ) ||
                 ( newExpenseDetail.status__c != oldExpenseDetailMap.get(newExpenseDetail.id).status__c && 
                   (newExpenseDetail.status__c == TEConstant.STATUS_PENDING_APPROVAL &&  (oldExpenseDetailMap.get(newExpenseDetail.id).status__c == TEConstant.STATUS_DRAFT  || oldExpenseDetailMap.get(newExpenseDetail.id).status__c == TEConstant.STATUS_NOT_SUBMITTED) ) ||
                   (newExpenseDetail.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL &&  (oldExpenseDetailMap.get(newExpenseDetail.id).status__c == TEConstant.STATUS_DRAFT  || oldExpenseDetailMap.get(newExpenseDetail.id).status__c == TEConstant.STATUS_NOT_SUBMITTED) ) ||
                   (newExpenseDetail.status__c == TEConstant.STATUS_PENDING_SITE_APPROVAL &&  (oldExpenseDetailMap.get(newExpenseDetail.id).status__c == TEConstant.STATUS_DRAFT  || oldExpenseDetailMap.get(newExpenseDetail.id).status__c == TEConstant.STATUS_NOT_SUBMITTED) )
                )
               ){
                employeeAdministratorList.add(newExpenseDetail.On_Behalf_Of__c);
                expenseDetailList.add(newExpenseDetail);
            }
        }
        if (!employeeAdministratorList.isEmpty()){
            for (Employee_Administrator__c reader : [select id, employee__r.expense_policy__r.local_currency__c from Employee_Administrator__c where id in :employeeAdministratorList]){
                employeeLocalCurrencyMap.put(reader.id, reader.employee__r.expense_policy__r.local_currency__c );
            }
            for ( Expense_Detail__c reader : newExpenseDetailMap.values() ){
                System.debug('test1: ' + reader.Receipt_Currency__c);
                System.debug('test2: ' + reader.On_Behalf_Of__c);
                System.debug('test3: ' + employeeLocalCurrencyMap);
                exchangeRateList.add(String.Valueof(reader.Receipt_Currency__c).left(15) + String.Valueof(employeeLocalCurrencyMap.get(reader.On_Behalf_Of__c)).left(15) );
            }
            
            for (Exchange_Rate__c reader : [select id, Rate__c, From_Currency__c, To_Currency__c from Exchange_Rate__c where Is_Latest__c = true and Is_Book_Rate__c = true and Tech_From_To_Currency_ID__c in :exchangeRateList]){
                exchangeRateMap.put(String.ValueOf(reader.From_Currency__c)+String.ValueOf(reader.To_Currency__c), reader);
            }
        }
        for (Expense_Detail__c newExpenseDetail : expenseDetailList){
           if ( exchangeRateMap.containskey(String.ValueOf(newExpenseDetail.Receipt_Currency__c)+String.ValueOf(employeeLocalCurrencyMap.get(newExpenseDetail.On_Behalf_Of__c))) ){
               newExpenseDetail.Exchange_Request__c = exchangeRateMap.get(String.ValueOf(newExpenseDetail.Receipt_Currency__c)+String.ValueOf(employeeLocalCurrencyMap.get(newExpenseDetail.On_Behalf_Of__c))).id;
               newExpenseDetail.Tech_Exchange_Rate__c = exchangeRateMap.get(String.ValueOf(newExpenseDetail.Receipt_Currency__c)+String.ValueOf(employeeLocalCurrencyMap.get(newExpenseDetail.On_Behalf_Of__c))).Rate__c;
               newExpenseDetail.Tech_Exchange_Date__c = System.Today();
               newExpenseDetail.local_Amount__c = newExpenseDetail.Tech_Exchange_Rate__c * newExpenseDetail.Amount__c;
           }
           else{
               newExpenseDetail.addError(Label.TE_Expense_Detail_Cannot_Find_Exchange_Rate);
           }
        }
    }

    /**
     * @description to intialize specific fields values when expense detail's Status is Pending Approval
     */
    public static void initFieldValues(Map <Id, Expense_Detail__c> newExpenseDetailMap, Map <Id, Expense_Detail__c> oldExpenseDetailMap){
    
        Map <Id, Expense_Detail__c > employeeAdministratorMap = new Map <Id, Expense_Detail__c >();
        List <Expense_Detail__c> expenseDetailList = new List <Expense_Detail__c> ();
        List <Expense_Detail__c> approvedExpenseDetailList = new List <Expense_Detail__c> ();
        Map <String, ID> departmentBudgetCurrencyMap = new Map <String, ID>();
        Map <String, exchange_rate__c> exchangeRateMap = null;
        Map <String, exchange_rate__c> budgetExchangeRateMap = null;
        Map <Id, String> receiptCurrencyMap = null;
        Map <Id, Expense_type__c> expenseTypeMap = new Map <Id, Expense_type__c>();
        //Map <Id, String> applyDateMap = new Map <Id, String>();
        List <String> departmentList = null;
        List <String> expenseDetailCurrency = new List <String>();
        List <String> healthCurrencyList = new List <String>();
        List <Expense_Application__c> expenseApplicationSharingList = new List <Expense_Application__c>();
        //List <String> yearList = new List <String>();
        String key = '';
        String localCurrencyId = '';
        String budgetCurrencyId = '';
        //FinanceUtil fu = new FinanceUtil();
        
        for (Expense_Detail__c reader : newExpenseDetailMap.Values()){
            if (reader.status__c == TEConstant.STATUS_NOT_SUBMITTED && reader.status__c != oldExpenseDetailMap.get(reader.id).status__c){
                 reader.Tech_Budget_Exchange_Rate__c = 0;
                 reader.amount_adjustment__c = 0;
                 reader.Tech_Health_Exchange_Rate__c = 0;
                 reader.Tech_Site_Admin_Email__c = null;
                 reader.Allow_to_Exceed_Max_Cap__c = false;
                 reader.Applied_Amount_Chatter__c = '-';
                 reader.Approved_Amount_Chatter__c = '-';
            }
            if ((reader.status__c == TEConstant.STATUS_REJECT || reader.status__c == TEConstant.STATUS_CANCELLED) && reader.status__c != oldExpenseDetailMap.get(reader.id).status__c){
                 reader.Applied_Amount_Chatter__c = '-';
                 reader.Approved_Amount_Chatter__c = '-';
            }
        }
        for (Expense_Detail__c reader : newExpenseDetailMap.Values()){
            if ( (reader.status__c == TEConstant.STATUS_PENDING_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_SITE_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation)  && reader.status__c != oldExpenseDetailMap.get(reader.id).status__c 
                 && (oldExpenseDetailMap.get(reader.id).status__c == TEConstant.STATUS_DRAFT || oldExpenseDetailMap.get(reader.id).status__c == TEConstant.STATUS_NOT_SUBMITTED)
            ){
                expenseDetailList.add(reader);
                expenseDetailCurrency.add(reader.receipt_currency__c);
                reader.amount_adjustment__c = reader.amount__c;
            }
            
            if (((reader.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation || reader.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION)  && reader.status__c != oldExpenseDetailMap.get(reader.id).status__c)
                ||(reader.Amount_Adjustment__c != oldExpenseDetailMap.get(reader.id).Amount_Adjustment__c && reader.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation)){
                approvedExpenseDetailList.add(reader);
            }
        }
           
        if ( !expenseDetailList.isempty()){            
            departmentList = new List <String>();
            exchangeRateMap = new Map <String, exchange_rate__c> ();
            budgetExchangeRateMap = new Map <String, exchange_rate__c> ();
            for (Expense_Detail__c reader : [
                select id, status__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Approver_1__c, Expense_Application__r.On_Behalf_Of__r.Employee__r.Approver_2__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Approver_3__c, Expense_Application__r.On_Behalf_Of__r.Employee__r.Approver_4__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_1__c, Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_2__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_3__c, Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_4__c,
                Expense_Application__r.On_Behalf_Of__c,
                //Expense_Application__r.Education_Application__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Name,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.local_currency__c,
                Expense_Application__r.Copy_to_1__r.Email, Expense_Application__r.Copy_to_2__r.Email,
                Expense_Application__r.Copy_to_3__r.Email, Expense_Application__r.Copy_to_4__r.Email,
                Expense_Application__r.Copy_to_5__r.Email, Expense_Application__r.Copy_to_6__r.Email,
                Expense_Application__r.Copy_to_7__r.Email, Expense_Application__r.Copy_to_8__r.Email,
                Expense_Application__r.Copy_to_9__r.Email, Expense_Application__r.Copy_to_10__r.Email,
                Expense_Application__r.On_Behalf_Of__r.Employee_Administrator__r.User__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Finance_Email__c,
                Expense_Application__r.On_Behalf_Of__r.Employee_Administrator__r.User__r.Email,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.site__r.admin_email__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.User__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.User__r.Email,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.department__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense_currency__c,
                Expense_Type__r.Expense_Category__c, Expense_Type__r.Is_Health_Expense__c, Expense_Type__r.Is_Hotel_Expense__c, Expense_Type__r.Is_Meal_Expense__c,
                Receipt_Currency__r.Name, apply_date__c
                from Expense_Detail__c where id in :expenseDetailList ]){
                    employeeAdministratorMap.put(reader.id, reader);
                    departmentList.add(reader.Expense_Application__r.On_Behalf_Of__r.Employee__r.department__c);
                    healthCurrencyList.add(reader.Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense_currency__c);
                    localCurrencyId = reader.Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.local_currency__c;
                    //applyDateMap.put(reader.id, String.ValueOf(reader.apply_date__c.year()) + '-' +String.ValueOf(reader.apply_date__c.month()) + '-' +String.ValueOf(reader.apply_date__c.day()) );
                    //yearList.add(String.ValueOf(reader.apply_date__c.year()));
            }
            /*
            for (Budget__c reader : [select id, Department__c, Currency__c, Expense_Category__c, year__c  from Budget__c where Department__c in :departmentList and year__c = :yearList]){
                departmentBudgetCurrencyMap.put(reader.Department__c+String.Valueof(reader.Expense_Category__c).left(15), reader.currency__c);
            }
            */
            for (Exchange_Rate__c reader : [
                select id, rate__c, Is_Book_Rate__c,Is_Budget_Rate__c,
                from_currency__c, to_currency__c,
                Tech_From_To_Currency_ID__c
                from exchange_rate__c 
                where is_latest__c = true
                and (to_currency__c in :[select id from currency__c where Is_Budget_Currency__c = true] or to_currency__c in :healthCurrencyList)
            ]){
                if (reader.Is_Book_Rate__c){
                    exchangeRateMap.put (reader.Tech_From_To_Currency_ID__c, reader);
                }
                if (reader.Is_Budget_Rate__c){
                    budgetCurrencyId  = reader.to_currency__c;
                    budgetExchangeRateMap.put (reader.Tech_From_To_Currency_ID__c, reader);
                }
            }
             
            for (Expense_Detail__c reader : newExpenseDetailMap.values() ){
                if ( reader.status__c != oldExpenseDetailMap.get(reader.id).status__c && 
                    (oldExpenseDetailMap.get(reader.id).status__c ==  TEConstant.STATUS_DRAFT || oldExpenseDetailMap.get(reader.id).status__c == TEConstant.STATUS_NOT_SUBMITTED) &&
                    (reader.status__c == TEConstant.STATUS_PENDING_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_SITE_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation) ) {
                //if ( reader.status__c != oldExpenseDetailMap.get(reader.id).status__c && (reader.status__c == TEConstant.STATUS_PENDING_APPROVAL )){
                    if (reader.status__c == TEConstant.STATUS_PENDING_SITE_APPROVAL){
                        reader.Tech_Site_Admin_Email__c  = employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.site__r.admin_email__c ;
                    }
                    if ((oldExpenseDetailMap.get(reader.id).status__c ==  TEConstant.STATUS_DRAFT || oldExpenseDetailMap.get(reader.id).status__c == TEConstant.STATUS_NOT_SUBMITTED)){
                        reader.Tech_Approver_1_Email__c = null;
                        reader.Tech_Approver_2_Email__c = null;
                        reader.Tech_Approver_3_Email__c = null;
                        reader.Tech_Approver_4_Email__c = null;
                        //reader.Current_Approver__c = null;
                    }
                    reader.Allow_to_Exceed_Max_Cap__c = false;
                    reader.Actual_Approver_1__c = (employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_1__c == null)? employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Approver_1__c : employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_1__c ;
                    reader.Actual_Approver_2__c = (employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_2__c == null)? employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Approver_2__c : employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_2__c ;
                    reader.Actual_Approver_3__c = (employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_3__c == null)? employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Approver_3__c : employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_3__c ;
                    reader.Actual_Approver_4__c = (employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_4__c == null)? employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Approver_4__c : employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Acting_Approver_4__c ;
                    reader.On_Behalf_Of__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__c;
                    //reader.Education_Application__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.Education_Application__c;
                    reader.Tech_Expense_Policy__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Name;
                    reader.Tech_1st_Copy_to_User_Email__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_1__r.Email;
                    reader.Tech_2nd_Copy_to_User_Email__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_2__r.Email;
                    reader.Tech_3rd_Copy_to_User_Email__c= employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_3__r.Email;
                    reader.Tech_4th_Copy_to_User_Email__c= employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_4__r.Email;
                    reader.Tech_5th_Copy_to_User_Email__c= employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_5__r.Email;
                    reader.Tech_6th_Copy_to_User_Email__c= employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_6__r.Email;
                    reader.Tech_7th_Copy_to_User_Email__c= employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_7__r.Email;
                    reader.Tech_8th_Copy_to_User_Email__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_8__r.Email;
                    reader.Tech_9th_Copy_to_User_Email__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_9__r.Email;
                    reader.Tech_10th_Copy_to_User_Email__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.Copy_to_10__r.Email;
                    reader.Tech_Applicant__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee_Administrator__r.User__c;
                    reader.Tech_Expense_Policy_Finance_Email__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Finance_Email__c;
                    reader.Tech_Applicant_Email__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee_Administrator__r.User__r.Email ;
                    reader.Tech_On_Behalf_of_Email__c = employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.User__r.Email;
                    reader.Applied_Amount_Chatter__c = accountingFormatString(employeeAdministratorMap.get(reader.id).Receipt_Currency__r.Name, reader.Amount__c);
                    if(!String.isBlank(localCurrencyId) && !String.isBlank(budgetCurrencyId)){
                        key = String.valueof(localCurrencyId).left(15) + String.valueof(budgetCurrencyId).left(15);
                    }
                    if(budgetExchangeRateMap.containskey(key)){
                        reader.Tech_Budget_Exchange_Rate__c = budgetExchangeRateMap.get(key).rate__c;
                    }
                    //key = employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.department__c + String.Valueof(employeeAdministratorMap.get(reader.id).Expense_Type__r.Expense_Category__c).left(15);
                    /*
                    if (departmentBudgetCurrencyMap.containskey(key)){
                        reader.Tech_Budget_Exchange_Rate__c = budgetExchangeRateMap.get(String.valueof(localCurrencyId).left(15) + String.valueof(departmentBudgetCurrencyMap.get(key)).left(15)).rate__c;
                        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
                        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'+budgetExchangeRateMap);
                        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
                        
                        //reader.Budget_Amount__c = reader.Amount_Adjustment__c * exchangeRateMap.get(String.valueof(reader.receipt_currency__c).left(15) + String.valueof(departmentBudgetCurrencyMap.get(key)).left(15)).rate__c;
                    }
                    */
                    if (employeeAdministratorMap.get(reader.id).Expense_Type__r.Is_Health_Expense__c){
                        reader.Tech_Health_Exchange_Rate__c = exchangeRateMap.get(String.valueof(reader.receipt_currency__c).left(15) + String.valueof(employeeAdministratorMap.get(reader.id).Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense_currency__c).left(15)).rate__c;
                    }
                    expenseApplicationSharingList.add(new Expense_Application__c(id = reader.expense_application__c, Actual_Approver_1__c = reader.Actual_Approver_1__c, Actual_Approver_2__c = reader.Actual_Approver_2__c, Actual_Approver_3__c = reader.Actual_Approver_3__c, Actual_Approver_4__c = reader.Actual_Approver_4__c));                    
                }
            } 
           TEManualSharingCtrl.TEExpenseApplicationSharing(expenseApplicationSharingList, true);
        }
        
        if (!approvedExpenseDetailList.isEmpty()){
            receiptCurrencyMap = new Map <Id, String> ();
            for (Expense_Detail__c reader : [
                select id, Receipt_Currency__r.Name
                from Expense_Detail__c where id in :approvedExpenseDetailList]){
                    receiptCurrencyMap.put(reader.id, reader.Receipt_Currency__r.Name);
            }
            for (Expense_Detail__c reader : newExpenseDetailMap.values() ){
                if ((reader.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation || reader.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION)  && reader.status__c != oldExpenseDetailMap.get(reader.id).status__c
                    ||(reader.Amount_Adjustment__c != oldExpenseDetailMap.get(reader.id).Amount_Adjustment__c && reader.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation)){
                    reader.Approved_Amount_Chatter__c = accountingFormatString(receiptCurrencyMap.get(reader.Id), reader.Amount_Adjustment__c);
                }
            }
        }
    }
    
    private static string accountingFormatString(String currencyName, Decimal amount){
        String result;
        //result = currencyName + amount.format();
        if (amount == null) return '0.00';
        
        amount = Decimal.valueOf(Math.roundToLong(amount * 100)) / 100;
        result = (amount.setScale(2) + (amount >= 0 ? 0.001 : -0.001)).format();
        result = currencyName + ' ' + result.substring(0, result.length() - 1);
        return result;
    }
    
    Public Static void deductBudget(Map <Id, Expense_Detail__c> newExpenseDetailMap, Map <Id, Expense_Detail__c> oldExpenseDetailMap){
        List <Id> expenseDetailIdList = new List <Id>();
        List <Id> expenseCategoryIdList = new List <Id>();
        List <String> departmentList = new List <String>();
        //List <String> yearList = new List <String>();
        Map <Id, String> budgetKeyMap = new Map <Id, String>();
        Map <String, budget__c> budgetMap = new Map <String, budget__c>();
        Map <Id, Expense_Detail__c> expenseDetailMap = null;
        String key = '';
        FinanceUtil fu = new FinanceUtil();
        
        for (Expense_Detail__c reader : newExpenseDetailMap.Values()){
            if (reader.status__c == TEConstant.STATUS_CLOSED && reader.status__c != oldExpenseDetailMap.get(reader.id).status__c){
                expenseDetailIdList.add(reader.id);
            }
        }
        if (!expenseDetailIdList.isempty()){
            expenseDetailMap = new Map <Id, Expense_Detail__c>([
                select id, apply_date__c,  
                Expense_Application__r.On_Behalf_Of__r.Employee__r.department__c, Expense_Type__r.Expense_Category__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.site__c, 
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Tech_Policy_Function_Department_Section__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__r.Tech_Policy_Function_Department__c,
                Budget_Amount__c, Tech_Expense_Policy__c,
                Expense_Application__r.On_Behalf_Of__r.Employee__c
                from Expense_Detail__c where id in :expenseDetailIdList]);
            
            for (Expense_Detail__c reader : expenseDetailMap.values()){
                //expenseCategoryIdList.add(reader.Expense_Type__r.Expense_Category__c);
                key = budgetKey(reader, 1);
                budgetKeyMap.put (reader.id, key);
                // effDate_policy_expenseCategoryId_function_department_section
                //departmentList.add(reader.Expense_Application__r.On_Behalf_Of__r.Employee__r.department__c);
                //yearList.add(String.ValueOf(reader.apply_date__c.year()));
            }
            if(!budgetKeyMap.isEmpty()){
                budgetMap = fu.BudgetMap(budgetKeyMap.values());
            }
            for (Expense_Detail__c reader : expenseDetailMap.values()){
                key = budgetKey(reader, 1);
                if(!budgetMap.containsKey(key)){
                    key = budgetKey(reader, 2);
                }
                if(budgetMap.containsKey(key)){
                    budgetMap.get(key).Expense_Amount__c += reader.Budget_Amount__c;
                }
            }
            /*
            for (budget__c reader : [select id, Expense_Amount__c, department__c, Expense_Category__c, year__c, site__c
                                     from budget__c 
                                     where department__c in :departmentList and Expense_Category__c in :expenseCategoryIdList
                                     and year__c in :yearList
                                     and currency__r.is_budget_currency__c = true]){
                budgetMap.put(reader.department__c + String.Valueof(reader.Expense_Category__c).left(15) + reader.year__c + reader.site__c, reader);
            }
            
            for (Expense_Detail__c reader : expenseDetailMap.values()){
                key = reader.Expense_Application__r.On_Behalf_Of__r.Employee__r.department__c + String.Valueof(reader.Expense_Type__r.Expense_Category__c).left(15) + String.ValueOf(reader.apply_date__c.year())+ reader.Expense_Application__r.On_Behalf_Of__r.Employee__r.site__c ;
                if(budgetMap.containsKey(key)){
                        budgetMap.get(key).Expense_Amount__c += reader.Budget_Amount__c;
                }
                
            }
            */
            if (!budgetMap.isEmpty()){
                update budgetMap.values();
            }
            
        }
    }
    
    private Static String budgetKey(Expense_Detail__c reader, Integer type){
        String key = '';
        key  = String.ValueOf(reader.apply_date__c.year()) + '-';
        key += String.ValueOf(reader.apply_date__c.month()) + '-';
        key += String.ValueOf(reader.apply_date__c.day()) + '_';
        //key += reader.Tech_Expense_Policy__c + '_';
        key += reader.Expense_Type__r.Expense_Category__c + '_';        
        if (type == 1){
            key += reader.Expense_Application__r.On_Behalf_Of__r.Employee__r.Tech_Policy_Function_Department_Section__c;
        }
        if (type == 2){
            key += reader.Expense_Application__r.On_Behalf_Of__r.Employee__r.Tech_Policy_Function_Department__c;
        }
        return key;
    }
    
    /**
    * @description Add Expense Detail Log after the Expense Application is updated
    */ 
    public static void addExpenseDetailLogUponUpdate(Map <Id, Expense_Detail__c> newExpenseDetailMap, Map <Id, Expense_Detail__c> oldExpenseDetailMap){
        /*
        if(isRun){
            return;
        }
        isRun = !isRun;
        */
        String key = '';
        FinanceUtil fu = new FinanceUtil();
        List <Expense_Detail_Log__c> logToInsertList = new List <Expense_Detail_Log__c>(); 
        List <Id> expenseDetailIdList = new List <Id>();
        Set <String> departmentIdList = new Set <String>();
        Map <Id, String> budgetKeyMap = new Map <Id, String>();
        Map <Id, Expense_Detail__c> expenseDetailMap = new Map <Id, Expense_Detail__c>();
        Map <String, Cost_Center__c> costCenterMap = new Map <String, Cost_Center__c>();
        Map <String, budget__c> budgetMap = new Map <String, budget__c>();
        Map<Id, Budget__c> edbudgetMap = new Map <Id, Budget__c>();
        Map<String, String> typeMap = new Map <String, String>{
                TEConstant.STATUS_NOT_SUBMITTED => TEConstant.STATUS_ED_NOT_SUBMITTED,
                TEConstant.STATUS_PENDING_APPROVAL => TEConstant.STATUS_ED_PENDING_APPROVAL,
                TEConstant.STATUS_PENDING_FIN_Confirmation => TEConstant.STATUS_ED_PENDING_FINANCE,
                TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION => TEConstant.STATUS_ED_PENDING_APPLICANT,
                TEConstant.STATUS_CONFIRMED => TEConstant.STATUS_ED_CONFIRMED,
                TEConstant.STATUS_CANCELLED => TEConstant.STATUS_ED_CANCELLED,
                TEConstant.STATUS_CLOSED => TEConstant.STATUS_ED_CLOSED            
        };
        for (Expense_Detail__c reader : newExpenseDetailMap.values()){
            if (reader.status__c != oldExpenseDetailMap.get(reader.id).status__c &&
                   !edlogSet.contains(reader.id+reader.Status__c) &&
                   (reader.Status__c ==  TEConstant.STATUS_NOT_SUBMITTED || 
                    reader.Status__c ==  TEConstant.STATUS_PENDING_APPROVAL || 
                    reader.Status__c ==  TEConstant.STATUS_PENDING_FIN_Confirmation ||
                    reader.Status__c ==  TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION || 
                    reader.Status__c ==  TEConstant.STATUS_CONFIRMED || 
                    reader.Status__c ==  TEConstant.STATUS_CANCELLED ||
                    reader.Status__c ==  TEConstant.STATUS_CLOSED 
                   )
               ){
                    edlogSet.add(reader.id+reader.Status__c);
                    expenseDetailIdList.add(reader.id);
            }
        }      
        
        if (expenseDetailIdList.isEmpty()){
            return;
        }
        
        for (Expense_Detail__c reader : [select Name, Expense_Application__c, 
                                   Expense_Application__r.On_Behalf_Of__r.Employee__c, 
                                   Expense_Application__r.On_Behalf_Of__r.Employee_Department__c, 
                                   Expense_Application__r.On_Behalf_Of__r.Employee_Function__c, 
                                   Expense_Application__r.On_Behalf_Of__r.Employee_Section__c,
                                   Expense_Application__r.On_Behalf_Of__r.Employee_Full_Name__c,
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.Employee_ID__c,
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.Original_Employee_ID__c,
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.Grade__c,
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.Division__c, 
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.site__r.Division__c,
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.Site__r.Name,
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.Tech_Policy_Function_Department_Section__c,
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.Tech_Policy_Function_Department__c,
                                   Expense_Application__r.Travel_Application__c,
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Local_Currency__r.Name,
                                   Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c,
                                   Amount__c, Receipt_Currency__r.Name, Local_Amount__c, 
                                   Exchange_Request__r.Type__c, Exchange_Rate__c,
                                   Local_Amount_Adjustment__c, Budget_Amount__c,
                                   Expense_Type__r.Name, Expense_Type__r.Expense_Category__r.Name, Expense_Type__r.Account_Info__r.Name,
                                   Pay_Cheque__c, Description__c, Status__c,
                                   Expense_Application__r.On_Behalf_Of__r.Employee__r.expense_policy__r.Name,
                                   LastModifiedDate, createdById, On_Behalf_Of_Active_UserId__c, Apply_Date__c, Tech_Expense_Policy__c                               
                                   from Expense_Detail__c
                                   where Id in :expenseDetailIdList
                                   ]){
            expenseDetailMap.put(reader.Id, reader);
        }
        
        for (Id expenseDetailId : expenseDetailIdList){
            //departmentIdList.add(expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.employee__r.Tech_Policy_Function_Department__c);
            departmentIdList.add(expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.employee__r.Tech_Policy_Function_Department_Section__c);
        }
        System.debug(departmentIdList);
        costCenterMap = fu.CostCenterMap(new List<String>(departmentIdList));
        System.debug(costCenterMap);
        
        /*
        
        */
        for(Expense_Detail__c reader : expenseDetailMap.values()){  
            key = budgetKey(reader, 1);
            budgetKeyMap.put (reader.id, key);
        }
        if(!budgetKeyMap.isEmpty()){
            budgetMap = fu.BudgetMap(budgetKeyMap.values());
        }
        for(Expense_Detail__c reader : expenseDetailMap.values()){        
            key = budgetKey(reader, 1);
            if(!budgetMap.containsKey(key)){
                key = budgetKey(reader, 2);
            }
            if(budgetMap.containsKey(key)){
                edbudgetMap.put(reader.id, budgetMap.get(key));
                //budgetMap.get(key).Expense_Amount__c += reader.Budget_Amount__c;
            }
        }
        /*
        for (Cost_Center__c reader : [select Name, Department_Code__c, Function_Code__c, Section_Code__c,Tech_Policy_Function_Department_Section__c 
                                   from Cost_Center__c
                                   where Tech_Policy_Function_Department_Section__c in :departmentIdList
                                     ]){
            costCenterMap.put(reader.Tech_Policy_Function_Department_Section__c , reader.Name);      
        }
        */
        /*
        List <String> yearList = new List <String>();
        List <String> expenseCategoryList = new List <String>();
        List <Budget__c> budgetList = new List <Budget__c>();
        for (Id expenseDetailId : expenseDetailIdList){
            yearList.add(string.valueof(expenseDetailMap.get(expenseDetailId).LastModifiedDate.date().year()));
        }        
        for (Id expenseDetailId : expenseDetailIdList){
            expenseCategoryList.add(expenseDetailMap.get(expenseDetailId).Expense_Type__r.Expense_Category__r.Name);
        }
        for (Budget__c reader : [select Id, Budget__c, Currency__r.Name, Department__c, Expense_Category__r.Name, Year__c, Site__r.Name
                                   from Budget__c
                                   where Department__c in :departmentIdList
                                   and Expense_Category__r.Name in :expenseCategoryList
                                   and Year__c in :yearList
                                     ]){
            budgetList.add(reader);      
        }
        */
        /*
        for (Id expenseDetailId : expenseDetailIdList){
            
            for (Budget__c reader : budgetList){
                if (expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee_Department__c == reader.Department__c &&
                    expenseDetailMap.get(expenseDetailId).Expense_Type__r.Expense_Category__r.Name == reader.Expense_Category__r.Name &&
                    expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__r.Site__r.Name == reader.Site__r.Name &&
                    string.valueof(expenseDetailMap.get(expenseDetailId).LastModifiedDate.date().year()) == reader.Year__c){
                        budgetMap.put(expenseDetailId, reader);
                    }
            }
        }
        */
        //Datetime confirmedDate = null;
        // Build up expense detail log 
        for (Id expenseDetailId : expenseDetailIdList){
            /*
            if (expenseDetailMap.get(expenseDetailId).Status__c == TEConstant.STATUS_CONFIRMED)
            {
                confirmedDate = Datetime.now();
            }
            */

           logToInsertList.add(new Expense_Detail_Log__c (               
                /*
                 userIdSet.add(reader.createdById);
            if (reader.On_behalf_of_userid__c != null){
                userIdSet.add(reader.On_behalf_of_userid__c);
            }
            */
                //from expense detail
                ownerId =((expenseDetailMap.get(expenseDetailId).On_Behalf_Of_Active_UserId__c != null)?expenseDetailMap.get(expenseDetailId).On_Behalf_Of_Active_UserId__c : expenseDetailMap.get(expenseDetailId).createdById ),
                Expense_Application__c = expenseDetailMap.get(expenseDetailId).Expense_Application__c,
                Travel_Application__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.Travel_Application__c,
                Employee__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__c,
                Employee_Department__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee_Department__c,
                Employee_Full_Name__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee_Full_Name__c,
                Employee_ID__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__r.Employee_ID__c,
                Original_Employee_ID__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__r.Original_Employee_ID__c,
                Employee_Grade__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__r.Grade__c,             
                Division__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__r.site__r.Division__c,
                //Site__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__r.Site__r.Name,
                Expense_Detail__c = expenseDetailId,
                Amount__c = expenseDetailMap.get(expenseDetailId).Amount__c ,                
                Currency__c = expenseDetailMap.get(expenseDetailId).Receipt_Currency__r.Name,
                Exchange_Rate__c = expenseDetailMap.get(expenseDetailId).Exchange_Rate__c,
                Exchange_Rate_Type__c = ((expenseDetailMap.get(expenseDetailId).Exchange_Request__r.Type__c == 'BK')?'1':'2'),
                Local_Amount__c = expenseDetailMap.get(expenseDetailId).Local_Amount__c,
                Local_Currency__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Local_Currency__r.Name, 
                Amount_Adjustment__c = expenseDetailMap.get(expenseDetailId).Local_Amount_Adjustment__c,
                Requested_Budget_Amount__c = expenseDetailMap.get(expenseDetailId).Budget_Amount__c,
                Expense_Type__c = expenseDetailMap.get(expenseDetailId).Expense_Type__r.Name,
                Expense_Category__c = expenseDetailMap.get(expenseDetailId).Expense_Type__r.Expense_Category__r.Name,
                Expense_Policy_Name__c = expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__r.expense_policy__r.Name,
                Account_Number__c = expenseDetailMap.get(expenseDetailId).Expense_Type__r.Account_Info__r.Name,
                Pay_Cheque__c = expenseDetailMap.get(expenseDetailId).Pay_Cheque__c,
                Remarks__c = expenseDetailMap.get(expenseDetailId).Description__c,
                //Confirmed_Date__c = confirmedDate,
                Type__c = typeMap.get(expenseDetailMap.get(expenseDetailId).Status__c),
                
                //from cost center
                Cost_Center_Number__c = (costCenterMap.containskey(expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.employee__r.Tech_Policy_Function_Department_Section__c))?
                                         costCenterMap.get(expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.employee__r.Tech_Policy_Function_Department_Section__c).Name:
                                         (costCenterMap.containskey(expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.employee__r.Tech_Policy_Function_Department__c)?
                                         costCenterMap.get(expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.employee__r.Tech_Policy_Function_Department__c).Name
                                         :''),
                //Cost_Center_Number__c = costCenterMap.get(expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.employee__r.Tech_Policy_Function_Department_Section__c).Name,
                //Cost_Center_Number__c = costCenterMap.get(expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee__r.expense_policy__r.Name+expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee_Function__c+expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee_Department__c+expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee_Section__c),

                //from budget
                //edbudgetMap
                Budget__c = (edbudgetMap.containsKey(expenseDetailId)?edbudgetMap.get(expenseDetailId).Id:null),
                Budget_Currency__c = (edbudgetMap.containsKey(expenseDetailId)?edbudgetMap.get(expenseDetailId).Currency__r.Name:null),
                Budget_Department__c = (edbudgetMap.containsKey(expenseDetailId)?edbudgetMap.get(expenseDetailId).Tech_Policy_Function_Department_Section__c:''),
                Budget_Expense_Category__c = (edbudgetMap.containsKey(expenseDetailId)?edbudgetMap.get(expenseDetailId).Expense_Category__r.Name:''),
                /*
                Budget__c = (budgetMap.containsKey(expenseDetailId)?budgetMap.get(expenseDetailId).Id:null),
                //Budget_Amount__c = (budgetMap.containsKey(expenseDetailId)?budgetMap.get(expenseDetailId).Budget__c:0),
                Budget_Currency__c = (budgetMap.containsKey(expenseDetailId)?budgetMap.get(expenseDetailId).Currency__r.Name:''),
                Budget_Department__c = (budgetMap.containsKey(expenseDetailId)?budgetMap.get(expenseDetailId).Department__c:expenseDetailMap.get(expenseDetailId).Expense_Application__r.On_Behalf_Of__r.Employee_Department__c),
                Budget_Expense_Category__c = (budgetMap.containsKey(expenseDetailId)?budgetMap.get(expenseDetailId).Expense_Category__r.Name:''),
                */
                //special values for M3 reports
                Interface_Name__c = 'SALARY OFF STF',
                Identity__c = 'I1',
                Group_Number__c = 'a',
                Quantity__c = '0',
                VAT_Code__c = '0'
           ));
        }
        if (!logToInsertList.isEmpty()){
            insert logToInsertList;
            TEManualSharingCtrl.TEExpenseDetailSharing(expenseDetailMap.values(),true);            
        }
    }
    
    public static void uncheckAllowtoExceedMaxCap(Map <Id, Expense_Detail__c> newExpenseDetailMap, Map <Id, Expense_Detail__c> oldExpenseDetailMap){
        for(Expense_Detail__c reader: newExpenseDetailMap.values()) {
             if (reader.status__c == TEConstant.STATUS_DRAFT || reader.status__c == TEConstant.STATUS_NOT_SUBMITTED ) {
                if( reader.Allow_to_Exceed_Max_Cap__c == true) {
                    reader.Allow_to_Exceed_Max_Cap__c = false;
                }
             }
        }

    }
    
    public static void cahngeApprover(Map <Id, Expense_Detail__c> newExpenseDetailMap, Map <Id, Expense_Detail__c> oldExpenseDetailMap){
        Set<String> eaidSet = new Set<String>();
        Set<String> currentApprover = null;
        List<String> currentApproverList = null;
        List<Expense_Application__c> eaList = new List<Expense_Application__c>();
        for(Expense_Detail__c reader : newExpenseDetailMap.values()){
            if(reader.current_approver__c !=  oldExpenseDetailMap.get(reader.id).current_approver__c ){
                eaidSet.add(reader.expense_application__c);
            }
        }
        if(!eaidSet.isempty()){
            for(Expense_Application__c reader :[select id, current_approver__c, (select id, current_approver__c from expense_details__r) from expense_application__c where id in :eaidSet]){
                currentApprover = new Set<String>();
                for(expense_detail__c edreader : reader.expense_details__r){
                    if(!String.isBlank(edreader.current_approver__c)){
                        currentApprover.add(edreader.current_approver__c);
                    }
                }
                if(!currentApprover.isempty()){
                    currentApproverList = new List<String>();
                    currentApproverList.addAll(currentApprover);
                    eaList.add(new Expense_Application__c (id = reader.id, current_approver__c = String.join(currentApproverList, '^')));
                }
                else{
                    eaList.add(new Expense_Application__c (id = reader.id, current_approver__c = ''));
                }
            }
            if(!eaList.isempty()){
                upsert eaList;
            }
        }
    }
}