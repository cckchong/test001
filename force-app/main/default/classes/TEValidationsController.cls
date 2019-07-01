/**
 * TEValidationsController
 * @description validations controller for travel and expense
 */
public without Sharing class TEValidationsController {
    
    private static final String FINGROUOPNAMECODE = '@name';
    private static final String TRAVELAPPLICATIONCODE = '@name';
    private static final String FIN_GROUOP_NAME= 'TE_@name_FIN';
    
    public static Void checkOneExpenseToOneTravelApplication(Map<Id, Expense_Application__c> newTravelApplicationMap, Map<Id, Expense_Application__c> oldTravelApplicationMap){
        Map <Id, Id> expenseApplicationtravelApplicationIdLMap = new Map <Id, Id>();
        Map <Id, Travel_Application__c> travelApplicationIdLMap = null;
        String msg = '';
        for(Expense_Application__c reader : newTravelApplicationMap.values()){
            if((reader.status__c != oldTravelApplicationMap.get(reader.id).status__c) && (reader.status__c == TEConstant.STATUS_PENDING_APPROVAL) && (reader.travel_application__c != null)){
                expenseApplicationtravelApplicationIdLMap.put(reader.id, reader.travel_application__c);
            }
        }
        if (!expenseApplicationtravelApplicationIdLMap.isEmpty()){
            travelApplicationIdLMap = new Map <Id, Travel_Application__c>([select id, Name,Tech_Is_Expense_Application__c from Travel_Application__c where id in :expenseApplicationtravelApplicationIdLMap.values()]);
            for(Expense_Application__c reader : newTravelApplicationMap.values()){
                if(travelApplicationIdLMap.get(reader.travel_application__c).Tech_Is_Expense_Application__c){
                    msg = Label.TE_Expense_Application_And_Travel_Application;
                    msg = msg.replace(TRAVELAPPLICATIONCODE, travelApplicationIdLMap.get(reader.travel_application__c).name);
                    reader.adderror(msg);
                }
            }
        }
        
        
    }
    
    /**
     * @description check the existance of travel distance
     */      
    public static String checkExistingTravelDistance(Map<Id, Journey__c> journeyMap, Id journeyId, String err){
        if (String.isBlank(err)) {
            err = Label.TE_Travel_Application_Travel_Distance_Not_Found;
        }
        //err = err + Label.TE_Travel_Application_Travel_Distance_Not_Found_From + ' ' + journeyMap.get(journeyId).Origin_Site__r.City__c + ' ' + Label.TE_Travel_Application_Travel_Distance_Not_Found_To + ' ' + journeyMap.get(journeyId).Destination__r.City__c + '; ';
        
        //err = err + Label.TE_Travel_Application_Travel_Distance_Not_Found_From + ' ' + journeyMap.get(journeyId).From_Airport__r.Tech_Airport_Name__c + ' ' + Label.TE_Travel_Application_Travel_Distance_Not_Found_To + ' ' + journeyMap.get(journeyId).To_Airport__r.Tech_Airport_Name__c + '; ';
        err = err + Label.TE_Travel_Application_Travel_Distance_Not_Found_From + ' ' + journeyMap.get(journeyId).From_Airport__r.Name + ' ' + Label.TE_Travel_Application_Travel_Distance_Not_Found_To + ' ' + journeyMap.get(journeyId).To_Airport__r.Name + '; ';
        return err;
    }
    
    /**
     * @description block applicant recalling the expense application when expense application's status is Pending Applicant Approval
     */ 
    public static void blockApplicantRecallExpenseApplicationWhenPAC (Map<Id, Expense_Application__c> newExpenseApplicationMap, Map<Id, Expense_Application__c> oldExpenseApplicationMap) {
        
        for (Expense_Application__c reader : newExpenseApplicationMap.values()) {
                if ((reader.Status__c == TEConstant.STATUS_NOT_SUBMITTED) && (oldExpenseApplicationMap.get(reader.Id).Status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION)) {
                    reader.adderror(Label.TE_Expense_Application_Unable_To_Recall_When_PAC);
                }                
        }
    } 
    /**
     * @description block applicant recalling the expense detail when expense detail's status is Pending Applicant Approval
     */      
    public static void blockApplicantRecallExpenseDetailWhenPAC (Map<Id, Expense_Detail__c> newExpenseDetailMap, Map<Id, Expense_Detail__c> oldExpenseDetailMap) {
        
        for (Expense_Detail__c reader : newExpenseDetailMap.values()) {
                if ((reader.Status__c == TEConstant.STATUS_NOT_SUBMITTED) && (oldExpenseDetailMap.get(reader.Id).Status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION)) {
                    reader.adderror(Label.TE_Expense_Detail_Unable_To_Recall_When_PAC);
                }
        }
    }   
    /**
    * @description check whether the current user is in queue
    */
    public static boolean isQueueUser(String policyName){
        Boolean isQueueUser = false;
        String groupName = '';
        groupName = FIN_GROUOP_NAME;
        groupName = groupName.replace(FINGROUOPNAMECODE, policyName);
        for(GroupMember reader : [select id 
                                  from GroupMember 
                                  where
                                  UserOrGroupId = :UserInfo.getUserId()
                                  and GroupId in (select id from Group where DeveloperName = :groupName )] ){
            isQueueUser = true;
        }
        return isQueueUser; 
    }
    
    public static void checkExistingExpenseDetail(Map<Id,Expense_Application__c> newExpenseApplicationMap, Map<Id,Expense_Application__c> oldExpenseApplicationMap){
        for(Expense_Application__c ea: newExpenseApplicationMap.values()){
            if(ea.Status__c == TEConstant.STATUS_PENDING_APPROVAL){
                if(ea.Total_Amount__c == 0){
                    ea.Total_Amount__c.addError(Label.TE_Expense_Application_Should_Contain_Expense_Detail);
                }
            }
        }
    }
    
    public static void checkOverlappedEducationApplication(List<Education_Application__c> newEducationApplicationList,  Map<Id,Education_Application__c> oldEducationApplicationMap){
        List<ID> employeeAdministorIDList = new List<Id>();
        List<Education_Application__c> existingEducationApplicationList = new List<Education_Application__c>();

        for(Education_Application__c reader : newEducationApplicationList) {
            /**
            if( reader.status__c == TEConstant.STATUS_DRAFT || reader.status__c == TEConstant.STATUS_NOT_SUBMITTED ||
                reader.status__c == TEConstant.STATUS_PENDING_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ||
                reader.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL || reader.status__c == TEConstant.STATUS_APPROVED ) {
            */     
            if (oldEducationApplicationMap == NULL ||
                (reader.status__c != oldEducationApplicationMap.get(reader.Id).status__c &&
                    (reader.status__c == TEConstant.STATUS_PENDING_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ||
                    reader.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL || reader.status__c == TEConstant.STATUS_APPROVED ||
                    (reader.status__c == TEConstant.STATUS_NOT_SUBMITTED && 
                        (oldEducationApplicationMap.get(reader.Id).status__c == TEConstant.STATUS_CANCELLED || oldEducationApplicationMap.get(reader.Id).status__c == TEConstant.STATUS_REJECT ))))){ 
                employeeAdministorIDList.add(reader.On_Behalf_Of__c);
            }
        }
        if(!employeeAdministorIDList.isempty()) {
            existingEducationApplicationList = [SELECT Id, Name, On_Behalf_Of__c, RecordTypeId, Start_Date__c, End_Date__c, Status__c FROM Education_Application__c WHERE On_Behalf_Of__c =: employeeAdministorIDList AND Status__c =: TEConstant.STATUS_APPROVED];
        }
        
        for(Education_Application__c newEducationApplication : newEducationApplicationList) {
            for(Education_Application__c existingEducationApplication: existingEducationApplicationList ) {
                if (newEducationApplication.Id == existingEducationApplication.Id) {
                    continue;
                }
                if(newEducationApplication.On_Behalf_Of__c ==  existingEducationApplication.On_Behalf_Of__c) {
                    if (newEducationApplication.RecordTypeId == existingEducationApplication.RecordTypeId ){
                        if (newEducationApplication.Is_Child_Education__c){
                            newEducationApplication.adderror(Label.TE_Child_Education_Application_Only_One_Allowed + ' ' + existingEducationApplication.Name + ')');
                        }
                        else if( (newEducationApplication.Start_Date__c >= existingEducationApplication.Start_Date__c && newEducationApplication.Start_Date__c <= existingEducationApplication.End_Date__c) ||
                            (newEducationApplication.End_Date__c>= existingEducationApplication.Start_Date__c && newEducationApplication.End_Date__c <= existingEducationApplication.End_Date__c) ||
                            (newEducationApplication.Start_Date__c <= existingEducationApplication.Start_Date__c && newEducationApplication.End_Date__c >= existingEducationApplication.End_Date__c)) {
                                newEducationApplication.adderror(Label.TE_Education_Application_Period_Cannot_Be_Overlapped + ' ' + existingEducationApplication.Name + ')');
                        }
                    }
                }
            }
        }
    }
    //=============================================================================
    /*
    Public static void checkGHGSetting (List<Journey__c> JourneyList){
        List<id> fromIdList = new List<id>();
        List<id> toIdList = new List<id>();
        List<id> cabinClassIdList = new List<id>();
        List<Journey__c> journeydCheckList = new List<Journey__c>();
        List<Carbon_Emission__c> carbonEmissionsList = null;
        Map<String, travel_distance__c> travelDistanceMap = new Map<String, travel_distance__c>();
        Map<String, AirPort__c> taMap = new Map<String, AirPort__c>();
        String errorMsg = '';
        String key = '';
        Boolean existingGHGfactor;
        
        for(Journey__c reader : JourneyList){
            if(reader.Cabin_Class__c != null){
                fromIdList.add(reader.From_Airport__c);
                toIdList.add(reader.To_Airport__c);
                cabinClassIdList.add(reader.Cabin_Class__c);
                journeydCheckList.add(reader);
            }
        }
        
        for(travel_distance__c reader : [select id, (select id, GHG_Factor__r.Cabin_Class__c from Carbon_Emissions__r), 
                                         from_city__c, to_city__c, Tech_From_To__c, 
                                         //from__c, to__c,
                                         From_Airport__c, To_Airport__c
                                         from travel_distance__c 
                                         where From_Airport__c in :fromIdList and To_Airport__c in :toIdList]){
            travelDistanceMap.put(String.Valueof(reader.From_Airport__c).left(15)+String.Valueof(reader.To_Airport__c).left(15), reader);
        }
        
        for(AirPort__c reader : [select id, Travel_Location__c, Travel_Location__r.city__c 
                                 from AirPort__c where id in :fromIdList or id in :toIdList]){
            taMap.put(reader.id, reader);
        }
        
        for(Journey__c reader : journeydCheckList){
            key = String.Valueof(reader.From_Airport__c).left(15)+String.Valueof(reader.To_Airport__c).left(15);
            errorMsg = '';
            if (travelDistanceMap.containsKey(key)){
                carbonEmissionsList = travelDistanceMap.get(key).Carbon_Emissions__r;
                existingGHGfactor = false;
                for(Carbon_Emission__c cereader : carbonEmissionsList){
                    if(cereader.GHG_Factor__r.Cabin_Class__c == reader.Cabin_Class__c){
                        existingGHGfactor = true;
                    }
                }
                if(!existingGHGfactor){
                    errorMsg += Label.TE_Travel_Application_GHG_Factor_Not_Found;
                    errorMsg += Label.TE_Travel_Application_GHG_Factor_Not_Found_From + ' ' + taMap.get(reader.From_Airport__c).Travel_Location__r.city__c+ ' ' + Label.TE_Travel_Application_GHG_Factor_Not_Found_To + ' ' + taMap.get(reader.To_Airport__c).Travel_Location__r.city__c + '; ' ;
                }
                
            }
            else{
                errorMsg += Label.TE_Travel_Application_Travel_Distance_Not_Found;
                errorMsg += Label.TE_Travel_Application_GHG_Factor_Not_Found_From + ' ' + taMap.get(reader.From_Airport__c).Travel_Location__r.city__c + ' ' + Label.TE_Travel_Application_GHG_Factor_Not_Found_To + ' ' + taMap.get(reader.To_Airport__c).Travel_Location__r.city__c + '; ' ;
            }
            if (errorMsg != ''){
                reader.adderror(errorMsg);
            }
        }
    }
    
    */
    
    /**
     * @description check the existance of GHG Factor 
     */  
    /*
    public static String checkExistingGHGFactor(Map<Id, Journey__c> journeyMap, Id journeyId, String err){
        if (String.isBlank(err)) {
            err = Label.TE_Travel_Application_GHG_Factor_Not_Found;
        }
        //err = err + Label.TE_Travel_Application_GHG_Factor_Not_Found_From + ' ' + journeyMap.get(journeyId).Origin_Site__r.City__c + ' ' + Label.TE_Travel_Application_GHG_Factor_Not_Found_To + ' ' + journeyMap.get(journeyId).Destination__r.City__c + '; ';
        err = err + Label.TE_Travel_Application_GHG_Factor_Not_Found_From + ' ' + journeyMap.get(journeyId).From_Airport__r.Name + ' ' + Label.TE_Travel_Application_GHG_Factor_Not_Found_To + ' ' + journeyMap.get(journeyId).To_Airport__r.Name + '; ';
        return err;
    }
    */

    
    /**
     * @description block the submission of the travel application without journey records 
     */
    /*
    public static void checkExistingJourneyRecords(Map<Id,Travel_Application__c> newTravelApplicationMap, Map<Id,Travel_Application__c> oldTravelApplicationMap ){
        
        for(Travel_Application__c ta: newTravelApplicationMap.values()){
            if(ta.Status__c == TEConstant.STATUS_PENDING_APPROVAL){
                if(ta.Total_Journey__c <= 0){
                    ta.Total_Journey__c.addError(Label.TE_Travel_Application_Should_Contain_Journey);
                }
            }
        }
        
    }
    */
    
    /**
     * @description To check journey departure/arrival date is between travel application departure/arrival date
    */
    /*
    public static void checkDepartureDatewithJourney (Map<Id,Travel_Application__c> newTravelApplicationMap, Map<Id,Travel_Application__c> oldTravelApplicationMap){
       
       for(Travel_Application__c ta: newTravelApplicationMap.values()){
            if(ta.Status__c == TEConstant.STATUS_PENDING_APPROVAL && oldTravelApplicationMap.get(ta.id).status__c != ta.status__c){                
                if(ta.Tech_Earliest_Departure_Date__c < ta.Departure_Date__c || ta.Tech_Latest_Arrival_Date__c > ta.Return_Date__c ){
                    ta.adderror(Label.TE_Travel_Application_Date_Error);
                }
            }
        }
        
    }
    */ 
    
    /**
     * @description block the deletion of cash advance when travel application is not Draft or Not Submitted
     */   
    /* 
    public static Void checkCashAdvanceDeleteValidation(Map<Id, Cash_Advance__c> newTravelApplicationMap, Map<Id, Cash_Advance__c> oldTravelApplicationMap ){
        for (Cash_Advance__c reader : oldTravelApplicationMap.values() ){
            if ( !( reader.Travel_Application_Status__c == TEConstant.STATUS_NOT_SUBMITTED || reader.Travel_Application_Status__c == TEConstant.STATUS_DRAFT ) ){
                reader.adderror(Label.TE_Cash_Advance_Cannot_Delete);
            }
        }
    }
    */
    
    /**
     * @description block applicant modifying the expense Application when expense application's status is Pending Applicant Approval
     */  
   /*
    public static void blockApplicantModifyExpenseApplicationWhenPAC (Map<Id, Expense_Application__c> newExpenseApplicationMap, Map<Id, Expense_Application__c> oldExpenseApplicationMap) {
        
        for (Expense_Application__c reader : newExpenseApplicationMap.values()) {
            if (reader.Status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION) {
                if ((UserInfo.getUserId() == reader.Tech_Applicant__c)){                
                    if (reader.LastModifiedDate != oldExpenseApplicationMap.get(reader.Id).LastModifiedDate && (reader.status__c != oldExpenseApplicationMap.get(reader.Id).status__c || reader.Last_Approval_Action_Date__c != oldExpenseApplicationMap.get(reader.Id).Last_Approval_Action_Date__c)){
                        reader.adderror(Label.TE_Expense_Detail_Applicant_Not_Allowed_To_Modify);                        
                    }
                }
            }
        }
    }
    */
    /**
     * @description block applicant modifying the expense detail when expense detail's status is Pending Applicant Approval
     */
    /*     
    public static void blockApplicantModifyExpenseDetailWhenPAC (Map<Id, Expense_Detail__c> newExpenseDetailMap, Map<Id, Expense_Detail__c> oldExpenseDetailMap) {
        
        for (Expense_Detail__c reader : newExpenseDetailMap.values()) {
            if (reader.Status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION) {
                if ((UserInfo.getUserId() == reader.Tech_Applicant__c)){                
                    if (reader.LastModifiedDate != oldExpenseDetailMap.get(reader.Id).LastModifiedDate && (reader.status__c == oldExpenseDetailMap.get(reader.Id).status__c || reader.Last_Approval_Action_Date__c == oldExpenseDetailMap.get(reader.Id).Last_Approval_Action_Date__c)) {
                        reader.adderror(Label.TE_Expense_Detail_Applicant_Not_Allowed_To_Modify);                        
                    }
                }
            }
        }
    }
    */
    
    /**
    * @description require filling the field(s) 
    */
    /*   
    public static String receiptDatecheck(Expense_Detail__c expenseDetail){
        String errorMsg = '';
        if (expenseDetail.receipt_date__c > system.today()){
            errorMsg = Label.TE_Expense_Detail_Receipt_Date_Checker;
            errorMsg = errorMsg.replace('@date', ((DateTime)system.today()).format('dd MMM yyyy'));
        }
        return errorMsg ;
    }
    */
    /**
    * @description require filling the field(s) 
    */ 
    /*   
    public static String requiredFieldcheck(Expense_Detail__c expenseDetail, Map<Id, Expense_Type__c> ExpenseTypeMap){
        String errorMsg = '';
        if(expenseDetail.Amount__c == null){
            errorMsg += Label.TE_Expense_Detail_Amount_Field;
        }
        if(expenseDetail.Receipt_Date__c == null){
            errorMsg += Label.TE_Expense_Detail_Receipt_Date_field;
        }
        if ( expenseDetail.Expense_Type__c == null){
            errorMsg += Label.TE_Expense_Detail_Select_One_Expense_Type;
        } else
        if(expenseDetail.Description__c == null && 
            (
                expenseDetail.Number_Of_People__c > ExpenseTypeMap.get(expenseDetail.Expense_Type__c).Require_Number_of_People_Threshold__c //|| expenseDetail.Over_Max_Cap__c
            )
          ){
            errorMsg += Label.TE_Expense_Detail_Description_Field;
        }
        
        //ExpenseTypeMap 
        if (expenseDetail.Expense_Type__c != null && (ExpenseTypeMap.get(expenseDetail.Expense_type__c).Is_Meal_Expense__c || ExpenseTypeMap.get(expenseDetail.Expense_type__c).Is_Hotel_Expense__c)){
            if(expenseDetail.Destination__c == null){
                errorMsg += Label.TE_Expense_Detail_Destination_Field;
            }
        }
        return errorMsg ;
    }
    */
    /**
    * @description check own site from employee 
    */
    /*        
    public static String checkOwnSite(List<Travel_Application__c> travelApplicationList){
        
        List <ID> onBeHalfOfEmployeeList = new List <ID>();
        Map <id, Employee__c> employeeMap = new Map <id, Employee__c>();
                
        for ( Travel_Application__c reader : travelApplicationList){
            if (reader.status__c == TEConstant.STATUS_DRAFT || reader.status__c == TEConstant.STATUS_NOT_SUBMITTED){
                onBeHalfOfEmployeeList.add(reader.On_Behalf_of__c);
            }
        }

        if (!onBeHalfOfEmployeeList.isempty()){
            for (Employee__c reader : [select id, Site__c from employee__c where id in :onBeHalfOfEmployeeList]){
                employeeMap.put(reader.id, reader);
            }
        }
        
        return '';
    }
    */
    /**
     * @description block the submission of the expense application without expense detail(s) 
     */   
    
    /*
    Public Static void checkHealthAmountExceed (List<TEExpenseDetailItem> TEExpenseDetailItemList, Expense_Application__c expenseApplication, Map<Id, Expense_Type__c> ExpenseTypeMap){
        
        Map <String, double> yearFitnessAmoutMap = new Map <String, double>();
        Double healthAmount = 0;
        Boolean isHealthExpense = false;
        for (TEExpenseDetailItem reader :TEExpenseDetailItemList){
            if (expenseTypeMap.get(reader.expenseDetail.Expense_Type__c).Is_Health_Expense__c){
                isHealthExpense = true;
            }
        }
        if (isHealthExpense){
            for (AggregateResult result :[
                    select CALENDAR_YEAR (Apply_Date__c), sum (Health_Amount__c) healthAmount
                    from Expense_Detail__c 
                    where status__c = :TEConstant.STATUS_CLOSED
                    and expense_type__r.Is_Health_Expense__c = true
                    and CALENDAR_YEAR (Apply_Date__c) = :system.today().year()
                    and on_behalf_of__r.employee__c = :expenseApplication.On_Behalf_Of__r.employee__c
                    and Expense_Type__r.Is_Health_Expense__c = true
                    group by CALENDAR_YEAR (Apply_Date__c)
            ]){
                healthAmount = (Double)result.get('healthAmount');
            }
            for (TEExpenseDetailItem reader :TEExpenseDetailItemList){
                if (expenseTypeMap.get(reader.expenseDetail.Expense_Type__c).Is_Health_Expense__c){
                    healthAmount += reader.expenseDetail.Amount__c * reader.expenseDetail.Tech_Health_Exchange_Rate__c ;            
                    if (healthAmount > expenseApplication.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense__c){
                        reader.errormsg = Label.TE_Expense_Detail_health_expense_excess.replace('@',
                            expenseApplication.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense_currency__r.name +' '+ 
                            expenseApplication.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense__c 
                        );
                    }
                }
            }            
        }
    }
    
    Public Static void healthAmountCal (List<Expense_Detail__c> expenseDetailList){
        Map <Id, Expense_Type__C> expenseDetailTypeMap = new Map <Id, Expense_Type__C>();
        Map <Id, Expense_Type__C> expenseTypeMap = new Map <Id, Expense_Type__C>();
        List <ID> expenseTypeIDList = new List <ID>();
        List <ID> expenseApplicationIDList = new List <ID>();
        List <ID> expenseDetailIdList = new List<ID>();        
        List <ID> expenseDetailCurrencyList = new List<ID>();
        Map <String, Exchange_Rate__c> exchangeRateMap = new Map <String, Exchange_Rate__c>();
        Map <ID, ID> healthExpenseCurrencyMap = new Map<ID, ID>();
        Boolean existingHealthExpense = false;
        
        for(Expense_Detail__c reader : expenseDetailList){
            expenseDetailTypeMap.put(reader.id, null);
            expenseTypeIDList.add(reader.Expense_Type__c);            
            expenseDetailCurrencyList.add(reader.receipt_currency__c);
            expenseApplicationIDList.add(reader.Expense_Application__c);
            expenseDetailIdList.add(reader.id);
        }
        for (expense_type__c reader :[select id, Is_Health_Expense__c from expense_type__c where id in :expenseTypeIDList ]){
            expenseTypeMap.put(reader.id , reader);
            if (reader.Is_Health_Expense__c){
                existingHealthExpense = true;
            }
        }
        if (existingHealthExpense){
            for (Expense_Detail__c reader : expenseDetailList){
                expenseDetailTypeMap.put(reader.id, expenseTypeMap.get(reader.Expense_Type__c));
            }
            for (Expense_Application__c reader :[select id,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense_currency__c
                from Expense_Application__c  where id in :expenseApplicationIDList]){
                healthExpenseCurrencyMap.put(reader.id, reader.On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense_currency__c);
            }
            for(Exchange_Rate__c reader : [
                select id, Tech_From_To_Currency_ID__c, rate__c
                from Exchange_Rate__c
                where 
                From_Currency__c = :expenseDetailCurrencyList
                and To_Currency__c = :healthExpenseCurrencyMap.values()
                and is_latest__c = true
                and Is_Book_Rate__c = true
            ] ){
               exchangeRateMap.put (reader.Tech_From_To_Currency_ID__c, reader);
            } 
            for(Expense_Detail__c reader : expenseDetailList){
                reader.Tech_Health_Exchange_Rate__c= 0;
                if (expenseDetailTypeMap.get(reader.id).Is_Health_Expense__c){
                    reader.Tech_Health_Exchange_Rate__c = exchangeRateMap.get(String.valueof(reader.receipt_currency__c).left(15)+String.valueof(healthExpenseCurrencyMap.get(reader.Expense_Application__c)).left(15) ).rate__c ;
                }
            }
        }
    }
    */
    
    /*
    Public Static void checkExpenseDetailDailyMaxCap (List<TEExpenseDetailItem> TEExpenseDetailItemList ){
        List<Expense_Detail__c> expenseDetailList = new List<Expense_Detail__c>();
        for (TEExpenseDetailItem reader :TEExpenseDetailItemList){
            expenseDetailList.add(reader.expenseDetail);
        }
        checkMaxCap(expenseDetailList);
    }
    
    Private Static void checkMaxCap(List<Expense_Detail__c> expenseDetailList){        
        DateTime dt = null;
        String key = '';
        double amount = 0;
        Double cost;
        String toCurrencyId ='';
        List <ID> toCurrencyIdList = new List <ID>();
        List <ID> expenseTypeIdList = new List <ID>();
        List <ID> destinationIdList = new List <ID>();        
        List <ID> fromCurrencyIdList = new List <ID>();
        List <Expense_Detail__c> validExpenseDetailList = new List <Expense_Detail__c>();
        Map <Id, Expense_Type__c> ExpenseTypeMap = null;
        Map <ID, ID> expenseTypeExpensepolicyIDMap = new Map <ID, ID>();
        Map <Id, Travel_Location__c> travelLocationMap = new Map <Id, Travel_Location__c>();
        Map <String, double> expenseGroupByDestinationExpenseTypeAndDateMap = new Map <String, double>();
        Map <String, double> allExpenseGroupByDestinationAndDateMap = new Map <String, double>();
        Map <String, Exchange_Rate__c> exchangeRateMap = new Map <String, Exchange_Rate__c>();
        Map<String, Double> dailyMaxMeal = new Map<String, Double>();
        Map<String, Double> dailyMaxHotel = new Map<String, Double>();
        Map<String, Double> dailyMaxCap = new Map<String, Double>();
        List<Travel_Location_Allowance__c> travelLocationAllowanceList = null;
        
        
        for (Expense_Detail__c reader : expenseDetailList){
            reader.Over_Max_Cap__c = false;
            if (reader.expense_type__c != null && reader.Destination__c!= null && reader.Receipt_Currency__c!= null && reader.Receipt_Date__c!= null && reader.Amount__c!= null){
                expenseTypeIdList.add(reader.expense_type__c);
                destinationIdList.add(reader.Destination__c);
                fromCurrencyIdList.add(reader.Receipt_Currency__c);
                toCurrencyIdList.add(reader.Allowance_Currency__c);
                toCurrencyIdList.add(reader.Hotel_Allowance_Currency__c);
                toCurrencyIdList.add(reader.Meal_Allowance_Currency__c);
                dailyMaxMeal.put(String.valueof(reader.Receipt_Date__c), 0);
                dailyMaxHotel.put(String.valueof(reader.Receipt_Date__c), 0);
                dailyMaxCap.put(String.valueof(reader.Receipt_Date__c), 0);
                validExpenseDetailList.add(reader);
            }
        }
        ExpenseTypeMap = new Map <Id, Expense_Type__c>([select id, Expense_Category__c, Expense_Properties__c, Is_Hotel_Expense__c, Is_Meal_Expense__c, Expense_Policy__c, Expense_Policy__r.Is_Daily_Allowance__c from expense_type__c where id in :expenseTypeIdList ]);
        for (Expense_Type__c reader : ExpenseTypeMap.values()){
            expenseTypeExpensepolicyIDMap.put(reader.id, reader.Expense_Policy__c);
        }
        
        for (Exchange_Rate__c reader : [select id, Rate__c, Tech_From_To_Currency_ID__c, Is_Budget_Rate__c
                                        from Exchange_Rate__c 
                                        where From_Currency__c in :fromCurrencyIdList 
                                        and To_Currency__c in :toCurrencyIdList
                                        and Is_Latest__c = true
                                        and Is_Book_Rate__c = true
        ]){
            exchangeRateMap.put(reader.Tech_From_To_Currency_ID__c , reader);
        }        
        for (Travel_Location__c reader : [select id,
                                         (select id, Daily_Maximum_Hotel_Cost__c, Daily_Maximum_Meal__c, Daily_Maximum_Cost__c, Expense_Policy__c, Travel_Location__c
                                          from Travel_Location_Allowances__r 
                                          where Expense_Policy__c = :expenseTypeExpensepolicyIDMap.values())
                                         //Maximum_Hotel_Cost__c, Maximum_Meal__c
                                         from Travel_Location__c
                                         where id in :destinationIdList]){
            travelLocationMap.put(reader.id, reader);
        }
        for (Expense_Detail__c reader : validExpenseDetailList){
                travelLocationAllowanceList = travelLocationMap.get(reader.Destination__c).Travel_Location_Allowances__r;
                if (!travelLocationAllowanceList.isEmpty()){
                    for (Travel_Location_Allowance__c tlaReader : travelLocationAllowanceList){
                        if (tlaReader.expense_policy__c == expenseTypeExpensepolicyIDMap.get(reader.Expense_Type__c)){
                            if (ExpenseTypeMap.get(reader.Expense_Type__c).Expense_Policy__r.Is_Daily_Allowance__c){
                                if (dailyMaxCap.get(String.valueof(reader.Receipt_Date__c)) < tlaReader.Daily_Maximum_Cost__c){
                                    dailyMaxCap.put(String.valueof(reader.Receipt_Date__c), tlaReader.Daily_Maximum_Cost__c);
                                }
                            }
                            else{
                                if (dailyMaxMeal.get(String.valueof(reader.Receipt_Date__c)) < tlaReader.Daily_Maximum_Meal__c){
                                    dailyMaxMeal.put(String.valueof(reader.Receipt_Date__c), tlaReader.Daily_Maximum_Meal__c);
                                }
                                if (dailyMaxHotel.get(String.valueof(reader.Receipt_Date__c)) < tlaReader.Daily_Maximum_Hotel_Cost__c){
                                    dailyMaxHotel.put(String.valueof(reader.Receipt_Date__c), tlaReader.Daily_Maximum_Hotel_Cost__c);
                                }
                            }
                        }
                    }
                }
            //}
        }
        
        //Sum Expense Detail Amount And Group By Destination, Receipt Date, Expense Type 
        for (Expense_Detail__c reader : validExpenseDetailList){
            if (reader.Expense_Type__c != null){
                if (ExpenseTypeMap.get(reader.Expense_Type__c).Expense_Policy__r.Is_Daily_Allowance__c){
                    toCurrencyId = '';
                    key = String.valueof(reader.Receipt_Date__c);
                    if(reader.Allowance_Currency__c != null){
                            toCurrencyId = reader.Allowance_Currency__c;
                    }
                    if (toCurrencyId != ''){
                        amount = exchangeRateMap.get(String.valueof(reader.Receipt_Currency__c).left(15) + String.valueof(toCurrencyId).left(15)).Rate__c * reader.amount__c / ((reader.Number_Of_People__c == null || reader.Number_Of_People__c == 0)? 1: reader.Number_Of_People__c);
                        if (allExpenseGroupByDestinationAndDateMap .containsKey(key)){
                            amount += allExpenseGroupByDestinationAndDateMap .get(key);
                        }
                        allExpenseGroupByDestinationAndDateMap.put(key, amount);
                    }
                }
                else{
                    //key = String.valueof(reader.Receipt_Date__c)+String.valueof(reader.Expense_Type__c);
                    key = String.valueof(reader.Receipt_Date__c)+String.valueof(ExpenseTypeMap.get(reader.Expense_Type__c).Expense_Category__c)+String.valueof(ExpenseTypeMap.get(reader.Expense_Type__c).Expense_Properties__c);
                    if (ExpenseTypeMap.get(reader.Expense_Type__c).Is_Hotel_Expense__c || ExpenseTypeMap.get(reader.Expense_Type__c).Is_Meal_Expense__c){
                        //key = String.valueof(reader.Destination__c)+String.valueof(reader.Receipt_Date__c)+String.valueof(reader.Expense_Type__c);                
                        toCurrencyId = '';
                        if(ExpenseTypeMap.get(reader.Expense_Type__c).Is_Hotel_Expense__c){
                            toCurrencyId = reader.Hotel_Allowance_Currency__c;
                        }
                        if(ExpenseTypeMap.get(reader.Expense_Type__c).Is_Meal_Expense__c){
                            toCurrencyId = reader.Meal_Allowance_Currency__c;
                        }
                        if (toCurrencyId != ''){
                            amount = exchangeRateMap.get(String.valueof(reader.Receipt_Currency__c).left(15) + String.valueof(toCurrencyId).left(15)).Rate__c * reader.amount__c / ((reader.Number_Of_People__c == null || reader.Number_Of_People__c == 0)? 1: reader.Number_Of_People__c);
                            if (expenseGroupByDestinationExpenseTypeAndDateMap.containsKey(key)){
                                amount += expenseGroupByDestinationExpenseTypeAndDateMap.get(key);
                            }
                            expenseGroupByDestinationExpenseTypeAndDateMap.put(key, amount);                            
                        }
                    }
                }
            }
        }
        for (Expense_Detail__c reader : validExpenseDetailList){
            //if (reader.expense_type__c != null && reader.Destination__c!= null && reader.Receipt_Currency__c!= null && reader.Receipt_Date__c!= null && reader.Amount__c!= null){
                if (ExpenseTypeMap.get(reader.Expense_Type__c).Expense_Policy__r.Is_Daily_Allowance__c){
                    reader.Tech_Max_Cap__c = dailyMaxCap.get(String.Valueof(reader.Receipt_Date__c));
                }else{
                    reader.Tech_Meal_Max_Cap__c = dailyMaxMeal.get(String.Valueof(reader.Receipt_Date__c));
                    reader.Tech_Hotel_Max_Cap__c = dailyMaxHotel.get(String.Valueof(reader.Receipt_Date__c));
                }
            //}
        }
        for (Expense_Detail__c reader : validExpenseDetailList){
            if (reader.Expense_Type__c != null){
                reader.Over_Max_Cap__c = false;
                if (ExpenseTypeMap.get(reader.Expense_Type__c).Expense_Policy__r.Is_Daily_Allowance__c){
                    key = String.valueof(reader.Receipt_Date__c);    
                    if (dailyMaxCap.get(String.Valueof(reader.Receipt_Date__c)) < allExpenseGroupByDestinationAndDateMap.get(key)){
                            reader.Over_Max_Cap__c = true;
                    }
                } else{
                    //key = String.valueof(reader.Receipt_Date__c)+String.valueof(reader.Expense_Type__c);
                    key = String.valueof(reader.Receipt_Date__c)+String.valueof(ExpenseTypeMap.get(reader.Expense_Type__c).Expense_Category__c)+String.valueof(ExpenseTypeMap.get(reader.Expense_Type__c).Expense_Properties__c);
                    if (ExpenseTypeMap.get(reader.Expense_Type__c).Is_Hotel_Expense__c || ExpenseTypeMap.get(reader.Expense_Type__c).Is_Meal_Expense__c){
                        //key = String.valueof(reader.Destination__c)+String.valueof(reader.Receipt_Date__c)+String.valueof(reader.Expense_Type__c);
                        if (ExpenseTypeMap.get(reader.Expense_Type__c).Is_Hotel_Expense__c){
                            //reader.Tech_Hotel_Max_Cap__c = expenseGroupByDestinationExpenseTypeAndDateMap.get(key);
                            if (dailyMaxHotel.get(String.Valueof(reader.Receipt_Date__c)) < expenseGroupByDestinationExpenseTypeAndDateMap.get(key)){
                                reader.Over_Max_Cap__c = true;
                            }
                        }
                        if (ExpenseTypeMap.get(reader.Expense_Type__c).Is_Meal_Expense__c){
                            //reader.Tech_Meal_Max_Cap__c = expenseGroupByDestinationExpenseTypeAndDateMap.get(key);
                            if (dailyMaxMeal.get(String.Valueof(reader.Receipt_Date__c)) < expenseGroupByDestinationExpenseTypeAndDateMap.get(key)){
                                reader.Over_Max_Cap__c = true;
                            }
                        }
                    }
                }
            }
        }
    }
    */
    
    /*
    Public static String travelDetailRequiredField(Travel_Detail__c travelDetail){
        String msg = '';
        if (travelDetail.Origin_Site__c == null){
            msg = 'Missing From Field';
        }
        if (travelDetail.Destination__c == null){
            msg = 'Missing To Field';
        }
        if (travelDetail.Preferred_Departure_dt__c == null){
            msg = 'Missing To Field';
        }
        if (travelDetail.Preferred_Return_dt__c == null){
            msg = 'Missing To Field';
        }        
        if (travelDetail.Preferred_Airline__c== null){
            msg = 'Missing To Field';
        }
        
        
        return msg;
    }
    */
    
    
    
    
    
}