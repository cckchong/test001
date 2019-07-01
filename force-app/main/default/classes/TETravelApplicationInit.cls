public without sharing class TETravelApplicationInit{
    
    Public TETravelApplicationCtrl taCtrl = null;
     
    Public TETravelApplicationInit (TETravelApplicationCtrl taCtrl){
        this.taCtrl = taCtrl;
    }
    
    Public void initialNew(){
        String str;
        List <selectoption> tmppassportSelectionList = new List <selectoption>();
        
        this.taCtrl.currentEmp = currentEmpRecord(UserInfo.getUserId());
        this.taCtrl.refreshAgent(this.taCtrl.currentEmp.travel_policy__r.name);
        for (Employee_Administrator__c reader : this.taCtrl.currentEmp.Employee_Administrators1__r){
            if(!reader.is_active__c){
                continue;
            }
            if(this.taCtrl.travelApplication.On_Behalf_of__c == null){
                this.taCtrl.travelApplication.On_Behalf_of__c = reader.id;
            }
            tmppassportSelectionList = new List <SelectOption>();
            this.taCtrl.applicantSelectionList.add(new SelectOption(reader.Id, reader.Name));
            tmppassportSelectionList.add(new SelectOption('',''));
            if (reader.Employee__r.Passport_Type_1__c != null){
                str = reader.Employee__r.Passport_Type_1__c.replace(TETravelApplicationCtrl.WHITESPACE, TETravelApplicationCtrl.UNDERSCORE);
                tmppassportSelectionList.add(new SelectOption(str, reader.Employee__r.Passport_Type_1__c));
                if (reader.is_self__c){
                    this.taCtrl.passportSelectionList.add(new SelectOption(str , reader.Employee__r.Passport_Type_1__c));
                }
            }
            if (reader.Employee__r.Passport_Type_2__c != null){
                str = reader.Employee__r.Passport_Type_2__c.replace(TETravelApplicationCtrl.WHITESPACE, TETravelApplicationCtrl.UNDERSCORE);
                tmppassportSelectionList.add(new SelectOption(str, reader.Employee__r.Passport_Type_2__c));
                if (reader.is_self__c){
                    this.taCtrl.passportSelectionList.add(new SelectOption(str , reader.Employee__r.Passport_Type_2__c));
                }
            }
            if (reader.Employee__r.Passport_Type_3__c != null){
                str = reader.Employee__r.Passport_Type_3__c.replace(TETravelApplicationCtrl.WHITESPACE, TETravelApplicationCtrl.UNDERSCORE);
                tmppassportSelectionList.add(new SelectOption(str, reader.Employee__r.Passport_Type_3__c));
                if (reader.is_self__c){
                    this.taCtrl.passportSelectionList.add(new SelectOption(str , reader.Employee__r.Passport_Type_3__c));
                }
            }
            this.taCtrl.passportSelectionMap.put(reader.id, tmppassportSelectionList);
            this.taCtrl.applicantTravelPolicyMap.put(reader.id, reader.Employee__r.Travel_Policy__r.Name);
        }
        for (Integer i = 1; i <= this.taCtrl.NUM_OF_ROW_DEF; i++){
            this.taCtrl.travelDetailList.add(new TETravelDetail(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl));
        }
        this.taCtrl.cashAdvanceList.add(new TECashAdvanceCtrl(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl));
        this.taCtrl.travelAccommodationList.add(new TEAccommodationCtrl(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl));
        if(this.taCtrl.travelApplication.status__c != TEConstant.STATUS_DRAFT){
            this.taCtrl.airtravelOptionList.add(new TETravelOption(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl, TETravelApplicationCtrl.AIR_OPTION_TYPE));
            this.taCtrl.hotelTravelOptionList.add(new TETravelOption(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl, TETravelApplicationCtrl.HOTEL_OPTION_TYPE));
        }
    }
    
    Public void initialExisting(){
        String str = '';
        DateTime dt = null; 
        
        this.taCtrl.travelApplication = this.taCtrl.travelApplicationRecord(this.taCtrl.taid);
        this.taCtrl.refreshAgent(this.taCtrl.travelApplication.On_behalf_of__r.Employee__r.travel_policy__r.name);
        if(this.taCtrl.travelApplication.On_Behalf_Of__r.Employee_UserId__c == null){
            this.taCtrl.currentEmp = this.taCtrl.currentEmpRecord(this.taCtrl.travelApplication.On_Behalf_Of__r.Employee_UserId__c);
        }
        else{
            this.taCtrl.currentEmp = this.taCtrl.currentEmpRecord(this.taCtrl.travelApplication.On_Behalf_Of__r.employee__c);
        }
        this.taCtrl.isMySelf = this.taCtrl.isMySelf();
        this.taCtrl.selectedOption1 = this.taCtrl.travelApplication.Selected_Option_1__c;
        this.taCtrl.selectedOption2 = this.taCtrl.travelApplication.Selected_Option_2__c;
        this.taCtrl.selectedOption3 = this.taCtrl.travelApplication.Selected_Option_3__c;
        if (this.taCtrl.travelApplication.on_behalf_of__r.Employee__r.Passport_Type_1__c != null){
            str = this.taCtrl.travelApplication.on_behalf_of__r.Employee__r.Passport_Type_1__c.replace(TETravelApplicationCtrl.WHITESPACE, TETravelApplicationCtrl.UNDERSCORE);
            this.taCtrl.passportSelectionList.add(new SelectOption(str, this.taCtrl.travelApplication.on_behalf_of__r.Employee__r.Passport_Type_1__c));
        }
        if (this.taCtrl.travelApplication.on_behalf_of__r.Employee__r.Passport_Type_2__c != null){
            str = this.taCtrl.travelApplication.on_behalf_of__r.Employee__r.Passport_Type_2__c.replace(TETravelApplicationCtrl.WHITESPACE, TETravelApplicationCtrl.UNDERSCORE);
            this.taCtrl.passportSelectionList.add(new SelectOption(str, this.taCtrl.travelApplication.on_behalf_of__r.Employee__r.Passport_Type_2__c));
        }
        if (this.taCtrl.travelApplication.on_behalf_of__r.Employee__r.Passport_Type_3__c != null){
            str = this.taCtrl.travelApplication.on_behalf_of__r.Employee__r.Passport_Type_3__c.replace(TETravelApplicationCtrl.WHITESPACE, TETravelApplicationCtrl.UNDERSCORE);
            this.taCtrl.passportSelectionList.add(new SelectOption(str, this.taCtrl.travelApplication.on_behalf_of__r.Employee__r.Passport_Type_3__c));
        }
        this.taCtrl.passportSelectionMap.put(this.taCtrl.travelApplication.on_behalf_of__c, this.taCtrl.passportSelectionList);
        if(this.taCtrl.travelApplication.deadline__c != null){
            dt = this.taCtrl.travelApplication.deadline__c;
            this.taCtrl.deadline = dt.format(TETravelApplicationCtrl.Date_FORMAT);
        }
        for (Travel_Detail__c reader : this.taCtrl.travelApplication.travel_Details__r){
            if(!String.IsBlank(reader.Origin_Site__c)){
                this.taCtrl.travelLocationMap.put(reader.Origin_Site__c, new Travel_Location__c(id=reader.Origin_Site__c, Name = reader.Origin_Site__r.Name));
            }
            if(!String.IsBlank(reader.Destination__c)){
                this.taCtrl.travelLocationMap.put(reader.Destination__c, new Travel_Location__c(id=reader.Destination__c, Name = reader.Destination__r.Name));
            }
            this.taCtrl.travelDetailList.add(new TETravelDetail(this.taCtrl, reader));
        }
        for (Accommodation__c reader : this.taCtrl.travelApplication.Accommodations__r){
            this.taCtrl.travelLocationMap.put(reader.Location__c, new Travel_Location__c(id=reader.Location__c, Name = reader.Location__r.Name));
            this.taCtrl.travelAccommodationList.add(new TEAccommodationCtrl(reader, this.taCtrl));
        }
        for (Journey__c reader : this.taCtrl.travelApplication.Journeys__r){
            this.taCtrl.travelItineraryList.add(new TETravelItineraryCtrl(this.taCtrl, reader));
        }
        TETravelOption tmpTTO = null;
        for (TravelOption__c reader : this.taCtrl.travelApplication.TravelOptions__r){
            tmpTTO = new TETravelOption (reader, this.taCtrl);
            if(!String.IsBlank(reader.Destination__c)){
                this.taCtrl.travelLocationMap.put(reader.Destination__c, new Travel_Location__c(id=reader.Destination__c, Name = reader.Destination__r.Name));
            }
            if(!String.IsBlank(reader.From__c)){
                this.taCtrl.travelLocationMap.put(reader.From__c, new Travel_Location__c(id=reader.From__c, Name = reader.From__r.Name));
            }
            if(!String.IsBlank(reader.To__c)){
                this.taCtrl.travelLocationMap.put(reader.To__c, new Travel_Location__c(id=reader.To__c, Name = reader.To__r.Name));
            }
            if (tmpTTO.Type == TETravelApplicationCtrl.AIR_OPTION_TYPE ){
                this.taCtrl.airTravelOptionList.add(tmpTTO);
            }
            if (tmpTTO.Type == TETravelApplicationCtrl.HOTEL_OPTION_TYPE ){
                this.taCtrl.hotelTravelOptionList.add(tmpTTO);
            }
        }
        TETravelpricectrl tmptp = null;
        for(Travel_Price__c reader : this.taCtrl.travelApplication.travel_prices__r){
            tmptp = new TETravelpricectrl(this.taCtrl, reader);
            this.taCtrl.travelPriceList.add(tmptp);
        }
        if(this.taCtrl.travelItineraryList.isempty() && this.taCtrl.travelApplication.status__c == TEConstant.STATUS_CONFIRMED){            
            for(TETravelDetail reader : this.taCtrl.travelDetailList){
                for (RecordType rtreader : this.taCtrl.recordTypeList){
                    if(rtreader.SobjectType == TETravelApplicationCtrl.TRAVEL_DETAIL_API_NAME && rtreader.Name == TETravelApplicationCtrl.AIR_TRAVEL_DETAIL_TYPE && reader.TravelDetail.recordTypeId == rtreader.id){
                         this.taCtrl.travelItineraryList.add(new TETravelItineraryCtrl(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl, reader, TETravelApplicationCtrl.ITINERARY_TYPE_DEPARTURE));
                         if ( reader.TravelDetail.Preferred_Return_dt__c != null){
                             this.taCtrl.travelItineraryList.add(new TETravelItineraryCtrl(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl, reader, TETravelApplicationCtrl.ITINERARY_TYPE_RETURN));
                         }
                    }
                }
            }
        }
        for(Cash_Advance__c reader : this.taCtrl.travelApplication.Cash_Advances__r){
            this.taCtrl.cashAdvanceList.add(new TECashAdvanceCtrl(reader.id, this.taCtrl, reader));
        }
        if(this.taCtrl.travelDetailList.isempty()){
            for (Integer i = 1; i <= this.taCtrl.NUM_OF_ROW_DEF; i++){
                this.taCtrl.travelDetailList.add(new TETravelDetail(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl));
            }
        }
        /*
        if(this.taCtrl.travelAccommodationList.isempty() && (this.taCtrl.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.taCtrl.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED)){
        */
        if(this.taCtrl.isMyself && (this.taCtrl.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.taCtrl.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED || this.taCtrl.travelApplication.status__c == TEConstant.STATUS_PENDING)){
            this.taCtrl.travelAccommodationList.add(new TEAccommodationCtrl(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl));
        }
        if(this.taCtrl.isTravelAgent && this.taCtrl.airtravelOptionList.isempty() && this.taCtrl.travelApplication.status__c == TEConstant.STATUS_PENDING){
            this.taCtrl.airtravelOptionList.add(new TETravelOption(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl, TETravelApplicationCtrl.AIR_OPTION_TYPE));
        }
        if(this.taCtrl.isTravelAgent && this.taCtrl.hotelTravelOptionList.isempty() && this.taCtrl.travelApplication.status__c == TEConstant.STATUS_PENDING){
            this.taCtrl.hotelTravelOptionList.add(new TETravelOption(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl, TETravelApplicationCtrl.HOTEL_OPTION_TYPE));
        }
        this.taCtrl.travelPriceList.add(new TETravelPriceCtrl(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl));
        if(this.taCtrl.isMyself && this.taCtrl.cashAdvanceList.isempty()){
            //if (this.taCtrl.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.taCtrl.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED  || this.taCtrl.travelApplication.status__c == TEConstant.STATUS_CONFIRMED){
               this.taCtrl.cashAdvanceList.add(new TECashAdvanceCtrl(this.taCtrl.generateRandomString(this.taCtrl.RANDOM_STRING_LEN), this.taCtrl));
            //}
        }
    }
    
    Private Employee__c currentEmpRecord(String eid){
       return [
               select id, Name, user__r.Name, user__c, user__r.Physical_Delivery_Address__c, expense_policy__r.local_currency__c,
               user__r.Name_display__c,
               travel_policy__r.name,
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
               Employee__r.Travel_Policy__r.Name, is_active__c, Employee__r.is_active__c
               from Employee_Administrators1__r order by Is_Self__c desc, Employee__r.Name ) 
               from employee__c 
               where (user__c = :eid or id = :eid)
               limit 1
       ];
   }
}