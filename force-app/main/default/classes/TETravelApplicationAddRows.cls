public without sharing class TETravelApplicationAddRows{

    Public Static String ROW_ACTION_ADD = 'A';
    Public Static String ROW_ACTION_REMOVE = 'R';
    Public Static String AIR_OPTION_TYPE = 'Air';
    Public Static String HOTEL_OPTION_TYPE = 'Hotel';  
    Public Static String ROW_ACTION_DUPLICATE = 'D';
    Public Static String SHUTTLE_TRAVEL_DETAIL_TYPE = 'Shuttle';
    Public Static String AIR_TRAVEL_DETAIL_TYPE = 'Air';
    Public Static String SURFACE_TRAVEL_DETAIL_TYPE = 'Surface';
    Public Static String WHITESPACE= ' ';
    Public String RANDOM_STRING = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    Public Integer RANDOM_STRING_LEN = 15;
    Public Travel_Application__c travelApplication{get;set;}
    Public List <TETravelItineraryCtrl> travelItineraryList{get;set;}
    Public List <TETravelOption> airTravelOptionList{get;set;}
    Public List <TETravelOption> hotelTravelOptionList{get;set;}
    Public List <TETravelPriceCtrl> travelPriceList{get;set;}
    //Public List <TEAccommodationCtrl> travelAccommodationList{get;set;}
    Public List <TECashAdvanceCtrl> cashAdvanceList{get;set;}
    Public List <TETravelDetail> travelDetailList{get;set;}
    Public Map <id, Travel_Location__c> travelLocationMap{get;set;}
    Public Map <Id, Site__c> siteMap;
    Public Map <String, String> tdRecordTypeMap{get;set;}   
    Public TETravelApplicationCtrl taCtrl = null;
    
    Public TETravelApplicationAddRows(TETravelApplicationCtrl taCtrl){
        this.taCtrl = taCtrl;
        this.travelItineraryList = taCtrl.travelItineraryList;
        this.airTravelOptionList = taCtrl.airTravelOptionList;
        this.hotelTravelOptionList = taCtrl.hotelTravelOptionList;
        this.travelPriceList = taCtrl.travelPriceList;
        //this.travelAccommodationList = taCtrl.travelAccommodationList;
        this.cashAdvanceList = taCtrl.cashAdvanceList;
        this.travelDetailList = taCtrl.travelDetailList;
        this.travellocationmap = taCtrl.travellocationmap;
        this.siteMap = taCtrl.siteMap;
        this.tdRecordTypeMap = taCtrl.tdRecordTypeMap;
        this.travelApplication = taCtrl.travelApplication;
        
    }
        
    Public Void itineraryRows(String itID, String action){
      Integer size = travelItineraryList.size();
      Integer counter = 1;
      if (size == 1 && action == ROW_ACTION_REMOVE){
           itineraryRows(itID, ROW_ACTION_ADD);
           this.travelItineraryList.remove(0);
           return;
       }
       TETravelItineraryCtrl newTravelItinerary = new TETravelItineraryCtrl(generateRandomString(RANDOM_STRING_LEN), this.taCtrl);
       for(TETravelItineraryCtrl reader : travelItineraryList){
           if (reader.id == itID){
               if (action == ROW_ACTION_ADD){
                   if (counter == size){
                       this.travelItineraryList.add(newTravelItinerary);
                   }
                   else{
                       this.travelItineraryList.add(counter, newTravelItinerary);
                   }
                   break;
               }
               if (action == ROW_ACTION_REMOVE){
                   this.travelItineraryList.remove(counter-1);
                   break;
               }
           }
           counter++;
       }
   }
   
   Public Void OptionRows(String taID, String type, String action){
       Integer size = 0;
       Integer counter = 1;
       TETravelOption newTETravelOption = new TETravelOption(generateRandomString(RANDOM_STRING_LEN), this.taCtrl, type);
       for(TETravelOption reader : airtravelOptionList){
           if (!String.isBlank(reader.travelOption.From__c)){
               this.travelLocationMap.put(reader.travelOption.From__c, new Travel_Location__c(id=reader.travelOption.From__c, Name = reader.FromName));
           }
           if (!String.isBlank(reader.travelOption.To__c)){
               this.travelLocationMap.put(reader.travelOption.To__c, new Travel_Location__c(id=reader.travelOption.To__c, Name = reader.ToName));
           }
       }
       for(TETravelOption reader : hotelTravelOptionList){
          if (!String.isBlank(reader.travelOption.Destination__c)){
             this.travelLocationMap.put(reader.travelOption.Destination__c, new Travel_Location__c(id=reader.travelOption.Destination__c, Name = reader.DestinationName));
         }
       }
       If (type == AIR_OPTION_TYPE){
           size = airtravelOptionList.size();
            if (size == 1 && action == ROW_ACTION_REMOVE){
               OptionRows(taID, type,ROW_ACTION_ADD);
               this.airtravelOptionList.remove(0);
               return;
           }
           for(TETravelOption reader : airtravelOptionList){
               //tmp = reader.id + EQUALS + taID;
               if (reader.id == taID){
                   if (action == ROW_ACTION_ADD){
                       if (counter == size){
                           this.airtravelOptionList.add(newTETravelOption );
                       }
                       else{
                           this.airtravelOptionList.add(counter, newTETravelOption );
                       }
                       break;
                   }
                   if (action == ROW_ACTION_REMOVE){
                       this.airtravelOptionList.remove(counter-1);
                       break;
                   }
               }
               counter++;
           }
       }
       If (type == HOTEL_OPTION_TYPE){
           size = hotelTravelOptionList.size();
           if (size == 1 && action == ROW_ACTION_REMOVE){
               OptionRows(taID, type,ROW_ACTION_ADD);
               this.hotelTravelOptionList.remove(0);
               return;
           }
           for(TETravelOption reader : hotelTravelOptionList){
               //tmp = reader.id + EQUALS + taID;
               if (reader.id == taID){
                   if (action == ROW_ACTION_ADD){
                       if (counter == size){
                           this.hotelTravelOptionList.add(newTETravelOption );
                       }
                       else{
                           this.hotelTravelOptionList.add(counter, newTETravelOption );
                       }
                       break;
                   }
                   if (action == ROW_ACTION_REMOVE){
                       this.hotelTravelOptionList.remove(counter-1);
                       break;
                   }
               }
               counter++;
           }
       
       }
   }
   
   Public Void airfareRows(String taID, String action){
       Integer size = travelPriceList.size();
       Integer counter = 1;
       if (size == 1 && action == ROW_ACTION_REMOVE){
           airfareRows(taID, ROW_ACTION_ADD);
           this.travelPriceList.remove(0);
           return;
       }
       TETravelPriceCtrl newTravelPrice = new TETravelPriceCtrl(generateRandomString(RANDOM_STRING_LEN), this.taCtrl);
       
       for(TETravelPriceCtrl reader : travelPriceList){
           if (reader.id == taID){
               if (action == ROW_ACTION_ADD){
                   if (counter == size){
                       this.travelPriceList.add(newTravelPrice);
                   }
                   else{
                       this.travelPriceList.add(counter, newTravelPrice);
                   }
                   break;
               }
               if (action == ROW_ACTION_REMOVE){
                   this.travelPriceList.remove(counter-1);
                   break;
               }
               if (action == ROW_ACTION_DUPLICATE){
                   TETravelPriceCtrl clonedWrapper = reader.clone();
                   Travel_Price__c clonedTP = reader.travelPrice.clone(false, true, false, false);
                   clonedWrapper.travelPrice = clonedTP;
                   clonedWrapper.Id = generateRandomString(RANDOM_STRING_LEN);
                   
                   if (counter == size){
                       this.travelPriceList.add(clonedWrapper);
                   }
                   else{
                       if (this.travelPriceList[counter].travelPrice.Id != null || this.travelPriceList[counter].travelPrice.Invoice_No__c != null){
                           this.travelPriceList.add(counter, clonedWrapper);
                       }
                       else{
                           this.travelPriceList[counter] = clonedWrapper;
                       }
                   }
                   break;
               }
           }
           counter++;
       }
   }
   Public Void accommodationRows(String taID, String action){
       Integer size = this.taCtrl.travelAccommodationList.size();
       Integer counter = 1;      
       if (size == 1 && action == ROW_ACTION_REMOVE){
           accommodationRows(taID, ROW_ACTION_ADD);
           this.taCtrl.travelAccommodationList.remove(0);
           return;
       } 
       TEAccommodationCtrl newAccommodation = new TEAccommodationCtrl(generateRandomString(RANDOM_STRING_LEN), this.taCtrl);
       for(TEAccommodationCtrl reader : this.taCtrl.travelAccommodationList){
           if(!String.isblank(String.valueof(reader.Accommodation.location__c))){
               this.travelLocationMap.put(reader.Accommodation.location__c, new Travel_Location__c(id=reader.Accommodation.location__c, Name = reader.locationName));
           }
           if (reader.id == taID){
                if (action == ROW_ACTION_ADD){
                   if (counter == size){
                       this.taCtrl.travelAccommodationList.add(newAccommodation);
                   }
                   else{
                       this.taCtrl.travelAccommodationList.add(counter, newAccommodation);
                   }
                   break;
               }               
              if (action == ROW_ACTION_REMOVE){
                   this.taCtrl .travelAccommodationList.remove(counter-1);
                   break;
               }
           }
           counter++;
       }
   }
   
   Public Void cashAdvanceRow(String caId, String action){
       Integer size = cashAdvanceList.size();
       Integer counter = 1;
       if (size == 1 && action == ROW_ACTION_REMOVE){
           cashAdvanceRow(caID, ROW_ACTION_ADD);
           this.cashAdvanceList.remove(0);
           return;
       }
       TECashAdvanceCtrl newCashAdvance = new TECashAdvanceCtrl(generateRandomString(RANDOM_STRING_LEN), this.taCtrl);
       for(TECashAdvanceCtrl reader : cashAdvanceList){
           if (reader.id == caID){
               if (action == ROW_ACTION_ADD){
                   if (counter == size){
                       this.cashAdvanceList.add(newCashAdvance );
                   }
                   else{
                       this.cashAdvanceList.add(counter, newCashAdvance );
                   }
                   break;
               }
               if (action == ROW_ACTION_REMOVE){
                   this.cashAdvanceList.remove(counter-1);
                   break;
               }
           }
           counter++;
       }
       
   }
   
   Public Void accommodationAddRow(){ 
       TEAccommodationCtrl newAccommodation;
       List <TEAccommodationCtrl > newtravelAccommodationList = new List <TEAccommodationCtrl >();
       Integer counter = 0;
       List <Id> travelLocationIdList = new List <Id>();
       String expPolicy = '';
       Map<String, Travel_Location_Allowance__c> locationAllowance = new Map<String, Travel_Location_Allowance__c>();
       for(TEAccommodationCtrl reader : this.taCtrl.travelAccommodationList){
           if(!String.isblank(String.valueof(reader.accommodation.Location__c))){
               this.travelLocationMap.put(reader.Accommodation.location__c, new Travel_Location__c(id=reader.Accommodation.location__c, Name = reader.locationName));
           }
           if (reader.accommodation.accommodation_by__c != null || !String.isblank(String.valueof(reader.accommodation.Location__c))|| reader.CheckinDate != '' || reader.CheckoutDate != '' || reader.accommodation.remarks__c != null ){
               newtravelAccommodationList.add(reader);
           }
       }
       for(TETravelDetail reader : this.travelDetailList){           
           if(( !reader.accommodationFlage)){
               travelLocationIdList.add(reader.travelDetail.Destination__c);
               if (reader.travelDetail.Shuttle_To__c != null && siteMap.containskey(reader.travelDetail.Shuttle_To__c) && tdRecordTypeMap.get(reader.travelDetail.recordTypeId) == SHUTTLE_TRAVEL_DETAIL_TYPE){
                   //Only one element in the loop
                   for (travel_location__c tl : siteMap.get(reader.travelDetail.Shuttle_To__c).travel_locations__r ){
                       travelLocationIdList.add(tl.id);                           
                   }
               }
           }
           
       }
       for (Employee_Administrator__c  reader : [select employee__r.Expense_Policy__c from Employee_Administrator__c where id = :this.travelApplication.on_behalf_of__c]){
           expPolicy = reader.employee__r.Expense_Policy__c;
       }
       for(Travel_Location_Allowance__c reader :[
           select id, Daily_Maximum_Hotel_Cost__c, Maximum_of_Hotel_Allowance_Currency__c, Expense_Policy__r.Hotel_Allowance_Currency__c, Travel_Location__c,
           Expense_Policy__r.Hotel_Allowance_Currency__r.Name
           from Travel_Location_Allowance__c
           where Travel_Location__c =  :travelLocationIdList
           and Expense_Policy__c = :expPolicy 
           and Travel_Location__c != null
       ]){
           locationAllowance.put(reader.Travel_Location__c, reader);
       }
       for(TETravelDetail reader : this.travelDetailList){
           if(  ( !reader.accommodationFlage && ( !String.isBlank(reader.TravelDetail.Destination__c) || reader.travelDetail.Shuttle_To__c != null) && reader.DepartureDateTime != '')){
               counter += 1;
               newAccommodation = new TEAccommodationCtrl(generateRandomString(RANDOM_STRING_LEN), this.taCtrl);
               reader.accommodationFlage = true;
               
               if(this.tactrl.loactionSitMap.containsKey(reader.travelDetail.Destination__c)){
                   newAccommodation.accommodation.Tech_Site_and_Arrage_By__c = this.tactrl.loactionSitMap.get(reader.travelDetail.Destination__c).site__c + '_' + TEConstant.ACCOMMODATION_BY_SITE_ADMIN;
                   newAccommodation.accommodation.Accommodation_By__c = TEConstant.ACCOMMODATION_BY_SITE_ADMIN; 
               }
               newAccommodation.accommodation.Location__c = reader.travelDetail.Destination__c;
               newAccommodation.locationName = reader.DestinationName;
               if (!String.isBlank(reader.TravelDetail.Destination__c)){
                   this.travelLocationMap.put(reader.TravelDetail.Destination__c, new Travel_Location__c(id=reader.TravelDetail.Destination__c, Name = reader.DestinationName));
               }
               if ( String.isblank(reader.siteToVisit) && tdRecordTypeMap.get(reader.travelDetail.recordTypeId) == AIR_TRAVEL_DETAIL_TYPE){
                   newAccommodation.accommodation.Accommodation_By__c = TEConstant.ACCOMMODATION_BY_TRAVEL_AGENCY;
                   newAccommodation.accommodation.Tech_Site_and_Arrage_By__c = '_' + TEConstant.ACCOMMODATION_BY_TRAVEL_AGENCY;
               }
               if ( String.isblank(reader.siteToVisit) && tdRecordTypeMap.get(reader.travelDetail.recordTypeId) == SURFACE_TRAVEL_DETAIL_TYPE ){
                   newAccommodation.accommodation.Accommodation_By__c = TEConstant.ACCOMMODATION_BY_TRAVEL_AGENCY;
                   newAccommodation.accommodation.Tech_Site_and_Arrage_By__c = '_' + TEConstant.ACCOMMODATION_BY_TRAVEL_AGENCY;
               }
               if ( !String.isblank(reader.siteToVisit) && tdRecordTypeMap.get(reader.travelDetail.recordTypeId) == SHUTTLE_TRAVEL_DETAIL_TYPE){
                  if ( reader.DepartureDateTime == reader.ReturnDateTime){
                      counter -= 1;
                      continue;
                  }                   
                  //Only one element in the loop
                  for (travel_location__c tl : siteMap.get(reader.travelDetail.Shuttle_To__c).travel_locations__r ){
                       newAccommodation.accommodation.Location__c = tl.id;
                       newAccommodation.locationName = tl.name;
                       this.travelLocationMap.put(tl.id, new Travel_Location__c(id=tl.id, Name = tl.name));
                       newAccommodation.accommodation.Accommodation_By__c = TEConstant.ACCOMMODATION_BY_SITE_ADMIN; 
                       newAccommodation.accommodation.Tech_Site_and_Arrage_By__c = reader.travelDetail.Shuttle_To__c + '_' + TEConstant.ACCOMMODATION_BY_SITE_ADMIN;
                  }
               }
               newAccommodation.CheckinDate = reader.DepartureDateTime.split(WHITESPACE)[0];
               newAccommodation.CheckOutDate = reader.ReturnDateTime.split(WHITESPACE)[0];
               if (locationAllowance.containsKey(newAccommodation.accommodation.Location__c)){
                   newAccommodation.accommodation.Budget_per_Night__c = locationAllowance.get(newAccommodation.accommodation.Location__c).Daily_Maximum_Hotel_Cost__c;
                   newAccommodation.accommodation.Currency__c = locationAllowance.get(newAccommodation.accommodation.Location__c).Expense_Policy__r.Hotel_Allowance_Currency__c;
                   newAccommodation.accommodation.Currency__r = locationAllowance.get(newAccommodation.accommodation.Location__c).Expense_Policy__r.Hotel_Allowance_Currency__r;
               }
               newtravelAccommodationList.add(newAccommodation);               
           }
       }
       
       if ( counter > 0){
           counter = newtravelAccommodationList.size();
           newAccommodation = newtravelAccommodationList.get(counter-1);
           if ( newAccommodation.accommodation.id == null &&  (newAccommodation.checkoutDate == null || newAccommodation.checkoutDate == '')){
               newtravelAccommodationList.remove(counter-1);
           }
       }
       
       this.taCtrl.travelAccommodationList = newtravelAccommodationList;
       if(this.taCtrl.travelAccommodationList.isempty()){
            this.taCtrl.travelAccommodationList.add(new TEAccommodationCtrl(generateRandomString(RANDOM_STRING_LEN), this.taCtrl));
       }
       
   }
    
   Public Void travelDetailRows(String tdID, String action){
       Integer size = travelDetailList.size();
       Integer counter = 1;
       if (size == 1 && action == ROW_ACTION_REMOVE){
           travelDetailRows(tdID, ROW_ACTION_ADD);
           this.travelDetailList.remove(0);
           return;
       }
       TETravelDetail newTravelDetail = new TETravelDetail(generateRandomString(RANDOM_STRING_LEN), this.taCtrl);
       for(TETravelDetail reader : travelDetailList){
           reader.siteSelection();
           if ( !String.isBlank(reader.TravelDetail.Origin_Site__c)){
               this.travelLocationMap.put(reader.TravelDetail.Origin_Site__c, new Travel_Location__c(id=reader.TravelDetail.Origin_Site__c, Name = reader.OriginSiteName));
           }
           if ( !String.isBlank(reader.TravelDetail.Destination__c)){
               this.travelLocationMap.put(reader.TravelDetail.Destination__c, new Travel_Location__c(id=reader.TravelDetail.Destination__c, Name = reader.DestinationName));
           }
       }
       for(TETravelDetail reader : travelDetailList){
           if (reader.id == tdID){
              if (action == ROW_ACTION_ADD){
                   if (counter == size){
                       this.travelDetailList.add(newTravelDetail);
                   }
                   else{
                       this.travelDetailList.add(counter, newTravelDetail);
                   }
                   break;
              }
              if (action == ROW_ACTION_REMOVE){
                   this.travelDetailList.remove(counter-1);
                   break;
               }
           }
           counter++;
       }
   }
   
   private String generateRandomString(Integer len) {
       final String chars = RANDOM_STRING ;
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
   }
    
}