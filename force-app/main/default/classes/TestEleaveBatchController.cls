@isTest
public with sharing class TestEleaveBatchController
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
         Test: new a Leave Request Batch
     */
     @isTest
     public static void newLeaveRequestBatch() {
         PageReference page = null;
         String applicationDate = '';
         Preparation(false);
         System.runAs(UserMap.get('user1')) {
             EleaveBatchController eLeaveBatch = new EleaveBatchController();
             eLeaveBatch.LeaveRequest.Deduction__c = 1;
             eLeaveBatch.changeSite();         
             for ( SelectOption reader : eLeaveBatch.ListLeaveTypeOption){
                 eLeaveBatch.LeaveRequest.Leave_Type__c = reader.getValue();
                 break;
             }
             Test.startTest();
             page = eLeaveBatch.submitAction();
             System.assertNotEquals(null, page );         
             applicationDate = eLeaveBatch.getdateApplicationDate();
             System.assertNotEquals(null, applicationDate );        
             Test.stopTest();
         }
     }
     
     /*
         Test: Duplicate Leave Request
     */
     @IsTest
     public static void duplicateLeaveRequest() {
         PageReference page = null; 
         EleaveController eleaveCtrl = null;
         List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
         Preparation(false);
         EleaveBatchController eLeaveBatch = new EleaveBatchController();
         System.runAs(UserMap.get('user1')) {
              
             eleaveCtrl = eLeaveCreation ();           
             eleaveCtrl.saveAction();   
         }      
         Test.startTest();
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
             reader.leavetransaction.status__c = LeaveRequestConstant.STATUS_APPROVED;
             leaveRequestList.add( reader.leavetransaction);
             eLeaveBatch.LeaveRequest.Leave_Type__c = reader.leavetransaction.Leave_Type__c;
         }
         update leaveRequestList;
         eLeaveBatch.LeaveRequest.Deduction__c = 1;
         eLeaveBatch.LeaveRequest.from_date__c =  Date.newInstance(2015, 3, 20);
         page = eLeaveBatch.submitAction();
         System.assertEquals(null, page );  
         
         Test.stopTest();    
     }
     
     /*
         Test: Checking Deduction Value
     */
     @IsTest(SeeAllData = true)
     public static void checkingDeduction() {
         PageReference page = null;
         EleaveBatchController eLeaveBatch = new EleaveBatchController();         
         eLeaveBatch.changeSite();
         eLeaveBatch.adjustmentSearch();
         Test.startTest();
         page = eLeaveBatch.submitAction();
         System.assertEquals(null, page );
         Test.stopTest();
     }
     
     /*
         Test:  Holiday Check
     */
     @IsTest
     public static void checkingHoliday() {
         PageReference page = null;
         Preparation(false);
         System.runAs(UserMap.get('user1')) {
             EleaveBatchController eLeaveBatch = new EleaveBatchController();
             Test.startTest(); 
             eLeaveBatch.changeSite(); 
             eLeaveBatch.LeaveRequest.From_Date__c = Date.newInstance(2015, 3, 20);
             for ( Holiday__c holiday : [ select date__c, Description__c, type__c, Leave_Policy__c  from Holiday__c ] ){
                  eLeaveBatch.LeaveApplication.Mandatory_Leave_Policy__c = holiday.Leave_Policy__c;
             }
             eLeaveBatch.changeDate();
             
             System.assertNotEquals('', eLeaveBatch.stringErrorMessage);
             Test.stopTest();
         }
     }
     
     /*
         Test: Submit Adj Leave Request
     */
     @IsTest
     public static void adjLeaveRequestBatch() {
         PageReference page = null; 
         EleaveController eleaveCtrl = null;
         List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
         Preparation(false);
         System.runAs(UserMap.get('user1')) {
             EleaveBatchController eLeaveBatch = new EleaveBatchController();
             eleaveCtrl = eLeaveCreation ();           
             eleaveCtrl.saveAction();   
              
             Test.startTest();
             for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
                 reader.leavetransaction.status__c = LeaveRequestConstant.STATUS_APPROVED;
                 leaveRequestList.add( reader.leavetransaction);
                 eLeaveBatch.LeaveRequest.Leave_Type__c = reader.leavetransaction.Leave_Type__c;
             }
             update leaveRequestList;
             
             eLeaveBatch.LeaveRequest.From_Date__c =  Date.newInstance(2015, 3, 16);
             
             eLeaveBatch.LeaveRequest.Deduction__c = -0.4;
             eLeaveBatch.adjustmentSearch();
             
             eLeaveBatch.LeaveRequest.Deduction__c = 1;
             eLeaveBatch.adjustmentSearch();
             
             System.assertEquals(true, eLeaveBatch.getDisplaySearchResult() );
             for ( EleaveBatchController.LeaveRequest reader : eLeaveBatch.leaveRequestSearchResultSet ){
                 reader.setselected(false);             
             }
             eLeaveBatch.changeLeaveRequestSelection();
             for ( EleaveBatchController.LeaveRequest reader : eLeaveBatch.leaveRequestSearchResultSet ){
                 System.assertEquals(true, reader.getselected() );             
             }         
             page = eLeaveBatch.adjustmentSubmitAction();
             System.assertNotEquals(null, page ); 
             Test.stopTest();  
         }   
     }
}