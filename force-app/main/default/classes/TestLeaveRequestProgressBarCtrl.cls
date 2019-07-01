@isTest
public class TestLeaveRequestProgressBarCtrl
{
    public static Map<String, User> UserMap;
    public static Map<String, Employee__c> EmployeeMap;
    public static Map <String, Leave_Type__c> LeaveTypeMap;     
    public static TestEleavePreparation  EleavePreparation; 
    public static String stringLeaveStartTime;
    public static String stringLeaveEndTime;
    
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
        Test: Leave Request Progress Bar Status
    */
    @isTest
    public static void submitLeaveRequestProgressBar() {
        LeaveRequestProgressBarCtrl leaveRequestProgressBar = null;
        ApexPages.StandardController sc = null;
        Leave_Request__c lr = null;
        EleaveController eLeave = null;
        Preparation(false);
        Test.startTest(); 
        System.runAs(UserMap.get('user1')) {
            eLeave = eLeaveCreation ();
            eLeave.saveAction();
            for ( LeaveSection reader : eLeave.ListLeaveSection) {
                 lr = reader.leavetransaction;
             }
        }
        sc = new ApexPages.StandardController(lr);
        leaveRequestProgressBar = new LeaveRequestProgressBarCtrl (sc);
        system.assertNotEquals(null, leaveRequestProgressBar.MyRequest );
        Test.stopTest(); 
    }

}