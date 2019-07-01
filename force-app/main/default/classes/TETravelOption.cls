/**
 * TETravelDetail
 * @description Travel Option
 */
public without sharing class TETravelOption{

    Public String Id{get;set;}
    Public String Status{set;}
    Public String type{get;set;}
    Public String DepartureDate{get;set;}
    Public String CheckInDate{get;set;}
    Public String CheckOutDate{get;set;}
    Public String FromName{get;set;}
    Public String ToName{get;set;}
    Public String DestinationName{get;set;}
    Public TravelOption__c travelOption{get;set;}
    Public TETravelApplicationCtrl travelApplicationCtrl {get;set;}
    Public Map<String, Boolean> option1Map{get;set;}
    Public Map<String, Boolean> option2Map{get;set;}
    Public Map<String, Boolean> option3Map{get;set;}
    Public List <SelectOption> opt1SelectionList{get;set;}
    Public List <SelectOption> opt2SelectionList{get;set;}
    Public List <SelectOption> opt3SelectionList{get;set;}
    Public Boolean isEdit{get;set;}
    Public Boolean checkFrom{get;set;}
    Public Boolean checkTo{get;set;}
    Public Boolean checkDepartureDate{get;set;}
    Public Boolean checkOpt1{get;set;}
    Public Boolean checkCheckInDate{get;set;}
    Public Boolean checkCheckOutDate{get;set;}
    Public Boolean checkHotelOpt1{get;set;}
    Public Boolean checkDestination{get;set;}
    Public Static String WHITESPACE = ' ';
    Public Static String UNDERSCORE = '_';
    Public Static String CARRIAGE_RETURN_LINEFEED = '\r\n';
    Public Static String SEMICOLON = ';';
    Public Static String ROW_ACTION_REMOVE = 'R';
    Public Static String ROW_ACTION_ADD = 'A';
    
    /*
    Public Boolean checkOptionEstimatedPrice1{get;set;}
    Public Boolean checkOptionEstimatedPrice2{get;set;}
    Public Boolean checkOptionEstimatedPrice3{get;set;}
    Public Boolean checkOptionEstimatedCurrency{get;set;}
    */
    Public Boolean reqCheck{get;set;}    
    Public List<String> radioButtonOptionList{get;set;}
    
    //Public TETravelOption(String Id, TETravelApplicationCtrl travelApplicationCtrl){}
    Public TETravelOption(String Id, TETravelApplicationCtrl travelApplicationCtrl, String type){
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.type = type;
        this.Id = Id;
        this.isEdit = false;
        this.checkFrom = true;
        this.checkTo = true;
        this.checkDepartureDate = true;
        this.checkOpt1 = true;
        this.checkHotelOpt1 = true;
        this.checkDestination = true;
        this.checkCheckInDate = true;
        this.checkCheckOutDate = true;
        this.fromName = '';
        this.toName = '';
        this.DestinationName = '';
        /*
        this.checkOptionEstimatedPrice1 = true;
        this.checkOptionEstimatedPrice2 = true;
        this.checkOptionEstimatedPrice3 = true;
        this.checkOptionEstimatedCurrency = true;
        */
        this.reqCheck = false;
        travelOption = new TravelOption__c (status__c = TEConstant.STATUS_PENDING_ARRANGEMENT );
        option1Map = new Map<String, Boolean>();
        option2Map = new Map<String, Boolean>();
        option3Map = new Map<String, Boolean>();
        travelOption.recordtypeId = this.travelApplicationCtrl.optRecordTypeMap.get(this.type);
        //optRecordTypeMap
        
    }
    
    Public TETravelOption(TravelOption__c travelOption, TETravelApplicationCtrl travelApplicationCtrl){
        String str = '';
        String [] opts = null;
        DateTime checkDate = null;
        this.travelOption = travelOption;
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.Id = this.travelOption.id;
        this.isEdit = enableModify();
        this.checkFrom = true;
        this.checkTo = true;
        this.checkDepartureDate = true;
        this.checkOpt1 = true;
        this.checkHotelOpt1 = true;
        this.checkDestination = true;
        this.checkCheckInDate = true;
        this.checkCheckOutDate = true;
        this.fromName = travelOption.from__r.Name;
        this.toName = travelOption.to__r.Name;
        this.DestinationName = travelOption.Destination__r.Name;
        /*
        this.checkOptionEstimatedPrice1 = true;
        this.checkOptionEstimatedPrice2 = true;
        this.checkOptionEstimatedPrice3 = true;
        this.checkOptionEstimatedCurrency = true;
        */
        this.reqCheck = false;
        option1Map = new Map<String, Boolean>();
        option2Map = new Map<String, Boolean>();
        option3Map = new Map<String, Boolean>();
        opt1SelectionList = new List <SelectOption>();
        opt2SelectionList = new List <SelectOption>();
        opt3SelectionList = new List <SelectOption>();
        
        for(String reader : this.travelApplicationCtrl.optRecordTypeMap.keyset()){
            if(this.travelApplicationCtrl.optRecordTypeMap.get(reader) == this.travelOption.recordtypeId){
                this.type = reader;                
            }
        }
        checkDate = this.travelOption.check_In_Date__c;
        if ( checkDate !=null){
            this.checkInDate = checkDate.format(TETravelApplicationCtrl.Date_FORMAT, travelApplicationCtrl.travelApplication.On_Behalf_of__r.Employee_Administrator__r.user__r.TimeZoneSidKey);
        }
        checkDate = this.travelOption.check_Out_Date__c;
        if ( checkDate !=null){
            this.checkOutDate = checkDate.format(TETravelApplicationCtrl.Date_FORMAT, travelApplicationCtrl.travelApplication.On_Behalf_of__r.Employee_Administrator__r.user__r.TimeZoneSidKey);
        }
        checkDate = this.travelOption.Departure_Date__c;
        if ( checkDate !=null){
            this.DepartureDate = checkDate.format(TETravelApplicationCtrl.Date_FORMAT, travelApplicationCtrl.travelApplication.On_Behalf_of__r.Employee_Administrator__r.user__r.TimeZoneSidKey);
        }
        
        if (this.travelApplicationCtrl.isTravelAgent){            
            AgentView();
        }
        else{
            applicantView();
        }
        
    }
    
    
    
    Public Void applicantView(){
        String str = '';
        String [] opts = null;
        
        str = travelOption.Option1__c;
        if ( str != null){
            opts = str.split(SEMICOLON);
            //opt1SelectionList.add(new SelectOption('', ''));
            for(String reader : opts){
                opt1SelectionList.add(new SelectOption(reader.replace(WHITESPACE,UNDERSCORE), reader));
                option1Map.put(reader, false);
            }
        }
        
        str = travelOption.Option2__c;
        if ( str != null){
            opts = str.split(SEMICOLON);
            //opt2SelectionList.add(new SelectOption('', ''));
            for(String reader : opts){
                opt2SelectionList.add(new SelectOption(reader.replace(WHITESPACE,UNDERSCORE), reader));
                option2Map.put(reader, false);
            }
        }
        
        str = travelOption.Option3__c;
        if ( str != null){
            opts = str.split(SEMICOLON);
            //opt3SelectionList.add(new SelectOption('', ''));
            for(String reader : opts){
                opt3SelectionList.add(new SelectOption(reader.replace(WHITESPACE,UNDERSCORE), reader));
                option3Map.put(reader, false);
            }
        }
    }
    
    Public Void AgentView(){
        String str;
        str = travelOption.Option1__c;
        if ( str != null){
            travelOption.Option1__c = str.replace(SEMICOLON, CARRIAGE_RETURN_LINEFEED);
        }
        str = travelOption.Option2__c;
        if ( str != null){
            travelOption.Option2__c = str.replace(SEMICOLON, CARRIAGE_RETURN_LINEFEED);
        }
        str = travelOption.Option3__c;
        if ( str != null){
            travelOption.Option3__c = str.replace(SEMICOLON, CARRIAGE_RETURN_LINEFEED);
        }
    }
    
    Public Void addRow(){
        this.travelApplicationCtrl.OptionRows(this.id, this.type, ROW_ACTION_ADD);
    }
    
    Public Void RemoveRow(){
        if (travelOption.id != null){
            delete this.travelOption;
        }
        this.travelApplicationCtrl.OptionRows(this.id, this.type, ROW_ACTION_REMOVE);
    }
    
    private Boolean enableModify(){
        if(travelOption.status__c == TEConstant.STATUS_PENDING_SELECTION ){
            return true;
        }
        if(this.travelApplicationCtrl.isTravelAgent && travelOption.status__c == TEConstant.STATUS_PENDING_RESERVATION  ){
            return true;
        }
        if(this.travelApplicationCtrl.isTravelAgent && travelOption.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION  ){
            return true;
        }
        if(this.travelApplicationCtrl.isTravelAgent && travelOption.status__c == TEConstant.STATUS_CONFIRMED ){
            return true;
        }    
        return false;
    }
    
    Public boolean getiseditable(){
        this.isedit = this.travelApplicationCtrl.isTravelAgent  && (travelOption.status__c == TEConstant.STATUS_PENDING_SELECTION || travelOption.status__c == TEConstant.STATUS_PENDING_ARRANGEMENT || travelOption.status__c == null );
        return this.isedit;
    }
       
}