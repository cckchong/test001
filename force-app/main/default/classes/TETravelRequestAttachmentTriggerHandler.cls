public class TETravelRequestAttachmentTriggerHandler {
    
    public static void InsertItinerary(List<Attachment> attachments){
        String ContentType = 'text/plain';
        String trRecordType = '';
        Attachment attachment = null;
        TEItinerary itinerary = null;
        Blob contentFile = null;
        Set <ID> trhset = new Set <ID>();
        Map<String, Attachment> attachmentMap = new Map<String, Attachment>();
        //Map<String, Travel_Location__c > TravelLocationMap = new Map<String, Travel_Location__c >();
        //Map<String, airport__c> airportMap = new Map<String, airport__c>();
        
        Map<ID, TEItinerary> itineraryMap = new Map<ID, TEItinerary>();
        Map<ID, String> flightClassMap = new Map<ID, String>();
        List <Journey__c> journeyList = new List <Journey__c>();
        List <Journey__c> journeyToBeList = new List <Journey__c>();
        //Set <String> locationSet = new Set <String>();
        Set <String> flightClassSet = new Set <String>();
        String fromCity = '';
        String toCity = '';
        String flightClassId =  null;
        String flightClassName = '';
        
        for ( RecordType  reader : [SELECT Id FROM RecordType where SobjectType = :TEConstant.JOURNEY_APPLICATION_OBJECT_NAME   and DeveloperName = :TEConstant.JOURNEY_AIR_DEVELOPERNAME and IsActive  = true]){
            trRecordType = reader.id;
        }
        
        for ( Attachment reader : [SELECT Body, ContentType, ParentId FROM Attachment where id in :attachments and ContentType = :ContentType ] ){
            attachmentMap.put( reader.ParentId, reader );
        }
        /*
        for ( Travel_Application__c tr : [ select id from Travel_Application__c where id in :attachmentMap.keyset()  and Travel_Application__c.status__c in (:TEConstant.STATUS_NOT_SUBMITTED, :TEConstant.STATUS_DRAFT, :TEConstant.STATUS_REJECT, :TEConstant.STATUS_CANCELLED) ]){
            trhset.add(tr.id);
        }
        */
        for ( Travel_Application__c tr : [select id, status__c,
              (select id, status__c from TravelOptions__r where status__c = 'CON')
              from Travel_Application__c 
              where id in :attachmentMap.keyset() //and status__c =:TEConstant.STATUS_CONFIRMED
            ]){
              if(tr.TravelOptions__r.size() > 0){
                  trhset.add(tr.id);
              }
        }
        
        if ( !trhset.isempty() ){
            for ( ID reader : trhset ){
                attachment = attachmentMap.get(reader);
                contentFile = attachment.Body;                
                itinerary = new TEItinerary( contentFile.tostring() );
                itineraryMap.put(reader, itinerary);
                for ( TETripInfo trip : itinerary.tripInfoList ){
                    //fromCity = trip.fromCity.replaceAll( ' ', '').toUpperCase();
                    //toCity = trip.toCity.replaceAll( ' ', '').toUpperCase();                    
                    //locationSet.add(fromCity);
                    //locationSet.add(toCity);
                    flightClassSet.add(trip.flightClass);
                    //trip.flightClass
                    //TravelLocationMap
                    //journeyList.add( new Journey__c (recordtypeid = trRecordType, Travel_Request__c = reader, Flight__c = trip.Flight, Class__c = trip.flightClass, Site__c = trip.fromCity, Departure_Date__c = trip.fromDate, Destination__c = trip.toCity, Arrival_Date__c = trip.toDate, ETD__c = trip.fromTime, ETA__c = trip.toTime, Tech_Is_Itinerary__c = true ) );
                }   
            }
            /*
            for ( Travel_Location__c reader : [select id, Tech_City_String__c  from Travel_Location__c where Tech_City_String__c in :locationSet ] ){
                TravelLocationMap.put ( reader.Tech_City_String__c, reader );
            }
            
            for (airport__c reader: [select id, name, travel_location__c, Tech_Airport_Name__c  from airport__c where Tech_Airport_Name__c in :locationSet ]){
                airportMap.put(reader.Tech_Airport_Name__c, reader);
            }
            */
            //
            for ( Cabin_Class__c reader : [select id, Cabin_Class_Full_Name__c from Cabin_Class__c where isDeleted = false] ){
                for ( String flightClass : flightClassSet ){
                    flightClassName =  ';'+reader.Cabin_Class_Full_Name__c.replaceAll( ' ', '').toUpperCase()+';';
                    if ( flightClassName.contains(';'+flightClass.replaceAll( ' ', '').toUpperCase()+';')){
                        flightClassMap.put ( reader.id, reader.Cabin_Class_Full_Name__c.replaceAll( ' ', '').toUpperCase());            
                    }
                }
            }
            //System.debug('~~~~~'); 
            //System.debug('keySet:' + TravelLocationMap.keySet() + '\n'); 
            //System.debug('values:' + TravelLocationMap.values() + '\n'); 
            flightClassId =  null;
            for ( ID reader : trhset ){
                itinerary = itineraryMap.get(reader);
                for ( TETripInfo trip : itinerary.tripInfoList ){
                    //fromCity = trip.fromCity.replaceAll( ' ', '').toUpperCase();
                    //toCity = trip.toCity.replaceAll( ' ', '').toUpperCase();
                    fromCity = trip.fromCity;
                    toCity = trip.toCity;
                    for ( ID classId : flightClassMap.keySet() ){                        
                        if ( flightClassMap.get(classId).contains(trip.flightClass.replaceAll( ' ', '').toUpperCase()) ){
                            flightClassId = classId;
                        }
                    }
                    journeyList.add(
                        new Journey__c (
                            recordtypeid = trRecordType, 
                            Travel_Application__c = reader, 
                            Cabin_Class__c = flightClassId,
                            Flight__c = trip.Flight,
                            //Class__c = trip.flightClass, 
                            //from_airport__c = airportMap.get(fromCity).id,
                            //to_airport__c = airportMap.get(toCity).id,
                            Departure_Date__c = trip.fromDate,                            
                            From_Airport_Text__c = fromCity ,
                            To_Airport_Text__c = toCity,                            
                            //Origin_Site__c = airportMap.get(fromCity).Travel_Location__c,
                            //Destination__c = airportMap.get(toCity).Travel_Location__c,                            
                            Arrival_Date__c = trip.toDate, 
                            ETD__c = trip.fromTime, 
                            ETA__c = trip.toTime, 
                            Tech_Is_Itinerary__c = true,
                            //,remarks__c = fromCity +'/'+toCity+'/'+airportMap + '//'+locationSet 
                            status__c = ''
                            ) 
                    );
                }
            }
            
            for ( Journey__c reader : [select id from Journey__c where Travel_Application__c in :trhset and Tech_Is_Itinerary__c = true  and Travel_Application__r.status__c in (:TEConstant.STATUS_NOT_SUBMITTED, :TEConstant.STATUS_DRAFT, :TEConstant.STATUS_REJECT, :TEConstant.STATUS_CANCELLED) ] ){
              journeyToBeList.add(reader);  
            }
            if (!journeyToBeList.isempty()){
                delete journeyToBeList;
            }
            if (!journeyList.isempty()){
                insert journeyList;
            }
        }
        
    }
}