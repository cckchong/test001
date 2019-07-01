@isTest
public class TestLeaveRequestSupportDocReminderBatch
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
             reader.leavetransaction.From_Date__c = Date.Today().adddays(-15);
             reader.leavetransaction.To_Date__c = Date.Today().adddays(-7) ;
             reader.stringLeaveStartTime = stringLeaveStartTime;
             reader.stringLeaveEndTime = stringLeaveEndTime;
        } 
         
        for ( LeaveSection reader : leaveSectionList ) {
             reader.changeLeaveType();
        }
        return eleaveCtrl;
    }
    
    /*
        Test: Submit Support Doc
    */
    @isTest
    public static void submitSupportDoc() {
        List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c>();
        Set <Id> ids = new Set <Id>();
        EleaveController eleaveCtrl = null;
        Preparation(false);        
        System.runAs(UserMap.get('user1')) {
            eleaveCtrl = eLeaveCreation ();
            eleaveCtrl.saveAction();
            
            for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
                 reader.leavetransaction.status__c = LeaveRequestConstant.STATUS_APPROVED;
                 reader.leavetransaction.Required_Supporting_Document__c = true;
                 leaveRequestList.add( reader.leavetransaction );
                 ids.add (reader.leavetransaction.id);
            }
        
            update leaveRequestList;
            for ( Leave_Request__c reader : leaveRequestList ){
                System.assertEquals(true, reader.Required_Supporting_Document__c);
                System.assertEquals(LeaveRequestConstant.STATUS_APPROVED, reader.status__c);
                System.assertEquals(false, reader.Supporting_Document_Provided__c);
                System.assertEquals(Date.Today().addDays(-7) , reader.To_Date__c);
            }
            leaveRequestList.clear();
            for (Leave_Request__c reader : [select id, Employee_ID__r.User__c,  Employee_ID__r.User__r.id, Name, Notif_Supporting_Doc_Submit__c from Leave_Request__c where id in :ids ]){
                leaveRequestList.add(reader);
            }
            
            CS_Notification_Management__c csNotifi = new CS_Notification_Management__c(
                name = 'Leave_Missing_Doc',
                Activity_Description__c  = 'The following leave requests are still missing supporting document:',
                Activity_Subject__c = 'Leave requests are still missing supporting document',
                Activity_Type__c = 'Other'    
            );
            insert csNotifi;
            
            Test.startTest(); 
            
            LeaveRequestSupportingDocReminderBatch  leaveRequestSupportingDocReminder = new LeaveRequestSupportingDocReminderBatch();
            leaveRequestSupportingDocReminder.start(null);
            leaveRequestSupportingDocReminder.execute(null,leaveRequestList);
            leaveRequestSupportingDocReminder.finish(null);
            Task t = [select id from task];
            System.assertNotEquals(null, t.id);
            
            Test.stopTest();
        }
    }
}