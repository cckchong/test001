/**
 * TETravelApplication
 * @description override new button of Travel Accommodation
 */
public without sharing class TEAccommodationCtrl{

    Public String Id{get;set;}
    Public Accommodation__c accommodation {get;set;}
    Public TETravelApplicationCtrl travelApplicationCtrl {get;set;}
    Public String LocationName {get;set;} 
    Public String checkInDate {get;set;}
    Public String checkOutDate {get;set;}
    Public String Budget {get;set;}
    Public Boolean checkAccommodationBy {get;set;}
    Public Boolean checkLocation {get;set;}
    Public Boolean checkCheckIn {get;set;}
    Public Boolean checkCheckOut {get;set;}
    Public Boolean reqCheck{get;set;}
    Public Boolean adminArrange{set;}
    Public Static String ROW_ACTION_REMOVE = 'R';
    Public Static String ROW_ACTION_ADD = 'A';
    Public Static String ADMIN_GROUP = 'TE-@name-ADMIN';
    
    Public TEAccommodationCtrl(String Id, TETravelApplicationCtrl travelApplicationCtrl){
        Schema.DescribeFieldResult defStatus;
        List <Schema.PicklistEntry> pickVals;
        this.LocationName = '';
        this.checkAccommodationBy = true;
        this.checkLocation = true;
        this.checkCheckIn = true;
        this.checkCheckOut = true;
        this.reqCheck = false;
        this.Id = Id;
        this.accommodation = new Accommodation__c();        
        defStatus = Accommodation__c.status__c.getDescribe();
        pickVals = defStatus.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals){
            if (pv.isDefaultValue()){
                this.accommodation.status__c = pv.getValue();
            }
        }        
        this.travelApplicationCtrl = travelApplicationCtrl;
    }
    
    Public TEAccommodationCtrl(Accommodation__c accommodation, TETravelApplicationCtrl travelApplicationCtrl){
        DateTime checkDate = null;
        this.checkAccommodationBy = true;
        this.checkLocation = true;
        this.checkCheckIn = true;
        this.checkCheckOut = true;
        this.reqCheck = false;
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.id = accommodation.id;
        this.accommodation = accommodation;
        this.LocationName = accommodation.location__r.Name;
        checkDate = this.accommodation.check_In_Date__c;
        if ( checkDate !=null){
            this.checkInDate = checkDate.format(TETravelApplicationCtrl.Date_FORMAT, travelApplicationCtrl.travelApplication.On_Behalf_of__r.Employee_Administrator__r.user__r.TimeZoneSidKey );
        }
        checkDate = this.accommodation.check_Out_Date__c;
        if ( checkDate !=null){
            this.checkOutDate = checkDate.format(TETravelApplicationCtrl.Date_FORMAT, travelApplicationCtrl.travelApplication.On_Behalf_of__r.Employee_Administrator__r.user__r.TimeZoneSidKey );
        }
    }
    
    Public Boolean getisEdit(){
        return ((this.accommodation.status__c == TEConstant.STATUS_DRAFT || this.accommodation.status__c == TEConstant.STATUS_NOT_SUBMITTED )&&(this.travelApplicationCtrl.isMySelf));
    }
    
    Public Void addRow(){
        this.travelApplicationCtrl.accommodationRows(this.id, ROW_ACTION_ADD );
        //this.travelApplicationCtrl.travelDetailAddRow(this.id);
    }
    
    Public Void cancelRow(){
        this.accommodation.status__c = TEConstant.STATUS_CANCELLED;
        upsert this.accommodation;
    }
    
    Public Void RemoveRow(){        
        if( (this.accommodation.status__c == TEConstant.STATUS_DRAFT || this.accommodation.status__c == TEConstant.STATUS_NOT_SUBMITTED ) && this.accommodation.id != null){
            delete this.accommodation;            
        }
        this.travelApplicationCtrl.accommodationRows(this.id, ROW_ACTION_REMOVE );
    }
    
    Public Boolean getadminArrange(){
        List <String> publicGrouopList = this.travelApplicationCtrl.publicGrouopList;
        for(String reader : publicGrouopList){
            if(reader == ADMIN_GROUP.replace('@name', this.accommodation.site__r.Name)){
                return true;
            }
        }
        /*
        Map<Id, Travel_Location__c>loactionSitMap = this.travelApplicationCtrl.loactionSitMap;
        List <String> publicGrouopList = this.travelApplicationCtrl.publicGrouopList;
        if(loactionSitMap.containsKey(accommodation.Location__c)){
            for(String reader : publicGrouopList){
                if(reader == ADMIN_GROUP.replace('@name', loactionSitMap.get(accommodation.Location__c).Site__r.Name)){
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
/*    
    Public boolean getenableRcall(){
        return 
        (accommodation.Status__c != TEConstant.STATUS_PENDING_ARRANGEMENT  && accommodation.Status__c != TEConstant.STATUS_CONFIRMED  && accommodation.Status__c != TEConstant.STATUS_CANCELLED ) &&
        (
             (this.travelApplicationCtrl.isMySelf && ( (this.accommodation.Accommodation_By__c!= 'Travel Agency' && this.accommodation.Status__c != 'PR') || (this.accommodation.Accommodation_By__c == 'Air')) ) ||
             (this.travelApplicationCtrl.isTravelAgent && this.accommodation.Accommodation_By__c== 'Travel Agency' && (this.accommodation.Status__c != TEConstant.STATUS_NOT_SUBMITTED  && this.accommodation.Status__c != TEConstant.STATUS_DRAFT)) ||
             (this.travelApplicationCtrl.isadmin && this.accommodation.Accommodation_By__c!= 'Travel Agency' && (this.accommodation.Status__c != TEConstant.STATUS_NOT_SUBMITTED  && this.accommodation.Status__c != TEConstant.STATUS_DRAFT && this.accommodation.Status__c != 'PR'))
        );
    }
    
    Public void Recall(){
        Accommodation__c tmpAccommodation = new Accommodation__c();
        if(this.accommodation.Accommodation_By__c == 'Air'){
            tmpAccommodation.id = this.accommodation.id;
            tmpAccommodation.Status__c = TEConstant.STATUS_PENDING_ARRANGEMENT ;
        }
        else if(this.accommodation.Accommodation_By__c != ''){
            tmpAccommodation.id = this.accommodation.id;
            tmpAccommodation.Status__c = 'PR';
            
        }
        if (tmpAccommodation.id != null){
            this.accommodation.Status__c = tmpAccommodation.Status__c;
            update tmpAccommodation;
        }
    }
*/
}