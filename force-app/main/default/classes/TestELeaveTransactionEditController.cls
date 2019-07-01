@isTest
private with sharing class TestELeaveTransactionEditController
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
     
    @isTest
    public static void editLeaveRequest() {
        PageReference page = null;
        Leave_Request__c lr = null;
        Preparation(true);          
        System.runAs(UserMap.get('user1')) {            
            EleaveController eleaveCtrl = eLeaveCreation ();
            eleaveCtrl.saveAction();
            for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
                lr = reader.leavetransaction;
            }
           
        }
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lr);
        ELeaveTransactionEditController eLeaveTransactionEdit = new ELeaveTransactionEditController(sc);
        eLeaveTransactionEdit.newaction();
        system.assertEquals(false, eLeaveTransactionEdit.notSupported); 
        
        lr.status__c = LeaveRequestConstant.STATUS_APPROVED;
        update lr; 
        sc = new ApexPages.StandardController(lr);
        eLeaveTransactionEdit = new ELeaveTransactionEditController(sc);
        eLeaveTransactionEdit.newaction();
        system.assertEquals(false, eLeaveTransactionEdit.notSupported);         
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    public static void editflexibleLeaveRequest() {
        
         Leave_Request__c leaveRequest = null;
         Employee__c employee = null;
         Employee_Administrator__c employeeAdministrator = null;
         EleaveController eleaveCtrl = null;
         ApexPages.StandardController sc = null;
         ELeaveTransactionEditController eLeaveTransactionEdit = null;
         Leave_Request__c flexibleLeaveRequest = null;
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
         System.runAs(UserMap.get('user1')) {   
             flexibleLeaveRequest = EleavePreparation.flexibleLeaveRequestCreation( Date.Today().addDays(7).toStartOfWeek().addDays(1), employeeAdministrator, employee );
             insert flexibleLeaveRequest;
             system.assertNotEquals(null, flexibleLeaveRequest.id );
             system.assertEquals(LeaveRequestConstant.STATUS_NOT_SUBMITTED, flexibleLeaveRequest.status__c );
         }
         
         sc = new ApexPages.StandardController(flexibleLeaveRequest);         
         eLeaveTransactionEdit = new ELeaveTransactionEditController(sc);
         
         System.runAs(UserMap.get('user1')) {  
             eLeaveTransactionEdit.newaction();
             system.assertEquals(true, eLeaveTransactionEdit.notSupported);         
             flexibleLeaveRequest.status__c = LeaveRequestConstant.STATUS_SUBMITTED;
             update flexibleLeaveRequest;
             system.assertNotEquals(null, flexibleLeaveRequest.id );
             system.assertEquals(LeaveRequestConstant.STATUS_SUBMITTED, flexibleLeaveRequest.status__c );
          }
         sc = new ApexPages.StandardController(flexibleLeaveRequest);
         eLeaveTransactionEdit = new ELeaveTransactionEditController(sc);
         System.runAs(UserMap.get('user1')) {  
             eLeaveTransactionEdit.newaction();
             system.assertEquals(true, eLeaveTransactionEdit.notSupported); 
         }         
         Test.stopTest();         
    }
}