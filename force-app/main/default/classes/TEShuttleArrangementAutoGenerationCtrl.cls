public without sharing class TEShuttleArrangementAutoGenerationCtrl {

 
    public static void autoGeneration(){
    
        Map<String,Car_Journey__c> newShuttleArrangementMap = new Map<String,Car_Journey__c> ();
        Map<String,Car_Journey__c> currentShuttleArrangementMap = new Map<String,Car_Journey__c> ();
        
        List<Car_Journey__c> currentShuttleArrangementList = new List<Car_Journey__c> ();
        List<Route__c> routeList = new List<Route__c> ();        
        Car_Journey__c shuttleArrangement = new Car_Journey__c();
        Datetime dt = null;
        date startDate = date.today();
        Integer numberOfDays = 90;
        String mapKey = '';
        
        routeList = [SELECT Id, Name, Default_Car__c, Default_Car__r.Driver__c, 
                     Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c
                     FROM Route__c];
                    
        if(!routeList.isempty()){      
        
            currentShuttleArrangementList = [SELECT Id, Name, Route__c, Date__c, Company_Car__c, Active__c, Driver__c FROM Car_Journey__c Where Active__c = true];

            for(Car_Journey__c reader: currentShuttleArrangementList){
                currentShuttleArrangementMap.put(String.valueOf(reader.Date__c) + String.valueOf(reader.Route__c),reader);
            }    
            for(Integer i = 0; i < numberOfDays; i++){
                for(Route__c reader : routeList){
                    shuttleArrangement = new Car_Journey__c();
                    shuttleArrangement.Active__c = false;
                    shuttleArrangement.Date__c = startDate.addDays(i);
                    dt = DateTime.newInstance(shuttleArrangement.Date__c, Time.newInstance(0, 0, 0, 0));
                    if ( dt.format('u') == '1' && reader.Monday__c ){
                        shuttleArrangement.Active__c = true;
                    }
                    if ( dt.format('u') == '2' && reader.Tuesday__c ){
                        shuttleArrangement.Active__c = true;
                    }
                    if ( dt.format('u') == '3' && reader.Wednesday__c ){
                        shuttleArrangement.Active__c = true;
                    }
                    if ( dt.format('u') == '4' && reader.Thursday__c ){
                        shuttleArrangement.Active__c = true;
                    }
                    if ( dt.format('u') == '5' && reader.Friday__c){
                        shuttleArrangement.Active__c = true;
                    }
                    if ( dt.format('u') == '6' && reader.Saturday__c ){
                        shuttleArrangement.Active__c = true;
                    }
                    if ( dt.format('u') == '7' && reader.Sunday__c){
                        shuttleArrangement.Active__c = true;
                    }
                    shuttleArrangement.Route__c = reader.Id;
                    shuttleArrangement.Company_Car__c = reader.Default_Car__c;
                    shuttleArrangement.Driver__c = reader.Default_Car__r.Driver__c;
                    
                    mapKey = String.valueOf(shuttleArrangement.Date__c) + String.valueOf(shuttleArrangement.Route__c);
                    
                    if(!currentShuttleArrangementMap.containsKey(mapKey)){
                        newShuttleArrangementMap.put(mapKey,shuttleArrangement);
                    }
                   
                }
            }
            
            insert newShuttleArrangementMap.values();
        }
        

    }
     

}