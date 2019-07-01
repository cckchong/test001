/**
 * TravelDistanceTriggerHandler
 * @author Kelvin Wong
 * @description trigger of Travel Distance
 */
public class TravelDistanceTriggerHandler {
    
    /**
     * @description put flight type if empty, prompt error if flight type does not match with travel distance
     * @param oldMap old map given by trigger
     * @param newList new list given by trigger
     * @param isInsert whether the trigger is invoked by insert
     */
    public static void checkFlightTypeWithDistance(Map<Id, Travel_Distance__c> oldMap, List<Travel_Distance__c> newList, boolean isInsert){
        
        List <Flight_Type__c> flightTypeList = new List <Flight_Type__c>([select Id, Min_Range__c, Max_Range__c from Flight_Type__c where isdeleted = false]);
        for (Travel_Distance__c td : newList){
           /*
            if (td.From__c == td.To__c) {
                td.addError(Label.TE_Travel_Distance_Same_Location);
            } else 
            */
            if (td.Flight_Type__c != null) {
                // if there is a flight type, check whether travel distance is valid
                boolean check = false;
                //for (Flight_Type__c ft : [select Id from Flight_Type__c where Min_Range__c < :td.distance__c AND Max_Range__c >= :td.distance__c]){
                for (Flight_Type__c ft : flightTypeList ){
                    if (ft.Min_Range__c < td.distance__c && ft.Max_Range__c >= td.distance__c){
                        if (td.Flight_Type__c == ft.Id)
                            check = true;
                    }
                }
                if (!check){
                    td.addError(Label.TE_Travel_Distance_Flight_Type_Not_Match_Distance);
                    td.Flight_Type__c.addError(Label.TE_Travel_Distance_Flight_Type_Not_Match_Distance_Field_Hint);
                }
            } else {
                // if flight type is empty, assign a flight type to the empty field
                //for (Flight_Type__c ft : [select Id from Flight_Type__c where Min_Range__c < :td.distance__c AND Max_Range__c >= :td.distance__c LIMIT 1]){
                for (Flight_Type__c ft : flightTypeList){
                    if (ft.Min_Range__c < td.distance__c && ft.Max_Range__c >= td.distance__c){
                        td.Flight_Type__c = ft.Id;
                    }
                }
            }
        }
    }
    
     public static void createCarbonEmission(Map<Id, Travel_Distance__c> newMap){
         List <GHG_Factor__c> GHGFactorList = new List<GHG_Factor__c>([select id, Flight_Type__c from GHG_Factor__c where isdeleted = false]);
         List<Carbon_Emission__c> carbonEmissionList = new List<Carbon_Emission__c>();
         for(Travel_Distance__c reader : newMap.values()){
             for(GHG_Factor__c gf : GHGFactorList){
                 if (reader.Flight_Type__c == gf.Flight_Type__c){ 
                     carbonEmissionList.add(new Carbon_Emission__c( Name = reader.From_City__c +'-'+ reader.To_City__c, Travel_Distance__c = reader.id, GHG_Factor__c = gf.id));
                 }
             }
         }
         if(!carbonEmissionList.isempty()){
             insert carbonEmissionList;
         }
     }
    
}