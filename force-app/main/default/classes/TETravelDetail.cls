/**
 * TETravelDetail
 * @description Travel Detail
 */
public without sharing class TETravelDetail{

    Public Static String ADMIN_GROUP = 'TE-@name-ADMIN';
    Public String Id{get;set;}
    Public String dt_format = TETravelApplicationCtrl.DT_FORMAT;
    Public String d_format = TETravelApplicationCtrl.DATE_FORMAT;   
    Public TETravelApplicationCtrl travelApplicationCtrl;
    Public Map <String, String> siteSelectionMap{get;set;}
    Public Travel_Detail__c travelDetail{get;set;}
    Public String DepartureDateTime{get;set;}
    Public String ReturnDateTime{get;set;}
    Public String OriginSiteName{get;set;}
    Public String DestinationName{get;set;}    
    //Public Boolean accommodationData {set;}
    Public Boolean accommodationFlage{get;set;}
    Public String siteToVisit{get;set;}
    Public Map <String, Boolean> siteSelectionSelectedMap{get;set;}
    Public List <SelectOption> shuttleArrangementFromSelectionList{set;}
    Public List <SelectOption> shuttleArrangementToSelectionList{set;}
    Public Map <Id, Id> pickupRouteMap{get;set;}
    Public String ReturnAssignedShuttle{set;}
    Public String DepartureAssignedShuttle{set;}
    Public String errorMsg{get;set;}
    Public Boolean reqCheck{get;set;}
    Public Boolean checkTravelType{get;set;}
    Public Boolean checkFom{get;set;}
    Public Boolean checkTo{get;set;}
    Public Boolean checkDepartureDT{get;set;}
    Public Boolean checkPplnum{get;set;}
    Public Boolean checkDeparturePickup{get;set;}
    Public Boolean checkReturnPickup{get;set;}
    Public Boolean checkShuttleFrom{get;set;}
    Public Boolean checkShuttleTo{get;set;} 
    Public Boolean adminArrange{set;}
    Public Static String DOUBLECOMMA = ',,';
    Public Static String COMMA = ',';
    Public Static String NO_SHUTTLE = 'No Shuttle';
    Public Static String ROW_ACTION_REMOVE = 'R';
    Public Static String ROW_ACTION_ADD = 'A';
    Public Static String SHUTTLE_STOP_TYPE_PICK_UP_POINT = 'P';
    Public Static String OPEN_PARENTHESIS = ' (';
    Public Static String CLOSE_PARENTHESIS = ')';
    Public Static String HYPHEN = ' - ';
    /*
    Public Boolean getaccommodationData(){
        if (this.travelDetail.id == ''){
            return true;
        }
        if (!this.accommodationFlage){
            return true;
        }
        return false;
    }
    */  
    
    public TETravelDetail(String Id, TETravelApplicationCtrl travelApplicationCtrl){
        this.accommodationFlage = false;
        Schema.DescribeFieldResult defStatus;
        List <Schema.PicklistEntry> pickVals;
        this.id = id;
        this.travelDetail = new Travel_Detail__c(No_of_Seats__c = 1);
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.accommodationFlage = false;
        this.errorMsg = '';
        this.reqCheck = false;
        this.checkFom = true;
        this.checkTo = true;
        this.checkTravelType = true;
        this.checkDepartureDT = true;
        this.checkPplnum = true;
        this.checkDeparturePickup = true;
        this.checkReturnPickup = true;
        this.checkShuttleFrom = true;
        this.checkShuttleTo = true; 
        this.shuttleArrangementFromSelectionList = new List <SelectOption>();
        this.shuttleArrangementToSelectionList = new List <SelectOption>();
        this.ReturnAssignedShuttle = '';
        this.DepartureAssignedShuttle = '';
        this.OriginSiteName = '';
        siteSelectionMap = this.travelApplicationCtrl.siteSelectionMap;
        siteSelectionSelectedMap = new Map <String, Boolean>();
        this.pickupRouteMap = new Map <Id, Id>();
        for( String reader : this.siteSelectionMap.KeySet()){
            siteSelectionSelectedMap.put(reader, false);
        }
        defStatus = Travel_Detail__c.status__c.getDescribe();
        pickVals = defStatus.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals){
            if (pv.isDefaultValue()){
                this.travelDetail.status__c = pv.getValue();
            }
        }
    }
    
    public TETravelDetail(TETravelApplicationCtrl travelApplicationCtrl, Travel_Detail__c travelDetail ){
        
        List <RecordType> rt = null;
        String dateFormat = dt_format;
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.id = travelDetail.id;
        this.travelDetail = travelDetail ;
        this.accommodationFlage = true;
        this.ReturnAssignedShuttle = '';
        this.DepartureAssignedShuttle = '';
        this.reqCheck = false;
        this.checkFom = true;
        this.checkTo = true;
        this.checkTravelType = true;
        this.checkDepartureDT = true;
        this.checkPplnum = true;
        this.checkDeparturePickup = true;
        this.checkReturnPickup = true;
        this.checkShuttleFrom = true;
        this.checkShuttleTo = true; 
        this.errorMsg = '';
        this.OriginSiteName = this.travelDetail.Origin_Site__r.name;
        this.DestinationName = this.travelDetail.Destination__r.name;
        this.pickupRouteMap = new Map <Id, Id>();
        siteToVisit = '';
        if( this.travelDetail.site_To_Visit__c != null){
            siteToVisit = this.travelDetail.site_To_Visit__c;
        }
        rt = travelApplicationCtrl.recordTypeList;
        for (RecordType reader : rt){
            if (reader.id == travelDetail.recordtypeid && reader.Name == TETravelApplicationCtrl.SHUTTLE_TRAVEL_DETAIL_TYPE ){
                dateFormat = d_format;
            }
        }
        if ( this.travelDetail.Preferred_Departure_dt__c != null){
            DepartureDateTime = this.travelDetail.Preferred_Departure_dt__c.format(dateFormat, travelApplicationCtrl.travelApplication.On_Behalf_of__r.Employee_Administrator__r.user__r.TimeZoneSidKey);
        }
        if ( this.travelDetail.Preferred_Return_dt__c != null){        
            ReturnDateTime = (this.travelDetail.Preferred_Return_dt__c == null ? null : this.travelDetail.Preferred_Return_dt__c.format(dateFormat, travelApplicationCtrl.travelApplication.On_Behalf_of__r.Employee_Administrator__r.user__r.TimeZoneSidKey));
        }
        
        siteSelectionSelectedMap = new Map <String, Boolean>();
        siteSelectionMap = this.travelApplicationCtrl.siteSelectionMap;
        siteSelection();
    }
    
    Public void siteSelection(){
        siteToVisit += COMMA;
        siteToVisit = siteToVisit.replace(DOUBLECOMMA, COMMA);
        for( String reader : this.siteSelectionMap.KeySet()){
            siteSelectionSelectedMap.put(reader, false);
            if(siteToVisit.contains(siteSelectionMap.get(reader)+COMMA)){
                siteSelectionSelectedMap.put(reader, true);
            }
        }
    }
    
    Public Boolean getisEdit(){
        return ((this.travelDetail.status__c == TEConstant.STATUS_DRAFT || this.travelDetail.status__c == TEConstant.STATUS_NOT_SUBMITTED )&&(this.travelApplicationCtrl.isMySelf));
    }
    
    Public Void addRow(){
        this.travelApplicationCtrl.travelDetailRows(this.id, ROW_ACTION_ADD);
    }
    
    Public Void removeRow(){        
        if ( this.travelDetail.status__c == TEConstant.STATUS_DRAFT || this.travelDetail.status__c == TEConstant.STATUS_NOT_SUBMITTED ){
            if (this.travelDetail.id != null){
                delete this.travelDetail;
            }
            this.travelApplicationCtrl.travelDetailRows(this.id, ROW_ACTION_REMOVE);
        }        
    }
    /*
    Public boolean getenableRcall(){
        return 
        (TravelDetail.Status__c != TEConstant.STATUS_PENDING_ARRANGEMENT  && TravelDetail.Status__c != TEConstant.STATUS_CONFIRMED  && TravelDetail.Status__c != TEConstant.STATUS_CANCELLED ) &&
        (
             (this.travelApplicationCtrl.isMySelf && ( (this.TravelDetail.Record_Type_Name__c != TEConstant.TRAVEL_DETAIL_RECORD_TYPE_AIR  && TravelDetail.Status__c != TEConstant.STATUS_PENDING_RESERVATION ) || (this.TravelDetail.Record_Type_Name__c == TEConstant.TRAVEL_DETAIL_RECORD_TYPE_AIR )) ) ||
             (this.travelApplicationCtrl.isTravelAgent && this.TravelDetail.Record_Type_Name__c == TEConstant.TRAVEL_DETAIL_RECORD_TYPE_AIR  && (TravelDetail.Status__c != TEConstant.STATUS_NOT_SUBMITTED  && TravelDetail.Status__c != TEConstant.STATUS_DRAFT)) ||
             (this.travelApplicationCtrl.isadmin && this.TravelDetail.Record_Type_Name__c != TEConstant.TRAVEL_DETAIL_RECORD_TYPE_AIR  && (TravelDetail.Status__c != TEConstant.STATUS_NOT_SUBMITTED  && TravelDetail.Status__c != TEConstant.STATUS_DRAFT && TravelDetail.Status__c != TEConstant.STATUS_PENDING_RESERVATION ))
        );
    }
    
    Public void Recall(){
        Travel_Detail__c tmpTravelDetail = new Travel_Detail__c();
        if(this.TravelDetail.Record_Type_Name__c == TEConstant.TRAVEL_DETAIL_RECORD_TYPE_AIR ){
            tmpTravelDetail.id = this.TravelDetail.id;
            tmpTravelDetail.Status__c = TEConstant.STATUS_PENDING_ARRANGEMENT ;
        }
        else if(this.TravelDetail.Record_Type_Name__c != ''){
            tmpTravelDetail.id = this.TravelDetail.id;
            tmpTravelDetail.Status__c = TEConstant.STATUS_PENDING_RESERVATION ;
            
        }
        if (tmpTravelDetail.id != null){
            this.TravelDetail.Status__c = tmpTravelDetail.Status__c;
            update tmpTravelDetail;
        }
    }
    */
    Public String getDepartureAssignedShuttle(){
        String tmp = '';
        if (this.TravelDetail.Departure_Assigned_Shuttle__c!= null){
            tmp = this.TravelDetail.Departure_Assigned_Shuttle__c;
        }
        else{
            if (this.travelDetail.Departure_Route__c != null && this.travelDetail.Preferred_Departure_Date__c != null){
                for(Car_Journey__c reader : [select id, name from Car_Journey__c where route__c = :this.travelDetail.Departure_Route__c and  date__c = :this.travelDetail.Preferred_Departure_Date__c]){
                    tmp = reader.id;
                }
            }
        }
        return tmp;
    }
    Public String getReturnAssignedShuttle(){
        String tmp = '';
        if (this.TravelDetail.Return_Assigned_Shuttle__c != null){
            tmp = this.TravelDetail.Return_Assigned_Shuttle__c ;
        }
        else{
            if (this.travelDetail.Return_Route__c != null && this.travelDetail.Preferred_Return_Date__c != null){
                for(Car_Journey__c reader : [select id, name from Car_Journey__c where route__c = :this.travelDetail.Return_Route__c and  date__c = :this.travelDetail.Preferred_Return_Date__c]){
                    tmp = reader.id;
                }
            }
        }
        return tmp;
    }
    Public  List <SelectOption> getshuttleArrangementFromSelectionList(){
        DateTime dt = this.travelApplicationCtrl.getDateTimeObj(this.DepartureDateTime);        
        Date DepartureDate = null;
        if ( dt != null){
            DepartureDate = dt.date();
        }
        //return shuttleArrangementSelectionList(this.traveldetail.shuttle_to__c, DepartureDate);
        return shuttleArrangementSelectionList(this.traveldetail.shuttle_from__c, DepartureDate);
    }
    Public  List <SelectOption> getshuttleArrangementToSelectionList(){
        DateTime dt = this.travelApplicationCtrl.getDateTimeObj(this.ReturnDateTime);
        Date DepartureDate = null;
        if ( dt != null){
            DepartureDate = dt.date();
        }
        return shuttleArrangementSelectionList(this.traveldetail.shuttle_to__c, DepartureDate );
        //return shuttleArrangementSelectionList(this.traveldetail.shuttle_from__c, DepartureDate );
    }
    
    Public List <SelectOption> shuttleArrangementSelectionList(Id SiteId, Date DepartureDate ){
        List <SelectOption> tmpshuttleArrangementSelectionList = new List <SelectOption>();
        List <Id> routeIdList = new List <Id>();
        if (DepartureDate == null || SiteId == null){
            return tmpshuttleArrangementSelectionList;
        }
        
        for(Car_Journey__c reader : [select id, Route__c from Car_Journey__c where Date__c = :DepartureDate and Active__c = true ]){
            routeIdList.add(reader.Route__c);
        }
        
        if(routeIdList.isEmpty()){
            tmpshuttleArrangementSelectionList.add(new SelectOption('', NO_SHUTTLE));
        }
        else{
            tmpshuttleArrangementSelectionList.add(new SelectOption('', ''));
        }
        
        for (Route__c reader : 
        [SELECT Id, Name, Departure_Time__c , For_Guest__c, from__r.Name, from__c, to__r.Name, to__c, 
         (select id, Location__c, Stop_Type__c, Arrival_Time__c from Shuttle_Stops__r)
          FROM Route__c
          //where to__c = :SiteId and id in :routeIdList
          where from__c = :SiteId and id in :routeIdList
        ] ){
              for(Shuttle_Stop__c sreader : reader.Shuttle_Stops__r){
                if (sreader.Stop_Type__c == SHUTTLE_STOP_TYPE_PICK_UP_POINT){
                    this.pickupRouteMap.put(sreader.id, reader.id);
                    tmpshuttleArrangementSelectionList .add(new SelectOption(sreader.id,
                    sreader.location__c +OPEN_PARENTHESIS+sreader.Arrival_Time__c+ CLOSE_PARENTHESIS + 
                    ((reader.For_Guest__c)? HYPHEN + Route__c.fields.For_Guest__c.getDescribe().getLabel() : '')
                    ));
                }
           }   
        }
        return tmpshuttleArrangementSelectionList ;
    }
    
    
     Public Boolean getadminArrange() {
        Map<Id, Travel_Location__c> loactionSitMap = this.travelApplicationCtrl.loactionSitMap;
        List <String> publicGrouopList = this.travelApplicationCtrl.publicGrouopList;
        Map <Id, Site__c> siteMap = this.travelApplicationCtrl.siteMap;
        if(loactionSitMap.containsKey(this.travelDetail.Destination__c)){
            for(String reader : publicGrouopList){
                if(reader == ADMIN_GROUP.replace('@name', loactionSitMap.get(this.travelDetail.Destination__c).Site__r.Name)){
                     return true;
                }
            }
        }
        else if(siteMap.containsKey(this.travelDetail.Shuttle_To__c) || siteMap.containsKey(this.travelDetail.Shuttle_From__c)){
            for(String reader : publicGrouopList){
                if(reader == ADMIN_GROUP.replace('@name', siteMap.get(this.travelDetail.Shuttle_To__c).Name)){
                         return true;
                }
                else if(reader == ADMIN_GROUP.replace('@name', siteMap.get(this.travelDetail.Shuttle_From__c).Name)){
                         return true;
                }
            }
        }
        /*
        else if(loactionSitMap.containsKey(this.travelDetail.Origin_Site__c)){
            for(String reader : publicGrouopList){
                if(reader == ADMIN_GROUP.replace('@name', loactionSitMap.get(this.travelDetail.Origin_Site__c).Site__r.Name)){
                     return true;
                }
            }
        }
        else{
            for(String reader : publicGrouopList){
               if(reader == ADMIN_GROUP.replace('@name', this.travelApplicationCtrl.travelApplication.on_behalf_of__r.Employee__r.travel_policy__r.name)){
                     return true;
                } 
            } 
        }
        */
        return false;
     }
    
    
}