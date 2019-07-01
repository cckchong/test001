@isTest
public class TestELeaveApproveRejectController
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
        Test: Batch Approve
    */
    @isTest(SeeAllData=true)
    public static void approveLeaveRequest() {
        
        Employee__c emp = null;
        Id uid = null;
        String tmp = '';
        PageReference page = null;
        ApexPages.StandardSetController sc = null;
        ELeaveApproveRejectController ApproveReject = null;
        Leave_Request__c lr = null;        
        List <Leave_Request__c> lrList = new List <Leave_Request__c>();        
        Preparation(true);
        uid = UserMap.get('user1').id;         
        
        for ( Employee__c reader : [ select id, Approver_1__c , Approver_2__c, Approver_3__c, Approver_4__c from employee__c where user__c = :uid ]){
            emp = reader;
        }
        emp.Approver_1__c = uid;
        emp.Approver_2__c = uid;
        emp.Approver_3__c = uid;
        emp.Approver_4__c = uid;
        
        emp.Acting_Approver_1__c= uid;
        emp.Acting_Approver_2__c= uid;
        emp.Acting_Approver_3__c= uid;
        emp.Acting_Approver_4__c= uid;
        
        update emp;
        
        
        
        System.runAs(UserMap.get('user1')) {
            Test.startTest();
            EleaveController eleaveCtrl = eLeaveCreation ();
            eleaveCtrl.submitAction();
            
            
            for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
                lrList.add( reader.leavetransaction );
                tmp = reader.leavetransaction.id;
            }
            
            sc = new ApexPages.StandardSetController (lrList);
            sc.setSelected(lrList);
            ApproveReject = new ELeaveApproveRejectController(sc);
            page = ApproveReject.ApproveAction();
            Leave_request__c a = [select id, Approver_1__c,status__c, I_Am_Approver__c , Current_Approver__c    from leave_request__c where id = :tmp];
            system.assertEquals(uid , a.Approver_1__c   );  
            system.assertEquals('AP', a.status__c );  
            Test.stopTest();
        }
         
    }
    
    /*
        Test: Batch Approve
    */
    @isTest(SeeAllData=true)
    public static void rejectLeaveRequest() {
        
        Employee__c emp = null;
        Id uid = null;
        String tmp = '';
        PageReference page = null;
        ApexPages.StandardSetController sc = null;
        ELeaveApproveRejectController ApproveReject = null;
        Leave_Request__c lr = null;        
        List <Leave_Request__c> lrList = new List <Leave_Request__c>();        
        Preparation(true);
        uid = UserMap.get('user1').id;         
        
        for ( Employee__c reader : [ select id, Approver_1__c , Approver_2__c, Approver_3__c, Approver_4__c from employee__c where user__c = :uid ]){
            emp = reader;
        }
        emp.Approver_1__c = uid;
        emp.Approver_2__c = uid;
        emp.Approver_3__c = uid;
        emp.Approver_4__c = uid;
        
        emp.Acting_Approver_1__c= uid;
        emp.Acting_Approver_2__c= uid;
        emp.Acting_Approver_3__c= uid;
        emp.Acting_Approver_4__c= uid;
        
        update emp;
        
        
        
        System.runAs(UserMap.get('user1')) {
            
            EleaveController eleaveCtrl = eLeaveCreation ();
            Test.startTest();
            eleaveCtrl.submitAction();
            
            
            for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
                lrList.add( reader.leavetransaction );
                tmp = reader.leavetransaction.id;
            }
            
            sc = new ApexPages.StandardSetController (lrList);
            sc.setSelected(lrList);
            ApproveReject = new ELeaveApproveRejectController(sc);
            page = ApproveReject.RejectAction();
            Leave_request__c a = [select id, Approver_1__c,status__c, I_Am_Approver__c , Current_Approver__c    from leave_request__c where id = :tmp];
            system.assertEquals(uid , a.Approver_1__c   );  
            system.assertEquals('RJ', a.status__c );  
            Test.stopTest();
        }
         
    }
     
}