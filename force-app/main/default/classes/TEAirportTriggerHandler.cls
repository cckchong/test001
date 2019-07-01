public class TEAirportTriggerHandler {
    
    public static void addTravelDistance(List<AirPort__c> airportList) {
        
        List <Travel_Distance__C> travelDistanceList = new List <Travel_Distance__C>();
        for (AirPort__c reader : airportList){
            travelDistanceList.add(new Travel_Distance__C(name=reader.name, From_Airport__c = reader.id, To_Airport__c = reader.id, distance__c = 0  ));
        }
        if(!travelDistanceList.isEmpty()){
            insert travelDistanceList;
        }
    }

}