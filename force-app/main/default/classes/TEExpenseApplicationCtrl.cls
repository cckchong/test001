public without sharing class TEExpenseApplicationCtrl{

        
        private static final String TRAVELAPPLICATIONNAME = '@name';
        public String BLANKVALUE{get;set;}
        
        public String tmp{get;set;}  
        private Integer defaultNoOfRows = 5;
        public Attachment attach {get;set;}  
        public string textId{get;set;}
        public String eaId{get;set;}
        public Expense_Application__c ea{get;set;}
        public List<ExpenseDetailBizTO> edl{get;set;}
        public string createdBy{get;set;}
        public string refNo{get;set;}
        public List<Expense_Detail__c> deletedList{get;set;}
        //public boolean isSalesforceOne{get;set;} {isSalesforceOne = SystemUtil.isMobileDevice();}
        public string status{get;set;}
        public List<AttachmentTO> attachments{get;set;}
        public List<AttachmentTO> contents{get;set;}
        public Integer countOfFiles{get;set;}
        public List<Expense_Type__c> expenseTypeList{get;set;}
        public Map<Id,Expense_Type__c> expenseTypeMap{get;set;}
        public String applicationLabel{get;set;}
        public Map<Id, Travel_Location_Allowance__c> tlaMap{get;set;} //Id:locationId  
        public Employee__c onBehalfOf{get;set;}
        public Map<Id, Employee__c> onBehalfOfMap{get;set;}
        public Map<String, Exchange_Rate__c> rateMap{get;set;}
        public Map<Date,double> mealAmount{get;set;}
        public Map<Date,double> hotelAmount{get;set;}
        public Map<Date,double> mealCapMap{get;set;}
        public Map<Date,double> hotelCapMap{get;set;}
        public Map<date, List<Integer>> lineMealMap{get;set;}
        public Map<date, List<Integer>> lineHotelMap{get;set;}
        public Id targetApplicationId{get;set;}
        public String cashAdvanceCurrency{get;set;}
        public Double cashAdvanceAmount{get;set;}
        public String HCMAmount{get;set;}
        public Double duration{get;set;}
        public Map<Id, Education_Application__c> possibleEducationMap{get;set;}
        public Id localCurrencyId{get;set;}
        List<selectOption> TravelApplications;
        
       
        /******Record Type variables******/
        public boolean rtEducation{get;set;}{rtEducation = false;}
        public boolean rtTravel{get;set;}{rtTravel= false;}
        public boolean rtGeneral{get;set;}{rtGeneral = false;}
        public string rtName{get;set;}
        private string expenseClaims;
        private Id detailRTId; // Record Type Id for Lines
        
        /******Page configuration variables******/
        public string linkedApplicationName{get;set;}
        public String applicantDisp{get;set;}
        public Integer currentLineNo = 1;
        public boolean isEditable{get;set;}{isEditable =false;}
        public boolean showMaxCupOption{get;set;}{showMaxCupOption=false;}
        public boolean showFinalAmount{get;set;}{showFinalAmount=false;}
        public boolean isMaxCupEditable{get;set;}{isMaxCupEditable=false;}
        public boolean isFinalAmountEditable{get;set;}{isFinalAmountEditable=false;}
        public boolean isApprover{get;set;}{isApprover=false;}
        public boolean isFIN{get;set;}{isFIN=false;}
        public boolean isApplicant{get;set;}{isApplicant=false;}
        public boolean isHCM{get;set;}{isHCM=false;}
        public boolean isAdmin{get;set;}{isAdmin=false;}
        public boolean showButton{get;set;}{showButton=false;}
        public boolean rtGeneralSubmitted{get;set;}{rtGeneralSubmitted=false;}
        public boolean applicationError{get;set;}{applicationError=false;}
        public boolean showSave{get;set;}{showSave=false;}
        public boolean showSubmit{get;set;}{showSubmit=false;}
        public boolean showApprove{get;set;}{showApprove=false;}
        public boolean showReject{get;set;}{showReject=false;}
        
        public String approveText{get; set;}{approveText ='Approve';}
        public String exceedCapStr{get; set;}
        public PageReference prc{get; set;} 
        public TEExpenseApplicationCtrl(){
            
            
            //init parameters
            deletedList = new List<Expense_Detail__c>();
            onBehalfOfMap = new Map<Id, Employee__c>();
            attach= new attachment();
            prc = null;
            textId = ApexPages.currentPage().getParameters().get('id');
                             
            if (textId  == null){
                ea = new Expense_Application__c();
                edl = new List<ExpenseDetailBizTO>();
                
                if (ApexPages.currentPage().getParameters().get('rt') == 'education'){
                    rtEducation = true;
                    rtName = 'Education Expenses';
                    expenseClaims = 'Education_Expenses';
                    linkedApplicationName = 'Education Application:';
                }
                else if (ApexPages.currentPage().getParameters().get('rt') == 'travel'){
                    rtTravel = true;
                    rtName = 'Travel Expenses';
                    expenseClaims = 'Travel_Expenses';
                    linkedApplicationName = 'Travel Application:';
                }
                else if (ApexPages.currentPage().getParameters().get('rt') == 'general'){
                    rtGeneral = true;
                    rtName = 'General Expenses';
                    expenseClaims = 'General_Expenses';
                }
                    
                if(getRecordType(TEConstant.EXPENSE_DETAIL_OBJECT_NAME,rtName) != null){
                    detailRTId = getRecordType(TEConstant.EXPENSE_DETAIL_OBJECT_NAME,rtName).getRecordTypeId();
                } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.TE_Record_Type_Not_Found));
                }
                
                for (integer i = 0; i < defaultNoOfRows; i++){
                    ExpenseDetailBizTO ed = new ExpenseDetailBizTO(this, currentLineNo++,detailRTId );
                    
                    if(rtGeneral){
                        ed.expenseDetail.status__c = TEConstant.STATUS_DRAFT; 
                    }
                    edl.add(ed);
                    
                }
               
                if (getRecordType(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME,rtName) != NULL){
                    ea.RecordTypeId = getRecordType(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME,rtName).getRecordTypeId();
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.TE_Record_Type_Not_Found));
                }

                ea.Apply_Date__c = Date.Today();
                createdBy = getEmployeeName(UserInfo.getUserId());
                if(!rtGeneral){
                    ea.Status__c = getDefaultStatus();
                }
                
                refNo = '';
                
            }else{
            
                ea =  expenseApplicationRecord(textId);
                this.attach.ParentId = textId;
                this.onBehalfOf = ea.On_Behalf_Of__r.Employee__r;
                applicantDisp = onBehalfOf.name;
                createdBy = ea.Applicant__c;
                refNo = ea.Name;
                
                if (ea.recordType.name == 'Education Expenses'){
                    rtEducation = true;
                    rtName = 'Education Expenses';
                    expenseClaims = 'Education_Expenses';
                    linkedApplicationName = 'Education Application:';
                    applicationLabel  = ea.Education_Application__r.Name + ' -- ' + ea.Education_Application__r.Program_Course_Title__c + ' ('
                                        + ea.Education_Application__r.Start_Date__c.format() + ' to ' + ea.Education_Application__r.End_Date__c.format() + ')';
                }
                else if (ea.recordType.name == 'Travel Expenses'){
                    rtTravel = true;
                    rtName = 'Travel Expenses';
                    expenseClaims = 'Travel_Expenses';
                    linkedApplicationName = 'Travel Application:';
                    applicationLabel  = ea.Travel_Application__r.Name;
                    applicationLabel += (String.isBlank(ea.Travel_Application__r.Purpose_of_Visit__c)?'':' -- ' + ea.Travel_Application__r.Purpose_of_Visit__c);
                    //applicationLabel += ' (' + ea.Travel_Application__r.Tech_Earliest_Departure_Date__c.format() + ')';
                    
                    applicationLabel += ((ea.Travel_Application__r.Tech_Earliest_Departure_Date__c==null)?'':(' (' +ea.Travel_Application__r.Tech_Earliest_Departure_Date__c.date().format())
                    //*
                     + ' to '+ ( (ea.Travel_Application__r.Tech_Latest_Return_Date__c == null)?((ea.Travel_Application__r.Tech_Latest_Departure_Date__c == null)?'':ea.Travel_Application__r.Tech_Latest_Departure_Date__c.date().format()+ ')' )
                                 :(ea.Travel_Application__r.Tech_Latest_Return_Date__c.date().format()) + ')')); 
                    //*/

                }
                else if (ea.recordType.name == 'General Expenses'){
                    rtGeneral = true;
                    rtName = 'General Expenses';
                    expenseClaims = 'General_Expenses';
                }
                
                initTLAMap();
                initRateMap();
                expenseTypeList = initExpenseType();
                initLineDetail();
                refreshTotalAmount();
                
                
                
                
            }
            
            TravelApplications = getTravelApplications();
           
            if(!rtGeneral){
                status = getStatus(ea.Status__c);
            }
            getAllAttachments();
           
            setApplicationDetail();
            
            initFlag();
            
            refreshExceedCapStr();  
            
        }

        //EXPENSE_DETAIL_OBJECT_NAME  TEConstant.EXPENSE_APPLICATION_OBJECT_NAME
        private Schema.RecordTypeInfo getRecordType(String tableName, String rt){
             try {
                Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{tableName});
                Schema.DescribeSObjectResult schemaResults = descResult[0];
                Map<String, Schema.RecordTypeInfo> mapRecordTypeInfos = schemaResults.getRecordTypeInfosByName();
                return mapRecordTypeInfos.get(rt);         
                }
             catch(Exception ex) { 
                 return null;
                //die silently 
             }
        }

        public void onApplicantChange(){
            
            Id oriId = onBehalfOf.Expense_Policy__c;
             
            if(onBehalfOfMap.containsKey(ea.On_Behalf_Of__c)){
                onBehalfOf = onBehalfOfMap.get(ea.On_Behalf_Of__c);
            }
            
            if(oriId != onBehalfOf.Expense_Policy__c){
                
                
                initTLAMap();
                initRateMap();
                refreshAllMaxCapInfo();
            }
            
            ea.Travel_Application__c= null;
            ea.Education_Application__c = null;
            
            setApplicationDetail(); 
            
        }
        
        public void refreshExceedCapStr(){
            exceedCapStr ='';
            for (ExpenseDetailBizTO line : edl){
                    exceedCapStr = exceedCapStr + line.isExceedCap;
            }
            //System.debug('test191: '+exceedCapStr );
        }

        public void initTLAMap(){

            tlaMap =  new Map<Id,Travel_Location_Allowance__c>();
            for(Travel_Location_Allowance__c tla : [select Travel_Location__c, Daily_Maximum_Hotel_Cost__c,Daily_Maximum_Meal__c, Maximum_of_Meal_Allowance_Currency__c,
                                                           Maximum_of_Hotel_Allowance_Currency__c,
                                                           Expense_Policy__r.Meal_Allowance_Currency__c,Expense_Policy__r.Hotel_Allowance_Currency__c
                                                    from Travel_Location_Allowance__c where Expense_Policy__c =: onBehalfOf.Expense_Policy__c]){
               if(tla.Travel_Location__c != null){
                    tlaMap.put(tla.Travel_Location__c, tla);
                }

            }
            
        }

        public void initRateMap(){
            rateMap = new Map<String, Exchange_Rate__c>();
            List<String> toRateIds = new List<String>();
            toRateIds.add(onBehalfOf.Expense_Policy__r.Hotel_Allowance_Currency__c);
            toRateIds.add(onBehalfOf.Expense_Policy__r.Meal_Allowance_Currency__c);

            for(Exchange_Rate__c rate : [select Tech_From_To_Currency_ID__c, Rate__c, From_Currency__c, To_Currency__c from Exchange_Rate__c where Is_Latest__c = true and Is_Book_Rate__c = true and To_Currency__c in:toRateIds]){
                rateMap.put(rate.Tech_From_To_Currency_ID__c, rate);
            }
        }

        public void refreshTotalAmount(){
            mealAmount = new Map<Date,double>();
            hotelAmount = new Map<Date,double>();
            lineMealMap = new Map<date, List<Integer>>();
            lineHotelMap = new Map<date, List<Integer>>();
            mealCapMap = new Map<Date,double>();
            hotelCapMap = new Map<Date,double>();
            
            resetExceedFlag();
            
            
            for(ExpenseDetailBizTO line : edl){
                
                if(line.expenseDetail.Receipt_Date__c != null && line.expenseDetail.Destination__c != null && line.expenseDetail.Receipt_Currency__c != null && line.expenseDetail.Amount__c != null && line.expenseDetail.Amount__c >0){
                    Date d = line.expenseDetail.Receipt_Date__c;
                    
                    Integer pn = 1;
                    if(line.expenseDetail.Number_Of_People__c != null){
                        pn = (Integer)line.expenseDetail.Number_Of_People__c;
                    }
                    if(line.expenseType.Is_Meal_Expense__c && line.mealCap != null){
                           
                            String key = String.valueOf(line.expenseDetail.Receipt_Currency__c).left(15)+String.valueOf(onBehalfOf.Expense_Policy__r.Meal_Allowance_Currency__c).left(15);
                            
                            if(lineMealMap.containsKey(d)){
                                lineMealMap.get(d).add(line.lineNo);
                            } else {
                                List<Integer> temp = new List<Integer>();
                                temp.add(line.lineNo);
                                lineMealMap.put(d,temp);
                            }
                    
                    
                    
                        if(rateMap.containsKey(key)){
                            double targetAmount = (line.expenseDetail.Amount__c * rateMap.get(key).rate__c)/pn;
                            
                            if(mealAmount.containsKey(line.expenseDetail.Receipt_Date__c)){
                                mealAmount.put(line.expenseDetail.Receipt_Date__c, mealAmount.get(line.expenseDetail.Receipt_Date__c)+targetAmount );
                            } else {
                                mealAmount.put(line.expenseDetail.Receipt_Date__c, targetAmount );
                            }
                            
                        } else {
                            line.showMessage = false;
                            line.maxCapInfo ='Can\'t find the Exchange Rate. Please contact IT for support';
                        }
                        
                        if(mealCapMap.containsKey(d)){
                            if(line.mealCap > mealCapMap.get(d)){
                                mealCapMap.put(d,line.mealCap);
                            }
                        } else {
                            mealCapMap.put(d,line.mealCap);
                        }
                        
                    }else if(line.expenseType.Is_Hotel_Expense__c && line.hotelCap != null ){
                        String key =  String.valueOf(line.expenseDetail.Receipt_Currency__c).left(15)+ String.valueOf(onBehalfOf.Expense_Policy__r.Hotel_Allowance_Currency__c).left(15);
                        
                        if(lineHotelMap.containsKey(d)){
                            lineHotelMap.get(d).add(line.lineNo);
                        } else {
                            List<Integer> temp = new List<Integer>();
                            temp.add(line.lineNo);
                            lineHotelMap.put(d,temp);
                        }
        
                        if(rateMap.containsKey(key)){
                           

                            //Change by DTT, handle pn=0 problem.
                            double targetAmount;
                            if(pn<=0)
                            {
                                targetAmount=0;
                            }
                            else{
                                targetAmount = line.expenseDetail.Amount__c * rateMap.get(key).rate__c/pn; 
                            }

                            if(hotelAmount.containsKey(line.expenseDetail.Receipt_Date__c)){
                                hotelAmount.put(line.expenseDetail.Receipt_Date__c, hotelAmount.get(line.expenseDetail.Receipt_Date__c)+targetAmount );
                            } else {
                                 hotelAmount.put(line.expenseDetail.Receipt_Date__c, targetAmount );
                            }
                        }
        
                        if(hotelCapMap.containsKey(d)){
                            if(line.hotelCap > hotelCapMap.get(d)){
                                hotelCapMap.put(d,line.hotelCap);
                            }
                        } else {
                            hotelCapMap.put(d,line.hotelCap);
                        }
                        continue;
                    } 
                } else if(line.expenseDetail.Receipt_Currency__c != null && (line.mealCap != null || line.hotelCap != null)){
                         
                          String key ='';
                          
                          if(line.expenseType.Is_Meal_Expense__c && line.mealCap != null){
                          
                              key = String.valueOf(line.expenseDetail.Receipt_Currency__c).left(15)+String.valueOf(onBehalfOf.Expense_Policy__r.Meal_Allowance_Currency__c).left(15);
                          
                          } else if (line.expenseType.Is_Hotel_Expense__c && line.hotelCap != null ) {
                              
                              key =  String.valueOf(line.expenseDetail.Receipt_Currency__c).left(15)+ String.valueOf(onBehalfOf.Expense_Policy__r.Hotel_Allowance_Currency__c).left(15);
                          }
                          
                          if(!rateMap.containsKey(key)){
                         
                              line.showMessage = false;
                              line.maxCapInfo ='Can\'t find the Exchange Rate. Please contact IT for support';
                          }
                    }
            }
            
            updateExceedCapFlag();
        }
        
        public void updateExceedCapFlag(){
            List<Integer> tempList = new List<Integer>();
            
            if(mealAmount.size() + hotelAmount.size() > 0){
                for(Date d : mealAmount.keySet()){
                    Double amount = mealAmount.get(d);
                    Double cap = mealCapMap.get(d);
                    if(amount > cap){
                        tempList.addAll(lineMealMap.get(d));
                    }
                }
                
                for(Date d : hotelAmount.keySet()){
                    Double amount = hotelAmount.get(d);
                    Double cap = hotelCapMap.get(d);
                    if(amount > cap){
                        tempList.addAll(lineHotelMap.get(d));
                    }
                }
        
                if(tempList.size()>0){
                    for(Integer lineNo :tempList){
                       edl.get(lineNo-1).isExceedCap = 'Y';
                       edl.get(lineNo-1).ExpenseDetail.Over_Max_Cap__c = true;
                    }
                }
            }
            
            refreshExceedCapStr();
        }
        
        public void resetExceedFlag(){
             for(ExpenseDetailBizTO line : edl){
               line.isExceedCap= 'N';
               line.ExpenseDetail.Over_Max_Cap__c = false;
             }
        }

        private Expense_Application__c expenseApplicationRecord(String id){
        
            List<expense_detail__c> tempList = [Select name, expense_application__c                                            
                                                from expense_detail__c where  id = :id];
            
            if( tempList.size() < 1){
                eaId = id;
            } else {
                eaId = tempList[0].expense_application__c;
            }
            return [select id, On_Behalf_Of__c, On_Behalf_Of__r.Employee__r.Expense_Policy__c, recordType.name, Status__c, Name,
                Applicant__c,On_Behalf_Of__r.Administrator__c, currency__c,
                On_Behalf_Of__r.Employee__r.name,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.local_currency__c, 
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.name,
                On_Behalf_Of__r.Employee__r.grade__c, 
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense__c,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense_currency__c,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Maximum_of_fitness_expense_currency__r.name,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Meal_Allowance_Currency__r.Name,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Hotel_Allowance_Currency__r.Name,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Allowance_Currency__r.Name,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Meal_Allowance_Currency__c,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Hotel_Allowance_Currency__c,
                On_Behalf_Of__r.Employee__r.Expense_Policy__r.Allowance_Currency__c, CreatedBy.id,
                travel_Application__c,
                travel_Application__r.Name,
                travel_Application__r.Purpose_of_Visit__c, 
                //travel_Application__r.Departure_Date__c,
                Actual_Approver_1__c,Actual_Approver_2__c,Actual_Approver_3__c,Actual_Approver_4__c,Current_Approver__c,
                Education_Application__r.is_child_education__c,
                Education_Application__r.is_staff_education__c, education_application__c, education_application__r.Name,
                Education_Application__r.Tuition_Fee_Recommended_Currency__c, Remarks__c, Apply_Date__c,
                Education_Application__r.Program_Course_Title__c, Education_Application__r.Start_Date__c, Education_Application__r.End_Date__c,
                travel_Application__r.Duration__c, Education_Application__r.Duration__c,
                Amount_Applied_display__c,Amount_Approved_Display__c, Amount_Applied_Hand_Written_Receipt_Disp__c, Reimbursement_Amount_Display__c,
                HCM_Pre_approved_Amount__c, Total_Cash_Advance__c,
                Travel_application__r.Tech_Earliest_Departure_Date__c, 
                Travel_application__r.Tech_Latest_Departure_Date__c, 
                Travel_application__r.Tech_Latest_Return_Date__c     
                from Expense_Application__c 
                where id = :eaId ];
        }
        private List<Expense_Detail__c> expenseDetailList(String id){
           return [select id, Name, Status__c, Receipt_Date__c, Amount__c,  Number__c,
            Receipt_Currency__c, Receipt_Currency__r.Name, Description__c, Destination__c, Destination__r.name,
            Expense_Type__c, Pay_Cheque__c, Number_Of_People__c, Hand_written_Receipt__c, Expense_Application__r.Travel_Application__c,
            Meal_Allowance_Currency__r.Name, Hotel_Allowance_Currency__r.Name, Allowance_Currency__r.Name,
            Over_Max_Cap__c, Amount_Adjustment__c, Expense_Type__r.Expense_Claims__c, Allow_to_Exceed_Max_Cap__c,
            Expense_Type__r.Require_Number_of_People_Data__c,
            Tech_Max_Cap__c, Tech_Meal_Max_Cap__c, Tech_Hotel_Max_Cap__c,  Expense_Type__r.Expense_Policy__r.Is_Daily_Allowance__c, Tech_Health_Exchange_Rate__c,
            Current_Approver__c
            from Expense_Detail__c 
            where Expense_Application__c = :id
            order by Number__c];
        }
           
        private string getEmployeeName(String id){
            string name = '';
            for (Employee__c emp : [ SELECT Full_Name__c, Expense_Policy__r.local_currency__c  FROM Employee__c WHERE User__r.id = :id LIMIT 1]){
                if (emp != null){
                    name = emp.Full_Name__c ;
                }
            }
            return name;     
        } 
        
        private string getDefaultStatus(){
            Schema.DescribeFieldResult F = Expense_Application__c.Status__c.getDescribe();
            List <Schema.PicklistEntry> pickVals = F.getPicklistValues();        
            for (Schema.PicklistEntry pv: pickVals) {
                if (pv.isDefaultValue()) {
                    return pv.getValue();
                }    
            }
            return TEConstant.STATUS_DRAFT;
        }

        //Translate the status name
        private string getStatus(String shortStatus)
        {            
           Schema.DescribeFieldResult fieldResult = Expense_Application__c.Status__c.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
           for( Schema.PicklistEntry f : ple)
           {
               if (f.getValue() == shortStatus){
                   return f.getLabel();
               }
           }       
           return '';
        }
        
        //builds a picklist of applicants (on_behalf_of__c)
        public List<selectOption> getApplicants() {
            
            List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
            String temp = String.valueOf(UserInfo.getUserId()).subString(0, 15);
            
            
            if(ea.On_Behalf_Of__r != null){
                temp = ea.On_Behalf_Of__r.Administrator__c;  
                
            }
            for (Employee_Administrator__c eas: [SELECT Id, Name, Employee_UserId__c, Administrator__c, Employee__c, Employee__r.name,
                                                        Employee__r.Expense_Policy__c,Employee__r.Expense_Policy__r.Hotel_Allowance_Currency__c 
                                                        , Employee__r.Expense_Policy__r.Meal_Allowance_Currency__c
                                                 FROM Employee_Administrator__c WHERE Administrator__c = :temp ORDER BY Name]) { //query for Employee Administrators
                options.add(new selectOption(eas.Id, eas.Name)); //for all records found - add them to the picklist options
                onBehalfOfMap.put(eas.Id, eas.Employee__r);
          if (ea.On_Behalf_Of__c==null && eas.Employee_UserId__c == String.valueOf(UserInfo.getUserId()).subString(0, 15)){
                    ea.On_Behalf_Of__c = eas.Id;
                    this.onBehalfOf = eas.Employee__r;
                    initTLAMap();
                    initRateMap();
                }
            }
            
            return options; //return the picklist options
        }
        
        //builds a picklist of Education Application
        public List<selectOption> getEducationApplications() {
            List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
            options.add(new selectOption('', Label.TE_Picklist_Default_Value)); 
           
            //query for available educations applications based on the applicant selected (on on_behalf_of__c) - add them to the picklist options
            possibleEducationMap = new Map<Id, Education_Application__c>();
            if (ea.On_Behalf_Of__c != NULL){
                for (Education_Application__c eas: [SELECT Id, Name, On_Behalf_Of__c, Status__c, Program_Course_Title__c, End_Date__c ,Start_Date__c, Approved_Tuition_Fee__c FROM Education_Application__c WHERE On_Behalf_Of__r.Employee__c = :this.onBehalfOf.id AND Status__c = : TEConstant.STATUS_APPROVED ORDER BY Name DESC]) {
                    possibleEducationMap.put(eas.Id, eas);
                    options.add(new selectOption(eas.Id, eas.Name + ' -- ' + eas.Program_Course_Title__c + ' (' + eas.Start_Date__c.format() + ' to ' + eas.End_Date__c.format()+ ')')); 
                }
                //if no available record found
                if (options.size() < 2){
                    options.clear();
                    options.add(new selectOption('', Label.TE_No_Available_Record)); 
                }      
            }
            return options; //return the picklist options
        }
        
        //builds a picklist of Travel Applications
        public List<selectOption> getTravelApplications() {
            Map<Id, boolean> availableApplications = new Map<Id, boolean>();
            List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
            options.add(new selectOption('', Label.TE_Picklist_Default_Value)); 
           
            //query for available educations applications based on the applicant selected (on on_behalf_of__c) - add them to the picklist options
            //Add by DTT: Submitted application can be resubmit regardless the return day
            List<Expense_Application__c> myEA=[select Id, Last_Approval_Action_Date__c,Travel_Application__c,Travel_Application__r.ID from Expense_Application__c where id=:ea.Id];
            String currentTAID='';
            if(myEA!=null &&myEA.isEmpty()==false && myEA.get(0).Last_Approval_Action_Date__c!=null &&myEA.get(0).Travel_Application__c!=null)
            {
                currentTAID=myEA.get(0).Travel_Application__r.ID;
            }   
            //Add by DTT
            integer test = 3;
            if (ea.On_Behalf_Of__c != NULL){
                
                for (Travel_Application__c eas: [SELECT Id, Name, On_Behalf_Of__c, Status__c, //Departure_Date__c, Return_Date__c,  
                                                 Trip_Remarks__c, Purpose_of_Visit__c, Tech_Is_Expense_Application__c,Tech_Earliest_Departure_Date__c, Tech_Latest_Return_Date__c,
                                                 Tech_Latest_Departure_Date__c, Allow_Claim_Expense__c, Return_Date__c 
                                                 FROM Travel_Application__c 
                                                 WHERE (On_Behalf_Of__r.Employee__c = :this.onBehalfOf.id AND Status__c = : TEConstant.STATUS_CONFIRMED
                                                 AND Tech_Is_Expense_Application__c = false
                                                 AND Allow_Claim_Expense__c = true)
                                                 OR id=:currentTAID//Add by DTT, get current TA id
                                                 ORDER BY Name DESC]) {
                    options.add(new selectOption(eas.Id, eas.Name + (String.isBlank(eas.Purpose_of_Visit__c)?'':' -- ' + eas.Purpose_of_Visit__c) 
                                + ((eas.Tech_Earliest_Departure_Date__c==null)?'':(' (' +eas.Tech_Earliest_Departure_Date__c.date().format()))
                                + ((eas.Tech_Earliest_Departure_Date__c==null && eas.Return_Date__c == null)?'':(' to '))
                                + ((eas.Return_Date__c == null)?'':eas.Return_Date__c.format()+ ')')
                                )); 
                    availableApplications.put(eas.Id, True);
                }
                
                //if no available record found
                if (options.size() < 2){
                    options.clear();
                    options.add(new selectOption('', Label.TE_No_Available_Record)); 
                }    
            }
            try{
            if (ea.Status__c == TEConstant.STATUS_DRAFT || ea.Status__c == TEConstant.STATUS_NOT_SUBMITTED ){
                if (ea.Travel_Application__c != NULL && !availableApplications.containsKey(ea.Travel_Application__c)){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.TE_Expense_Application_And_Travel_Application.replace(TRAVELAPPLICATIONNAME , ea.Travel_Application__r.Name)));
                }            
            }
            } catch (Exception e) {}
            return options;
        }
        
        //builds a picklist of expense types
        public List<selectOption> getExpenseTypes() {
            List<selectOption> options = new List<selectOption>();
            //options.add(new selectOption('', Label.TE_Picklist_Default_Value));
            expenseTypeMap = new Map<Id,Expense_Type__c>(); 
            Education_Application__c edu;
            if (rtEducation && ea.Education_Application__c != null){
                edu = [SELECT Id, RecordType.DeveloperName From Education_Application__c where Id =:ea.Education_Application__c limit 1];
            }
            if (ea.On_Behalf_Of__c != NULL){
                Employee_Administrator__c applicant = [SELECT Id, Employee__c, Employee__r.Expense_Policy__c, Employee__r.Grade__c FROM Employee_Administrator__c 
                                                            WHERE Id = :ea.On_Behalf_Of__c ];
                for (Expense_Type__c et: [SELECT Id, Expense_Claims__c, Expense_Policy__c, Expense_Properties__c, Expense_Type__c,Duration_Threshold__c,Reminder__c, 
                                                 Min_Applicable_Grade__c, Type__c,Require_Number_of_People_Data__c,Is_Meal_Expense__c,Is_Hotel_Expense__c, Is_Health_Expense__c, 
                                                 Expense_Category__r.Is_Staff_Expense__c, Expense_Category__r.Is_Child_Expense__c
                                            FROM Expense_Type__c
                                            WHERE Type__c = 'L' AND Expense_Claims__c = :expenseClaims AND Expense_Policy__c = :applicant.Employee__r.Expense_Policy__c 
                                            AND Min_Applicable_Grade__c <= :applicant.Employee__r.Grade__c
                                            ORDER BY Expense_Type__c]) { 
                    if (rtEducation && edu != null){
                        if ((edu.RecordType.DeveloperName == TEConstant.EDUCATION_APPLICATION_EDUCATION && et.Expense_Category__r.Is_Staff_Expense__c) ||
                            (edu.RecordType.DeveloperName == TEConstant.EDUCATION_APPLICATION_CHILD_EDUCATION && et.Expense_Category__r.Is_Child_Expense__c)){
                            options.add(new selectOption(et.Id, et.Expense_Type__c));
                        }
                    }
                    else{                        
                        options.add(new selectOption(et.Id, et.Expense_Type__c));
                    }
                    expenseTypeMap.put(et.Id,et);
                }
              /*  if (options.size() < 2){
                    options.clear();
                    options.add(new selectOption('', Label.TE_No_Available_Expense_Type)); 
                }*/   
            }
            return options;
        }
        
        private List<Expense_Type__c>  initExpenseType(){
            List<Expense_Type__c> tempList = new List<Expense_Type__c>();
            expenseTypeMap = new Map<Id,Expense_Type__c>();  
            if(ea.On_Behalf_Of__c != null){
                Employee_Administrator__c applicant = [SELECT Id, Employee__c, Employee__r.Expense_Policy__c, Employee__r.Grade__c FROM Employee_Administrator__c 
                                                            WHERE Id = :ea.On_Behalf_Of__c ];
                if(!String.isBlank(expenseClaims) && applicant.Employee__r.Grade__c!=null && applicant.Employee__r.Expense_Policy__c!=null )  {                                 
                    tempList = [SELECT Id, Expense_Claims__c, Expense_Policy__c, Expense_Properties__c, Expense_Type__c,
                                       Duration_Threshold__c,Reminder__c, Min_Applicable_Grade__c, Type__c,Require_Number_of_People_Data__c,
                                       Is_Meal_Expense__c,Is_Hotel_Expense__c, is_Health_Expense__c
                                       FROM Expense_Type__c
                                            WHERE Type__c = 'L' AND Expense_Claims__c = :expenseClaims AND Expense_Policy__c = :applicant.Employee__r.Expense_Policy__c 
                                            AND Min_Applicable_Grade__c <= :applicant.Employee__r.Grade__c
                                            ORDER BY Expense_Type__c];
                    for(Expense_Type__c et : tempList){
                        expenseTypeMap.put(et.Id,et);
                    }
                }
            } 
            
            return tempList;
                
        }
      
        //builds a picklist of currencies
        public List<selectOption> getCurrencies() {        
            Id localCurrencyId = null;
            Id budgetCurrencyId = null;
            List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
            for (Employee_Administrator__c reader : [select id, employee__r.expense_policy__r.local_currency__c from Employee_Administrator__c where id = :ea.On_Behalf_Of__c]){
               localCurrencyId =  reader.employee__r.expense_policy__r.local_currency__c;
            }
            options.add(new selectOption('', Label.TE_Picklist_Default_Value)); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
            for ( Currency__c cr : [select id
                                         from Currency__c
                                         where is_budget_currency__c = true]
            ){
                budgetCurrencyId = cr.id;
            }
            if (budgetCurrencyId != null){
                for (Currency__c currencies: [SELECT Id, Name, Description__c 
                                             FROM Currency__c
                                             where  id in (select From_Currency__c
                                                          from Exchange_Rate__c 
                                                          where Is_Latest__c = true and
                                                          Is_Book_Rate__c = true and To_Currency__c = :localCurrencyId
                                                          
                                                          )
                                                    and
                                                    id IN
                                                     (select From_Currency__c 
                                                          from Exchange_Rate__c 
                                                          where Is_Latest__c = true and
                                                          Is_budget_Rate__c = true and To_Currency__c   =: budgetCurrencyId 
                                                          
                                                          )
                                                    
                                                    
                                             ORDER BY Description__c
                                             ]) { //query for Currency
                    //options.add(new selectOption(currencies.Id, currencies.Description__c + ' (' + currencies.Name + ')')); //for all records found - add them to the picklist options
                    options.add(new selectOption(currencies.Id,   currencies.Name)); //for all records found - add them to the picklist options
                }
            }
            else{
                for (Currency__c currencies: [SELECT Id, Name, Description__c 
                                             FROM Currency__c
                                             where  id in (select From_Currency__c
                                                          from Exchange_Rate__c 
                                                          where Is_Latest__c = true and
                                                          Is_Book_Rate__c = true and To_Currency__c = :localCurrencyId
                                                          )                                   
                                             ORDER BY Description__c
                                             ]) { //query for Currency
                    //options.add(new selectOption(currencies.Id, currencies.Description__c + ' (' + currencies.Name + ')')); //for all records found - add them to the picklist options
                    options.add(new selectOption(currencies.Id,   currencies.Name)); //for all records found - add them to the picklist options
                }
            }
            return options; //return the picklist options
        }
        
        //builds a picklist of travel locations
        public List<selectOption> getLocations() {
            List<selectOption> options = new List<selectOption>();
            options.add(new selectOption('', Label.TE_Picklist_Default_Value));
            for (Travel_Location__c tl: [SELECT Id, Name FROM Travel_Location__c  ORDER BY Name]) {
                options.add(new selectOption(tl.Id, tl.Name));
            }
            return options; //return the picklist options
        }
        
        private void resetAllErrorFlag(){
            applicationError = false;
            
            for(ExpenseDetailBizTO line : edl){
                line.expenseTypeFlag = false;
                line.receiptDateFlag = false;
                line.destinationFlag = false;
                line.currencyFlag = false;
                line.amountFlag = false;
                line.finalAmountFlag = false;
            }
        
        }    
        
        private boolean validate(){
            resetAllErrorFlag();
           
            // check header 
            if( rtEducation && (ea.Education_Application__c == NULL)){
                applicationError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.TE_Required_Field_Alert_Message + ' [Education Application]'));
                return false;
            }
                
            if( rtTravel && (ea.Travel_Application__c == NULL)){
                applicationError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.TE_Required_Field_Alert_Message + ' [Travel Application]'));
                return false;
            }

            String warningMessage = ''; //required field warning
            String receiptDateMessage = '';
            String cutoffDateMessage = '';
            boolean result = true;
            Integer lineNo = 1;
            boolean lineResult= true;
            boolean noDetail = true;
            
            // check lines
            for(ExpenseDetailBizTO line : edl){
                if(!isEmptyLine(line)){
                    noDetail = false;
                    lineResult = true;
                    String lineMessage = '';

                    if(line.expenseDetail.Expense_Type__c == null){
                       lineMessage += ' Expense Type &';
                       lineResult = false;
                       line.expenseTypeFlag = true;
                    } 
                    if(line.expenseDetail.Receipt_Date__c == null){
                        lineMessage += ' Receipt Date &';
                        lineResult = false;
                        line.receiptDateFlag = true;
                    } 
                    if(line.expenseDetail.Receipt_Date__c < Date.newInstance(2016,06,1) && !line.expenseType.Is_Health_Expense__c){
                        if (cutoffDateMessage == ''){
                            cutoffDateMessage = 'Line No. ';
                        }
                        else{
                            cutoffDateMessage += ', ';
                        }
                        cutoffDateMessage += lineNo;
                        line.receiptDateFlag = true;
                        result = false;
                    } 
                    if(line.expenseDetail.Receipt_Date__c > Date.Today()){
                        if (receiptDateMessage == ''){
                            receiptDateMessage = 'Line No. ';
                        }
                        else{
                            receiptDateMessage += ', ';
                        }
                        receiptDateMessage += lineNo;
                        line.receiptDateFlag = true;
                        result = false;
                    }
                    if(rtTravel && line.expenseDetail.Destination__c == null){
                        lineMessage += ' Location &';
                        lineResult = false;
                        line.destinationFlag = true;
                    }
                    if(line.expenseDetail.Receipt_Currency__c == null){
                        lineMessage += ' Currency &';
                        lineResult = false;
                        line.currencyFlag = true;
                    }
                    
                    if(line.expenseDetail.amount__c== null || line.expenseDetail.amount__c == 0.00){
                        lineMessage += ' Amount &';
                        lineResult = false;
                        line.amountFlag = true;
                    }

                    if(!lineResult){
                        result = false;
                        lineMessage = '<br/> - No. '+lineNo+lineMessage;
                        lineMessage  = lineMessage.left(lineMessage.length()-1);
                        warningMessage += lineMessage;
                    }
                }
                lineNo++;
            }

            if(!result){
                if (warningMessage != ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.TE_Required_Field_Alert_Message + warningMessage));
                }
                if (receiptDateMessage != ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.TE_Expense_Application_Receipt_Date_Checker + ' ' + receiptDateMessage));
                }
                if (cutoffDateMessage != ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.TE_Expensen_Cuffoff_date + ' ' + cutoffDateMessage));
                }
            }
            
            if(noDetail){
                result = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.TE_Expense_Application_Should_Contain_Expense_Detail));
            }

            return result;

        }

        private boolean isEmptyLine(ExpenseDetailBizTO line){
            if((line.expenseDetail.Expense_Type__c == null) 
                && (line.expenseDetail.Receipt_Date__c == null) 
                && (line.expenseDetail.Destination__c == null) 
                && (line.expenseDetail.Receipt_Currency__c == null)
                && (line.expenseDetail.amount__c==NULL || line.expenseDetail.amount__c <= 0.00)){
                
                line.isEmptyLine = true;
                
                return true;
            } else {
                
                line.isEmptyLine = false;
                return false;
            }
                
        }
        
        public void updateDuration(){
            
            if(ea.Travel_Application__c != null){
               List<Travel_Application__c> tempList = [Select Tech_Earliest_Departure_Date__c, Tech_Latest_Return_Date__c, Tech_Latest_Departure_Date__c from Travel_Application__c where id =:ea.Travel_Application__c];
              
               if(tempList.size() > 0 && tempList[0].Tech_Earliest_Departure_Date__c != null && (tempList[0].Tech_Latest_Return_Date__c != null || tempList[0].Tech_Latest_Departure_Date__c != null) ){
                    Date day1 = tempList[0].Tech_Earliest_Departure_Date__c.date();
                    Date day2 = null;
                    if ( tempList[0].Tech_Latest_Return_Date__c != null){
                        day2 = tempList[0].Tech_Latest_Return_Date__c.date();
                    }
                    else{
                        day2 = tempList[0].Tech_Latest_Departure_Date__c.date();
                    }                
                    duration = day1.daysBetween(day2);
               }else {
            
                   duration = -1;
            
               }
            } else if(ea.Education_Application__c != null){
                 List<Education_Application__c > tempList = [select duration__c from Education_Application__c  where id =:ea.Education_Application__c];
                 if(tempList.size() > 0 && tempList[0].duration__c!=null){
                    
                    duration = tempList[0].duration__c;
                   }else {
                
                       duration = -1;
                
                   }
               
            } else {
            
                duration = -1;
            
            }
            
            
            for(ExpenseDetailBizTO line: edl){
                line.updateReminder();
            }
        
        }
        
        
        private boolean saveOnly(){
            if(validate()){          
                    
                try{
                    List<Expense_Detail__c> tempList = new List<Expense_Detail__c>();
                    integer num = 1;
                    
                    if (textId == null && ea.Education_Application__c != null && possibleEducationMap.get(ea.Education_Application__c) != null){
                        ea.HCM_Pre_approved_Amount__c = possibleEducationMap.get(ea.Education_Application__c).Approved_Tuition_Fee__c;
                    }
                    upsert ea;
                    
                    for (ExpenseDetailBizTO ed : edl){
                        if ((!ed.isEmptyLine) && (ed.expenseDetail.Expense_Type__c != null)){
                            if(ed.expenseDetail.Expense_Application__c == null){
                                ed.expenseDetail.Expense_Application__c = ea.Id;
                            }
                            ed.expenseDetail.On_Behalf_Of__c = ea.On_Behalf_Of__c;
                            /*
                            if (rtGeneral && this.isApplicant){
                                if (ed.expenseDetail.Status__c == TEConstant.STATUS_CANCELLED || ed.expenseDetail.Status__c == TEConstant.STATUS_REJECT){
                                    ed.expenseDetail.Status__c = TEConstant.STATUS_NOT_SUBMITTED;
                                }
                            }
                            */
                            if (ed.expenseDetail.Status__c == TEConstant.STATUS_CANCELLED || ed.expenseDetail.Status__c == TEConstant.STATUS_REJECT){
                                ed.expenseDetail.Status__c = TEConstant.STATUS_NOT_SUBMITTED;
                            }
                            tempList.add(ed.expenseDetail);
                        }
                    }
                    upsert tempList;
                    if(ea.Status__c == TEConstant.STATUS_CANCELLED){
                        ea.Status__c = TEConstant.STATUS_NOT_SUBMITTED;
                    }
                    for(Expense_Detail__c to : tempList){
                        to.Number__c = num++;
                    }                
                    upsert tempList;
                    
                    delete deletedList;
                    deletedList.clear();
                    return true;
                }
                catch(Exception ex){
                    ApexPages.addMessages(ex);
                    return false;
                }
            } else {
                return false;
            }    
        }
        
        public void uploadFile(){
            if( attach.Name != null && attach.Body != null && ea.id != null){
                attach.ParentId = ea.id;
                insert attach;
                attach = new attachment();
                getAllAttachments();
            }
        }
        
        public PageReference uploadFileAndSubmit(){
            if (prc != null){
                prc.setRedirect(true);            
                if( attach.Name != null && attach.Body != null && ea.id != null){
                    attach.ParentId = ea.id;
                    insert attach;
                }
            }
            return prc;
        }
        
        public PageReference go(){
            
            if ( prc != null){
                prc.setRedirect(true);
            }
            return prc;
        }
        
        
        public PageReference  saveAndGo(){
            saveAndRedirect();
            if(prc != null){
                prc.setRedirect(true);
            }
            return prc;
        }
     
        public void saveAndRedirect(){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'TEST' ));
            prc = null;
            if (saveOnly()) {
                /*
                PageReference newPage = new PageReference('/apex/'+Label.ExpenseApplicationVFP+'?id=' + ea.id);
                newPage.setRedirect(true);            
                return newPage; 
                */
                prc = new PageReference('/apex/'+Label.ExpenseApplicationVFP+'?id=' + ea.id);
            }
            //return null;
        }
        
        public PageReference  SubmitAndGo(){
            saveAndSubmit();
            if(prc != null){
                prc.setRedirect(true);   
            }
            return prc;
        }
        
        public void saveAndSubmit(){       
            String msg;
            prc = null;
            if (String.isBlank(ea.Status__c) || ea.Status__c == TEConstant.STATUS_DRAFT || ea.Status__c == TEConstant.STATUS_NOT_SUBMITTED || ea.Status__c == TEConstant.STATUS_CANCELLED ){
                if (saveOnly()) {
                    try{
                        List <Approval.ProcessSubmitRequest> listreq = new List <Approval.ProcessSubmitRequest>();
                        Approval.ProcessSubmitRequest req = null; 
                        if(rtGeneral){
                            for(ExpenseDetailBizTO ed: edl){
                                if(ed.expenseDetail.id != null && (ed.expenseDetail.status__c == TEConstant.STATUS_DRAFT || ed.expenseDetail.status__c ==TEConstant.STATUS_NOT_SUBMITTED)){
                                    req = new Approval.ProcessSubmitRequest();
                                    req.setObjectId(ed.expenseDetail.id);
                                    listreq.add(req);                                
                                }
                            }                    
                        } else {                        
                            if (ea.id != null){
                                req = new Approval.ProcessSubmitRequest();
                                req.setObjectId(ea.id);
                                listreq.add(req);
                            }
                           
                        }
                        
                        if (!listreq.isempty()){
                            Approval.process(listreq);
                        }
                        prc = new PageReference('/' + ea.Id);
                        return;
                    }
                    catch(Exception ex){
                        ApexPages.addMessages(ex);                     
                        prc = null;
                        return;
                    }           
                }
                else{
                    prc = null;
                    return;
                }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.TE_Expense_Application_Cannot_Submit));
                prc = null;
                return;
            }     
            //String returnURL = ea.Id + '?msg=' + msg.replace(' ', '+');
            //prc = new PageReference('/' + ea.Id);
            //prc.setRedirect(true);   
            if (textId == null){
               prc = null;
               return;
            }
            //return null;
        }
        
        private Id getWorkItemId(Id targetObjectId){
            Id retVal = null;
            for(ProcessInstanceWorkitem workItem  : [Select Id from ProcessInstanceWorkitem
                where ProcessInstance.TargetObjectId =: targetObjectId]){
                retVal  =  workItem.Id;
            }
            return retVal;
        }
       
        public PageReference approve(){
            return approve(true);
        }
        
        public PageReference reject(){
            return approve(false);
        }
        
        public PageReference approve(Boolean isApprove){
            String action = '';
            if(isApprove){
                action = 'Approve';
            }else{
                action = 'Reject';
            }
            
            if (saveOnly()) {
                try{
                
                    List <Approval.ProcessWorkitemRequest > listreq = new List <Approval.ProcessWorkitemRequest >();
                    Approval.ProcessWorkitemRequest req = null;
                        
                    if(ea.status__c == TEConstant.STATUS_CONFIRMED){
                        ea.status__c =   TEConstant.STATUS_CLOSED_NOT_SUBMITTED;
                        update ea;
                        
                        Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                        psr.setObjectId(ea.id);
                        Approval.process(psr);
                    } else {
                        if(rtGeneral){
                            for(ExpenseDetailBizTO ed: edl){
                                if(ed.expenseDetail.id != null && (
                                     (this.isApplicant && ed.expenseDetail.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION )
                                     ||(this.isFIN && ed.expenseDetail.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation)
                                     ||(checkDetailApprover(ed.expenseDetail) && ed.expenseDetail.status__c == TEConstant.STATUS_PENDING_APPROVAL)
                                     ||(this.isAdmin && ed.expenseDetail.status__c == TEConstant.STATUS_PENDING_SITE_APPROVAL)
                                     ||(this.isHCM && ed.expenseDetail.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL)
                                   )){
                                    req = new Approval.ProcessWorkitemRequest();
                                    req.setAction(action);
                                    req.setWorkitemId(getWorkItemId(ed.expenseDetail.id));
                                    listreq.add(req);                                
                                }
                            }
                        }
                        else{
                            Id theWorkId=getWorkItemId(ea.Id);
                            if(theWorkId!=null)
                            {
                              req = new Approval.ProcessWorkitemRequest();
                              req.setAction(action);
                              req.setWorkitemId(theWorkId);
                              listreq.add(req);
                            }
                           
                        }
                    }
                    
                    if (!listreq.isempty()){
                        Approval.process(listreq);
                    }
                    
                }
                catch(Exception ex){
                    ApexPages.addMessages(ex);
                    return null;
                }           
            }
            else{
                return null;
            }
            
               
            //String returnURL = ea.Id + '?msg=' + msg.replace(' ', '+');
            return new PageReference('/' + ea.Id);
        }
        
        
        public PageReference cancel(){
            if (textId  == null){
                String preFix = '';
                Schema.DescribeSObjectResult r = Expense_Application__c.sObjectType.getDescribe();
                preFix  = r.getKeyPrefix();
                return new PageReference('/' + prefix + '/o');
                
            }
            else{
                return new PageReference('/' + eaId);
            }
        }
        
        public PageReference insertRows() {        
            for (Integer i = 0 ; i < 5 ; i++){
                ExpenseDetailBizTO ed = new ExpenseDetailBizTO(this,detailRTId);
                if(rtGeneral){
                    ed.expenseDetail.status__c = TEConstant.STATUS_DRAFT;
                }
                edl.add(ed);
            }
            refreshLineNo(currentLineNo-1, true);
            refreshExceedCapStr();
            return null;
        }
        
        public void insertRow(Integer lineNo) {
           Integer size = edl.size();
           if(size == lineNo){
              ExpenseDetailBizTO ed = new ExpenseDetailBizTO(this,detailRTId);
              
              if(rtGeneral){
                  ed.expenseDetail.status__c = TEConstant.STATUS_DRAFT;
              }
              
              edl.add(ed);
           } else {
           
              ExpenseDetailBizTO ed = new ExpenseDetailBizTO(this,detailRTId);
              
              if(rtGeneral){
                  ed.expenseDetail.status__c = TEConstant.STATUS_DRAFT;
              }
              
              edl.add(lineNo,ed);
           }
           
           refreshLineNo(lineNo, true);
           refreshExceedCapStr();
        }
        
        public void removeRow(Integer lineNo) {
            Integer size = edl.size();
            Expense_Detail__c temp = edl.get(lineNo-1).expenseDetail;
            
            if(temp.id != null){
                deletedList.add(temp);
            }
            
            edl.remove(lineNo-1);
            
            if(size == 1){
               edl.add(new ExpenseDetailBizTO(this,detailRTId ));
            }
            
            refreshLineNo(lineNo, false);
            refreshTotalAmount();
            refreshExceedCapStr();
        }
        
        public void duplicateRow(Integer lineNo) {
            
            Integer size = edl.size();
            ExpenseDetailBizTO toCloneWrapper = edl.get(lineNo-1);
            Expense_Detail__c toCloneED = toCloneWrapper.expenseDetail;
            Expense_Detail__c clonedED;
            Expense_Detail__c toDeleteED;
            Integer removed = 0;
            
            if(lineNo < size){
                toDeleteED = edl.get(lineNo).expenseDetail;
            }
            
            //**** Delete the row below if not submitted
            if (toDeleteED != null){
                /**
                if(toDeleteED.id != null && (toDeleteED.Status__c == TEConstant.STATUS_DRAFT || toDeleteED.Status__c == TEConstant.STATUS_NOT_SUBMITTED)){
                    deletedList.add(toDeleteED);
                }
                
                if(toDeleteED.id == null || toDeleteED.Status__c == TEConstant.STATUS_DRAFT || toDeleteED.Status__c == TEConstant.STATUS_NOT_SUBMITTED){
                    edl.remove(lineNo);
                }
                **/
                if(toDeleteED.id == null && toDeleteED.Expense_Type__c == null){
                    edl.remove(lineNo);
                    removed ++;
                    refreshLineNo(lineNo+1, false);
                }
            }
            
            //**** Clone the current row and insert just below
            clonedED = toCloneED.clone(false, true, false, false);
            clonedED.Status__c = TEConstant.STATUS_DRAFT;
            //ExpenseDetailBizTO ed = new ExpenseDetailBizTO(this,cloned,lineNo+1);
            ExpenseDetailBizTO ed = toCloneWrapper.clone();
            ed.lineNo = lineNo + 1;
            ed.expenseDetail = clonedED;
            
            if(lineNo < size - removed){
                edl.add(lineNo,ed);
            }
            else{
                edl.add(ed);
            }
            refreshLineNo(lineNo, true);
            
            refreshTotalAmount();
            refreshExceedCapStr();
        }
        
        public void refreshLineNo(Integer line, boolean isAdd){
            
            if(isAdd){
                currentLineNo = line+1;
             } else {
                currentLineNo = line;
             }    

            for(ExpenseDetailBizTO to : edl){
                if(to.lineNo>line || to.lineNo == 0){
                    to.lineNo = currentLineNo++; 
                }
            }
           
        }
        
        public PageReference upload(){
            if(saveOnly()){
                return new PageReference('/p/attach/NoteAttach?pid='+eaId+'&parentname='+ea.name+'&retURL=%2Fapex/TEExpenseApplicationVFP?id='+eaId);
            } else {
                return null;
            }
        }
        
        public void setApplicationDetail(){
            if(ea.Travel_Application__c!=null){
                  targetApplicationId = ea.Travel_Application__c;
                  
                  For (Travel_Application__c ta : [Select Id, Tech_Cash_Advance_Sum__c, On_Behalf_of__r.Employee__r.Expense_Policy__r.Local_Currency__r.Name From Travel_Application__c Where Id =:ea.Travel_Application__c]){
                      cashAdvanceCurrency = ta.On_Behalf_of__r.Employee__r.Expense_Policy__r.Local_Currency__r.Name;
                      if (ta.Tech_Cash_Advance_Sum__c == null){
                          cashAdvanceAmount = 0;
                      }
                      else{
                          cashAdvanceAmount = -1 * ta.Tech_Cash_Advance_Sum__c;
                      }
                  }
                  
            } else if(ea.Education_Application__c!= null){
                 targetApplicationId =ea.Education_Application__c;
                 For (Education_Application__c edu : [Select Id, Approved_Tuition_Fee__c, Tuition_Fee_Recommended__c From Education_Application__c Where Id =:ea.Education_Application__c]){
                      if (edu.Tuition_Fee_Recommended__c == 0){
                          HCMAmount = '-';
                      }
                      else{
                          HCMAmount = edu.Approved_Tuition_Fee__c ;
                      }
                 }
            } else {
                targetApplicationId  = null;
                cashAdvanceAmount = null;
                cashAdvanceCurrency = null;
                HCMAmount = null;
            }
            
            updateDuration();
            
        }
       
        public void getAllAttachments(){    
            attachments = new List<attachmentTO>();
            contents = new List<attachmentTO>();
            countOfFiles = 0;
            if(eaId != null){
                
                List<Attachment> att = [select id,name,ParentId,BodyLength,lastModifiedDate from attachment where parentid =:eaId order by lastModifiedDate desc];
                //List<FeedItem> feedItemList = [SELECT Id, ParentId, Type,  Title, RelatedRecordId, InsertedById,  HasContent  FROM FeedItem where parentId = :eaid  order by parentId];           
                List<Expense_Application__Feed> expenseApplicationFeedList = new List<Expense_Application__Feed>();
                
                for(Expense_Application__Feed reader : [ SELECT Id, RelatedRecordId, ContentFileName, ContentType, LastModifiedDate, ContentSize
                                                            FROM Expense_Application__Feed 
                                                            where ParentId = :eaId
                                                            and type = 'ContentPost'
                                                            order by LastModifiedDate
                                                        ]){
                                                        if(!String.isBlank(reader.RelatedRecordId) && !String.isBlank(reader.ContentFileName) && !String.isBlank(reader.ContentType) && reader.ContentType.contains('image')){
                                                            expenseApplicationFeedList.add(reader);
                                                        }
                }
                
                if(att != null && att.size()>0 ){   
                    for(Attachment f : att){
                        attachmentTO a = new attachmentTO(f,this);
                        attachments.add(a);
                    }
                    countOfFiles = att.size();
                }
                if(!expenseApplicationFeedList.isEmpty()){
                    
                    for(Expense_Application__Feed  f : expenseApplicationFeedList){
                        attachmentTO a = new attachmentTO(f, this);
                        attachments.add(a);
                    }
                    
                    countOfFiles += expenseApplicationFeedList.size();
                }
            }
        }
        
        
        public void initFlag(){
            String s = ea.status__c;
            
            /**
            if(rtTravel){
                this.isApprover = checkApprover();
            }else if(rtEducation){
                this.isHCM = checkHCM();
            }**/
            this.isApprover = checkApprover();
            this.isHCM = checkHCM();
            this.isFIN = checkFIN();
            this.isApplicant = checkIsApplicant();
            this.isAdmin = checkAdmin();
            
            if(rtGeneral){
            
                for(ExpenseDetailBizTO line : edl){
                    if(!String.isBlank(line.expenseDetail.status__c) && line.expenseDetail.status__c != TEConstant.STATUS_DRAFT && line.expenseDetail.status__c != TEConstant.STATUS_NOT_SUBMITTED && line.expenseDetail.status__c != TEConstant.STATUS_CANCELLED && line.expenseDetail.status__c != TEConstant.STATUS_REJECT){
                        rtGeneralSubmitted = true;
                        //break;
                    }
                    else if (this.isApplicant){
                        line.isGeneralEditable = true;
                    }
                }
            
            }
            
            if( String.isBlank(s) || s == TEConstant.STATUS_DRAFT || s== TEConstant.STATUS_NOT_SUBMITTED || s == TEConstant.STATUS_CANCELLED || s == TEConstant.STATUS_REJECT){
                isEditable = true;
            } else {
                isEditable = false;    
            }
            
            if(rtGeneralSubmitted || !this.isApplicant){
                isEditable = false;
            }
            
            if(rtTravel){
                if( s == TEConstant.STATUS_DRAFT || s== TEConstant.STATUS_NOT_SUBMITTED || s == TEConstant.STATUS_CANCELLED || s == TEConstant.STATUS_REJECT){
                    showMaxCupOption = false;
                } else {
                    showMaxCupOption = true;    
                }
            } else {
                 showMaxCupOption = false;
            }
            
            
            if( String.isBlank(s) || s == TEConstant.STATUS_DRAFT || s== TEConstant.STATUS_NOT_SUBMITTED || s == TEConstant.STATUS_CANCELLED || s == TEConstant.STATUS_REJECT || s == TEConstant.STATUS_PENDING_APPROVAL || s == TEConstant.STATUS_PENDING_HCM_APPROVAL){
                showFinalAmount = false;
            } else {
                showFinalAmount = true;    
            }
            
            if(rtGeneralSubmitted){
                showFinalAmount = true;
            }
            
            if(rtTravel &&  s == TEConstant.STATUS_PENDING_APPROVAL){
                isMaxCupEditable= true;
            } else {
                isMaxCupEditable= false;    
            }
            
            for(ExpenseDetailBizTO  line : edl){
                if(line.isfinAction && this.isFIN){
                    isFinalAmountEditable = true;
                    break;
                }                
            }
            
            /**
            if(rtTravel){
                this.isApprover = checkApprover();
            }else if(rtEducation){
                this.isHCM = checkHCM();
            }
            this.isFIN = checkFIN();
            this.isApplicant = checkIsApplicant();
            
            System.debug('isEditable: '+isEditable);
            System.debug('isApplicant: '+isApplicant );
            **/
            if((this.isApprover && s == TEConstant.STATUS_PENDING_APPROVAL)||
               (this.isFIN && s== TEConstant.STATUS_PENDING_FIN_Confirmation)||
               (this.isApplicant && this.isEditable)
               ){
                this.showSave = true;
            }
            
            if((this.isApprover && s == TEConstant.STATUS_PENDING_APPROVAL)||
               (this.isFIN && s== TEConstant.STATUS_PENDING_FIN_Confirmation)||
               (this.isApplicant && this.isEditable)||
               (this.isApplicant && s == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION)||
               (this.isHCM && s == TEConstant.STATUS_PENDING_HCM_APPROVAL)||
               (this.isFIN && s== TEConstant.STATUS_CONFIRMED)){
                this.showButton = true;
            }
            
            if((this.isApprover && s == TEConstant.STATUS_PENDING_APPROVAL)||
               (this.isFIN && s== TEConstant.STATUS_PENDING_FIN_Confirmation)||
               (this.isApplicant && s == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION)||
               (this.isHCM && s == TEConstant.STATUS_PENDING_HCM_APPROVAL)||
               (this.isFIN && s== TEConstant.STATUS_CONFIRMED)){
                this.showApprove = true;
                if (s != TEConstant.STATUS_CONFIRMED){
                    this.showReject = true;
                }
            }
            
            if(this.isApplicant && this.isEditable){
                this.showSubmit = true;
            }
                    
            if (rtGeneral){
                for(ExpenseDetailBizTO line : edl){
                    if((this.isApplicant && !String.isBlank(line.expenseDetail.status__c) && (line.expenseDetail.status__c == TEConstant.STATUS_DRAFT || line.expenseDetail.status__c == TEConstant.STATUS_NOT_SUBMITTED || line.expenseDetail.status__c == TEConstant.STATUS_CANCELLED || line.expenseDetail.status__c == TEConstant.STATUS_REJECT))
                     ||(this.isApplicant && !String.isBlank(line.expenseDetail.status__c) && line.expenseDetail.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION )
                     ||(this.isFIN && !String.isBlank(line.expenseDetail.status__c) && line.expenseDetail.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation)
                     ||(checkDetailApprover(line.expenseDetail) && !String.isBlank(line.expenseDetail.status__c) && line.expenseDetail.status__c == TEConstant.STATUS_PENDING_APPROVAL)
                     ||(this.isAdmin && !String.isBlank(line.expenseDetail.status__c) && line.expenseDetail.status__c == TEConstant.STATUS_PENDING_SITE_APPROVAL)
                     ||(this.isHCM && !String.isBlank(line.expenseDetail.status__c) && line.expenseDetail.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL)){
                        if ((this.isApplicant && line.expenseDetail.status__c != TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION) || this.isFIN){
                            this.showSave = true;
                        }
                        if (this.isApplicant && line.expenseDetail.status__c != TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION){
                            this.showSubmit = true;
                        }
                        else{
                            if (this.isApplicant){
                                approveText = 'Confirm'; 
                            }
                            this.showApprove = true;
                        }
                    }
                }
                if(this.showApprove){
                    for(ExpenseDetailBizTO line : edl){
                        if(line.expenseDetail.status__c != TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION){
                            this.showReject= true;
                        }
                        if(line.expenseDetail.status__c == TEConstant.STATUS_NOT_SUBMITTED || line.expenseDetail.status__c == TEConstant.STATUS_DRAFT || line.expenseDetail.status__c == TEConstant.STATUS_REJECT){
                            this.showApprove = false;
                        }
                    }
                }
            }
            
            if(s == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION){
                approveText = 'Confirm'; 
            }else if(s== TEConstant.STATUS_CONFIRMED ){
                approveText = 'Close Application';
            }
            
        }
        
         private boolean checkHCM(){
            //Get the ID of the custom permission
            List<Id> customPermissionIds = new List<Id>();
            for (CustomPermission cp : [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'TE_Is_HCM']){
                customPermissionIds.add(cp.Id);
            }                                                                          
            //Query whether the custom permissions have been assigned to the logged in user
            List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess 
                                                                        WHERE SetupEntityId in :customPermissionIds AND
                                                                             ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment
                                                                                           WHERE AssigneeId = :UserInfo.getUserId())];
            if (setupEntities.isEmpty()){
                return false;
            }
            else{
                return true;
            }  
        }
        
        private boolean checkApprover(){
            String userId = UserInfo.getUserId();
         if(!String.isBlank(userId)){
            userId = userId.left(15);    
            }
            /**
            if(ea.Actual_Approver_1__c == userId || ea.Actual_Approver_2__c == userId 
                || ea.Actual_Approver_3__c == userId|| ea.Actual_Approver_4__c == userId){
                    return true;
            }
            **/
            if (!String.isBlank(userId) && !String.isBlank(ea.Current_Approver__c) && ea.Current_Approver__c.contains(userId)){
             return true;
            }
            return false;
        }
        
        private boolean checkDetailApprover(Expense_Detail__c ed){
            Id userId = UserInfo.getUserId();
            if (ed.Current_Approver__c == userId){
                return true;
            }
            return false;
        }
        
         private boolean checkFIN(){
            //Get the ID of the custom permission
            List<Id> customPermissionIds = new List<Id>();
            for (CustomPermission cp : [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'TE_Is_Finance']){
                customPermissionIds.add(cp.Id);
            }                                                                          
            //Query whether the custom permissions have been assigned to the logged in user
            List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess 
                                                                        WHERE SetupEntityId in :customPermissionIds AND
                                                                             ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment
                                                                                           WHERE AssigneeId = :UserInfo.getUserId())];
            if (setupEntities.isEmpty()){
                return false;
            }
            else{
                return true;
            }  
        }
        
        private boolean checkAdmin(){
            //Get the ID of the custom permission
            List<Id> customPermissionIds = new List<Id>();
            for (CustomPermission cp : [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'TE_Is_Admin']){
                customPermissionIds.add(cp.Id);
            }                                                                          
            //Query whether the custom permissions have been assigned to the logged in user
            List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess 
                                                                        WHERE SetupEntityId in :customPermissionIds AND
                                                                             ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment
                                                                                           WHERE AssigneeId = :UserInfo.getUserId())];
            if (setupEntities.isEmpty()){
                return false;
            }
            else{
                return true;
            }  
        }
        
        private boolean checkIsApplicant(){
            Id userId = UserInfo.getUserId();
            if(textId  == null || ea.On_Behalf_Of__c == userId || ea.CreatedBy.id == userId){
                    return true;
            }
            return false;
        
        }
        
        private void initLineDetail(){
            edl = new List<ExpenseDetailBizTO>();
            
            if(getRecordType(TEConstant.EXPENSE_DETAIL_OBJECT_NAME,rtName) != null){
                detailRTId = getRecordType(TEConstant.EXPENSE_DETAIL_OBJECT_NAME,rtName).getRecordTypeId();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.TE_Record_Type_Not_Found));
            }
                
            List<Expense_Detail__c> tempList = expenseDetailList(eaId);
            if(tempList != null){
                for(Expense_Detail__c line : tempList){
                    ExpenseDetailBizTO to = new ExpenseDetailBizTO(this, line, currentLineNo++);
                    to.isSaved = true;
                    
                    
                        if(to.expenseDetail.Expense_Type__c != null){
                            if(expenseTypeMap!=null && expenseTypeMap.size()>0 ){
                                to.expenseType = expenseTypeMap.get(to.expenseDetail.Expense_Type__c);
                                 if(to.expenseType.Require_Number_of_People_Data__c){
                                    to.enablePeople = true;
                                }else {
                                    to.enablePeople = false;
                                    to.expenseDetail.Number_Of_People__c = 1;
                                    //to.expenseDetail.Number_Of_People__c = null;
                                }
                            }
                            
                           
                        } else {
                            to.enablePeople = false;
                            to.expenseDetail.Number_Of_People__c = 1;
                            //to.expenseDetail.Number_Of_People__c = null;
                        }
                    
                    to.initMaxCapInfo();

                    edl.add(to);
                }
            }
            
            if(edl.size()<1){
                
                
                for (integer i = 0; i < defaultNoOfRows; i++){
                    ExpenseDetailBizTO ed = new ExpenseDetailBizTO(this, currentLineNo++,detailRTId );
                    
                    if(rtGeneral){
                        ed.expenseDetail.status__c = TEConstant.STATUS_DRAFT;
                    }
                    edl.add(ed);
                }
            }
            
        }
        
        public void refreshAllMaxCapInfo(){
            if(edl!=null && edl.size() > 0){
                for(ExpenseDetailBizTO line : edl){
                    
                    
                    line.expenseDetail.Expense_Type__c = null;
                    line.expenseType = null;
                    line.enablePeople = false;
                    line.expenseDetail.Number_Of_People__c = 1;
                    //line.expenseDetail.Number_Of_People__c = null;
                    
                    
                    line.refreshLineCapInfo();
                }
                
                refreshTotalAmount();
            }
        }
        
        public void populateEducationExpense(){
            
            if(edl!=null && edl.size() > 0){
               
               Education_Application__c edu = [SELECT Id, RecordType.Name, On_Behalf_Of__r.Employee__r.Expense_Policy__c,
                                                       Tuition_Fee_Recommended__c, Tuition_Fee_Recommended_Currency__c, Start_Date__c
                                               From Education_Application__c where Id =:ea.Education_Application__c limit 1];
               /**
               Map<String, Id> expenseTypeMap = new Map<String, Id>();
               For (Expense_Type__c et : [Select Id, Expense_Type__c from Expense_Type__c Where Expense_Policy__c = :edu.On_Behalf_Of__r.Employee__r.Expense_Policy__c]){
                   expenseTypeMap.put(et.Expense_Type__c, et.Id);
               }
               */
               if(edu !=null){
                   /**
                   if (edu.RecordType.Name == 'Staff Education'){
                       edl[0].expenseDetail.Expense_Type__c = expenseTypeMap.get('Staff Tuition Fee');
                   }
                   else if (edu.RecordType.Name == 'Child Education'){
                       edl[0].expenseDetail.Expense_Type__c = expenseTypeMap.get('Child Tuition Fee');
                   }
                   */
                   edl[0].expenseDetail.Receipt_Date__c = edu.Start_Date__c;
                   edl[0].expenseDetail.Receipt_Currency__c = edu.Tuition_Fee_Recommended_Currency__c;
                   edl[0].expenseDetail.Amount__c = edu.Tuition_Fee_Recommended__c;
               }
            }
            
            setApplicationDetail();
        }
        
        public void populateLocation(){
            
            if(edl!=null && edl.size() > 0){
                
               List<Travel_Detail__c> tdcList = [SELECT  Destination__c, Destination__r.name,Preferred_Departure_dt__c, Destination__r.currency__c from Travel_Detail__c where Travel_Application__c =:ea.Travel_Application__c order by Preferred_Departure_dt__c asc limit 1];
              
               if(tdcList !=null && tdcList.size()>0){
                   Travel_Detail__c tdc = tdcList[0];
                   DateTime dT = tdc.Preferred_Departure_dt__c;
                   edl[0].expenseDetail.Destination__c = tdc.Destination__c;
                   edl[0].expenseDetail.Receipt_Currency__c = tdc.Destination__r.currency__c;
                   edl[0].expenseDetail.Receipt_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                   
                   if(edl[0].expenseDetail.Receipt_Currency__c == null){
                       edl[0].setCurrencyByLoc();
                   }
               }
            }
            
            setApplicationDetail();
            
        
        }
       public String body{set;get;}
       public String name{set;get;}
       public String contentType{set;get;}
       
       
    /* 
       Public pagereference uploadFileAction() {
           
           Attachment attach = new Attachment();
           attach.Name = name;
           attach.ContentType = contentType;
           attach.ParentId ='a1IO0000007w48P';
           body = body.replace('https://talgroup--test--c.cs5.visual.force.com/','');
           attach.Body = EncodingUtil.Base64Decode(body);
           
           //attach.Body = EncodingUtil.convertFromHex(body);
           //upsert new expense_application__c( id = 'a1IO0000007w48PMAQ', test__c = body );
     
           
           upsert attach;  
           body = null;
           
           contentType = '';
           name = '';
           return null;
       }
    */ 
       
       @RemoteAction
       Public static  String  uploadFileAction(String name , String contentType, String body, string attachid, String pid) {
           Attachment attach = new Attachment();
           if ( attachid != ''){
               for(Attachment atm : [select Id, Body from Attachment where Id = :attachid]){
                    //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                    update new Attachment(Id = attachid, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + body));
                }
               return attachid;
           }
           attach.Name = name;
           attach.ContentType = contentType;
           attach.ParentId =pid;
           attach.Body = EncodingUtil.Base64Decode(body);
           upsert attach;  
           body = null;
           
           contentType = '';
           name = '';
           return attach.id;
       }
        
        
       @RemoteAction
       Public static Expense_Detail__c  findLoaction(String tid , DateTime expDate) {
           Expense_Detail__c ed = new Expense_Detail__c ();
           Date dt = null;
           Integer duration = 0;
           Integer minDuration = null;
           DateTime ReturnDT, DepartureDT;
           if( expDate != null){
               dt = expDate.date();
           }
           for (Travel_Detail__c td : [select id, Preferred_Return_dt__c, Preferred_Departure_dt__c,
                                       Preferred_Return_Date__c, Preferred_Departure_Date__c,
                                       Destination__r.name, Destination__c, Destination__r.currency__c
                                       from Travel_Detail__c 
                                       where Travel_Application__c = :tid 
                                       and Preferred_Departure_Date__c <= :dt 
                                       and (Preferred_Return_Date__c >= :dt or Preferred_Return_Date__c = null)                                      
                                       order by name
                                      ]){
               DepartureDT = td.Preferred_Departure_Date__c;
               ReturnDT = td.Preferred_Return_Date__c;
               if (ReturnDT == null){
                   ReturnDT = DepartureDT;
               }
               duration = Math.abs(DepartureDT.Date().daysBetween(ReturnDT.Date()));
               if (minDuration == null){
                   minDuration = duration;
               }
               if (minDuration >= duration){
                   minDuration = duration;
                   ed.Destination__c = td.Destination__c;
                   ed.Receipt_Currency__c = td.Destination__r.currency__c;    
               }
           }
           
           return ed;
       }
           
    }