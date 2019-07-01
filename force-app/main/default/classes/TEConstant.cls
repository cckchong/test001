public without sharing class TEConstant {

     /*TE Application Object*/
     public static final String EDUCATION_APPLICATION_OBJECT_NAME =  'Education_Application__c';
     public static final String EXPENSE_APPLICATION_OBJECT_NAME =  'Expense_Application__c';
     public static final String TRAVEL_APPLICATION_OBJECT_NAME =  'Travel_Application__c';
     public static final String JOURNEY_APPLICATION_OBJECT_NAME =  'Journey__c';
     public static final String EXPENSE_DETAIL_OBJECT_NAME =  'Expense_Detail__c';
     public static final String EXPENSE_DETAIL_LOG_OBJECT_NAME =  'Expense_Detail_Log__c';
     public static final String CASH_ADVANCE_OBJECT_NAME = 'Cash_Advance__c';
    
     /*Developer Name*/
     public static final String JOURNEY_AIR_DEVELOPERNAME = 'Air';
     public static final String JOURNEY_SURFACE_DEVELOPERNAME = 'Surface';
     public static final String JOURNEY_COMPANYCAR_DEVELOPERNAME = 'Company_Car';
     
     /*Education Application Object*/
     public static final String EDUCATION_APPLICATION_EDUCATION = 'Education';
     public static final String EDUCATION_APPLICATION_CHILD_EDUCATION = 'Child_Education';
     
     /*Expense Application Object*/
     public static final String EXPENSE_APPLICATION_EXPENSE_APPLICATION = 'Expense_Application';
     public static final String EXPENSE_APPLICATION_RECORD_TYPE_EDUCATION_EXPENSES = 'Education_Expenses';
     public static final String EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES = 'General_Expenses';
     public static final String EXPENSE_APPLICATION_RECORD_TYPE_TRAVEL_EXPENSES = 'Travel_Expenses';
    
     /*Expense Detail Object*/
     public static final String EXPENSE_DETAIL_EXPENSE_DETAIL = 'Expense_Detail';
     public static final String EXPENSE_DETAIL_RECORD_TYPE_EDUCATION_EXPENSES = 'Education_Expenses';
     public static final String EXPENSE_DETAIL_RECORD_TYPE_GENERAL_EXPENSES = 'General_Expenses';
     public static final String EXPENSE_DETAIL_RECORD_TYPE_TRAVEL_EXPENSES = 'Travel_Expenses';
    
     /*Expense Type*/
     public static final String EXPENSE_TYPE_HOTEL = 'Hotel';
     public static final String EXPENSE_TYPE_MEAL = 'Meal';
     public static final String EXPENSE_TYPE_HEALTH = 'Health';
     
     
     /*Travel Application Object*/
     public static final String TRAVEL_APPLICATION_TRAVEL_APPLICATION = 'Travel_Application';
     public static final String TRAVEL_APPLICATION_BATCH =  'B';
     public static final String TRAVEL_APPLICATION_INDIVIDUAL =  'I';
     public static final String TRAVEL_APPLICATION_JOURNEY_TYPE_RETURN =  'R';
     public static final String TRAVEL_APPLICATION_JOURNEY_TYPE_ONE_WAY =  'O';
     public static final String TRAVEL_APPLICATION_JOURNEY_TYPE_MUTI_CITY =  'M';


     /*Travel Detail Object*/
     public static final String TRAVEL_DETAIL_RECORD_TYPE_AIR = 'Air';
     public static final String TRAVEL_DETAIL_RECORD_TYPE_SHUTTLE = 'Shuttle';
     public static final String TRAVEL_DETAIL_RECORD_TYPE_SURFACE = 'Surface';

     /*Travel Application Type Object*/
     public static final String TRAVEL_APPLICATION_TYPE_GENERAL_TRAVEL = 'General Travel';
     public static final String TRAVEL_APPLICATION_TYPE_SHUTTLE_TO_TAA = 'Shuttle to TAA';

     /*Travel Option Object*/
     Public Static String TRAVEL_OPTION_TYPE_AIR_TICKET = 'A';
     Public Static String TRAVEL_OPTION_TYPE_HOTEL = 'H';
    
     /*Travel Distance Application Object*/
     public static final String TRAVEL_DISTANCE = 'Travel_Distance';
    
     /*Travel Location Application Object*/
     public static final String TRAVEL_LOCATION_OBJECT_NAME = 'Travel_Location__c';
     public static final String TRAVEL_LOCATION_TRAVEL_LOCATION = 'Travel_Location';
    
     /*GHG Factor Application Object*/
     public static final String GHG_FACTOR = 'GHG_Factor';
    
     /*Carbon Emission Application Object*/
     public static final String CARBON_EMISSION_OBJECT_NAME = 'Carbon_Emission__c';
     public static final String CARBON_EMISSION_CARBON_EMISSION = 'Carbon_Emission';
    
     /*Travel Distance Application Object*/
     public static final String TRAVEL_DISTANCE_OBJECT_NAME = 'Travel_Distance__c';
     public static final String TRAVEL_DISTANCE_TRAVEL_DISTANCE = 'Travel_Distance';
    
     /*GHG Factor Application Object*/
     public static final String GHG_FACTOR_OBJECT_NAME = 'Ghg_Factor__c';
     public static final String GHG_FACTOR_GHG_FACTOR = 'GHG_Factor';
    
     /*Travel Application Cancellation Controller*/
     public static final String TRAVELAPPLICATIONIDCODE = '@TaID';
    
     /*Education Application Cancellation Controller*/
     public static final String EDUCATIONAPPLICATIONIDCODE = '@EaID';
    
     /*TE Education Application Trigger*/
     public static final String EDUCATION_APPLICATION_EMAIL = 'no-reply@salesforce.com';
     public static final String EDUCATION_APPLICATION_EMAIL_NAME = 'Education Application Approval Process';
    
     /*Education Application Approval Process: Queue*/
     public static final String EDUCATION_HCM_HKO = 'EDUCATION_HCM_HKO';
    
     /*Education Application Approval Process: email template*/
     public static final String EDUCATION_APPLICATION_STATUS_CHANGED_EMAIL_TEMPLATE = 'EducationApplicationStatusChanged';

     /*Status for all T&E*/
     public static final String STATUS_DRAFT = 'DF';
     public static final String STATUS_NOT_SUBMITTED = 'NS';
     public static final String STATUS_SUBMITTED = 'SM';
     public static final String STATUS_PENDING_APPROVAL = 'PA';
     public static final String STATUS_PENDING_ITINERARY = 'PI';
     public static final String STATUS_PENDING_HCM_APPROVAL = 'PH';
     public static final String STATUS_PENDING_SITE_APPROVAL = 'PS';
     public static final String STATUS_PENDING_CANCELLATION = 'PC';
     public static final String STATUS_CANCEL_NOT_SUBMITTED = 'CNS';
     public static final String STATUS_CANCELLED = 'CN';
     public static final String STATUS_APPROVED = 'AP';
     public static final String STATUS_REJECT = 'RJ';
     
     /*Status for Travel Application Details*/
     public static final String STATUS_PENDING = 'PE';
     public static final String STATUS_PENDING_ARRANGEMENT = 'PAR';
     public static final String STATUS_PENDING_SELECTION = 'PSE';
     public static final String STATUS_PENDING_RESERVATION = 'PR';
     public static final String STATUS_COMPLETE = 'CP';
     
     /*Status for Expense Detail*/
    public static final String STATUS_PENDING_FIN_Confirmation = 'PF';
    public static final String STATUS_PENDING_APPLICANT_CONFIRMATION = 'PAC';
    public static final String STATUS_CONFIRMATION_NOT_SUBMITTED = 'CONNS';
    public static final String STATUS_CONFIRMED = 'CON';
    public static final String STATUS_CLOSED_NOT_SUBMITTED = 'CLDNS';
    public static final String STATUS_CLOSED = 'CLD';
    
    /*Status for Cash Advance*/
    public static final String STATUS_OPEN = 'OP';
    public static final String STATUS_PAID_OUT = 'PO';
    public static final String STATUS_PAID_OUT_NOT_SUBMITTED = 'PONS';
    public static final String STATUS_RETURN_NOT_SUBMITTED = 'RUNS';
    public static final String STATUS_RETURN = 'RU';
    public static final String STATUS_REJECT_NOT_SUBMITTED = 'RJNS';
    
    /*Status for Expense Detail Log*/
    /*ED for Expense Detail; CA for Cash Advance*/
    public static final String STATUS_ED_NOT_SUBMITTED = 'Expense_Detail_Not_Submitted';
    public static final String STATUS_ED_PENDING_APPROVAL = 'Expense_Detail_Pending_Approval';
    public static final String STATUS_ED_PENDING_FINANCE = 'Expense_Detail_Pending_Finance';
    public static final String STATUS_ED_PENDING_APPLICANT = 'Expense_Detail_Pending_Applicant';
    public static final String STATUS_ED_CONFIRMED = 'Expense_Detail_Confirmed';
    public static final String STATUS_ED_CLOSED = 'Expense_Detail_Closed';
    public static final String STATUS_ED_CANCELLED = 'Expense_Detail_Cancelled';
    public static final String STATUS_CA_NOT_SUBMITTED = 'Cash_Advance_Not_Submitted';
    public static final String STATUS_CA_PENDING_APPROVAL = 'Cash_Advance_Pending_Approval';
    public static final String STATUS_CA_OPEN = 'Cash_Advance_Open';
    public static final String STATUS_CA_PAID_OUT = 'Cash_Advance_Paid_Out';
    public static final String STATUS_CA_TO_BE_RETURNED = 'Cash_Advance_To_Be_Returned';
    public static final String STATUS_CA_CANCELLED = 'Cash_Advance_Cancelled';
    public static final String STATUS_CA_CLOSED = 'Cash_Advance_Closed';

    /*TE Public Group Format*/
    public static final String FIN_PUBLIC_GROUP = 'TE_@_FIN'; 
    public static final String ADMIN_PUBLIC_GROUP = 'TE_@_ADMIN'; 
    
    /*TE Exchange Rate*/
    public static final String EXCHANGE_RATE_TYPE_BOOK_RATE = 'BK';
    public static final String EXCHANGE_RATE_TYPE_BUDGET_RATE = 'BU';

    /*Custom Permission*/
    Public Static final String CUSTOM_PERMISSION_TE_ADMIN = 'TE_Is_Admin';
    Public Static final String CUSTOM_PERMISSION_TE_TRAVEL_AGENT = 'TE_Is_Travel_Agent';

    /*Accommodation Accommodation by Picklist value*/
    Public Static final String ACCOMMODATION_BY_SITE_ADMIN = 'Site Admin';
    Public Static final String ACCOMMODATION_BY_TRAVEL_AGENCY = 'Travel Agency';
    
    /*Sharing Rule Reason*/
    
    /*
    Public static final String TRAVEL_APPLICATION_SHARING_RULE_APPROVER_SHARING = Schema.Travel_Application__Share.RowCause.Approver_Sharing__c;
    Public static final String TRAVEL_APPLICATION_SHARING_RULE_MENTION_USER_SHARING = Schema.Travel_Application__Share.RowCause.Mention_User_Sharing__c;
    Public static final String TRAVEL_APPLICATION_SHARING_RULE_ON_BEHALF_OF_USER_SHARING = Schema.Travel_Application__Share.RowCause.On_Behalf_Of_User_Sharing__c;
    Public static final String JOURNEY_LOG_SHARING_RULE_APPROVER_SHARING = Schema.Journey_Log__Share.RowCause.Approver_Sharing__c;    
    Public static final String EDUCATION_APPLICATION_SHARING_RULE_APPROVER_SHARING = Schema.Education_Application__Share.RowCause.Approver_Sharing__c;
    Public static final String EDUCATION_APPLICATION_SHARING_RULE_ON_BEHALF_OF_USER_SHARING = Schema.Education_Application__Share.RowCause.On_Behalf_Of_User_Sharing__c;    
    Public static final String EXPENSE_APPLICATION_SHARING_RULE_APPROVER_SHARING = Schema.EXPENSE_Application__Share.RowCause.Approver_Sharing__c;
    Public static final String EXPENSE_APPLICATION_SHARING_RULE_ON_BEHALF_OF_USER_SHARING = Schema.EXPENSE_Application__Share.RowCause.On_Behalf_Of_User_Sharing__c;    
    Public static final String EXPENSE_DETAIL_LOG_SHARING_RULE_APPROVER_SHARING = Schema.EXPENSE_DETAIL_LOG__Share.RowCause.Approver_Sharing__c;
    Public static final String CASH_ADVANCE_SHARING_RULE_APPROVER_SHARING = Schema.CASH_ADVANCE__Share.RowCause.Approver_Sharing__c;
    Public static final String CASH_ADVANCE_SHARING_RULE_ON_BEHALF_OF_USER_SHARING = Schema.CASH_ADVANCE__Share.RowCause.On_Behalf_Of_User_Sharing__c;
    */
    
    /*Organization Wide Email*/
    Public static final String ORGANIZATION_WIDE_EMAIL_NAME = 'Salesforce Admin';

    /*Email Template*/
    Public static final String TRAVEL_APPLICATION_TRAVEL_AGENT_EMAIL_TEMPLATE = 'TravelApplicationTravelAgency';
    Public static final String TRAVEL_APPLICATION_LOCAL_ADMIN_EMAIL_TEMPLATE = 'TravelApplicationLocalAdmin';

    
    public static Integer getExpenseStep(String status) {
        Integer Step;
        if (status == STATUS_DRAFT) {
            Step = 1;
        } else if (status == STATUS_NOT_SUBMITTED) {
            Step = 2;
        } else if (status == STATUS_PENDING_APPROVAL || status == STATUS_PENDING_HCM_APPROVAL|| status == STATUS_PENDING_SITE_APPROVAL) {
            Step = 3;
        } else if (status == STATUS_PENDING_FIN_Confirmation) {
            Step = 4;
        } else if (status == STATUS_PENDING_APPLICANT_CONFIRMATION) {
            Step = 5;
        } else if (status == STATUS_CONFIRMATION_NOT_SUBMITTED) {
            Step = 6;
        } else if (status == STATUS_CONFIRMED) {
            Step = 7;
        } else if (status == STATUS_CANCEL_NOT_SUBMITTED) {
            Step = 8;
        } else if (status == STATUS_CLOSED_NOT_SUBMITTED) {
            Step = 9;
        }else if (status == STATUS_CANCELLED) {
            Step = 10;
        } else if (status == STATUS_REJECT) {
            Step = 11;
        } else if (status == STATUS_CLOSED) {
            Step = 12;
        } else {
            Step = 13;
        }
        return Step;
    }
    
    public static Integer getCashAdvanceStep(String status) {
        Integer Step;
        if (status == STATUS_DRAFT) {
            Step = 1;
        } else if (status == STATUS_NOT_SUBMITTED) {
            Step = 2;
        } else if (status == STATUS_PENDING) {
            Step = 3;
        } else if (status == STATUS_OPEN) {
            Step = 4;
        } else if (status == STATUS_PAID_OUT_NOT_SUBMITTED) {
            Step = 5;
        } else if (status == STATUS_PAID_OUT) {
            Step = 6;
        } else if (status == STATUS_CANCEL_NOT_SUBMITTED) {
            Step = 7;
        } else if (status == STATUS_RETURN_NOT_SUBMITTED) {
            Step = 8;
        } else if (status == STATUS_CANCELLED) {
            Step = 9;
        } else if (status == STATUS_REJECT) {
            Step = 10;
        } else if (status == STATUS_CLOSED) {
            Step = 11;
        } else {
            Step = 12;
        }
        return Step;
    }
    
    public static Integer getTravelApplicationStep(String status) {
        Integer Step;
        if (status == STATUS_DRAFT) {
            Step = 1;
        } else if (status == STATUS_NOT_SUBMITTED) {
            Step = 2;
        /**
        } else if (status == STATUS_PENDING_ITINERARY) {
            Step = 3;
        } else if (status == STATUS_PENDING_APPROVAL) {
            Step = 4;
        } else if (status == STATUS_CANCEL_NOT_SUBMITTED) {
            Step = 5;
        } else if (status == STATUS_APPROVED) {
            Step = 6;
        } else if (status == STATUS_REJECT) {
            Step = 7;
        } else if (status == STATUS_CANCELLED) {
            Step = 8;
        } else {
            Step = 9;
        }
        **/
        } else if (status == STATUS_PENDING) {
            Step = 3;
        } else if (status == STATUS_CONFIRMED) {
            Step = 4;
        } else if (status == STATUS_CANCEL_NOT_SUBMITTED) {
            Step = 5;
        } else if (status == STATUS_CANCELLED) {
            Step = 6;
        } else if (status == STATUS_COMPLETE) {
            Step = 7;
        }else {
            Step = 8;
        }
        return Step;
    }
    
    public static Integer getEducationApplicationStep(String status) {
        Integer Step;
        if (status == STATUS_DRAFT) {
            Step = 1;
        } else if (status == STATUS_NOT_SUBMITTED) {
            Step = 2;
        } else if (status == STATUS_PENDING_APPROVAL) {
            Step = 3;
        } else if (status == STATUS_PENDING_HCM_APPROVAL) {
            Step = 4;
        } else if (status == STATUS_PENDING_APPLICANT_CONFIRMATION) {
            Step = 5;
        } else if (status == STATUS_CANCEL_NOT_SUBMITTED) {
            Step = 6;
        } else if (status == STATUS_APPROVED) {
            Step = 7;
        } else if (status == STATUS_REJECT) {
            Step = 8;
        } else if (status == STATUS_CANCELLED) {
            Step = 9;
        } else {
            Step = 10;
        }
        return Step;
    }

}