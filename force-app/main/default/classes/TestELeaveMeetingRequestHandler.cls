@IsTest
public class TestELeaveMeetingRequestHandler {
    
    public static Map<String, User> userMap;
    public static User user;
    public static Map<String, Employee__c> employeeMap;
    public static TestEleavePreparation  eleavePreparation;
    public static String stringLeaveStartTime;
    public static String stringLeaveEndTime;
    public static Map <String, Leave_Type__c> leaveTypeMap;
    public static Leave_Request__c leaveRequest;

    public static void Preparation(Boolean isSeeAll) {
        eleavePreparation = new TestEleavePreparation(isSeeAll);
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
    
    
    @IsTest(SeeAllData=true)
    public static void shouldProcessLeave() {
        // Setup
        Preparation(true);
        leaveRequest.from_date__c = Date.today();
        leaveRequest.to_date__c = Date.today();
        leaveRequest.from_hour__c = '09';
        leaveRequest.from_minute__c = '30';
        leaveRequest.to_hour__c = '18';
        leaveRequest.to_minute__c = '30';
        leaveRequest.Status__c = LeaveRequestConstant.STATUS_PENDING_APPROVAL;
        leaveRequest.Leave_Type__c = eleavePreparation.leaveTypeMap.get('HKO Annual LeaveT').id;
        update leaveRequest;
        
        // Test
        leaveRequest.Status__c = LeaveRequestConstant.STATUS_APPROVED;
        update leaveRequest;
        
        // Verify
        leaveRequest = [Select id, name from Leave_Request__c where id = :leaveRequest.id];
        List<Event> events = [Select id, OwnerId, Subject, startDateTime, endDateTime from Event where OwnerId = :user.id and Subject like :('%' + leaveRequest.Name)];
        System.assertEquals(1, events.size());
    }
    
    @IsTest(SeeAllData=true)
    public static void shouldProcessFlexiTime() {
        // Setup
        user = prepareUser();

        Leave_Policy__c leavePolicy = new Leave_Policy__c(Name = 'Unit Test'
                                                            , Time_Zone_Offset__c = 0);
        insert leavePolicy;
        
        Time_Set__c timeSet = new Time_Set__c (
            Time_Set_ID__c = 'HKO_TS1T', 
            Name = 'HKO_TS1',
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
                                                            , status__c = LeaveRequestConstant.STATUS_NOT_SUBMITTED
                                                            , date__c = Date.today().addDays(1)
                                                            , Adjustment_mins__c = '+60');
        insert flexiTime;
        
        // Test
        flexiTime.Status__c = LeaveRequestConstant.STATUS_SUBMITTED;
        update flexiTime;
        
        // Verify
        flexiTime = [Select id, name from Leave_Request__c where id = :flexiTime.id];
        List<Event> events = [Select id, OwnerId, Subject, startDateTime, endDateTime from Event where OwnerId = :user.id and Subject like :('%' + flexiTime.Name)];
        System.assertEquals(1, events.size());
    }
}