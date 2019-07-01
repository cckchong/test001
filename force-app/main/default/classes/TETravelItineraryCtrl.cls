/**
 * TETravelItinerary
 * @description Travel Itinerary
 */
public without sharing class TETravelItineraryCtrl{

    Public String Id{get;set;}
    Public String departureDate{get;set;}
    Public String arrivalDate{get;set;}
    Public TETravelApplicationCtrl travelApplicationCtrl{get;set;}
    Public Journey__c journey{get;set;}
    Public Map <id, Travel_Location__c> travelLocationMap{get;set;}
    Public Boolean checkFlight{get;set;}
    Public Boolean checkCabinClass{get;set;}
    Public Boolean checkFrom{get;set;}
    Public Boolean checkDeparture {get;set;}
    Public Boolean checkETD{get;set;}
    Public Boolean checkTo{get;set;}
    Public Boolean checkArrival{get;set;}
    Public Boolean checkETA{get;set;}
    Public Boolean reqCheck{get;set;}
    Public Static String TRAVEL_DETAIL_API_NAME = Travel_Detail__c.sObjectType.getDescribe().getName();
    Public Static String ITINERARY_TYPE_DEPARTURE = 'D';
    Public Static String ITINERARY_TYPE_RETURN = 'R';
    Public Static String WHITESPACE = ' ';
    Public Static String ROW_ACTION_REMOVE = 'R';
    Public Static String ROW_ACTION_ADD = 'A';
    
    Public TETravelItineraryCtrl(String Id, TETravelApplicationCtrl travelApplicationCtrl){
        this.Id = Id;
        this.travelApplicationCtrl = travelApplicationCtrl;       
        this.journey = new journey__c();
        this.travelLocationMap = this.travelApplicationCtrl.travelLocationMap;
        this.checkFlight = true;
        this.checkCabinClass = true;
        this.checkFrom = true;
        this.checkDeparture = true;
        this.checkETD = true;
        this.checkTo = true;
        this.checkArrival = true;
        this.checkETA = true; 
        this.reqCheck = false;
    }
     
    
    Public TETravelItineraryCtrl(String Id, TETravelApplicationCtrl travelApplicationCtrl, TETravelDetail travelDetail, String type ){
        Travel_Detail__c td = null;
        List <RecordType> recordTypeList = null;
        List <Airport__c> airportList = new List <Airport__c>();
        String dt;
        String [] dtarray;        
        this.Id = Id;
        this.travelApplicationCtrl = travelApplicationCtrl;
        td = travelDetail.travelDetail;
        this.journey = new journey__c();
        this.travelLocationMap = this.travelApplicationCtrl.travelLocationMap;
        this.checkFlight = true;
        this.checkCabinClass = true;
        this.checkFrom = true;
        this.checkDeparture = true;
        this.checkETD = true;
        this.checkTo = true;
        this.checkArrival = true;
        this.checkETA = true;
        this.reqCheck = false;
        recordTypeList = this.travelApplicationCtrl.recordTypeList;
        for (RecordType reader : recordTypeList){
            if(reader.id == td.recordTypeId && reader.Name == TEConstant.TRAVEL_DETAIL_RECORD_TYPE_AIR  && reader.SobjectType == TRAVEL_DETAIL_API_NAME){
                if (type == ITINERARY_TYPE_DEPARTURE){
                    dt = travelDetail.departureDatetime;
                    dtarray = dt.split(WHITESPACE);
                    this.departureDate = dt.split(WHITESPACE)[0];
                    if(dtarray.size() >= 1 ){
                        this.journey.ETD__c= dt.split(WHITESPACE)[1];
                    }
                    if (this.travelLocationMap.containskey(td.Origin_Site__c) ){
                        airportList = this.travelLocationMap.get(td.Origin_Site__c).airports__r ;
                    }
                }
                if(type == ITINERARY_TYPE_RETURN){
                    dt = travelDetail.returnDatetime;
                    dtarray = dt.split(WHITESPACE);
                    this.departureDate = dt.split(WHITESPACE)[0];
                    if(dtarray.size() >= 1 ){
                        this.journey.ETD__c= dt.split(WHITESPACE)[1];
                    }                    
                    if (this.travelLocationMap.containskey(td.Destination__c) ){
                        airportList = this.travelLocationMap.get(td.Destination__c).airports__r ;
                    }                    
                }
                for(airport__c airportreader : airportList){
                    if(airportreader.Is_Primary__c){
                        this.journey.From_Airport__c = airportreader.id;
                    }
                }
                
                if (type == ITINERARY_TYPE_DEPARTURE){
                    airportList = new List <Airport__c>();
                    if (this.travelLocationMap.containskey(td.Destination__c) ){
                        airportList = this.travelLocationMap.get(td.Destination__c).airports__r ;
                    }
                }
                if (type == ITINERARY_TYPE_RETURN){
                     airportList = new List <Airport__c>();
                    if (this.travelLocationMap.containskey(td.Origin_Site__c) ){
                        airportList = this.travelLocationMap.get(td.Origin_Site__c).airports__r ;
                    }
                }
                
                for(airport__c airportreader : airportList){
                    if(airportreader.Is_Primary__c){
                        this.journey.To_Airport__C = airportreader.id;
                    }
                }
                
            }
        }
    }
    
    Public TETravelItineraryCtrl(TETravelApplicationCtrl travelApplicationCtrl, Journey__c journey){
        DateTime dt = null;
        this.Id = journey.Id;
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.journey = journey;
        this.travelLocationMap = this.travelApplicationCtrl.travelLocationMap;
        this.checkFlight = true;
        this.checkCabinClass = true;
        this.checkFrom = true;
        this.checkDeparture = true;
        this.checkETD = true;
        this.checkTo = true;
        this.checkArrival = true;
        this.checkETA = true;
        this.reqCheck = false;
        dt = this.journey.Departure_Date__c;
        if ( dt !=null){
            this.departureDate = dt.format(TETravelApplicationCtrl.Date_FORMAT);
        }
        
        dt = this.journey.Arrival_Date__c;
        if ( dt !=null){
            this.arrivalDate = dt.format(TETravelApplicationCtrl.Date_FORMAT);
        }
    }
    
    Public Void addRow(){
        this.travelApplicationCtrl.itineraryRows(this.id, ROW_ACTION_ADD);
    }
    
    Public Void RemoveRow(){
        if(this.journey.id != null){
            delete this.journey;
        }
        this.travelApplicationCtrl.itineraryRows(this.id, ROW_ACTION_REMOVE);

    }
    
    

}