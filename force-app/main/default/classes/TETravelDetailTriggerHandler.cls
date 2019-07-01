public class TETravelDetailTriggerHandler{

    public static void shuttleAssignmentUpdate(Map<Id,Travel_Detail__c> oldJourneyMap, List<Travel_Detail__c> newJourneyList) {
        TEShuttleAssignmentUpdateUtil.updateOccupiedSeats(oldJourneyMap, newJourneyList);
    }
    
}