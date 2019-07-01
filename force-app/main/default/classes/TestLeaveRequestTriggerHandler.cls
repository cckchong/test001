@isTest
private with sharing class TestLeaveRequestTriggerHandler
{
    
    public static Map<String, User> UserMap ;
    public static Map<String, Employee__c> EmployeeMap ;
    public static Map <String, Leave_Type__c> LeaveTypeMap;     
    public static TestEleavePreparation  EleavePreparation; 
    public static String stringLeaveStartTime;
    public static String stringLeaveEndTime ;
     
    public static void Preparation(Boolean isSeeAllData) {
        EleavePreparation = new TestEleavePreparation (isSeeAllData);
        UserMap = EleavePreparation.getUserMap();
        EmployeeMap = EleavePreparation.getEmployeeMap(UserMap);
        EleavePreparation.setleaveBalanceList (EmployeeMap.values());
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
        LeaveTypeMap = EleavePreparation.LeaveTypeMap;
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
     
     /*
         Type: Leave Request
         Test: Draft leave request
     */
     @IsTest
     public static void saveLeaveRequest() {
         Preparation(true);
         Test.startTest();    
         System.runAs(UserMap.get('user1')) {
             EleaveController eleaveCtrl = eLeaveCreation ();
             eleaveCtrl.saveAction();         
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertEquals(reader.leavetransaction.status__c, LeaveRequestConstant.STATUS_DRAFT);
             }
         }
         Test.stopTest();   
     }
     
     /*
         Type: Leave Request 
         Test: Pending Approval leave request
     */
     @IsTest(SeeAllData = true)
     public static void submitLeaveRequest() {
         Preparation(true);  
         Test.startTest();        
         System.runAs(UserMap.get('user1')) {
             EleaveController eleaveCtrl = eLeaveCreation ();
             eleaveCtrl.submitAction();
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertNotEquals(null, reader.leavetransaction.id );
             }
         }
         Test.stopTest();
     }
     
     /*
         Type: Leave Request 
         Test: Approved leave request
     */
     @IsTest//(SeeAllData = true)
     public static void approvedLeaveRequest() {
         List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
         Approval.ProcessWorkitemRequest approve = new Approval.ProcessWorkitemRequest();
         EleaveController eleaveCtrl;
         Preparation(true);          
         Test.startTest();
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();
             //eleaveCtrl.submitAction(); 
             eleaveCtrl.saveAction(); 
             
         }
           
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
             reader.leavetransaction.status__c = LeaveRequestConstant.STATUS_APPROVED;
             leaveRequestList.add( reader.leavetransaction);
         }
         update leaveRequestList;
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertEquals(reader.leavetransaction.status__c, LeaveRequestConstant.STATUS_APPROVED);
         }
         Test.stopTest();   
         
     }
     
     /*
         Type: Leave Request 
         Test: Reject Approved leave request
     */
     @IsTest(SeeAllData = true)
     public static void rejectApprovedLeaveRequest() {
         Leave_Request__c leaveRequest = null;
         List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
         Approval.ProcessWorkitemRequest approve = new Approval.ProcessWorkitemRequest();
         EleaveController eleaveCtrl;
         Preparation(true);          
         Test.startTest(); 
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ) {
                 reader.changeLeaveType();
             }  
             eleaveCtrl.submitAction();              
         }
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
             leaveRequest = new Leave_Request__c( id = reader.leavetransaction.id, status__c = LeaveRequestConstant.STATUS_REJECT);          
             leaveRequestList.add(leaveRequest);
         }   
         update leaveRequestList;
         for ( Leave_Request__c  reader : leaveRequestList) {
                 system.assertEquals( LeaveRequestConstant.STATUS_REJECT, reader.status__c);
         }
         Test.stopTest();   
         
     }
     
     /*
         Type: Leave Request 
         Test: Pending cancellation leave request
     */
     @IsTest(SeeAllData = true)
     public static void pendingCancellationLeaveRequest() {
         List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
         Approval.ProcessWorkitemRequest approve = new Approval.ProcessWorkitemRequest();
         EleaveController eleaveCtrl;
         Preparation(true);
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();
             eleaveCtrl.saveAction();             
         }
         Test.startTest();         
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
             reader.leavetransaction.status__c = LeaveRequestConstant.STATUS_APPROVED;
             leaveRequestList.add( reader.leavetransaction);
         }
         update leaveRequestList;
         for ( Leave_Request__c reader : leaveRequestList ){
             reader.status__c = LeaveRequestConstant.STATUS_PENDING_CANCELLATION;
         }
         update leaveRequestList;
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                 system.assertEquals(LeaveRequestConstant.STATUS_PENDING_CANCELLATION, reader.leavetransaction.status__c );
         }    
         Test.stopTest(); 
         
     }
     
     /*
         Type: Leave Request 
         Test: Reject cancellation leave request
     */
     @IsTest(SeeAllData = true)
     public static void rejectCancellationLeaveRequest() {
         List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
         EleaveController eleaveCtrl;
         Preparation(true);          
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();
             eleaveCtrl.saveAction();             
         }
         Test.startTest();  
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
             reader.leavetransaction.status__c = 'PC';
             leaveRequestList.add( reader.leavetransaction);
         }
         update leaveRequestList;
         for ( Leave_Request__c reader : leaveRequestList ){
             reader.status__c = LeaveRequestConstant.STATUS_APPROVED;
         }
         update leaveRequestList;
         for ( Leave_Request__c reader : leaveRequestList ) {
                 system.assertNotEquals(null, reader.id);
         }  
         Test.stopTest();   
         
     }
     
     /*
         Type: Leave Request 
         Test: cancellation leave request
     */
     @IsTest(SeeAllData = true)
     public static void cancellationLeaveRequest() {
         List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
         Approval.ProcessWorkitemRequest approve = new Approval.ProcessWorkitemRequest();
         EleaveController eleaveCtrl;
         Preparation(true);
         
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();             
             eleaveCtrl.saveAction();              
         }
         Test.startTest();
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
             reader.leavetransaction.status__c = 'PC';
             leaveRequestList.add( reader.leavetransaction);
         }
         update leaveRequestList;
         for ( Leave_Request__c reader : leaveRequestList  ){
             reader.status__c = 'CA';
         }
         update leaveRequestList; 
         for ( Leave_Request__c reader : leaveRequestList ) {
                 system.assertNotEquals(null, reader.id);
         }        
         Test.stopTest();
     }
     
     
     /*
         Type: Flexible Leave Request 
         Test: Save a Flexible Leave Request
     */
     @IsTest
     public static void saveFlexibleLeaveRequest() {
         Integer integerDay;
         Leave_Request__c leaveRequest = null;
         Employee__c employee = null;
         Employee_Administrator__c employeeAdministrator = null;
         EleaveController eleaveCtrl;
         Preparation(false);
         Leave_Request__c flexibleLeaveRequest;
         for ( Employee__c reader : EmployeeMap.values() ) {
             if (reader.First_Name__c == 'user1') {
                 employee = reader;
                 //employeeAdmin.put( reader, EmployeeMap.values());
             }
         }
         
         for ( Employee_Administrator__c reader : 
         [
             select id, Employee__c, Employee_Administrator__c from Employee_Administrator__c  where Employee_Administrator__c = :employee.id and Employee__c = :employee.id 
         ]) {
             employeeAdministrator = reader;
         }
         
         Test.startTest(); 
         integerDay = Math.Mod ( Date.newInstance(1900, 1, 7).daysBetween( Date.Today().addDays(1) ),7 );
         if ( integerDay  ==  0 ||  integerDay  ==  6 ){
             flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation( Date.Today().addDays(4), employeeAdministrator, employee );
         }
         else{
             flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation( Date.Today().addDays(1), employeeAdministrator, employee );
         }
          
         
         insert flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_NOT_SUBMITTED, flexibleLeaveRequest.status__c );
         Test.stopTest();   
         
     }
     
     /*
         Type: Flexible Leave Request 
         Test: Submited a Flexible Leave Request
     */
     @IsTest(SeeAllData=true)
     public static void submitFlexibleLeaveRequest() {
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
         Leave_Request__c flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation(  Date.Today().addDays(7).toStartOfWeek().addDays(1), employeeAdministrator, employee );
         flexibleLeaveRequest.Copy_to_1__c = UserMap.get('user1').id;
         flexibleLeaveRequest.Copy_to_2__c = UserMap.get('user2').id;
         flexibleLeaveRequest.Copy_to_3__c = UserMap.get('apr1').id;
         flexibleLeaveRequest.Copy_to_4__c = UserMap.get('apr2').id;
         flexibleLeaveRequest.Copy_to_5__c = UserMap.get('apr3').id;
         flexibleLeaveRequest.Copy_to_6__c = UserMap.get('apr4').id;
         flexibleLeaveRequest.Copy_to_7__c = UserMap.get('actapr1').id;
         flexibleLeaveRequest.Copy_to_8__c = UserMap.get('actapr2').id;
         flexibleLeaveRequest.Copy_to_9__c = UserMap.get('actapr3').id;
         flexibleLeaveRequest.Copy_to_10__c = UserMap.get('actapr4').id;
         
         insert flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_NOT_SUBMITTED, flexibleLeaveRequest.status__c );
         
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_SUBMITTED;
         update flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_SUBMITTED, flexibleLeaveRequest.status__c );
         Test.stopTest(); 
     }
     
     /*
         Type: Flexible Leave Request 
         Test: Cancel a Flexible Leave Request
     */
    @IsTest(SeeAllData=true)
     public static void cancelFlexibleLeaveRequest() {
         Leave_Request__c leaveRequest = null;
         Employee__c employee = null;
         Employee_Administrator__c employeeAdministrator = null;
         EleaveController eleaveCtrl;
         Preparation(true);
         
         for ( Employee__c reader : EmployeeMap.values() ) {
             if (reader.First_Name__c == 'user1') {
                 employee = reader;
                 //employeeAdmin.put( reader, EmployeeMap.values());
             }
         }
         
         for ( Employee_Administrator__c reader : 
         [
             select id, Employee__c, Employee_Administrator__c from Employee_Administrator__c  where Employee_Administrator__c = :employee.id and Employee__c = :employee.id 
         ]) {
             employeeAdministrator = reader;
         }
         
         Test.startTest(); 
         Leave_Request__c flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation(  Date.Today().addDays(7).toStartOfWeek().addDays(1), employeeAdministrator, employee );
         insert flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_NOT_SUBMITTED, flexibleLeaveRequest.status__c );
         
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_SUBMITTED;
         update flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_SUBMITTED, flexibleLeaveRequest.status__c );
         
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_CANCELLED ;
         update flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_CANCELLED , flexibleLeaveRequest.status__c );
         Test.stopTest(); 
     }
     
     /*
         Type: Flexible Leave Request 
         Test: submit a Flexible Leave Request again
     */
     @IsTest(SeeAllData=true)
     public static void resubmitFlexibleLeaveRequest() {
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
         
         Leave_Request__c flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation(  Date.Today().addDays(7).toStartOfWeek().addDays(1), employeeAdministrator, employee );
         insert flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_NOT_SUBMITTED, flexibleLeaveRequest.status__c );
         
         Test.startTest();
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_SUBMITTED;
         update flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_SUBMITTED, flexibleLeaveRequest.status__c );
         
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_CANCELLED ;
         update flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_CANCELLED , flexibleLeaveRequest.status__c );
         
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_NOT_SUBMITTED;
         update flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_NOT_SUBMITTED, flexibleLeaveRequest.status__c );
           
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_SUBMITTED;
         update flexibleLeaveRequest;
         system.assertNotEquals(null, flexibleLeaveRequest.id );
         system.assertEquals(LeaveRequestConstant.STATUS_SUBMITTED, flexibleLeaveRequest.status__c );
         Test.stopTest(); 
     }
     
     /*
         Type: Flexible Leave Request 
         Test: Duplicate Flexible Leave Request
     */
     @IsTest(SeeAllData=true)
     public static void duplicateFlexibleLeaveRequest() {
         Integer integerDay;
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
         Leave_Request__c flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation( Date.Today().addDays(7).toStartOfWeek().addDays(1), employeeAdministrator, employee );         
         insert flexibleLeaveRequest;
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_SUBMITTED;         
         update flexibleLeaveRequest;
         
         Test.startTest(); 
         flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation( Date.Today().addDays(7).toStartOfWeek().addDays(1), employeeAdministrator, employee );         
         try {
             insert flexibleLeaveRequest;
         }
         catch(DmlException e) {
             for (Integer i = 0; i < e.getNumDml(); i++) {
                 system.assertEquals(Label.ELeave_FT_Duplicate_Date, e.getDmlMessage(i) );
             }
         } 
        
         
         flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation(  Date.Today().addDays(7).toStartOfWeek().addDays(2), employeeAdministrator, employee );
         insert flexibleLeaveRequest;
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_SUBMITTED;         
         update flexibleLeaveRequest;
         
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_CANCELLED ;         
         update flexibleLeaveRequest;
          
         integerDay = Math.Mod ( Date.newInstance(1900, 1, 7).daysBetween( Date.Today() ),7 );
         if ( integerDay  ==  0){
             flexibleLeaveRequest.date__c = Date.Today().addDays(3);
         }
         if ( integerDay  ==  6){
             flexibleLeaveRequest.date__c = Date.Today().addDays(3);
         }
         flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_NOT_SUBMITTED;         
         
         try {
             update flexibleLeaveRequest;
         }
         catch(DmlException e) {
             for (Integer i = 0; i < e.getNumDml(); i++) {
                 system.assertEquals(Label.ELeave_FT_Duplicate_Date, e.getDmlMessage(i) );
             }
         }    
         Test.stopTest();            
     }
     
     /*
         Type: Flexible Leave Request 
         Test: Flexible Leave Request Batch 
     */
     @IsTest(SeeAllData=true)
     public static void flexibleLeaveRequestbatch() {         
         List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c>();
         Leave_Request__c flexibleLeaveRequest  = null;
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
         for ( integer i = 1 ; i < 8; i++ ){
             flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation( Date.Today().addDays(i), employeeAdministrator, employee );
             leaveRequestList.add(flexibleLeaveRequest);
         }
         Try {
             insert leaveRequestList;
             for ( Leave_Request__c reader : leaveRequestList) {
                     system.assertNotEquals(null, reader.id);
             }
         }  catch (Exception ex){}
         Test.stopTest();
         
     }  
}