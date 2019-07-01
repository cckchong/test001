/**
 * TEManualSharingCtrl
 * @author KONG
 * @description To set Manual Sharing for T&E Sharing
 */
 
public without sharing class TEManualSharingCtrl  {

    /*Sharing Rule Reason*/
    Public static final String TRAVEL_APPLICATION_SHARING_RULE_APPROVER_SHARING = Schema.Travel_Application__Share.RowCause.Approver_Sharing__c;
    Public static final String TRAVEL_APPLICATION_SHARING_RULE_MENTION_USER_SHARING = Schema.Travel_Application__Share.RowCause.Mention_User_Sharing__c;
    Public static final String TRAVEL_APPLICATION_SHARING_RULE_ON_BEHALF_OF_USER_SHARING = Schema.Travel_Application__Share.RowCause.On_Behalf_Of_User_Sharing__c;
    Public static final String JOURNEY_LOG_SHARING_RULE_APPROVER_SHARING = Schema.Journey_Log__Share.RowCause.Approver_Sharing__c;    
    Public static final String EDUCATION_APPLICATION_SHARING_RULE_APPROVER_SHARING = Schema.Education_Application__Share.RowCause.Approver_Sharing__c;
    Public static final String EDUCATION_APPLICATION_SHARING_RULE_ON_BEHALF_OF_USER_SHARING = Schema.Education_Application__Share.RowCause.On_Behalf_Of_User_Sharing__c;    
    Public static final String EXPENSE_APPLICATION_SHARING_RULE_APPROVER_SHARING = Schema.EXPENSE_Application__Share.RowCause.Approver_Sharing__c;
    Public static final String EXPENSE_APPLICATION_SHARING_RULE_ON_BEHALF_OF_USER_SHARING = Schema.EXPENSE_Application__Share.RowCause.On_Behalf_Of_User_Sharing__c;    
    Public static final String EXPENSE_DETAIL_LOG_SHARING_RULE_APPROVER_SHARING = Schema.EXPENSE_DETAIL_LOG__Share.RowCause.Approver_Sharing__c;
    //Public static final String CASH_ADVANCE_SHARING_RULE_APPROVER_SHARING = Schema.CASH_ADVANCE__Share.RowCause.Approver_Sharing__c;
    //Public static final String CASH_ADVANCE_SHARING_RULE_ON_BEHALF_OF_USER_SHARING = Schema.CASH_ADVANCE__Share.RowCause.On_Behalf_Of_User_Sharing__c;
   
    Public Static String travelApplicationapproverSharing = TRAVEL_APPLICATION_SHARING_RULE_APPROVER_SHARING;
    Public Static String travelApplicationcopyTouserSharing = TRAVEL_APPLICATION_SHARING_RULE_MENTION_USER_SHARING;
    Public Static String travelApplicationonBehalfOfuserSharing = TRAVEL_APPLICATION_SHARING_RULE_ON_BEHALF_OF_USER_SHARING;
    Public Static String journeyApplicationapproverSharing = JOURNEY_LOG_SHARING_RULE_APPROVER_SHARING;
    Public Static String educationApplicationapproverSharing = EDUCATION_APPLICATION_SHARING_RULE_APPROVER_SHARING;
    Public Static String educationApplicationonBehalfOfuserSharing = EDUCATION_APPLICATION_SHARING_RULE_ON_BEHALF_OF_USER_SHARING;
    Public Static String expenseApplicationapproverSharing = EXPENSE_APPLICATION_SHARING_RULE_APPROVER_SHARING;
    Public Static String expenseApplicationonBehalfOfuserSharing = EXPENSE_APPLICATION_SHARING_RULE_ON_BEHALF_OF_USER_SHARING ;
    Public Static String expenseDetailLogapproverSharing = EXPENSE_DETAIL_LOG_SHARING_RULE_APPROVER_SHARING;
    //Public Static String cashAdvanceapproverSharing = CASH_ADVANCE_SHARING_RULE_APPROVER_SHARING;
    //Public Static String cashAdvanceOnBehalfOfSharing = CASH_ADVANCE_SHARING_RULE_ON_BEHALF_OF_USER_SHARING;
    public static final String TRAVEL_APPLICATION_APPROVER_ACCESS_RIGHT = 'Read';
    public static final String TRAVEL_APPLICATION_COPY_TO_USER_ACCESS_RIGHT = 'Read';
    public static final String TRAVEL_APPLICATION_ON_BEHALF_OF_USER_ACCESS_RIGHT = 'Edit';
    public static final String JOURNEY_APPROVER_ACCESS_RIGHT = 'Read';
    public static final String EDUCATION_APPLICATION_APPROVER_ACCESS_RIGHT = 'Read';    
    public static final String EDUCATION_APPLICATION_ON_BEHALF_OF_USER_ACCESS_RIGHT = 'Edit';    
    public static final String EXPENSE_APPLICATION_APPROVER_ACCESS_RIGHT = 'Read';    
    public static final String EXPENSE_APPLICATION_ON_BEHALF_OF_USER_ACCESS_RIGHT = 'Edit';    
    public static final String EXPENSE_DETAIL_LOG_APPROVER_ACCESS_RIGHT = 'Read';
    public static final String CASH_ADVANCE_APPROVER_ACCESS_RIGHT = 'Read';
    public static final String CASH_ADVANCE_ON_BEHALF_OF_USER_ACCESS_ACCESS_RIGHT = 'Edit';
    //public static final String APPROVER_ACCESS_RIGHT = 'Edit';
    //public static final String COPY_TO_USER_ACCESS_RIGHT = 'Read';
    
    
    /*@description Travel Request Sharing*/
    public static void TETravelRequestSharing (List<Travel_Application__c> travelRequestList, Boolean removeAllSharing) {
        Set<ID> userIdSet = new Set<ID>();
        Set<ID> requestuserIdSet = null;
        Map <Id, Set<ID>> travelApproverUserMapping = new Map <Id, Set<ID>>();
        Map <Id, Set<ID>> travelCopyToUserMapping = new Map <Id, Set<ID>>();
        Map <ID, user> activeUserMap = null;
        List <Travel_Application__Share> travelApplicationShareList = new List <Travel_Application__Share>();
        List <Travel_Application__Share> toBeDeleteTravelApplicationShareList = new List <Travel_Application__Share>();
        Id userId = null;
        
        for(Travel_Application__c reader : travelRequestList){
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Actual_Approver_1__c);
            //requestuserIdSet.add(reader.Actual_Approver_2__c);
            //requestuserIdSet.add(reader.Actual_Approver_3__c);
            //requestuserIdSet.add(reader.Actual_Approver_4__c);            
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            travelApproverUserMapping.put(reader.id, requestuserIdSet);            
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Copy_to_1__c);
            requestuserIdSet.add(reader.Copy_to_2__c);
            requestuserIdSet.add(reader.Copy_to_3__c);
            requestuserIdSet.add(reader.Copy_to_4__c);
            requestuserIdSet.add(reader.Copy_to_5__c);
            requestuserIdSet.add(reader.Copy_to_6__c);
            requestuserIdSet.add(reader.Copy_to_7__c);
            requestuserIdSet.add(reader.Copy_to_8__c);
            requestuserIdSet.add(reader.Copy_to_9__c);
            requestuserIdSet.add(reader.Copy_to_10__c);
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            travelCopyToUserMapping.put(reader.id, requestuserIdSet);
            if(reader.On_Behalf_Of_UserId__c != reader.ownerId){
                userIdSet.add(reader.On_Behalf_Of_UserId__c);
            }
        }
        if (removeAllSharing){
            for(Travel_Application__Share reader :[select id from Travel_Application__Share where ParentId in :travelApproverUserMapping.KeySet() and RowCause in (:travelApplicationonBehalfOfuserSharing, :travelApplicationapproverSharing, :travelApplicationcopyTouserSharing)]){
                toBeDeleteTravelApplicationShareList.add(reader);
            }
        }
        activeUserMap = activeUsers(userIdSet);
        travelApproverUserMapping = requesetActiveUserMap (travelApproverUserMapping, activeUserMap);
        travelCopyToUserMapping = requesetActiveUserMap (travelCopyToUserMapping, activeUserMap);
        
        for(Id requestId : travelCopyToUserMapping.keySet()){
            for(Id activeuserId : travelCopyToUserMapping.get(requestId)){
                travelApplicationShareList.add(new Travel_Application__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = TRAVEL_APPLICATION_COPY_TO_USER_ACCESS_RIGHT, RowCause = travelApplicationcopyTouserSharing));
            }
        }
        for(Id requestId : travelApproverUserMapping.keySet()){
            for(Id activeuserId : travelApproverUserMapping.get(requestId)){
                travelApplicationShareList.add(new Travel_Application__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = TRAVEL_APPLICATION_APPROVER_ACCESS_RIGHT, RowCause = travelApplicationapproverSharing));
            }
        }
        for(Travel_Application__c reader : travelRequestList){
            if(reader.On_Behalf_Of_UserId__c != null && activeUserMap.containsKey(reader.On_Behalf_Of_UserId__c)){
                travelApplicationShareList.add(new Travel_Application__Share(ParentId = reader.id, UserOrGroupId = reader.On_Behalf_Of_UserId__c, AccessLevel = TRAVEL_APPLICATION_ON_BEHALF_OF_USER_ACCESS_RIGHT, RowCause = travelApplicationonBehalfOfuserSharing ));
            }
        }
        if (!toBeDeleteTravelApplicationShareList.isEmpty()){
            delete toBeDeleteTravelApplicationShareList;
        }
        if (!travelApplicationShareList.isEmpty()){
            insert travelApplicationShareList;
        }
    }
    
    public static void journeyLogSharing (List<Travel_Application__c> travelRequestList, Boolean removeAllSharing) {
        Set<ID> userIdSet = new Set<ID>();
        Set<ID> requestIdSet = new Set<ID>();
        Set<ID> requestuserIdSet = null;
        Map <Id, Set<ID>> journeyLogApproverUserMapping = new Map <Id, Set<ID>>();
        Map <Id, Set<ID>> travelApplicationApproverUserMapping = new Map <Id, Set<ID>>();
        Map <ID, user> activeUserMap = null;
        List <Journey_Log__Share> journeyLogShareList = new List <Journey_Log__Share>();
        List <Journey_Log__Share> toBeDeleteJourneyLogShareList = new List <Journey_Log__Share>();
        Id userId = null;
        
        for(Travel_Application__c reader : travelRequestList){
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Actual_Approver_1__c);
            requestuserIdSet.add(reader.Actual_Approver_2__c);
            requestuserIdSet.add(reader.Actual_Approver_3__c);
            requestuserIdSet.add(reader.Actual_Approver_4__c);
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            requestIdSet.add(reader.id);
            travelApplicationApproverUserMapping.put(reader.id, requestuserIdSet);
        }
        for(Journey_Log__c reader : [select id, Travel_Application__c  from Journey_Log__c where Travel_Application__c in :requestIdSet]){
            journeyLogApproverUserMapping.put(reader.id, travelApplicationApproverUserMapping.get(reader.Travel_Application__c));
        }
        
        if (removeAllSharing){
            for(Journey_Log__Share reader :[select id from Journey_Log__Share where ParentId in :journeyLogApproverUserMapping.KeySet() and RowCause = :journeyApplicationapproverSharing]){
                toBeDeleteJourneyLogShareList.add(reader);
            }
        }
        activeUserMap = activeUsers(userIdSet);
        journeyLogApproverUserMapping = requesetActiveUserMap (journeyLogApproverUserMapping, activeUserMap);
        
        for(Id requestId : journeyLogApproverUserMapping.keySet()){
            for(Id activeuserId : journeyLogApproverUserMapping.get(requestId)){
                JourneyLogShareList.add(new Journey_Log__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = JOURNEY_APPROVER_ACCESS_RIGHT, RowCause = journeyApplicationapproverSharing));
            }
        }
        if (!toBeDeleteJourneyLogShareList.isEmpty()){
            delete toBeDeleteJourneyLogShareList;
        }
        if (!JourneyLogShareList.isEmpty()){
            insert JourneyLogShareList;
        }
    }
    
    /*@description Education Application Sharing*/
    public static void TEEducationApplicationSharing (List<Education_Application__c> educationApplicationList, Boolean removeAllSharing) {
        Set<ID> userIdSet = new Set<ID>();
        Set<ID> requestuserIdSet = null;
        Map <Id, Set<ID>> educationApplicationApproverUserMapping = new Map <Id, Set<ID>>();
        Map <ID, user> activeUserMap = null;
        List <Education_Application__Share> educationApplicationShareList = new List <Education_Application__Share>();
        List <Education_Application__Share> toBeDeleteEducationApplicationShareList = new List <Education_Application__Share>();
        Id userId = null;
        
        for(Education_Application__c reader : educationApplicationList){
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Actual_Approver_1__c);
            requestuserIdSet.add(reader.Actual_Approver_2__c);
            requestuserIdSet.add(reader.Actual_Approver_3__c);
            requestuserIdSet.add(reader.Actual_Approver_4__c);
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            educationApplicationApproverUserMapping.put(reader.id, requestuserIdSet);
            if(reader.On_Behalf_Of_UserId__c != reader.ownerid){
                userIdSet.add(reader.On_Behalf_Of_UserId__c);
            }
        }
        if (removeAllSharing){
            for(Education_Application__Share reader :[select id from Education_Application__Share where ParentId in :educationApplicationApproverUserMapping.KeySet() and RowCause in(:educationApplicationonBehalfOfuserSharing, :educationApplicationapproverSharing)]){
                toBeDeleteEducationApplicationShareList.add(reader);
            }
        }
        activeUserMap = activeUsers(userIdSet);
        educationApplicationApproverUserMapping = requesetActiveUserMap (educationApplicationApproverUserMapping, activeUserMap);
        
        for(Id requestId : educationApplicationApproverUserMapping.keySet()){
            for(Id activeuserId : educationApplicationApproverUserMapping.get(requestId)){
                educationApplicationShareList.add(new Education_Application__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = EDUCATION_APPLICATION_APPROVER_ACCESS_RIGHT, RowCause = educationApplicationapproverSharing));
            }
        }
        for(Education_Application__c reader : educationApplicationList){
            if(reader.On_Behalf_Of_UserId__c != null && reader.On_Behalf_Of_UserId__c != reader.ownerid && activeUserMap.containsKey(reader.On_Behalf_Of_UserId__c)){
                educationApplicationShareList.add(new Education_Application__Share(ParentId = reader.id, UserOrGroupId = reader.On_Behalf_Of_UserId__c, AccessLevel = EDUCATION_APPLICATION_ON_BEHALF_OF_USER_ACCESS_RIGHT, RowCause = educationApplicationonBehalfOfuserSharing));
            }
        }
        if (!toBeDeleteEducationApplicationShareList.isEmpty()){
            delete toBeDeleteEducationApplicationShareList;
        }
        if (!educationApplicationShareList.isEmpty()){
            insert educationApplicationShareList ;
        }
    }
    
    
    /*@description Expense Application Sharing*/
    public static void TEExpenseApplicationSharing (List<Expense_Application__c> expenseApplicationList, Boolean removeAllSharing) {
        Set<ID> userIdSet = new Set<ID>();
        Set<ID> requestuserIdSet = null;
        Map <Id, Set<ID>> expenseApplicationApproverUserMapping = new Map <Id, Set<ID>>();
        Map <Id, expense_Application__c> expenseApplicationMapping = new Map <Id, expense_Application__c>([select id, On_Behalf_Of_UserId__c, On_Behalf_Of__r.Employee_Administrator__r.User__c, On_Behalf_Of__r.Employee__r.User__c, ownerid from expense_Application__c where id in :expenseApplicationList]);
        Map <ID, user> activeUserMap = null;
        List <Expense_Application__Share> expenseApplicationShareList = new List <Expense_Application__Share>();
        List <Expense_Application__Share> toBeDeleteEducationApplicationShareList = new List <Expense_Application__Share>();
        Id userId = null;
        for(Expense_Application__c reader : expenseApplicationList){
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Actual_Approver_1__c);
            requestuserIdSet.add(reader.Actual_Approver_2__c);
            requestuserIdSet.add(reader.Actual_Approver_3__c);
            requestuserIdSet.add(reader.Actual_Approver_4__c);
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            expenseApplicationApproverUserMapping.put(reader.id, requestuserIdSet);
            if(expenseApplicationMapping.get(reader.id).On_Behalf_Of__r.Employee__r.User__c != expenseApplicationMapping.get(reader.id).On_Behalf_Of__r.Employee_Administrator__r.User__c){
                userIdSet.add(expenseApplicationMapping.get(reader.id).On_Behalf_Of__r.Employee__r.User__c);
            }
        }
        if (removeAllSharing){
            for(Expense_Application__Share reader :[select id from Expense_Application__Share where ParentId in :expenseApplicationApproverUserMapping.KeySet() and RowCause in(:expenseApplicationonBehalfOfuserSharing , :expenseApplicationapproverSharing)]){
                toBeDeleteEducationApplicationShareList.add(reader);
            }
        }
        activeUserMap = activeUsers(userIdSet);
        expenseApplicationApproverUserMapping = requesetActiveUserMap (expenseApplicationApproverUserMapping, activeUserMap);
        
        for(Id requestId : expenseApplicationApproverUserMapping.keySet()){
            for(Id activeuserId : expenseApplicationApproverUserMapping.get(requestId)){
                expenseApplicationShareList.add(new Expense_Application__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = EXPENSE_APPLICATION_APPROVER_ACCESS_RIGHT , RowCause = expenseApplicationapproverSharing));
            }
        }
        for(Expense_Application__c reader : expenseApplicationList){
            if(expenseApplicationMapping.get(reader.id).On_Behalf_Of_UserId__c != null && expenseApplicationMapping.get(reader.id).On_Behalf_Of_UserId__c != expenseApplicationMapping.get(reader.id).ownerid && activeUserMap.containsKey(expenseApplicationMapping.get(reader.id).On_Behalf_Of_UserId__c)){
                expenseApplicationShareList.add(new Expense_Application__Share(ParentId = reader.id, UserOrGroupId = expenseApplicationMapping.get(reader.id).On_Behalf_Of_UserId__c, AccessLevel = EXPENSE_APPLICATION_ON_BEHALF_OF_USER_ACCESS_RIGHT, RowCause = expenseApplicationonBehalfOfuserSharing ));
                
            }
        }
        if (!toBeDeleteEducationApplicationShareList.isEmpty()){
            delete toBeDeleteEducationApplicationShareList;
        }
        if (!expenseApplicationShareList.isEmpty()){
            insert expenseApplicationShareList;
        }
    }
    
    /*@description Expense Detail log Sharing*/
    public static void TEExpenseDetailSharing (List<Expense_Detail__c> expenseDetailLogList, Boolean removeAllSharing) {
        Set<ID> userIdSet = new Set<ID>();
        Set<ID> requestuserIdSet = null;
        Map <Id, Set<ID>> expenseDetailApproverUserMapping = new Map <Id, Set<ID>>();
        Map <Id, Set<ID>> expenseDetailLogApproverUserMapping = new Map <Id, Set<ID>>();
        Map <ID, user> activeUserMap = null;
        List <Expense_Detail_Log__Share> expenseDetailLogShareList = new List <Expense_Detail_Log__Share>();
        List <Expense_Detail_Log__Share> toBeDeleteExpenseDetailLogShareList = new List <Expense_Detail_Log__Share>();
        Id userId = null;
        
        for(Expense_Detail__c reader : expenseDetailLogList){
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Actual_Approver_1__c);
            requestuserIdSet.add(reader.Actual_Approver_2__c);
            requestuserIdSet.add(reader.Actual_Approver_3__c);
            requestuserIdSet.add(reader.Actual_Approver_4__c);
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId); 
            }
            expenseDetailApproverUserMapping.put(reader.id, requestuserIdSet);
        }
        
        for(Expense_Detail_log__c reader : [select id, expense_detail__c from Expense_Detail_log__c where expense_detail__c in :expenseDetailApproverUserMapping.keyset()]){
            expenseDetailLogApproverUserMapping.put(reader.id, expenseDetailApproverUserMapping.get(reader.expense_detail__c));
        }
        
        if (removeAllSharing){
            for(Expense_Detail_Log__Share reader :[select id from Expense_Detail_Log__Share where ParentId in :expenseDetailLogApproverUserMapping.KeySet() and RowCause = :expenseDetailLogapproverSharing]){
                toBeDeleteExpenseDetailLogShareList.add(reader);
            }
        }
        activeUserMap = activeUsers(userIdSet);
        expenseDetailLogApproverUserMapping = requesetActiveUserMap (expenseDetailLogApproverUserMapping, activeUserMap);
        
        for(Id requestId : expenseDetailLogApproverUserMapping.keySet()){
            for(Id activeuserId : expenseDetailLogApproverUserMapping.get(requestId)){
                expenseDetailLogShareList.add(new Expense_Detail_Log__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = EXPENSE_DETAIL_LOG_APPROVER_ACCESS_RIGHT , RowCause = expenseDetailLogapproverSharing));
            }
        }
        
        if (!toBeDeleteExpenseDetailLogShareList.isEmpty()){
            delete toBeDeleteExpenseDetailLogShareList;
        }
        if (!expenseDetailLogShareList.isEmpty()){
            insert expenseDetailLogShareList;
        }
    }
    
    
    /*@description Cash Advance Sharing*/
    /*
    public static void TECashAdvanceSharing (List<Travel_Application__c> travelApplicationList, Boolean removeAllSharing) {
        Set<ID> userIdSet = new Set<ID>();
        Set<ID> requestuserIdSet = null;
        Map <Id, Set<ID>> travelApplocationApproverUserMapping = new Map <Id, Set<ID>>();
        Map <Id, Set<ID>> cashAdvanceApproverUserMapping = new Map <Id, Set<ID>>();
        Map <Id, Cash_Advance__c> cashAdvanceMapping = new Map <Id, Cash_Advance__c>();
        Map <ID, user> activeUserMap = null;
        List <Cash_Advance__Share> cashAdvanceShareList = new List <Cash_Advance__Share>();
        List <Cash_Advance__Share> toBeDeleteCashAdvanceShareList = new List <Cash_Advance__Share>();
        Id userId = null;
        for(Travel_Application__c reader : travelApplicationList){
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Actual_Approver_1__c);
            requestuserIdSet.add(reader.Actual_Approver_2__c);
            requestuserIdSet.add(reader.Actual_Approver_3__c);
            requestuserIdSet.add(reader.Actual_Approver_4__c);
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            travelApplocationApproverUserMapping.put(reader.id, requestuserIdSet);
            if(reader.On_Behalf_Of_UserId__c != reader.ownerid){
                userIdSet.add(reader.On_Behalf_Of_UserId__c);
            }
        }
        for(Cash_Advance__c reader : [select id, On_Behalf_Of_UserId__c , Travel_Application__c, Travel_Application__r.ownerid, Travel_Application__r.On_Behalf_Of_UserId__c  from Cash_Advance__c where Travel_Application__c in :travelApplocationApproverUserMapping.keyset()]){
            cashAdvanceApproverUserMapping.put(reader.id, travelApplocationApproverUserMapping.get(reader.Travel_Application__c));
            cashAdvanceMapping.put(reader.id, reader);
        }
        
        if (removeAllSharing){
            for(Cash_Advance__Share reader :[select id from Cash_Advance__Share where ParentId in :cashAdvanceApproverUserMapping.KeySet() and RowCause in (:cashAdvanceapproverSharing, :cashAdvanceOnBehalfOfSharing)]){
                toBeDeleteCashAdvanceShareList.add(reader);
            }
        }
        activeUserMap = activeUsers(userIdSet);
        cashAdvanceApproverUserMapping = requesetActiveUserMap (cashAdvanceApproverUserMapping, activeUserMap);
        
        for(Id requestId : cashAdvanceApproverUserMapping.keySet()){
            for(Id activeuserId : cashAdvanceApproverUserMapping.get(requestId)){
                cashAdvanceShareList.add(new Cash_Advance__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = CASH_ADVANCE_APPROVER_ACCESS_RIGHT, RowCause = cashAdvanceapproverSharing));
            }
        }
        for(Cash_Advance__c reader : cashAdvanceMapping.values()){
            if(reader.Travel_Application__r.On_Behalf_Of_UserId__c != null && reader.Travel_Application__r.ownerid != reader.Travel_Application__r.On_Behalf_Of_UserId__c && activeUserMap.containskey(reader.Travel_Application__r.On_Behalf_Of_UserId__c)){
                cashAdvanceShareList.add(new Cash_Advance__Share(ParentId = reader.id, UserOrGroupId = reader.Travel_Application__r.On_Behalf_Of_UserId__c, AccessLevel = CASH_ADVANCE_ON_BEHALF_OF_USER_ACCESS_ACCESS_RIGHT, RowCause = cashAdvanceOnBehalfOfSharing));
            }
        }
        if (!toBeDeleteCashAdvanceShareList.isEmpty()){
            delete toBeDeleteCashAdvanceShareList;
        }
        if (!cashAdvanceShareList.isEmpty()){
            insert cashAdvanceShareList ;
        }
    }
    */
    /*@description Expense Application Sharing*/
    /*
    public static void TECashAdvanceSharing (List<Cash_Advance__c> cashAdvanceList, Boolean removeAllSharing) {
        Set<ID> userIdSet = new Set<ID>();
        Set<ID> requestuserIdSet = null;
        Map <Id, Set<ID>> cashAdvanceApproverUserMapping = new Map <Id, Set<ID>>();
        Map <ID, user> activeUserMap = null;
        List <Cash_Advance__Share> cashAdvanceShareList = new List <Cash_Advance__Share>();
        List <Cash_Advance__Share> toBeDeleteCashAdvanceShareList = new List <Cash_Advance__Share>();
        Id userId = null;
        
        for(Cash_Advance__c reader : cashAdvanceList){
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Actual_Approver_1__c);
            requestuserIdSet.add(reader.Actual_Approver_2__c);
            requestuserIdSet.add(reader.Actual_Approver_3__c);
            requestuserIdSet.add(reader.Actual_Approver_4__c);
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            cashAdvanceApproverUserMapping.put(reader.id, requestuserIdSet);            
            if(reader.On_Behalf_Of_UserId__c != reader.ownerid){
                userIdSet.add(reader.On_Behalf_Of_UserId__c);
            }
        }
        if (removeAllSharing){
            for(Cash_Advance__Share reader :[select id from Cash_Advance__Share where ParentId in :cashAdvanceApproverUserMapping.KeySet() and RowCause in (:cashAdvanceapproverSharing, :cashAdvanceOnBehalfOfSharing)]){
                toBeDeleteCashAdvanceShareList.add(reader);
            }
        }
        activeUserMap = activeUsers(userIdSet);
        cashAdvanceApproverUserMapping  = requesetActiveUserMap (cashAdvanceApproverUserMapping, activeUserMap);        
        for(Id requestId : cashAdvanceApproverUserMapping.keySet()){
            for(Id activeuserId : cashAdvanceApproverUserMapping.get(requestId)){
                cashAdvanceShareList.add(new Cash_Advance__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = CASH_ADVANCE_APPROVER_ACCESS_RIGHT, RowCause = cashAdvanceapproverSharing));
            }            
        }
        for(Cash_Advance__c reader : cashAdvanceList){
            if(reader.On_Behalf_Of_UserId__c != null && reader.On_Behalf_Of_UserId__c != reader.ownerid && activeUserMap.containskey(reader.On_Behalf_Of_UserId__c)){
                cashAdvanceShareList.add(new Cash_Advance__Share(ParentId = reader.id, UserOrGroupId = reader.On_Behalf_Of_UserId__c, AccessLevel = CASH_ADVANCE_ON_BEHALF_OF_USER_ACCESS_ACCESS_RIGHT, RowCause = cashAdvanceOnBehalfOfSharing));
            }
        }
        if (!toBeDeleteCashAdvanceShareList.isEmpty()){
            delete toBeDeleteCashAdvanceShareList;
        }
        if (!cashAdvanceShareList.isEmpty()){
            insert cashAdvanceShareList;
        }
    }
    */
    
    
    /*@description To Return Request active users*/
    private static Map <Id, Set<Id>> requesetActiveUserMap (Map<Id, Set<Id>> requestUserMapping, Map <Id, user> activeUserMap){
        Map<Id, Set<Id>> requestActiveUsersMap = new Map<Id, Set<Id>>();
        Set<Id> userIdSet = null;

        for (Id key : requestUserMapping.keyset()){
            userIdSet = new Set<Id>();
            for (Id userId : requestUserMapping.get(key)){
                if(activeUserMap.containsKey(userId)){
                    userIdSet.add(userId);
                }
            }
            if (!userIdSet.isempty()){
                requestActiveUsersMap.put(key, userIdSet);
            }
        }
        return requestActiveUsersMap;
    }
    
    
    /*@description To Return active users*/
    private static Map <ID, user> activeUsers (Set<ID> userIdSet){
        return new Map <ID, user>([select id from user where id in :userIdSet and isactive = true]);
    }
}