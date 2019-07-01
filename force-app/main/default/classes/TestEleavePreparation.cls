public virtual class TestEleavePreparation
{
    public Static final String USER_GLOBAL = 'Far East';
    public Static final String USER_REGION = 'CORP';
    public Static final String USER_LOCAL = 'en_US';
    public Static final String USER_GRADE = '21';
    public Static final String USER_DEPT = 'IT';
    public Static final String USER_FUNCTION = '';
    public Static final String USER_LANG = 'en';
    public Static final String USER_ADMIN_REGION = 'Far East;CORP;TAL';
    public Static final String USER_ADMIN_DEPT = 'IT;HKHCM';        
    public Static final Boolean USER_CREATE_PAGE = true;
    public Static final String USER_PHYSICAL_DELIVERY_ADDRESS = 'HKO';
    public Static final String EMPLOYEE_GRADE = '15';        
    public Profile systemAdminprofile {get;set;}
    public Map <String, Locale_DateTime_Format__c> LocaleDateTimeFormatMap {get;set;}
    public Map <String, Leave_policy__c> LeavepolicyMap {get;set;}
    public Map <String, Time_Set__c> TimeSetMap {get;set;}
    public Map <String, Leave_Type__c> LeaveTypeMap {get;set;}
    public Map <String, Leave_Available_Time__c> LeaveAvailableTimeMap {get;set;}
    public Map <String, Holiday__c> HolidayMap {get;set;}
    public Map <String, Employee_Type__c> EmployeeTypeMap {get;set;}
    public Map <String, Site__c> SiteMap {get;set;}
    public List <Leave_balance__c> LeaveBalanceList {get;set;}
    public String stringLeaveRequestHeaderRecordType {get;set;}
    public String stringLeaveRequestlineRecordType {get;set;}
    public String stringFlexibleLeaveRequestlineRecordType{get;set;}
    public Boolean isSeeAllData;
   
    
    public TestEleavePreparation( Boolean isSeeAllData ){
        this.isSeeAllData = isSeeAllData;
        this.LocaleDateTimeFormatMap = new Map <String, Locale_DateTime_Format__c>(); 
        this.LeavepolicyMap = new Map <String, Leave_policy__c>(); 
        this.TimeSetMap = new Map <String, Time_Set__c>(); 
        this.LeaveTypeMap = new Map <String, Leave_Type__c>(); 
        this.LeaveAvailableTimeMap = new Map <String, Leave_Available_Time__c>(); 
        this.HolidayMap = new Map <String, Holiday__c>();
        this.EmployeeTypeMap = new Map <String, Employee_Type__c>();
        this.LeaveBalanceList = new List <Leave_balance__c>();
        this.SiteMap = new Map <String, Site__c>();
        this.stringLeaveRequestHeaderRecordType = '';
        this.stringLeaveRequestlineRecordType = '';
        this.stringFlexibleLeaveRequestlineRecordType = '';
        
    }
    
    public  user userCreation ( string userAlias, String userEmail, Id userProfileId, String userGlobal, String userRegion, String userLocal, String userGrade, String userDept, String userFunction, String userLang, String userAdminRegion, String userAdminDept, Boolean userCreatePage )
    {
        return 
        new User 
        (
            Alias = userAlias, Email = userEmail , 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = userProfileId , 
            TimeZoneSidKey = 'America/Los_Angeles', UserName = userEmail , 
            Location_Global__c = userGlobal  , 
            Location_Region__c = userRegion,
            Location_Local__c = userLocal,
            Grade__c = userGrade,
            Department__c = userDept,
            Function__c = userFunction ,
            Portal_Language__c = userLang,
            Administrative_Regions__c = userAdminRegion,
            Administrative_Department__c = userAdminDept,
            Create_Portal_Page__c = userCreatePage

        );        
    }
   
    public void basicSetting ()
    {
        List <Locale_DateTime_Format__c> LocaleDateTimeFormatList = new List <Locale_DateTime_Format__c>(); 
        List <Leave_policy__c> LeavepolicyList = new List <Leave_policy__c>(); 
        List <Leave_Type__c> LeaveTypeList = new List <Leave_Type__c>();
        List <Leave_Available_Time__c > LeaveAvailableTimeList = new List <Leave_Available_Time__c >();
        List <Holiday__c> HolidayList = new List <Holiday__c>();
        List <Employee_Type__c> employeeTypeList = new List <Employee_Type__c>();
        
        
        /*Record Type*/
        for ( RecordType reader :  
            [ 
                SELECT Id, SobjectType, DeveloperName 
                FROM RecordType 
                WHERE DeveloperName IN (:LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST, :LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST )
                AND SobjectType IN ( :LeaveRequestConstant.LEAVE_APPLICATION_OBJECT_NAME, :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME ) 
            ]){                    
                if ( reader.SobjectType == LeaveRequestConstant.LEAVE_APPLICATION_OBJECT_NAME ) {
                    stringLeaveRequestHeaderRecordType = reader.Id;                
                } else if ( reader.SobjectType == LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME && reader.DeveloperName == LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST ) {
                    stringLeaveRequestlineRecordType = reader.Id;                
                } else if ( reader.SobjectType == LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME && reader.DeveloperName == LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST ) {
                    stringFlexibleLeaveRequestlineRecordType= reader.Id;                
                }
        }
        
        /*Date Time Format Setting*/
        Locale_DateTime_Format__c LocaleDateTimeFormat = new Locale_DateTime_Format__c(
            Locale__c = 'en_US',
            Name = 'en_US',
            Datetime_Format__c = 'M/d/yyyy h:mm a',
            Date_Format__c = 'M/d/yyyy'
        );
        LocaleDateTimeFormatList.add(LocaleDateTimeFormat );
        if ( !isSeeAllData ) { 
            insert LocaleDateTimeFormatList;
        }
        
        for ( Locale_DateTime_Format__c reader : 
            [
                 select id, Locale__c, Datetime_Format__c, Date_Format__c, Name                 
                 from Locale_DateTime_Format__c    
        ]){
            LocaleDateTimeFormatMap.put (reader.name, reader);
        }
        
        /*Site*/
        Site__c site = new Site__c ( name = 'HKOT', Site_ID__c = 'HKOT' );
        insert site;        
        SiteMap.put(site.name, site); 
        
        /*Leave Policy Setting*/
        Leave_Policy__c LeavePolicy = new Leave_Policy__c (
            Leave_Soft_Doc_Require__c = true,
            Time_Zone_Offset__c = 8,
            Leave_Hard_Doc_Require__c = true,
            Period_Frequency__c = 'A',
            Name = 'HKO'
        );
        LeavepolicyList.add(LeavePolicy);
        insert LeavepolicyList;
        
        for ( Leave_Policy__c reader : 
            [
                 select id, Leave_Soft_Doc_Require__c , Time_Zone_Offset__c , Leave_Hard_Doc_Require__c,
                 Period_Frequency__c, Name 
                 from Leave_Policy__c 
        ]){
            LeavepolicyMap.put ( reader.name, reader );
        }
        
        /*TimeSet Setting*/
        //SELECT Time_Set_ID__c, Leave_Policy__c, MonStartTime1__c, MonEndTime1__c, FriEndTime1__c, FriStartTime1__c, SatEndTime1__c, SatStartTime1__c, FriEndTime2__c, FriStartTime2__c, MonEndTime2__c, SatStartTime2__c, MonStartTime2__c, SatEndTime2__c, SunEndTime1__c, WedStartTime2__c, TueEndTime1__c, SunEndTime2__c, SunStartTime2__c, SunStartTime1__c, ThuEndTime1__c, ThuEndTime2__c, WedStartTime1__c, ThuStartTime1__c, ThuStartTime2__c, TueEndTime2__c, TueStartTime1__c, TueStartTime2__c, WedEndTime1__c, WedEndTime2__c, Is_Mon_Available__c, Is_Thu_Available__c, Is_Wed_Available__c, Is_Tue_Available__c, Is_Fri_Available__c, Is_Sat_Available__c, Is_Sun_Available__c FROM Time_Set__c
        Time_Set__c TimeSet = new Time_Set__c (
            Time_Set_ID__c = 'HKO_TS1A', 
            Name = 'HKO_TS1',
            Leave_Policy__c = LeavepolicyMap.get('HKO').id,
            MonStartTime1__c = '09:00',
            MonEndTime1__c = '13:00',
            ThuStartTime1__c = '09:00',
            ThuEndTime1__c = '13:00',            
            WedStartTime1__c = '09:00',
            WedEndTime1__c = '13:00',
            TueStartTime1__c = '09:00',
            TueEndTime1__c = '13:00',
            FriStartTime1__c = '09:00',
            FriEndTime1__c = '13:00',
            SatStartTime1__c = null,
            SatEndTime1__c = null,
            SunStartTime1__c = null,
            SunEndTime1__c = null
            //MonStartTime2__c = '14:00',
            //MonEndTime2__c = '18:00',
            //ThuStartTime2__c = '14:00',
            //ThuEndTime2__c = '18:00',
            //WedStartTime2__c = '14:00',
            //WedEndTime2__c = '18:00',
            //TueStartTime2__c = '14:00',
            //TueEndTime2__c = '18:00',
            //FriStartTime2__c = '14:00',
            //FriEndTime2__c = '18:00',
            //SatStartTime2__c = '14:00',
            //SatEndTime2__c = '18:00',
            //SunStartTime2__c = '14:00',
            //SunEndTime2__c = '18:00'
        );
        insert TimeSet ;
        
        for ( Time_Set__c reader : 
            [
                 select id, Name , Leave_Policy__c , 
                 MonStartTime1__c, MonEndTime1__c, //MonStartTime2__c, MonEndTime2__c, 
                 ThuStartTime1__c, ThuEndTime1__c, //ThuStartTime2__c, ThuEndTime2__c, 
                 WedStartTime1__c, WedEndTime1__c, //WedStartTime2__c, WedEndTime2__c, 
                 TueStartTime1__c, TueEndTime1__c, //TueStartTime2__c, TueEndTime2__c, 
                 FriStartTime1__c, FriEndTime1__c, //FriStartTime2__c, FriEndTime2__c, 
                 SatStartTime1__c, SatEndTime1__c, //SatStartTime2__c, SatEndTime2__c, 
                 SunStartTime1__c, SunEndTime1__c //SunStartTime2__c, SunEndTime2__c
                 from Time_Set__c 
        ]){
            TimeSetMap.put ( reader.name, reader );
        }
        
        Leave_Type__c LeaveType = new Leave_Type__c (
            Name = 'HKO Annual LeaveT',
            Display_Name__c = 'Annual Leave',
            LEAD_TIME_BELOW_THRESHOLD__C = 3,
            Deduct_PUBLIC_HOLIDAY__C = true,
            Deduct_EARLY_RELEASE__C = true, 
            ALLOW_ADVANCED_LEAVE__C = false,
            LEAVE_TYPE_ID__C = 'HKO_AnnualT',
            REMINDER__C = 'Please apply 3 days in advance for 3 consecutive days or less, and 1 month in advance for more than 4 consecutive days.',
            LEAD_TIME_ABOVE_THRESHOLD__C = 30,
            LEAD_TIME_THRESHOLD__C = 3,
            APPROVAL_WORKFLOW__C = 'Approval_Workflows_Type_3', 
            REMARK_REQUIRE__C = false,
            LEAVE_POLICY__C = LeavepolicyMap.get('HKO').id,
            ALLOW_UNLIMITED_LEAVE_BALANCE__C = false,
            ALLOW_DATE_BACK__C = 12,
            CANCELLATION_WORKFLOW__C = 'Leave_Cancellation_Flow_Type_1',
            Document_Required__c = 2
        );
        LeaveTypeList.add( LeaveType );
        
        LeaveType = new Leave_Type__c (
            Name = 'HKO Compensation LeaveT',
            Display_Name__c = 'Compensation Leave',
            Deduct_PUBLIC_HOLIDAY__C = true,
            Deduct_EARLY_RELEASE__C = false, 
            ALLOW_ADVANCED_LEAVE__C = true,
            LEAVE_TYPE_ID__C = 'Compensation LeaveT',
            REMINDER__C = '1) You <u>MUST</u> apply all the comp days in this trip within this Leave Application.<BR/>2) Comp days <u>MUST</u> be taken within 60 days after the <u>Departure Date</u> of your trip.<BR/>3) A Leave Application can apply multiple trips.',
            APPROVAL_WORKFLOW__C = 'Approval_Workflows_Type_1', 
            REMARK_REQUIRE__C = false,
            LEAVE_POLICY__C = LeavepolicyMap.get('HKO').id,
            ALLOW_UNLIMITED_LEAVE_BALANCE__C = true,
            ALLOW_DATE_BACK__C = 12,
            CANCELLATION_WORKFLOW__C = 'Leave_Cancellation_Flow_Type_1',
            Reference__c = 'Travel Application'
        );
        LeaveTypeList.add( LeaveType );
        
        insert LeaveTypeList;
        for (  Leave_Type__c  reader : 
            [
                select id, name, Display_Name__c, LEAD_TIME_BELOW_THRESHOLD__C,
                Deduct_PUBLIC_HOLIDAY__C, Deduct_EARLY_RELEASE__C,
                ALLOW_ADVANCED_LEAVE__C, LEAVE_TYPE_ID__C,
                REMINDER__C, 
                LEAD_TIME_ABOVE_THRESHOLD__C, LEAD_TIME_THRESHOLD__C,
                APPROVAL_WORKFLOW__C, REMARK_REQUIRE__C, LEAVE_POLICY__C,
                ALLOW_UNLIMITED_LEAVE_BALANCE__C, ALLOW_DATE_BACK__C,
                CANCELLATION_WORKFLOW__C
                from Leave_Type__c
                where id in :LeaveTypeList
        ]){
            LeaveTypeMap.put( reader.name, reader);
        }
        Leave_Available_Time__c LeaveAvailableTime = null;
        for (String lt : LeaveTypeMap.keySet()){
                LeaveAvailableTime = new Leave_Available_Time__c(
                NAME = 'HKO Timeset 1 '+LeaveTypeMap.get(lt).display_name__c+' 1',
                LEAVE_TYPE__C = LeaveTypeMap.get(lt).id,// LeaveTypeMap.get( 'HKO Annual LeaveT' ).id,
                COST__C = 0.25,
                TIMESET__C = TimeSetMap.get( 'HKO_TS1' ).id,
                AVAILABLE_START_TIME_HOUR__C = '9',
                AVAILABLE_END_TIME_HOUR__C = '11',
                AVAILABLE_START_TIME_MINUTE__C = '0',
                AVAILABLE_END_TIME_MINUTE__C = '0'
            );
            LeaveAvailableTimeList.add (LeaveAvailableTime );
            
            LeaveAvailableTime = new Leave_Available_Time__c(
                NAME = 'HKO Timeset 1 '+LeaveTypeMap.get(lt).display_name__c+' 2',
                LEAVE_TYPE__C = LeaveTypeMap.get(lt).id,// LeaveTypeMap.get( 'HKO Annual LeaveT' ).id,
                COST__C = 0.25,
                TIMESET__C = TimeSetMap.get( 'HKO_TS1' ).id,
                AVAILABLE_START_TIME_HOUR__C = '11',
                AVAILABLE_END_TIME_HOUR__C = '14',
                AVAILABLE_START_TIME_MINUTE__C = '0',
                AVAILABLE_END_TIME_MINUTE__C = '0'
            );
            LeaveAvailableTimeList.add (LeaveAvailableTime );
            
            LeaveAvailableTime = new Leave_Available_Time__c(
                NAME = 'HKO Timeset 1 '+LeaveTypeMap.get(lt).display_name__c+' 3',
                LEAVE_TYPE__C = LeaveTypeMap.get(lt).id,// LeaveTypeMap.get( 'HKO Annual LeaveT' ).id,
                COST__C = 0.25,
                TIMESET__C = TimeSetMap.get( 'HKO_TS1' ).id,
                AVAILABLE_START_TIME_HOUR__C = '14',
                AVAILABLE_END_TIME_HOUR__C = '16',
                AVAILABLE_START_TIME_MINUTE__C = '0',
                AVAILABLE_END_TIME_MINUTE__C = '0'
            );
            LeaveAvailableTimeList.add (LeaveAvailableTime );
            
            LeaveAvailableTime = new Leave_Available_Time__c(
                NAME = 'HKO Timeset 1 '+LeaveTypeMap.get(lt).display_name__c+' 4',
                LEAVE_TYPE__C = LeaveTypeMap.get(lt).id,// LeaveTypeMap.get( 'HKO Annual LeaveT' ).id,
                COST__C = 0.25,
                TIMESET__C = TimeSetMap.get( 'HKO_TS1' ).id,
                AVAILABLE_START_TIME_HOUR__C = '16',
                AVAILABLE_END_TIME_HOUR__C = '18',
                AVAILABLE_START_TIME_MINUTE__C = '0',
                AVAILABLE_END_TIME_MINUTE__C = '0'
            );
            LeaveAvailableTimeList.add (LeaveAvailableTime );     
        }
        insert LeaveAvailableTimeList;
        
        for ( Leave_Available_Time__c reader : 
            [
                Select id, Name, LEAVE_TYPE__C, COST__C, TIMESET__C, 
                AVAILABLE_START_TIME_HOUR__C, AVAILABLE_END_TIME_HOUR__C 
                from Leave_Available_Time__c
                where TIMESET__C = :TimeSetMap.get( 'HKO_TS1' ).id 
                and LEAVE_TYPE__C = :LeaveTypeMap.get( 'HKO Annual LeaveT' ).id
        ]){
            LeaveAvailableTimeMap.put( reader.name, reader );
        }
        
        /*Holiday Setting*/
        Date testingHoliday = Date.newInstance(2015, 3, 20);
        Holiday__c holiday = new Holiday__c(
            Name = 'Holiday Testing',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = LeavepolicyMap.get('HKO').id,
            Holiday_External_ID__c = 'Holiday Testing'
        );
        HolidayList.add( holiday );
        
        /*Early Release Setting*/
        testingHoliday = Date.newInstance(2015, 3, 19);
        holiday = new Holiday__c(
            Name = 'Holiday Testing',
            Description__c = 'Early Release Testing',
            Date__c = testingHoliday,
            Type__c = 'E', 
            Minute__c = '00', 
            Hour__c = '11', 
            Cost__c = 0, 
            Leave_Policy__c = LeavepolicyMap.get('HKO').id,
            Holiday_External_ID__c = 'Early Release Testing'
        );
        
        HolidayList.add( holiday );
        insert HolidayList;
        
        for ( Holiday__c reader : 
            [
                Select id, Name, Description__c, Date__c, Type__c, Minute__c, Hour__c, Cost__c, Leave_Policy__c 
                from Holiday__c 
        ]){
            HolidayMap.put( reader.name, reader );
        }
        
        /*Employee Type Setting*/ 
        Employee_Type__c employeeType = new Employee_Type__c(
            Name = 'Permanent',
            Entitled_Early_Release__c = true,
            Entitled_Public_Holiday__c = true,
            Leave_Policy__c = LeavepolicyMap.get('HKO').id
        );
        employeeTypeList.add(employeeType);
        insert employeeTypeList;
        
        for ( Employee_Type__c reader : 
        [
            select id, Name, Entitled_Early_Release__c, Entitled_Public_Holiday__c, Leave_Policy__c, Leave_Policy__r.name
            from Employee_Type__c 
        ]){
            EmployeeTypeMap.put(reader.Leave_Policy__r.name + reader.Name, reader);
        }
        
        
    }
    
    public Map<String, User> getUserMap() {

        Map <String, User> UserMap = new Map<String, User> ();
        List <PermissionSetAssignment> PermissionSetAssignmentList = new List <PermissionSetAssignment>();
        
        String user_ProfileName = 'TAL FE Standard Platform User'; 
        String Admin_ProfileName = 'System Administrator'; 
        String Permission_Set = 'Leave_User_Prod';
        //String TE_Permission_Set = 'TE_%';
        List <String> TE_Permission_Set_List = new List <String>{'TE_User', 'TE_Admin', 'TE_CSR', 'TE_Finance', 'TE_HCM', 'TE_Travel_Agency'};
        String TE_GROUP_NAME = 'TE_%_%';
        String HCM_GROUP_NAME = 'ELE_%_Admin';
        List <ID> groupIDList = new List <ID>();
        List <GroupMember> userGroupList = new List <GroupMember>();
        List <String> Permission_SetID = new List <String>();
        
        String Admin_Email = 'admin@testclass.com';        
        String Admin_Alias = 'admin';         
        
        String user1_Email = 'user1@testclass.com';        
        String user1_Alias = 'user1'; 
        
        String user2_Email = 'user2@testclass.com';        
        String user2_Alias = 'user2'; 
        
        String approver1_Email = 'approver1@testclass.com';        
        String approver1_Alias = 'apr1'; 
        
        String approver2_Email = 'approver2@testclass.com';        
        String approver2_Alias = 'apr2'; 
        
        String approver3_Email = 'approver3@testclass.com';        
        String approver3_Alias = 'apr3'; 
        
        String approver4_Email = 'approver4@testclass.com';        
        String approver4_Alias = 'apr4'; 
        
        String actingapprover1_Email = 'actingapprover1@testclass.com';        
        String actingapprover1_Alias = 'actapr1'; 
         
        String actingapprover2_Email = 'actingapprover2@testclass.com';        
        String actingapprover2_Alias = 'actapr2'; 
        
        String actingapprover3_Email = 'actingapprover3@testclass.com';        
        String actingapprover3_Alias = 'actapr3'; 
        
        String actingapprover4_Email = 'actingapprover4@testclass.com';        
        String actingapprover4_Alias = 'actapr4'; 
        
        String HCMUser_Email = 'HCMUser@testclass.com';        
        String HCMUser_Alias = 'HCMUser';        
        
        for ( PermissionSet reader : [select id, Name from PermissionSet WHERE Name = :Permission_Set 
                                       or (Name in :TE_Permission_Set_List)
                                    ] ){
            Permission_SetID.add(reader.id);
        }
        for(Group reader : [select id from Group where DeveloperName like :TE_GROUP_NAME or DeveloperName  like :HCM_GROUP_NAME ]){
            groupIDList.add(reader.id);
        }
        
        systemAdminprofile = [ SELECT Id FROM Profile WHERE Name = :Admin_ProfileName ];
        
        
        Profile talFEStdPlatformUserprofile = [ SELECT Id FROM Profile WHERE Name = :user_ProfileName ];        
        User adminUser = userCreation ( Admin_Alias, Admin_Email, systemAdminprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION,  USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        adminUser.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;
        UserMap.put (adminUser.Alias, adminUser);
        
        User user = userCreation ( user1_Alias, user1_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        user.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (user.Alias, user );
        
        user = userCreation ( user2_Alias, user2_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        user.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (user.Alias, user );
        
        User approver1 = userCreation ( approver1_Alias, approver1_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        approver1.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (approver1.Alias, approver1);
        
        User approver2 = userCreation ( approver2_Alias, approver2_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        approver2 .Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (approver2.Alias, approver2);
        
        User approver3 = userCreation ( approver3_Alias, approver3_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        approver3.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (approver3.Alias, approver3);
        
        User approver4 = userCreation ( approver4_Alias, approver4_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        approver4.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (approver4.Alias, approver4);
        
        User actingapprover1 = userCreation ( actingapprover1_Alias, actingapprover1_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        actingapprover1.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (actingapprover1.Alias, actingapprover1 );
        
        User actingapprover2 = userCreation ( actingapprover2_Alias, actingapprover2_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        actingapprover2.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (actingapprover2.Alias, actingapprover2 );
        
        User actingapprover3 = userCreation ( actingapprover3_Alias, actingapprover3_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        actingapprover3.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (actingapprover3.Alias, actingapprover3 );
        
        User actingapprover4 = userCreation ( actingapprover4_Alias, actingapprover4_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        actingapprover4.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (actingapprover4.Alias, actingapprover4 );
        
        User HCMUser = userCreation ( HCMUser_Alias, HCMUser_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        HCMUser.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS;        
        UserMap.put (HCMUser.Alias, HCMUser);
        
        insert UserMap.values();
        
        
        List<ID> usrIDList = new List<ID> ();
        for ( User usr : UserMap.values() ){
            usrIDList.add(usr.id);
        }
        UserMap.clear();
        
        for ( User reader : 
            [
                select id,
                Alias, Email, 
                EmailEncodingKey, LastName, LanguageLocaleKey, 
                LocaleSidKey, ProfileId, 
                TimeZoneSidKey, UserName,
                Location_Global__c,
                Location_Region__c,
                Location_Local__c,
                Grade__c,
                Department__c,
                Function__c,
                Portal_Language__c,
                Administrative_Regions__c,
                Administrative_Department__c,
                Create_Portal_Page__c
                from user
                where id in :usrIDList
        ]){
            UserMap.put ( reader.Alias, reader);
            if (!Permission_SetID.isEmpty()){
                for(String pid : Permission_SetID){
                    PermissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = reader.id, PermissionSetId = pid));
                }
                for(Id gid :groupIDList){
                    userGroupList.add(new GroupMember(UserOrGroupId = reader.id, GroupId = gid));
                }
            }
        }
        
        System.runAs(UserMap.get('admin')){       
            if(!PermissionSetAssignmentList.isempty()){
                insert PermissionSetAssignmentList;
            }
            
            if(!userGroupList.isempty()){
                insert userGroupList;
            }
        } 
         
        
        return UserMap;
    }
    
    public   Map<String, Employee__c> getEmployeeMap(  Map<String, User> UserMap  ) {             
        Map<String, Employee__c> EmployeeMap = new Map<String, Employee__c>();
        basicSetting();
        List <Employee__c> EmployeeList = new List <Employee__c>();        
        Employee__c user1= new Employee__c(
            Name = 'user1',
            Original_Employee_ID__c = 'user1',
            Employee_ID__c = 'user1',
            Employee_Type__c = EmployeeTypeMap.get('HKOPermanent').id,
            First_Name__c = 'user1',
            Last_Name__c = 'user1',
            Leave_Policy__c = LeavepolicyMap.get('HKO').id,
            Timeset__c = TimeSetMap.get('HKO_TS1').id,
            user__c = UserMap.get('user1').id,
            Approver_1__c = UserMap.get('apr1').id,
            Approver_2__c = UserMap.get('apr2').id,
            Approver_3__c = UserMap.get('apr3').id,
            Approver_4__c = UserMap.get('apr4').id,
            Acting_Approver_1__c = UserMap.get('actapr1').id,
            Acting_Approver_2__c = UserMap.get('actapr2').id,
            Acting_Approver_3__c = UserMap.get('actapr3').id,
            Acting_Approver_4__c = UserMap.get('actapr4').id,
            Site__c = SiteMap.get('HKOT').id,
            Grade__c = EMPLOYEE_GRADE,
            //Employee_Department__c = 'IT'
            
            //Added by TAL (Twinkle LI) @20170721 for testclass issue fix
            Function_Code__c = 'IT',
            Department_Code__c = 'IT',
            Section_Code__c = 'BA'

        );
        EmployeeList.add(user1);
        
        Employee__c user2= new Employee__c(
            Name = 'user2',
            Original_Employee_ID__c = 'user2',
            Employee_ID__c = 'user2',
            Employee_Type__c = EmployeeTypeMap.get('HKOPermanent').id,
            First_Name__c = 'user2',
            Last_Name__c = 'user2',
            Leave_Policy__c = LeavepolicyMap.get('HKO').id,
            Timeset__c = TimeSetMap.get('HKO_TS1').id,
            user__c = UserMap.get('user2').id,
            Approver_1__c = UserMap.get('apr1').id,
            Approver_2__c = UserMap.get('apr2').id,
            Approver_3__c = UserMap.get('apr3').id,
            Approver_4__c = UserMap.get('apr4').id,
            Acting_Approver_1__c = UserMap.get('actapr1').id,
            Acting_Approver_2__c = UserMap.get('actapr2').id,
            Acting_Approver_3__c = UserMap.get('actapr3').id,
            Acting_Approver_4__c = UserMap.get('actapr4').id,
            Site__c = SiteMap.get('HKOT').id,
            Grade__c = EMPLOYEE_GRADE,
            //Employee_Department__c = 'IT'
            
            //Added by TAL (Twinkle LI) @20170721 for testclass issue fix
            Function_Code__c = 'IT',
            Department_Code__c = 'IT',
            Section_Code__c = 'BA'
            
        );
        EmployeeList.add(user2);
        
        insert EmployeeList;    
        for ( Employee__c reader : 
            [
                select id, Name, First_Name__c, Last_Name__c,
                Leave_Policy__c, Timeset__c, user__c, Notif_Leave_Forfeiture__c,
                Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c,
                Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c,
                Original_Employee_ID__c 
                from Employee__c
                where Original_Employee_ID__c in ( 'user1', 'user2' )
        ]){
            EmployeeMap.put (reader.name, reader);
        }
         
        return EmployeeMap;
    }
    
    public  List <Leave_balance__c> getleaveBalanceList (){
        return this.leaveBalanceList;
    }
    
    public  void setleaveBalanceList ( List <Employee__c> employeeList ) {  
        Set<String> leaveBalanceSet = new Set<String>();
        for ( Employee__c employee : employeeList ){
            for ( Leave_Available_Time__c leaveAvailableTime : LeaveAvailableTimeMap.values() ){
                if ( leaveAvailableTime.TIMESET__C == employee.TIMESET__C ) {
                    if ( !leaveBalanceSet.contains(employee.Original_Employee_ID__c + leaveAvailableTime.LEAVE_TYPE__C) ){
                        leaveBalanceList.add( leaveBalanceCreation ( employee, leaveAvailableTime ) );
                        leaveBalanceSet.add(employee.Original_Employee_ID__c + leaveAvailableTime.LEAVE_TYPE__C );
                    }
                }
            }
        }
        //Employee__r.Original_Employee_ID__c & Leave_Type_Code__r.Leave_Type_ID__c & Year__c & TEXT(VALUE(Month__c))
        insert leaveBalanceList;
    }
    
    public  Leave_balance__c leaveBalanceCreation ( Employee__c employee, Leave_Available_Time__c leaveAvailableTime ) {        
        return new Leave_balance__c (
            Leave_Type_Code__c = leaveAvailableTime.LEAVE_TYPE__C,
            Employee__c = employee.id,
            Year__c = '2010',
            Month__c = '1',
            //Is_Latest__c = true,
            Opening_Balance_Days__c = 100,
            Forfeited__c = 0,
            Approved_Current_Period__c = 0,
            Approved_Future_Period__c = 0,
            Unapproved_Balance__c = 0,
            Increment_Days__c = 1,
            Maximum_Cumulative_Entitlement__c = 10
        );
    }
    
    
    /*
        Map< Administrator, Employee List> EmployeeAdministratorMap
    */
    public  List <Employee_Administrator__c> EmployeeAdministratorCreation ( Map< Employee__c, List<Employee__c> > EmployeeAdministratorMap ) {
        List <Employee_Administrator__c> EmployeeAdministrator = new List <Employee_Administrator__c>();
        Set<ID> selfEmployeeAdministratorIds = new Set<ID>();
        
        for ( Employee__c key : EmployeeAdministratorMap.keyset() ){
            for ( Employee__c val : EmployeeAdministratorMap.get(key) ){
                if ( val.id != key.id ) {
                    EmployeeAdministrator.add(new Employee_Administrator__c ( Employee_Administrator__c = key.id, Employee__c = val.id ));
                } else {
                    selfEmployeeAdministratorIds.add(key.id);
                }
            }
        }
        insert EmployeeAdministrator;
        
        employeeAdministrator.addAll([Select Employee_Administrator__c, Employee__c from Employee_Administrator__c where Employee_Administrator__c in :selfEmployeeAdministratorIds and Is_Self__c = true]);
        
        return EmployeeAdministrator;
    }
    
    public  Leave_Application__c leaveApplicationCreation ( Employee__c onBehalfOf ){
        Leave_Application__c leaveApplication = new Leave_Application__c(
            Employee_ID__c = onBehalfOf.id,
            Remarks__c  ='TEST',
            Type__c = LeaveRequestConstant.LEAVE_APPLICATION_INDIVIDUAL,
            RecordTypeId = stringLeaveRequestHeaderRecordType 
        );        
        insert leaveApplication;
        return leaveApplication;
    }
    
    public  Leave_Request__c leaveRequestCreation ( Leave_Application__c leaveApplication, List <Employee_Administrator__c> employeeAdministratorList,  Employee__c employee, Employee__c onBehalfOf ){
        
        String EmployeeAdministratorId = null;
        
        for ( Employee_Administrator__c reader : employeeAdministratorList ){ 
            if ( reader.Employee_Administrator__c == employee.id && reader.employee__c == onBehalfOf.id ) {
                EmployeeAdministratorId = reader.id;
            }
        }
         
        if ( EmployeeAdministratorId == null ){
            return null;
        }
        
        Leave_Request__c LeaveRequest = new Leave_Request__c
        (
            Employee_Administrator__c = EmployeeAdministratorId,
            //From_date__c = '2011-01-02',
            From_Hour__c = '09',
            From_Minute__c = '00',
            To_Hour__c = '18',
            To_Minute__c = '00',
            Leave_Application__c = leaveApplication.id,
            Acting_Approver_1__c = onBehalfOf.Acting_Approver_1__c,
            Acting_Approver_2__c = onBehalfOf.Acting_Approver_2__c,
            Acting_Approver_3__c = onBehalfOf.Acting_Approver_3__c,
            Acting_Approver_4__c = onBehalfOf.Acting_Approver_4__c,
            Approver_1__c = onBehalfOf.Approver_1__c,
            Approver_2__c = onBehalfOf.Approver_2__c,
            Approver_3__c = onBehalfOf.Approver_3__c,
            Approver_4__c = onBehalfOf.Approver_4__c,
            Actual_Approver_1__c = onBehalfOf.Acting_Approver_1__c != null ? onBehalfOf.Acting_Approver_1__c : onBehalfOf.Approver_1__c,
            Actual_Approver_2__c = onBehalfOf.Acting_Approver_2__c != null ? onBehalfOf.Acting_Approver_2__c : onBehalfOf.Approver_2__c,
            Actual_Approver_3__c = onBehalfOf.Acting_Approver_3__c != null ? onBehalfOf.Acting_Approver_3__c : onBehalfOf.Approver_3__c,
            Actual_Approver_4__c = onBehalfOf.Acting_Approver_4__c != null ? onBehalfOf.Acting_Approver_4__c : onBehalfOf.Approver_4__c
        );
        insert LeaveRequest;
        return LeaveRequest;
    }
    
    public Leave_Request__c flexibleLeaveRequestCreation (Date flexibleDate, Employee_Administrator__c employeeAdministrator, Employee__c employee ){
        Leave_Request__c leaveRequest = new Leave_Request__c (
            RecordTypeId = stringFlexibleLeaveRequestlineRecordType,
            Date__c = flexibleDate,
            Adjustment_mins__c = '+45',
            Employee_Administrator__c = employeeAdministrator.id,
            Employee_ID__c = employee.id,
            Status__c = LeaveRequestConstant.STATUS_NOT_SUBMITTED
            
        );
        
        return leaveRequest;
    }
      
     
}