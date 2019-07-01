@isTest
public class TestEmployeeNotificationBatch
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
    
    /*
        Test: Submit EmployeeNotificationBatch
    */
    @isTest//(SeeAllData=true)
    public static void submitEmployeeNotificationBatch() {
        Preparation(false);
        CS_Notification_Management__c forfeitReminder = new CS_Notification_Management__c (name = 'Leave_Forfeit_Notification');
        insert forfeitReminder ;
        EmployeeMap = new Map<String, Employee__c>( [select id, Full_Name__c, Name,Department__c, User__c  from Employee__C ]);
        Test.startTest(); 
        System.runAs(UserMap.get('user1')) {
            EmployeeNotificationBatch employeeNotification = new EmployeeNotificationBatch();
            employeeNotification.start(null);
            employeeNotification.execute(null,EmployeeMap.values());
            employeeNotification.finish(null);
        }
        Test.stopTest();
    }
}