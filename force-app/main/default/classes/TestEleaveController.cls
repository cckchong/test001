@isTest
public with sharing class TestEleaveController
{
     public static Map<String, User> UserMap ;
     public static Map<String, Employee__c> EmployeeMap ;
     public static Map <String, Leave_Type__c> LeaveTypeMap;   
     public static Map <String, Time_Set__c> TimeSetMap {get;set;}
     public static TestEleavePreparation  EleavePreparation; 
     public static String stringLeaveStartTime;
     public static String stringLeaveEndTime ;
     
     
     public static void Preparation(Boolean isSeeAllData) {
         EleavePreparation = new TestEleavePreparation (isSeeAllData);
         UserMap = EleavePreparation.getUserMap();
         EmployeeMap = EleavePreparation.getEmployeeMap(UserMap);
         EleavePreparation.setleaveBalanceList (EmployeeMap.values());
         LeaveTypeMap = EleavePreparation.LeaveTypeMap;
         TimeSetMap  = EleavePreparation.TimeSetMap;
         stringLeaveStartTime = '';
         stringLeaveEndTime  = '';
         for ( Leave_Available_Time__c reader : EleavePreparation.LeaveAvailableTimeMap.values() ){
             if ( stringLeaveStartTime == '' ){             
                 stringLeaveStartTime = reader.id;
             }
             stringLeaveEndTime = reader.id;
         }
     }
     
     public static EleaveController  eLeaveCreation () {
        EleaveController eleaveCtrl = new EleaveController(); 
        
        
        List < LeaveSection > leaveSectionList  = eleaveCtrl.ListLeaveSection;
          
        for ( LeaveSection reader : leaveSectionList ){
             reader.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
             reader.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 15);
             reader.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 21);
             reader.stringLeaveStartTime = stringLeaveStartTime;
             reader.stringLeaveEndTime = stringLeaveEndTime;
        } 
         
        for ( LeaveSection reader : leaveSectionList ) {
             reader.changeLeaveType();
        }
        return eleaveCtrl;
     }
     
     @isTest
     public static void LeaveRequestCreation() {
         PageReference page = null;
         Preparation(false);
         Integer leaveSectionListSize = 0;
         System.runAs(UserMap.get('user1')) {
             EleaveController eleaveCtrl = new EleaveController(); 
             LeaveTypeMap = EleavePreparation.LeaveTypeMap;
             List < LeaveSection > leaveSectionList  = eleaveCtrl.ListLeaveSection;
             
             /*Test the EleaveController initialization*/
             system.assertEquals(1, leaveSectionList.size() );
             
             /*Create and Remove Leave Request*/
             for ( LeaveSection reader : leaveSectionList ) {
                 reader.booleanechecked = true;
             }
             eleaveCtrl.addLeaveSection();
             eleaveCtrl.removeLeaveSection();
             leaveSectionList  = eleaveCtrl.ListLeaveSection;
             system.assertEquals(1, leaveSectionList.size() );
             eleaveCtrl.addLeaveSection();
             eleaveCtrl.addLeaveSection();
             eleaveCtrl.addLeaveSection();
             eleaveCtrl.addLeaveSection();
             eleaveCtrl.addLeaveSection();
             eleaveCtrl.addLeaveSection();
             eleaveCtrl.addLeaveSection();
             leaveSectionListSize = leaveSectionList.size();
             
             LeaveSection leaveSec;
             
             for ( Integer i = 0 ; i < leaveSectionListSize; i++ ){
                  
                 if ( i == 0 ){
                     /* i = 0
                         Testing a leave request with Early Release and Holiday
                         Date: 15/03/2015 - 21/03/2015
                         Leave Type: HKO Annual Leave
                         Early Release: 19/03/2015
                         Holiday: 20/03/2015
                     */ 
                     leaveSec = leaveSectionList.get(i);
                     leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
                     leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 15);
                     leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 21);
                     leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                     leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 }
                 
                 if ( i == 1 ){
                     /* i = 1
                          Take one Day AL
                          Date: 25/03/2015 - 25/03/2015
                          Leave Type: HKO Annual Leave
                     */ 
                     leaveSec = leaveSectionList.get(i);
                     leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
                     leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 25);
                     leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 25);
                     leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                     leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 }
                 
                 if ( i == 2 ){
                     /* i = 2
                          Take one Day AL on holiday
                          Date: 20/03/2015 - 20/03/2015
                          Leave Type: HKO Annual Leave
                     */ 
                     leaveSec = leaveSectionList.get(i);
                     leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
                     leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 20);
                     leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 20);
                     leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                     leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 }
                 
                 if ( i == 3 ){
                     /* i = 3
                          Take one Day AL on early release
                          Date: 19/03/2015 - 19/03/2015
                          Leave Type: HKO Annual Leave
                     */ 
                     leaveSec = leaveSectionList.get(i);
                     leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
                     leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 19);
                     leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 19);
                     leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                     leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 }
                 if ( i == 4 ){
                     /* i = 4
                          Take a leave until early release
                          Date: 14/03/2015 - 20/03/2015
                          Leave Type: HKO Annual Leave
                     */ 
                     leaveSec = leaveSectionList.get(i);
                     leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
                     leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 14);
                     leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 19);
                     leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                     leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 }
                 if ( i == 5 ){
                     /* i = 5
                          Take a leave starting from early release
                          Date: 20/03/2015 - 25/03/2015
                          Leave Type: HKO Annual Leave
                     */ 
                     leaveSec = leaveSectionList.get(i);
                     leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
                     leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 19);
                     leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 25);
                     leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                     leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 }
                 if ( i == 6 ){
                     /* i = 6
                          Take 2 months AL leave 
                          Date: 01/03/2015 - 30/04/2015
                          Leave Type: HKO Annual Leave
                     */ 
                     leaveSec = leaveSectionList.get(i);
                     leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
                     leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 01);
                     leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 4, 30);
                     leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                     leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 }
                 if ( i == 7 ){
                     /* i = 6
                          From Date > To Date
                          Date: 01/04/2015 - 30/03/2015
                          Leave Type: HKO Annual Leave
                     */ 
                     leaveSec = leaveSectionList.get(i);
                     leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
                     leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 4, 01);
                     leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 30);
                     leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                     leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 }
                 
             }
             
             for ( LeaveSection reader : leaveSectionList ) {
                 reader.changeLeaveTypefalse();
             }
             page = eleaveCtrl.submitAction();
             system.assertEquals(null, page);
             
         }
         
     }
     
     /*
         Reason why SeeAllData = true
         system.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @isTest(SeeAllData=true).
     */
     @isTest(SeeAllData = true)
     public static void LeaveRequestsubmit() {

         List<ID> leaveRequestIDList = new List<ID>();
         Preparation(true);         
         System.runAs(UserMap.get('user1')) {
             Test.startTest();   
             EleaveController eleaveCtrl = eLeaveCreation (); 
             eleaveCtrl.setdateApplicationDate(Date.today());
             eleaveCtrl.submitAction(); 
             eleaveCtrl.getdateApplicationDate();
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertNotEquals(null, reader.leavetransaction.id );
                 leaveRequestIDList.add(reader.leavetransaction.id);
             }
             for ( Leave_Request__c reader : [select id, CHATTERFEEDID__C from Leave_Request__c where id = :leaveRequestIDList]){
                 system.assertNotEquals(null, reader.CHATTERFEEDID__C);
             }
             Test.stopTest();
         }
     }
     
     @isTest
     public static void openDraftLeaveRequest() {
         Preparation(false);
         System.runAs(UserMap.get('user1')) {
             EleaveController eleaveCtrl = eLeaveCreation();
             eleaveCtrl.saveAction();
             Test.startTest();               
             eleaveCtrl = new EleaveController(eleaveCtrl.request.id);
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertNotEquals(null, reader.leavetransaction.id );
             }          
             Test.stopTest();
         } 
     }
     
     @isTest(SeeAllData = true)
     public static void openSubmitedLeaveRequest() {
         Preparation(true);          
         System.runAs(UserMap.get('user1')) {
             EleaveController eleaveCtrl = eLeaveCreation();
             Test.startTest(); 
             eleaveCtrl.submitAction();                          
             eleaveCtrl = new EleaveController(eleaveCtrl.request.id);
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertNotEquals(null, reader.leavetransaction.id );
             }
             Test.stopTest();
         }
     }
     
     @isTest(SeeAllData = true)
     public static void closeLeaveRequestForm() {
         Preparation(true);          
         System.runAs(UserMap.get('user1')) {
             EleaveController eleaveCtrl = eLeaveCreation();
             Test.startTest();
             eleaveCtrl.cancelAction();
             eleaveCtrl.submitAction(); 
             Leave_Application__c  leaveApplication = eleaveCtrl.request;
             eleaveCtrl = new EleaveController(eleaveCtrl.request.id);  
             eleaveCtrl.cancelAction();
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertNotEquals(null, reader.leavetransaction.id );
             }
             Test.stopTest();
         } 
     }
     
     @isTest
     public static void changeEmployeeLeaveRequest() {
         List <Employee_Administrator__c> EmployeeAdministrator;         
         Map< Employee__c, List<Employee__c>> employeeAdmin = new Map< Employee__c, List<Employee__c>>();
         Preparation(true);          
         for ( Employee__c reader : EmployeeMap.values() ) {
             if (reader.First_Name__c == 'user1') {
                 employeeAdmin.put( reader, EmployeeMap.values());
             }
         }
         EmployeeAdministrator = EleavePreparation.EmployeeAdministratorCreation(employeeAdmin);         
         System.runAs(UserMap.get('user1')) {
             EleaveController eleaveCtrl = eLeaveCreation();
             Test.startTest();             
             for ( Employee_Administrator__c reader : EmployeeAdministrator ) {
                 if (reader.Employee_Administrator__c != reader.Employee__c) {
                     eleaveCtrl.request.Employee_Administrator__c  = reader.id;
                     break;
                 }
             }
             eleaveCtrl.changeEmployee();  
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertEquals(null, reader.leavetransaction.id );
             }
             Test.stopTest();
         } 
     }
     
     @isTest(SeeAllData = true)
     public static void changeTimeSet() {
         Preparation(true);
          Map <String, Time_Set__c> TimeSetMaps = EleavePreparation.TimeSetMap;
          Time_Set__c TimeSet = TimeSetMaps.get('HKO_TS1');
          TimeSet.MonStartTime1__c = null;
          TimeSet.MonEndTime1__c = null;
          TimeSet.ThuStartTime1__c = null;
          TimeSet.ThuEndTime1__c = null;
          TimeSet.WedStartTime1__c = null;
          TimeSet.WedEndTime1__c = null;
          TimeSet.TueStartTime1__c = null;
          TimeSet.TueEndTime1__c = null;
          TimeSet.FriStartTime1__c = null;
          TimeSet.FriEndTime1__c = null;
          TimeSet.SatStartTime1__c = '09:00';
          TimeSet.SatEndTime1__c = '13:00';
          TimeSet.SunStartTime1__c = '09:00';
          TimeSet.SunEndTime1__c = '13:00';
          update TimeSet;
            
         System.runAs(UserMap.get('user1')) {
             Test.startTest();
             EleaveController eleaveCtrl = eLeaveCreation();
             eleaveCtrl.submitAction();
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertNotEquals(null, reader.leavetransaction.id );
             }
             Test.stopTest();
         } 

     
     }
     
     /*
         Type: Submit a leave Request with a Flexible Leave Request 
         Test: Submited a Flexible Leave Request
     */
     @isTest(SeeAllData=true)
     public static void submitLeaveRequestAndFlexibleLeaveRequest() {
         Leave_Request__c leaveRequest = null;
         Employee__c employee = null;
         Employee_Administrator__c employeeAdministrator = null;
         EleaveController eleaveCtrl;
         Preparation(true);
         
         for ( Employee__c reader : EmployeeMap.values() ) {
             if (reader.First_Name__c == 'user1') {
                 employee = reader;
             }
         }
         
         for ( Employee_Administrator__c reader : 
         [
             select id, Employee__c, Employee_Administrator__c from Employee_Administrator__c  where Employee_Administrator__c = :employee.id and Employee__c = :employee.id 
         ]) {
             employeeAdministrator = reader;
         }
         
         Test.startTest(); 
         Leave_Request__c flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation( Date.Today().addDays(7).toStartOfWeek().addDays(1), employeeAdministrator, employee );         
         insert flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_NOT_SUBMITTED, flexibleLeaveRequest.status__c );
         
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_SUBMITTED;
         update flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_SUBMITTED, flexibleLeaveRequest.status__c );
         
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 reader.leavetransaction.from_date__c = Date.Today().addDays(7).toStartOfWeek().addDays(1);
                 reader.leavetransaction.to_date__c = Date.Today().addDays(7).toStartOfWeek().addDays(1);
             }
             eleaveCtrl.saveAction();
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertNotEquals(null, reader.leavetransaction.id );
             }
         }         
         Test.stopTest(); 
     }
     
     @isTest(SeeAllData=false)
     public static void submitcompLeave() {         
         List<Leave_Request__c> leaveRequestList = new List<Leave_Request__c>();
         Employee__c employee = null;
         Employee_Administrator__c employeeAdministrator = null;
         EleaveController eleaveCtrl;
         PageReference prf;
         Preparation(false);
         
         for ( Employee__c reader : EmployeeMap.values() ) {
             if (reader.First_Name__c == 'user1') {
                 employee = reader;
             }
         }
         
         for ( Employee_Administrator__c reader : 
         [
             select id, Employee__c, Employee_Administrator__c from Employee_Administrator__c  where Employee_Administrator__c = :employee.id and Employee__c = :employee.id 
         ]) {
             employeeAdministrator = reader;
         }
         
         Travel_Application__c ta = new Travel_Application__c();
         ta.on_behalf_of__c = employeeAdministrator.id;
         ta.status__c = TEConstant.STATUS_CONFIRMED;
         ta.num_of_leave_days__c = 12;
         ta.Leave_Date__c = ((Datetime)System.Today().adddays(-10)).format('yyyymmdd') +';'+ ((Datetime)System.Today().adddays(-8)).format('yyyymmdd') +';'+ ((Datetime)System.Today().adddays(-9)).format('yyyymmdd');
         upsert ta; 
         upsert  new Leave_balance__c (
            Leave_Type_Code__c =  LeaveTypeMap.get( 'HKO Compensation LeaveT' ).id,
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
         
         Test.startTest();
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();
             for ( Leave_Available_Time__c reader : 
             [
                Select id, Name, LEAVE_TYPE__C, COST__C, TIMESET__C, 
                AVAILABLE_START_TIME_HOUR__C, AVAILABLE_END_TIME_HOUR__C 
                from Leave_Available_Time__c
                where 
                LEAVE_TYPE__C = :LeaveTypeMap.get( 'HKO Compensation LeaveT' ).id
                and TIMESET__C = :TimeSetMap.get( 'HKO_TS1' ).id 
                
                
             ]){
                 if ( stringLeaveStartTime == '' ){             
                     stringLeaveStartTime = reader.id;
                 }
                 stringLeaveEndTime = reader.id;
             
             }
             for(LeaveSection leaveSec : eleaveCtrl.ListLeaveSection){
                 leaveSec.leavetransaction.travel_Application__c = ta.id;
                 leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Compensation LeaveT' ).id;                 
                 leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 25);
                 leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 25);
                 leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                 leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 leaveRequestList.add(leaveSec.leavetransaction);
             }
             prf = eleaveCtrl.SaveAction();
             system.assertNotEquals(prf, null);
         }
         for(Leave_Request__c lr : leaveRequestList){
             lr.status__c = LeaveRequestConstant.STATUS_APPROVED;
             lr.Deduction__c = 1; 
         }
         upsert leaveRequestList;
         System.runAs(UserMap.get('user1')) {
             //reuse travel Application
             eleaveCtrl = eLeaveCreation ();
             for(LeaveSection leaveSec : eleaveCtrl.ListLeaveSection){
                 leaveSec.leavetransaction.travel_Application__c = ta.id;
                 leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Compensation LeaveT' ).id;                 
                 leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 25);
                 leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 25);
                 leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                 leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 
             }
             eleaveCtrl.saveAction();
         }         
         Test.stopTest(); 
     }
     
     @isTest
     public static void errorTestcompLeave() {
         List<Leave_Request__c> leaveRequestList = new List<Leave_Request__c>();
         Employee__c employee = null;
         Employee_Administrator__c employeeAdministrator = null;
         EleaveController eleaveCtrl;
         PageReference prf;
         Preparation(false);
         
         for ( Employee__c reader : EmployeeMap.values() ) {
             if (reader.First_Name__c == 'user1') {
                 employee = reader;
             }
         }
         
         for ( Employee_Administrator__c reader : 
         [
             select id, Employee__c, Employee_Administrator__c from Employee_Administrator__c  where Employee_Administrator__c = :employee.id and Employee__c = :employee.id 
         ]) {
             employeeAdministrator = reader;
         }
         
         Travel_Application__c ta = new Travel_Application__c();
         ta.on_behalf_of__c = employeeAdministrator.id;
         ta.status__c = TEConstant.STATUS_CONFIRMED;
         ta.num_of_leave_days__c = 1;
         ta.Leave_Date__c = ((Datetime)System.Today().adddays(-10)).format('yyyymmdd') +';'+ ((Datetime)System.Today().adddays(-8)).format('yyyymmdd') +';'+ ((Datetime)System.Today().adddays(-9)).format('yyyymmdd');
         upsert ta; 
         upsert  new Leave_balance__c (
            Leave_Type_Code__c =  LeaveTypeMap.get( 'HKO Compensation LeaveT' ).id,
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
         
         Test.startTest();
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();
             for ( Leave_Available_Time__c reader : 
             [
                Select id, Name, LEAVE_TYPE__C, COST__C, TIMESET__C, 
                AVAILABLE_START_TIME_HOUR__C, AVAILABLE_END_TIME_HOUR__C 
                from Leave_Available_Time__c
                where 
                LEAVE_TYPE__C = :LeaveTypeMap.get( 'HKO Compensation LeaveT' ).id
                and TIMESET__C = :TimeSetMap.get( 'HKO_TS1' ).id 
                
                
             ]){
                 if ( stringLeaveStartTime == '' ){             
                     stringLeaveStartTime = reader.id;
                 }
                 stringLeaveEndTime = reader.id;
             
             }
             for(LeaveSection leaveSec : eleaveCtrl.ListLeaveSection){
                 leaveSec.leavetransaction.travel_Application__c = ta.id;
                 leaveSec.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Compensation LeaveT' ).id;                 
                 leaveSec.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 25);
                 leaveSec.leavetransaction.To_Date__c = Date.newInstance(2015, 4, 25);
                 leaveSec.stringLeaveStartTime = stringLeaveStartTime;
                 leaveSec.stringLeaveEndTime = stringLeaveEndTime;
                 leaveRequestList.add(leaveSec.leavetransaction);
             }
             prf = eleaveCtrl.SaveAction();
             system.assertEquals(prf, null);
         }         
         Test.stopTest(); 
     }
     
     @isTest
     public static void errorCheck() {
         String result = '';
         Boolean bResult = false;
         String LeavepolicyId = '';
         Preparation(false);
         Date testingHoliday = Date.newInstance(2015, 3, 21);
         
         for(Leave_policy__c r : [select id, Name  from Leave_policy__c  where name = 'HKO']){
             LeavepolicyId = r.id;
         }
         upsert new Holiday__c(
            Name = 'Holiday Testing',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = LeavepolicyId 
         );
         
         EleaveValidationsController ev = new EleaveValidationsController();
         result = ev.MandatoryLeaveRequestDeductionChecker(null);
         result += ev.MandatoryLeaveRequestDeductionChecker(0);
         result += ev.MandatoryLeaveRequestDeductionChecker(-2);
         result += ev.AdjustmentLeaveRequestDeductionChecker(0);
         result += ev.AdjustmentLeaveRequestDeductionChecker(-3);
         system.assertNotEquals(result, '');
         bResult = ev.IsHolidayexisting (testingHoliday ,LeavepolicyId , null );
         bResult = ev.IsHolidayexisting (testingHoliday.adddays(10) ,LeavepolicyId , -1);
         bResult = ev.IsHolidayexisting (testingHoliday ,LeavepolicyId , 1);
         system.assertEquals(bResult, true);
     }
     
     @isTest
     public static void searchUser() {
         String result = '';
         String LeavepolicyId = '';
         Preparation(false);
         result  = EleaveController.searchEmployeesJson('u');
         result  +=EleaveController.searchUsersJson('u');
         system.assertNotEquals(result, '');
     }
     
}