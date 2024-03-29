public without sharing class LeaveRequestConstant {
    
    /*General*/
    public static final Integer SUNDAY =  0;
    public static final Integer MONDAY =  1;
    public static final Integer TUESDAY =  2;
    public static final Integer WEDNESDAY =  3;
    public static final Integer THURSDAY =  4;
    public static final Integer FRIDAY =  5;
    public static final Integer SATURDAY =  6;
    
    public static final Integer WEEKDAYS =  7;
    public static final Integer MONTHLY =  1;
    public static final Integer ANNIVERSARY = 12;
    public static final Integer HOUR_IN_MINUTES = 60;
    public static final Integer YEAR_IN_MONTHS = 12;
    
    public static final String LEAVE_DeveloperName = 'Leave_Request';
    
    /*Leave Application Object*/
    public static final String LEAVE_APPLICATION_OBJECT_NAME =  'Leave_Application__c';
    public static final String LEAVE_APPLICATION_BATCH =  'B';
    public static final String LEAVE_APPLICATION_INDIVIDUAL =  'I';
     
    
    /*Leave Request Object*/
    public static final String LEAVE_REQUEST_OBJECT_NAME =  'Leave_Request__c';
    public static final String LEAVE_TYPE_LEAVE_REQUEST = 'Leave_Request';
    public static final String LEAVE_TYPE_FLEXIBLE_TIME_REQUEST = 'Flexible_Time_Request';
    
    public static final String STATUS_DRAFT = 'DF';
    public static final String STATUS_NOT_SUBMITTED = 'NS';
    public static final String STATUS_SUBMITTED = 'SM';
    public static final String STATUS_PENDING_APPROVAL = 'PA';
    public static final String STATUS_PENDING_CANCELLATION = 'PC';
    public static final String STATUS_CANCEL_NOT_SUBMITTED = 'CNS';
    public static final String STATUS_CANCELLED = 'CA';
    public static final String STATUS_APPROVED = 'AP';
    public static final String STATUS_REJECT = 'RJ';
    
    /*Holiday Object*/
    public static final String HOLIDAY_TYPE = 'H';
    public static final String EARLY_RELEASE_TYPE = 'E';
    
    /*Leave Policy Object*/
    public static final String LEAVE_POLICY_PERIOD_FREQUENCY_MONTHLY  = 'M';
    public static final String LEAVE_POLICY_PERIOD_FREQUENCY_ANNIVERSARY = 'A';
    
    /*Leave Request Log Object*/
    public static final String LEAVE_REQUEST_LOG_TYPE_CANCELLATION = 'Cancellation';
    public static final String LEAVE_REQUEST_LOG_TYPE_ADJUSTMENT = 'Adjustment';
    public static final String LEAVE_REQUEST_LOG_TYPE_LEAVE_REQUEST = 'Leave_Request';
    public static final String LEAVE_REQUEST_LOG_TYPE_PENDING_APPROVAL = 'Leave_Request_Pending_Approval';
    
    /*Leave Application Log*/
    public static final String ALREADY_ON_LEAVE= 'A';    
    public static final String NEGATIVE_BALANCE= 'N';
    
    //Added by TAL (Twinkle Li) @20170816
    /*Leave Type*/
    public static final String LEAVE_TYPE_TRAVEL_COMPENSATION_LEAVE = 'Travel Compensation Leave';
    
    /*holds the locale to timedate formats*/
    /*
    public static final  Map<String, String> LOCALEDATETIMEMAP = new Map<String, String>
    {
        'ar'         => 'dd/MM/yyyy hh:mm a',
        'ar_AE'      => 'dd/MM/yyyy hh:mm a',
        'ar_BH'      => 'dd/MM/yyyy hh:mm a',
        'ar_JO'      => 'dd/MM/yyyy hh:mm a',
        'ar_KW'      => 'dd/MM/yyyy hh:mm a',
        'ar_LB'      => 'dd/MM/yyyy hh:mm a',
        'ar_SA'      => 'dd/MM/yyyy hh:mm a',
        'bg_BG'      => 'yyyy-M-d H:mm',
        'ca'         => 'dd/MM/yyyy HH:mm',
        'ca_ES'      => 'dd/MM/yyyy HH:mm',
        'ca_ES_EURO' => 'dd/MM/yyyy HH:mm',
        'cs'         => 'd.M.yyyy H:mm',
        'cs_CZ'      => 'd.M.yyyy H:mm',
        'da'         => 'dd-MM-yyyy HH:mm',
        'da_DK'      => 'dd-MM-yyyy HH:mm',
        'de'         => 'dd.MM.yyyy HH:mm',
        'de_AT'      => 'dd.MM.yyyy HH:mm',
        'de_AT_EURO' => 'dd.MM.yyyy HH:mm',
        'de_CH'      => 'dd.MM.yyyy HH:mm',
        'de_DE'      => 'dd.MM.yyyy HH:mm',
        'de_DE_EURO' => 'dd.MM.yyyy HH:mm',
        'de_LU'      => 'dd.MM.yyyy HH:mm',
        'de_LU_EURO' => 'dd.MM.yyyy HH:mm',
        'el_GR'      => 'd/M/yyyy h:mm a',
        'en_AU'      => 'd/MM/yyyy HH:mm',
        'en_B'       => 'M/d/yyyy h:mm a',
        'en_BM'      => 'M/d/yyyy h:mm a',
        'en_CA'      => 'dd/MM/yyyy h:mm a',
        'en_GB'      => 'dd/MM/yyyy HH:mm',
        'en_GH'      => 'M/d/yyyy h:mm a',
        'en_ID'      => 'M/d/yyyy h:mm a',
        'en_IE'      => 'dd/MM/yyyy HH:mm',
        'en_IE_EURO' => 'dd/MM/yyyy HH:mm',
        'en_NZ'      => 'd/MM/yyyy HH:mm',
        'en_SG'      => 'M/d/yyyy h:mm a',
        'en_US'      => 'M/d/yyyy h:mm a',
        'en_ZA'      => 'yyyy/MM/dd hh:mm a',
        'es'         => 'd/MM/yyyy H:mm',
        'es_AR'      => 'dd/MM/yyyy HH:mm',
        'es_BO'      => 'dd-MM-yyyy hh:mm a',
        'es_CL'      => 'dd-MM-yyyy hh:mm a',
        'es_CO'      => 'd/MM/yyyy hh:mm a',
        'es_CR'      => 'dd/MM/yyyy hh:mm a',
        'es_EC'      => 'dd/MM/yyyy hh:mm a',
        'es_ES'      => 'd/MM/yyyy H:mm',
        'es_ES_EURO' => 'd/MM/yyyy H:mm',
        'es_GT'      => 'd/MM/yyyy hh:mm a',
        'es_HN'      => 'MM-dd-yyyy hh:mm a',
        'es_MX'      => 'd/MM/yyyy hh:mm a',
        'es_PE'      => 'dd/MM/yyyy hh:mm a',
        'es_PR'      => 'MM-dd-yyyy hh:mm a',
        'es_PY'      => 'dd/MM/yyyy hh:mm a',
        'es_SV'      => 'MM-dd-yyyy hh:mm a',
        'es_UY'      => 'dd/MM/yyyy hh:mm a',
        'es_VE'      => 'dd/MM/yyyy hh:mm a',
        'et_EE'      => 'd.MM.yyyy H:mm',
        'fi'         => 'd.M.yyyy H:mm',
        'fi_FI'      => 'd.M.yyyy H:mm',
        'fi_FI_EURO' => 'd.M.yyyy H:mm',
        'fr'         => 'dd/MM/yyyy HH:mm',
        'fr_BE'      => 'd/MM/yyyy H:mm',
        'fr_CA'      => 'yyyy-MM-dd HH:mm',
        'fr_CH'      => 'dd.MM.yyyy HH:mm',
        'fr_FR'      => 'dd/MM/yyyy HH:mm',
        'fr_FR_EURO' => 'dd/MM/yyyy HH:mm',
        'fr_LU'      => 'dd/MM/yyyy HH:mm',
        'fr_MC'      => 'dd/MM/yyyy HH:mm',
        'hr_HR'      => 'yyyy.MM.dd HH:mm',
        'hu'         => 'yyyy.MM.dd. H:mm',
        'hy_AM'      => 'M/d/yyyy h:mm a',
        'is_IS'      => 'd.M.yyyy HH:mm',
        'it'         => 'dd/MM/yyyy H.mm',
        'it_CH'      => 'dd.MM.yyyy HH:mm',
        'it_IT'      => 'dd/MM/yyyy H.mm',
        'iw'         => 'HH:mm dd/MM/yyyy',
        'iw_IL'      => 'HH:mm dd/MM/yyyy',
        'ja'         => 'yyyy/MM/dd H:mm',
        'ja_JP'      => 'yyyy/MM/dd H:mm',
        'kk_KZ'      => 'M/d/yyyy h:mm a',
        'km_KH'      => 'M/d/yyyy h:mm a',
        'ko'         => 'yyyy. M. d a h:mm',
        'ko_KR'      => 'yyyy. M. d a h:mm',
        'lt_LT'      => 'yyyy.M.d HH.mm',
        'lv_LV'      => 'yyyy.d.M HH:mm',
        'ms_MY'      => 'dd/MM/yyyy h:mm a',
        'nl'         => 'd-M-yyyy H:mm',
        'nl_BE'      => 'd/MM/yyyy H:mm',
        'nl_NL'      => 'd-M-yyyy H:mm',
        'nl_SR'      => 'd-M-yyyy H:mm',
        'no'         => 'dd.MM.yyyy HH:mm',
        'no_NO'      => 'dd.MM.yyyy HH:mm',
        'pl'         => 'yyyy-MM-dd HH:mm',
        'pt'         => 'dd-MM-yyyy H:mm',
        'pt_AO'      => 'dd-MM-yyyy H:mm',
        'pt_BR'      => 'dd/MM/yyyy HH:mm',
        'pt_PT'      => 'dd-MM-yyyy H:mm',
        'ro_RO'      => 'dd.MM.yyyy HH:mm',
        'ru'         => 'dd.MM.yyyy H:mm',
        'sk_SK'      => 'd.M.yyyy H:mm',
        'sl_SI'      => 'd.M.y H:mm',
        'sv'         => 'yyyy-MM-dd HH:mm',
        'sv_SE'      => 'yyyy-MM-dd HH:mm',
        'th'         => 'M/d/yyyy h:mm a',
        'th_TH'      => 'd/M/yyyy => H:mm ?.',
        'tr'         => 'dd.MM.yyyy HH:mm',
        'ur_PK'      => 'M/d/yyyy h:mm a',
        'vi_VN'      => 'HH:mm dd/MM/yyyy',
        'zh'         => 'yyyy-M-d ah:mm',
        'zh_CN'      => 'yyyy-M-d ah:mm',
        'zh_HK'      => 'yyyy-M-d ah:mm',
        'zh_TW'      => 'yyyy/M/d a h:mm'
    };
    //*/ 
}