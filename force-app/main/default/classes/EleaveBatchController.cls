public without sharing class EleaveBatchController extends EleaveValidationsController 
{ 
    public static final String dateFormat = 'dd MMM yyyy';
    public Leave_Application__c LeaveApplication {get;set;}
    public Leave_Request__c LeaveRequest {get;set;}
    public List<SelectOption> ListLeaveTypeOption {get;set;} 
    public List<SelectOption> ListLeavePolicyOption {get;set;} 
    public List<Leave_Request__c > ListLeaveRequest {get;set;} 
    public List<Leave_Application_Log__c> ListLeaveApplicationLog {get;set;}
    public String stringRecordTypeID = '';
    public String stringParameterID  {get;set;}  // The Application ID if it exists
    public DateTime dateApplicationDate;
    public String stringErrorMessage {get;set;}
    public List <LeaveRequest> leaveRequestSearchResultSet {get;set;}
    public boolean allSelected  {get;set;}
    
    /*
     *   @description EleaveBatchController constructor
     */  
    public EleaveBatchController()
    {
        ListLeaveApplicationLog = new List<Leave_Application_Log__c>();
        leaveRequestSearchResultset = new List <LeaveRequest> ();        
        LeaveApplication = new Leave_Application__c ();
        LeaveRequest = new Leave_Request__c ();
        ListLeaveTypeOption = new List<SelectOption>(); 
        ListLeavePolicyOption = new List<SelectOption>(); 
        stringParameterID = ApexPages.currentPage().getParameters().get('id');
        stringErrorMessage = '';
        allSelected =  false;        
        if ( stringParameterID  == null ){
            LeaveRequest.From_Date__c  = Date.today();
            LeaveRequest.Deduction__c = null;
            for ( RecordType rt :[ SELECT Id FROM RecordType where SobjectType  =  :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME and IsActive = true and DeveloperName = :LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST  ] ){
                stringRecordTypeID = rt.id;
            } 
            for ( Employee__c reader : [ select id , Name, first_name__c, last_name__c, Department__c, Full_Name__c, leave_policy__c, site__c   
                from Employee__c  where user__r.id = :UserInfo.getUserId() and  Is_Active__c = true limit 1 ]){ 
                LeaveRequest.Employee_ID__c =  reader.id;
                LeaveRequest.Employee_ID__r =  reader;
                LeaveRequest.Employee_ID__r.site__c =  reader.site__c;
                LeaveRequest.RecordTypeid  =  stringRecordTypeID  ;              
                LeaveApplication.Mandatory_Leave_Policy__c = reader.leave_policy__c ;
                for ( AggregateResult LeavePolicyResult : [select leave_policy__c, leave_policy__r.Name from employee__c where Is_Active__c = true  and  leave_policy__r.Name != null and  site__r.name != null and site__c = :reader.site__c group by leave_policy__c, leave_policy__r.Name order by leave_policy__r.Name  ] ){
                  ListLeavePolicyOption.add( new SelectOption( (String)LeavePolicyResult.get('leave_policy__c') , (String)LeavePolicyResult.get('Name') ) );
                }
            }
            
            if ( LeaveApplication.Mandatory_Leave_Policy__c != null){
                for( Leave_type__c reader : [ select id,Display_Name__c   from Leave_type__c where Leave_Policy__c = :LeaveApplication.Mandatory_Leave_Policy__c  order by Display_Name__c ] ){
                    ListLeaveTypeOption.add( new SelectOption(reader.id ,reader.Display_Name__c) ) ;
                }
            }
            LeaveApplication.type__c = LeaveRequestConstant.LEAVE_APPLICATION_BATCH ;
        }
        else{
            for (Leave_Request__c lq : [ select From_Hour__c , From_Minute__c ,From_Time__c, To_Hour__c , To_Minute__c ,To_Time__c,   Deduction__c, Leave_type__r.Display_Name__c, From_Date__c , Employee_ID__c, 
                Employee_ID__r.department__c, Employee_ID__r.name,  Employee_ID__r.Full_Name__c, Employee_ID__r.leave_policy__r.name, Employee_ID__r.site__r.name  from Leave_Request__c where Leave_Application__c = :stringParameterID  limit 1 ] ){   
                LeaveRequest = lq;
                dateApplicationDate = lq.From_Date__c;
            }
             
            for ( Leave_Application_Log__c reader : [select name, Employee_ID__c, Leave_Application__c, Type__c   from Leave_Application_Log__c where Leave_Application__c = :stringParameterID  ] ){
                ListLeaveApplicationLog.add(reader);
            }            
        } 
    }
    
    /*
     *   @description inverse all selected function
     */  
    public void changeLeaveRequestSelection()
    {
        for ( LeaveRequest reader : leaveRequestSearchResultSet  ){
            reader.selected = !allSelected; 
        }
        allSelected  = !allSelected;
    }
    
    /*
     *   @description To get application date as locale format
     */   
    public String getdateApplicationDate ()
    {
        if ( dateApplicationDate == null ){
            return '';
        }
        else{
            return  dateApplicationDate.date().format();
        }
    }
    
    /*
     *   @description To set application date
     */   
    public void setdateApplicationDate (DateTime  dateApplicationDate )
    {
        this.dateApplicationDate  = dateApplicationDate ;
    } 
    
    /*
     *   @description To chagne site 
     */   
    public void changeSite ()
    {
        String stringSiteID = LeaveRequest.Employee_ID__r.site__c;
        Boolean first = true; 
        this.ListLeavePolicyOption.clear();
        this.ListLeaveTypeOption.clear(); 
        LeaveApplication.Mandatory_Leave_Policy__c = null; 
        if ( stringSiteID != null ){
          for ( AggregateResult LeavePolicyResult : [select leave_policy__c, leave_policy__r.Name from employee__c where Is_Active__c = true and site__c = :stringSiteID group by leave_policy__c, leave_policy__r.Name order by leave_policy__r.Name  ] ){
              ListLeavePolicyOption.add( new SelectOption( (String)LeavePolicyResult.get('leave_policy__c') , (String)LeavePolicyResult.get('Name') ) );
              if ( first ){
                  LeaveApplication.Mandatory_Leave_Policy__c = (String)LeavePolicyResult.get('leave_policy__c');
                  changeLeaveType ();
                  first = false;
              }
          }
        }        
    }
    
    /*
     *   @description To change leave type
     */   
    public void changeLeaveType ()
    {         
        this.ListLeaveTypeOption.clear();
        for ( Leave_type__c reader : [ select id,Display_Name__c from Leave_type__c where Leave_Policy__c  = :LeaveApplication.Mandatory_Leave_Policy__c  order by Display_Name__c ] ){
            ListLeaveTypeOption.add( new SelectOption(reader.id ,reader.Display_Name__c) ) ;
        }        
    }
    
    /*
     *   @description to check the adjustemnt/mandatory day.
         if the date is early release or holiday, the error message will return holiday or early relaese message.
     */   
    public void changeDate()
    {
        this.stringErrorMessage = MandatoryLeaveRequestHolidayChecker ( this.LeaveRequest.From_Date__c, this.LeaveApplication.Mandatory_Leave_Policy__c );
    }
    
    /*
     *   @description to submit mandatory leave
     */   
    public PageReference  submitAction ()
    {
        Leave_Application_Log__c LeaveApplicationLog;
        List<Leave_Application_Log__c > ListLeaveApplicationLog = new List<Leave_Application_Log__c > ();
        PageReference acctPage = null;
        Set <String> setEmployeeID = new Set <String>();
        Leave_Request__c  LeaveRequest = new Leave_Request__c ();
        ListLeaveRequest = new List<Leave_Request__c > ();
        String[] timestrings;
        Approval.ProcessSubmitRequest req1 ;
        List <Approval.ProcessSubmitRequest> listreq ;        
        Approval.ProcessResult result;
        String stringmessage = '' ;
        String stringfromdate ='';
        String stringtodate ='';
        listreq = new List <Approval.ProcessSubmitRequest> ();
        stringmessage = MandatoryLeaveRequestDeductionChecker( this.LeaveRequest.Deduction__c  );
        if ( stringmessage != '' ){
           this.LeaveRequest.Deduction__c.addError(stringmessage);
           return acctPage ;
        }
        System.debug ('site__c = ' + this.LeaveRequest.Employee_ID__r.site__c);
        System.debug ('Leave_Policy__c = ' + LeaveApplication.Mandatory_Leave_Policy__c);
        System.debug ('Leave_Type__c = ' + this.LeaveRequest.Leave_Type__c);
        System.debug ('UserId = ' + UserInfo.getUserId());
        for( leave_balance__c lbc : 
             [
                 select id , Available_Balance_Days__c, Employee__c, Employee__r.name
                 from leave_balance__c 
                 where Employee__r.site__c = :this.LeaveRequest.Employee_ID__r.site__c
                 and Employee__r.Leave_Policy__c = :LeaveApplication.Mandatory_Leave_Policy__c  
                 and Leave_Type_Code__c = :this.LeaveRequest.Leave_Type__c
                 and Is_Latest__c = true
         ]){
            if ( lbc.Available_Balance_Days__c > 0 ){
                setEmployeeID.add(lbc.Employee__c);
            }
            else{            
                LeaveApplicationLog  = new Leave_Application_Log__c ();
                LeaveApplicationLog.type__c =  LeaveRequestConstant.NEGATIVE_BALANCE ;
                LeaveApplicationLog.Employee_ID__c = lbc.Employee__r.name;
                ListLeaveApplicationLog.add(LeaveApplicationLog);
            }
        }
        System.debug ('setEmployeeID = ' + setEmployeeID);
        if ( setEmployeeID.isempty() ){
            this.LeaveRequest.addError('Leave requests cannot be created. Please check related employee leave balance.');
            return acctPage ;
        }
        
        stringfromdate = String.valueof((this.LeaveRequest.From_date__c).year()) +'/'+ String.valueof((this.LeaveRequest.From_date__c).month()) +'/'+ String.valueof((this.LeaveRequest.From_date__c).day()) + ' '  ;
        stringfromdate  += this.LeaveRequest.From_Hour__c + ':'+this.LeaveRequest.From_Minute__c;
        stringtodate = String.valueof((this.LeaveRequest.From_date__c).year()) +'/'+ String.valueof((this.LeaveRequest.From_date__c).month()) +'/'+ String.valueof((this.LeaveRequest.From_date__c).day()) + ' '  ;
        stringtodate += this.LeaveRequest.To_Hour__c + ':'+this.LeaveRequest.To_Minute__c;
       
        for ( Leave_Request__c  lqc :
              [
                  select On_Behalf_of__c, On_Behalf_of__r.name
                  from Leave_Request__c  
                  where status__c = :LeaveRequestConstant.STATUS_APPROVED 
                  and RecordTypeid = :stringRecordTypeID 
                  and 
                  (
                      (from__c <= :stringfromdate and to__c   >= :stringtodate) or
                      (from__c >= :stringfromdate and to__c   <= :stringtodate) or
                      (from__c >= :stringfromdate and from__c <= :stringtodate) or
                      (to__c   >= :stringfromdate and to__c   <= :stringtodate)
                  ) 
        ]){
            if ( setEmployeeID.contains(lqc.On_Behalf_of__c) ){                
                LeaveApplicationLog  = new Leave_Application_Log__c ();
                LeaveApplicationLog.type__c =  LeaveRequestConstant.ALREADY_ON_LEAVE;
                LeaveApplicationLog.Employee_ID__c = lqc.On_Behalf_of__r.name;               
                ListLeaveApplicationLog.add(LeaveApplicationLog);
                setEmployeeID.remove( lqc.On_Behalf_of__c );                
            }            
        }
        insert LeaveApplication;
        
        for ( Leave_Application_Log__c  lal : ListLeaveApplicationLog ){
            lal.Leave_Application__c = LeaveApplication.id;
        }
        insert ListLeaveApplicationLog;
        
        if ( !setEmployeeID.isempty() ){
            for ( Employee__c employee : [select id, Timeset__c from Employee__c where id in :setEmployeeID] ){
                LeaveRequest = new Leave_Request__c ();
                LeaveRequest.Apply_date__c = System.now();
                LeaveRequest.On_Behalf_of__c = employee.id;
                LeaveRequest.Employee_ID__c = this.LeaveRequest.Employee_ID__c ;
                LeaveRequest.From_Date__c = this.LeaveRequest.From_Date__c;
                LeaveRequest.To_Date__c = this.LeaveRequest.From_Date__c;
                LeaveRequest.Leave_Type__c= this.LeaveRequest.Leave_Type__c;               
                LeaveRequest.From_Hour__c = this.LeaveRequest.From_Hour__c ;
                LeaveRequest.From_Minute__c = this.LeaveRequest.From_Minute__c ;
                LeaveRequest.To_Hour__c = this.LeaveRequest.To_Hour__c ;
                LeaveRequest.To_Minute__c = this.LeaveRequest.To_Minute__c ;
                LeaveRequest.Deduction__c= this.LeaveRequest.Deduction__c; 
                LeaveRequest.From_Date_Unit_Cost__c  = this.LeaveRequest.Deduction__c;
                LeaveRequest.To_Date_Unit_Cost__c  = 0;
                LeaveRequest.status__c = LeaveRequestConstant.STATUS_NOT_SUBMITTED  ;
                LeaveRequest.Is_Mandatory_Leave_Request__c = true;
                LeaveRequest.RecordTypeid = this.LeaveRequest.RecordTypeid;
                LeaveRequest.Leave_Application__c= LeaveApplication.id;
                ListLeaveRequest.add( LeaveRequest );
            }            
            insert ListLeaveRequest;            
            
            for ( Leave_Request__c lq: ListLeaveRequest){
                req1 =  new Approval.ProcessSubmitRequest(); 
                req1.setObjectId( lq.id );
                listreq.add(req1);                
            }
            Approval.process(listreq);
            
        }
        if ( LeaveApplication.id != null ){
            acctPage =  new PageReference('/'+ LeaveApplication.id ); 
            acctPage.setRedirect(true);
        }
        return acctPage;
    }
    
    /*
     *   @description to submit leave adjustment
     */   
    public PageReference  adjustmentSubmitAction ()
    {
        Leave_Request_log__c LeaveRequestlogItem ;        
        PageReference acctPage = null;
        String stringmessage = '' ;
        string stringLogType = LeaveRequestConstant.LEAVE_REQUEST_LOG_TYPE_ADJUSTMENT ;
        Set <String> setEmployeeID = new Set <String>();        
        ListLeaveRequest = new List<Leave_Request__c > ();
        List<Leave_Request_log__c > ListLeaveRequestLog = new List<Leave_Request_log__c > ();
        
        if ( !leaveRequestSearchResultSet.isEmpty() ){
            for ( LeaveRequest lr : leaveRequestSearchResultSet ){
                if (lr.selected){
                    lr.LeaveRequest.Deduction__c += this.LeaveRequest.Deduction__c ;
                    stringmessage = '\r\n'+label.ELeave_Adj_has_occurred+'\r\n';
                    stringmessage += Label.ELeave_Date + String.valueof(System.now().format(dateFormat )) + '\r\n' ;
                    stringmessage += Label.ELeave_Adjustment + this.LeaveRequest.Deduction__c + '\r\n' ;
                    if ( this.LeaveRequest.Remarks__c != null ){
                        stringmessage += Label.ELeave_Note + this.LeaveRequest.Remarks__c;
                    }
                    stringmessage = stringmessage.unescapeJava().unescapeHtml4();
                    if ( lr.LeaveRequest.Remarks__c == null){
                        lr.LeaveRequest.Remarks__c = stringmessage;
                    }
                    else{
                        lr.LeaveRequest.Remarks__c += stringmessage;
                    }
                    LeaveRequestlogItem = new Leave_Request_log__c ();            
                    LeaveRequestlogItem.Type__c = stringLogType;
                    LeaveRequestlogItem.Date__c = this.LeaveRequest.From_Date__c;
                    LeaveRequestlogItem.From_Hour__c= this.LeaveRequest.From_Hour__c;
                    LeaveRequestlogItem.From_Minute__c= this.LeaveRequest.From_Minute__c;
                    LeaveRequestlogItem.To_Hour__c= this.LeaveRequest.To_Hour__c;
                    LeaveRequestlogItem.To_Minute__c= this.LeaveRequest.To_Minute__c;
                    LeaveRequestlogItem.Deduction__c = this.LeaveRequest.Deduction__c ;
                    LeaveRequestlogItem.Leave_Request_ID__c= lr.LeaveRequest.Name;
                    LeaveRequestlogItem.Leave_Type__c = lr.LeaveRequest.Leave_type__r.Name;
                    LeaveRequestlogItem.Leave_Policy__c = lr.LeaveRequest.On_Behalf_of__r.Leave_policy__r.name;
                    LeaveRequestlogItem.Employee_ID__c = lr.LeaveRequest.On_Behalf_of_Employee_ID__c ; 
                    LeaveRequestlogItem.Employee__c = lr.LeaveRequest.On_Behalf_of__c ; 
                    LeaveRequestlogItem.Employee_Department__c= lr.LeaveRequest.On_Behalf_of_Department__c; 
                    LeaveRequestlogItem.Employee_Full_Name__c= lr.LeaveRequest.On_Behalf_of_Full_Name__c; 
                    LeaveRequestlogItem.site__c = lr.LeaveRequest.On_Behalf_of_Site__c; 
                    LeaveRequestlogItem.Original_Employee_ID__c = lr.LeaveRequest.On_Behalf_of_Site__c; 
                    ListLeaveRequestLog.add (LeaveRequestlogItem );
                    ListLeaveRequest.add(lr.LeaveRequest);
                }
            }
        }
        if ( !ListLeaveRequest.isempty() ){
            update ListLeaveRequest;
        }
        if ( !ListLeaveRequestLog.isempty() ){
            insert ListLeaveRequestLog;
        }
        acctPage =  new PageReference( label.ELeave_Adjust_Log_Page ); 
        acctPage.setRedirect(true);  
        return acctPage; 
    }
    
    public Boolean getDisplaySearchResult() {
        return leaveRequestSearchResultSet .size() > 0; 
    }
    
    
    public void adjustmentSearch() 
    {
        boolean error = false;
        stringErrorMessage   = '';
        leaveRequestSearchResultSet = new List <LeaveRequest>();

       stringErrorMessage  = AdjustmentLeaveRequestDeductionChecker(LeaveRequest.Deduction__c);
       if (  stringErrorMessage != '' )
       {
            error = true;
            LeaveRequest.Deduction__c.adderror(stringErrorMessage);
       }
        
        
        if ( !error )
        {
            if ( LeaveRequest.Deduction__c < 0 ){
                if ( IsHolidayexisting ( LeaveRequest.From_Date__c, LeaveApplication.Mandatory_Leave_Policy__c, Math.abs(LeaveRequest.Deduction__c) ) ){
                    error = false;
                }
                else{
                    error = true;
                    LeaveRequest.From_Date__c.adderror(label.ELeave_Holiday_Setting);
                }
            }
            else{
                error = false;
            }
        }
        
        if ( !error ){
            LeaveRequest lr;
            for ( Leave_Request__c result : [ 
                Select On_Behalf_of__c,On_Behalf_of_Full_Name__c, Name, Leave_Type_Display_Name__c, On_Behalf_of_Original_Employee_ID__c,
                On_Behalf_of_Site__c, From_Date__c, From_Time__c, To_Date__c, To_Time__c,
                Total_Days_Display__c, Remarks__c , Leave_type__r.Display_Name__c,Leave_type__r.Name,
                On_Behalf_of__r.Leave_policy__r.name, On_Behalf_of_Employee_ID__c, On_Behalf_of_Department__c,
                Deduction__c, From_Hour__c, From_Minute__c, To_Hour__c, To_Minute__c
                from Leave_Request__c 
                where Status__c = :LeaveRequestConstant.STATUS_APPROVED  and from_date__c <= :LeaveRequest.From_Date__c and to_date__c >= :LeaveRequest.From_Date__c 
                and Leave_Type__c = :LeaveRequest.Leave_Type__c
                
             ]){
                lr = new LeaveRequest ( result );
                leaveRequestSearchResultSet.add( lr );
            }
        }        
    }
    
    public class LeaveRequest
    {
        public boolean selected;
        public Leave_Request__c  LeaveRequest {get;set;}  
        
        public LeaveRequest( Leave_Request__c  LeaveRequest )
        {
            this.LeaveRequest = LeaveRequest;
            selected= false;
        }
        
        public boolean getselected (  )
        { return this.selected; }
        
        public void setselected ( boolean selected)
        {
            this.selected= selected;
        }
        
    } 
}