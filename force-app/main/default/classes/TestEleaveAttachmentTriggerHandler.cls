@isTest
public with sharing class TestEleaveAttachmentTriggerHandler
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
         Test: update Supporting Doc
     */
     @IsTest
     public static void updateSupportingDoc() {
         Id leaveRequestId = null;         
         String leaveRequestName = '';
         EleaveController eleaveCtrl = null;
         
         Preparation(true);   
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();
             eleaveCtrl.saveAction();
         }
         
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
             leaveRequestId = reader.leavetransaction.id;
             leaveRequestName = reader.leavetransaction.Name;
         }
         Test.startTest(); 
         Attachment attach = new Attachment (
              ParentId = leaveRequestId,
              Name = leaveRequestName,
              IsPrivate = false,
              ContentType = 'JPG', 
              Body = Blob.valueOf('Unit Test Attachment Body'),
              Description = ''
         );
         insert attach ;
         
         attach.Body = Blob.valueOf('Unit Test Attachment Body Again');
         update attach;
         system.assertNotEquals(null, attach.id);
         Test.stopTest();   
     }
     
      /*
         Test: Delete Supporting Doc
     */
     @IsTest
     public static void deleteSupportingDoc() {
         Id leaveRequestId = null;         
         String leaveRequestName = '';
         Boolean isDelete = true;
         EleaveController eleaveCtrl = null;
         Preparation(true);   
         System.runAs(UserMap.get('user1')) {
             eleaveCtrl = eLeaveCreation ();
             eleaveCtrl.saveAction();
         }
         
         for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
             leaveRequestId = reader.leavetransaction.id;
             leaveRequestName = reader.leavetransaction.Name;
         }
         Test.startTest(); 
         Attachment attach = new Attachment (
              ParentId = leaveRequestId,
              Name = leaveRequestName,
              IsPrivate = false,
              ContentType = 'JPG', 
              Body = Blob.valueOf('Unit Test Attachment Body'),
              Description = ''
         );
         insert attach ;
         delete attach;
         for ( Attachment reader : [select id from Attachment where id = :attach.id] ){
             isDelete = false;
         }
         system.assertEquals(true, isDelete);
         Test.stopTest();   
     }
}