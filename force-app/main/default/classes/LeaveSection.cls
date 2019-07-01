public without sharing class LeaveSection  
    {
        public Leave_Request__c  leavetransaction {get;set;}
        public boolean booleanechecked  {get;set;}
        public List <Leave_Type__c> ListLeaveType {get;set;}
        public List <SelectOption> ListLeaveStartTimeOption {get;set;}
        public List <SelectOption> ListLeaveEndTimeOption {get;set;}
        public List <Leave_Available_Time__c> listLeaveAvailableTime  {get;set;}
        public String stringLeaveStartTime  {get;set;}
        public String stringLeaveEndTime  {get;set;} 
        public boolean booleanRemarkRequire  {get;set;} 
        public boolean lateapplication {get;set;}
        public String stringErrorMsg {get;set;}
        public Map <String, Decimal> mapLeaveTypeDeduction {get;set;}
        public Map <String, Decimal> mapItemLeaveTypeDeduction {get;set;}        
        public String stringtmp {get;set;}
        public List <Holiday__c> listHoliday {get;set;}  
        public String comDate {get;set;}  
        /*
         *  @description leave section class constructor
         */     
        public LeaveSection (Leave_Request__c  leavetransaction, List <Leave_Type__c> ListLeaveType, Map <String, Decimal> mapLeaveTypeDeduction, List <Leave_Available_Time__c> listLeaveAvailableTime, List <Holiday__c> listHoliday )
        {
            this.booleanechecked = false;
            this.booleanRemarkRequire = false;
            this.ListLeaveType = ListLeaveType;
            this.leavetransaction = leavetransaction;
            this.ListLeaveStartTimeOption = new List<SelectOption>();
            this.ListLeaveEndTimeOption = new List<SelectOption>();
            this.mapItemLeaveTypeDeduction = new Map <String, Decimal>();
            this.stringLeaveStartTime = '';
            this.stringLeaveEndTime = '';
            this.stringErrorMsg = '';
            this.mapLeaveTypeDeduction = mapLeaveTypeDeduction;
            this.listLeaveAvailableTime = listLeaveAvailableTime;
            this.listHoliday = listHoliday;
            if ( this.leavetransaction.Leave_Type__c == null && ! this.ListLeaveType.isEmpty() )
            {
                this.lateapplication = false;
            } 
            
            for (Leave_Available_Time__c LeaveAvailableTime : this.listLeaveAvailableTime  ){
                if ( LeaveAvailableTime.Leave_Type__c == leavetransaction.Leave_Type__c  ){
                    if ( LeaveAvailableTime.Available_Start_Time__c  != null ){
                        if ( stringLeaveStartTime == '' ){
                            stringLeaveStartTime = LeaveAvailableTime.id;
                        }
                        ListLeaveStartTimeOption.add( new SelectOption(LeaveAvailableTime.id, LeaveAvailableTime.Available_Start_Time__c ) );
                    }
                    if ( LeaveAvailableTime.Available_End_Time__c != null ){
                        if ( stringLeaveEndTime == '' ){
                            stringLeaveEndTime = LeaveAvailableTime.id;
                        }
                        ListLeaveEndTimeOption.add( new SelectOption(LeaveAvailableTime.id, LeaveAvailableTime.Available_End_Time__c ) );
                    }
                }
            }
        }
        
        public void changeLeaveType( )
        { changeLeaveType( true );} 
        
        
        public void changeLeaveTypefalse( )
        { changeLeaveType( false );} 
        
        
        public void changeLeaveType( boolean isinitial )
        {
            Leave_Type__c  tmpLeaveType = null;
            if ( !isinitial ){
                stringLeaveEndTime = '';
                stringLeaveStartTime = '';
            }
            
            this.booleanRemarkRequire = false;
            this.ListLeaveStartTimeOption.clear();
            this.ListLeaveEndTimeOption.clear();
            
            for ( Leave_Type__c LeaveType : this.ListLeaveType){
                if ( LeaveType.id == this.leavetransaction.Leave_Type__c ){
                    tmpLeaveType = LeaveType;
                }
            }
            
            if ( tmpLeaveType  != null ){
                if ( tmpLeaveType.id == this.leavetransaction.Leave_Type__c ){
                    this.booleanRemarkRequire = false;
                    this.ListLeaveStartTimeOption.clear();
                    this.ListLeaveEndTimeOption.clear();
                    for (Leave_Available_Time__c LeaveAvailableTime : this.listLeaveAvailableTime ){
                        if ( LeaveAvailableTime.Leave_Type__c == leavetransaction.Leave_Type__c ){
                            if ( LeaveAvailableTime.Available_Start_Time__c  != null ){
                                if ( stringLeaveStartTime == '' ){
                                    stringLeaveStartTime = LeaveAvailableTime.id;
                                }
                                this.ListLeaveStartTimeOption.add( new SelectOption(LeaveAvailableTime.id, LeaveAvailableTime.Available_Start_Time__c ) );
                            }
                            if ( LeaveAvailableTime.Available_End_Time__c != null ){
                                if ( !isinitial ){
                                    stringLeaveEndTime = LeaveAvailableTime.id;
                                }
                                this.ListLeaveEndTimeOption.add( new SelectOption(LeaveAvailableTime.id, LeaveAvailableTime.Available_End_Time__c ) );
                            }
                        }
                    }
                    this.leavetransaction.Leave_Type__r = tmpLeaveType;
                }
            }
            changeDeductionCalculation();            
        }
        
        public void changeLateApplication()
        {            
            Integer integerDays= 0;
            if ( leavetransaction.From_Date__c != null && leavetransaction.Deduction__c!= null && leavetransaction.Leave_Type__r.Lead_Time_Threshold__c  != null  ){
                integerDays = system.today().daysBetween( leavetransaction.From_Date__c );
                if ( leavetransaction.Deduction__c> leavetransaction.Leave_Type__r.Lead_Time_Threshold__c ){
                    if ( integerDays <= leavetransaction.Leave_Type__r.Lead_Time_above_Threshold__c ){
                        leavetransaction.Late_Application__c= true;
                    }
                    else{
                        leavetransaction.Late_Application__c= false;
                     }
                }
                else{
                    if ( integerDays  <= leavetransaction.Leave_Type__r.Lead_Time_Below_Threshold__c  ){
                        leavetransaction.Late_Application__c= true;
                    }
                    else{
                        leavetransaction.Late_Application__c = false;
                    }
                }
            }
            else{
                 leavetransaction.Late_Application__c = false;
            }            
        }
        
        /*
         *  @description to calculate Leave Request total days
         */
        public void changeDeductionCalculation()
        { 
            Map<String, Decimal> mapEarlyRelease = new Map<String, Decimal>();
            leavetransaction.Deduction__c = 0;
            
            //if start/end Time, from/to date, timeset and leave type are not empty, the leave request will start to calculate the leave request total days
            if ( stringLeaveStartTime != '' && stringLeaveEndTime != '' && leavetransaction.On_Behalf_of__r.Timeset__c != null && leavetransaction.Leave_Type__c != null  && leavetransaction.To_Date__c != null && leavetransaction.From_Date__c  != null ){
                List <Leave_Available_Time__c> listlat = new List <Leave_Available_Time__c>();
                List <Holiday__c> listholiday = new List <Holiday__c>();
                Integer [] integerDaysOfWeek = new Integer [LeaveRequestConstant.WEEKDAYS];
                Decimal [] decDaysOfMonth = new Decimal [LeaveRequestConstant.YEAR_IN_MONTHS ];
                Integer integerDays = 0;
                Integer integerDaysRemainder = 0;
                Integer integerDay = 0;
                String stringAvailableStartTime = '';
                String stringAvailableEndTime = '';
                Decimal decCost = 0;
                Decimal decTotalCost = 0;
                Decimal decTotalAvailableTimeCost = 0;
                integerDays = 1 + leavetransaction.From_Date__c.daysBetween( leavetransaction.To_Date__c );
                integerDaysRemainder = Math.Mod ( integerDays, LeaveRequestConstant.WEEKDAYS );
                
                for ( Integer i = 0; i <decDaysOfMonth.size(); i ++){
                    decDaysOfMonth[i] = 0;
                }
                
                //To calculate number of days from a specific date to a specific date
                for ( Integer i = 0; i <integerDaysOfWeek.size(); i ++){
                    integerDaysOfWeek[i] = integerDays / LeaveRequestConstant.WEEKDAYS;
                }
                integerDay = Math.Mod ( Date.newInstance(1900, 1, 7).daysBetween( leavetransaction.From_Date__c  ),7 );                
                
                for (integer i = integerDay; i <integerDay + integerDaysRemainder; i++){
                    if ( i > 6){
                        integerDaysOfWeek[i-LeaveRequestConstant.WEEKDAYS] += 1;
                    }
                    else{
                        integerDaysOfWeek[i] += 1;
                    }
                }
                
                //if it is a dayoff, the integerDaysOfWeek[day of week] = 0
                if ( leavetransaction.Leave_Type__r.Deduct_Non_Working_Day__c ){
                    if ( !leavetransaction.On_Behalf_of__r.Timeset__r.Is_Sun_Available__c ){
                            integerDaysOfWeek[LeaveRequestConstant.SUNDAY] = 0;
                    }
                    if ( !leavetransaction.On_Behalf_of__r.Timeset__r.Is_Mon_Available__c ){
                            integerDaysOfWeek[LeaveRequestConstant.MONDAY ] = 0;
                    }
                    if ( !leavetransaction.On_Behalf_of__r.Timeset__r.Is_Tue_Available__c ){
                            integerDaysOfWeek[LeaveRequestConstant.TUESDAY ] = 0;
                    }
                    if ( !leavetransaction.On_Behalf_of__r.Timeset__r.Is_Wed_Available__c ){
                            integerDaysOfWeek[LeaveRequestConstant.WEDNESDAY ] = 0;
                    }
                    if ( !leavetransaction.On_Behalf_of__r.Timeset__r.Is_Thu_Available__c ){
                            integerDaysOfWeek[LeaveRequestConstant.THURSDAY ] = 0;
                    }
                    if ( !leavetransaction.On_Behalf_of__r.Timeset__r.Is_Fri_Available__c ){
                            integerDaysOfWeek[LeaveRequestConstant.FRIDAY ] = 0;
                    }
                    if ( !leavetransaction.On_Behalf_of__r.Timeset__r.Is_Sat_Available__c ){
                            integerDaysOfWeek[LeaveRequestConstant.SATURDAY ] = 0;
                    } 
                }
                //if the day is a holiday,the integerDaysOfWeek[day of week] = 1
                if ( leavetransaction.On_Behalf_of__r.Employee_Type__r.Entitled_Public_Holiday__c && leavetransaction.Leave_Type__r.Deduct_Public_Holiday__c ){
                    for ( Holiday__c holiday : this.listHoliday){
                        if ( holiday.Leave_Policy__c == leavetransaction.On_Behalf_of__r.Leave_Policy__c && holiday.Type__c == LeaveRequestConstant.HOLIDAY_TYPE && holiday.Date__c>= leavetransaction.From_Date__c && holiday.Date__c <= leavetransaction.To_Date__c ){
                            if ( integerDaysOfWeek[(Integer)holiday.Day_Of_Week__c]> 0 ){
                                integerDaysOfWeek[(Integer)holiday.Day_Of_Week__c] -= (Integer)Math.ceil(holiday.cost__c);
                                decDaysOfMonth[(holiday.Date__c).Month() -1  ] -= holiday.cost__c;
                            }
                        }
                    }
                }
                
                //To calculate total days
                for ( Integer i = 0; i < LeaveRequestConstant.WEEKDAYS; i++){
                       leavetransaction.Deduction__c += integerDaysOfWeek[i];
                }
                
                for ( Leave_Available_Time__c LeaveAvailableTime : this.listLeaveAvailableTime ){
                    if ( LeaveAvailableTime.id == stringLeaveStartTime ){
                        stringAvailableStartTime = LeaveAvailableTime.Available_Start_Time__c;
                    }
                    if ( LeaveAvailableTime.id == stringLeaveEndTime ){
                        stringAvailableEndTime = LeaveAvailableTime.Available_End_Time__c;
                    }
                    
                }
                
                //if the leave request takes one day leave, the From_Date_Unit_Cost__c = deduction
                if ( leavetransaction.Deduction__c == 1 ){                    
                    decTotalAvailableTimeCost = 0;
                    for ( Leave_Available_Time__c leaveAvailableTimeReader : this.listLeaveAvailableTime ){
                        if ( leaveAvailableTimeReader.Leave_Type__c == leavetransaction.Leave_Type__c && leaveAvailableTimeReader.Timeset__c == leavetransaction.On_Behalf_of__r.Timeset__c && leaveAvailableTimeReader.Available_Start_Time__c>= stringAvailableStartTime && leaveAvailableTimeReader.Available_End_Time__c <= stringAvailableEndTime ){
                            decTotalAvailableTimeCost += leaveAvailableTimeReader.cost__c;
                        }
                    }
                    if ( decTotalAvailableTimeCost == 0){
                        leavetransaction.Deduction__c = 0;
                    }
                    else{
                        leavetransaction.Deduction__c = leavetransaction.Deduction__c * decTotalAvailableTimeCost;
                        leavetransaction.From_Date_Unit_Cost__c = leavetransaction.Deduction__c;
                        leavetransaction.To_Date_Unit_Cost__c = 0;
                    }                    
                }
                //if the total days > 1 , the From_Date_Unit_Cost__c = first day deduction and To_Date_Unit_Cost__c = end day deduction
                else if ( leavetransaction.Deduction__c > 1 ){                    
                    decCost = 0;
                    decTotalAvailableTimeCost = 0;
                    for ( Leave_Available_Time__c leaveAvailableTimeReader : this.listLeaveAvailableTime ){
                        if ( leaveAvailableTimeReader.Leave_Type__c == leavetransaction.Leave_Type__c && leaveAvailableTimeReader.Timeset__c == leavetransaction.On_Behalf_of__r.Timeset__c && leaveAvailableTimeReader.Available_Start_Time__c>= stringAvailableStartTime ){
                            decTotalAvailableTimeCost += leaveAvailableTimeReader.cost__c;
                        }
                    }
                    leavetransaction.From_Date_Unit_Cost__c = decTotalAvailableTimeCost;
                    decCost += decTotalAvailableTimeCost;
                    
                    decTotalAvailableTimeCost = 0;
                    for ( Leave_Available_Time__c leaveAvailableTimeReader : this.listLeaveAvailableTime ){
                        if ( leaveAvailableTimeReader.Leave_Type__c == leavetransaction.Leave_Type__c && leaveAvailableTimeReader.Timeset__c == leavetransaction.On_Behalf_of__r.Timeset__c  && leaveAvailableTimeReader.Available_End_Time__c <= stringAvailableEndTime){
                            decTotalAvailableTimeCost += leaveAvailableTimeReader.cost__c;
                        }                    
                    }
                    leavetransaction.To_Date_Unit_Cost__c = decTotalAvailableTimeCost;
                    decCost += decTotalAvailableTimeCost;
                    leavetransaction.Deduction__c = (leavetransaction.Deduction__c - 2) + decCost;
                } 
                
                //To calculate the early release                
                if ( leavetransaction.On_Behalf_of__r.Employee_Type__r.Entitled_Early_Release__c && leavetransaction.Leave_Type__r.Deduct_Early_Release__c && leavetransaction.Deduction__c > 0 ){
                    for ( Leave_Available_Time__c  lat : this.listLeaveAvailableTime){
                        if ( lat.Timeset__c == leavetransaction.On_Behalf_of__r.Timeset__c  && lat.Leave_Type__c == leavetransaction.Leave_Type__c ){
                            listlat.add(lat);
                        }
                    } 
                    for ( Holiday__c holiday : this.listHoliday){
                        if ( holiday.Leave_Policy__c == leavetransaction.On_Behalf_of__r.Leave_Policy__c && holiday.Type__c == LeaveRequestConstant.EARLY_RELEASE_TYPE && holiday.Date__c>= leavetransaction.From_Date__c && holiday.Date__c <= leavetransaction.To_Date__c){
                            listholiday.add(holiday);
                            decDaysOfMonth[(holiday.Date__c).Month() -1 ] -= (1 - holiday.cost__c );
                        }
                    }
                    decCost = 0;
                    decTotalCost = 0; 
                    
                    if ( !listholiday.isempty() ){
                        for( Holiday__c  holiday : listholiday ){
                            decCost = 0;
                            decTotalCost = 0;
                            //If the early release day = from day and to day, From_Date_Unit_Cost__c = leave request total day - early release cost and To_Date_Unit_Cost__c = 0
                            if ( leavetransaction.From_Date__c == leavetransaction.To_Date__c && holiday.date__c == leavetransaction.To_Date__c ){
                                for ( Leave_Available_Time__c  lat : listlat ){
                                    if ( (stringAvailableStartTime  <= lat.Available_START_Time__c && stringAvailableendTime>= lat.Available_end_Time__c) && ( lat.Available_Start_Time__c < holiday.Time__c ) ){
                                        decCost += lat.cost__c;
                                    }
                                    decTotalCost += lat.cost__c;
                                }
                                leavetransaction.From_Date_Unit_Cost__c = 0;
                                leavetransaction.To_Date_Unit_Cost__c = 0;
                                leavetransaction.Deduction__c = 0;
                                leavetransaction.From_Date_Unit_Cost__c = decCost;                                
                            }
                            //If the early release day = from day, From_Date_Unit_Cost__c = leave request total day - early release cost
                            else if ( leavetransaction.From_Date__c == holiday.date__c ){
                                for ( Leave_Available_Time__c  lat : listlat ){                                    
                                    if ( stringAvailableStartTime <= lat.Available_START_Time__c && ( lat.Available_Start_Time__c < holiday.Time__c ) ){
                                        decCost += lat.cost__c;
                                    }
                                    decTotalCost += lat.cost__c;
                                }
                                leavetransaction.Deduction__c -= leavetransaction.From_Date_Unit_Cost__c;
                                leavetransaction.From_Date_Unit_Cost__c = decCost;
                                
                            }
                            //If the early release day = to day, To_Date_Unit_Cost__c = leave request total day - early release cost
                            else if ( leavetransaction.To_Date__c == holiday.date__c ){
                                for ( Leave_Available_Time__c  lat : listlat ){                                    
                                    if ( stringAvailableendTime>= lat.Available_END_Time__c && ( lat.Available_Start_Time__c  <holiday.Time__c ) ){
                                        decCost += lat.cost__c;
                                    }
                                    decTotalCost += lat.cost__c;
                                }
                                leavetransaction.Deduction__c -= leavetransaction.To_Date_Unit_Cost__c;
                                leavetransaction.To_Date_Unit_Cost__c = decCost;
                            }
                            //If the early release day between from day and to day, total days = leave request total day - early release cost
                            else if ( leavetransaction.From_Date__c  <holiday.date__c && leavetransaction.To_Date__c> holiday.date__c ){
                                for ( Leave_Available_Time__c  lat : listlat ){
                                    if ( lat.Available_Start_Time__c  < holiday.Time__c ){
                                        decCost += lat.cost__c;
                                    }
                                    decTotalCost += lat.cost__c;
                                }
                                leavetransaction.Deduction__c -= decTotalCost;                                
                            }
                            leavetransaction.Deduction__c += decCost;
                        }
                    }
                }
                //To calculate total days
                leavetransaction.Deduction__c = Math.Max( 0.00, leavetransaction.Deduction__c  );
                
                // If it is a late application, the Late_Application__c = true
                this.changeLateApplication();
                
                //if the leave type must require supporting doc, Required_Supporting_Document__c = true
                if ( leavetransaction.Leave_Type__r.Document_Required__c != null && leavetransaction.Leave_Type__r.Document_Required__c == 0){
                     leavetransaction.Required_Supporting_Document__c = true;
                }
                if ( leavetransaction.Leave_Type__r.Document_Required__c == null ){
                    leavetransaction.Required_Supporting_Document__c = false;
                }
                
                //if the leave request meet supporting doc requirement, Required_Supporting_Document__c = true
                if ( leavetransaction.Leave_Type__r.Document_Required__c != null && leavetransaction.Leave_Type__r.Document_Required__c > 0 && leavetransaction.from_date__c != null &&  leavetransaction.to_date__c != null && leavetransaction.Leave_Type__c != null ){
                    Decimal decdeduction = 0;
                    Date startdate = leavetransaction.from_date__c;
                    Date enddate = leavetransaction.to_date__c;
                    Integer intDayOfWeek = 0;
                    Integer currmonth = 0;
                    currmonth = startdate.month();
                    stringtmp = '';
                    
                    for ( String key : mapItemLeaveTypeDeduction.keyset() ){
                        if ( this.mapLeaveTypeDeduction.containskey(key) ){
                            decdeduction = this.mapLeaveTypeDeduction.get(key) - mapItemLeaveTypeDeduction.get(key);
                            this.mapLeaveTypeDeduction.put ( key, decdeduction );
                        }
                    }
                    decdeduction = leavetransaction.Deduction__c;
                    mapItemLeaveTypeDeduction = new Map <String, Decimal>();
                    
                    //To set the leave type total days on related month
                    if ( startdate.year() == enddate.year() && startdate.month() == enddate.month() ){
                        mapItemLeaveTypeDeduction.put ( String.valueof(startdate.year()) + '_' + String.valueof(startdate.month()) + '_' + leavetransaction.Leave_Type__r.Name, decdeduction );
                    }
                    else{
                        decdeduction = 0;
                        for ( Date start = startdate;start <= enddate;start = start.adddays(1) ){
                            //initialize date as Sunday (1900-01-07)
                            intDayOfWeek = Math.Mod ( Date.newInstance(1900, 1, 7).daysBetween( start ),7 );
                            if(( 
                                leavetransaction.On_Behalf_of__r.Timeset__r.Is_Sun_Available__c && intDayOfWeek == LeaveRequestConstant.SUNDAY ||
                                leavetransaction.On_Behalf_of__r.Timeset__r.Is_Mon_Available__c && intDayOfWeek == LeaveRequestConstant.MONDAY ||
                                leavetransaction.On_Behalf_of__r.Timeset__r.Is_Tue_Available__c && intDayOfWeek == LeaveRequestConstant.TUESDAY ||
                                leavetransaction.On_Behalf_of__r.Timeset__r.Is_Wed_Available__c && intDayOfWeek == LeaveRequestConstant.WEDNESDAY ||
                                leavetransaction.On_Behalf_of__r.Timeset__r.Is_Thu_Available__c && intDayOfWeek == LeaveRequestConstant.THURSDAY ||
                                leavetransaction.On_Behalf_of__r.Timeset__r.Is_Fri_Available__c && intDayOfWeek == LeaveRequestConstant.FRIDAY ||
                                leavetransaction.On_Behalf_of__r.Timeset__r.Is_Sat_Available__c && intDayOfWeek == LeaveRequestConstant.SATURDAY  )){
                                if ( start.month() == currmonth  ){
                                    decdeduction += 1;
                                }
                                else{
                                    mapItemLeaveTypeDeduction.put( String.valueof(start.year()) + '_' + String.valueof(currmonth) + '_' + leavetransaction.Leave_Type__r.Name, decdeduction );
                                    decdeduction = 1;
                                    currmonth = start.month();
                                }
                            } 
                        }                        
                        mapItemLeaveTypeDeduction.put ( String.valueof(enddate.year()) + '_'+ String.valueof(enddate.month()) + '_' + leavetransaction.Leave_Type__r.Name, decdeduction );
                    }

                    if ( !( startdate.year() == enddate.year() && startdate.month() == enddate.month() ) ){
                        for ( String key : mapItemLeaveTypeDeduction.keyset() ){      
                            for ( Integer i = 0; i <decDaysOfMonth.size(); i++){
                                if ( key.contains('_' + string.valueof(i+1) + '_')){
                                    decdeduction = mapItemLeaveTypeDeduction.get(key) + decDaysOfMonth[i];
                                    mapItemLeaveTypeDeduction.put ( key, decdeduction  );
                                }
                            }
                        }
                    }
                    
                    decdeduction = 0;
                    for ( String reader : mapItemLeaveTypeDeduction.keySet() ){
                        if ( this.mapLeaveTypeDeduction.containskey(reader ) ){
                            decdeduction = this.mapLeaveTypeDeduction.get(reader) + mapItemLeaveTypeDeduction.get(reader);
                        }
                        else{
                            decdeduction = mapItemLeaveTypeDeduction.get(reader);                            
                        }
                        this.mapLeaveTypeDeduction.put (reader, decdeduction);
                    }                    
                    leavetransaction.Required_Supporting_Document__c = false;
                    
                    for ( String reader : mapItemLeaveTypeDeduction.keySet() ){                        
                        if ( this.mapLeaveTypeDeduction.get(reader) > leavetransaction.Leave_Type__r.Document_Required__c ){
                            leavetransaction.Required_Supporting_Document__c = true;
                        }
                    }
                    
                }
            }
        }
    }