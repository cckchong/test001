public class TEShuttleAssignmentUpdateUtil {

    public static void updateOccupiedSeats(Map<Id,Travel_Detail__c> oldJourneyMap, List<Travel_Detail__c> newJourneyList) {
        Map<Id, Integer> journeyToSeatCount = new Map<Id, Integer>();
        Integer count;
        // if it is delete        
        if (newJourneyList == null){
            for (Travel_Detail__c j : oldJourneyMap.values()){
                //departure shuttle
                if (j.Departure_Assigned_Shuttle__c != null){
                    if(journeyToSeatCount.get(j.Departure_Assigned_Shuttle__c) != null) {
                        count = journeyToSeatCount.get(j.Departure_Assigned_Shuttle__c);
                        count = count - Integer.valueOf(j.No_of_Seats__c);
                        journeyToSeatCount.put(j.Departure_Assigned_Shuttle__c, count);
                    } else {
                        count = 0;
                        count = count - Integer.valueOf(j.No_of_Seats__c);
                        journeyToSeatCount.put(j.Departure_Assigned_Shuttle__c, count); 
                    }
                }
                //return shuttle
                if (j.Return_Assigned_Shuttle__c != null){
                    if(journeyToSeatCount.get(j.Return_Assigned_Shuttle__c) != null) {
                        count = journeyToSeatCount.get(j.Return_Assigned_Shuttle__c);
                        count = count - Integer.valueOf(j.No_of_Seats__c);
                        journeyToSeatCount.put(j.Return_Assigned_Shuttle__c, count);
                    } else {
                        count = 0;
                        count = count - Integer.valueOf(j.No_of_Seats__c);
                        journeyToSeatCount.put(j.Return_Assigned_Shuttle__c, count); 
                    }
                }
            }
        }
        // if it is update
        else {
            For (Travel_Detail__c j : newJourneyList){
                //departure shuttle
                if (oldJourneyMap.get(j.Id).Departure_Assigned_Shuttle__c != j.Departure_Assigned_Shuttle__c){
                    if (j.Departure_Assigned_Shuttle__c != null) {
                        if(journeyToSeatCount.get(j.Departure_Assigned_Shuttle__c ) != null) {
                            count = journeyToSeatCount.get(j.Departure_Assigned_Shuttle__c);
                            count = count + Integer.valueOf(j.No_of_Seats__c);
                            journeyToSeatCount.put(j.Departure_Assigned_Shuttle__c, count);
                        } 
                        else {
                            count = 0;
                            count = count + Integer.valueOf(j.No_of_Seats__c);
                            journeyToSeatCount.put(j.Departure_Assigned_Shuttle__c, count); 
                        }
                    } 
                    else {
                        if(journeyToSeatCount.get(oldJourneyMap.get(j.Id).Departure_Assigned_Shuttle__c) != null) {
                            count = journeyToSeatCount.get(oldJourneyMap.get(j.Id).Departure_Assigned_Shuttle__c);
                            count = count - Integer.valueOf(oldJourneyMap.get(j.Id).No_of_Seats__c);
                            journeyToSeatCount.put(oldJourneyMap.get(j.Id).Departure_Assigned_Shuttle__c, count);
                        } else {
                            count = 0;
                            count = count - Integer.valueOf(oldJourneyMap.get(j.Id).No_of_Seats__c);
                            journeyToSeatCount.put(oldJourneyMap.get(j.Id).Departure_Assigned_Shuttle__c, count); 
                        }
                    }
                    
                }
                if (oldJourneyMap.get(j.Id).Return_Assigned_Shuttle__c != j.Return_Assigned_Shuttle__c){
                    if (j.Return_Assigned_Shuttle__c != null) {
                        if(journeyToSeatCount.get(j.Return_Assigned_Shuttle__c) != null) {
                            count = journeyToSeatCount.get(j.Return_Assigned_Shuttle__c);
                            count = count + Integer.valueOf(j.No_of_Seats__c);
                            journeyToSeatCount.put(j.Return_Assigned_Shuttle__c, count);
                        } 
                        else {
                            count = 0;
                            count = count + Integer.valueOf(j.No_of_Seats__c);
                            journeyToSeatCount.put(j.Return_Assigned_Shuttle__c, count); 
                        }
                    } 
                    else {
                        if(journeyToSeatCount.get(oldJourneyMap.get(j.Id).Return_Assigned_Shuttle__c) != null) {
                            count = journeyToSeatCount.get(oldJourneyMap.get(j.Id).Return_Assigned_Shuttle__c);
                            count = count - Integer.valueOf(oldJourneyMap.get(j.Id).No_of_Seats__c);
                            journeyToSeatCount.put(oldJourneyMap.get(j.Id).Return_Assigned_Shuttle__c, count);
                        } else {
                            count = 0;
                            count = count - Integer.valueOf(oldJourneyMap.get(j.Id).No_of_Seats__c);
                            journeyToSeatCount.put(oldJourneyMap.get(j.Id).Return_Assigned_Shuttle__c, count); 
                        }
                    }
                    
                }
            }
        }
        //if (journeyToSeatCount != NULL && !journeyToSeatCount.keyset().isEmpty()){
        if (!journeyToSeatCount.isEmpty()){
            List<Car_Journey__c> cjl = new List<Car_Journey__c>();
            for(Car_Journey__c cj : [SELECT Id, Occupied_Seats__c, Available_Seats__c FROM Car_Journey__c WHERE Id IN: journeyToSeatCount.keyset()]) {
                cj.Occupied_Seats__c = cj.Occupied_Seats__c + journeyToSeatCount.get(cj.Id);
                cjl.add(cj);
            }
            
            update cjl;
        }
    }
}