/*
  
  This is main travel application class
  
  Created By:   Kong
  Date Created: 2nd March 2016
  
  * Version   Author           |  Date           |    Description
  
  * ----------------------------------------------------------------------
  
  * V1.0   |  kong             |  2016-03-02     |    New created
  ------------------------------------------------------------------------
  
  * V1.1   |  kong             |  2016-07-30     |    To reduce the class size.
                                                      Create TETravelApplicationAddRows, TETravelApplicationActions to support all actions
  ------------------------------------------------------------------------
  * V1.2   |  kong             |  2016-08-15     |    Renew Accommodation arragnment flow. Application can select site admin in 'arranged by' field
  ------------------------------------------------------------------------
*/
 
 

public without sharing class TETravelApplicationCtrl{
    Public Static String travelApplicationURLParameter= 'taid';
    Public Static String TRAVEL_DETAIL_API_NAME = Travel_Detail__c.sObjectType.getDescribe().getName();
    Public Static String TRAVEL_OPTION_API_NAME = TravelOption__c.sObjectType.getDescribe().getName();
    Public Static String DEFAULT_TAB = '1';
    Public Static String DT_FORMAT = 'dd/MM/yyyy HH:mm';
    Public Static String Date_FORMAT = 'dd/MM/yyyy';
    Public Static String DT_FORMAT_0000 = '00:00';  
    Public Static String TRAVEL_AGENT_GP = 'TE-@name-AGENT';
    Public Static String DEF_TRAVEL_AGENT_GP = 'TE-HKO-AGENT';
    Public Static String AIR_OPTION_TYPE = 'Air';
    Public Static String HOTEL_OPTION_TYPE = 'Hotel';    
    Public Static String AIR_TRAVEL_DETAIL_TYPE = 'Air';
    Public Static String SHUTTLE_TRAVEL_DETAIL_TYPE = 'Shuttle';
    Public Static String BUDGET_ERROR_MESSAGE = 'Cannot find budget';
    Public Static String ITINERARY_TYPE_DEPARTURE = 'D';
    Public Static String ITINERARY_TYPE_RETURN = 'R';
    Public Static String OPEN_PARENTHESIS= ' (';
    Public Static String CLOSE_PARENTHESIS= ')';
    Public Static String WHITESPACE= ' ';
    Public Static String UNDERSCORE= '_';
    Public String sDT_FORMAT{get;set;}
    Public String sDate_FORMAT{get;set;}
    Public String orgDT_FORMAT{get;set;}
    Public String orgDate_FORMAT{get;set;}
    Public String RANDOM_STRING = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    Public String selectedTab{get;set;}
    Public Integer RANDOM_STRING_LEN = 15;
    Public Integer NUM_OF_ROW_DEF = 4;
    Public Boolean isTravelAgent{get;set;}
    Public Boolean isAdmin{get;set;}
    Public Boolean isMySelf{get;set;}    
    Public Boolean selectedOption1{get;set;}
    Public Boolean selectedOption2{get;set;}
    Public Boolean selectedOption3{get;set;}
    Public Boolean checkPassportType{get;set;}
    Public Boolean checkOptionEstimatedPrice1{get;set;}
    Public Boolean checkOptionEstimatedPrice2{get;set;}
    Public Boolean checkOptionEstimatedPrice3{get;set;}
    Public Boolean checkOptionEstimatedCurrency{get;set;}
    Public Boolean checkOptionEstimatedCurrency2{get;set;}
    Public Boolean checkOptionEstimatedCurrency3{get;set;}
    Public Boolean checkSelectedOption1{get;set;}
    Public Boolean checkSelectedOption2{get;set;}
    Public Boolean checkSelectedOption3{get;set;}
    Public Boolean checkDeadline{get;set;}
    Public Boolean isEmptyAccommodation{set;}
    Public Travel_Application__c travelApplication{get;set;}
    Public Employee__c currentEmp{set;get;}
    Public List <SelectOption> applicantSelectionList{get;set;}
    Public List <SelectOption> siteSelectionList{get;set;}    
    Public List <SelectOption> currencySelectionList{get;set;}
    Public Map <String, SelectOption> shortCurrencySelectionMap{get;set;}
    Public List <SelectOption> journeyTypeSelectionList{get;set;}
    Public List <SelectOption> accommodationBySelectionList{get;set;}
    Public List <SelectOption> airfareTypeSelectionList{get;set;}    
    Public List <SelectOption> cabinClassSelectionList{get;set;}
    Public List <SelectOption> passportSelectionList{get;set;}
    Public List <SelectOption> userSelectionList{get;set;}
    Public List <SelectOption> userSelectionList1{get;set;}
    Public List <SelectOption> userSelectionList2{get;set;}
    Public List <SelectOption> userSelectionList3{get;set;}
    Public List <SelectOption> userSelectionList4{get;set;}
    Public List <SelectOption> userSelectionList5{get;set;}
    Public List <SelectOption> userSelectionList6{get;set;}
    Public List <SelectOption> userSelectionList7{get;set;}
    Public List <SelectOption> userSelectionList8{get;set;}
    Public List <SelectOption> userSelectionList9{get;set;}
    Public List <SelectOption> routeSiteList{get;set;}
    Public List <SelectOption> travelAgentList{get;set;}
    Public Map <String, List <SelectOption>> passportSelectionMap{get;set;}
    Public List <airport__c> airportList{get;set;}    
    Public Map <String, String> airportMap{get;set;}
    Public Map <String, String> siteSelectionMap{get;set;}
    Public Map <String, String> expensePolicyAllowanceMap{get;set;}
    Public Map <String, String> optRecordTypeMap{get;set;}
    Public Map <String, String> tdRecordTypeMap{get;set;}
    Public Map <Id, Site__c> siteMap;
    Public List <TETravelDetail> travelDetailList{get;set;}
    Public List <TEAccommodationCtrl> travelAccommodationList{get;set;}
    Public List <TETravelOption> airTravelOptionList{get;set;}
    Public List <TETravelOption> hotelTravelOptionList{get;set;}
    Public List <TETravelPriceCtrl> travelPriceList{get;set;}    
    Public List <TETravelItineraryCtrl> travelItineraryList{get;set;}
    Public List <TECashAdvanceCtrl> cashAdvanceList{get;set;}
    Public List <RecordType> recordTypeList{get;set;}
    Public List <String> publicGrouopList{get;set;}
    Public Map <id, user> travelAgentMap{get;set;}
    Public Map <id, String> applicantTravelPolicyMap{get;set;}
    Public Map <id, Travel_Location__c> travelLocationMap{get;set;}
    Public Map<Id, Travel_Location__c>loactionSitMap{get;set;}
    Public String taId{get;set;}
    Public String deadline{get;set;}
    Public String emailList{get;set;}
    Public String currURL{get;set;} 
    Public TETravelApplicationAddRows taAddRows{get;set;}
    Public TETravelApplicationActions taActions{get;set;}
    Public TETravelApplicationInit taInit{get;set;}
    
    Public TETravelApplicationCtrl(){        
        taInit = new TETravelApplicationInit(this);
        initial();
        taAddRows = new TETravelApplicationAddRows(this);
        taActions = new TETravelApplicationActions(this);
    }
    
   /*
     To initialize all parameters and classes
   */
    Public void initial(){
        currURL = System.URL.getCurrentRequestUrl().toExternalForm();
        Schema.DescribeFieldResult defStatus;
        List <Schema.PicklistEntry> pickVals;
        List <String> sobjectTypeList = new List <String>();
        List <selectoption> tmppassportSelectionList = new List <selectoption>();
        String str = '';
        Integer counter = 0;
        this.recordTypeList = new List <RecordType>();
        this.taId =  ApexPages.currentPage().getParameters().get(travelApplicationURLParameter);
        travelDetailList = new List<TETravelDetail>();
        travelAccommodationList = new List<TEAccommodationCtrl>();
        airTravelOptionList = new List <TETravelOption>();
        hotelTravelOptionList = new List <TETravelOption>();
        travelItineraryList = new List <TETravelItineraryCtrl>();
        travelPriceList= new List <TETravelPriceCtrl>();
        cashAdvanceList = new List <TECashAdvanceCtrl>();        
        siteSelectionMap = new Map <String, String>();
        expensePolicyAllowanceMap = new Map <String, String>();        
        optRecordTypeMap = new Map <String, String>();
        tdRecordTypeMap = new Map <String, String>();
        DateTime dt = null; 
        sobjectTypeList.add(TRAVEL_DETAIL_API_NAME);
        sobjectTypeList.add(TRAVEL_OPTION_API_NAME);
        this.applicantSelectionList = new List<SelectOption>();
        this.siteSelectionList = new List<SelectOption>();
        this.currencySelectionList = new List<SelectOption>();
        this.shortCurrencySelectionMap = new Map<String, SelectOption>();
        this.journeyTypeSelectionList = new List<SelectOption>();
        this.accommodationBySelectionList = new List<SelectOption>();
        this.airfareTypeSelectionList = new List<SelectOption>();
        this.cabinClassSelectionList = new List <SelectOption>();
        this.travelAgentList = new List <SelectOption>();
        this.travelAgentMap = new Map <id, user>();
        this.applicantTravelPolicyMap = new Map <id, String>();
        this.loactionSitMap = new Map <id, Travel_Location__c>();
        this.airportMap = new Map<String, String>();
        this.passportSelectionList = new List <SelectOption>();
        this.passportSelectionMap = new Map <String, List <SelectOption>>();        
        this.userSelectionList = new List <SelectOption>();
        this.userSelectionList1 = new List <SelectOption>();
        this.userSelectionList2 = new List <SelectOption>();
        this.userSelectionList3 = new List <SelectOption>();
        this.userSelectionList4 = new List <SelectOption>();
        this.userSelectionList5 = new List <SelectOption>();
        this.userSelectionList6 = new List <SelectOption>();
        this.userSelectionList7 = new List <SelectOption>();
        this.userSelectionList8 = new List <SelectOption>();
        this.userSelectionList9 = new List <SelectOption>();
        this.routeSiteList = new List <SelectOption>();
        this.publicGrouopList = new List <String>();
        this.travelApplication = new Travel_Application__c ();
        this.travelLocationMap = new Map <id, Travel_Location__c>();
        this.siteMap = new Map <Id, Site__c>();
        this.checkPassportType = true;
        this.checkOptionEstimatedPrice1 = true;
        this.checkOptionEstimatedPrice2 = true;
        this.checkOptionEstimatedPrice3 = true;
        this.checkOptionEstimatedCurrency = true;
        this.checkOptionEstimatedCurrency2 = true;
        this.checkOptionEstimatedCurrency3 = true;
        this.checkSelectedOption1 = true;
        this.checkSelectedOption2 = true;
        this.checkSelectedOption3 = true;
        this.selectedOption1 = true;
        this.selectedOption2 = true;
        this.selectedOption3 = true;
        this.checkDeadline = true;
        this.deadline = '';
        this.selectedTab = DEFAULT_TAB;
        this.isTravelAgent = false;
        this.isAdmin = false;
        this.isMySelf = true;
        this.IsEmptyAccommodation = true;
        defStatus = Travel_Application__c.status__c.getDescribe();
        pickVals = defStatus.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals){
            if (pv.isDefaultValue()){
                this.travelApplication.status__c = pv.getValue();
            }
        }
        for ( Locale_DateTime_Format__c reader : 
            [ 
                select Locale__c, Datetime_Format__c, Date_Format__c, UI_Date_Format__c, UI_Datetime_Format__c 
                from Locale_DateTime_Format__c where Locale__c = :userinfo.getlocale()
            ]){
                TETravelApplicationCtrl.DT_FORMAT = reader.Datetime_Format__c;
                TETravelApplicationCtrl.Date_FORMAT = reader.Date_Format__c;
                this.orgDate_FORMAT = String.valueof(TETravelApplicationCtrl.Date_FORMAT);
                this.orgDt_FORMAT = String.valueof(TETravelApplicationCtrl.DT_FORMAT);
                this.sDT_FORMAT =  reader.UI_Datetime_Format__c;
                this.sDate_FORMAT = reader.UI_Date_Format__c;
        }
        
        // to set site list
        List <Site__c> siteList = siteAllList();
        for (Site__c reader: siteList){          
          siteMap.put(reader.id, reader);
          this.siteSelectionMap.put(reader.Name, reader.Name);
        }
        
        // to set route list
        List <Route__c> carRouteList = routeList();
        Map <Id, Site__c> routeSiteMap = new Map <id, Site__c>();
        for (Route__c reader : carRouteList){
            if (!String.isBlank(reader.from__c)){
                routeSiteMap.put(reader.from__c, new Site__c(id = reader.from__c, Name = reader.from__r.Name));
            }
            if (!String.isBlank(reader.to__c)){
                routeSiteMap.put(reader.to__c, new Site__c(id = reader.to__c, Name = reader.to__r.Name));
            }
        }
        this.routeSiteList.add(new SelectOption('', ''));
        for (String reader :routeSiteMap.keyset()){
            this.routeSiteList.add(new SelectOption(reader, routeSiteMap.get(reader).Name));
        }
        
        // to set cabin class list
        List <Cabin_Class__c > cabinClassList = cabinClassList();
        for (Cabin_Class__c reader : cabinClassList){
            cabinClassSelectionList.add(new SelectOption(reader.id, reader.name));
        }
        
        // to set air fare list
        this.airfareTypeSelectionList.add(new SelectOption('', ''));
        defStatus = Travel_Price__c.Type__c.getDescribe();
        pickVals = defStatus.getPicklistValues();
        for (Schema.PicklistEntry pv: pickVals){
            this.airfareTypeSelectionList.add(new SelectOption(pv.getValue(), pv.getLabel()));
        }
        recordTypeList =  recordTypes (sobjectTypeList);
        this.journeyTypeSelectionList.add(new SelectOption('', ''));
        for (RecordType reader : recordTypeList){
            if(reader.SobjectType == TRAVEL_DETAIL_API_NAME){
                journeyTypeSelectionList.add(new SelectOption(reader.id, reader.Name));
                tdRecordTypeMap.put(reader.id, reader.Name);
            }
            if(reader.SobjectType == TRAVEL_OPTION_API_NAME){
                optRecordTypeMap.put(reader.Name, reader.id);
            }            
        }
        this.passportSelectionList.add(new SelectOption('',''));
        for(Travel_location__c tl : [select id, site__r.Name, site__c,  Name from travel_Location__c where site__c != null]){
            this.loactionSitMap.put(tl.id, tl);
        }
        for(GroupMember reader : [SELECT Id, GroupId, UserOrGroupId, SystemModstamp , Group.Name
                                    FROM GroupMember
                                    where UserOrGroupId = :userinfo.getUserId()]){
            publicGrouopList.add(reader.Group.Name);
        }

        if (taId == null){
            // to init parameters when the travel application is a new application
            taInit.initialNew();
        }else{
            // to init parameters when the travel application is not a new application
            this.isTravelAgent = isTravelAgent();
            this.isAdmin = isAdmin();
            taInit.initialExisting();
            this.isMySelf = isMySelf();
        }
        
        // to set accommodation by list
        List <String> accommodationByList = new List <String>();
        this.accommodationBySelectionList.add(new SelectOption('', ''));
        defStatus = Accommodation__c.Accommodation_By__c.getDescribe();
        pickVals = defStatus.getPicklistValues();
        for (Schema.PicklistEntry pv: pickVals){
            if(this.travelApplication.status__c == TEConstant.STATUS_PENDING && pv.getValue() == 'Travel Agency'){
                continue;
            }
            if(pv.getValue() == 'Travel Agency'){
                this.accommodationBySelectionList.add(new SelectOption('_'+pv.getValue(), pv.getValue()));
            }
            else{
                for(Site__c reader : siteMap.values()){
                    if(reader.Accommodation_Arragement__c){
                        this.accommodationBySelectionList.add(new SelectOption(reader.id + '_' + pv.getValue(), reader.Name + ' ' + pv.getValue()));
                    }
                }
            }
        }
        
        // to set currency list
        List<Currency__c> currencyList = currencyList();
        this.currencySelectionList.add(new SelectOption('', '')); 
        this.shortCurrencySelectionMap.put(null, new SelectOption('', ''));  
        for (Currency__c reader: currencyList){
          this.currencySelectionList.add(new SelectOption(reader.Id, reader.Description__c +OPEN_PARENTHESIS+reader.Name+ CLOSE_PARENTHESIS));
          this.shortCurrencySelectionMap.put(reader.id, new SelectOption(reader.Id, reader.Name));
        }
        
        // to set CC user list
        List<User> userList = userList();
        String name = '';
        Integer i = 1;        
        if( Label.TE_Enable_Full_CC_List == '1' ){
            for (user reader : userList){
                name = reader.Name_Display__c;
                if(String.isblank(name)){
                    name = reader.Name;
                }
                if( i <= 1000){
                    userSelectionList.add(new SelectOption(reader.Id, name));
                }
                if( i > 1000 && i <= 2000){
                    userSelectionList1.add(new SelectOption(reader.Id, name));
                }
                if( i > 2000 && i <= 3000){
                    userSelectionList2.add(new SelectOption(reader.Id, name));
                }
                if( i > 3000 && i <= 4000){
                    userSelectionList3.add(new SelectOption(reader.Id, name));
                }
                if( i > 4000 && i <= 5000){
                    userSelectionList4.add(new SelectOption(reader.Id, name));
                }
                if( i > 5000 && i <= 6000){
                    userSelectionList5.add(new SelectOption(reader.Id, name));
                }
                if( i > 6000 && i <= 7000){
                    userSelectionList6.add(new SelectOption(reader.Id, name));
                }
                if( i > 7000 && i <= 8000){
                    userSelectionList7.add(new SelectOption(reader.Id, name));
                }
                if( i > 8000 && i <= 9000){
                    userSelectionList8.add(new SelectOption(reader.Id, name));
                }
                if( i > 9000 && i <= 10000){
                    userSelectionList9.add(new SelectOption(reader.Id, name));
                }
                i++;
            }
        }
        else{
            for (user reader : userList){
                this.userSelectionList.add(new SelectOption(reader.Id, reader.Name));
            }
        }
        
        // to set airport list
        if (this.travelApplication.status__c == TEConstant.STATUS_CONFIRMED){
            this.airportList = airportList();
        }
        else{
            this.airportList = new List<Airport__c>();
        }
        counter = 1;
        for (airport__c reader : airportList){
            this.airportMap.put(reader.Name, reader.Name);
        }
    }
    
    /*
     if the application is not submit, then the apply date = current date; 
     if not, the apply date = createdDate
     @return apply date
    */
    public String getApplyDate(){
        DateTime dt;
        if (taId != null){
            dt = this.travelApplication.CreatedDate;
        }
        else{
            dt = Date.today();
        }
        return dt.format(orgDate_FORMAT);
    }
    
    /*
     When user changes the on behalf of employee, the function will refresh the travel agent list 
     @param  travelpolicy: on behalf of employee travel policy 
    */
    public void refreshAgent(String travelpolicy){
        String gpName = TRAVEL_AGENT_GP; 
        gpName = gpName.replace('@name',travelpolicy);
        this.travelAgentList.clear();
        this.travelAgentMap = new Map<id, user>([select id, Name, email from user 
                            where id in (select UserOrGroupId  from GroupMember where Group.Name = :gpName)
                            order by name
                            ]);
        for(user reader :travelAgentMap.values()){
          this.travelAgentList.add(new SelectOption(reader.id, reader.name));  
        }
        if(this.travelAgentList.isempty()){
            this.travelAgentMap = new Map<id, user>([select id, Name, email from user 
                                where id in (select UserOrGroupId  from GroupMember where Group.Name = :DEF_TRAVEL_AGENT_GP)
                                order by name
                                ]);
            for(user reader :travelAgentMap.values()){
              this.travelAgentList.add(new SelectOption(reader.id, reader.name));  
            }
        }
   }
   
   Public Void itineraryRows(String itID, String action){
       this.taAddRows.itineraryRows(taID, action);
   }
   
   Public Void OptionRows(String taID, String type, String action){
       this.taAddRows.OptionRows(taID, type, action);
   }
   
   Public Void airfareRows(String taID, String action){
       this.taAddRows.airfareRows(taID, action);
   }
   
   Public Void accommodationRows(String taID, String action){
       this.taAddRows.accommodationRows(taID, action);
   }
   
   Public Void cashAdvanceRow(String caId, String action){
       this.taAddRows.cashAdvanceRow(caId, action);
   }
   
   Public Void accommodationAddRow(){ 
       this.taAddRows.accommodationAddRow();
   }
    
   Public Void travelDetailRows(String tdID, String action){
       this.taAddRows.travelDetailRows(tdID, action);
   }
   
   Public PageReference cancelAction(){
       return this.taActions.cancelAction();
   }
   
   Public PageReference submitAction(){
       return this.taActions.submitAction();
   }
   
   Public PageReference RearrangeAction(){
       return this.taActions.RearrangeAction();
   }
   
   Public PageReference saveAction(){
       return this.taActions.saveAction();
   }
   Public PageReference savePriceAction(){//Add by DTT Team
       PageReference prf=this.taActions.saveTravelPriceAction();
       // taInit.initialExisting();
       // initial();
       return prf;
       
   }
   
   Public void changeApplicant(){
       this.passportSelectionList = passportSelectionMap.get(this.travelApplication.On_Behalf_of__c);
       refreshAgent(applicantTravelPolicyMap.get(this.travelApplication.On_Behalf_of__c));
   }
   
   /*
     To translate UI dateformat to SFDC dateformat
     @param str the date from UI
     @return SFDC datetiem format
   */
   Public DateTime getDateTimeObj(String str){
       if (str == null || str == ''){
           return null;
       }
       String[] strDTDivided = null;
       String split = ' ';
       String sDayfm = '';
       String sTimefm = '';
       String sDay = '';
       String sTime = '';
       String strtmp;
       String reg = '\\s*[a-zA-Z]+';
       Set <String> res = null;
       Integer Day;
       Integer Month;
       Integer Year;
       Integer Hr = 0;
       Integer Min = 0;
       Integer counter;
       
       if (!str.contains(':')){
           str += ' '+DT_FORMAT_0000;
       }
       strDTDivided = orgDt_FORMAT.split(WHITESPACE);
       if(strDTDivided[0] == this.orgDate_FORMAT){
           sDayfm = orgDt_FORMAT.split(WHITESPACE)[0];
           sTimefm = orgDt_FORMAT.split(WHITESPACE)[1];
           sDay = str.split(WHITESPACE)[0];
           sTime = str.split(WHITESPACE)[1];
       }
       else{
           sDayfm = orgDt_FORMAT.split(WHITESPACE)[1];
           sTimefm = orgDt_FORMAT.split(WHITESPACE)[0];
           sDay = str.split(WHITESPACE)[1];
           sTime = str.split(WHITESPACE)[0];
       }
       res = new Set<String>(sDayfm.split(reg));
       for (String reader : res){
           if(!String.isBlank(reader)){
               split = reader;
           }
       }
       counter = 0;
       strDTDivided = sDayfm.split(split);
       for(String reader : strDTDivided ){
           reader = reader.tolowercase();
           if (reader.contains('y')){
               year = Integer.valueof(sDay.split(split)[counter]);
           }
           if (reader.contains('m')){
               month = Integer.valueof(sDay.split(split)[counter]);
           }
           if (reader.contains('d')){
               day = Integer.valueof(sDay.split(split)[counter]);
           }
           counter++;
       }
       res = new Set<String>(sTimefm.split(reg));
       for (String reader : res){
           if(!String.isBlank(reader)){
               split = reader;
           }
       }
       counter = 0;
       strDTDivided = sTimefm.split(split);
       for(String reader : strDTDivided ){
           reader = reader.tolowercase();
           if (reader.contains('h')){
               Hr = Integer.valueof(sTime.split(split)[counter]);
           }
           if (reader.contains('m')){           
               if (reader.contains('a')){
                   Min = Integer.valueof((sTime.split(split)[counter]).substring(0,2));
                   if(sTime.split(split)[counter].contains('PM') && Hr != 12){
                       Hr += 12;
                   }
                   if(sTime.split(split)[counter].contains('AM') && Hr == 12){
                       Hr = 0;
                   }
               }
               else{
                   Min = Integer.valueof((sTime.split(split)[counter]));               
               }
           }
           counter++;
       }
       return DateTime.newInstance(year, month, day, Hr, Min, 0);
   }

   private List<Travel_Location__c> travelLocationAllList(){
       return [ select id, Name, Country__c, 
           (select id, name, Is_Primary__c, Travel_Location__c   from airports__r)
           from Travel_Location__c  order by Name];    
   }
   
   Private List<Cabin_Class__c> cabinClassList(){
       return [select id, Name from Cabin_Class__c order by Name  ];
   }
   
   Private List<Site__c> siteAllList(){
       return [select id, Name,(select id, Name from travel_locations__r), Accommodation_Arragement__c from Site__c order by Name  ];
   }
   
   /**
     1. if there is no budget currency, the function will return all currencies with local currency exchange rate
     2. if there is a budget currency, the function will return all currencies with local currency exchange rate
        and the cash advanve currency with budget currency    
     @return to return currency list
   */
   Private List<currency__c> currencyList(){
      Id budgetCurrencyId = null;
      Id localCurrencyId = null;
      for (Employee_Administrator__c reader : [select id, employee__r.expense_policy__r.local_currency__c from Employee_Administrator__c 
          where id = :travelApplication.On_Behalf_of__c
          ]){
           localCurrencyId =  reader.employee__r.expense_policy__r.local_currency__c;
      }
      for ( Currency__c cr : [select id
                                     from Currency__c
                                     where is_budget_currency__c = true]
        ){
            budgetCurrencyId = cr.id;
       }
       if (budgetCurrencyId != null){
           return
            [SELECT Id, Name, Description__c 
             FROM Currency__c
             where  id in (select From_Currency__c
                          from Exchange_Rate__c 
                          where Is_Latest__c = true and
                          Is_Book_Rate__c = true and To_Currency__c = :localCurrencyId)
                    and
                    id IN
                     (select From_Currency__c 
                          from Exchange_Rate__c 
                          where Is_Latest__c = true and
                          Is_budget_Rate__c = true and To_Currency__c   =: budgetCurrencyId 
                          
                          )
             ORDER BY Description__c];
       }
       else{
           return
           [SELECT Id, Name, Description__c 
            FROM Currency__c
            where  id in (select From_Currency__c
                          from Exchange_Rate__c 
                          where Is_Latest__c = true and
                          Is_Book_Rate__c = true and To_Currency__c = :localCurrencyId)                                   
            ORDER BY Description__c
            ];
       }
   }
   
   public List<SelectOption> getshortCurrencySelectionList(){
       return shortCurrencySelectionMap.values();
   }
   
   public Employee__c currentEmpRecord(String eid){
       return [
               select id, Name, user__r.Name, user__c, user__r.Physical_Delivery_Address__c, expense_policy__r.local_currency__c,
               user__r.Name_display__c,travel_policy__r.name,
               (select id, Name, Employee_Administrator__r.expense_policy__c, Employee__r.expense_policy__c, is_self__c,
               Employee__r.user__c, Employee__r.user__r.Physical_Delivery_Address__c, Employee__r.Flight_Class__c,
               Employee__r.Frequent_Flyer_No_1__c, Employee__r.Frequent_Flyer_No_2__c, Employee__r.Frequent_Flyer_No_3__c,
               Employee__r.Frequent_Flyer_Program_1__c, Employee__r.Frequent_Flyer_Program_2__c, Employee__r.Frequent_Flyer_Program_3__c,
               Employee__r.Passport_Expiry_Date_1__c, Employee__r.Passport_Expiry_Date_2__c, Employee__r.Passport_Expiry_Date_3__c,
               Employee__r.Passport_Issue_Date_1__c, Employee__r.Passport_Issue_Date_2__c, Employee__r.Passport_Issue_Date_3__c,
               Employee__r.Passport_Full_Name__c, Employee__r.Passport_Full_Name_2__c, Employee__r.Passport_Full_Name_3__c,
               Employee__r.Passport_No_1__c, Employee__r.Passport_No_2__c, Employee__r.Passport_No_3__c,
               Employee__r.Passport_Type_1__c, Employee__r.Passport_Type_2__c, Employee__r.Passport_Type_3__c,
               Employee__r.Preferred_Seat__c, Employee__r.expense_policy__r.Finance_Email__c,
               Employee__r.Travel_Policy__r.Name
               from Employee_Administrators1__r order by Is_Self__c desc, Employee__r.Name ) 
               from employee__c 
               where (user__c = :eid or id = :eid) limit 1
       ];
   }
   
   Public Travel_Application__c travelApplicationRecord(String Id){
       return [
       select id, CreatedDate, Status__c, Name, CreatedById, CreatedBy.Name, Selected_Passport__c, cc_Email_List__c,       
       On_Behalf_of__c, On_Behalf_of__r.Employee_Administrator__c, On_Behalf_of__r.Employee__c,
       On_Behalf_of__r.Employee_Administrator__r.Name, On_Behalf_of__r.Employee__r.Name,  on_behalf_of__r.Employee__r.travel_policy__r.name,
       On_Behalf_of__r.Employee__r.user__c, On_Behalf_of__r.Employee_Administrator__r.user__c, On_Behalf_of__r.Employee_Administrator__r.user__r.TimeZoneSidKey ,
       on_behalf_of__r.Employee__r.Flight_Class__c, CreatedBy.Physical_Delivery_Address__c,
       on_behalf_of__r.Employee__r.Frequent_Flyer_No_1__c, on_behalf_of__r.Employee__r.Frequent_Flyer_No_2__c, on_behalf_of__r.Employee__r.Frequent_Flyer_No_3__c,
       on_behalf_of__r.Employee__r.Frequent_Flyer_Program_1__c, on_behalf_of__r.Employee__r.Frequent_Flyer_Program_2__c, on_behalf_of__r.Employee__r.Frequent_Flyer_Program_3__c,
       on_behalf_of__r.Employee__r.Passport_Expiry_Date_1__c, on_behalf_of__r.Employee__r.Passport_Expiry_Date_2__c, on_behalf_of__r.Employee__r.Passport_Expiry_Date_3__c,
       on_behalf_of__r.Employee__r.Passport_Issue_Date_1__c, on_behalf_of__r.Employee__r.Passport_Issue_Date_2__c, on_behalf_of__r.Employee__r.Passport_Issue_Date_3__c,
       on_behalf_of__r.Employee__r.Passport_Full_Name__c, on_behalf_of__r.Employee__r.Passport_Full_Name_2__c, on_behalf_of__r.Employee__r.Passport_Full_Name_3__c,
       on_behalf_of__r.Employee__r.Passport_No_1__c, on_behalf_of__r.Employee__r.Passport_No_2__c, on_behalf_of__r.Employee__r.Passport_No_3__c,
       on_behalf_of__r.Employee__r.Passport_Type_1__c, on_behalf_of__r.Employee__r.Passport_Type_2__c, on_behalf_of__r.Employee__r.Passport_Type_3__c,
       on_behalf_of__r.Employee__r.Preferred_Seat__c, on_behalf_of__r.Employee__r.expense_policy__r.Finance_Email__c,
       on_behalf_of__r.Employee__r.expense_policy__r.local_currency__c, on_Behalf_Of__r.Employee_UserId__c,On_Behalf_Of__r.Administrator__c,
       Purpose_of_Visit__c, Trip_Remarks__c, Confirmed_Air_Travel_Detail_Count__c, Departure_Date__c, Return_Date__c,
       Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c,
       Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c,
       Option_Estimated_Price1__c, Option_Estimated_Price2__c, Option_Estimated_Price3__c, 
       Option_Estimated_Currency__c, Option_Estimated_Currency__r.Name,
       Option_Estimated_Currency2__c, Option_Estimated_Currency2__r.Name,
       Option_Estimated_Currency3__c, Option_Estimated_Currency3__r.Name,
       Deadline__c,Selected_Option_1__c, Selected_Option_2__c, Selected_Option_3__c, Tech_Earliest_Departure_Date__c,
       Agent_Travel_Option_Counter__c, Pending_Applicant_Selection_Count__c, Pending_Applicant_Confirmation__c, Accommodation_Cancelled_Count__c,
       Admin_Pending_Arrangement__c, Travel_Option_Pending_Applicant_Confirm__c, Applicant_Travel_Option_Counter__c,
       Pending_Reservation_Accommodation_Count__c, Admin_Accommodation_Count__c, Travel_Agency__c, Pending_Accommodation_Confirm_Count__c,
       (select id, Site_To_Visit__c, Self_Arragnment__c, Admin_Pick_Up__c, Preferred_Airline__c,Departure_Route__c,
       Origin_Site__c, Destination__c, Origin_Site__r.Name, Destination__r.Name,
       Status__c, Preferred_Departure_dt__c, Preferred_Return_dt__c, Return_Date__c, No_of_Seats__c,
       Return_Route__c , RecordTypeId, Record_Type_Name__c, Travel_Application__c,
       Preferred_Departure_Time_Display__c , Preferred_Return_Time_Display__c, 
       Shuttle_From__c, Shuttle_To__c, Shuttle_From__r.Name, Shuttle_To__r.Name,
       Departure_Route__r.For_Guest__c, Return_Route__r.For_Guest__c,
       Departure_Pick_Up_Point__c, Departure_Pick_Up_Point__r.Arrival_Time__c, Departure_Pick_Up_Point__r.Location__c, 
       Confirmed_Departure_Pick_Up_Point__c, Confirmed_Departure_Pick_Up_Point__r.Arrival_Time__c, Confirmed_Departure_Pick_Up_Point__r.Location__c, 
       Return_Pick_Up_Point__c, Return_Pick_Up_Point__r.Arrival_Time__c, Return_Pick_Up_Point__r.Location__c,
       Confirmed_Return_Pick_Up_Point__c, Confirmed_Return_Pick_Up_Point__r.Arrival_Time__c, Confirmed_Return_Pick_Up_Point__r.Location__c,
       Departure_Assigned_Shuttle__c, Return_Assigned_Shuttle__c, Is_Exist__c,
       Preferred_Departure_Date__c, Preferred_return_Date__c  
       from travel_Details__r),
       (select id, Accommodation_By__c, Budget_per_Night__c, Check_in_Date__c, Check_out_Date__c, Is_Exist__c, site__r.Name,
       Currency__c, Currency__r.name, Location__c, Location__r.name, Remarks__c, Status__c, Travel_Application__c, Tech_Site_and_Arrage_By__c, site__c
       from Accommodations__r),
       (select id, Check_in_Date__c, Check_out_Date__c, Departure_Date__c, Destination__c, Destination__r.Name, recordtypeId, 
       From__c, From__r.name, Option1__c, Option2__c, Option3__c, 
       Selected_Option1__c, Selected_Option2__c, Selected_Option3__c, To__c, To__r.Name, status__c,
       Selected_Option1_Display__c, Selected_Option2_Display__c, Selected_Option3_Display__c, Travel_Application__c,
       Preferred_Departure_Time__c , Preferred_Return_Time__c, travel_detail__r.Origin_Site__c, travel_detail__r.Destination__c,
       Budget_Currency__c, Budget_Currency__r.name, Budget_per_Night__c
       from TravelOptions__r order by Departure_Date__c),
       (select id, Invoice_No__c, invoice_date__c, remark__c, type__c, amount__c, currency__c
       from travel_prices__r),
       (select id,  ETA__c, ETD__c, Cabin_Class__c, Flight_Classification__c, Flight__c, Departure_Date__c, Arrival_Date__c, 
        From_Airport__c, To_Airport__c, Travel_Application__c, From_Airport_Text__c, To_Airport_Text__c 
       from Journeys__r),
       (select id, Name, currency__c, currency__r.Name, currency__r.Description__c, status__c, amount__c, Expected_Collection_Date__c, Remarks__c, Travel_Application__c from Cash_Advances__r)
       from Travel_Application__c where id = :id];
   }
   
   /**
     To control the rearrange button button
     @return true if the login user can rearrage the travel application
             false if the login user can not rearragene the travel application
   */
   public Boolean getisRearrange(){
       return 
       (    isTravelAgent() && 
            ((this.travelApplication.Travel_Option_Pending_Applicant_Confirm__c >0 || this.travelApplication.Agent_Travel_Option_Counter__c > 0 )&& this.travelApplication.status__c == TEConstant.STATUS_PENDING)
       );
   }
   
   /**
     To control the save button button
     @return true if the login user can save the travel application
             false if the login user can not save the travel application
   */
   public Boolean getisSave(){
       return 
       !( 
           (isMySelf() && (
               (this.travelApplication.id == null ||  this.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED  || this.travelApplication.status__c == TEConstant.STATUS_CONFIRMED) ||
               (this.travelApplication.status__c == TEConstant.STATUS_PENDING 
                   //&& (this.travelApplication.Pending_Applicant_Selection_Count__c > 0 || this.travelApplication.Pending_Applicant_Confirmation__c > 0  || this.travelApplication.Pending_Accommodation_Confirm_Count__c > 0 ) 
               )
           )) ||
           (isTravelAgent() && (
               this.travelApplication.Agent_Travel_Option_Counter__c > 0  || this.travelApplication.Pending_Applicant_Selection_Count__c > 0  ||
               this.travelApplication.status__c == TEConstant.STATUS_CONFIRMED   
           )) ||
           (isAdmin() && (
               (this.travelApplication.Admin_Pending_Arrangement__c > 0) ||
               (this.travelApplication.Pending_Reservation_Accommodation_Count__c > 0 && this.travelApplication.Admin_Accommodation_Count__c > 0)
           ))
       );
   }
   
   /**
     To control the submit button button
     @return true if the login user can submit the travel application
             false if the login user can not submit the travel application
   */
   public Boolean getisSubmit(){
       return 
       !(
           (this.travelApplication.status__c == TEConstant.STATUS_CONFIRMED ||
            this.travelApplication.status__c == TEConstant.STATUS_CANCELLED
           ) ||  
           (isMySelf() && (
               //Revised by TAL (Twinkle LI) @20170719 to enable 'Submit' button when Application is in PENDING status and contains 'Cancelled' Accommodation
               (this.travelApplication.id == null ||  this.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED  || this.travelApplication.status__c == TEConstant.STATUS_CONFIRMED) ||
               (this.travelApplication.status__c == TEConstant.STATUS_PENDING && (this.travelApplication.Pending_Applicant_Selection_Count__c > 0 || this.travelApplication.Pending_Applicant_Confirmation__c > 0  || this.travelApplication.Pending_Accommodation_Confirm_Count__c > 0 || this.travelApplication.Accommodation_Cancelled_Count__c > 0) )

           )) ||
           (isTravelAgent() && (
               this.travelApplication.Agent_Travel_Option_Counter__c > 0  || 
               this.travelApplication.status__c == TEConstant.STATUS_CONFIRMED               
           )) ||
           (isAdmin() && (
               (this.travelApplication.Admin_Pending_Arrangement__c > 0) ||
               (this.travelApplication.Pending_Reservation_Accommodation_Count__c > 0 && this.travelApplication.Admin_Accommodation_Count__c > 0) 
           ))
       );
   }
   /**
     To random output string
     @param len the random string length
     @return random string
   */
   
   Public String generateRandomString(Integer len) {
       final String chars = RANDOM_STRING ;
       String randStr = '';
       while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
       }
       return randStr; 
   }
   
   private List<RecordType> recordTypes (List <String> sobjectTypeList){
       return [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType = :sobjectTypeList and IsActive = true];
   }
   
   private List<Route__c> routeList (){
       return  [SELECT Id, Name, Departure_Time__c , For_Guest__c, from__r.Name, from__c, to__r.Name, to__c, (select id, Location__c, Stop_Type__c, Arrival_Time__c from Shuttle_Stops__r)
             FROM Route__c];
   }
   
   private List<user> userList(){
       if(Label.TE_Enable_Full_CC_List == '1'){
           return [select id, Name, Name_display__c from user where isactive= true and Profile.UserType  in ( 'Standard', 'CsnOnly' ) order by Name];
       }
       else{
           return [select id, Name, Name_display__c  from user where Physical_Delivery_Address__c = :this.currentEmp.user__r.Physical_Delivery_Address__c  and isactive= true order by Name];
        }
   }
   
   private List <airport__c> airportList(){
       return [select id, Name, travel_location__c, Is_Primary__c, Airport_Code__c from airport__c order by Name ];
   }
   
   public Boolean getisApplicantMode(){
       if(this.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED){
           return true;
       }
       else{
           return false;
       }    
   }

   /**
     Check the login user is the applicant or not
     @return true if the login user is applicant
             false if the login user is not applicant
   */
   Public Boolean isMySelf(){ 
       if (this.travelApplication.id == null) {
           return true;
       }
       if (this.travelApplication.On_Behalf_of__r.Employee__r.user__c == UserInfo.getUserId()){
           return true;
       }
       if (this.travelApplication.On_Behalf_of__r.Employee_Administrator__r.user__c == UserInfo.getUserId()){
           return true;
       }
       return false;
   }
   
   /**
     Check the login user is travel agent or not
     @return true if the login user is travel agent
             false if the login user is not travel agent
   */
   private Boolean isTravelAgent(){
      for (SetupEntityAccess  readrer : [SELECT Id
            FROM SetupEntityAccess 
            where SetupEntityId in ( SELECT Id  FROM CustomPermission where DeveloperName =: TEConstant.CUSTOM_PERMISSION_TE_TRAVEL_AGENT )
            and ParentId in 
            ( SELECT   PermissionSetId
              FROM PermissionSetAssignment
              where AssigneeId  = :UserInfo.getUserId()
            )
      ]){
          return true;
      }
      return false;
   }

   /**
     Check the login user is local admin or not
     @return true if the login user is admin
             false if the login user is not admin
   */
   private Boolean isAdmin(){      
      for (SetupEntityAccess  readrer : [SELECT Id
            FROM SetupEntityAccess 
            where SetupEntityId in ( SELECT Id  FROM CustomPermission where DeveloperName =: TEConstant.CUSTOM_PERMISSION_TE_ADMIN )
            and ParentId in 
            ( SELECT   PermissionSetId
              FROM PermissionSetAssignment
              where AssigneeId  = :UserInfo.getUserId()
            )]){
          return true;
      }
      return false;
   }
   
   Public String getDT_FORMAT(){
        return TETravelApplicationCtrl.DT_FORMAT;
   }
    
   Public String getDate_FORMAT (){
        return TETravelApplicationCtrl.Date_FORMAT ;
   }
   
   /**
     To check any accommodation lines in the accommodation tab.
     @return true  if there are some empty accommodation lines in the accommodation tab
             false if there are no empty accommodation lines in the accommodation tab
   */
   Public Boolean getisEmptyAccommodation(){
       if ((travelApplication.status__c != 'DF' || travelApplication.status__c != 'NS') && travelApplication.id != null){
           return false;
       }
       for(TEAccommodationCtrl reader: travelAccommodationList){
           if( 
               !String.isBlank(reader.CheckInDate) ||
               !String.isBlank(reader.CheckOutDate) || 
               !String.isBlank(reader.accommodation.location__c) ||
               !String.isBlank(reader.accommodation.Tech_Site_and_Arrage_By__c)
           ){
               return false;
           }
       }
       return true;
   }
   
   /**
     When user input a location to travel application, the action will trigger the function and find the location allowance
     @param  locationId: the location ID
     @param  onBehalfOfId: employee administrator ID
     @return Returns the travel location allowance (budget/night) 
   */
   @RemoteAction
   Public static Travel_Location_Allowance__c getBudget(String locationId, String onBehalfOfId) {
       String expPolicy = '';
       String budget = BUDGET_ERROR_MESSAGE;
       Travel_Location_Allowance__c tla = null;
       for (Employee_Administrator__c  reader : [select employee__r.Expense_Policy__c from Employee_Administrator__c where id = :onBehalfOfId]){
           expPolicy = reader.employee__r.Expense_Policy__c;
       }
       for (Travel_Location_Allowance__c reader : [
           select id, Daily_Maximum_Hotel_Cost__c, Maximum_of_Hotel_Allowance_Currency__c, Expense_Policy__r.Hotel_Allowance_Currency__c
           from Travel_Location_Allowance__c
           where Travel_Location__c =  :locationId
           and Expense_Policy__c = :expPolicy 
       ]){
           budget = reader.Maximum_of_Hotel_Allowance_Currency__c +WHITESPACE+ reader.Daily_Maximum_Hotel_Cost__c; 
           tla = reader;
       }
       return tla;
   }
}