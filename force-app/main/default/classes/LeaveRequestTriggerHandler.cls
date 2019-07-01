public without sharing class LeaveRequestTriggerHandler 
{
    public static final String SPLIT = ':';
    public static final String MANUAL = Schema.Leave_Request__Share.RowCause.Manual;
    public static final String APPROVER_ACCESS_RIGHT = 'Edit';
    public static final String USER_ACCESS_RIGHT = 'Edit';
    public static final String COPY_TO_USER_ACCESS_RIGHT = 'Read';
    public static final String POLICY_NAME_PATTERN = '@policyname';
    public static final String LOCAL_HCM_GROUP_NAME_PATTERN = 'ELE-@policyname-Admin';  
    List <Id> usersToMention;
    List <Leave_Balance__c> listLeaveBalance;
    List <Leave_Request__c> listnewLeaveRequest;
    List <Leave_Request__c> listCurrentLeaveRequest;
    List <Leave_Available_Time__c> listLeaveAvailableTime;
    List <Holiday__c> listHoliday;
    Set <Id> setUsersToMention;
    Set <Id> setLocalHCMUserId;
    List <Leave_Request__share> listLeaveRequestshare;
    List <Leave_Application__share> listLeaveApplicationshare;
    Set <Leave_Type__c> setLeaveType;    
    Map <Id, String> recordtype;
    Map <Id, Leave_Request__c> oldmapLeaveRequest;
    Map <id, Employee__c> mapEmployee ;
    Map <id, Employee_Administrator__c> mapEmployeeAdministrator ;
    Leave_Request__c oldLeaveRequest;
    Decimal decRemainingBalance; 
    
    private static List<RecordType> leaveRequestRts;
    
    public static List<RecordType> getLeaveRequestRts() {
        if(LeaveRequestTriggerHandler.leaveRequestRts == null) {
            LeaveRequestTriggerHandler.leaveRequestRts = [SELECT Id, DeveloperName FROM RecordType where SobjectType = :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME and IsActive = true];
        }
        
        return LeaveRequestTriggerHandler.leaveRequestRts;
    }
    
    public LeaveRequestTriggerHandler ( List <Leave_Request__c> listnewLeaveRequest, Map<Id,Leave_Request__c> oldmapLeaveRequest  )
    {       
        Set <String> setLocalHCMGroupName = new Set <String>();
        Set <String> setLocalHCMGroupId = new Set <String>();
        Set <Id> setemployeeID = new Set <Id>();
        Set <Id> setLeaveTypeID = new Set <Id>();
        Set <Id> setEmployeeAdministratorID = new Set <Id>();
        Set <Id> setEmployeeTimesetID = new Set <Id>(); 
        Set <Id> setOnBehalfofEmployeePolicy = new Set <Id>(); 
        Set <Id> setLeaveRequestId = new Set <Id>(); 
        Set <Id> setLeaveApplicationId = new Set <Id>();        
        setLocalHCMUserId = new Set <Id>();
        listCurrentLeaveRequest = new List <Leave_Request__c>();
        listLeaveBalance = new List <Leave_Balance__c>();
        listLeaveAvailableTime = new List <Leave_Available_Time__c>();
        listHoliday = new List <Holiday__c>();
        listLeaveRequestshare = new List <Leave_Request__share>();        
        listLeaveApplicationshare = new List <Leave_Application__share>();
        recordtype = new Map <Id, String>();
        mapEmployee = new Map <id, Employee__c>();
        mapEmployeeAdministrator = new Map <id, Employee_Administrator__c>();
        usersToMention = new List <Id>();
        this.listnewLeaveRequest = listnewLeaveRequest;
        oldLeaveRequest = null;
        setUsersToMention = null;
        decRemainingBalance = 0;
        if ( oldmapLeaveRequest != null ){
            this.oldmapLeaveRequest = oldmapLeaveRequest  ;
        }
        else{
            this.oldmapLeaveRequest = new Map<Id,Leave_Request__c>();
        }
        
        for ( RecordType rt : LeaveRequestTriggerHandler.getLeaveRequestRts()){
            recordtype.put ( rt.id, rt.DeveloperName );
        }
        for ( Leave_Request__c lr : this.listnewLeaveRequest){
            setLeaveApplicationId.add(lr.Leave_Application__c);
            setLeaveRequestId.add(lr.id);
            setLeaveTypeID.add(lr.Leave_Type__c);
            setEmployeeAdministratorID.add(lr.Employee_Administrator__c);
        }
        for ( Employee_Administrator__c employeeAdministrator : [ select id, Employee__c  from Employee_Administrator__c where id in :setEmployeeAdministratorID ]){
            mapEmployeeAdministrator.put ( employeeAdministrator.id, employeeAdministrator);
        }
        for ( Leave_Request__c lr : this.listnewLeaveRequest){
            if ( lr.Employee_Administrator__c != null && mapEmployeeAdministrator.containskey(lr.Employee_Administrator__c) && mapEmployeeAdministrator.get(lr.Employee_Administrator__c).Employee__c != null ){
                if ( lr.On_Behalf_of__c != mapEmployeeAdministrator.get(lr.Employee_Administrator__c).Employee__c ){
                    lr.On_Behalf_of__c = mapEmployeeAdministrator.get(lr.Employee_Administrator__c).Employee__c;
                }
            }
            setemployeeID.add(lr.On_Behalf_of__c);
        }        
        for ( Employee__c employee : 
            [ select id,
              Employee_Type__r.Entitled_Public_Holiday__c, Employee_Type__r.Entitled_Early_Release__c, Timeset__c,
              Timeset__r.Is_Sun_Available__c, Timeset__r.SunStartTime1__c, Timeset__r.SunEndTime1__c,
              Timeset__r.Is_Mon_Available__c, Timeset__r.MonStartTime1__c, Timeset__r.MonEndTime1__c,
              Timeset__r.Is_Tue_Available__c, Timeset__r.TueStartTime1__c, Timeset__r.TueEndTime1__c,
              Timeset__r.Is_Wed_Available__c, Timeset__r.WedStartTime1__c, Timeset__r.WedEndTime1__c,
              Timeset__r.Is_Thu_Available__c, Timeset__r.ThuStartTime1__c, Timeset__r.ThuEndTime1__c,
              Timeset__r.Is_Fri_Available__c, Timeset__r.FriStartTime1__c, Timeset__r.FriEndTime1__c,
              Timeset__r.Is_Sat_Available__c, Timeset__r.SatStartTime1__c, Timeset__r.SatEndTime1__c,
              Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,
              Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c,
              User__r.id, Full_Name__c,Leave_Policy__r.name, Leave_Policy__c, Leave_Bypass_Approvals__c,User__r.IsActive/*Add by DTT*/
              from Employee__c where id in :setemployeeID 
        ]){
            mapEmployee.put ( employee.id, employee );
            setEmployeeTimesetID.add(employee.Timeset__c);
            setOnBehalfofEmployeePolicy.add(employee.Leave_Policy__c);
            setLocalHCMGroupName.add ( LOCAL_HCM_GROUP_NAME_PATTERN.replace( POLICY_NAME_PATTERN, employee.Leave_Policy__r.name ) );
        }
        for ( Leave_Balance__c leaveBalance : 
            [ select 
              Employee__r.Leave_Policy__r.Period_Frequency__c, Unapproved_Balance__c, Remaining_Balance__c, 
              Month__c, year__c, Approved_Current_Period__c, Approved_Future_Period__c, Employee__c, Leave_Type_Code__c
              from Leave_Balance__c 
              where Is_Latest__c = true
              and Employee__c in :setemployeeID and Leave_Type_Code__c in :setLeaveTypeID
              
        ]){
            listLeaveBalance.add( leaveBalance );
        }
        for ( Leave_Available_Time__c  lat : 
            [ SELECT  Available_Start_Time__c, Available_End_Time__c, 
               Available_Start_Time_Hour__c, Available_End_Time_Hour__c, Available_Start_Time_Minute__c, Available_End_Time_Minute__c, 
               Cost__c, Timeset__c, Leave_Type__c
               FROM Leave_Available_Time__c 
               where Timeset__c in :setEmployeeTimesetID 
               and Leave_Type__c in  :setLeaveTypeID 
        ]){
            listLeaveAvailableTime.add(lat);
        }
        
        for ( Holiday__c holiday : 
            [ select Day_Of_Week__c, cost__c, Time__c, Date__c, Leave_Policy__c, type__c  
              from Holiday__c 
              where  Leave_Policy__c in :setOnBehalfofEmployeePolicy 
        ]){
            listHoliday.add(holiday);
        }
        
        for ( Leave_Request__c LeaveRequest : 
            [ select date__c, from_date__c, To_Date__c, RecordTypeId, On_Behalf_of__c, status__c 
              from Leave_Request__c 
              where On_Behalf_of__c in :setemployeeID and status__c in ( :LeaveRequestConstant.STATUS_SUBMITTED, :LeaveRequestConstant.STATUS_APPROVED )
        ]){
            listCurrentLeaveRequest.add(LeaveRequest );
        }  
        
        for ( GroupMember reader : 
            [ SELECT UserOrGroupId 
              FROM GroupMember
              where GroupId in (SELECT Id FROM Group where Name in :setLocalHCMGroupName ) 
        ]){
           setLocalHCMGroupId.add(reader.UserOrGroupId); 
        }        
        
        for ( User reader : 
            [ SELECT id from user where id in :setLocalHCMGroupId 
        ]){
            setLocalHCMUserId.add(reader.id);
        }
        
        for (Leave_Request__share reader : 
            [
                select id, UserOrGroupId, ParentId, RowCause 
                from Leave_Request__share
                where ParentId in :setLeaveRequestId 
        ]){
            listLeaveRequestshare.add( reader );
        }
        
        for ( Leave_Application__share reader : 
            [ select id, UserOrGroupId, ParentId, RowCause 
              from Leave_Application__share
              where ParentId in :setLeaveApplicationId
        ]){
            listLeaveApplicationshare.add( reader ); 
        }
    }
    
    public void runinsert( )
    {
        Employee__c employeec ;
        for ( Leave_Request__c newLeaveRequest : listnewLeaveRequest ){
            newLeaveRequest.Leave_Policy_Name__c = newLeaveRequest.Leave_Display_Policy_Name__c;
            employeec = mapEmployee.get(newLeaveRequest.On_Behalf_of__c);
            /*=================Flexible_Time_Request=================*/
            if ( recordtype.get( newLeaveRequest.RecordTypeId ).contains( LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST ) ) {
                 flextimeadj ( newLeaveRequest, employeec );
                 if ( newLeaveRequest.Adjustment_mins__c == null){
                     newLeaveRequest.Date__c.addError(Label.ELeave_Is_Working_Day);
                 }
                 for ( Leave_Request__c lqc: listCurrentLeaveRequest){
                    if ( lqc.On_Behalf_of__c == newLeaveRequest.On_Behalf_of__c ){
                        try{  
                            if ( recordtype.get(lqc.RecordTypeId).contains( LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST  ) ){
                                if ( newLeaveRequest.date__c == lqc.date__c ){
                                    newLeaveRequest.Date__c.addError(Label.ELeave_FT_Duplicate_Date);
                                }
                            }
                            if ( recordtype.get(lqc.RecordTypeId).contains( LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST  ) ){
                                if ( lqc.from_date__c <= newLeaveRequest.date__c && lqc.to_date__c >= newLeaveRequest.date__c || lqc.from_date__c == newLeaveRequest.date__c || lqc.to_date__c == newLeaveRequest.date__c ){
                                    newLeaveRequest.Date__c.addError(Label.ELeave_LR_Duplicate_Date);
                                }
                            }
                        }
                        catch(DmlException e){}    
                    }
                  }  
                  for ( Holiday__c holiday :listHoliday ){
                       if ( holiday.Type__c == LeaveRequestConstant.EARLY_RELEASE_TYPE   &&  holiday.Leave_Policy__c == newLeaveRequest.On_Behalf_of_Policy_ID__c){
                            if ( newLeaveRequest.date__c == holiday.date__c ){
                                try{
                                    newLeaveRequest.Date__c.addError( Label.ELeave_Early_Release_Existing );
                                }
                                catch(DmlException e){}
                             }
                       }
                  }
            }
        }
    }
    
    public  List <Leave_Request_Log__c > leaverequestline(   List <Leave_Available_Time__c  > listlat, String type, Id requestId)
    {
        List <Leave_Request_Log__c > listlql = new List <Leave_Request_Log__c >  ();
        List <Leave_Request_Log__c > listAlllql = new List <Leave_Request_Log__c >  ();
        Leave_Request_Log__c lql;
        Integer integerDay = 0;
        Employee__c employeec ;
        Decimal decCost = 0;
        Decimal decTotalCost = 0;
        String strmintime = '';
        String strmaxtime = '';
        
        
        for ( Leave_Available_Time__c lat : listlat ){
            if ( strmaxtime == ''){
                strmaxtime = lat.Available_End_Time__c;
            }
            if ( strmintime == ''){
                strmintime = lat.Available_Start_Time__c;
            }
            if ( strmintime != '' && strmaxtime != '' ){
                if ( strmaxtime < lat.Available_End_Time__c ){
                    strmaxtime = lat.Available_End_Time__c;
                }
                if ( strmintime > lat.Available_Start_Time__c ){
                    strmintime = lat.Available_Start_Time__c;
                }
            }   
        }
        for ( Leave_Request__c newLeaveRequest : listnewLeaveRequest ){
            if ( newLeaveRequest.id == requestId ){
                employeec = mapEmployee.get(newLeaveRequest.On_Behalf_of__c);
                for ( Date startdate = newLeaveRequest.From_date__c ; startdate<=newLeaveRequest.To_date__c ; ){
                   lql = new Leave_Request_Log__c ();
                   lql.ownerid = employeec.User__r.id;
                   if ( lql.ownerid == null || employeec.User__r.IsActive==false /*Add by DTT*/){
                       lql.ownerid = newLeaveRequest.ownerid;
                   }
                   lql.Leave_Policy__c = employeec.Leave_Policy__r.name;
                   lql.Type__c = type;
                   lql.date__c = startdate ;
                   lql.Deduction__c = 1;
                   if ( !newLeaveRequest.Is_Mandatory_Leave_Request__c ){
                       if ( strmintime != '' && strmaxtime != '' ){
                           lql.From_Hour__c = strmintime.split(SPLIT)[0];
                           lql.From_Minute__c = strmintime.split(SPLIT)[1];
                           lql.To_Hour__c = strmaxtime.split(SPLIT)[0];
                           lql.To_Minute__c = strmaxtime.split(SPLIT)[1];
                       }
                   }
                   else {
                       lql.From_Hour__c = newLeaveRequest.From_Hour__c;
                       lql.From_Minute__c = newLeaveRequest.From_Hour__c;
                       lql.To_Hour__c = newLeaveRequest.To_Hour__c;
                       lql.To_Minute__c = newLeaveRequest.To_Hour__c;
                   }
    
                   if ( startdate == newLeaveRequest.From_date__c  ){
                       lql.Deduction__c = newLeaveRequest.From_Date_Unit_Cost__c;
                       lql.From_Hour__c = newLeaveRequest.From_Hour__c;
                       lql.From_Minute__c = newLeaveRequest.From_Minute__c;
                   }
                   if ( startdate == newLeaveRequest.To_date__c ){
                       if ( newLeaveRequest.From_date__c != newLeaveRequest.To_date__c ){
                           lql.Deduction__c = newLeaveRequest.To_Date_Unit_Cost__c;
                       }
                       lql.To_Hour__c = newLeaveRequest.To_Hour__c;
                       lql.To_Minute__c = newLeaveRequest.To_Minute__c;
                   }
                   lql.Employee__c = newLeaveRequest.On_Behalf_of__c;
                   lql.Employee_ID__c = newLeaveRequest.On_Behalf_of_Employee_ID__c;
                   lql.Employee_Full_Name__c = newLeaveRequest.On_Behalf_of_Full_Name__c;
                   lql.Employee_Department__c = newLeaveRequest.On_Behalf_of_Department__c;
                   lql.Leave_Request_ID__c = newLeaveRequest.name;
                   lql.Leave_Type__c = newLeaveRequest.Leave_Type_Name__c;
                   lql.site__c = newLeaveRequest.On_Behalf_of_Site__c;
                   lql.Original_Employee_ID__c = newLeaveRequest.On_Behalf_of_Original_Employee_ID__c;
                   if ( !newLeaveRequest.Is_Mandatory_Leave_Request__c && newLeaveRequest.Leave_Type_Deduct_Non_Working_Day__c ){
                       integerDay = Math.Mod ( Date.newInstance(1900, 1, 7).daysBetween( lql.date__c ),7 );
                       if ( !employeec.Timeset__r.Is_Sun_Available__c && integerDay == LeaveRequestConstant.SUNDAY ){
                           lql.Deduction__c = 0;
                       }
                       if ( !employeec.Timeset__r.Is_Mon_Available__c && integerDay == LeaveRequestConstant.MONDAY ){
                           lql.Deduction__c = 0;
                       }
                       if ( !employeec.Timeset__r.Is_Tue_Available__c && integerDay == LeaveRequestConstant.TUESDAY ){
                           lql.Deduction__c = 0;
                       }
                       if ( !employeec.Timeset__r.Is_Wed_Available__c && integerDay == LeaveRequestConstant.WEDNESDAY ){
                           lql.Deduction__c = 0;
                       }
                       if ( !employeec.Timeset__r.Is_Thu_Available__c && integerDay == LeaveRequestConstant.THURSDAY ){
                           lql.Deduction__c = 0;
                       }
                       if ( !employeec.Timeset__r.Is_Fri_Available__c && integerDay == LeaveRequestConstant.FRIDAY ){
                           lql.Deduction__c = 0;
                       }
                       if ( !employeec.Timeset__r.Is_Sat_Available__c && integerDay == LeaveRequestConstant.SATURDAY ){
                           lql.Deduction__c = 0;
                       }
                   } 
                   Listlql.add(lql);
                   startdate = startdate.adddays(1);
               }  
               if ( !newLeaveRequest.Is_Mandatory_Leave_Request__c && employeec.Employee_Type__r.Entitled_Public_Holiday__c && newLeaveRequest.Leave_Type_Deduct_Public_Holiday__c ){
                   for (   Holiday__c holiday : listHoliday ){
                       if ( holiday.Type__c == LeaveRequestConstant.HOLIDAY_TYPE  && holiday.Date__c >= newLeaveRequest.From_Date__c && holiday.Date__c <= newLeaveRequest.To_Date__c ){
                           for ( Leave_Request_Log__c reader : Listlql ){                                       
                               if ( reader.date__c == holiday.Date__c ){
                                   reader.Deduction__c = 0 ;
                               }                           
                           }
                       }
                   }
               }
               
               if ( !newLeaveRequest.Is_Mandatory_Leave_Request__c && employeec.Employee_Type__r.Entitled_Early_Release__c && newLeaveRequest.Leave_Type_Deduct_Early_Release__c ){
                   decCost = 0;
                    for (  Holiday__c holiday : listHoliday ){
                        if ( holiday.Type__c == LeaveRequestConstant.EARLY_RELEASE_TYPE  && holiday.Time__c  < newLeaveRequest.To_Time__c && holiday.Date__c > newLeaveRequest.From_Date__c && holiday.Date__c < newLeaveRequest.To_Date__c ){
                           for ( Leave_Request_Log__c reader : Listlql ){
                               decCost = 0;
                               if ( reader.date__c == holiday.Date__c && reader.Deduction__c > 0 && newLeaveRequest.From_date__c != holiday.Date__c  && newLeaveRequest.To_date__c != holiday.Date__c ){
                                   for (  Leave_Available_Time__c   lat : listlat ){
                                       if ( lat.Available_Start_Time__c  < holiday.Time__c ){
                                           decCost += lat.cost__c;
                                       }
                                   }
                                   //decCost = Math.Min( decCost, (Decimal) holiday.cost__c );
                                   reader.Deduction__c = decCost ;
                               }
                           }
                        }
                    }
               }           
            }
        }
        return listlql;
    }
   
    public void runupdate( )
    {
        List <Leave_Available_Time__c> listlat;
        List <Leave_Request_Log__c> listlql = new List <Leave_Request_Log__c>();
        List <Leave_Request_Log__c> listAlllql = new List <Leave_Request_Log__c>();
        List <Leave_Request_Log__c> listlqlPendingApproval = new List <Leave_Request_Log__c>();        
        List <EntitySubscription> EntitySubscriptionList = new List <EntitySubscription> ();
        List <EntitySubscription> toBeDelEntitySubscriptionList = new List <EntitySubscription> ();
        List <Leave_request__Share> lrshareList = new List <Leave_request__Share>();
        List <Leave_application__Share> lashareList = new List <Leave_Application__Share>();
        Set <Id> toBeDelEntitySubscriptionIDSet = new Set <Id> ();
        Set <ID> shareUserIDSet = new Set <ID>();
        Map <ID, user> activeUserIDMap = new Map <ID, user>();
        Leave_Request_Log__c lql;
        Decimal decCost = 0;
        String stringChatterFeedId = '';
        String stringChatterFeed = '';
        Employee__c employeec ;
        String status = '';
        String userID = '';
        Set <ID> setLeaveBalanceID = new Set <ID>();
        List <Leave_Balance__c> listLeaveBalance = new List <Leave_Balance__c>();
        List <Leave_Request__share> listToBeDelLeaveRequest = new List <Leave_Request__share>();
        List <Leave_Request__share> listLeaveRequest = new List <Leave_Request__share>();
        List <Leave_Request__share> tmpListLeaveRequest = new List <Leave_Request__share>();
        Set <Id> setLeaveRequestOwner = new Set<Id>();
        Leave_Request__share tmpLeaveRequestshare = null;
        Set <ID> setLeaveApplicationshareId = new Set <ID> ();
        List <Leave_Application__share> listToBeDelLeaveApplication = new List <Leave_Application__share>();
        List <Leave_Application__share> listLeaveApplication = new List <Leave_Application__share>();
        List <Leave_Application__share> tmpListLeaveApplication = new List <Leave_Application__share>();
        Set <Id> setLeaveApplicationOwner = new Set<Id>();
        Leave_Application__share tmpLeaveApplicationshare = null;
        Date current_date = null ;
        FeedComment fcomment;
        List <FeedComment> listfcomment = new List <FeedComment>(); 
        Integer num_of_month = 0;
        Integer [] integerDaysOfWeek = new Integer [LeaveRequestConstant.WEEKDAYS];
        Integer integerDays = 0;
        Integer integerDaysRemainder = 0;
        Integer integerDay = 0;
        Decimal Deduction = 0;
        Boolean feedExisting = false;
        
        if ( !listnewLeaveRequest.isEmpty() && !oldmapLeaveRequest.isEmpty() ){
            for ( Leave_Request__c newLeaveRequest : listnewLeaveRequest ){                
                newLeaveRequest.Leave_Policy_Name__c = newLeaveRequest.Leave_Display_Policy_Name__c;
                employeec = mapEmployee.get(newLeaveRequest.On_Behalf_of__c);
                /*=================Leave_Request=================*/
                if (  recordtype.get(newLeaveRequest.RecordTypeId) == LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST ){
                    listlat = new List <Leave_Available_Time__c>  ();
                    oldLeaveRequest = oldmapLeaveRequest.get(newLeaveRequest.id);
                    if ( oldLeaveRequest.Status__c != newLeaveRequest.Status__c ){
                        for ( Leave_Available_Time__c lat : listLeaveAvailableTime){
                            if ( lat.Timeset__c == employeec.Timeset__c && lat.Leave_Type__c == newLeaveRequest.Leave_Type__c ){
                               listlat.add(lat);
                            }
                        }
                        status = newLeaveRequest.Status__c;                        
                        if ( status == LeaveRequestConstant.STATUS_PENDING_APPROVAL || ( status == LeaveRequestConstant.STATUS_NOT_SUBMITTED  && oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL  ) || (status == LeaveRequestConstant.STATUS_REJECT && oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL ) ){
                           if ( status != oldLeaveRequest.Status__c && status == LeaveRequestConstant.STATUS_PENDING_APPROVAL ){
                               newLeaveRequest.Acting_Approver_1__c = mapEmployee.get(newLeaveRequest.On_Behalf_of__c).Acting_Approver_1__c;
                               newLeaveRequest.Acting_Approver_2__c = mapEmployee.get(newLeaveRequest.On_Behalf_of__c).Acting_Approver_2__c;
                               newLeaveRequest.Acting_Approver_3__c = mapEmployee.get(newLeaveRequest.On_Behalf_of__c).Acting_Approver_3__c;
                               newLeaveRequest.Acting_Approver_4__c = mapEmployee.get(newLeaveRequest.On_Behalf_of__c).Acting_Approver_4__c;
                               newLeaveRequest.Approver_1__c = mapEmployee.get(newLeaveRequest.On_Behalf_of__c).Approver_1__c;
                               newLeaveRequest.Approver_2__c = mapEmployee.get(newLeaveRequest.On_Behalf_of__c).Approver_2__c;
                               newLeaveRequest.Approver_3__c = mapEmployee.get(newLeaveRequest.On_Behalf_of__c).Approver_3__c;
                               newLeaveRequest.Approver_4__c = mapEmployee.get(newLeaveRequest.On_Behalf_of__c).Approver_4__c;
                               newLeaveRequest.Actual_Approver_1__c = newLeaveRequest.Acting_Approver_1__c != null ? newLeaveRequest.Acting_Approver_1__c : newLeaveRequest.Approver_1__c;
                               newLeaveRequest.Actual_Approver_2__c = newLeaveRequest.Acting_Approver_2__c != null ? newLeaveRequest.Acting_Approver_2__c : newLeaveRequest.Approver_2__c;
                               newLeaveRequest.Actual_Approver_3__c = newLeaveRequest.Acting_Approver_3__c != null ? newLeaveRequest.Acting_Approver_3__c : newLeaveRequest.Approver_3__c;
                               newLeaveRequest.Actual_Approver_4__c = newLeaveRequest.Acting_Approver_4__c != null ? newLeaveRequest.Acting_Approver_4__c : newLeaveRequest.Approver_4__c;
                           }
                           for ( Leave_Balance__c LeaveBalance : this.listLeaveBalance ){
                                if ( LeaveBalance.Employee__c == newLeaveRequest.On_Behalf_of__c && LeaveBalance.Leave_Type_Code__c == newLeaveRequest.Leave_Type__c ){
                                    if ( ( status == LeaveRequestConstant.STATUS_NOT_SUBMITTED && oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL ) || (status == LeaveRequestConstant.STATUS_REJECT && oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL ) ){
                                        LeaveBalance.Unapproved_Balance__c -= newLeaveRequest.Deduction__c;
                                    }  
                                    if (  status == LeaveRequestConstant.STATUS_PENDING_APPROVAL ){                                        
                                        setLeaveRequestOwner.clear();
                                        setLeaveApplicationOwner.clear();
                                        for ( Leave_Request__share reader : listLeaveRequestshare ){
                                            if ( reader.ParentId == newLeaveRequest.id ){
                                                if ( reader.RowCause == MANUAL ){
                                                    listToBeDelLeaveRequest.add(reader);
                                                }
                                                else{
                                                    setLeaveRequestOwner.add(reader.UserOrGroupId);
                                                }
                                            }
                                        }
                                        
                                        for ( Leave_Application__share reader : listLeaveApplicationshare){
                                            if ( reader.ParentId == newLeaveRequest.Leave_Application__c ){
                                                if ( reader.RowCause == MANUAL ){
                                                    if ( !setLeaveApplicationshareId.contains(reader.id) ){
                                                        listToBeDelLeaveApplication.add(reader);
                                                        setLeaveApplicationshareId.add(reader.id);
                                                    }
                                                }
                                                else{
                                                    setLeaveApplicationOwner.add(reader.UserOrGroupId);
                                                }
                                            }
                                        }
                                        
                                        tmpListLeaveRequest = listLeaveRequestShare(newLeaveRequest, employeec, setLeaveRequestOwner);   
                                        tmpListLeaveApplication = listLeaveApplicationShare(newLeaveRequest, employeec, setLeaveRequestOwner);
                                        
                                        for ( Leave_Request__Share reader : tmpListLeaveRequest ){
                                            listLeaveRequest.add(reader);
                                        }
                                        for ( Leave_Application__share reader : tmpListLeaveApplication ){
                                            listLeaveApplication.add(reader);
                                        }                                        
                                        LeaveBalance.Unapproved_Balance__c += newLeaveRequest.Deduction__c;                                        
                                    }
                                    setLeaveBalanceID.add(LeaveBalance.id);
                                    if ( status == LeaveRequestConstant.STATUS_NOT_SUBMITTED && oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL ){
                                        if ( newLeaveRequest.ChatterFeedId__c != null ){
                                            fcomment = new FeedComment(); 
                                            fcomment.FeedItemId = newLeaveRequest.ChatterFeedId__c;
                                            stringChatterFeed = Label.Eleave_Recall_Application + newLeaveRequest.name ;
                                            fcomment.CommentBody = stringChatterFeed.unescapeJava().unescapeHtml4()  ;
                                            listfcomment.add(fcomment);
                                        }
                                    }
                                    if ( status == LeaveRequestConstant.STATUS_REJECT && oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL ){
                                        if ( newLeaveRequest.ChatterFeedId__c != null ){
                                            fcomment = new FeedComment(); 
                                            fcomment.FeedItemId = newLeaveRequest.ChatterFeedId__c;
                                            stringChatterFeed = Label.Eleave_Reject_Application+ newLeaveRequest.name ;
                                            fcomment.CommentBody = stringChatterFeed.unescapeJava().unescapeHtml4()  ;
                                            listfcomment.add(fcomment);
                                        }
                                    }
                                }
                           }
                           Listlql = leaverequestline(listlat, LeaveRequestConstant.LEAVE_REQUEST_LOG_TYPE_PENDING_APPROVAL, newLeaveRequest.id );
                           for ( Leave_Request_Log__c  lrl : Listlql ){
                               if ( ( status == LeaveRequestConstant.STATUS_NOT_SUBMITTED && oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL ) || (status == LeaveRequestConstant.STATUS_REJECT && oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL ) ){
                                   lrl.Deduction__c = -lrl.Deduction__c;
                               }
                               listAlllql.add(lrl);
                           }
                        }
                        
                        if ( status == LeaveRequestConstant.STATUS_APPROVED && ( oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL || oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED || oldLeaveRequest.Status__c == LeaveRequestConstant.STATUS_DRAFT ) ){
                           integerDaysOfWeek = new Integer [LeaveRequestConstant.WEEKDAYS];
                           integerDays = 0;
                           integerDaysRemainder = 0;
                           integerDay = 0;
                           Deduction = 0;
                           
                           setLeaveRequestOwner.clear();
                           setLeaveApplicationOwner.clear();
                           for ( Leave_Request__share reader : listLeaveRequestshare ){
                                if ( reader.ParentId == newLeaveRequest.id ){
                                    if ( reader.RowCause == MANUAL ){
                                        listToBeDelLeaveRequest.add(reader);
                                    }
                                    else{
                                        setLeaveRequestOwner.add(reader.UserOrGroupId);
                                    }
                                }
                           }
                           
                           for ( Leave_Application__share reader : listLeaveApplicationshare){
                               if ( reader.ParentId == newLeaveRequest.Leave_Application__c ){
                                   if ( reader.RowCause == MANUAL ){
                                        if ( !setLeaveApplicationshareId.contains(reader.id) ){
                                            listToBeDelLeaveApplication.add(reader);
                                            setLeaveApplicationshareId.add(reader.id);
                                        }
                                    }
                                    else{
                                        setLeaveApplicationOwner.add(reader.UserOrGroupId);
                                    }
                                }
                           }
                            
                           tmpListLeaveRequest = listLeaveRequestShare(newLeaveRequest, employeec, setLeaveRequestOwner);   
                           tmpListLeaveApplication = listLeaveApplicationShare(newLeaveRequest, employeec, setLeaveRequestOwner);
                            
                           for ( Leave_Request__Share reader : tmpListLeaveRequest ){
                                listLeaveRequest.add(reader);
                           }
                           for ( Leave_Application__share reader : tmpListLeaveApplication ){
                                listLeaveApplication.add(reader);
                           }
                           Listlql = leaverequestline(listlat, LeaveRequestConstant.LEAVE_REQUEST_LOG_TYPE_LEAVE_REQUEST, newLeaveRequest.id );
                           for ( Leave_Balance__c LeaveBalance : this.listLeaveBalance){
                               if ( LeaveBalance.Employee__c == newLeaveRequest.On_Behalf_of__c && LeaveBalance.Leave_Type_Code__c == newLeaveRequest.Leave_Type__c ){
                                    current_date = date.newInstance( Integer.Valueof(LeaveBalance.year__c), Integer.Valueof(LeaveBalance.month__c), 1 );
                                    if ( LeaveBalance.Employee__r.Leave_Policy__r.Period_Frequency__c == LeaveRequestConstant.LEAVE_POLICY_PERIOD_FREQUENCY_MONTHLY ){
                                        num_of_month = LeaveRequestConstant.MONTHLY;
                                    }
                                    if ( LeaveBalance.Employee__r.Leave_Policy__r.Period_Frequency__c == LeaveRequestConstant.LEAVE_POLICY_PERIOD_FREQUENCY_ANNIVERSARY ){
                                        num_of_month = LeaveRequestConstant.ANNIVERSARY;
                                    }
                                    if ( !employeec.Leave_Bypass_Approvals__c && !newLeaveRequest.Is_Mandatory_Leave_Request__c ){
                                        LeaveBalance.Unapproved_Balance__c -= newLeaveRequest.Deduction__c;
                                    }
                                    if ( current_date <= newLeaveRequest.From_Date__c && current_date <= newLeaveRequest.To_Date__c ){                                        
                                        if ( newLeaveRequest.From_Date__c <  current_date.addMonths(num_of_month) && newLeaveRequest.From_Date__c >= current_date ){
                                            if ( newLeaveRequest.To_Date__c <  current_date.addMonths(num_of_month) && newLeaveRequest.To_Date__c >= current_date ){
                                                LeaveBalance.Approved_Current_Period__c += newLeaveRequest.Deduction__c;
                                                newLeaveRequest.Approved_Current_Period__c = newLeaveRequest.Deduction__c;                                                
                                            }
                                            else{
                                                Deduction = 0;
                                                for ( Leave_Request_Log__c reader : Listlql ){                                                
                                                    if ( reader.date__c <=current_date.addMonths(num_of_month) && reader.date__c >= current_date ){
                                                        Deduction  += reader.Deduction__c;
                                                    }
                                                }
                                                LeaveBalance.Approved_Current_Period__c += Deduction;
                                                LeaveBalance.Approved_Future_Period__c += newLeaveRequest.Deduction__c - Deduction;
                                                newLeaveRequest.Approved_Current_Period__c = Deduction;
                                                newLeaveRequest.Approved_Future_Period__c = newLeaveRequest.Deduction__c - Deduction;
                                            }
                                        }
                                        else{
                                            LeaveBalance.Approved_Future_Period__c += newLeaveRequest.Deduction__c;
                                            newLeaveRequest.Approved_Future_Period__c = newLeaveRequest.Deduction__c ;
                                        }
                                    }
                                    setLeaveBalanceID.add(LeaveBalance.id);
                               }
                           }
                           if ( !newLeaveRequest.Is_Mandatory_Leave_Request__c ){
                               listlqlPendingApproval = leaverequestline(listlat, LeaveRequestConstant.LEAVE_REQUEST_LOG_TYPE_PENDING_APPROVAL, newLeaveRequest.id );
                               for ( Leave_Request_Log__c lrl : listlqlPendingApproval ){
                                   lrl.Deduction__c = -lrl.Deduction__c;
                                   Listlql.add (lrl);
                               }
                           }
                           for ( Leave_Request_Log__c lrl :Listlql){
                               listAlllql.add(lrl);
                           }
                        }
                        else if ( status == LeaveRequestConstant.STATUS_CANCELLED ){
                            userID = '';
                            usersToMention = new List<Id>();
                            Listlql = leaverequestline( listlat, LeaveRequestConstant.LEAVE_REQUEST_LOG_TYPE_CANCELLATION, newLeaveRequest.id );
                            for ( Leave_Request_Log__c reader  : Listlql ){
                                reader.Deduction__c = -reader.Deduction__c ;
                            }
                            
                            for ( Leave_Balance__c LeaveBalance : this.listLeaveBalance ){
                                if ( LeaveBalance.Employee__c == newLeaveRequest.On_Behalf_of__c && LeaveBalance.Leave_Type_Code__c == newLeaveRequest.Leave_Type__c ){
                                    if ( LeaveBalance.Employee__r.Leave_Policy__r.Period_Frequency__c == LeaveRequestConstant.LEAVE_POLICY_PERIOD_FREQUENCY_MONTHLY ){
                                        num_of_month = LeaveRequestConstant.MONTHLY ;
                                    }
                                    if ( LeaveBalance.Employee__r.Leave_Policy__r.Period_Frequency__c == LeaveRequestConstant.LEAVE_POLICY_PERIOD_FREQUENCY_ANNIVERSARY ){
                                        num_of_month = LeaveRequestConstant.ANNIVERSARY;
                                    }
                                    current_date = date.newInstance( Integer.Valueof(LeaveBalance.year__c), Integer.Valueof(LeaveBalance.month__c), 1 );
                                    if ( current_date <= newLeaveRequest.From_Date__c && current_date <= newLeaveRequest.To_Date__c ){
                                        if ( newLeaveRequest.From_Date__c <  current_date.addMonths(num_of_month) && newLeaveRequest.From_Date__c >= current_date ){
                                            if ( newLeaveRequest.To_Date__c <  current_date.addMonths(num_of_month) && newLeaveRequest.To_Date__c >= current_date ){
                                                LeaveBalance.Approved_Current_Period__c -= newLeaveRequest.Approved_Current_Period__c ;
                                            }
                                            else{
                                                LeaveBalance.Approved_Current_Period__c -= newLeaveRequest.Approved_Current_Period__c ;
                                                LeaveBalance.Approved_Future_Period__c  -= newLeaveRequest.Approved_Future_Period__c ;
                                            }
                                        }
                                        else{
                                            LeaveBalance.Approved_Future_Period__c  -= newLeaveRequest.Approved_Future_Period__c ;
                                        }
                                    }
                                    setLeaveBalanceID.add(LeaveBalance.id);
                                }
                            }
                            newLeaveRequest.Approved_Current_Period__c = 0;
                            newLeaveRequest.Approved_Future_Period__c = 0;                            
                            //======for Chatter comments when Cancellation is requested========
                            if ( newLeaveRequest.Actual_Approver_2__c != null ){
                                usersToMention.add( newLeaveRequest.Actual_Approver_2__c );
                            }
                            else if ( newLeaveRequest.Actual_Approver_3__c != null ){
                                usersToMention.add( newLeaveRequest.Actual_Approver_3__c );
                            }
                            else if ( newLeaveRequest.Actual_Approver_4__c != null ){
                                usersToMention.add( newLeaveRequest.Actual_Approver_4__c );
                            }
                            for ( Id reader : setLocalHCMUserId ){
                                usersToMention.add( reader );
                            }                            
                            if (  employeec.User__r.id == null){
                                userID = newLeaveRequest.Employee_ID__c;
                            }
                            else{
                                userID = employeec.User__r.id ;
                            }
                            if ( newLeaveRequest.ChatterFeedId__c != null ){
                                fcomment = new FeedComment(); 
                                fcomment.FeedItemId = newLeaveRequest.ChatterFeedId__c;
                                stringChatterFeed = Label.Eleave_Cancellation_Application+ newLeaveRequest.name ;
                                fcomment.CommentBody = stringChatterFeed.unescapeJava().unescapeHtml4()  ;
                                listfcomment.add(fcomment);
                            }
                            else{
                                ChatterUtil.simpleTextPostWithMultipleMentions( userID, usersToMention, Label.Eleave_Cancellation_Application+ newLeaveRequest.name );
                            }
                            //======for Chatter comments when Cancellation is requested========
                            for ( Leave_Request_Log__c lrl :Listlql){
                               listAlllql.add(lrl);
                           }
                        }
                    }
                    
                    //Added by TAL (Twinkle Li) @20170816 - Clear "Travel Application" if Leave Type is not "Travel Compensation Leave" anymore
                    if(!newLeaveRequest.Leave_Type_Display_Name__c.contains(LeaveRequestConstant.LEAVE_TYPE_TRAVEL_COMPENSATION_LEAVE)){
                        newLeaveRequest.Travel_Application__c = null;
                    }
                }
                /*==================FLEXIBLE_TIME_REQUEST==================*/
                if (  recordtype.get(newLeaveRequest.RecordTypeId).contains( LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST ) ) {                    
                    newLeaveRequest.Approver_1__c = employeec.Approver_1__c ;
                    newLeaveRequest.Acting_Approver_1__c = employeec.Acting_Approver_1__c;
                    newLeaveRequest.Approver_2__c = employeec.Approver_2__c ;
                    newLeaveRequest.Acting_Approver_2__c = employeec.Acting_Approver_2__c;
                    newLeaveRequest.Approver_3__c = employeec.Approver_3__c ;
                    newLeaveRequest.Acting_Approver_3__c = employeec.Acting_Approver_3__c;
                    newLeaveRequest.Approver_4__c = employeec.Approver_4__c ;
                    newLeaveRequest.Acting_Approver_4__c = employeec.Acting_Approver_4__c;
                    newLeaveRequest.Actual_Approver_1__c = employeec.Acting_Approver_1__c != null ? employeec.Acting_Approver_1__c : employeec.Approver_1__c;
                    newLeaveRequest.Actual_Approver_2__c = employeec.Acting_Approver_2__c != null ? employeec.Acting_Approver_2__c : employeec.Approver_2__c;
                    newLeaveRequest.Actual_Approver_3__c = employeec.Acting_Approver_3__c != null ? employeec.Acting_Approver_3__c : employeec.Approver_3__c;
                    newLeaveRequest.Actual_Approver_4__c = employeec.Acting_Approver_4__c != null ? employeec.Acting_Approver_4__c : employeec.Approver_4__c;
                    
                    if ( newLeaveRequest.status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED ){
                        for ( Leave_Request__c lqc: listCurrentLeaveRequest ){
                            if ( lqc.On_Behalf_of__c == newLeaveRequest.On_Behalf_of__c ){
                                try{  
                                    if ( recordtype.get(lqc.RecordTypeId).contains( LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST ) ){
                                        if ( newLeaveRequest.date__c == lqc.date__c ){
                                            newLeaveRequest.Date__c.addError( Label.ELeave_FT_Duplicate_Date);
                                        }
                                    }
                                    if ( recordtype.get(lqc.RecordTypeId).contains( LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST )){
                                        if ( lqc.from_date__c <= newLeaveRequest.date__c && lqc.to_date__c >= newLeaveRequest.date__c || lqc.from_date__c == newLeaveRequest.date__c || lqc.to_date__c == newLeaveRequest.date__c ){
                                            newLeaveRequest.Date__c.addError( Label.ELeave_LR_Duplicate_Date );
                                        }
                                    }
                                }
                                catch(DmlException e){}
                            } 
                        }
                        for ( Holiday__c holiday :listHoliday ){
                            if ( newLeaveRequest.date__c == holiday.date__c && holiday.Leave_Policy__c == newLeaveRequest.On_Behalf_of_Policy_ID__c &&  holiday.Type__c == LeaveRequestConstant.EARLY_RELEASE_TYPE ){
                                try{
                                    newLeaveRequest.Date__c.addError( Label.ELeave_Early_Release_Existing );
                                }
                                catch(DmlException e){}
                             }
                        }
                    }
                     
                                                            
                    if( ( newLeaveRequest.status__c != oldmapLeaveRequest.get(newLeaveRequest.id).status__c ) && ( newLeaveRequest.status__c == LeaveRequestConstant.STATUS_SUBMITTED ) ) {
                        setUsersToMention = new Set <Id>(); 
                        if ( newLeaveRequest.Date__c < Date.today() ) {
                             newLeaveRequest.Date__c.adderror(Label.ELeave_Date_Passed);
                        }
                        setLeaveRequestOwner.clear();
                        newLeaveRequest.Apply_date__c = System.now();                        
                        for ( Leave_Request__share reader : listLeaveRequestshare  ){
                            if ( reader.ParentId == newLeaveRequest.id ){
                                if ( reader.RowCause == MANUAL ){
                                    listToBeDelLeaveRequest.add(reader);
                                }
                                else{
                                    setLeaveRequestOwner.add(reader.UserOrGroupId);
                                }
                            }
                        }
                        listLeaveRequest = listLeaveRequestShare(newLeaveRequest, employeec, setLeaveRequestOwner);                        
                        if ( newLeaveRequest.Actual_Approver_1__c != null ){
                            setUsersToMention.add(newLeaveRequest.Actual_Approver_1__c );
                        }
                        if ( newLeaveRequest.Copy_to_1__c != null ){
                            setUsersToMention.add( newLeaveRequest.Copy_to_1__c );
                        }
                        if ( newLeaveRequest.Copy_to_2__c != null ) {
                            setUsersToMention.add( newLeaveRequest.Copy_to_2__c );
                        }
                        if ( newLeaveRequest.Copy_to_3__c != null ) {
                            setUsersToMention.add( newLeaveRequest.Copy_to_3__c );
                        }
                        if ( newLeaveRequest.Copy_to_4__c != null ){
                            setUsersToMention.add( newLeaveRequest.Copy_to_4__c );
                        }
                        if ( newLeaveRequest.Copy_to_5__c != null ){
                            setUsersToMention.add( newLeaveRequest.Copy_to_5__c );
                        }
                        if ( newLeaveRequest.Copy_to_6__c != null ){
                            setUsersToMention.add( newLeaveRequest.Copy_to_6__c );
                        }
                        if ( newLeaveRequest.Copy_to_7__c != null ){
                            setUsersToMention.add( newLeaveRequest.Copy_to_7__c );
                        }
                        if ( newLeaveRequest.Copy_to_8__c != null ){
                            setUsersToMention.add( newLeaveRequest.Copy_to_8__c );
                        }
                        if ( newLeaveRequest.Copy_to_9__c != null ){
                            setUsersToMention.add( newLeaveRequest.Copy_to_9__c );
                        }
                        if ( newLeaveRequest.Copy_to_10__c != null ) {
                            setUsersToMention.add( newLeaveRequest.Copy_to_10__c );
                        }
                        if ( employeec.user__c != null ) {
                            setUsersToMention.add( employeec.user__c );
                        }
                        if ( newLeaveRequest.Employee_UserId__c != null ) {
                            setUsersToMention.add( newLeaveRequest.Employee_UserId__c );
                        }
                        usersToMention = new List<ID>(setUsersToMention);                        
                        for ( ID reader :setUsersToMention ){
                            EntitySubscriptionList.add(new EntitySubscription (ParentId = newLeaveRequest.id, SubscriberId = reader));
                        }
                        toBeDelEntitySubscriptionIDSet.add(newLeaveRequest.id);
                        
                        if ( newLeaveRequest.ChatterFeedId__c == null ){
                            stringChatterFeed = employeec.Full_Name__c + Label.ELeave_Submit_FT+ Label.ELeave_Date + (newLeaveRequest.Date__c).format() + Label.ELeave_Original_Start_Time + newLeaveRequest.Original_Start_Time_Display__c +  Label.ELeave_Original_End_Time + newLeaveRequest.Original_End_Time_Display__c +  Label.ELeave_Adjust_Start_Time + newLeaveRequest.Adj_Start_Time_Display__c +  Label.ELeave_Adjust_End_Time + newLeaveRequest.Adj_End_Time_Display__c ;
                            stringChatterFeedId = ChatterUtil.simpleTextPostWithMultipleMentions( newLeaveRequest.id, usersToMention, stringChatterFeed.unescapeJava().unescapeHtml4()   );
                            newLeaveRequest.ChatterFeedId__c = stringChatterFeedId;
                        }
                        else{
                            stringChatterFeed = employeec.Full_Name__c + Label.ELeave_Submit_FT+ Label.ELeave_Date + (newLeaveRequest.Date__c).format() + Label.ELeave_Original_Start_Time + newLeaveRequest.Original_Start_Time_Display__c +  Label.ELeave_Original_End_Time + newLeaveRequest.Original_End_Time_Display__c +  Label.ELeave_Adjust_Start_Time + newLeaveRequest.Adj_Start_Time_Display__c +  Label.ELeave_Adjust_End_Time + newLeaveRequest.Adj_End_Time_Display__c ;
                            fcomment = new FeedComment(); 
                            fcomment.FeedItemId = newLeaveRequest.ChatterFeedId__c;
                            fcomment.CommentBody = stringChatterFeed.unescapeJava().unescapeHtml4()  ;
                            listfcomment.add(fcomment);
                        }
                    }
                    
                    if ( ( newLeaveRequest.status__c != oldmapLeaveRequest.get(newLeaveRequest.id).status__c ) && ( newLeaveRequest.status__c == LeaveRequestConstant.STATUS_CANCELLED ) ){
                        if ( newLeaveRequest.ChatterFeedId__c != null ){
                            stringChatterFeed = employeec.Full_Name__c + Label.ELeave_Cancel_FT+ Label.ELeave_Date + (newLeaveRequest.Date__c).format() + Label.ELeave_Original_Start_Time + newLeaveRequest.Original_Start_Time_Display__c +  Label.ELeave_Original_End_Time + newLeaveRequest.Original_End_Time_Display__c +  Label.ELeave_Adjust_Start_Time + newLeaveRequest.Adj_Start_Time_Display__c +  Label.ELeave_Adjust_End_Time + newLeaveRequest.Adj_End_Time_Display__c ;
                            fcomment = new FeedComment(); 
                            fcomment.FeedItemId = newLeaveRequest.ChatterFeedId__c;
                            fcomment.CommentBody = stringChatterFeed.unescapeJava().unescapeHtml4()  ;
                            listfcomment.add(fcomment);
                        }
                    }
                    
                    if( ( newLeaveRequest.Date__c != oldmapLeaveRequest.get(newLeaveRequest.id).Date__c ) || ( newLeaveRequest.Adjustment_mins__c != oldmapLeaveRequest.get(newLeaveRequest.id).Adjustment_mins__c )){
                        flextimeadj (  newLeaveRequest, employeec  );
                        if ( newLeaveRequest.Adjustment_mins__c == null){
                            newLeaveRequest.Date__c.addError(Label.ELeave_Is_Working_Day);
                        } 
                    }
                    if( 
                        (
                          ( newLeaveRequest.Date__c != oldmapLeaveRequest.get(newLeaveRequest.id).Date__c ) ||
                          ( newLeaveRequest.Adjustment_mins__c != oldmapLeaveRequest.get(newLeaveRequest.id).Adjustment_mins__c   ) ||
                          ( newLeaveRequest.Employee_ID__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Employee_ID__c) ||
                          ( newLeaveRequest.On_Behalf_of__c!= oldmapLeaveRequest.get(newLeaveRequest.id).On_Behalf_of__c) ||
                          ( newLeaveRequest.Copy_to_1__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_1__c) ||
                          ( newLeaveRequest.Copy_to_2__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_2__c) ||
                          ( newLeaveRequest.Copy_to_3__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_3__c) ||
                          ( newLeaveRequest.Copy_to_4__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_4__c) ||
                          ( newLeaveRequest.Copy_to_5__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_5__c) ||
                          ( newLeaveRequest.Copy_to_6__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_6__c) ||
                          ( newLeaveRequest.Copy_to_7__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_7__c) ||
                          ( newLeaveRequest.Copy_to_8__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_8__c) ||
                          ( newLeaveRequest.Copy_to_9__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_9__c) ||
                          ( newLeaveRequest.Copy_to_10__c!= oldmapLeaveRequest.get(newLeaveRequest.id).Copy_to_10__c)
                        ) &&
                        ( newLeaveRequest.status__c == oldmapLeaveRequest.get(newLeaveRequest.id).status__c) &&
                        ( newLeaveRequest.status__c == LeaveRequestConstant.STATUS_CANCELLED ) 
                    ){
                        newLeaveRequest.status__c = LeaveRequestConstant.STATUS_NOT_SUBMITTED;
                    }
                }
            }
            
        }
        if ( !listAlllql.isempty() ){
            insert listAlllql;
        }
        
        if ( !setLeaveBalanceID.isempty() ){
            for ( Id id : setLeaveBalanceID ){
                for ( Leave_Balance__c LeaveBalance : this.listLeaveBalance ){
                    if ( LeaveBalance.id == id ){
                        listLeaveBalance.add(LeaveBalance);
                    }
                }    
            }
            update listLeaveBalance;
        }
        if (  !listfcomment.isempty() ){
            insert listfcomment;
        }
        if( !listToBeDelLeaveApplication.isEmpty() ){
            delete listToBeDelLeaveApplication ;
        }
        if( !listToBeDelLeaveRequest.isEmpty() ){
            delete listToBeDelLeaveRequest;
        }
        
        if( !listLeaveRequest.isEmpty() ){
            for ( Leave_Request__Share reader : listLeaveRequest){
                shareUserIDSet.add(reader.UserOrGroupId);
            }
        }
        if( !listLeaveApplication.isEmpty() ){
            for ( Leave_Application__Share reader : listLeaveApplication){
                shareUserIDSet.add(reader.UserOrGroupId);
            }
        }
        for (User reader :[select id from user where isactive = true and id in :shareUserIDSet]){
            activeUserIDMap.put(reader.id, reader);
        }
        
        if( !listLeaveRequest.isEmpty() ){
            for ( Leave_Request__Share reader : listLeaveRequest){
                if ( activeUserIDMap.containsKey(reader.UserOrGroupId) ){
                    lrshareList.add(reader);
                }
            }
            upsert lrshareList;
        }
        
        if( !listLeaveApplication.isEmpty() ){
            for (Leave_Application__Share reader : listLeaveApplication){
                if ( activeUserIDMap.containsKey(reader.UserOrGroupId) ){
                    lashareList.add(reader);
                }
            }
            upsert lashareList;
        }
        if( !toBeDelEntitySubscriptionIdSet.isEmpty() ){
            for ( EntitySubscription reader : [select id from EntitySubscription where ParentId in :toBeDelEntitySubscriptionIdSet] ){
                toBeDelEntitySubscriptionList.add(reader);
            }
            delete toBeDelEntitySubscriptionList;
        }       
        if( !EntitySubscriptionList.isEmpty() ){
            Insert EntitySubscriptionList;
        }
    }
    
    public static void chatterPost( Map <Id, Leave_Request__c> newLeaveRequestMap, Map<Id,Leave_Request__c> oldLeaveRequestMap ){
        System.debug('===========Start===============chatterPost=================');
        List <Leave_Request__c> lrList = new List < Leave_Request__c > ();
        List <EntitySubscription> EntitySubscriptionList = new List <EntitySubscription> ();
        List <EntitySubscription> toBeDelEntitySubscriptionList = new List <EntitySubscription> ();
        List <Id> listCopyTo = null;
        Set <Id> setCopyTo = null; 
        Map <Id, String> recordtype = new Map <Id, String>();
        Map <Id, String> Mapfcomment = new Map <Id, String>();
        Map <String, String> MapChatterPost = new Map <String, String>();
        Map <String, List<Id> > MapCopyTo = new Map <String, List<Id> >();
        String stringChatterFeed = '';
        String ChatterId = '';
        String key = '';
        FeedComment fcomment = null;
        List <FeedComment> listfcomment = new List <FeedComment>();
        String status = '';
        
        for ( RecordType rt : LeaveRequestTriggerHandler.getLeaveRequestRts()){
            recordtype.put ( rt.id, rt.DeveloperName );
        }
        for ( Leave_request__c lr : newLeaveRequestMap.values() ){
            status = lr.status__c;            
            if ( status == LeaveRequestConstant.STATUS_PENDING_APPROVAL && ( oldLeaveRequestMap.get(lr.id).Status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED || oldLeaveRequestMap.get(lr.id).Status__c == LeaveRequestConstant.STATUS_DRAFT ) && !lr.Is_Mandatory_Leave_Request__c && recordtype.get(lr.RecordTypeId) == LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST ){
                if ( lr.ChatterFeedId__c == null){                    
                    key = lr.id;                       
                    stringChatterFeed = lr.Applicant__c + ' ' + Label.ELeave_Chatter_CC_Message + ' \n\n';
                    stringChatterFeed += lr.From__c + ' ' + Label.ELeave_General_To + ' ' + lr.To__c + '\n\n';
                    System.debug('===============================stringChatterFeed ================='+stringChatterFeed );
                    setCopyTo = new Set <Id>();
                    if ( lr.Copy_to_1__c != null){                          
                        setCopyTo.add(lr.Copy_to_1__c);
                    }
                    if ( lr.Copy_to_2__c != null){
                        setCopyTo.add(lr.Copy_to_2__c);
                    }
                    if ( lr.Copy_to_3__c != null){
                        setCopyTo.add(lr.Copy_to_3__c);
                    }
                    if ( lr.Copy_to_4__c != null){
                        setCopyTo.add(lr.Copy_to_4__c);
                    }
                    if ( lr.Copy_to_5__c != null){
                        setCopyTo.add(lr.Copy_to_5__c);
                    }
                    if ( lr.Copy_to_6__c != null){
                        setCopyTo.add(lr.Copy_to_6__c);
                    }
                    if ( lr.Copy_to_7__c != null){
                        setCopyTo.add(lr.Copy_to_7__c);
                    }
                    if ( lr.Copy_to_8__c != null){
                        setCopyTo.add(lr.Copy_to_8__c);
                    }
                    if ( lr.Copy_to_9__c != null){
                        setCopyTo.add(lr.Copy_to_9__c);
                    }
                    if ( lr.Copy_to_10__c != null){
                        setCopyTo.add(lr.Copy_to_10__c);
                    }                        
                    setCopyTo.add(lr.createdbyid);
                    if ( lr.On_Behalf_of_User__c != null){
                        setCopyTo.add(lr.On_Behalf_of_User__c);
                    }
                    System.debug('===============================setCopyTo================='+setCopyTo);                    
                    listCopyTo  = new List<Id>(setCopyTo);
                    MapCopyTo.put( key, listCopyTo );
                    System.debug('===============================MapCopyTo================='+MapCopyTo);
                    /*
                    for (Id reader : listCopyTo){
                        EntitySubscriptionList.add(new EntitySubscription (ParentId = lr.id, SubscriberId = reader));
                    }
                    */
                    MapChatterPost.put(key, stringChatterFeed);
                    System.debug('===============================MapChatterPost================='+MapChatterPost);
                }
                else {
                    stringChatterFeed = lr.From__c + ' ' + Label.ELeave_General_To + ' ' + lr.To__c + '\n\n';               
                    if ( Mapfcomment.containskey( lr.ChatterFeedId__c) ){
                       stringChatterFeed = Mapfcomment.get(lr.ChatterFeedId__c) + stringChatterFeed;                       
                    }
                    else{
                        stringChatterFeed = lr.Applicant__c + ' ' + Label.ELeave_Chatter_CC_Message + ' \n\n' + stringChatterFeed;
                    }
                    Mapfcomment.put( lr.ChatterFeedId__c, stringChatterFeed );                    
                }     
            }
        }               
        for ( String postKey : MapChatterPost.keyset() ){
            Chatterid = ChatterUtil.simpleTextPostWithMultipleMentions(postKey, MapCopyTo.get(postKey), MapChatterPost.get(postKey) );
            System.debug('===============================Chatterid ================='+Chatterid );
            lrList.add(new Leave_Request__c (id = postKey, ChatterFeedId__c = Chatterid ) );
        }
        System.debug('===============================lrList================='+lrList);           
        for ( Id reader : Mapfcomment.keySet() ){
            fcomment = new FeedComment(); 
            fcomment.FeedItemId = reader;
            stringChatterFeed = Mapfcomment.get(reader);
            fcomment.CommentBody = stringChatterFeed.unescapeJava().unescapeHtml4()  ;
            listfcomment.add(fcomment);            
        } 
        /*      
        for (EntitySubscription reader : [select id from EntitySubscription where ParentId = :MapCopyTo.keySet() ]){
            toBeDelEntitySubscriptionList.add(reader);
        }       
        if ( !toBeDelEntitySubscriptionList.isempty() ){
            delete toBeDelEntitySubscriptionList;
        }
        if ( !EntitySubscriptionList.isempty() ){
            try{
                insert EntitySubscriptionList;
            } 
            catch(Exception e){}
        }
        */
        if ( !listfcomment.isempty() ){
            insert listfcomment;
        }
        if ( !lrList.isempty() ){
            System.debug('===============================update start================='+lrList);    
            update lrList;
            System.debug('===============================update end================='+lrList);    
        }
        System.debug('===========End===============chatterPost=================');
    }
    
    public List <Leave_Request__share> listLeaveRequestShare ( Leave_Request__c newLeaveRequest, Employee__c employeec, Set <Id> setLeaveRequestOwner){
        List <Leave_Request__share> listLeaveRequest = new List <Leave_Request__share>();
        Leave_Request__share tmpLeaveRequestshare = null;               
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_1__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }       
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_1__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }       
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_2__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }       
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_3__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }       
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_4__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }       
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_5__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }       
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_6__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }       
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_7__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }       
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_8__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_9__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Copy_to_10__c, COPY_TO_USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, employeec.User__r.id, USER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Actual_Approver_1__c, APPROVER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Actual_Approver_2__c, APPROVER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Actual_Approver_3__c, APPROVER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }
        tmpLeaveRequestshare = LeaveRequestshare ( newLeaveRequest.id, newLeaveRequest.Actual_Approver_4__c, APPROVER_ACCESS_RIGHT, setLeaveRequestOwner);
        if ( tmpLeaveRequestshare != null ){
            listLeaveRequest.add(tmpLeaveRequestshare );
        }
        return listLeaveRequest;
    }
    
    public List <Leave_Application__share> listLeaveApplicationShare ( Leave_Request__c newLeaveRequest, Employee__c employeec, Set <Id> setLeaveApplicationOwner  ){
        List <Leave_Application__share> listLeaveApplication = new List <Leave_Application__share>();
        Leave_Application__Share tmpLeaveApplicationshare = null;        
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_1__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_2__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_3__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_4__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_5__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_6__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_7__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_8__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_9__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Copy_to_10__c , COPY_TO_USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, employeec.User__r.id, USER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }        
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Actual_Approver_1__c, APPROVER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Actual_Approver_2__c, APPROVER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Actual_Approver_3__c, APPROVER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        tmpLeaveApplicationshare = LeaveApplicationshare ( newLeaveRequest.Leave_Application__c, newLeaveRequest.Actual_Approver_4__c, APPROVER_ACCESS_RIGHT, setLeaveApplicationOwner );
        if ( tmpLeaveApplicationshare != null ){
            listLeaveApplication.add(tmpLeaveApplicationshare);
        }
        return listLeaveApplication;
    }
    
    public static Leave_Request__Share LeaveRequestshare ( Id pid, Id uid, String AccessLevel, set<id> owner  )
    {
        if ( uid == null || owner.contains(uid) ){
            return null;
        }        
        Leave_Request__Share LeaveRequestShare = new Leave_Request__Share ();
        LeaveRequestShare.ParentId = pid ;
        LeaveRequestShare.UserOrGroupId = uid ;
        LeaveRequestShare.AccessLevel = AccessLevel  ;        
        return LeaveRequestShare  ;
    }
    
    public static Leave_Application__Share LeaveApplicationshare ( Id pid, Id uid, String AccessLevel, set<id> owner  )
    {
        if ( uid == null || owner.contains(uid) ) {
            return null;
        }
        Leave_Application__Share LeaveApplicationShare = new Leave_Application__Share ();
        LeaveApplicationShare.ParentId = pid ;
        LeaveApplicationShare.UserOrGroupId = uid ;
        LeaveApplicationShare.AccessLevel = AccessLevel;
        return LeaveApplicationShare;
    }
    
    public string adjcalculation (string orgTime, string adjustment)
    {
        Integer integerOrghr, integerOrgmin, integerAdjustmentMins;        
        if ( orgTime != null && adjustment != null && orgTime.contains(SPLIT) ){
            integerOrghr = Integer.Valueof(orgTime.split(SPLIT)[0]); 
            integerOrgmin = Integer.Valueof(orgTime.split(SPLIT)[1]);
            integerAdjustmentMins = Integer.Valueof(adjustment);
            integerOrgmin = integerOrgmin + integerAdjustmentMins;
            if ( integerOrgmin < 0 ){
                integerOrgmin = LeaveRequestConstant.HOUR_IN_MINUTES + integerOrgmin;
                integerOrghr = integerOrghr - 1;
            }
            else if ( integerOrgmin >= LeaveRequestConstant.HOUR_IN_MINUTES ){
                integerOrgmin = integerOrgmin - LeaveRequestConstant.HOUR_IN_MINUTES;
                integerOrghr = integerOrghr + 1;
            } 
            return (( integerOrghr < 10)? '0' + String.valueof(integerOrghr):String.valueof(integerOrghr)) + ':' + ((integerOrgmin < 10 )? '0' + String.valueof(integerOrgmin) : String.valueof(integerOrgmin));                
        }
        else{
            return '';
        }
    }
    
    public void flextimeadj ( Leave_Request__c FlexibleTimeApplication, Employee__c employeec  )
    {
        String stringOrgStartTime = '';
        String stringOrgEndTime = '';
        String stringResult = '';        
        FlexibleTimeApplication.Adj_Start_Time__c = null;
        FlexibleTimeApplication.Adj_End_Time__c = null;
        FlexibleTimeApplication.Original_Start_Time__c = null;
        FlexibleTimeApplication.Original_End_Time__c = null;
        
        if (FlexibleTimeApplication.Day_Of_Week__c == LeaveRequestConstant.SUNDAY && employeec.Timeset__r.Is_Sun_Available__c ) {
            if ( employeec.Timeset__r.SunStartTime1__c != null ){
                FlexibleTimeApplication.Original_Start_Time__c = employeec.Timeset__r.SunStartTime1__c;
            }
            if ( employeec.Timeset__r.SunEndTime1__c != null ){
                FlexibleTimeApplication.Original_End_Time__c = employeec.Timeset__r.SunEndTime1__c;
            }
        }
        else if (FlexibleTimeApplication.Day_Of_Week__c == LeaveRequestConstant.MONDAY && employeec.Timeset__r.Is_Mon_Available__c ){
            if ( employeec.Timeset__r.MonStartTime1__c != null ){
                FlexibleTimeApplication.Original_Start_Time__c = employeec.Timeset__r.MonStartTime1__c;
            }
            if ( employeec.Timeset__r.MonEndTime1__c != null ){
                FlexibleTimeApplication.Original_End_Time__c = employeec.Timeset__r.MonEndTime1__c;
            }
        } 
        else if ( FlexibleTimeApplication.Day_Of_Week__c == LeaveRequestConstant.TUESDAY  && employeec.Timeset__r.Is_Tue_Available__c ) {
            if ( employeec.Timeset__r.TueStartTime1__c != null ){
                FlexibleTimeApplication.Original_Start_Time__c = employeec.Timeset__r.TueStartTime1__c;
            }
            if ( employeec.Timeset__r.TueEndTime1__c != null ){
                FlexibleTimeApplication.Original_End_Time__c = employeec.Timeset__r.TueEndTime1__c;
            }
        }
        else if (FlexibleTimeApplication.Day_Of_Week__c == LeaveRequestConstant.WEDNESDAY  && employeec.Timeset__r.Is_Wed_Available__c ) {
            if ( employeec.Timeset__r.WedStartTime1__c != null ){
                FlexibleTimeApplication.Original_Start_Time__c = employeec.Timeset__r.WedStartTime1__c;
            }
            if ( employeec.Timeset__r.WedEndTime1__c != null ){
                FlexibleTimeApplication.Original_End_Time__c = employeec.Timeset__r.WedEndTime1__c;
            }
        }
        else if (FlexibleTimeApplication.Day_Of_Week__c == LeaveRequestConstant.THURSDAY   && employeec.Timeset__r.Is_Thu_Available__c ) {
            if ( employeec.Timeset__r.ThuStartTime1__c != null ){
                FlexibleTimeApplication.Original_Start_Time__c = employeec.Timeset__r.ThuStartTime1__c;
            }
            if ( employeec.Timeset__r.ThuEndTime1__c != null ){
                FlexibleTimeApplication.Original_End_Time__c = employeec.Timeset__r.ThuEndTime1__c;
            }
        }
        else if (FlexibleTimeApplication.Day_Of_Week__c == LeaveRequestConstant.FRIDAY && employeec.Timeset__r.Is_Fri_Available__c ) {
            if ( employeec.Timeset__r.FriStartTime1__c != null ){
                FlexibleTimeApplication.Original_Start_Time__c = employeec.Timeset__r.FriStartTime1__c;
            }
            if ( employeec.Timeset__r.FriEndTime1__c != null ){
                FlexibleTimeApplication.Original_End_Time__c = employeec.Timeset__r.FriEndTime1__c;
            }
        }
        else if (FlexibleTimeApplication.Day_Of_Week__c == LeaveRequestConstant.SATURDAY  && employeec.Timeset__r.Is_Sat_Available__c ) {
            if ( employeec.Timeset__r.SatStartTime1__c != null ){
                FlexibleTimeApplication.Original_Start_Time__c = employeec.Timeset__r.SatStartTime1__c;
            }
            if ( employeec.Timeset__r.SatEndTime1__c != null ){
                FlexibleTimeApplication.Original_End_Time__c = employeec.Timeset__r.SatEndTime1__c;
            }
        }
        stringOrgStartTime = FlexibleTimeApplication.Original_Start_Time__c;
        stringOrgEndTime = FlexibleTimeApplication.Original_End_Time__c;
        if ( stringOrgStartTime != null && stringOrgEndTime != null ){
            stringResult = adjcalculation (stringOrgStartTime, FlexibleTimeApplication.Adjustment_mins__c);
            if ( stringResult != '' ) {
                FlexibleTimeApplication.Adj_Start_Time__c = stringResult;
            }
            stringResult = adjcalculation (stringOrgEndTime, FlexibleTimeApplication.Adjustment_mins__c);
            if ( stringResult != '' ){
                FlexibleTimeApplication.Adj_End_Time__c = stringResult;
            }
            FlexibleTimeApplication.status__c = LeaveRequestConstant.STATUS_NOT_SUBMITTED;
        }
        else{
            FlexibleTimeApplication.Adjustment_mins__c = null;                    
        }
    }
}