@IsTest
public class TestELeaveCancellationController {
    
    public static Map<String, User> userMap;
    public static User user;
    public static Map<String, Employee__c> employeeMap;
    public static TestEleavePreparation  eleavePreparation;
    public static String stringLeaveStartTime;
    public static String stringLeaveEndTime;
    public static Map <String, Leave_Type__c> leaveTypeMap;
    public static Leave_Request__c leaveRequest;

    public static void Preparation(Boolean seeAllData) {
        eleavePreparation = new TestEleavePreparation(seeAllData);
        userMap = EleavePreparation.getUserMap();
        user = userMap.get('user1');
        employeeMap = EleavePreparation.getEmployeeMap(userMap);
        Employee__c employee = employeeMap.get('Testing (HKOTuser1)');
        Map<Employee__c, List<Employee__c>> employeeAdministratorMap = new Map<Employee__c, List<Employee__c>>();
        List<Employee__c> employees = new List<Employee__c>();
        employees.add(employee);
        employeeAdministratorMap.put(employee, employees);        
        List<Employee_Administrator__c> employeeAdministrators = eleavePreparation.employeeAdministratorCreation(employeeAdministratorMap);        
        Employee_Administrator__c employeeAdministrator = new Employee_Administrator__c();        
        Leave_Application__c leaveApplication = eleavePreparation.leaveApplicationCreation(employee);
        leaveRequest = eleavePreparation.leaveRequestCreation(leaveApplication, employeeAdministrators, employee, employee);
    }
    
    public static User prepareUser() {
        user = new User(username = 'unit_test_user@talgroup.com'
                            , email = 'servicenowdev@weavenow.com'
                            , Firstname = 'FirstName'
                            , Lastname = 'LastName'
                            , Alias = 'UnitTest'
                            , TimeZoneSidKey = UserInfo.getTimeZone().getId()
                            , LocaleSidKey = UserInfo.getLocale()
                            , EmailEncodingKey = 'UTF-8'
                            , ProfileId = UserInfo.getProfileId()
                            , LanguageLocaleKey = UserInfo.getLanguage()
                            , EmployeeNumber = 'UnitTest-Employee'
                            , Physical_Delivery_Address__c = 'UnitTest-Site');
        insert user;
        return user;
    }
    
    @IsTest
    public static void shouldCancelSingleLeave() {
        // Setup
        Preparation(false);
        leaveRequest.from_date__c = Date.today();
        leaveRequest.to_date__c = Date.today();
        leaveRequest.from_hour__c = '09';
        leaveRequest.from_minute__c = '30';
        leaveRequest.to_hour__c = '18';
        leaveRequest.to_minute__c = '30';
        leaveRequest.Status__c = LeaveRequestConstant.STATUS_APPROVED;
        leaveRequest.Leave_Type__c = eleavePreparation.leaveTypeMap.get('HKO Annual LeaveT').id;
        update leaveRequest;
        
        // Test
        ApexPages.StandardController sc = new ApexPages.StandardController(leaveRequest);
        apexpages.currentpage().getparameters().put('id' , leaveRequest.id);
    
        ELeaveCancellationController controller = new ELeaveCancellationController(sc);

        controller.cancel();
        
        // Verify
        leaveRequest = [Select Status__c from Leave_Request__c where id = :leaveRequest.id];
        System.assertEquals('PC', leaveRequest.status__c);
    }

    @IsTest
    public static void shouldCancelMultipleLeave() {
        // Setup
        Preparation(false);
        leaveRequest.from_date__c = Date.today();
        leaveRequest.to_date__c = Date.today();
        leaveRequest.from_hour__c = '09';
        leaveRequest.from_minute__c = '30';
        leaveRequest.to_hour__c = '18';
        leaveRequest.to_minute__c = '30';
        leaveRequest.Status__c = LeaveRequestConstant.STATUS_APPROVED;
        leaveRequest.Leave_Type__c = eleavePreparation.leaveTypeMap.get('HKO Annual LeaveT').id;
        update leaveRequest;
        
        // Test
        List<Leave_Request__c> leaveRequests = new List<Leave_Request__c>();
        leaveRequests.add(leaveRequest);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leaveRequests);
        sc.setSelected(leaveRequests);
        //apexpages.currentpage().getparameters().put('id' , leaveRequest.id);
    
        ELeaveCancellationController controller = new ELeaveCancellationController(sc);

        controller.cancel();
        
        // Verify
        leaveRequest = [Select Status__c from Leave_Request__c where id = :leaveRequest.id];
        System.assertEquals('PC', leaveRequest.status__c);
    }
    
    @IsTest
    public static void shouldNotCancelZeroLeave1() {
        // Setup
        Preparation(false);
        leaveRequest.from_date__c = Date.today();
        leaveRequest.to_date__c = Date.today();
        leaveRequest.from_hour__c = '09';
        leaveRequest.from_minute__c = '30';
        leaveRequest.to_hour__c = '18';
        leaveRequest.to_minute__c = '30';
        leaveRequest.Status__c = LeaveRequestConstant.STATUS_APPROVED;
        leaveRequest.Leave_Type__c = eleavePreparation.leaveTypeMap.get('HKO Annual LeaveT').id;
        update leaveRequest;
        
        // Test
        ApexPages.StandardController sc = new ApexPages.StandardController(leaveRequest);
    
        ELeaveCancellationController controller = new ELeaveCancellationController(sc);

        PageReference pageReference = controller.cancel();
        
        // Verify
        System.assertEquals('javascript: window.history.back();', pageReference.getUrl());
    }
    
    @IsTest
    public static void shouldNotCancelZeroLeave2() {
        // Setup
        Preparation(false);
        leaveRequest.from_date__c = Date.today();
        leaveRequest.to_date__c = Date.today();
        leaveRequest.from_hour__c = '09';
        leaveRequest.from_minute__c = '30';
        leaveRequest.to_hour__c = '18';
        leaveRequest.to_minute__c = '30';
        leaveRequest.Status__c = LeaveRequestConstant.STATUS_APPROVED;
        leaveRequest.Leave_Type__c = eleavePreparation.leaveTypeMap.get('HKO Annual LeaveT').id;
        update leaveRequest;
        
        // Test
        List<Leave_Request__c> leaveRequests = new List<Leave_Request__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leaveRequests);
        sc.setSelected(leaveRequests);
    
        ELeaveCancellationController controller = new ELeaveCancellationController(sc);

        PageReference pageReference = controller.cancel();
        
        // Verify
        System.assertEquals('javascript: alert(\''+ Label.ELeave_Select_One_Record +'\');window.history.back();', pageReference.getUrl());
    }
    
    @IsTest(SeeAllData=true)
    public static void shouldNotCancelLeaveThatNotAllowCancel() {
        // Setup
        Preparation(true);
        leaveRequest.from_date__c = Date.today();
        leaveRequest.to_date__c = Date.today();
        leaveRequest.from_hour__c = '09';
        leaveRequest.from_minute__c = '30';
        leaveRequest.to_hour__c = '18';
        leaveRequest.to_minute__c = '30';
        leaveRequest.Status__c = LeaveRequestConstant.STATUS_CANCELLED;
        leaveRequest.Leave_Type__c = eleavePreparation.leaveTypeMap.get('HKO Annual LeaveT').id;
        update leaveRequest;
        
        // Test
        ApexPages.StandardController sc = new ApexPages.StandardController(leaveRequest);
        ApexPages.currentPage().getParameters().put('id',leaveRequest.id);
    
        ELeaveCancellationController controller = new ELeaveCancellationController(sc);

        PageReference pageReference = controller.cancel();
        
        // Verify
        System.assertNotEquals(null, pageReference.getUrl());
    }
    
    @IsTest(SeeAllData=true)
    public static void shouldCancelSingleFlexiTime() {
        // Setup
        user = prepareUser();

        Leave_Policy__c leavePolicy = new Leave_Policy__c(Name = 'Unit Test'
                                                            , Time_Zone_Offset__c = 0);
        insert leavePolicy;
        
        Time_Set__c timeSet = new Time_Set__c (
            Time_Set_ID__c = 'HKO_TS1T', 
            Name = 'HKO_TS1T',
            Leave_Policy__c = leavePolicy.id,
            MonStartTime1__c = '09:00',
            MonEndTime1__c = '13:00',
            ThuStartTime1__c = '09:00',
            ThuEndTime1__c = '13:00',            
            WedStartTime1__c = '09:00',
            WedEndTime1__c = '13:00',
            TueStartTime1__c = '09:00',
            TueEndTime1__c = '13:00',
            FriStartTime1__c = '09:00',
            FriEndTime1__c = '13:00',
            SatStartTime1__c = '09:00',
            SatEndTime1__c = '13:00',
            SunStartTime1__c = '09:00',
            SunEndTime1__c = '13:00'
        );
        insert timeset;
        
        Employee__c employee = new Employee__c(Leave_Policy__c = leavePolicy.id
                                                , User__c = user.id
                                                , Timeset__c = timeset.id);
        insert employee;
        
        Leave_Request__c flexiTime = new Leave_Request__c(RecordTypeId = [select id from RecordType where DeveloperName = :LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST].id
                                                            , employee_id__c = employee.id
                                                            , on_behalf_of__c = employee.id
                                                            , date__c = Date.today().addDays(1)
                                                            , Adjustment_mins__c = '+60');
        insert flexiTime;
        
        flexiTime.status__c = LeaveRequestConstant.STATUS_SUBMITTED;
        update flexiTime;
        
        // Test
        ApexPages.StandardController sc = new ApexPages.StandardController(flexiTime);
        apexpages.currentpage().getparameters().put('id' , flexiTime.id);
    
        ELeaveCancellationController controller = new ELeaveCancellationController(sc);

        controller.cancel();
        
        // Verify
        flexiTime = [Select Status__c from Leave_Request__c where id = :flexiTime.id];
        System.assertEquals(LeaveRequestConstant.STATUS_CANCELLED, flexiTime.status__c);
    }
    
    //@IsTest
    /*public static void shouldCancel() {
        // Setup
        Leave_Policy__c leavePolicy = new Leave_Policy__c(Name = 'UnitTest');
        leavePolicy.Time_Zone_Offset__c = 0;
        insert leavePolicy;
        
        Leave_Type__c leaveType = new Leave_Type__c();
        leaveType.Name = 'Unit Test Leave Type';
        leaveType.Leave_Type_ID__c = 'Unit Test Leave Type';
        leaveType.Approval_Workflow__c = 'Approval_Workflows_Type_1';
        leaveType.Leave_Policy__c = leavePolicy.id;
        insert leaveType;
        
        Time_Set__c timeSet = new Time_Set__c();
        timeSet.Time_set_ID__c = 'UNIT_TEST_TIME_SET_ID';
        timeSet.Leave_Policy__c = leavePolicy.id;
        insert timeSet;
        
        Leave_Available_Time__c timeSlot = new Leave_Available_Time__c();
        timeSlot.timeset__c = timeSet.id;
        insert timeSlot;
        
        Employee__c employee = new Employee__c();
        employee.Leave_Policy__c = leavePolicy.id;
        employee.timeset__c = timeSet.id;
        employee.approver_1__c = UserInfo.getUserId();
        employee.approver_2__c = UserInfo.getUserId();
        employee.approver_3__c = UserInfo.getUserId();
        employee.approver_4__c = UserInfo.getUserId();
        insert employee;
        
        Leave_Request__c leaveRequest = new Leave_request__c();
        leaveRequest.Employee_ID__c = employee.id;
        leaveRequest.On_Behalf_of__c = employee.id;
        leaveRequest.Leave_Type__c = leaveType.id;
        leaveRequest.actual_approver_1__c = UserInfo.getUserId();
        leaveRequest.actual_approver_2__c = UserInfo.getUserId();
        leaveRequest.actual_approver_3__c = UserInfo.getUserId();
        leaveRequest.actual_approver_4__c = UserInfo.getUserId();
        insert leaveRequest;
        
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(leaveRequest.id);
        
        // Submit on behalf of a specific submitter
        Approval.process(request);
        
        Approval.ProcessWorkitemRequest approve = new Approval.ProcessWorkitemRequest();
//        approve.setComments('Approving request.');
        approve.setAction('Approve');
        approve.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        approve.setWorkitemId(leaveRequest.id);
        Approval.process(approve);

    
        ApexPages.StandardController sc = new ApexPages.StandardController(leaveRequest);
        apexpages.currentpage().getparameters().put('id' , leaveRequest.id);
    
        ELeaveCancellationController controller = new ELeaveCancellationController(sc);

        // Test        
        controller.cancel();
        
        // Verify
        leaveRequest = [Select Status__c from Leave_Request__c where id = :leaveRequest.id];
        System.assertEquals('PC', leaveRequest.status__c);
    }*/
}