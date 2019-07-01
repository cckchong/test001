/**
 * TravelDistanceTriggerHandler
 * @author Kelvin Wong
 * @description trigger of Carbon Emission
 */
public class TECarbonEmissionTriggerHandler {

    /**
     * @description get travel distance flight type map
     * @return a map binding ID with Travel Distance
     */
    private static Map<Id, Travel_Distance__c> getTravelDistanceFlightType(List<Id> tdList){
        
        Map<Id, Travel_Distance__c> tmpMap = new Map<Id, Travel_Distance__c>();
        
        for (Travel_Distance__c ft : [select Id, Flight_Type__c from Travel_Distance__c where Id IN :tdList]){
            tmpMap.put(ft.Id, ft);
        }
       
        return tmpMap;
        
    }
    
    /**
     * @description get GHG Factor flight type map
     */
    private static Map<Id, GHG_Factor__c> getGHGFactorFlightType(List<Id> gfList){
        
        Map<Id, GHG_Factor__c> tmpMap = new Map<Id, GHG_Factor__c>();
        
        for (GHG_Factor__c ft : [select Id, Flight_Type__c from GHG_Factor__c where Id IN :gfList]){
            tmpMap.put(ft.Id, ft);
        }
        
        return tmpMap;
    }
    
    /**
     * @description compare flight type of travel distance and flight type of GHG Factor
     */
    public static void checkDistanceWithGHGFactor(Map<Id, Carbon_Emission__c> oldMap, List<Carbon_Emission__c> newList, boolean isInsert){
        
        Map<Id, Id> travelDistanceMap = new Map<Id, Id>();
        Map<Id, Integer> carbonEmissionPosMap = new Map<Id, Integer>();
        Map<Id, Id> carbonEmissionIdMap = new Map<Id, Id>();
        List<Id> travalDistanceList = new List<Id>();
        List<Id> ghgFactorList = new List<Id>();
        Carbon_Emission__c ce;
        
        for (Integer i = 0; i < newList.size(); ++i){
            ce = newList.get(i);
            travelDistanceMap.put(ce.Travel_Distance__c, ce.GHG_Factor__c);
            travalDistanceList.add(ce.Travel_Distance__c);
            ghgFactorList.add(ce.GHG_Factor__c);
            carbonEmissionPosMap.put(ce.Travel_Distance__c, i);
            carbonEmissionIdMap.put(ce.Travel_Distance__c, ce.Id);
        }
        
        Map<Id, Travel_Distance__c> tdMap = getTravelDistanceFlightType(travalDistanceList);
        Map<Id, GHG_Factor__c> gfMap = getGHGFactorFlightType(ghgFactorList);
        
        for (Id tdId : tdMap.keySet()){
            if (gfMap.get(travelDistanceMap.get(tdId)).Flight_Type__c != tdMap.get(tdId).Flight_Type__c){
                if (isInsert){
                    newList.get(carbonEmissionPosMap.get(tdId)).addError(Label.TE_Carbon_Emission_Different_Flight_Type);
                } else {
                    oldMap.get(carbonEmissionIdMap.get(tdId)).addError(Label.TE_Carbon_Emission_Different_Flight_Type);
                }
            }
        }
    }
    
}