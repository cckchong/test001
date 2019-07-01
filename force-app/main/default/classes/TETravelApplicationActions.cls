public without sharing class TETravelApplicationActions{
    Public Static String SLASH = '/';
    Public Static String TRAVEL_DETAIL_API_NAME = Travel_Detail__c.sObjectType.getDescribe().getName();
    Public Static String TRAVEL_OPTION_API_NAME = TravelOption__c.sObjectType.getDescribe().getName();
    Public Static String HOTEL_OPTION_TYPE = 'Hotel';    
    Public Static String AIR_OPTION_TYPE = 'Air';
    Public Static String AIR_TRAVEL_DETAIL_TYPE = 'Air';
    Public Static String SURFACE_TRAVEL_DETAIL_TYPE = 'Surface';
    Public Static String SHUTTLE_TRAVEL_DETAIL_TYPE = 'Shuttle';
    Public Static String travelApplicationURLParameter= 'taid';
    Public Static String URL_PARAMETER_LABEL_TAB = 'tabs-';
    Public Static String OPEN_BRACKET =  '[';
    Public Static String CLOSE_BRACKET =  ']';
    Public Static String WHITESPACE= ' ';
    Public Static String SINGLECOMMA = ',';
    Public Static String DT_FORMAT_hhmma = 'hh:mm a';
    Public Static String DOUBLECOMMA = ',,';
    Public Static String SEMICOLON = ';';
    Public Static String CARRIAGE_RETURN = '\r';
    Public Static String LINEFEED = '\n';
    Public Static String CARRIAGE_RETURN_LINEFEED = '\r\n';
    Public List <RecordType> recordTypeList{get;set;}
    //Public List <TEAccommodationCtrl> travelAccommodationList{get;set;}
    Public List <TETravelDetail> travelDetailList{get;set;}
    Public List <TETravelPriceCtrl> travelPriceList{get;set;} 
    Public List <TETravelItineraryCtrl> travelItineraryList{get;set;}
    Public List <TECashAdvanceCtrl> cashAdvanceList{get;set;}
    Public List <TETravelOption> airTravelOptionList{get;set;}
    Public List <TETravelOption> hotelTravelOptionList{get;set;}
    Public Boolean isTravelAgent{get;set;}
    Public Boolean isAdmin{get;set;}
    Public Boolean isMySelf{get;set;}
    Public Boolean selectedOption1{get;set;}
    Public Boolean selectedOption2{get;set;}
    Public Boolean selectedOption3{get;set;}
    //Public String deadline{get;set;}
    Public String currURL{get;set;} 
    Public String selectedTab{get;set;}
    Public String emailList{get;set;}
    Public String taId{get;set;}
    Public Map <id, user> travelAgentMap{get;set;}
    Public Map <id, Travel_Location__c> travelLocationMap{get;set;}    
    Public Travel_Application__c travelApplication{get;set;}
    Public TETravelApplicationCtrl taCtrl = null;
    Public String tmp {get;set;}
    Public TETravelApplicationActions(TETravelApplicationCtrl taCtrl){
        this.taCtrl = taCtrl;
        this.recordTypeList = taCtrl.recordTypeList;
        //this.travelAccommodationList = taCtrl.travelAccommodationList;
        this.travelDetailList = taCtrl.travelDetailList;
        this.travelPriceList = taCtrl.travelPriceList;
        this.travelItineraryList = taCtrl.travelItineraryList;
        this.cashAdvanceList = taCtrl.cashAdvanceList;
        this.airTravelOptionList = taCtrl.airTravelOptionList;
        this.hotelTravelOptionList = taCtrl.hotelTravelOptionList;
        this.isTravelAgent = taCtrl.isTravelAgent;
        this.isAdmin = taCtrl.isAdmin;
        this.isMySelf = taCtrl.isMySelf;
        this.selectedOption1 = taCtrl.selectedOption1;
        this.selectedOption2 = taCtrl.selectedOption2;
        this.selectedOption3 = taCtrl.selectedOption3;
        //this.deadline = taCtrl.deadline;
        this.currURL = taCtrl.currURL;
        this.selectedTab = taCtrl.selectedTab;
        this.emailList = taCtrl.emailList;
        this.travelAgentMap = taCtrl.travelAgentMap;
        this.travelApplication = taCtrl.travelApplication;
        this.travelLocationMap = taCtrl.travelLocationMap;
        this.taId = taCtrl.taId;
    }
    
    Public PageReference cancelAction(){
       PageReference prf;
       if (this.travelApplication.id != null){
           if (this.isTravelAgent){
               prf = new PageReference(SLASH + 'travel' + SLASH + this.travelApplication.id);
           }
           else{
               prf = new PageReference(SLASH + this.travelApplication.id);
           }
       }
       else{
           String preFix = '';
           Schema.DescribeSObjectResult r = Travel_Application__c.sObjectType.getDescribe();
           preFix  = r.getKeyPrefix();
           
           if (this.isTravelAgent){
               prf = new PageReference(SLASH + 'travel' + SLASH + prefix + SLASH + 'o');
           }
           else{
               prf = new PageReference(SLASH + prefix + SLASH + 'o');
           }
        }
       return prf;
   }
   
   Public PageReference submitAction(){
       List <Accommodation__c> tmpAccommodationList = new List <Accommodation__c>();
       List <Travel_Detail__c> tmpTravelDetailList = new List <Travel_Detail__c>();
       List <TravelOption__c> tmpTravelOptionList = new List <TravelOption__c>();
       List <Cash_Advance__c> tmpcashAdvanceList = new List <Cash_Advance__c>();
       Map <String, String> tdRecordType = new Map <String, String>();
       Map <String, String> opRecordType = new Map <String, String>();
       Travel_Application__c  tmptravelApplication = null;
       Boolean setIssueEmail = false;
       TravelOption__c travelopt = null;
       PageReference prf = null;
       Boolean allConfirm = true;
       for (RecordType rtreader : recordTypeList){
           if(rtreader.SobjectType == TRAVEL_DETAIL_API_NAME){
               tdRecordType.put(rtreader.Name, rtreader.id);
           }
           if(rtreader.SobjectType == TRAVEL_OPTION_API_NAME ){
               opRecordType.put(rtreader.Name, rtreader.id);
           }
       }
       prf = saveAction();
       if (prf == null){
           return prf;
       }
       prf  = new PageReference(SLASH + this.travelApplication.id);
       if (this.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED  ){
           tmptravelApplication = new Travel_Application__c (
               id = this.travelApplication.id, 
               status__c = TEConstant.STATUS_PENDING
           );
           
           for (TravelOption__c reader : this.travelApplication.TravelOptions__r){
               travelopt = new TravelOption__c (
                                                Status__c = TEConstant.STATUS_PENDING_ARRANGEMENT,
                                                id = reader.id
                                               );
              tmpTravelOptionList.add(travelopt);
           }
           for (TEAccommodationCtrl reader : this.taCtrl.travelAccommodationList){
               if (reader.accommodation.Accommodation_By__c == TEConstant.ACCOMMODATION_BY_TRAVEL_AGENCY){
                   if(!reader.accommodation.Is_Exist__c){
                       travelopt = new TravelOption__c (
                                                    Destination__c = reader.accommodation.Location__c, 
                                                    Check_in_Date__c = reader.accommodation.Check_in_Date__c,
                                                    Check_out_Date__c = reader.accommodation.Check_out_Date__c,
                                                    recordTypeID = opRecordType.get(HOTEL_OPTION_TYPE ),
                                                    Status__c = TEConstant.STATUS_PENDING_ARRANGEMENT,
                                                    Travel_Application__c = this.travelApplication.id,
                                                    Budget_Currency__c = reader.accommodation.Currency__c,
                                                    Budget_per_Night__c = reader.accommodation.Budget_per_Night__c
                                                   );
                       tmpTravelOptionList.add(travelopt);
                   }
                   tmpAccommodationList.add(new Accommodation__c (id = reader.accommodation.id, status__c = TEConstant.STATUS_PENDING_ARRANGEMENT, Is_Exist__c = true));
               }
               else if(reader.accommodation.Accommodation_By__c != null){
                   tmpAccommodationList.add(new Accommodation__c (id = reader.accommodation.id, status__c = TEConstant.STATUS_PENDING_RESERVATION, Is_Exist__c = true));
               }
              
           }
           for (TETravelDetail reader : travelDetailList){
               if(tdRecordType.get(AIR_TRAVEL_DETAIL_TYPE) == reader.travelDetail.recordTypeID){
                   if(!reader.travelDetail.Is_Exist__c){
                       travelopt = new TravelOption__c (From__c = reader.travelDetail.Origin_Site__c, 
                                                    To__c = reader.travelDetail.Destination__c, 
                                                    Departure_Date__c = reader.travelDetail.Preferred_Departure_dt__c.date(),
                                                    recordTypeID = opRecordType.get(AIR_OPTION_TYPE),
                                                    Status__c = TEConstant.STATUS_PENDING_ARRANGEMENT,
                                                    Travel_Application__c = this.travelApplication.id,
                                                    Travel_Detail__c = reader.travelDetail.id
                                                   );
                       tmpTravelOptionList.add(travelopt);
                       if ( reader.travelDetail.Preferred_Return_dt__c != null){
                           travelopt = new TravelOption__c (To__c = reader.travelDetail.Origin_Site__c, 
                                                        From__c = reader.travelDetail.Destination__c, 
                                                        Departure_Date__c = reader.travelDetail.Preferred_Return_dt__c.date(),
                                                        recordTypeID = opRecordType.get(AIR_OPTION_TYPE),
                                                        Status__c = TEConstant.STATUS_PENDING_ARRANGEMENT,
                                                        Travel_Application__c = this.travelApplication.id,
                                                        Travel_Detail__c = reader.travelDetail.id
                                                       );
                           tmpTravelOptionList.add(travelopt);
                       }
                   }
                   tmpTravelDetailList.add(new Travel_Detail__c (id = reader.travelDetail.id, status__c = TEConstant.STATUS_PENDING_ARRANGEMENT, Is_Exist__c = true));
               }
               else if(reader.travelDetail.recordTypeID != null){
                   if(reader.travelDetail.Self_Arragnment__c){
                       tmpTravelDetailList.add(new Travel_Detail__c (id = reader.travelDetail.id, status__c = TEConstant.STATUS_CONFIRMED, Is_Exist__c = true));
                   }
                   else{
                      tmpTravelDetailList.add(new Travel_Detail__c (id = reader.travelDetail.id, status__c = TEConstant.STATUS_PENDING_RESERVATION, Is_Exist__c = true));
                   }
               }
           }
           for(TECashAdvanceCtrl reader : cashAdvanceList){
              if (this.isMySelf && reader.cashadvance.status__c == TEConstant.STATUS_DRAFT && reader.cashadvance.id != null){
                  tmpcashAdvanceList.add(new Cash_Advance__c(id = reader.cashadvance.id, status__c = TEConstant.STATUS_PENDING));
              }
           }
       }
       if (this.travelApplication.status__c == TEConstant.STATUS_PENDING){
          for (TETravelDetail reader : travelDetailList){             
              if(reader.travelDetail.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION  && this.isMySelf){
                  tmpTravelDetailList.add(new Travel_Detail__c (id = reader.TravelDetail.id, status__c = TEConstant.STATUS_CONFIRMED));
              }
              if(tdRecordType.get(AIR_TRAVEL_DETAIL_TYPE) == reader.travelDetail.recordTypeID && reader.travelDetail.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT && this.isTravelAgent){
                  tmpTravelDetailList.add(new Travel_Detail__c (id = reader.TravelDetail.id, status__c = TEConstant.STATUS_PENDING_SELECTION));
              }
              if(tdRecordType.get(AIR_TRAVEL_DETAIL_TYPE) == reader.travelDetail.recordTypeID && reader.travelDetail.status__c == TEConstant.STATUS_PENDING_SELECTION && this.isMySelf){
                  tmpTravelDetailList.add(new Travel_Detail__c (id = reader.TravelDetail.id, status__c = TEConstant.STATUS_PENDING_RESERVATION));
              }
              if(tdRecordType.get(AIR_TRAVEL_DETAIL_TYPE) == reader.travelDetail.recordTypeID && reader.travelDetail.status__c == TEConstant.STATUS_PENDING_RESERVATION && this.isTravelAgent){
                  tmpTravelDetailList.add(new Travel_Detail__c (id = reader.TravelDetail.id, status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ));
              }
              if(tdRecordType.get(SURFACE_TRAVEL_DETAIL_TYPE) == reader.travelDetail.recordTypeID && reader.travelDetail.status__c == TEConstant.STATUS_PENDING_RESERVATION && this.isAdmin){
                  if(reader.getadminArrange()){
                      tmpTravelDetailList.add(new Travel_Detail__c (id = reader.TravelDetail.id, status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ));
                  }
              }
              if(tdRecordType.get(SHUTTLE_TRAVEL_DETAIL_TYPE ) == reader.travelDetail.recordTypeID && reader.travelDetail.status__c == TEConstant.STATUS_PENDING_RESERVATION && this.isAdmin){
                  if(reader.getadminArrange()){
                      tmpTravelDetailList.add(new Travel_Detail__c (id = reader.TravelDetail.id, status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ));
                  }
              }
              
          }
          for (TEAccommodationCtrl reader : this.taCtrl.travelAccommodationList){
              if (reader.accommodation.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION  && this.isMySelf){
                  tmpAccommodationList.add(new Accommodation__c (id = reader.accommodation.id, status__c = TEConstant.STATUS_CONFIRMED));
              }
              if (reader.accommodation.Accommodation_By__c == TEConstant.ACCOMMODATION_BY_TRAVEL_AGENCY && reader.accommodation.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT && this.isTravelAgent){
                  tmpAccommodationList.add(new Accommodation__c (id = reader.accommodation.id, status__c = TEConstant.STATUS_PENDING_SELECTION));
              }
              if (reader.accommodation.Accommodation_By__c == TEConstant.ACCOMMODATION_BY_TRAVEL_AGENCY && reader.accommodation.status__c == TEConstant.STATUS_PENDING_SELECTION && this.isMySelf){
                  tmpAccommodationList.add(new Accommodation__c (id = reader.accommodation.id, status__c = TEConstant.STATUS_PENDING_RESERVATION));
              }
              if (reader.accommodation.Accommodation_By__c == TEConstant.ACCOMMODATION_BY_TRAVEL_AGENCY && reader.accommodation.status__c == TEConstant.STATUS_PENDING_RESERVATION && this.isTravelAgent){
                  tmpAccommodationList.add(new Accommodation__c (id = reader.accommodation.id, status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ));
              }
              if(reader.accommodation.Accommodation_By__c == TEConstant.ACCOMMODATION_BY_SITE_ADMIN && reader.accommodation.status__c == TEConstant.STATUS_PENDING_RESERVATION && this.isAdmin && reader.getadminArrange()){
                  tmpAccommodationList.add(new Accommodation__c(id = reader.accommodation.id, status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ));
              }
          }
          for(TETravelOption reader : airTravelOptionList){
             if (reader.TravelOption.id == null){
                  continue;
             }
             if (this.isMySelf && reader.TravelOption.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ){
                 tmpTravelOptionList.add(new TravelOption__c(id = reader.TravelOption.id, status__c = TEConstant.STATUS_CONFIRMED ));
                 setIssueEmail = true;
                 tmptravelApplication = new Travel_Application__c (id = this.travelApplication.id, Tech_Send_Issue_Air_Ticket_Email__c = 1);
             }
             if (this.isTravelAgent && reader.TravelOption.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT){
                 tmpTravelOptionList.add(new TravelOption__c(id = reader.TravelOption.id, status__c = TEConstant.STATUS_PENDING_SELECTION ));
             }
             if (this.isMySelf && reader.TravelOption.status__c == TEConstant.STATUS_PENDING_SELECTION){
                 tmpTravelOptionList.add(new TravelOption__c(id = reader.TravelOption.id, status__c = TEConstant.STATUS_PENDING_RESERVATION ));
             }
             if (this.isTravelAgent && reader.TravelOption.status__c == TEConstant.STATUS_PENDING_RESERVATION){
                 tmpTravelOptionList.add(new TravelOption__c(id = reader.TravelOption.id, status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION  ));
             }
             
          }
          for(TETravelOption reader : hotelTravelOptionList){
              if (reader.TravelOption.id == null){
                  continue;
              }
              if (this.isMySelf && reader.TravelOption.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ){
                  tmpTravelOptionList.add(new TravelOption__c(id = reader.TravelOption.id, status__c = TEConstant.STATUS_CONFIRMED ));
                  setIssueEmail = true;
                  tmptravelApplication = new Travel_Application__c (id = this.travelApplication.id, Tech_Send_Issue_Air_Ticket_Email__c = 1);
              }
              if (this.isTravelAgent && reader.TravelOption.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT){
                  tmpTravelOptionList.add(new TravelOption__c(id = reader.TravelOption.id, status__c = TEConstant.STATUS_PENDING_SELECTION ));
              }
              if (this.isMySelf && reader.TravelOption.status__c == TEConstant.STATUS_PENDING_SELECTION){
                  tmpTravelOptionList.add(new TravelOption__c(id = reader.TravelOption.id, status__c = TEConstant.STATUS_PENDING_RESERVATION ));
              }
              if (this.isTravelAgent && reader.TravelOption.status__c == TEConstant.STATUS_PENDING_RESERVATION){
                  tmpTravelOptionList.add(new TravelOption__c(id = reader.TravelOption.id, status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION  ));
              }
          }  
       }
       /*Commented by TAL (Twinkle LI) @20170719 for fixing the issue that:
         status of Application is not updated to 'Confirmed' after Accommodation is cancelled 
         when all other Travel detail is Confirmed and Accommodations are Confirmed/Cancelled.*/   
       /*if (tmpAccommodationList.size() == 0 && tmpTravelDetailList.size() == 0 ){
            return prf;
       }*/
       
       if (!tmpTravelOptionList.isempty()){
           upsert tmpTravelOptionList; 
       }
       if (!tmpAccommodationList.isempty()){
           upsert tmpAccommodationList;
       }
       if (!tmpTravelDetailList.isempty()){
           upsert tmpTravelDetailList;
       }
       if (!tmpcashAdvanceList.isempty()){
            upsert tmpcashAdvanceList; 
       }
       if (tmptravelApplication != null && !isTravelAgent){
           upsert tmptravelApplication;
       }
       
       tmpcashAdvanceList = new List <Cash_Advance__c>();
       if (isMySelf){
           tmptravelApplication = [select id, status__c, Agent_Travel_Detail_Count__c,
                                   (select id, status__c from travel_Details__r where status__c !=: TEConstant.STATUS_CONFIRMED),
                                   (select id, status__c from Accommodations__r where status__c !=: TEConstant.STATUS_CONFIRMED and status__c !=: TEConstant.STATUS_CANCELLED),
                                   (select id, status__c from TravelOptions__r where status__c !=: TEConstant.STATUS_CONFIRMED and travel_Application__r.Agent_Travel_Detail_Count__c > 0),
                                   (select id, status__c from Cash_Advances__r )//where status__c = TEConstant.STATUS_PENDING_APPROVAL )
                                   from travel_Application__c where id =:this.travelApplication.id];
           
           if( tmptravelApplication.travel_Details__r.size() == 0 &&
               tmptravelApplication.Accommodations__r.size() == 0 &&
               tmptravelApplication.TravelOptions__r.size() == 0 &&
               tmptravelApplication.status__c == TEConstant.STATUS_PENDING
             ){
                 tmptravelApplication = new Travel_Application__c (id = this.travelApplication.id, status__c = TEConstant.STATUS_CONFIRMED);
                 if(!setIssueEmail){
                     tmptravelApplication.Tech_Send_Issue_Air_Ticket_Email__c = 2;
                 }
                 for (Cash_Advance__c reader : [select id, status__c from cash_advance__c where status__c =: TEConstant.STATUS_PENDING and travel_application__c = :this.travelApplication.id] ){
                     tmpcashAdvanceList.add(new cash_advance__c (id = reader.id, status__c = TEConstant.STATUS_OPEN));
                 }
                 upsert tmptravelApplication;
                 if (!tmpcashAdvanceList.isempty()){
                        upsert tmpcashAdvanceList; 
                 } 
           }
       }
       return prf;
   }
   Public PageReference RearrangeAction(){
       PageReference prf = null;
       List <travel_detail__c> tdList = new List <travel_detail__c>();
       List <Accommodation__c> accList = new List <Accommodation__c>();
       List <TravelOption__c> toList = new List <TravelOption__c>();
       Travel_Application__c ta = this.travelApplication;
       Travel_Application__c newTA = null;
       for(travel_Application__c reader : [select id,
           (select id, status__c from travel_details__r where Record_Type_Name__c = :TEConstant.TRAVEL_DETAIL_RECORD_TYPE_AIR  and status__c in (:TEConstant.STATUS_PENDING_ARRANGEMENT, :TEConstant.STATUS_PENDING_SELECTION, :TEConstant.STATUS_PENDING_RESERVATION, :TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION ) ),
           (select id, status__c from Accommodations__r where Accommodation_By__c = :TEConstant.ACCOMMODATION_BY_TRAVEL_AGENCY and status__c in (:TEConstant.STATUS_PENDING_ARRANGEMENT, :TEConstant.STATUS_PENDING_SELECTION, :TEConstant.STATUS_PENDING_RESERVATION, :TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION) ),
           (select id, status__c from TravelOptions__r where status__c in (:TEConstant.STATUS_PENDING_ARRANGEMENT, :TEConstant.STATUS_PENDING_SELECTION, :TEConstant.STATUS_PENDING_RESERVATION, :TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION))
           from travel_Application__c 
           where id = :ta.id 
           and status__c = :TEConstant.STATUS_PENDING 
       ]){
           newTA = new Travel_Application__c (id = ta.id, Deadline__c = null, Selected_Option_1__c = false, Selected_Option_2__c = false, Selected_Option_3__c = false);
           for(travel_detail__c tdreader :  reader.travel_details__r){
               tdList.add(new travel_detail__c (id = tdreader.id, status__c = TEConstant.STATUS_PENDING_ARRANGEMENT) );
           }
           for(Accommodation__c accreader :  reader.Accommodations__r){
               accList.add(new Accommodation__c (id = accreader.id, status__c = TEConstant.STATUS_PENDING_ARRANGEMENT) );
           }
           for(TravelOption__c toreader :  reader.TravelOptions__r){
               toList.add(new TravelOption__c (id = toreader.id, status__c = TEConstant.STATUS_PENDING_ARRANGEMENT, Selected_Option1__c = null, Selected_Option2__c = null, Selected_Option3__c = null) );
           }
       }
       if(!tdList.isEmpty() || !accList.isEmpty() || !toList.isEmpty()){
           upsert newTA;
       }
       if(!tdList.isEmpty()){
           upsert tdList;
       }
       if(!accList.isEmpty()){
           upsert accList;
       }
       if(!toList.isEmpty()){
           upsert toList;
       }
       prf = new PageReference(currURL);
       prf.getParameters().put(travelApplicationURLParameter, ta.id);
       prf.setAnchor(URL_PARAMETER_LABEL_TAB + selectedTab);
       return prf;
   }

   Public PageReference saveTravelPriceAction(){
     List <Travel_Price__c> tmpTravelPriceList = new List <Travel_Price__c>();
     Boolean optAllConfirm = false;

      /*Add by DTT Support Team*/  
      if(this.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED)
      {
        optAllConfirm=false;
      }
      else
      {
        if ((airtravelOptionList!=null && !airtravelOptionList.isEmpty()) || (hotelTravelOptionList!=null && !hotelTravelOptionList.isEmpty()))
        {
          optAllConfirm=true;
        }
      } 

      List <TETravelPriceCtrl> tempList=new List <TETravelPriceCtrl>();

      for(TETravelPriceCtrl reader : travelPriceList){
               if((reader.travelPrice.Amount__c == null || reader.travelPrice.Amount__c ==0) 
                        && (reader.travelPrice.Invoice_No__c == null || reader.travelPrice.Invoice_No__c == '') 
                        && (reader.invoiceDate=='' || reader.invoiceDate==null ))
                {
                   continue;
                }
               else
               {
                if(reader.travelPrice.Amount__c ==0)
                {
                  reader.travelPrice.Amount__c=null;
                }
                tempList.add(reader);
               }
        }
      travelPriceList.clear();
      travelPriceList.addAll(tempList);

      /*Add by DTT Support Team*/
       List <TETravelPriceCtrl> myTempList=new List <TETravelPriceCtrl>();
       if(optAllConfirm){
           for(TETravelPriceCtrl reader : travelPriceList){
               if(this.istravelAgent && 
                   (reader.travelPrice.Type__c != null 
                   || (reader.travelPrice.Amount__c != null && reader.travelPrice.Amount__c!=0)
                   || reader.travelPrice.Currency__c != null 
                   || (reader.invoiceDate != '' && reader.invoiceDate != null) 
                   || (reader.travelPrice.Invoice_No__c != null))){
                   reader.checkreq = true;
                   reader.travelPrice.invoice_date__c = null;
                   if (reader.invoiceDate != '' && reader.invoiceDate != null){
                       reader.travelPrice.invoice_date__c = this.taCtrl.getDateTimeObj(reader.invoiceDate).date();
                   }
                   tmpTravelPriceList.add(reader.travelPrice);
               }
           }
       }
      if (!TETravelApplicationValidationsController.checkPrice(TravelPriceList)){
           return null;
      }


      if (!tmpTravelPriceList.isEmpty()){
               for(Travel_Price__c reder : tmpTravelPriceList){
                   if (reder.id == null){
                       reder.Travel_Application__c = this.travelApplication.id;
                   }
               }
               upsert tmpTravelPriceList;
      }

      PageReference prf = new PageReference(currURL);
      if ( this.taId == null){
         prf.getParameters().put(travelApplicationURLParameter, this.travelApplication.id);          
      }
      prf.setAnchor(URL_PARAMETER_LABEL_TAB + selectedTab);
      return prf;
   }


   Public PageReference saveAction(){
       List <Travel_Detail__c > tmptravelDetailList = new List <Travel_Detail__c >();
       List <Accommodation__c> tmpAccommodationList = new List <Accommodation__c>();
       List <TravelOption__c> tmpTravelOptionList = new List <TravelOption__c>();
       List <Travel_Price__c> tmpTravelPriceList = new List <Travel_Price__c>();
       List <Journey__c > tmpTravelItineraryList = new List <Journey__c >();
       List <Cash_Advance__c > tmpCashAdvanceList = new List <Cash_Advance__c  >();
       Travel_Application__c ta = null;
       DateTime dt = null;
       String[] strDTDivided = null;
       String[] strDate = null;
       String[] strTime = null;
       String str = '';
       String tmpEmailList = this.taCtrl.emailList;
       String [] splitEmailList;
       Integer emailListSize = 0;
       Boolean isCorrect = true;
       PageReference prf = null;
       if (!isTravelAgent && (this.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED || this.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.travelApplication.status__c == TEConstant.STATUS_PENDING)){
           if (this.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED || this.travelApplication.status__c == TEConstant.STATUS_DRAFT){
               if (tmpEmailList == null){
                   tmpEmailList = '';
               }
               tmpEmailList = tmpEmailList.replace(OPEN_BRACKET,'');
               tmpEmailList = tmpEmailList.replace(CLOSE_BRACKET,'');
               tmpEmailList = tmpEmailList.replaceAll(WHITESPACE,'');
               
               if(isMyself){
                   splitEmailList = tmpEmailList.split(SINGLECOMMA) ;
                   emailListSize = splitEmailList.size();              
                   this.travelApplication.Copy_to_1__c = null;
                   this.travelApplication.Copy_to_2__c = null;
                   this.travelApplication.Copy_to_3__c = null;
                   this.travelApplication.Copy_to_4__c = null;
                   this.travelApplication.Copy_to_5__c = null;
                   this.travelApplication.Copy_to_6__c = null;
                   this.travelApplication.Copy_to_7__c = null;
                   this.travelApplication.Copy_to_8__c = null;
                   this.travelApplication.Copy_to_9__c = null;
                   this.travelApplication.Copy_to_10__c = null;
                   
                   if ( emailListSize > 0 && tmpEmailList.length() > 0){
                       this.travelApplication.Copy_to_1__c = splitEmailList[0];
                   }               
                   if ( emailListSize > 1){
                       this.travelApplication.Copy_to_2__c = splitEmailList[1];
                   }
                   if ( emailListSize > 2){
                       this.travelApplication.Copy_to_3__c = splitEmailList[2];
                   }
                   if ( emailListSize > 3){
                       this.travelApplication.Copy_to_4__c = splitEmailList[3];
                   }
                   if ( emailListSize > 4){
                       this.travelApplication.Copy_to_5__c = splitEmailList[4];
                   }
                   if ( emailListSize > 5){
                       this.travelApplication.Copy_to_6__c = splitEmailList[5];
                   }
                   if ( emailListSize > 6){
                       this.travelApplication.Copy_to_7__c = splitEmailList[6];
                   }
                   if ( emailListSize > 7){
                       this.travelApplication.Copy_to_8__c = splitEmailList[7];
                   }
                   if ( emailListSize > 8){
                       this.travelApplication.Copy_to_9__c = splitEmailList[8];
                   }
                   if ( emailListSize > 9){
                       this.travelApplication.Copy_to_10__c = splitEmailList[9];
                   }
               }
               this.travelApplication.Tech_Travel_Agent_Email__c = null;
               if(this.travelAgentMap.containskey(this.travelApplication.Travel_Agency__c)){
                   this.travelApplication.Tech_Travel_Agent_Email__c = travelAgentMap.get(this.travelApplication.Travel_Agency__c).email;
               }
           }
           ta = this.travelApplication;
           this.SelectedOption1 = this.travelApplication.Selected_Option_1__c;
           this.SelectedOption2 = this.travelApplication.Selected_Option_2__c;
           this.SelectedOption3 = this.travelApplication.Selected_Option_3__c;
       }
       for (TETravelOption reader : airtravelOptionList){
           if (this.isTravelAgent && !this.taCtrl.getissave() && ta == null){
               ta = new Travel_Application__c(id = this.travelApplication.id,
                                              Option_Estimated_Price1__c = this.travelApplication.Option_Estimated_Price1__c,
                                              Option_Estimated_Price2__c = this.travelApplication.Option_Estimated_Price2__c,
                                              Option_Estimated_Price3__c = this.travelApplication.Option_Estimated_Price3__c,
                                              Option_Estimated_Currency__c = this.travelApplication.Option_Estimated_Currency__c,
                                              Option_Estimated_Currency2__c = this.travelApplication.Option_Estimated_Currency2__c,
                                              Option_Estimated_Currency3__c = this.travelApplication.Option_Estimated_Currency3__c
                                             );
           }
           if (this.isTravelAgent && reader.travelOption.status__c == TEConstant.STATUS_PENDING_RESERVATION){
               if (this.taCtrl.deadline  != '' && this.taCtrl.deadline != null){
                   ta = new Travel_Application__c(id = this.travelApplication.id, deadline__c = this.taCtrl.getDateTimeObj(this.taCtrl.deadline).date());
               }
           }
       }
       for (TETravelDetail reader : travelDetailList){
           if( ( reader.traveldetail.status__c == TEConstant.STATUS_DRAFT || reader.traveldetail.status__c ==  TEConstant.STATUS_NOT_SUBMITTED ) 
                 && (reader.travelDetail.Travel_Application__c != null || !String.isBlank(String.valueof(reader.travelDetail.Origin_Site__c)) || !String.isBlank(String.valueof(reader.travelDetail.Destination__c))  ||
                     reader.travelDetail.Return_Pick_Up_Point__c != null || reader.travelDetail.Departure_Pick_Up_Point__c != null ||
                     reader.travelDetail.Shuttle_From__c != null || reader.travelDetail.Shuttle_To__c != null 
                    )
             ){
               if ( !String.isBlank(reader.TravelDetail.Origin_Site__c)){
                   this.travelLocationMap.put(reader.TravelDetail.Origin_Site__c, new Travel_Location__c(id=reader.TravelDetail.Origin_Site__c, Name = reader.OriginSiteName));
               }
               if ( !String.isBlank(reader.TravelDetail.Destination__c)){
                   this.travelLocationMap.put(reader.TravelDetail.Destination__c, new Travel_Location__c(id=reader.TravelDetail.Destination__c, Name = reader.DestinationName));
               }
               reader.reqCheck = true;
               reader.travelDetail.Preferred_Departure_dt__c = this.taCtrl.getDateTimeObj(reader.DepartureDateTime);
               if (reader.travelDetail.Preferred_Departure_dt__c != null){
                   reader.travelDetail.Preferred_Departure_Time_Display__c = reader.travelDetail.Preferred_Departure_dt__c.format(DT_FORMAT_hhmma);
               }
               reader.travelDetail.Preferred_Return_dt__c = this.taCtrl.getDateTimeObj(reader.ReturnDateTime);
               if(reader.travelDetail.Preferred_Return_dt__c != null){
                   reader.travelDetail.Preferred_Return_Time_Display__c = reader.travelDetail.Preferred_Return_dt__c.format(DT_FORMAT_hhmma);
               }
               reader.travelDetail.site_To_Visit__c = '';
               if (reader.siteToVisit != ''){                                      
                   reader.siteToVisit +=SINGLECOMMA;
                   reader.siteToVisit = reader.siteToVisit.replace(DOUBLECOMMA, SINGLECOMMA);
                   reader.travelDetail.site_To_Visit__c = reader.siteToVisit;
               }
               reader.travelDetail.Departure_Route__c = reader.pickupRouteMap.get(reader.travelDetail.Departure_Pick_Up_Point__c);
               reader.travelDetail.Return_Route__c = reader.pickupRouteMap.get(reader.travelDetail.Return_Pick_Up_Point__c);
               tmptravelDetailList.add(reader.travelDetail);
           }
       }
       for (TECashAdvanceCtrl reader :cashAdvanceList){
           //Modified by TAL (Twinkle LI) @20170728 - Check if Amount of Cash Advance is null
           if(
               (reader.CashAdvance.status__c == TEConstant.STATUS_CANCELLED ||reader.CashAdvance.status__c == TEConstant.STATUS_PENDING || reader.CashAdvance.status__c == TEConstant.STATUS_NOT_SUBMITTED || reader.CashAdvance.status__c == TEConstant.STATUS_DRAFT) 
                && (reader.CashAdvance.amount__c != 0 && reader.CashAdvance.amount__c != null && reader.CashAdvance.currency__c != null && !String.isblank(reader.collectionDate))
             ){
                 reader.CashAdvance.Expected_Collection_Date__c = this.taCtrl.getDateTimeObj(reader.collectionDate).date();
                 if(this.TravelApplication.status__c == TEConstant.STATUS_CONFIRMED){
                     reader.CashAdvance.status__C = TEConstant.STATUS_OPEN;
                 }
                 tmpCashAdvanceList.add(reader.CashAdvance);
             }
          
        }
       String [] siteAndArragedBy = null;
       for (TEAccommodationCtrl reader : this.taCtrl.travelAccommodationList){
           reader.reqcheck = false;
           if(reader.accommodation.Tech_Site_and_Arrage_By__c != null){
               siteAndArragedBy = reader.accommodation.Tech_Site_and_Arrage_By__c.split('_');
               if(!String.isBlank(siteAndArragedBy[0])){
                   reader.accommodation.Site__c = siteAndArragedBy[0];
               }
               reader.accommodation.Accommodation_By__c = siteAndArragedBy[1];
           }
           if((reader.accommodation.status__c == TEConstant.STATUS_NOT_SUBMITTED|| reader.accommodation.status__c == TEConstant.STATUS_DRAFT) && 
              (reader.accommodation.Accommodation_By__c != null
              || !String.isBlank(reader.checkInDate) || !String.isBlank(reader.checkOutDate)
              || !String.isBlank(String.valueof(reader.accommodation.Location__c)))
             ){
               reader.reqcheck = true;
               if ( !String.isBlank(String.valueof(reader.accommodation.Location__c))){
                   this.travelLocationMap.put(reader.accommodation.Location__c, new Travel_Location__c(id=reader.accommodation.Location__c, Name = reader.locationName));
               }
               dt = null;
               reader.accommodation.check_In_Date__c = null;
               reader.accommodation.check_Out_Date__c = null;
               dt = this.taCtrl.getDateTimeObj(reader.checkInDate);
               if (dt != null){
                   reader.accommodation.check_In_Date__c = dt.date();
               }
               
               dt = this.taCtrl.getDateTimeObj(reader.checkOutDate);
               if (dt != null){
                   reader.accommodation.check_Out_Date__c = dt.date();
               }
               tmpAccommodationList.add(reader.accommodation);
          }
           if(reader.accommodation.Accommodation_By__c == TEConstant.ACCOMMODATION_BY_SITE_ADMIN && reader.accommodation.status__c == TEConstant.STATUS_PENDING_RESERVATION && isAdmin && reader.getadminArrange()){
               tmpAccommodationList.add(new Accommodation__c(id = reader.accommodation.id, remarks__c = reader.accommodation.remarks__c));
           }           
       }
       if (this.travelApplication.status__c == TEConstant.STATUS_PENDING){
           for (TETravelOption reader : airtravelOptionList){
               if (this.isTravelAgent && (reader.travelOption.status__c == TEConstant.STATUS_PENDING_RESERVATION ) ){
                   if (!String.isBlank(this.taCtrl.deadline)){
                       this.travelApplication.deadline__c = this.taCtrl.getDateTimeObj(this.taCtrl.deadline).date();
                   }
               }
               if(
                   (reader.travelOption.option1__c != null || reader.travelOption.option2__c != null || reader.travelOption.option3__c != null) ||
                   reader.travelOption.Departure_Date__c != null || !String.isBlank(String.valueof(reader.travelOption.From__c)) || !String.isBlank(String.valueof(reader.travelOption.To__c))
               ){
                   reader.reqCheck = true;
                   //if (this.isTravelAgent && (reader.travelOption.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT || reader.travelOption.status__c == TEConstant.STATUS_PENDING_SELECTION)){                   
                   if (this.isTravelAgent && (!this.taCtrl.getissave())){
                       reader.travelOption.option1__c = replaceLlineFeed(reader.travelOption.option1__c);
                       reader.travelOption.option2__c = replaceLlineFeed(reader.travelOption.option2__c);
                       reader.travelOption.option3__c = replaceLlineFeed(reader.travelOption.option3__c);
                       reader.travelOption.Departure_Date__c = null;
                       if (reader.DepartureDate != null && reader.DepartureDate != ''){
                           reader.travelOption.Departure_Date__c = this.taCtrl.getDateTimeObj(reader.DepartureDate).date();
                       }
                       tmpTravelOptionList.add(reader.travelOption);
                       if (!String.isBlank(reader.travelOption.From__c)){
                           this.travelLocationMap.put(reader.travelOption.From__c, new Travel_Location__c(id=reader.travelOption.From__c, Name = reader.FromName));
                       }
                       if (!String.isBlank(reader.travelOption.To__c)){
                           this.travelLocationMap.put(reader.travelOption.To__c, new Travel_Location__c(id=reader.travelOption.To__c, Name = reader.ToName));
                       }
                   }
                   if (!this.isTravelAgent && (reader.travelOption.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT || reader.travelOption.status__c == TEConstant.STATUS_PENDING_SELECTION)){
                       str = reader.travelOption.Selected_Option1__c;
                       if( str != null){
                           reader.travelOption.Selected_Option1__c = str.replace(WHITESPACE,'');
                       }
                       str = reader.travelOption.Selected_Option2__c;
                       if( str != null){
                           reader.travelOption.Selected_Option2__c = str.replace(WHITESPACE,'');
                       }
                       str = reader.travelOption.Selected_Option3__c;
                       if( str != null){
                           reader.travelOption.Selected_Option3__c = str.replace(WHITESPACE,'');
                       }
                       tmpTravelOptionList.add(reader.travelOption);
                   }
               }
           }           
           for (TETravelOption reader : hotelTravelOptionList){
               if(
                   reader.travelOption.option1__c != null || !String.isBlank(String.valueof(reader.travelOption.Destination__c)) ||
                   reader.CheckInDate != '' || reader.CheckOutDate != ''
               ){  
                   reader.reqCheck = true;
                     if (this.isTravelAgent && (!this.taCtrl.getissave())){
                       reader.travelOption.option1__c = replaceLlineFeed(reader.travelOption.option1__c);               
                       reader.travelOption.Check_In_Date__c = null;
                       if (reader.CheckInDate != null && reader.CheckInDate != ''){
                           reader.travelOption.Check_In_Date__c = this.taCtrl.getDateTimeObj(reader.CheckInDate).date();
                       }
                       reader.travelOption.Check_Out_Date__c = null;
                       if (reader.CheckOutDate != null && reader.CheckOutDate != ''){
                           reader.travelOption.Check_Out_Date__c = this.taCtrl.getDateTimeObj(reader.CheckOutDate).date();
                       }
                       tmpTravelOptionList.add(reader.travelOption);
                   }
                   if (!this.isTravelAgent && (reader.travelOption.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT || reader.travelOption.status__c == TEConstant.STATUS_PENDING_SELECTION)){
                       str = reader.travelOption.Selected_Option1__c;
                       if( str != null){
                           reader.travelOption.Selected_Option1__c = str.replace(WHITESPACE,'');
                       }
                       str = reader.travelOption.Selected_Option2__c;
                       if( str != null){
                           reader.travelOption.Selected_Option2__c = str.replace(WHITESPACE,'');
                       }
                       str = reader.travelOption.Selected_Option3__c;
                       if( str != null){
                           reader.travelOption.Selected_Option3__c = str.replace(WHITESPACE,'');
                       }
                       tmpTravelOptionList.add(reader.travelOption);
                   }                   
                   if (!String.isBlank(reader.travelOption.Destination__c)){
                       this.travelLocationMap.put(reader.travelOption.Destination__c, new Travel_Location__c(id=reader.travelOption.Destination__c, Name = reader.DestinationName));
                   }
               }
           }
       }       
       Boolean optAllConfirm = false;

       /*Comment by DTT Support Team  Reason:Can add invoice regardless the status*/
       // for (TETravelOption reader : airtravelOptionList){
       //    if(reader.TravelOption.status__c != TEConstant.STATUS_CONFIRMED ){
       //        optAllConfirm = false;
       //    }
       // }       
       // for (TETravelOption reader : hotelTravelOptionList){
       //    if(reader.TravelOption.status__c != TEConstant.STATUS_CONFIRMED ){
       //        optAllConfirm = false;
       //    }
       // }


      /*Add by DTT Support Team*/  
      if(this.travelApplication.status__c == TEConstant.STATUS_DRAFT || this.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED)
      {
        optAllConfirm=false;
      }
      else
      {
        if ((airtravelOptionList!=null && !airtravelOptionList.isEmpty()) || (hotelTravelOptionList!=null && !hotelTravelOptionList.isEmpty()))
        {
          optAllConfirm=true;
        }
      } 

      List <TETravelPriceCtrl> tempList=new List <TETravelPriceCtrl>();

      for(TETravelPriceCtrl reader : travelPriceList){
               if((reader.travelPrice.Amount__c == null || reader.travelPrice.Amount__c ==0) 
                        && (reader.travelPrice.Invoice_No__c == null || reader.travelPrice.Invoice_No__c == '') 
                        && (reader.invoiceDate=='' || reader.invoiceDate==null ))
                {
                   continue;
                }
               else
               {
                if(reader.travelPrice.Amount__c ==0)
                {
                  reader.travelPrice.Amount__c=null;
                }
                tempList.add(reader);
               }
        }
      travelPriceList.clear();
      travelPriceList.addAll(tempList);

      /*Add by DTT Support Team*/
       List <TETravelPriceCtrl> myTempList=new List <TETravelPriceCtrl>();
       if(optAllConfirm){
           for(TETravelPriceCtrl reader : travelPriceList){
               if(this.istravelAgent && 
                   (reader.travelPrice.Type__c != null 
                   || (reader.travelPrice.Amount__c != null && reader.travelPrice.Amount__c!=0)
                   || reader.travelPrice.Currency__c != null 
                   || (reader.invoiceDate != '' && reader.invoiceDate != null) 
                   || (reader.travelPrice.Invoice_No__c != null))){
                   reader.checkreq = true;
                   reader.travelPrice.invoice_date__c = null;
                   if (reader.invoiceDate != '' && reader.invoiceDate != null){
                       reader.travelPrice.invoice_date__c = this.taCtrl.getDateTimeObj(reader.invoiceDate).date();
                   }
                   tmpTravelPriceList.add(reader.travelPrice);
               }
           }
       }

      
       for (TETravelItineraryCtrl reader : travelItineraryList){
           if( 
               !String.isBlank(reader.journey.From_Airport_Text__c) || !String.isBlank(reader.journey.To_Airport_Text__c) 
               || !String.isBlank(reader.journey.Flight__c)
           ){
               reader.reqCheck = true;
               reader.journey.Arrival_Date__c = null;
               reader.journey.Departure_Date__c = null;
               if (!String.isBlank(reader.arrivalDate)){
                   reader.journey.Arrival_Date__c = this.taCtrl.getDateTimeObj(reader.arrivalDate ).date();
               }
               if (!String.isBlank(reader.departureDate)){
                   reader.journey.Departure_Date__c = this.taCtrl.getDateTimeObj(reader.departureDate ).date();
               }
               tmpTravelItineraryList.add(reader.journey);
           }
       }
       if (!TETravelApplicationValidationsController.CheckTravelApplication(this.taCtrl)){
           isCorrect = false;
       }
       if (!TETravelApplicationValidationsController.checkTravelDetail(travelDetailList)){
           isCorrect = false;
       }
       if (!TETravelApplicationValidationsController.CheckVaildDepartureDate(travelDetailList)){
           isCorrect = false;
       }
       if (!TETravelApplicationValidationsController.checkAccommodation(this.taCtrl.travelAccommodationList)){
           isCorrect = false;
       }       if (!TETravelApplicationValidationsController.checkCashAdvance(CashAdvanceList)){
           isCorrect = false;
       }           
       if(!TETravelApplicationValidationsController.checkOption(hoteltravelOptionList, TEConstant.TRAVEL_OPTION_TYPE_HOTEL)){
           isCorrect = false;
       }
       if(!TETravelApplicationValidationsController.checkOption(airtravelOptionList, TEConstant.TRAVEL_OPTION_TYPE_AIR_TICKET)){
           isCorrect = false;
       }
       if (!TETravelApplicationValidationsController.checkPrice(TravelPriceList)){
           isCorrect = false;
       }
       if (!TETravelApplicationValidationsController.checkSelectedOption(airtravelOptionList)){
           isCorrect = false;
       }
       if (!iscorrect){
           return null;
       } 
       
       if (this.travelApplication.status__c == TEConstant.STATUS_PENDING){
           for(Accommodation__c reader : tmpAccommodationList){
               if(this.isMySelf && reader.status__c == TEConstant.STATUS_NOT_SUBMITTED|| reader.status__c == TEConstant.STATUS_DRAFT){
                   reader.status__c = TEConstant.STATUS_PENDING_RESERVATION;
               }
           }
       }
       
           if(ta != null){
               upsert ta;
           }else{
               ta = this.travelApplication;
           }
           prf = new PageReference(currURL);
           if ( this.taId == null){
              prf.getParameters().put(travelApplicationURLParameter, ta.id);          
           }
           prf.setAnchor(URL_PARAMETER_LABEL_TAB + selectedTab);
    
           if (!tmptravelDetailList.isEmpty()){
               for(Travel_Detail__c reder : tmptravelDetailList){
                   if (reder.id == null){
                       reder.Travel_Application__c = ta.id;
                   }
               }
               upsert tmptravelDetailList;
           }
           
           if (!tmpAccommodationList.isEmpty()){
               for(Accommodation__c reder : tmpAccommodationList){
                   if (reder.id == null){
                       reder.Travel_Application__c = ta.id;
                   }
               }
               upsert tmpAccommodationList;
           }
           
           if (!tmpTravelOptionList.isEmpty()){
               for(TravelOption__c reder : tmpTravelOptionList){
                   if (reder.id == null){
                       reder.Travel_Application__c = ta.id;
                   }
               }
               upsert tmpTravelOptionList ;
           }
           
           if (!tmpTravelPriceList.isEmpty()){
               for(Travel_Price__c reder : tmpTravelPriceList){
                   if (reder.id == null){
                       reder.Travel_Application__c = ta.id;
                   }
               }
               upsert tmpTravelPriceList;
           }
           if (!tmpCashAdvanceList.isEmpty()){
               for(Cash_Advance__c reder : tmpCashAdvanceList){
                   if (reder.id == null){
                       reder.Travel_Application__c = ta.id;
                   }
               }
               upsert tmpCashAdvanceList;
           }
           isCorrect = true;
           if (!TETravelApplicationValidationsController.CheckItinerary(travelItineraryList)){
               isCorrect = false;
           }
           if (!iscorrect){
               return null;
           }
         
           if (!tmpTravelItineraryList.isEmpty()){
               for(journey__c reder : tmpTravelItineraryList){
                   if (reder.id == null){
                       reder.Travel_Application__c = ta.id;
                   }
               }
               upsert tmpTravelItineraryList;
           }
       return prf;
   }
   private String replaceLlineFeed(String str){
       if ( str == null){
           return '';
       }
       str = str.replace(CARRIAGE_RETURN_LINEFEED, SEMICOLON);
       str = str.replace(CARRIAGE_RETURN, SEMICOLON);
       str = str.replace(LINEFEED, SEMICOLON);
       return str;
   }
   
}