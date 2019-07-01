/**
 * EleaveController.cls
 * @description main controller for EleaveVFP
 * @author Chi Kong Chong, Andrew Ng
 */
public without sharing class EleaveController extends EleaveValidationsController {
    public static final String REQUIRE_SECOND_LEVEL_APPROVER = 'Require_Second_Level_Approver';    
    public static final String ROUTER_TO_OBJECT = '/o';
    public static final String SPLIT = ' : ';
    public String stringDatetimeFormat {get;set;}
    public String stringDateFormat {get;set;}
    public Boolean booleanError;
    public Employee__c requester {get;set;}
    public Leave_Application__c request {get;set;}
    public DateTime dateApplicationDate; //{get;set;}
    public List <LeaveSection> ListLeaveSection {get;set;}    
    public List <Leave_Type__c> ListLeaveType {get;set;}   
    public List <SelectOption> ListLeaveTypeOption {get;set;}
    public List <SelectOption> ListTravelRequestOption {get;set;}
    public List <Leave_Available_Time__c> listLeaveAvailableTime {get;set;}
    public List <Holiday__c> listHoliday {get;set;}    
    public Map <String, List<Leave_Available_Time__c>> mapLeaveAvailableTime {get;set;}
    public Map <String, Leave_Balance__c> mapLeaveBalance {get;set;}    
    public Boolean editable {get;set;}    
    public Boolean booleanIsExisting {get;set;}
    public String stringParameterID = '';// The Application ID if it exists
    public String stringLeaveRequestHeaderRecordType  {get;set;}
    public String stringLeaveRequestlineRecordType  {get;set;}
    public String stringErrorMsghead  {get;set;}
    public List <Leave_Request__c> listToBeDeleteLeaveRequest;
    public Map <String, Decimal> mapLeaveTypeDeduction {get;set;} { mapLeaveTypeDeduction = new Map <String, Decimal>();}
    Public String EAname {get;set;}
    //Public Map<Id, List<SelectOption>> taComLeaveDateMap {get;set;}
    Public Map<Id, String> taComLeaveMap {get;set;}
    Public Map<Id, Double> taComdaysMap {get;set;}
    /** For Salesforce1 Routing */
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}
    
    /*
     *   @description constructor with a parameter
     */         
    public EleaveController (String stringParameterID) {
        setup ( stringParameterID );
    }     
    
    /*
     *  @description constructor without a parameter
     */     
    public EleaveController () {
        setup ( ApexPages.currentPage().getParameters().get('id') );
    }     
    
    /*
     *  @description initialization setup
     */
    public void setup ( String stringParameterID ){
        this.booleanError = false;
        this.editable = true;
        this.stringLeaveRequestHeaderRecordType = '';
        this.stringLeaveRequestlineRecordType = '';
        this.stringErrorMsghead = '';
        this.booleanIsExisting = false;        
        this.mapLeaveBalance = new Map <String, Leave_Balance__c>();
        this.request = new  Leave_Application__c ();
        this.requester = new Employee__c();
        this.ListLeaveSection = new List <LeaveSection>();
        this.ListLeaveTypeOption = new List<SelectOption>();
        this.ListTravelRequestOption = new List<SelectOption>();
        this.ListLeaveType = new List <Leave_Type__c>();
        this.listLeaveAvailableTime = new List  <Leave_Available_Time__c>();
        this.listToBeDeleteLeaveRequest = new List <Leave_Request__c>();
        this.listHoliday = new List <Holiday__c>();
        this.mapLeaveAvailableTime = new Map<String, List<Leave_Available_Time__c>>();
        //this.taComLeaveDateMap= new Map<Id, List<SelectOption>>();
        this.taComLeaveMap = new Map<Id, String>();
        this.taComdaysMap = new Map<Id, Double>();
        this.stringParameterID = stringParameterID;
        this.dateApplicationDate = DateTime.now();
        
        // Get the login user Date format setting
        for ( Locale_DateTime_Format__c reader : 
            [ 
                select Locale__c, Datetime_Format__c, Date_Format__c  from Locale_DateTime_Format__c where Locale__c = :userinfo.getlocale()
            ]){
                this.stringDatetimeFormat = reader.Datetime_Format__c;
                this.stringDateFormat = reader.Date_Format__c;
        }
        
        for ( RecordType reader :  
            [ 
                SELECT Id, SobjectType
                FROM RecordType 
                WHERE DeveloperName = :LeaveRequestConstant.LEAVE_DeveloperName
                AND SobjectType IN ( :LeaveRequestConstant.LEAVE_APPLICATION_OBJECT_NAME, :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME ) 
            ]){                    
                if (reader.SobjectType == LeaveRequestConstant.LEAVE_APPLICATION_OBJECT_NAME ) {
                    this.stringLeaveRequestHeaderRecordType = reader.Id;                
                } else if (reader.SobjectType == LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME ) {
                    this.stringLeaveRequestlineRecordType = reader.Id;                
                }
        }
        
        // Check if we're edit mode or not
        if ( this.stringParameterID == null ) {
            newLeaveRequestSetup();
        }
        else{
            existingLeaveRequestSetup( stringParameterID );
        }
        
        //Get on behalf of employee leave type balance
        for( Leave_Balance__c LeaveBalance : [
                select id, Available_Balance_Days__c,
                Leave_Type_Code__r.id, Opening_Balance_Days__c, Leave_Type_Code__r.name,
                Remaining_Balance__c,Remaining_Balance_Current_Display__c, Leave_Type_Code__r.Allow_Advanced_Leave__c
                from Leave_Balance__c 
                where Employee__c = :request.Employee_ID__c  
                and is_latest__c = true
        ]){ 
            this.mapLeaveBalance.put ( LeaveBalance.Leave_Type_Code__r.id, LeaveBalance);
        }
        
        //Get total day of each leave type for the on behalf of employee
        for ( AggregateResult resultset : [
            select   Leave_Type__c, calendar_year(date__c) date_year, calendar_month(date__c) date_month, sum(Deduction__c) Deduction
            from Leave_Request_log__c
            where 
            Employee__c = :request.Employee_ID__c
            group by Leave_Type__c, calendar_year (date__c), calendar_month (date__c)
        ]){
                        
            this.mapLeaveTypeDeduction.put( String.valueof(resultset.get('date_year')) + '_' + String.valueof(resultset.get('date_month')) + '_' + (string)resultset.get('Leave_Type__c'), (Decimal)resultset.get('Deduction') );
        }
        
        //Get related holiday and early release
        if ( this.listHoliday.isempty() ){
            for ( Holiday__c holiday : getHolidayList() ){
                this.listHoliday.add(holiday);
            }           
        }
    }
    
    /*
     *  @description initialization exiting leave request setup
     */
    public void existingLeaveRequestSetup( String stringParameterID ){
        Set <String> setRequest = new Set <String>();
        Set <ID> setLRLeaveTypeID = new Set <ID>();
        Set <ID> setLRTimeSetID = new Set <ID>();
        List <Leave_Available_Time__c> listLAT = new List <Leave_Available_Time__c>();
        Employee__c onBeHalfEmployee = new Employee__c();
        this.booleanIsExisting = true;
        this.editable = false;
        
        //Get the leave request header
        for( Leave_Application__c requestreader : 
           [
                SELECT Name, Employee_ID__c, Employee_ID__r.Name,
                Employee_ID__r.Full_Name__c, Employee_ID__r.Department__c, 
                Employee_ID__r.Timeset__c,
                Employee_ID__r.Acting_Approver_1__c, Employee_ID__r.Acting_Approver_2__c, 
                Employee_ID__r.Acting_Approver_3__c, Employee_ID__r.Acting_Approver_4__c, 
                Employee_ID__r.Approver_1__c, Employee_ID__r.Approver_2__c, 
                Employee_ID__r.Approver_3__c, Employee_ID__r.Approver_4__c,
                CreatedDate, OwnerId, Remarks__c,
                CC_1__c, CC_2__c, CC_3__c, CC_4__c, CC_5__c,
                CC_6__c, CC_7__c, CC_8__c, CC_9__c, CC_10__c,
                CC_1__r.name, CC_2__r.name, CC_3__r.name, CC_4__r.name, CC_5__r.name,
                CC_6__r.name, CC_7__r.name, CC_8__r.name, CC_9__r.name, CC_10__r.name,
                Employee_ID__r.Timeset__r.Is_Mon_Available__c, Employee_ID__r.Timeset__r.Is_Tue_Available__c, Employee_ID__r.Timeset__r.Is_Wed_Available__c,
                Employee_ID__r.Timeset__r.Is_Thu_Available__c, Employee_ID__r.Timeset__r.Is_Fri_Available__c, Employee_ID__r.Timeset__r.Is_Sat_Available__c,
                Employee_ID__r.Timeset__r.Is_Sun_Available__c, Employee_ID__r.Leave_Policy__r.Leave_Soft_Doc_Require__c, Employee_ID__r.Leave_Policy__r.Leave_Hard_Doc_Require__c,
                Employee_ID__r.Employee_Type__r.Entitled_Early_Release__c, Employee_ID__r.Employee_Type__r.Entitled_Public_Holiday__c,
                Employee_Administrator__r.Employee_Full_Name__c, Employee_Administrator__r.Employee_Department__c, 
                Employee_Administrator__r.Employee__r.name, Employee_ID__r.Leave_Policy__c, Employee_ID__r.Leave_Policy__r.Compensation_Leave_Threshold__c,
                Employee_Administrator__r.name, Employee_Administrator__c
                FROM Leave_Application__c 
                WHERE Id = :stringParameterID
                limit 1
        ]){
            this.request = requestreader;
            this.dateApplicationDate = requestreader.CreatedDate;
            this.EAname = requestreader.Employee_Administrator__r.name;
            //Get the leave request available time
            for ( Leave_Available_Time__c leaveAvailableTimeReader : [
            SELECT id, Available_Start_Time__c, Available_End_Time__c, Leave_Type__c,
            Timeset__c, Cost__c   
            FROM Leave_Available_Time__c 
            where Timeset__c = :requestreader.Employee_ID__r.Timeset__c 
            order by Leave_Type__c, Available_Start_Time__c asc, Available_End_Time__c  asc
            ]){
                this.listLeaveAvailableTime.add(leaveAvailableTimeReader);
            }                
        }
        
        //Get the on behalf of employee information
        for ( Employee__c  employee : [
            Select Id, Name, first_name__c, last_name__c, department__c, Full_Name__c, 
            Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c, 
            Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c, Timeset__c, Leave_Policy__r.Leave_Soft_Doc_Require__c, Leave_Policy__r.Leave_Hard_Doc_Require__c,
            Leave_Policy__r.Compensation_Leave_Threshold__c
            from Employee__c 
            where user__r.id = :request.OwnerId
            limit 1
        ]){
            this.requester = employee;
        }
        
        //Get the on behalf of employee related Leave Request 
        for (Leave_Request__c  leaverequestreader : [
            SELECT Id, Name, CreatedDate, 
            On_Behalf_of__c, On_Behalf_of__r.Leave_Policy__c, On_Behalf_of__r.Timeset__c,
            On_Behalf_of__r.Timeset__r.Is_Mon_Available__c, On_Behalf_of__r.Timeset__r.Is_Tue_Available__c, 
            On_Behalf_of__r.Timeset__r.Is_Wed_Available__c, On_Behalf_of__r.Timeset__r.Is_Thu_Available__c, 
            On_Behalf_of__r.Timeset__r.Is_Fri_Available__c, On_Behalf_of__r.Timeset__r.Is_Sat_Available__c,
            On_Behalf_of__r.Timeset__r.Is_Sun_Available__c,
            On_Behalf_of__r.Employee_Type__r.Entitled_Early_Release__c, On_Behalf_of__r.Employee_Type__r.Entitled_Public_Holiday__c,
            On_Behalf_of__r.Leave_Policy__r.Leave_Soft_Doc_Require__c, On_Behalf_of__r.Leave_Policy__r.Leave_Hard_Doc_Require__c, 
            On_Behalf_of__r.Leave_Policy__r.Compensation_Leave_Threshold__c,
            Leave_Type__c,Leave_Type__r.Reminder__c, Deduction__c, Travel_Application__c,
            Supporting_Document_Provided__c, 
            Supporting_Document_Uploaded__c,
            From_Hour__c, From_Minute__c, To_Hour__c, To_Minute__c, To_Date__c, From_Date__c,Remarks__c, Advance_Leave__c,
            status__c, Late_Application__c, Is_Editable__c,
            Employee_Administrator__c,Leave_Type__r.Document_Required__c,
            Employee_Administrator__r.Employee__r.name,ChatterFeedId__c, From__c, To__c, Applicant__c,Required_Supporting_Document__c,
            leave_type__r.Deduct_Non_Working_Day__c, leave_type__r.Deduct_Public_Holiday__c, leave_type__r.Deduct_Early_Release__c,
            Leave_Type__r.Lead_Time_Threshold__c, Leave_Type__r.Lead_Time_Above_Threshold__c, Employee_Administrator__r.Employee__c
            FROM Leave_Request__c 
            where Leave_Application__c = :stringParameterID
            order by Name asc            
        ]){
            
            if ( leaverequestreader.Is_Editable__c ){
                this.editable = true;
            }
            //Only insert related leave type while implementing the loop at first time
            if ( this.ListLeaveType.isempty()){
                setLeavetype ( leaverequestreader.On_Behalf_of__r );
            }
            onBeHalfEmployee = leaverequestreader.On_Behalf_of__r;
            setRequest.add(leaverequestreader.id);
            LeaveSection LeveRecord = new  LeaveSection(leaverequestreader, this.ListLeaveType, this.mapLeaveTypeDeduction, this.listLeaveAvailableTime, this.listHoliday  );
            LeveRecord.stringLeaveStartTime = leaverequestreader.From_Hour__c + SPLIT + leaverequestreader.From_Minute__c;
            LeveRecord.stringLeaveEndTime = leaverequestreader.To_Hour__c + SPLIT + leaverequestreader.To_Minute__c;
            setLRLeaveTypeID.add(leaverequestreader.Leave_Type__c );
            setLRTimeSetID.add(leaverequestreader.On_Behalf_of__r.Timeset__c);
            this.ListLeaveSection.add(LeveRecord);
        }
        setTravelRequst (onBeHalfEmployee);
        //Get the employee available time set
        for ( Leave_Available_Time__c lvt : [
                select id, Available_Start_Time__c, Available_End_Time__c,Leave_Type__c, Timeset__c 
                FROM Leave_Available_Time__c 
                where Leave_Type__c = :setLRLeaveTypeID
                and Timeset__c = :setLRTimeSetID
        ]){
            listLAT.add(lvt);
        } 
               
        //Get List of Holiday and Early Release date
        for ( Holiday__c holiday : getHolidayList() ){
            this.listHoliday.add(holiday);
        }
                
        //set leave start and end time for each leave request
        for ( LeaveSection LeveRecord : this.ListLeaveSection ){
            for ( Leave_Available_Time__c lvt : listLAT ){
                if ( lvt.Leave_Type__c == LeveRecord.leavetransaction.Leave_Type__c && lvt.Timeset__c == LeveRecord.leavetransaction.On_Behalf_of__r.Timeset__c ){
                    if ( lvt.Available_Start_Time__c == LeveRecord.stringLeaveStartTime ){
                        LeveRecord.stringLeaveStartTime = lvt.id;
                    }
                    if ( lvt.Available_End_Time__c == LeveRecord.stringLeaveEndTime ){
                        LeveRecord.stringLeaveEndTime = lvt.id;
                    }
                }
            }
            LeveRecord.changeLeaveType();
        }
    }
    
   /*
    *  @description initialization New leave request setup
    */    
    public void newLeaveRequestSetup(){
        LeaveSection leaveSection = null;
        for ( Employee_Administrator__c  reader : 
            [
                select id, Employee_Full_Name__c, Employee_Department__c, Employee__c, name
                from Employee_Administrator__c
                where 
                Is_Employee_Active__c = true
                and Employee_Administrator__r.User__r.Id= :UserInfo.getUserId()                 
                and Employee__r.user__c = :UserInfo.getUserId()                
            ]){
                this.request.Employee_Administrator__c = reader.id;
                this.request.Employee_Administrator__r = reader;  
                this.EAname = reader.name;
        }
        
        for ( Employee__c  employee : 
        [
            Select Id, Name, first_name__c, last_name__c, department__c, Full_Name__c,
            Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c, 
            Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c, Timeset__c,
            Timeset__r.Is_Mon_Available__c, Timeset__r.Is_Tue_Available__c, Timeset__r.Is_Wed_Available__c,
            Timeset__r.Is_Thu_Available__c, Timeset__r.Is_Fri_Available__c, Timeset__r.Is_Sat_Available__c,
            Timeset__r.Is_Sun_Available__c, 
            Employee_Type__r.Entitled_Early_Release__c, Employee_Type__r.Entitled_Public_Holiday__c, Leave_Policy__r.Leave_Soft_Doc_Require__c, Leave_Policy__c,
            Leave_Policy__r.Leave_Hard_Doc_Require__c, Leave_Policy__r.Compensation_Leave_Threshold__c
            from Employee__c 
            where user__r.id = :UserInfo.getUserId()
            limit 1 
        ]) {
            this.requester = employee;
            for ( Leave_Available_Time__c leaveAvailableTimeReader : 
                [
                    SELECT id, Available_Start_Time__c, Available_End_Time__c, Leave_Type__c, Cost__c, Timeset__c
                    FROM Leave_Available_Time__c 
                    where Timeset__c = :employee.Timeset__c
                    and Cost__c != 0 
                    order by Leave_Type__c, Available_Start_Time__c asc, Available_End_Time__c asc
                ]){
                    this.listLeaveAvailableTime.add(leaveAvailableTimeReader);
            }
        }
        Leave_Request__c  leavetransaction = new Leave_Request__c ();
        this.request.Employee_ID__c = this.requester.id;
        this.request.Employee_ID__r = this.requester;
        leavetransaction.Leave_Application__c = this.request.id;
        leavetransaction.Leave_Application__r = this.request;
        leavetransaction.Employee_ID__c = this.requester.id;
        leavetransaction.Employee_ID__r = this.requester;
        leavetransaction.On_Behalf_of__c = this.requester.id;
        leavetransaction.On_Behalf_of__r = this.requester;
        setLeavetype ( this.requester );
        setTravelRequst ( this.requester );
        leaveSection = new LeaveSection( leavetransaction, this.ListLeaveType, this.mapLeaveTypeDeduction, this.listLeaveAvailableTime, this.listHoliday );
        this.ListLeaveSection.add(leaveSection);
    }
   
   
    /**
     * @description set related Travel Request to Leave Request
     */
    public void setTravelRequst ( Employee__c employee )
    {
        Datetime dt;
        String diplayName = '';
        List <Date> tmp = null;
        List <String> datestringList = null;
        Integer year, month, day;
        Integer compensationLeaveThreshold = Integer.valueof(employee.Leave_policy__r.Compensation_Leave_Threshold__c.round(System.RoundingMode.CEILING));
        List <SelectOption> dateOption = null;
        List <Id> TravelApplicationIdList = new List <Id>();
        List <String> tmpDate = new List<String>();
        
        for(LeaveSection reader : ListLeaveSection){
            if (!String.isBlank(reader.leavetransaction.Travel_Application__c)){
                TravelApplicationIdList.add(reader.leavetransaction.Travel_Application__c);
            }            
        }

        this.ListTravelRequestOption.clear();
        this.ListTravelRequestOption.add( new SelectOption( '', 'Select One Travel Request' ) );
        for(Travel_Application__c reader : [select id, Name, leave_date__c,num_of_leave_days__c,
                                            Departure_Date__c, Return_Date__c 
                                            from Travel_Application__c 
                                            where   
                                            status__c = :TEConstant.STATUS_CONFIRMED
                                            and on_behalf_of__r.employee__c = :employee.id
                                            and id not in (select Travel_Application__c 
                                                             from Leave_request__c 
                                                             where Travel_Application__c  != null 
                                                             and status__c in (:LeaveRequestConstant.STATUS_PENDING_APPROVAL, :LeaveRequestConstant.STATUS_APPROVED) 
                                                             and Travel_Application__c not in :TravelApplicationIdList 
                                                          )
                                            and Return_Date__c <= :System.Today()
                                            and Departure_Date__c <= :System.Today().adddays(compensationLeaveThreshold)
        ]){
            if (!String.isBlank(reader.leave_date__c)){
                dateOption = new List<SelectOption>();
                tmp = new List <Date>();
                diplayName =  reader.Name + '--------';
                diplayName += ((DateTime)reader.Departure_Date__c).format(stringDateFormat ) + '--------';
                diplayName += ((DateTime)reader.Return_Date__c).format(stringDateFormat ) + '   ' ;
                this.ListTravelRequestOption.add( new SelectOption(reader.id, diplayName) );
                
                datestringList = reader.leave_date__c.split(';');
                for (String dateReader : datestringList){
                    year = Integer.valueof(dateReader.SubString(0,4));
                    month = Integer.valueof(dateReader.SubString(4,6));
                    day = Integer.valueof(dateReader.SubString(6,8));
                    dt = DateTime.newInstance(year, month, day);
                    dateOption.add(new SelectOption(dateReader, dt.format(stringDateFormat + ' (EEE)')));
                    String a = dt.format(stringDateFormat) +' ('+dt.format('EEE') +')';
                    //tmpdate.add(dt.format(stringDateFormat + ' (EEE)')));
                    tmpDate.add((DateTime.newInstance(year, month, day)).format(stringDateFormat + ' (EEE)'));
                }
                this.taComLeaveMap.put(reader.id, String.join(tmpDate, ', '));
                this.taComdaysMap.put(reader.id, tmpDate.size());
                tmpDate = new List<String>();
                //this.taComLeaveDateMap.put(reader.id, dateOption); 
            }
        }
    }
    
    /**
     * @description set related leave types to Leave Request
     */
    public void setLeavetype ( Employee__c employee )
    {
        this.ListLeaveType.clear();
        this.ListLeaveTypeOption.clear();
        this.ListLeaveTypeOption.add( new SelectOption( '', Label.ELeave_Select_One_Leave_Type ) );
        for ( Leave_Type__c LeaveType : 
        [
            SELECT  id, Name,Display_Name__c, Document_Required__c, Lead_Time_Below_Threshold__c, Lead_Time_Above_Threshold__c,Lead_Time_Threshold__c, Reminder__c, Deduct_Non_Working_Day__c, Deduct_Early_Release__c, Deduct_Public_Holiday__c, Remark_Require__c,
            Allow_Advanced_Leave__c, Allow_Date_Back__c, Leave_Type_ID__c, Allow_Unlimited_Leave_Balance__c, Reference_Travel_Application__c
            FROM Leave_Type__c 
            where IsDeleted = false and Leave_Policy__c = :employee.Leave_Policy__c
            and id in ( select Leave_Type__c from Leave_Available_Time__c where Timeset__c = :employee.Timeset__c   )
            order by Display_Name__c
        ]){
            this.ListLeaveType.add (LeaveType);
            this.ListLeaveTypeOption.add( new SelectOption(LeaveType.id,LeaveType.Display_Name__c) );
        }
    }
    
    /**
     * @description Get related holiday and early release
     */
    public List <Holiday__c> getHolidayList(){
        List <Holiday__c> listHoliday = new List <Holiday__c>();
        for ( Holiday__c holiday : [ 
            select Time__c, Type__c, Date__c, Leave_Policy__c, Day_Of_Week__c, cost__c
            from Holiday__c
            where  Leave_Policy__c = :this.request.Employee_ID__r.Leave_Policy__c
        ]){
            listHoliday.add(holiday);
        }
        return listHoliday;
    }
    
    /**
     * @description Add a new Leave Request line item
     */
    public void addLeaveSection()
    { 
        Leave_Request__c  LeaveRequest = new  Leave_Request__c ();
        LeaveRequest.Leave_Application__c = this.request.id;
        LeaveRequest.Leave_Application__r = this.request;        
        LeaveRequest.Employee_ID__c = this.requester.id;
        LeaveRequest.Employee_ID__r = this.requester;
        LeaveRequest.On_Behalf_of__c= this.request.Employee_ID__c;
        LeaveRequest.On_Behalf_of__r= this.request.Employee_ID__r;
        LeaveSection LeveRecord= new  LeaveSection(LeaveRequest, this.ListLeaveType, this.mapLeaveTypeDeduction, this.listLeaveAvailableTime, this.listHoliday );
        this.ListLeaveSection.add(LeveRecord);
    }
 
    /**
     * @description Remove the selected Leave Request line item
     */
    public void removeLeaveSection()
    {
        List <LeaveSection>  ListLeaveSectionTemp = new List <LeaveSection>();
        
        for ( LeaveSection reader :  this.ListLeaveSection ){
            if ( !reader.booleanechecked ){
                ListLeaveSectionTemp.add(reader);
            }
            else
            if ( reader.leavetransaction.id != null && reader.leavetransaction.status__c == LeaveRequestConstant.STATUS_DRAFT ){
                this.listToBeDeleteLeaveRequest.add(reader.leavetransaction );
            }
        }
        this.ListLeaveSection = ListLeaveSectionTemp;
    }
    
    public PageReference submitAction()
    {
        String stringChatterFeedId = null;
        saveAction(false);
        if ( this.booleanError ){
            return null;
        }
        
        
        
        //prepare leave request to approval process
        List <Approval.ProcessSubmitRequest> listreq = new List <Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest req1 = null;
        for ( LeaveSection   leavesectionreader : ListLeaveSection ){
            if ( leavesectionreader.leavetransaction.status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED || leavesectionreader.leavetransaction.status__c == LeaveRequestConstant.STATUS_DRAFT ){ 
                req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(leavesectionreader.leavetransaction.id );
                listreq.add(req1);
                
            }
        }
         
        //Submit to Approval processes
        Approval.process(listreq);
        if(getIsMobile()) {
            this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.OBJECTID;
            this.mobileRoute.navResultObjectId = stringParameterID;
            return null;

        } else {
            PageReference acctPage = new PageReference('/' + stringParameterID  );
            acctPage.setRedirect(true);
            return acctPage;
        }
    }
    
    /**
     * @description Create leave request chatter post to on behalf of employee
     */
    public ID processCc(Leave_Application__c  theRequest, List<Leave_Request__c> leaveTransactionList) {
        if(theRequest != null && leaveTransactionList != null && !leaveTransactionList.isEmpty()){
            List<Id> usersToMention = new List<Id>();            
            usersToMention = addIdToList(usersToMention, theRequest.CC_1__c);
            usersToMention = addIdToList(usersToMention, theRequest.CC_2__c);
            usersToMention = addIdToList(usersToMention, theRequest.CC_3__c);
            usersToMention = addIdToList(usersToMention, theRequest.CC_4__c);
            usersToMention = addIdToList(usersToMention, theRequest.CC_5__c);
            usersToMention = addIdToList(usersToMention, theRequest.CC_6__c);
            usersToMention = addIdToList(usersToMention, theRequest.CC_7__c);
            usersToMention = addIdToList(usersToMention, theRequest.CC_8__c);
            usersToMention = addIdToList(usersToMention, theRequest.CC_9__c);
            usersToMention = addIdToList(usersToMention, theRequest.CC_10__c);            
            // Process the Chatter text 
            List<Leave_Request__c> requeriedLeaveRequests = 
                [
                    SELECT Id, Leave_Type__c, Leave_Type__r.Display_Name__c, From__c, To__c, Applicant__c
                    FROM Leave_Request__c  
                    WHERE Id IN: leaveTransactionList
                ];
            String chatterText = requeriedLeaveRequests[0].Applicant__c + ' ' + Label.ELeave_Chatter_CC_Message + ' \n\n';
            for( Leave_Request__c  leave : requeriedLeaveRequests){            
                chatterText = chatterText + leave.From__c + ' ' + Label.ELeave_General_To + ' ' + leave.To__c + '\n\n';
            }
            
            Id userId;
            List<Employee__c> theEmployee = [SELECT Id, User__c FROM Employee__c WHERE Id =: leaveTransactionList[0].On_Behalf_of__c];
            if( theEmployee[0].User__c != null ){
                userId = theEmployee[0].User__c;
            } else {
                userId = leaveTransactionList[0].CreatedById;
            }

            return ChatterUtil.simpleTextPostWithMultipleMentions(userId, usersToMention, chatterText);
        }
        return null;
    }
    
    /**
     * @description Add users to mention list
     */
    private List<Id> addIdToList(List <Id> theList, Id theId) {
        if( theId != null ){
            theList.add(theId);
        }        
        return theList;
    }
    
    
    /**
     * @description To save leave request only 
     */
    public PageReference saveAction() {
        return saveAction(true);
    }
    
    /**
     * @description To calculate advance leave
     */
    public void advcal()
    {
        Map <String, Decimal>  tmpmapLeaveBalance = new Map <String, Decimal>();
        Leave_Balance__c tmpLeaveBalance = new Leave_Balance__c ();
        Decimal decRemainingBalance = 0;
        Decimal decDeduction = 0;
        
        for ( String key : this.mapLeaveBalance.keySet()  ){
            tmpmapLeaveBalance.put(key, this.mapLeaveBalance.get(key).Available_Balance_Days__c);
        } 
        for ( LeaveSection reader : this.ListLeaveSection ){ 
            if ( reader.leavetransaction.Leave_Type__c != null ){
                if ( tmpmapLeaveBalance.containskey ( reader.leavetransaction.Leave_Type__c ) ){
                    decRemainingBalance = tmpmapLeaveBalance.get(reader.leavetransaction.Leave_Type__c);
                }
                else{
                    decRemainingBalance = 0;
                }
                if ( reader.leavetransaction.Deduction__c == null ){
                    decDeduction = 0;
                }
                else{
                    decDeduction = reader.leavetransaction.Deduction__c;
                }
                if ( !reader.leavetransaction.Leave_Type__r.Allow_Unlimited_Leave_Balance__c && decRemainingBalance - decDeduction < 0 ){
                    if ( decRemainingBalance < 0 ){
                        reader.leavetransaction.Advance_Leave__c = decDeduction;
                    }
                    else{
                        reader.leavetransaction.Advance_Leave__c = reader.leavetransaction.Deduction__c - decRemainingBalance;
                    } 
                }
                else{
                    reader.leavetransaction.Advance_Leave__c = 0;
                }
                decRemainingBalance = decRemainingBalance -decDeduction;
                tmpmapLeaveBalance.put(reader.leavetransaction.Leave_Type__c, decRemainingBalance);
            }
        }
    }
    
    /**
     * @description To save Leave request
     */
    public PageReference saveAction(boolean booleanReDirectPage)
    {
        PageReference acctPage = null;
        String travelApplicationId = null;
        String stringStartTime = '';
        String stringEndTime = '';
        String id = UserInfo.getUserId();
        List <Leave_Request__c> listNewLeaveTransaction = new List <Leave_Request__c>();
        List <Leave_Request__c> listExistingLeaveTransaction = new List <Leave_Request__c>();
        Set <ID> setExistingLeaveTransactionId = new Set <ID>();
        Map <String, String> tmpmapLeaveAvailableTime = new Map <String, String>();
        this.stringErrorMsghead = '';
        List <Leave_Request__c> listFlexiTimeLeaveRequest = new List <Leave_Request__c>();            
        advcal();
        for ( Leave_Available_Time__c LeaveAvailableTime : [
                SELECT 
                id, Available_Start_Time__c, Available_End_Time__c 
                FROM Leave_Available_Time__c
                where Timeset__c = :request.Employee_ID__r.Timeset__c
            ]){
            if ( LeaveAvailableTime.Available_Start_Time__c != null && LeaveAvailableTime.Available_End_Time__c != null ){
                tmpmapLeaveAvailableTime.put (LeaveAvailableTime.id, LeaveAvailableTime.Available_Start_Time__c + '/' + LeaveAvailableTime.Available_End_Time__c );
            }
        }
        
        //To get existing pending approcal and Approved Leave request
        for ( Leave_Request__c  LeaveRequest : 
            [ 
                SELECT name, from_date__c, to_date__c, from__c, to__c, From_Hour__c, From_Minute__c, To_Hour__c, To_Minute__c
                FROM Leave_Request__c 
                WHERE status__c in ( :LeaveRequestConstant.STATUS_PENDING_APPROVAL, :LeaveRequestConstant.STATUS_PENDING_CANCELLATION, :LeaveRequestConstant.STATUS_APPROVED ) 
                AND On_Behalf_of__c = :request.Employee_ID__c
        ]){
            listNewLeaveTransaction.add( LeaveRequest );
        }
        
        for ( LeaveSection reader : this.ListLeaveSection ){
            if ( reader.leavetransaction.name == null || reader.leavetransaction.status__c == LeaveRequestConstant.STATUS_CANCELLED || reader.leavetransaction.status__c == LeaveRequestConstant.STATUS_DRAFT || reader.leavetransaction.status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED ){
                if ( reader.stringLeaveStartTime != null && reader.stringLeaveEndTime != null ){
                    stringStartTime = tmpmapLeaveAvailableTime.get(reader.stringLeaveStartTime).split('/')[0];
                    stringEndTime = tmpmapLeaveAvailableTime.get(reader.stringLeaveEndTime).split('/')[1];
                    reader.leavetransaction.From_Hour__c = stringStartTime.split(SPLIT)[0];
                    reader.leavetransaction.From_Minute__c = stringStartTime.split(SPLIT)[1];
                    reader.leavetransaction.To_Hour__c = stringEndTime.split(SPLIT)[0];
                    reader.leavetransaction.To_Minute__c = stringEndTime.split(SPLIT)[1];
                    /*
                    reader.leavetransaction.Compensation_Date__c = null;
                    if (this.request.travel_application__c != null && reader.comDate != '' && reader.leavetransaction.leave_type__r.Reference_Travel_Application__c){
                        reader.leavetransaction.Compensation_Date__c = Date.newInstance(Integer.valueof(reader.comDate.SubString(0,4)),Integer.valueof(reader.comDate.SubString(4,6)),Integer.valueof(reader.comDate.SubString(6,8)))  ;
                    }
                    if (reader.leavetransaction.Compensation_Date__c == null){
                         reader.comDate = '';
                    }
                    */
                    listNewLeaveTransaction.add(reader.leavetransaction);
                    if ( reader.leavetransaction.status__c == LeaveRequestConstant.STATUS_CANCELLED ){
                        reader.leavetransaction.status__c = LeaveRequestConstant.STATUS_NOT_SUBMITTED;
                    }
                }
            }
        }
        this.booleanError = false;
        if ( this.ListLeaveSection.size () == 0  ){
            this.stringErrorMsghead += Label.ELeave_Missing_Request;
        }
        
        if ( this.stringErrorMsghead != '' ){
            this.booleanError = true;
            return acctPage;
        }
        listFlexiTimeLeaveRequest = getFlexiTimeLeaveRequestList ();
        leaveRequestValidation( listFlexiTimeLeaveRequest, listNewLeaveTransaction, ListLeaveSection, tmpmapLeaveAvailableTime, request);
        if ( this.booleanError ){
            return acctPage;
        }        
        if ( !this.listToBeDeleteLeaveRequest.isempty() ){
            delete this.listToBeDeleteLeaveRequest;
        }        
        listNewLeaveTransaction = new List <Leave_Request__c>();
        this.request.Employee_ID__c = this.request.Employee_Administrator__r.Employee__c;
        this.request.RecordTypeId = this.stringLeaveRequestHeaderRecordType;
        this.request.Type__c = LeaveRequestConstant.LEAVE_APPLICATION_INDIVIDUAL;
        /*
        travelApplicationId = this.request.travel_application__c;
        this.request.travel_application__c = null;
        for ( LeaveSection reader : this.ListLeaveSection ){
            if(reader.leavetransaction.Compensation_Date__c != null){
                this.request.travel_application__c = travelApplicationId;
            }
        }
        */
        if ( this.request.Remarks__c != null ){
            if ( this.request.Remarks__c.length() > 255 ){            
                this.request.Remarks__c = this.request.Remarks__c.substring(0,255) ;
            }
        }       
        if ( this.request.id == null ){
            this.request.OwnerId = UserInfo.getUserId();
            insert this.request;            
        }
        else{
            update this.request;
        }
        stringParameterID = request.id;
        this.request = getLeaveApplication ( stringParameterID );
        leaveRequestSetting( tmpmapLeaveAvailableTime );
        for ( LeaveSection reader : this.ListLeaveSection ){
            reader.leavetransaction.Copy_to_1__c = this.request.CC_1__c;
            reader.leavetransaction.Copy_to_2__c = this.request.CC_2__c;
            reader.leavetransaction.Copy_to_3__c = this.request.CC_3__c;
            reader.leavetransaction.Copy_to_4__c = this.request.CC_4__c;
            reader.leavetransaction.Copy_to_5__c = this.request.CC_5__c;
            reader.leavetransaction.Copy_to_6__c = this.request.CC_6__c;
            reader.leavetransaction.Copy_to_7__c = this.request.CC_7__c;
            reader.leavetransaction.Copy_to_8__c = this.request.CC_8__c;
            reader.leavetransaction.Copy_to_9__c = this.request.CC_9__c;
            reader.leavetransaction.Copy_to_10__c = this.request.CC_10__c;
            if ( reader.leavetransaction.Remarks__c != null ){
                if ( reader.leavetransaction.Remarks__c.length() > 255 ){
                    reader.leavetransaction.Remarks__c = reader.leavetransaction.Remarks__c.substring(0,255) ;
                }
            }
            if ( reader.leavetransaction.id == null ){
                listNewLeaveTransaction.add (reader.leavetransaction);
            }
            else
            if ( reader.leavetransaction.status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED || reader.leavetransaction.status__c == LeaveRequestConstant.STATUS_DRAFT ){
                listExistingLeaveTransaction.add (reader.leavetransaction);
            }
        }        
        if (!listNewLeaveTransaction.isEmpty()) {
            insert listNewLeaveTransaction;
        }        
        if (!listExistingLeaveTransaction.isEmpty()) {
            update listExistingLeaveTransaction;
        }        
        for ( Leave_Request__c  leaverequestreader : listNewLeaveTransaction ){
            setExistingLeaveTransactionId.add(leaverequestreader.id);
        }        
        for ( Leave_Request__c  leaverequestreader : listExistingLeaveTransaction){
            setExistingLeaveTransactionId.add(leaverequestreader.id);
        }
        for ( Leave_Request__c  leaverequest :
        [
            SELECT  id, Name, From_Date__c, To_Date__c,Leave_Type__r.Reminder__c,Is_Editable__c, 
            Supporting_Document_Provided__c, Supporting_Document_Uploaded__c,
            Remarks__c, Leave_Type__r.Document_Required__c, Employee_ID__r.Leave_Policy__r.Leave_Hard_Doc_Require__c,
            Employee_ID__r.Leave_Policy__r.Compensation_Leave_Threshold__c,
            Employee_ID__r.Name, Employee_ID__r.Full_Name__c,  Employee_ID__r.Department__c, 
            Employee_ID__c, On_Behalf_of__c, //travel_application__c,
            On_Behalf_of__r.Acting_Approver_1__c, On_Behalf_of__r.Acting_Approver_2__c, On_Behalf_of__r.Acting_Approver_3__c, On_Behalf_of__r.Acting_Approver_4__c,
            On_Behalf_of__r.Approver_1__c, On_Behalf_of__r.Approver_2__c, On_Behalf_of__r.Approver_3__c, On_Behalf_of__r.Approver_4__c,
            Leave_Type__c, Deduction__c,status__c, Leave_Type__r.Allow_Advanced_Leave__c, Leave_Type__r.Allow_Date_Back__c, 
            Leave_Type__r.Display_Name__c, Leave_Type__r.Reference_Travel_Application__c,
            Late_Application__c, ChatterFeedId__c, From__c, To__c, Applicant__c,Required_Supporting_Document__c, CreatedbyId
            FROM    Leave_Request__c  
            WHERE   id in :setExistingLeaveTransactionId
        ]){
            for ( Leave_Request__c  leaverequestreader : listNewLeaveTransaction ){
                if ( leaverequestreader.id == leaverequest.id ){
                    for ( LeaveSection reader : this.ListLeaveSection ){
                         if( leaverequestreader == reader.leavetransaction ){
                             reader.leavetransaction.id = leaverequest.id;
                         }
                    }
                }
            }
            for ( LeaveSection reader : this.ListLeaveSection ){
                if ( reader.leavetransaction.id == leaverequest.id ){
                    reader.leavetransaction = leaverequest;
                }
            }
        }        
        if ( booleanReDirectPage )
        {
            if(getIsMobile()) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.OBJECTID;
                this.mobileRoute.navResultObjectId = this.request.id;
                return null;
            } else {
                acctPage = new PageReference( '/' + this.request.id );
                acctPage.setRedirect(true);
            }
        }
        return acctPage;
    }
    
    /**
     * @description To modify leave request date before saving leave request
     */
    public void leaveRequestSetting( Map <String, String> tmpmapLeaveAvailableTime )
    {
        String stringStartTime = '';
        String stringEndTime = '';
        for ( LeaveSection reader : this.ListLeaveSection ){
            reader.leavetransaction.Employee_ID__c = this.requester.id;
            reader.leavetransaction.On_Behalf_of__c = this.request.Employee_ID__c;
            if ( reader.leavetransaction.id == null ){
                reader.leavetransaction.Apply_date__c = System.now();
                reader.leavetransaction.Leave_Application__c = this.request.id;
            }            
            stringStartTime = tmpmapLeaveAvailableTime.get(reader.stringLeaveStartTime).split('/')[0];
            stringEndTime = tmpmapLeaveAvailableTime.get(reader.stringLeaveEndTime).split('/')[1];
            reader.leavetransaction.Employee_Administrator__c = this.request.Employee_Administrator__c;
            reader.leavetransaction.From_Hour__c = stringStartTime.split(SPLIT)[0];
            reader.leavetransaction.From_Minute__c = stringStartTime.split(SPLIT)[1];
            reader.leavetransaction.To_Hour__c = stringEndTime.split(SPLIT)[0];
            reader.leavetransaction.To_Minute__c = stringEndTime.split(SPLIT)[1];
            reader.leavetransaction.Acting_Approver_1__c = this.request.Employee_ID__r.Acting_Approver_1__c;
            reader.leavetransaction.Acting_Approver_2__c = this.request.Employee_ID__r.Acting_Approver_2__c;
            reader.leavetransaction.Acting_Approver_3__c = this.request.Employee_ID__r.Acting_Approver_3__c;
            reader.leavetransaction.Acting_Approver_4__c = this.request.Employee_ID__r.Acting_Approver_4__c;
            reader.leavetransaction.Approver_1__c = this.request.Employee_ID__r.Approver_1__c;
            reader.leavetransaction.Approver_2__c = this.request.Employee_ID__r.Approver_2__c;
            reader.leavetransaction.Approver_3__c = this.request.Employee_ID__r.Approver_3__c;
            reader.leavetransaction.Approver_4__c = this.request.Employee_ID__r.Approver_4__c;
            reader.leavetransaction.Actual_Approver_1__c = reader.leavetransaction.Acting_Approver_1__c != null ? reader.leavetransaction.Acting_Approver_1__c : reader.leavetransaction.Approver_1__c;
            reader.leavetransaction.Actual_Approver_2__c = reader.leavetransaction.Acting_Approver_2__c != null ? reader.leavetransaction.Acting_Approver_2__c : reader.leavetransaction.Approver_2__c;
            reader.leavetransaction.Actual_Approver_3__c = reader.leavetransaction.Acting_Approver_3__c != null ? reader.leavetransaction.Acting_Approver_3__c : reader.leavetransaction.Approver_3__c;
            reader.leavetransaction.Actual_Approver_4__c = reader.leavetransaction.Acting_Approver_4__c != null ? reader.leavetransaction.Acting_Approver_4__c : reader.leavetransaction.Approver_4__c;
            
            if ( reader.leavetransaction.status__c == LeaveRequestConstant.STATUS_CANCELLED || reader.leavetransaction.status__c == LeaveRequestConstant.STATUS_REJECT ){
                reader.leavetransaction.status__c = LeaveRequestConstant.STATUS_NOT_SUBMITTED;
            }
            
            if ( reader.leavetransaction.id == null ){
                reader.leavetransaction.RecordTypeId = this.stringLeaveRequestlineRecordType;
                reader.leavetransaction.status__c = LeaveRequestConstant.STATUS_DRAFT;                
            }
        }
    }
    
    /**
     * @description To get leave request head level (leave application) date
     */
    public Leave_Application__c getLeaveApplication ( String stringParameterID ) {
        return 
        [ 
            select id, name, 
            CC_1__c, CC_2__c, CC_3__c, CC_4__c, CC_5__c,
            CC_6__c, CC_7__c, CC_8__c, CC_9__c, CC_10__c,
            CC_1__r.name, CC_2__r.name, CC_3__r.name, CC_4__r.name, CC_5__r.name,
            CC_6__r.name, CC_7__r.name, CC_8__r.name, CC_9__r.name, CC_10__r.name,
            Remarks__c, 
            Employee_ID__c, Employee_ID__r.Full_Name__c, Employee_ID__r.Department__c, 
            Employee_ID__r.Acting_Approver_1__c, Employee_ID__r.Acting_Approver_2__c, 
            Employee_ID__r.Acting_Approver_3__c, Employee_ID__r.Acting_Approver_4__c, 
            Employee_ID__r.Approver_1__c, Employee_ID__r.Approver_2__c, 
            Employee_ID__r.Approver_3__c, Employee_ID__r.Approver_4__c,
            Employee_ID__r.Leave_Policy__r.Leave_Hard_Doc_Require__c,
            Employee_ID__r.Leave_Policy__r.Leave_Soft_Doc_Require__c,
            Employee_ID__r.Leave_Policy__r.Compensation_Leave_Threshold__c,
            Employee_Administrator__c,
            Employee_Administrator__r.Name,            
            Employee_Administrator__r.id, Employee_Administrator__r.Employee_Full_Name__c, 
            Employee_Administrator__r.Employee_Department__c,
            Employee_Administrator__r.Employee__r.Id, 
            Employee_Administrator__r.Employee__r.Name, 
            Employee_Administrator__r.Employee__r.first_name__c, 
            Employee_Administrator__r.Employee__r.last_name__c, 
            Employee_Administrator__r.Employee__r.department__c, 
            Employee_Administrator__r.Employee__r.Full_Name__c,
            Employee_Administrator__r.Employee__r.Acting_Approver_1__c, 
            Employee_Administrator__r.Employee__r.Acting_Approver_2__c, 
            Employee_Administrator__r.Employee__r.Acting_Approver_3__c, 
            Employee_Administrator__r.Employee__r.Acting_Approver_4__c, 
            Employee_Administrator__r.Employee__r.Approver_1__c, 
            Employee_Administrator__r.Employee__r.Approver_2__c, 
            Employee_Administrator__r.Employee__r.Approver_3__c, 
            Employee_Administrator__r.Employee__r.Approver_4__c, 
            Employee_Administrator__r.Employee__r.Timeset__c,
            Employee_Administrator__r.Employee__r.Timeset__r.Is_Mon_Available__c, 
            Employee_Administrator__r.Employee__r.Timeset__r.Is_Tue_Available__c, 
            Employee_Administrator__r.Employee__r.Timeset__r.Is_Wed_Available__c,
            Employee_Administrator__r.Employee__r.Timeset__r.Is_Thu_Available__c, 
            Employee_Administrator__r.Employee__r.Timeset__r.Is_Fri_Available__c, 
            Employee_Administrator__r.Employee__r.Timeset__r.Is_Sat_Available__c,
            Employee_Administrator__r.Employee__r.Timeset__r.Is_Sun_Available__c, 
            Employee_Administrator__r.Employee__r.Employee_Type__r.Entitled_Early_Release__c, 
            Employee_Administrator__r.Employee__r.Employee_Type__r.Entitled_Public_Holiday__c, 
            Employee_Administrator__r.Employee__r.Leave_Policy__r.Leave_Soft_Doc_Require__c, 
            Employee_Administrator__r.Employee__r.Leave_Policy__c,
            Employee_Administrator__r.Employee__r.Leave_Policy__r.Compensation_Leave_Threshold__c,
            Employee_Administrator__r.Employee__r.Leave_Policy__r.Leave_Hard_Doc_Require__c
            from Leave_Application__c  where id = :stringParameterID limit 1];
    }
    
    /**
     * @description To get leave request head level (leave application) date
     */
    public void leaveRequestValidation(List <Leave_Request__c> listFlexiTimeLeaveRequest, List <Leave_Request__c> listNewLeaveTransaction, List <LeaveSection> ListLeaveSection, Map <String, String> tmpmapLeaveAvailableTime, Leave_Application__c request){
        String msg = '';
        for ( LeaveSection reader : this.ListLeaveSection ){
            if ( reader.leavetransaction.Leave_Type__c != null ){
                if ( !reader.leavetransaction.Is_Editable__c && reader.leavetransaction.id != null  ){
                    continue;
                }
                msg = '';                   
                msg = duplicateflexitimechecker ( reader.leavetransaction, listFlexiTimeLeaveRequest );
                reader.leavetransaction.Require_Second_Level_Approver__c = false;
                if ( msg == REQUIRE_SECOND_LEVEL_APPROVER ){
                    reader.leavetransaction.Require_Second_Level_Approver__c = true;
                    msg = '';
                }
                msg += compensationLeaveChecker(reader.comDate, this.request, reader.leavetransaction, ListLeaveSection);
                msg += leavebalancechecker ( reader.leavetransaction, this.mapLeaveBalance );
                msg += datechecker ( reader.leavetransaction );
                msg += deductionchecker ( reader.leavetransaction.deduction__c  );
                msg += lineremarkchecker ( reader.leavetransaction );
                msg += advancechecker ( reader.leavetransaction  );
                msg += duplicatedatechecker( reader.leavetransaction, listNewLeaveTransaction,tmpmapLeaveAvailableTime, reader.stringLeaveStartTime, reader.stringLeaveEndTime);
                msg += datebackchecker ( reader.leavetransaction.Leave_Type__r, reader.leavetransaction );
            }
            else{
                msg = Label.ELeave_Leave_Type_Selection;
            }
            reader.stringErrorMsg = msg;
            if ( msg != '' ){
                this.booleanError = true;
            }
        }
    }
    
    /**
     * @description To get flexitime leave request
     */
    public List <Leave_Request__c> getFlexiTimeLeaveRequestList (){
        Id OnBehalfofId = null;
        List <Leave_Request__c> listFlexiTimeLeaveRequest = new List <Leave_Request__c>();
        Date minDate = null;
        Date maxDate = null;
        for ( LeaveSection reader : this.ListLeaveSection  ){
            if ( reader.leavetransaction.From_date__c != null && reader.leavetransaction.to_date__c != null ){
                OnBehalfofId = reader.leavetransaction.On_Behalf_of__c;
                if ( maxDate == null ){
                    maxDate = reader.leavetransaction.to_date__c;
                }
                if ( minDate == null ){
                    minDate = reader.leavetransaction.From_date__c;
                }
                if ( maxDate < reader.leavetransaction.to_date__c ){
                    maxDate = reader.leavetransaction.to_date__c;
                }
                if ( minDate > reader.leavetransaction.From_date__c ){
                    minDate = reader.leavetransaction.From_date__c;
                }
            }
        }
        
        if ( minDate != null && maxDate != null ){
            for ( Leave_Request__c reader : 
                [
                    Select id, date__c, RecordTypeId  
                    from Leave_Request__c 
                    where
                    RecordTypeId in ( SELECT Id FROM RecordType where DeveloperName =  :LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST and SobjectType  = :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME and IsActive = true ) 
                    and status__c = :LeaveRequestConstant.STATUS_SUBMITTED
                    and On_Behalf_of__c = :OnBehalfofId 
                    and date__c>= :minDate and date__c <= :maxDate
                ]){
                listFlexiTimeLeaveRequest.add( reader );
            }
        }
        return listFlexiTimeLeaveRequest;
    }
    
    /**
     * @description cancel leave request button
     */
    public PageReference  cancelAction() {
        PageReference acctPage = null;
        Schema.DescribeSObjectResult objid = null;
        if ( this.stringParameterID != null ){
            if(getIsMobile()){
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                return null;                
            } else {
                acctPage = new PageReference( '/' + this.stringParameterID );
                acctPage.setRedirect(true);
                return acctPage;
            }
        } else{
            objid = Leave_Request__c.sObjectType.getDescribe();
            this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
            acctPage = new PageReference( + '/' + objid.getKeyPrefix() + ROUTER_TO_OBJECT );
            return acctPage.setRedirect(true);
        }
    }
    
    /**
     * @description change to other emplotees
     */
    public void changeEmployee()
    { 
        for ( Employee_Administrator__c  reader : 
            [
                select id, Employee_Full_Name__c, Employee_Department__c, 
                Employee__c, name
                from Employee_Administrator__c
                where id = :request.Employee_Administrator__c
                //and Is_Employee_Active__c = true
            ]){
            this.request.Employee_Administrator__c = reader.id;
            this.request.Employee_Administrator__r = reader;
            this.request.Employee_ID__c = reader.Employee__c;   
            this.EAname = reader.name;         
        }
        
        for ( Employee__c employee : 
            [ 
              select  Name, Full_Name__c, Department__c, 
              Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c, 
              Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c, Timeset__c,
              Timeset__r.Is_Mon_Available__c, Timeset__r.Is_Tue_Available__c, 
              Timeset__r.Is_Wed_Available__c, Timeset__r.Is_Thu_Available__c, 
              Timeset__r.Is_Fri_Available__c, Timeset__r.Is_Sat_Available__c,
              Timeset__r.Is_Sun_Available__c, Leave_Policy__r.Leave_Soft_Doc_Require__c, Leave_Policy__r.Leave_Hard_Doc_Require__c,
              Employee_Type__r.Entitled_Public_Holiday__c, Employee_Type__r.Entitled_Early_Release__c, Leave_Policy__c,
              Leave_Policy__r.Compensation_Leave_Threshold__c
              from Employee__c
              where id = :request.Employee_ID__c
              limit 1
          ]){
            this.request.Employee_ID__c = employee.id;
            this.request.Employee_ID__r = employee;
            setLeavetype (employee);
            setTravelRequst (employee); 
            //setTravelRequst (employee);     
          }
          this.listLeaveAvailableTime.clear();
          for ( Leave_Available_Time__c leaveAvailableTimeReader : 
             [
                  SELECT id, Available_Start_Time__c, Available_End_Time__c, Leave_Type__c, Timeset__c, cost__c
                  FROM Leave_Available_Time__c 
                  where Timeset__c = :request.Employee_ID__r.Timeset__c
                  and Cost__c != 0
                  order by Leave_Type__c, Available_Start_Time__c asc, Available_End_Time__c  asc
            ]){
            this.listLeaveAvailableTime.add(leaveAvailableTimeReader);
          }
          
          for ( LeaveSection leavesectionreader : this.ListLeaveSection ){
            leavesectionreader.ListLeaveType = this.ListLeaveType;
            leavesectionreader.leavetransaction.Leave_Type__c = null;
            leavesectionreader.leavetransaction.On_Behalf_of__r = this.request.Employee_ID__r;
            leavesectionreader.leavetransaction.On_Behalf_of__c = this.request.Employee_ID__c;
            leavesectionreader.changeLeaveType(false);
          }
          
          this.mapLeaveBalance.clear(); //Added by TAL (Twinkle LI) @20170802
          for ( Leave_Balance__c LeaveBalance : 
             [                   
                select Available_Balance_Days__c,
                Leave_Type_Code__r.id, Opening_Balance_Days__c, Leave_Type_Code__r.name,
                Remaining_Balance__c,Remaining_Balance_Current_Display__c, Leave_Type_Code__r.Allow_Advanced_Leave__c
                from Leave_Balance__c where Employee__c = :request.Employee_ID__c  
                and is_Latest__c = true
           ]){
               this.mapLeaveBalance.put ( LeaveBalance.Leave_Type_Code__r.id, LeaveBalance);
           }
           
           this.listHoliday.clear();
           for ( Holiday__c holiday : 
               [ 
                    select Time__c, Type__c, Date__c, Leave_Policy__c, Day_Of_Week__c, cost__c
                    from Holiday__c
                    where  Leave_Policy__c = :request.Employee_ID__r.Leave_Policy__c
               ]){
                this.listHoliday.add(holiday );
            }
            
    }

    /**
     * @description Change the application date as locale format
     */
    public String getdateApplicationDate ()
    {
        return  this.dateApplicationDate.date().format();
    }
    
    /**
     * @description Set the application date
     */
    public void setdateApplicationDate (DateTime  dateApplicationDate )
    {
        this.dateApplicationDate = dateApplicationDate;
    }
     
    /**
     * @description Is a mobile device?
     */
    public boolean getIsMobile(){
        return SystemUtil.isMobileDevice();
    }
    
    /** Remote Actions **/    
    @RemoteAction
    public static String searchEmployeesJson(String tempQuery) {
        String response = '';        
        List<Employee_Administrator__c> employeeResultList = new List<Employee_Administrator__c>();        
        tempQuery = '%' + tempQuery + '%';
        for(Employee_Administrator__c a : 
            [
                SELECT Id, Employee__r.Full_Name__c, Employee__r.Department__c, Employee__r.Name, Name
                FROM Employee_Administrator__c
                WHERE (Employee__r.Name LIKE :tempQuery
                OR    Employee__r.Full_Name__c LIKE :tempQuery)
                AND Employee_Administrator__r.User__c =:UserInfo.getUserId()
                ORDER BY Employee__r.Name
                LIMIT 10
            ]){                
            employeeResultList.add(a);
        }
        response = Json.serialize(employeeResultList);                
        return response;
    }
    
    @RemoteAction
    public static String searchUsersJson(String tempQuery) {
        String response = '';        
        List<User> employeeResultList = new List<User>();        
        tempQuery = '%' + tempQuery + '%';
        for( User a : 
            [
                SELECT Id, Name, Email
                FROM User
                WHERE (Name LIKE :tempQuery)
                AND IsActive = true
                ORDER BY Name
                LIMIT 10
            ]){
                
            employeeResultList.add(a);
        }
        response = Json.serialize(employeeResultList);                
        return response;
    } 
}