@isTest
public class TestLeaveRequestNotificationBatch
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
        Test: Submit EmployeeNotificationBatch
    */
    @isTest(SeeAllData=true)
    public static void submitLeaveRequestNotificationBatch() {
        Set <Id> Ids = new Set <Id>();
        List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
        Preparation(true);
        Test.startTest(); 
        System.runAs(UserMap.get('user1')) {
            EleaveController  eleave = eLeaveCreation ();
            eleave.submitAction();
        
            for ( LeaveSection reader : eleave.ListLeaveSection) {
                Ids.add(reader.leavetransaction.id);
            }
            
            for ( Leave_Request__c reader : [ select id, Notif_Pending_Approval__c from Leave_Request__c where id in :Ids ]){
                leaveRequestList.add(reader);
            }
        }
        LeaveRequestNotificationBatch LeaveRequestNotification = new LeaveRequestNotificationBatch();
        LeaveRequestNotification.start(null);
        LeaveRequestNotification.execute(null, leaveRequestList);
        LeaveRequestNotification.finish(null);
        Test.stopTest();
    }
}