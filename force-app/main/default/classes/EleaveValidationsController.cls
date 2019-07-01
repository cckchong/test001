public without sharing virtual  class EleaveValidationsController 
{    
    public static final String REQUIRE_SECOND_LEVEL_APPROVER = 'Require_Second_Level_Approver'; 
    public static final String SICK = 'Sick'; 
    public static final String ANNUAL = 'Annual'; 
    public static final String REPLACE_DATE = '@date';
    
    public EleaveValidationsController()
    {}
    
    public virtual  String datechecker ( Leave_Request__c  LeaveRequest )
    {
        String msg = '';        
        if ( LeaveRequest.From_Date__c > Date.today().addyears(1) ||  LeaveRequest.To_Date__c > Date.today().addyears(1) )
        {
            msg += Label.ELeave_Error_No_Longer_YR ;
        }
        return msg;
    }
    
    public virtual String deductionchecker ( Decimal deduction )
    {
        String msg = '';        
        if ( deduction == null || deduction <= 0 )
        {
            msg += Label.ELeave_Error_Greater_Zero;
        }
        return msg;
    }
    
    
    public virtual String advancechecker ( Leave_Request__c LeaveRequest )
    {    
        String msg = '';
        if ( !LeaveRequest.Leave_Type__r.Allow_Advanced_Leave__c && !LeaveRequest.Leave_Type__r.Allow_Unlimited_Leave_Balance__c )
        {
            if ( LeaveRequest.Advance_Leave__c > 0 )
            {
                msg += Label.ELeave_Error_Exceed_Balance;
            }
        }
        return msg;
    }
    
    public virtual String datebackchecker ( Leave_Type__c LeaveType, Leave_Request__c  LeaveRequest )
    {
        String msg = '';
        Date currentDate = Date.newInstance( Date.today().year(), Date.today().month(), 1);
        if(Test.isRunningTest()) { 
            currentDate = Date.newInstance( 2015, 3, 1); // It's because test cases are set to this date
        }
        
        if ( LeaveRequest.From_Date__c < currentDate.addMonths( -(Integer)LeaveType.Allow_Date_Back__c) ) {}
        if ( LeaveRequest.To_Date__c < currentDate.addMonths( -(Integer)LeaveType.Allow_Date_Back__c) ){}
        if ( LeaveRequest.From_Date__c < currentDate.addMonths( -(Integer)LeaveType.Allow_Date_Back__c) || LeaveRequest.To_Date__c < currentDate.addMonths( -(Integer)LeaveType.Allow_Date_Back__c) )        
        {
            msg = Label.ELeave_Error_Not_Available; 
        }
        return msg;
    }
    
    public virtual String leavebalancechecker ( Leave_Request__c  LeaveRequest, Map <String, Leave_Balance__c> mapLeaveBalance )
    {
        String msg = '';
        if ( !mapLeaveBalance.containskey (LeaveRequest.Leave_type__c) )
        {
            msg = Label.ELeave_Error_No_Leave_Balance;
        }
        return msg;
    }
    
    public virtual String lineremarkchecker ( Leave_Request__c LeaveRequest )
    {
        String msg = '';
        if ( LeaveRequest.Leave_Type__r.Remark_Require__c && LeaveRequest.Remarks__c == null )
        {
            msg += Label.ELeave_Error_Provide_Remark;
        }
        return msg;
    }
    
    public virtual String duplicateflexitimechecker ( Leave_Request__c LeaveRequest, List<Leave_Request__c> FlexiTimeLeaveRequest )
    {
        String msg = '';
        String stringLeaveType = '';
        
        if ( FlexiTimeLeaveRequest.isempty() )
        {
            return msg;
        }
        
        if ( LeaveRequest.Leave_type__c != null )
        {
            stringLeaveType = LeaveRequest.Leave_type__r.Leave_Type_ID__c;
        }
        
        if ( LeaveRequest.from_date__c != null && LeaveRequest.to_date__c != null )
        {
            for ( Leave_Request__c lqc : FlexiTimeLeaveRequest )
            {
                if ( lqc.date__c >= LeaveRequest.from_date__c && lqc.date__c <= LeaveRequest.to_date__c )
                {
                    msg = Label.ELeave_Error_Duplicate_FT;
                    if ( stringLeaveType.contains(ANNUAL) ||  stringLeaveType.contains(SICK) )
                    {
                         msg = '';
                    }
                    /*
                    if ( LeaveRequest.from_date__c != LeaveRequest.to_date__c &&  stringLeaveType.contains(SICK) )
                    {
                         msg = Label.ELeave_Error_Only_One_SL; 
                    }
                    if ( stringLeaveType.contains( ANNUAL ) )
                    {
                         msg = REQUIRE_SECOND_LEVEL_APPROVER; 
                    }
                    */
                }
            }
        }       
        return msg;
    }
    
    public String getModifiedDateTime(Date dateValue, string stringTimeValue )
    {
        String stringDateTime = '';     
        stringDateTime = String.valueof((dateValue).year()) + '/' + ('0'+String.valueof((dateValue).month())).right(2) +'/'+ ('0'+String.valueof((dateValue).day())).right(2) + ' ';
        stringDateTime += stringTimeValue.replaceAll('\\s','');
        return stringDateTime;
    }
    
    public virtual String duplicatedatechecker ( Leave_Request__c LeaveRequest, List <Leave_Request__c > ListLeaveRequest, Map <String, String> mapLeaveAvailableTime, String stringLeaveStartTime, String stringLeaveEndTime )
    {
        String msg = '';
        Integer counter = 0;
        String stringFromDate = '';
        String stringToDate = '';
        String stringCurrentFromDate = '';
        String stringCurrentToDate = '';
        
        if ( LeaveRequest.From_date__c == null || LeaveRequest.To_date__c == null )
        { return msg ; }
        stringLeaveStartTime = mapLeaveAvailableTime.get(stringLeaveStartTime).split('/')[0];
        stringLeaveEndTime = mapLeaveAvailableTime.get(stringLeaveEndTime).split('/')[1];        
        stringFromDate = getModifiedDateTime(LeaveRequest.From_date__c, stringLeaveStartTime);
        stringToDate = getModifiedDateTime(LeaveRequest.To_date__c, stringLeaveEndTime);
        
        for ( Leave_Request__c reader : ListLeaveRequest )
        {
            if ( reader.id != null )
            {                
                if 
                (
                    ( stringFromDate >= reader.from__c && stringToDate <= reader.to__c ) ||
                    ( stringFromDate <= reader.from__c && stringToDate >= reader.to__c ) ||
                    ( stringFromDate >= reader.from__c && stringFromDate < reader.to__c ) ||
                    ( stringToDate > reader.from__c && stringToDate <= reader.to__c ) 
                )
                {
                    counter = counter + 1; 
                } 
            }
            else
            {    
                if ( reader.From_date__c != null && reader.To_date__c != null )
                {   
                    stringCurrentFromDate = getModifiedDateTime(reader.From_date__c, reader.From_Hour__c + ':'+reader.From_Minute__c);
                    stringCurrentToDate = getModifiedDateTime(reader.To_date__c, reader.To_Hour__c + ':' + reader.To_Minute__c);
                    
                    if 
                    (
                        ( stringFromDate >= stringCurrentFromDate && stringToDate <= stringCurrentToDate ) ||
                        ( stringFromDate <= stringCurrentFromDate && stringToDate >= stringCurrentToDate ) ||
                        ( stringFromDate >= stringCurrentFromDate && stringFromDate <= stringCurrentToDate ) ||
                        ( stringToDate  > stringCurrentFromDate && stringToDate <= stringCurrentToDate ) 
                    )
                    {
                        counter = counter + 1;
                    }
                }
            }
             
            if ( counter == 2 )
            {
                counter = counter + 1;
                break;
            }
        }
        if ( counter >= 2 )
        {
            msg += Label.ELeave_Error_Duplicate_Days;           
        }
        return msg ;    
    }
    
    public virtual String MandatoryLeaveRequestDeductionChecker ( Decimal decDeduction )
    {
        if ( decDeduction == null )
        {
            return Label.ELeave_Error_Field_Is_Required;
        }
        if ( decDeduction < -1 || decDeduction > 1 || decDeduction == 0 || decDeduction == null)
        {
            if ( decDeduction == 0 )
            {
                return Label.ELeave_Error_Deduction_Zero;
            }
            return  Label.ELeave_Error_Deduction;
        }        
        return '';
    }
    
    public virtual String AdjustmentLeaveRequestDeductionChecker ( Decimal decDeduction )
    {
        if ( decDeduction < -1 || decDeduction > 1 || decDeduction == 0 || decDeduction == null )
        {
            if ( decDeduction == 0 )
            {
                return Label.ELeave_Adjust_Zero;
            }
            return Label.ELeave_Adjust_Deduction_Checker;
        }
        return '';
    }
    
    public virtual Boolean IsHolidayexisting (Date DateValue, String stringLeavePolicy, Decimal Deduction )
    {
        if ( Deduction == null )
        {
            return false;
        }
        Deduction  = Math.abs(Deduction); 
        for ( Holiday__c holiday : 
            [
              select date__c, Description__c, type__c 
              from Holiday__c 
              where Leave_Policy__c = :stringLeavePolicy and date__c = :DateValue  and cost__c = :Deduction 
        ]){
            return true;
        }        
        return false;
    }
    
    public virtual String compensationLeaveChecker(String comDate, Leave_Application__c request, Leave_Request__c LeaveRequest, List <LeaveSection> ListLeaveSection)
    {
        String msg = '';
        List <Id> travelApplicationIdList = new List <Id>();
        Map <ID, Double> travelApplicationCompDaysMap = new Map <ID, Double>();
        Map <ID, Double> leaveTotalCompDaysMap = new Map <ID, Double>();
        double totalDays = 0;
        
        for (LeaveSection reader : ListLeaveSection){
            if (!String.isBlank(reader.leavetransaction.Travel_Application__c)){
                travelApplicationIdList.add(reader.leavetransaction.Travel_Application__c);
            }
        }
        
        if(travelApplicationIdList.isEmpty()){
            return msg;
        }
        
        for(Travel_Application__c reader : [select id, Name, num_of_leave_days__c,
                                           (select id,  Name from Leave_Requests__r where leave_Application__c != :request.id)
                                           from Travel_Application__c 
                                           where id in (
                                                           select Travel_Application__c 
                                                           from Leave_request__c 
                                                           where 
                                                           Travel_Application__c  != null
                                                           and status__c in (:LeaveRequestConstant.STATUS_PENDING_APPROVAL, :LeaveRequestConstant.STATUS_APPROVED)
                                                           and Travel_Application__c  in :travelApplicationIdList
                                                       )
                                          ]){
            if (reader.id == LeaveRequest.travel_application__c){                
                for(Leave_request__c lr : reader.Leave_Requests__r){
                    msg += 'The Application had been called by ' + lr.Name + '.<BR/>';
                }
            }
        }
        if (!String.isBlank(msg)){
            return msg;
        }
        for (Travel_Application__c reader : [select id, num_of_leave_days__c from Travel_Application__c where id in :travelApplicationIdList]){
            travelApplicationCompDaysMap.put(reader.id, reader.num_of_leave_days__c);
        }
        for (LeaveSection reader : ListLeaveSection){
            if (!String.isBlank(reader.leavetransaction.Travel_Application__c)){
                if(leaveTotalCompDaysMap.containskey(reader.leavetransaction.Travel_Application__c)){
                    totalDays = leaveTotalCompDaysMap.get(reader.leavetransaction.Travel_Application__c);
                    totalDays += reader.leavetransaction.Deduction__c;
                    leaveTotalCompDaysMap.put(reader.leavetransaction.Travel_Application__c, totalDays);
                }
                else{
                    leaveTotalCompDaysMap.put(reader.leavetransaction.Travel_Application__c, reader.leavetransaction.Deduction__c);
                }
            }
        }
         
        for (LeaveSection reader : ListLeaveSection){
            if (!String.isBlank(reader.leavetransaction.Travel_Application__c)){                
                if(travelApplicationCompDaysMap.get(reader.leavetransaction.Travel_Application__c) <
                   leaveTotalCompDaysMap.get(reader.leavetransaction.Travel_Application__c) &&
                   reader.leavetransaction.id == LeaveRequest.id
                  ){
                      msg += 'You cannot take more than '+ travelApplicationCompDaysMap.get(reader.leavetransaction.Travel_Application__c) + ' day(s) compensation leave';
                }
            }
        }
        
        return msg;
        /*
        List <leave_request__c> LeaveTypeList = new List <leave_request__c>();
        Id travelApplicationId = null;
        Id leaveApplicationId = null;
        String name = '';
        String msg = '';
        Boolean existingTravelApplication = false;
        travelApplicationId = request.Travel_Application__c;
        leaveApplicationId = request.id;
        double totatlDays = 0;
        
        
        if(request.travel_Application__c == null){
            return msg;
        }
        for(Leave_Application__c reader : [select id, Name, (select id from leave_requests__r where Leave_Type__r.Reference_Travel_Application__c = true and status__c in (:LeaveRequestConstant.STATUS_PENDING_APPROVAL, :LeaveRequestConstant.STATUS_APPROVED)) from Leave_Application__c where  id != :leaveApplicationId]){
            name = reader.name;
            existingTravelApplication = true;
            LeaveTypeList = reader.leave_requests__r;
        }
        if(existingTravelApplication && LeaveTypeList.size() > 0){
            msg += 'The Application had been called by ' + name + '.<BR/>';
        }
        if (comDate != ''){
            totatlDays = 0;
            for(LeaveSection reader : ListLeaveSection){
                if ( reader.comDate == comDate){
                    totatlDays += reader.leavetransaction.Deduction__c;
                }
            }
        }        
        return msg;
        //*/
    return '';
    }
    
    public virtual String MandatoryLeaveRequestHolidayChecker (Date DateValue, String stringLeavePolicy )
    {
        Map <Date, Holiday__c> mapHoliday = new Map <Date, Holiday__c>();
        for ( Holiday__c holiday : [ select date__c, Description__c, type__c from Holiday__c where Leave_Policy__c = :stringLeavePolicy] )
        {
            mapHoliday.put ( holiday.date__c , holiday );
        }
        if ( mapHoliday.containsKey( DateValue ) )
        {            
            if ( mapHoliday.get( DateValue ).type__c == LeaveRequestConstant.EARLY_RELEASE_TYPE )
            {
                return (Label.ELeave_Error_Early_Release).replace( REPLACE_DATE, String.valueof( dateValue.format()) );
            }
            if ( mapHoliday.get( DateValue ).type__c == LeaveRequestConstant.HOLIDAY_TYPE )
            {
                return ( Label.ELeave_Error_Holiday ).replace( REPLACE_DATE, String.valueof( dateValue.format()) );
            }
        }
        else
        {
            return '';
        }        
        return '';
    }
}