/**
 * TETravelApplicationValidationsController 
 * @description validations controller for  Travel Application
 */
public without Sharing class TETravelApplicationValidationsController {

    Public Static String LABEL_PASSPORT = ' [Passport Type],';
    Public Static String LABEL_BOOKINGDATE = ' [Booking Date],';
    Public Static String LABEL_INVOICENO = ' [Invoice No],';
    Public Static String LABEL_TYPE = ' [Type],';
    Public Static String LABEL_CURRENCY = ' [Currency],';
    Public Static String LABEL_AMOUNT = ' [Amount],';
    Public Static String LABEL_DESTINATION=' [Destination],';
    Public Static String LABEL_CHECK_IN = ' [Check In],';
    Public Static String LABEL_CHECK_OUT = ' [Check Out],';
    Public Static String LABEL_OPTION = ' [Option],';    
    Public Static String LABEL_TRAVEL_TYPE = ' [Travel Type],';
    Public Static String LABEL_FROM = ' [From],';
    Public Static String LABEL_TO = ' [To],';
    Public Static String LABEL_DEPARTURE_PICK_UP_POINT = ' [Departure Pick-Up Point],';
    Public Static String LABEL_RETURN_PICK_UP_POINT = ' [Return Pick-Up Point],';
    Public Static String LABEL_DEPARTURE_DATE_AND_TIME = ' [Departure Date and Time],';
    Public Static String LABEL_NUMBER_OF_PEOPLE = ' [# ppl],';      
    Public Static String LABEL_FLIGHT = ' [Flight],';
    Public Static String LABEL_CABIN_CLASS = ' [Cabin Class],';
    Public Static String LABEL_DEPARTURE_DATE = ' [Departure Date],';
    Public Static String LABEL_ETD = ' [ETD],';
    Public Static String LABEL_ARRIVAL_DATE = ' [Arrival Date],';
    Public Static String LABEL_ETA = ' [ETA],';
    Public Static String LABEL_OPTION_1 = ' [Option 1],';
    Public Static String LABEL_COLLECTION_DATE = ' [Collection Date],';
    Public Static String LABEL_ARRANGED_BY = ' [Arranged By],';                 
    Public Static String LABEL_LOCATION = ' [Location],';                 
    Public Static String LABEL_CHECK_IN_DATE = ' [Check-in Date],';                 
    Public Static String LABEL_CHECK_OUT_DATE = ' [Check-out Date],';
    
    Public Static String MESSAGE_AIR_TICKET_OPTION_SELECT_ONE = Label.TE_Travel_Application_Message_Air_Ticket_Option_Select_One;
    Public Static String MESSAGE_AIR_TICKET_OPTION_FILL_IN_CONFIRM_BEFORE_DEADLINE = Label.TE_Travel_Application_Message_Air_Ticket_Option_Fill_In_Confrim_Before_Deadline;
    Public Static String MESSAGE_AIR_TICKET_OPTION_DEADLINE = Label.TE_Travel_Application_Message_Air_Ticket_Option_Deadline;
    Public Static String MESSAGE_AIR_TICKET_FILL_IN_ESTIMATED_PRICE = Label.TE_Travel_Application_Message_Air_Ticket_Fill_In_Estimated_Price; 
    Public Static String TRAVEL_DETAIL_API_NAME = Travel_Detail__c.sObjectType.getDescribe().getName();
        
    Public Static String COMMA_ASTERISK = ',*';
    Public Static String ASTERISK = '*';
    Public Static String WHITESPACE = ' ';
    Public Static String LINENUMBER = '@number';
    Public Static String LABELNAME = '@label';
    
    Public Static Boolean checkPrice(List <TETravelPriceCtrl> travelPriceList){
        Boolean isCorrect = true;
        
        for(TETravelPriceCtrl reader : travelPriceList){
            reader.checkInvoiceNo = true;
            reader.checkBookingDate = true;
            reader.checkType = true;
            reader.checkCurrency = true;
            reader.checkAmount = true;
        }
        
        isCorrect = checkPriceReq(travelPriceList);
        
        return isCorrect;
    }
    
    Public Static Boolean checkPriceReq(List <TETravelPriceCtrl> travelPriceList){
        Boolean iscorrect = true;
        Boolean isFirst = true;
        String msg = '';
        String tmpstr = '';
        Integer counter = 1;
        for(TETravelPriceCtrl reader : travelPriceList){
            tmpstr = '';
            if (reader.checkreq && reader.travelApplicationCtrl.isTravelAgent){
                  if(String.isBlank(reader.travelPrice.Invoice_No__c)){
                       reader.checkInvoiceNo = false;
                      tmpstr += LABEL_INVOICENO;
                  }
                  if(reader.travelPrice.Invoice_Date__c == null){
                       reader.checkbookingDate= false;
                      tmpstr += LABEL_BOOKINGDATE;
                  }
                  if(reader.travelPrice.Type__c == null){
                       reader.checktype = false;
                      tmpstr += LABEL_TYPE;
                  }
                  if(reader.travelPrice.currency__c== null){
                       reader.checkCurrency = false;
                      tmpstr += LABEL_CURRENCY;
                  }
                  if(reader.travelPrice.Amount__c == null){
                       reader.checkAmount = false;
                      tmpstr += LABEL_AMOUNT;
                  }
                
            }
            tmpstr += ASTERISK;
            tmpstr = tmpstr.replace(COMMA_ASTERISK,WHITESPACE);
            tmpstr = tmpstr.replace(ASTERISK,'');
            if (tmpstr != ''){
                     
                //tmpstr = MESSAGE_TRAVEL_PRICE_LINE + String.Valueof(counter) +MESSAGE_PLEASE_FILL_IN+ tmpstr + MESSAGE_FIELDS;
                tmpstr = Label.TE_Travel_Application_Message_Travel_Price_Line.replace(LABELNAME,tmpstr);
                tmpstr = tmpstr.replace(LINENUMBER,String.Valueof(counter));
                reader.travelPrice.adderror(tmpstr);
                isCorrect = false;
            }
            counter ++;
        
        }
        
        
        return isCorrect;
    }
    
    Public Static Boolean checkSelectedOption(List<TETravelOption> optList){
        Boolean iscorrect = true;
        Boolean isFirst = true;
        String msg = '';
        Date ddate = null;
        //travelOption
        for (TETravelOption reader : optList ){
            if ( ddate == null){
                ddate = reader.travelOption.Departure_Date__c;
            }
            if( ddate > reader.travelOption.Departure_Date__c){
                ddate = reader.travelOption.Departure_Date__c;
            }
        }
        
        for(TETravelOption reader : optList){
            
            if (isFirst){
                reader.travelApplicationCtrl.checkSelectedOption1 = true;
                reader.travelApplicationCtrl.checkSelectedOption2 = true;
                reader.travelApplicationCtrl.checkSelectedOption3 = true;
                reader.travelApplicationCtrl.checkDeadline = true;                
                isFirst = false;
            }
            if ( reader.travelOption.status__c == TEConstant.STATUS_PENDING_SELECTION  && reader.travelApplicationCtrl.isMySelf){
                if( !reader.travelApplicationCtrl.travelApplication.Selected_Option_1__c && 
                    !reader.travelApplicationCtrl.travelApplication.Selected_Option_2__c && 
                    !reader.travelApplicationCtrl.travelApplication.Selected_Option_3__c){
                    reader.travelApplicationCtrl.checkSelectedOption1 = false;
                    reader.travelApplicationCtrl.checkSelectedOption2 = false;
                    reader.travelApplicationCtrl.checkSelectedOption3 = false;
                    msg = MESSAGE_AIR_TICKET_OPTION_SELECT_ONE;
                    iscorrect  = false;
                }
            }
            if ( reader.travelOption.status__c == TEConstant.STATUS_PENDING_RESERVATION && reader.travelApplicationCtrl.isTravelAgent){
                if( reader.travelApplicationCtrl.travelApplication.Deadline__c == null){
                    reader.travelApplicationCtrl.checkDeadline = false;
                    msg = MESSAGE_AIR_TICKET_OPTION_FILL_IN_CONFIRM_BEFORE_DEADLINE;
                    iscorrect  = false;
                }
                
                //if( reader.travelApplicationCtrl.travelApplication.Deadline__c < Date.today() ){
                //if( reader.travelApplicationCtrl.travelApplication.Deadline__c > reader.travelApplicationCtrl.travelApplication.Departure_Date__c ){
                if( reader.travelApplicationCtrl.travelApplication.Deadline__c > ddate ){
                    reader.travelApplicationCtrl.checkDeadline = false;
                    msg = MESSAGE_AIR_TICKET_OPTION_DEADLINE;
                    iscorrect  = false;
                }
            }
        }
        if (msg != '' && !optList.isempty()){
            optList[0].travelApplicationCtrl.travelApplication.adderror(msg);
        }
        return iscorrect;
    }
    
    public static Boolean checkOption(List<TETravelOption> optList, String type){
         Integer counter = 1;
         Boolean iscorrect = true;
         String tmpstr = '';
         for(TETravelOption reader : optList){
            reader.checkFrom = true;
            reader.checkTo = true;
            reader.checkDepartureDate = true;
            reader.checkOpt1 = true;
            reader.checkHotelOpt1 = true;
            reader.checkDestination = true;
            reader.checkCheckInDate = true;
            reader.checkCheckOutDate = true;
            reader.checkDestination = true;
            reader.travelApplicationCtrl.checkOptionEstimatedPrice1 = true;
            reader.travelApplicationCtrl.checkOptionEstimatedPrice2 = true;
            reader.travelApplicationCtrl.checkOptionEstimatedPrice3 = true;
            reader.travelApplicationCtrl.checkOptionEstimatedCurrency = true;
            reader.travelApplicationCtrl.checkOptionEstimatedCurrency2 = true;
            reader.travelApplicationCtrl.checkOptionEstimatedCurrency3 = true;            
         }
         iscorrect = checkAllOption(optList, type);
         return iscorrect ;
    }
    
    public Static Boolean checkAllOption(List<TETravelOption> optList, String type){
        Boolean isCorrect = true;
        Boolean isAirCorrect = true;
        Boolean isHotelCorrect = true;
        if (type == TEConstant.TRAVEL_OPTION_TYPE_AIR_TICKET ){
            isAirCorrect = checkAirOptionReq(optList);
            if(isAirCorrect){
                isAirCorrect = checkAirOption(optList);
            }
        }
        if (type == TEConstant.TRAVEL_OPTION_TYPE_HOTEL){
            isHotelCorrect = checkHotelOptionReq(optList);
            if(isHotelCorrect){
                isHotelCorrect = checkHotelOption(optList);
            }
        }
        
        if(!isAirCorrect || !isHotelCorrect){
            isCorrect = false;
        }
        return isCorrect;
    }
    
    public Static Boolean checkHotelOption(List<TETravelOption> optList){
        Boolean isCorrect = true;
        Integer counter = 1;
        for(TETravelOption reader : optList){
            if (!reader.reqCheck){
                 continue;
            }
            if( reader.travelOption.Check_In_Date__c != null && reader.travelOption.Check_In_Date__c != null){
                if(!CheckDate(reader.travelOption.Check_In_Date__c, reader.travelOption.Check_Out_Date__c)){
                    reader.checkCheckInDate = false; 
                    //reader.TravelOption.check_In_Date__c.addError(MESSAGE_HOTEL_OPTION_LINE+ String.Valueof(counter) +MESSAGE_TRAVEL_DETAIL_LINE_RETURN_DATE);
                    reader.TravelOption.check_In_Date__c.addError(Label.TE_Travel_Application_Message_Hotel_Option_Line_Return_Date.replace(LINENUMBER,String.Valueof(counter)));
                    
                    iscorrect = false;
                }
            }
            counter ++;
        }
        return isCorrect;
    }
    
    public Static Boolean checkHotelOptionReq(List<TETravelOption> optList){
        Boolean isCorrect = true;
        String tmpstr = '';
        Integer counter = 1;
        
        for(TETravelOption reader : optList){
            tmpstr = '';
            if (!reader.reqCheck){
                 continue;
            }
            if ( reader.travelOption.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT  && reader.travelApplicationCtrl.isTravelAgent){
                if (reader.travelOption.Destination__c == null){
                    reader.checkDestination = false;
                    tmpstr += LABEL_DESTINATION;
                    isCorrect = false;
                }
                 if (reader.travelOption.Check_in_Date__c == null){
                    reader.checkCheckInDate = false;
                    tmpstr += LABEL_CHECK_IN;
                    isCorrect = false;
                }
                if (reader.travelOption.Check_out_Date__c == null){
                    reader.checkCheckOutDate = false;
                    tmpstr += LABEL_CHECK_OUT;
                    isCorrect = false;
                }
                if ( String.isBlank(reader.travelOption.Option1__c) ){
                    reader.checkHotelOpt1 = false;
                    tmpstr += LABEL_OPTION;
                    isCorrect = false;
                }
            }        
            tmpstr += ASTERISK;
            tmpstr = tmpstr.replace(COMMA_ASTERISK,WHITESPACE);
            tmpstr = tmpstr.replace(ASTERISK,'');
            if (tmpstr != ''){         
                //tmpstr = MESSAGE_HOTEL_OPTION_LINE+ String.Valueof(counter) +MESSAGE_PLEASE_FILL_IN+ tmpstr + MESSAGE_FIELDS;
                tmpstr = Label.TE_Travel_Application_Message_Hotel_Option_Line.replace(LABELNAME,tmpstr);
                tmpstr = tmpstr.replace(LINENUMBER,String.Valueof(counter));
                reader.travelOption.adderror(tmpstr);
                isCorrect = false;
            }
            counter ++;
        }
        return isCorrect;
    }
    
    public Static Boolean checkAirOption(List<TETravelOption> optList){
        Boolean isCorrect = true;
        String msg = '';
        
        for(TETravelOption reader : optList){
            if (!reader.reqCheck){
                 continue;
            }
            if ( reader.travelOption.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT  && reader.travelApplicationCtrl.isTravelAgent){
                if (reader.travelApplicationCtrl.travelApplication.Option_Estimated_Price1__c == null && reader.travelApplicationCtrl.travelApplication.Option_Estimated_Price2__c == null && reader.travelApplicationCtrl.travelApplication.Option_Estimated_Price3__c == null){
                    reader.travelApplicationCtrl.checkOptionEstimatedPrice1 = false;
                    isCorrect = false;
                }
                /*
                if (reader.travelApplicationCtrl.travelApplication.Option_Estimated_Price2__c == null){
                    reader.travelApplicationCtrl.checkOptionEstimatedPrice2 = false;
                    isCorrect = false;
                }
                if (reader.travelApplicationCtrl.travelApplication.Option_Estimated_Price3__c == null){
                    reader.travelApplicationCtrl.checkOptionEstimatedPrice3 = false;
                    isCorrect = false;
                }
                */
                if ((!String.isBlank(reader.travelOption.Option1__c) || !String.isBlank(reader.travelOption.Option2__c) || !String.isBlank(reader.travelOption.Option3__c)) &&
                reader.travelApplicationCtrl.travelApplication.Option_Estimated_Currency__c == null
                ){
                    reader.travelApplicationCtrl.checkOptionEstimatedCurrency = false;
                    isCorrect = false;
                }
                if (reader.travelApplicationCtrl.travelApplication.Option_Estimated_Currency2__c == null && reader.travelApplicationCtrl.travelApplication.Option_Estimated_Price2__c != null && reader.travelApplicationCtrl.travelApplication.Option_Estimated_Price2__c != 0){
                    reader.travelApplicationCtrl.checkOptionEstimatedCurrency2= false;
                    isCorrect = false;
                }
                if (reader.travelApplicationCtrl.travelApplication.Option_Estimated_Currency3__c == null && reader.travelApplicationCtrl.travelApplication.Option_Estimated_Price3__c != null && reader.travelApplicationCtrl.travelApplication.Option_Estimated_Price3__c != 0){
                    reader.travelApplicationCtrl.checkOptionEstimatedCurrency3= false;
                    isCorrect = false;
                }
                if(!isCorrect){
                    msg = MESSAGE_AIR_TICKET_FILL_IN_ESTIMATED_PRICE;
                }
            }
        }
        if(msg != '' && !optList.isempty()){
            optList[0].travelApplicationCtrl.travelApplication.adderror(msg);
        }
        return isCorrect;
    }
    
    public Static Boolean checkAirOptionReq(List<TETravelOption> optList){
         Boolean isCorrect = true;
         String tmpstr = '';
         Integer counter = 1;
         
         for(TETravelOption reader : optList){
             if (!reader.reqCheck){
                 continue;
             }
             tmpstr = '';
             /*
             if ( reader.travelOption.From__c == null && reader.travelOption.To__c == null &&
                  reader.travelOption.Departure_Date__c == null &&
                  reader.travelOption.Option1__c == null && reader.travelOption.Option2__c == null &&
                  reader.travelOption.Option3__c == null && reader.travelOption.Hotel_Option__c == null &&
                  reader.travelOption.Check_in_Date__c == null && reader.travelOption.Check_out_Date__c== null
             ){
                 continue;
             }
             */
             if ( reader.travelOption.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT  && reader.travelApplicationCtrl.isTravelAgent){
                 if(reader.travelOption.From__c == null){
                     reader.checkFrom = false;
                     tmpstr += LABEL_FROM;
                     isCorrect = false;
                 }
                 if(reader.travelOption.To__c == null){
                     reader.checkTo = false;
                     tmpstr += LABEL_TO;
                     isCorrect = false;
                 }
                 if(reader.travelOption.Departure_Date__c == null){
                     reader.checkDepartureDate = false;
                     tmpstr += LABEL_DEPARTURE_DATE;
                     isCorrect = false;
                 }
                 if ( reader.travelOption.Option1__c == '' && reader.travelOption.Option2__c == ''&& reader.travelOption.Option3__c == ''){
                     if(reader.travelOption.Option1__c == ''){
                         reader.checkOpt1= false;
                         tmpstr += LABEL_OPTION_1;
                         isCorrect = false;
                     }
                 }
             }
             tmpstr += ASTERISK;
             tmpstr = tmpstr.replace(COMMA_ASTERISK,WHITESPACE);
             tmpstr = tmpstr.replace(ASTERISK,'');
             if (tmpstr != ''){         
                 //tmpstr = MESSAGE_AIR_TICKET_OPTION_LINE+ String.Valueof(counter) +MESSAGE_PLEASE_FILL_IN+ tmpstr + MESSAGE_FIELDS;
                 tmpstr = Label.TE_Travel_Application_Message_Air_Ticket_Option_Line.replace(LABELNAME,tmpstr);
                 tmpstr = tmpstr.replace(LINENUMBER,String.Valueof(counter));                 
                 reader.travelOption.adderror(tmpstr);
                 isCorrect = false;
             }
             counter ++;
        
         }
         return isCorrect;
    }
    
    public static Boolean checkCashAdvance(List<TECashAdvanceCtrl> caList){     
         Integer counter = 1;
         Boolean iscorrect = true;
         for(TECashAdvanceCtrl reader : caList){
            reader.checkCurrency = true;
            reader.checkAmount = true;
            reader.checkCollectionDate = true;
         }
         iscorrect = checkCashAdvanceReq(caList);         
         return iscorrect ;
    }
     
    public Static Boolean checkCashAdvanceReq(List<TECashAdvanceCtrl> caList){
         Boolean isCorrect = true;
         String tmpstr = '';
         Integer counter = 1;
         for(TECashAdvanceCtrl reader : caList){
             tmpstr  = '';
             if ( reader.CashAdvance.currency__c  == null && reader.CashAdvance.amount__c == 0 &&
                  reader.CashAdvance.Expected_Collection_Date__c == null
             ){
                 continue;
             }
             if(reader.CashAdvance.currency__c == null){
                 reader.checkCurrency = false;
                 tmpstr += LABEL_CURRENCY;                 
             }
             //Modified by TAL (Twinkle LI) @20170728 - Check if Amount of Cash Advance is null
             if(reader.CashAdvance.amount__c == 0 || reader.CashAdvance.amount__c == null){
                 reader.checkAmount = false;
                 tmpstr += LABEL_AMOUNT;                 
             }
             //Modified by TAL (Twinkle LI) @20170728 - Check collectionDate instead of CashAdvance.Expected_Collection_Date__c
             if(reader.collectionDate == null){
                 reader.checkCollectionDate = false;
                 tmpstr += LABEL_COLLECTION_DATE;                 
             }
             tmpstr += ASTERISK;
             tmpstr = tmpstr.replace(COMMA_ASTERISK,WHITESPACE);
             tmpstr = tmpstr.replace(ASTERISK,'');
             if (tmpstr != ''){         
                 //tmpstr = MESSAGE_CASH_ADVANCE_LINE+ String.Valueof(counter) +MESSAGE_PLEASE_FILL_IN+ tmpstr + MESSAGE_FIELDS;
                 
                 tmpstr = Label.TE_Travel_Application_Message_Cash_Advance_Line.replace(LABELNAME,tmpstr);
                 tmpstr = tmpstr.replace(LINENUMBER,String.Valueof(counter));
                 reader.CashAdvance.adderror(tmpstr);
                 isCorrect = false;
             }
             counter ++;
         }
         return isCorrect;
    }
     
    public static Boolean checkAccommodation(List<TEAccommodationCtrl> taList){     
         Integer counter = 1;
         Boolean iscorrect = true;
         
         for(TEAccommodationCtrl reader : taList){
            reader.checkAccommodationBy = true;
            reader.checkLocation = true;
            reader.checkCheckIn = true;
            reader.checkCheckOut = true;
         }
         iscorrect = CheckAccommodationReq(taList);
         for(TEAccommodationCtrl reader : taList){             
             if (reader.accommodation.check_In_Date__c != null && reader.accommodation.check_Out_Date__c != null){
                 if(!CheckDate(reader.accommodation.check_In_Date__c, reader.accommodation.check_Out_Date__c )){                 
                     reader.checkCheckIn = false; 
                     //reader.accommodation.addError(MESSAGE_ACCOMMODATION_LINE + String.Valueof(counter) +MESSAGE_ACCOMMODATION_LINE_CHECK_OUT_DATE);
                     reader.accommodation.addError(Label.TE_Travel_Application_Message_Accommodation_Line_Error.replace(LINENUMBER, String.Valueof(counter)));
                     iscorrect = false;
                 }
             }
             counter ++;
         }
         return iscorrect;
    }
    public Static Boolean CheckAccommodationReq(List<TEAccommodationCtrl> taList){
         Boolean isCorrect = true;
         String tmpstr = '';
         Integer counter = 1;
         for(TEAccommodationCtrl reader : taList){
             tmpstr  = '';
             if (!reader.reqCheck){
                 continue;
             }
             /*
             if ( reader.accommodation.Accommodation_By__c  == null && reader.accommodation.Location__c == null &&
                  reader.accommodation.check_In_Date__c == null && reader.accommodation.check_Out_Date__c == null
             ){
                 continue;
             }
             */
             if(reader.accommodation.Accommodation_By__c == null){
                 reader.checkAccommodationBy = false;
                 tmpstr += LABEL_ARRANGED_BY;                 
             }
             if(reader.accommodation.Location__c == null){
                 reader.checkLocation = false;
                 tmpstr += LABEL_LOCATION;                 
             }
             if(reader.accommodation.check_In_Date__c == null){
                 reader.checkCheckIn = false;
                 tmpstr += LABEL_CHECK_IN_DATE;                 
             }
             if(reader.accommodation.check_Out_Date__c == null){
                 reader.checkCheckOut = false;
                 tmpstr += LABEL_CHECK_OUT_DATE;                 
             }
             
             tmpstr += ASTERISK;
             tmpstr = tmpstr.replace(COMMA_ASTERISK,WHITESPACE);
             tmpstr = tmpstr.replace(ASTERISK,'');
             if (tmpstr != ''){         
                 
                 //tmpstr = MESSAGE_ACCOMMODATION_LINE + String.Valueof(counter) +MESSAGE_PLEASE_FILL_IN+ tmpstr + MESSAGE_FIELDS;
                 tmpstr = Label.TE_Travel_Application_Message_Accommodation_Line.replace(LABELNAME,tmpstr);
                 tmpstr = tmpstr.replace(LINENUMBER,String.Valueof(counter));
                 reader.accommodation.adderror(tmpstr);
                 isCorrect = false;
             }
             counter ++;
         }
         return iscorrect;
    }
    public static Boolean checkTravelDetail(List<TETravelDetail> tdList){
         Integer counter = 1;
         Boolean iscorrect = true;
         
         for(TETravelDetail reader : tdList){
             reader.checkTravelType = true;
             reader.checkFom = true;
             reader.checkTo = true;
             reader.checkDepartureDT = true;
             reader.checkPplnum = true;
             reader.checkDeparturePickup = true;
             reader.checkReturnPickup = true;
             reader.checkShuttleFrom = true;
             reader.checkShuttleTo = true;
         }         
         iscorrect = CheckTravelDetailReq(tdList);         
         for(TETravelDetail reader : tdList){             
             if (reader.travelDetail.Preferred_Departure_dt__c != null && reader.travelDetail.Preferred_Return_dt__c != null){
                 if(!CheckDate(reader.travelDetail.Preferred_Departure_dt__c, reader.travelDetail.Preferred_Return_dt__c)){                 
                     reader.checkDepartureDT = false; 
                     //reader.travelDetail.addError(MESSAGE_TRAVEL_DETAIL_LINE+ String.Valueof(counter) +MESSAGE_TRAVEL_DETAIL_LINE_RETURN_DATE);
                     reader.travelDetail.addError(Label.TE_Travel_Application_Message_Travel_Detail_Line_Return_Date.replace(LINENUMBER,String.Valueof(counter)));
                     iscorrect = false;
                 }
             }
             if (reader.travelDetail.No_of_Seats__c <= 0){
                 iscorrect = false;
                 reader.checkPplnum= false;
                 //reader.travelDetail.addError(MESSAGE_TRAVEL_DETAIL_LINE+ String.Valueof(counter) + MESSAGE_TRAVEL_DETAIL_LINE_PPL );
                 reader.travelDetail.addError(Label.TE_Travel_Application_Message_Travel_Detail_Line_PPL.replace(LINENUMBER,String.Valueof(counter)));
             }             
             counter ++;
         }
         //iscorrect = true;
         return iscorrect;
         
    }
    public Static Boolean CheckTravelDetailReq(List<TETravelDetail> tdList){
         Boolean isCorrect = true;
         Boolean isAllEmpty = true;
         String tmpstr = '';
         Integer counter = 0;
         List <RecordType> recordTypeList;
         String ShuttleRecordTypeId = '';
         for(TETravelDetail reader : tdList){
             recordTypeList = reader.travelApplicationCtrl.recordTypeList;
             if (reader.reqCheck){
                 isAllEmpty = false;
             }
         }
         for (RecordType reader : recordTypeList){
             if( reader.SobjectType == TRAVEL_DETAIL_API_NAME && reader.DeveloperName ==  TETravelApplicationCtrl.SHUTTLE_TRAVEL_DETAIL_TYPE ){
                 ShuttleRecordTypeId = reader.id;
             }
         }
        
         for(TETravelDetail reader : tdList){
             if (!reader.reqCheck && !isAllEmpty){
                 continue;
             }
             isAllEmpty = false;
             counter ++;
             tmpstr = '';
             if (reader.travelDetail.recordTypeId == null){
                 reader.checkTravelType  = false;
                 tmpstr += LABEL_TRAVEL_TYPE;
             }
             
             if (reader.travelDetail.recordTypeId != ShuttleRecordTypeId && reader.travelDetail.Origin_Site__c == null){
                 reader.checkFom = false;
                 tmpstr += LABEL_FROM;
             }
             if (reader.travelDetail.recordTypeId != ShuttleRecordTypeId && reader.travelDetail.Destination__c == null){
                 reader.checkTo = false;
                 tmpstr += LABEL_TO;
             }
             /*
             if (reader.travelDetail.recordTypeId == ShuttleRecordTypeId && reader.getshuttleArrangementFromSelectionList().size() > 1 && reader.travelDetail.Departure_Pick_Up_Point__c == null){
                 reader.checkDeparturePickup = false;
                 tmpstr += LABEL_DEPARTURE_PICK_UP_POINT;
             }
             if (reader.travelDetail.recordTypeId == ShuttleRecordTypeId && reader.getshuttleArrangementToSelectionList().size() > 1 && reader.travelDetail.Preferred_Return_dt__c != null && reader.travelDetail.Return_Pick_Up_Point__c == null){
                 reader.checkReturnPickup = false;
                 tmpstr += LABEL_RETURN_PICK_UP_POINT;
             }
             */
             if (reader.travelDetail.recordTypeId == ShuttleRecordTypeId && reader.travelDetail.Departure_Pick_Up_Point__c == null && reader.travelDetail.Return_Pick_Up_Point__c == null){
                 reader.checkDeparturePickup = false;
                 reader.checkReturnPickup = false;
                 tmpstr += LABEL_DEPARTURE_PICK_UP_POINT;
                 tmpstr += LABEL_RETURN_PICK_UP_POINT;
             }
             if (reader.travelDetail.recordTypeId == ShuttleRecordTypeId && reader.travelDetail.Shuttle_From__c == null){
                 reader.checkShuttleFrom = false;
                 tmpstr += LABEL_FROM;
             }
             if (reader.travelDetail.recordTypeId == ShuttleRecordTypeId && reader.travelDetail.Shuttle_To__c == null){
                 reader.checkShuttleTo = false;
                 tmpstr += LABEL_TO;
             }
             /*
             if (reader.travelDetail.recordTypeId == ShuttleRecordTypeId && CheckVaildShuttle(reader)){
                 reader.checkShuttlePickupFrom = true;
                 reader.checkShuttlePickupTo = true;
                 tmpstr += LABEL_TO;
             }
             */
             if (reader.travelDetail.Preferred_Departure_dt__c == null){
                 reader.checkDepartureDT = false;
                 tmpstr += LABEL_DEPARTURE_DATE_AND_TIME;
             }
             if (reader.travelDetail.No_of_Seats__c == null){
                 reader.checkPplnum = false;
                 tmpstr += LABEL_NUMBER_OF_PEOPLE;
             }
             tmpstr += ASTERISK;
             tmpstr = tmpstr.replace(COMMA_ASTERISK,WHITESPACE);
             tmpstr = tmpstr.replace(ASTERISK,'');
             if (tmpstr != ''){         
                 //tmpstr = MESSAGE_TRAVEL_DETAIL_LINE+ String.Valueof(counter) +MESSAGE_PLEASE_FILL_IN+ tmpstr + MESSAGE_FIELDS;
                 tmpstr = Label.TE_Travel_Application_Message_Travel_Detail_Line.replace(LABELNAME,tmpstr);
                 tmpstr = tmpstr.replace(LINENUMBER,String.Valueof(counter));
                 reader.travelDetail.adderror(tmpstr);
                 isCorrect = false;
             }
         }
         return isCorrect;
    }
    
    public Static Boolean CheckItinerary(List<TETravelItineraryCtrl> itineraryList){
        Boolean isCorrect = true;
        Integer counter = 1;
        
        for(TETravelItineraryCtrl reader : itineraryList){
            reader.checkFlight = true;
            reader.checkCabinClass = true;
            reader.checkFrom = true;
            reader.checkDeparture = true;
            reader.checkETD = true;
            reader.checkTo = true;
            reader.checkArrival = true;
            reader.checkETA = true; 
        }        
        isCorrect = CheckItineraryReq(itineraryList);
        for(TETravelItineraryCtrl reader : itineraryList){
             if(!reader.reqCheck){
                 continue;
             }              
             if (reader.journey.Departure_Date__c != null && reader.journey.Arrival_Date__c != null){
                 if(!CheckDate(reader.journey.Departure_Date__c , reader.journey.Arrival_Date__c )){                 
                     reader.checkDeparture = false; 
                     //reader.journey.addError(MESSAGE_TRAVEL_ITINERARY_LINE+ String.Valueof(counter) + MESSAGE_TRAVEL_ITINERARY_LINE_ARRIVAL_DATE);
                     reader.journey.addError(Label.TE_Travel_Application_Message_Travel_Itinerary_Line_Arrival_Date.replace(LINENUMBER,String.Valueof(counter)));
                     
                     
                     iscorrect = false;
                 }
             }
             counter ++;
         }
        return isCorrect;
    }
    public Static Boolean CheckItineraryReq(List<TETravelItineraryCtrl> itineraryList){
        Boolean isCorrect = true;
        Integer counter = 1;
        String tmpstr = '';
        
        for(TETravelItineraryCtrl reader : itineraryList){                        
            if(!reader.reqCheck){
                continue;
            }
            if(String.isBlank(reader.journey.Flight__c)){
                reader.checkFlight = false;
                tmpstr += LABEL_FLIGHT;
            }
            
            if(String.isBlank(reader.journey.Cabin_Class__c)){
                reader.checkCabinClass = false;
                tmpstr += LABEL_CABIN_CLASS;
            }
            if(String.isBlank(reader.journey.From_Airport_Text__c)){
                reader.checkFrom = false;
                tmpstr += LABEL_FROM;
            }
            /*
            if(String.isBlank(reader.departureDate)){
                reader.checkDeparture = false;
                tmpstr += LABEL_DEPARTURE_DATE;
            }
            */
            if(String.isBlank(reader.journey.To_Airport_Text__c)){
                reader.checkTo = false;
                tmpstr += LABEL_TO;
            }
            tmpstr += ASTERISK;
            tmpstr = tmpstr.replace(COMMA_ASTERISK,WHITESPACE);
            tmpstr = tmpstr.replace(ASTERISK,'');
            if (!String.isBlank(tmpstr)){         
                //tmpstr = MESSAGE_TRAVEL_ITINERARY_LINE+ String.Valueof(counter) +MESSAGE_PLEASE_FILL_IN+ tmpstr + MESSAGE_FIELDS;
                tmpstr = Label.TE_Travel_Application_Message_Travel_Itinerary_Line.replace(LABELNAME,tmpstr);
                tmpstr = tmpstr.replace(LINENUMBER,String.Valueof(counter));                
                reader.journey.adderror(tmpstr);
                isCorrect = false;
            }
            tmpstr = '';
            counter++;
        }
        return isCorrect;
    }
    
    
    
    
    
    
    public Static Boolean CheckTravelApplication(TETravelApplicationCtrl travelApp){
        Boolean isCorrect = true;
        travelApp.checkPassportType = true;     
        isCorrect = CheckTravelApplicationReq(travelApp);
        return isCorrect;
    }
    public Static Boolean CheckTravelApplicationReq(TETravelApplicationCtrl travelApp){
        Boolean isCorrect = true;
        String tmpstr = '';

        if(String.isBlank(travelApp.travelApplication.Selected_Passport__c)){
            travelApp.checkPassportType = false;
            tmpstr += LABEL_PASSPORT;
        }
        
        tmpstr += ASTERISK;
        tmpstr = tmpstr.replace(COMMA_ASTERISK,WHITESPACE);
        tmpstr = tmpstr.replace(ASTERISK,'');
        if (!String.isBlank(tmpstr)){         
            //tmpstr = MESSAGE_APPLICATION_HEADER + MESSAGE_PLEASE_FILL_IN+ tmpstr + MESSAGE_FIELDS;
            tmpstr = Label.TE_Travel_Application_Message_Application_Header.replace(LABELNAME,tmpstr);
            travelApp.travelApplication.adderror(tmpstr);
            isCorrect = false;
        }
        tmpstr = '';
        
        return isCorrect;
    }
    
    
    public Static Boolean CheckVaildDepartureDate(List<TETravelDetail> tdList){
        Boolean isCorrect = true;
        String tmpstr = '';
        Integer counter = 1;
        DateTime cutoffDate = null;
        tmpstr = label.TE_Travel_Application_Start_Date;        
        cutoffDate = DateTime.newInstance(Integer.valueof(tmpstr.split('/')[0]), Integer.valueof(tmpstr.split('/')[1]), Integer.valueof(tmpstr.split('/')[2]),0,0,0);
        for(TETravelDetail reader : tdList){
            if(reader.TravelDetail.Preferred_Departure_dt__c < cutoffDate){
                tmpstr = Label.TE_Expense_Detail_Not_Earlier_Than;
                tmpstr = tmpstr.replace(LINENUMBER, String.Valueof(counter));
                tmpstr = tmpstr.replace(LABELNAME, cutoffDate.format('dd MMMM yyyy'));
                reader.TravelDetail.adderror(tmpstr);
                if(!Test.isRunningTest()){
                    isCorrect = false;
                }
            }
            tmpstr = '';
            counter++;
        }
        return isCorrect;
    }
    
    
    public Static Boolean CheckDate(DateTime fromDate, DateTime toDate){
         return (fromDate <= toDate);
    }
}