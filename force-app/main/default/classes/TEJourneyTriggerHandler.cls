public class TEJourneyTriggerHandler {

    //Public final Static String DATE_PARAMETER = '@date';
    Public final Static String STATUS_DELETED = 'DEL';
    /**
    public static void carAssignmentUpdate(List<Journey__c> journeyList) {
        TEJourneyCarAssignmentUpdateUtil.updateOccupiedSeats(journeyList);
    }
    */
    
    /*
    public static void checkGHGSetting(List<Journey__c> JourneyList, Map<ID, Journey__c> oldJourneyMap, String type){
        List<Journey__c> journeydCheckList = new List<Journey__c>();
        List<travel_distance__c> travelDistanceList = new List<travel_distance__c>();
        
        if ( type == 'I'){
            for(Journey__c reader : JourneyList){
                if(reader.Cabin_Class__c != null){
                    journeydCheckList.add(reader);
                }
            }
        }
        if ( type == 'U'){
            for(Journey__c reader : JourneyList){
                if(reader.Cabin_Class__c != null &&( reader.From_Airport__c != oldJourneyMap.get(reader.id).From_Airport__c || reader.To_Airport__c != oldJourneyMap.get(reader.id).To_Airport__c )){
                    journeydCheckList.add(reader); 
                }
            }
        }
        TEValidationsController.checkGHGSetting(journeydCheckList);
    }
    
    public static void checkTripDetailsIfPlaceIsOthers(List<Journey__c> journeyList) {
    
        List<Travel_Location__c> location = new List<Travel_Location__c>();
        for (Travel_Location__c tl : [select Id from Travel_Location__c where Country__c = 'OTHERS']) {
            location.add(tl);
        }
        if (location.isEmpty()) return;
        for (Journey__c j : journeyList) {
            if ((j.Origin_Site__c == location.get(0).Id || j.Destination__c == location.get(0).Id) && String.isBlank(j.Remarks__c)) {
                j.addError(Label.TE_Travel_Location_Specify_Other_Places);
                j.Remarks__c.addError(Label.TE_Travel_Location_Specify_Other_Places_Hint);
            }
        }
    }
    
    Public static Void checkdate(List<Journey__c> journeyList){
        String msg = '';
        for (Journey__c j : journeyList) {
            if(!j.Tech_Is_Itinerary__c){
                if (j.Arrival_Date__c != null && j.Arrival_Date__c > j.Travel_Return_Date__c){
                    msg = Label.TE_Journey_Arrival_Date_Error;
                    msg = msg.replace(DATE_PARAMETER, ( Datetime.newInstance(j.Travel_Return_Date__c.year() , j.Travel_Return_Date__c.month(), j.Travel_Return_Date__c.day()).format('dd MMM yyyy')));
                    j.Arrival_Date__c.adderror(msg);
                }
                if (j.Return_Date__c != null &&  j.Return_Date__c > j.Travel_Return_Date__c){
                    msg = Label.TE_Journey_Arrival_Date_Error;
                    msg = msg.replace(DATE_PARAMETER, ( Datetime.newInstance(j.Travel_Return_Date__c.year() , j.Travel_Return_Date__c.month(), j.Travel_Return_Date__c.day()).format('dd MMM yyyy')));
                    j.Return_Date__c.adderror(msg);
                }
                if (j.Departure_Date__c != null &&  j.Departure_Date__c < j.Travel_Departure_Date__c){
                    msg = Label.TE_Journey_Departure_Date_Error;
                    msg = msg.replace(DATE_PARAMETER, ( Datetime.newInstance(j.Travel_Departure_Date__c.year() , j.Travel_Departure_Date__c.month(), j.Travel_Departure_Date__c.day()).format('dd MMM yyyy')));
                    j.Departure_Date__c.adderror(msg);
                }
            }
        }
    }
    */
    /**
    Public static Void journeyLogUpdate(List<Journey__c> journeyList){

        List<String> travelApplicationIdList = new List<String>();
        List<String> JourneyFromIdList = new List<String>();
        List<String> JourneyToIdList = new List<String>();
        List<Journey_Log__c> deleteJourneyLogList = new List<Journey_Log__c>();

        for(Journey__c reader: journeyList){
            travelApplicationIdList.add(reader.Travel_Application__c);
            JourneyFromIdList.add(reader.Origin_Site__c);
            JourneyToIdList.add(reader.Destination__c);
        }
        
        if(!travelApplicationIdList.isempty()){
        
            deleteJourneyLogList = [SELECT Id, Travel_Application__c FROM Journey_Log__c WHERE Travel_Application__c =: travelApplicationIdList];
        }

        if(!travelApplicationIdList.isempty()){
            delete deleteJourneyLogList;
        }    
    } **/
    /*
    private static void addErrorLines(List<Journey__c> newList, Map<Id, String> errMap, Map<Id, Integer> journeyPosMap){
        // Concat the two types of error and add error to status field or object itself
        String errorLine;
        Integer errorPosition;
        String cutErr = '';
        for (Id jId : errMap.keySet()) {
            errorLine = errMap.get(jId);
            errorPosition = journeyPosMap.get(jId);
            if (!String.isBlank(errorLine)) {
                cutErr = errorLine.substring(0, errorLine.length()-2);
                //newList.get(errorPosition).Status__c.addError(cutErr);
                newList.get(errorPosition).addError(cutErr);
            }
        }
    }
    */
    /** 
     * Add new journey logs upon update/insert
     */
    /*
    Public static Void addJourneyLog(List<Journey__c> newList){
        if(newList.isempty()){
            return;
        }
        List<Journey_Log__c> logToInsertList = new List<Journey_Log__c>();
        Map<Id, Journey__c> journeyMap = new Map<Id, Journey__c>();
        Map<Id, Journey__c> detailedJourneyMap = new Map<Id, Journey__c>();
        List<Id> journeyIdList = new List<Id>();
        Map<Id, Integer> journeyPosMap = new Map<Id, Integer>();
        List<Id> airportIdList = new List<Id>();
        Map<Id, String> airportNameMap = new Map<Id, String>();
        List<String> siteNamePairList = new List<String>();
        List<String> flightClassShortNameList = new List<String>();
        List<String> fromToCabinClassFlightTypeList = new List<String>();
        Map<String, Travel_Distance__c> travelDistanceTechNameMap = new Map<String, Travel_Distance__c>();
        Map<String, Ghg_Factor__c> ghgFactorTechTypeMap = new Map<String, Ghg_Factor__c>();
        List<String> cabinClassFlightTypePairList = new List<String>();
        Map<Id, GHG_Factor__c> ghgFactorMap = new Map<Id, GHG_Factor__c>();
        Map<String, Carbon_Emission__c> carbonEmissionTechTypeMap = new Map<String, Carbon_Emission__c>();
        List<Carbon_Emission__c> insertEmissionList = new List<Carbon_Emission__c>();
        List<Id> insertEmissionIdList = new List<Id>();
        
        Map<Id, Travel_Application__c> travelApplicationMap = new Map<Id, Travel_Application__c>();
        List<Id> travelApplicationIdList = new List<Id>();
         
        Map<Id, Travel_Distance__c> travelDistanceMap = new Map<Id, Travel_Distance__c>();
        Map<Id, Carbon_Emission__c> carbonEmissionMap = new Map<Id, Carbon_Emission__c>();
        string err;
        Map<Id, String> errMap = new Map<Id, String>();
        integer count = 0;
        
        for (Journey__c journey : newList) {
            if (journey.Status__c == TEConstant.STATUS_CONFIRMED){
                journeyMap.put(journey.Id, journey);
                journeyIdList.add(journey.Id);
                travelApplicationIdList.add(journey.Travel_Application__c);
            }
            journeyPosMap.put(journey.Id, count);
            ++count;
        }
        if (journeyMap.isEmpty()) return;

        for (Journey__c journey: [select id, Cabin_Class__r.Tech_Keyword__c, Departure_Date__c,
                                    Cabin_Class__r.Name, From_Airport__r.Travel_Location__r.City__c, From_Airport__r.Airport_Code__c,
                                    To_Airport__r.Travel_Location__r.City__c, To_Airport__r.Airport_Code__c,
                                    From_Airport__r.Tech_Airport_Name__c, To_Airport__r.Tech_Airport_Name__c
                                  from Journey__c where id IN : journeyIdList]){
            flightClassShortNameList.add(journey.Cabin_Class__r.Tech_Keyword__c);
            siteNamePairList.add(journey.From_Airport__r.Tech_Airport_Name__c + journey.To_Airport__r.Tech_Airport_Name__c);
            detailedJourneyMap.put(journey.id, journey);
        }

        for (Travel_Distance__c dist : [select Id, Flight_Type__r.Name, Flight_Type__r.Short_Name__c, Distance__c, Tech_From_To__c 
                                            from Travel_Distance__c 
                                            where Tech_From_To__c IN :siteNamePairList]){
            travelDistanceTechNameMap.put(dist.Tech_From_To__c, dist);
        }
        
        // Catch no Travel Distance
        string journeyId;
        Travel_Distance__c distance;
        for (Integer i = 0; i < siteNamePairList.size(); ++i) {
            journeyId = journeyIdList.get(i);
            if (errMap.containsKey(journeyId)) {
                err = errMap.get(journeyId);
            } else {
                err = '';
            }
            if (!travelDistanceTechNameMap.containsKey(siteNamePairList.get(i))) {
                err = TEValidationsController.checkExistingTravelDistance(detailedJourneyMap, journeyId, err);
                errMap.put(journeyId, err);
            } else {
                distance = travelDistanceTechNameMap.get(siteNamePairList.get(i));
                cabinClassFlightTypePairList.add(distance.Flight_Type__r.Short_Name__c + flightClassShortNameList.get(i));
                travelDistanceMap.put(journeyId, distance);
            }
        }
                
        if (!errMap.isEmpty()) {
            addErrorLines(newList, errMap, journeyPosMap);
            return;
        }
        
        for (Ghg_Factor__c factor : [select Id, Tech_Flight_Type_Cabin_Class__c 
                                     from Ghg_Factor__c 
                                     where Tech_Flight_Type_Cabin_Class__c IN :cabinClassFlightTypePairList]) {
            ghgFactorTechTypeMap.put(factor.Tech_Flight_Type_Cabin_Class__c, factor);
        }

        Ghg_Factor__c ghgFactor;

        // Catch no GHG Factor
        for (Integer i = 0; i < cabinClassFlightTypePairList.size(); ++i) {
            journeyId = journeyIdList.get(i);
            if (errMap.containsKey(journeyId)) {
                err = errMap.get(journeyId);
            } else {
                err = '';
            }
            if (!ghgFactorTechTypeMap.containsKey(cabinClassFlightTypePairList.get(i))) {
                err = TEValidationsController.checkExistingGHGFactor(detailedJourneyMap, journeyId, err);
                errMap.put(journeyId, err);
            } else {
                ghgFactor = ghgFactorTechTypeMap.get(cabinClassFlightTypePairList.get(i));
                fromToCabinClassFlightTypeList.add(travelDistanceMap.get(journeyId).Tech_From_To__c + cabinClassFlightTypePairList.get(i));
                ghgFactorMap.put(journeyId, ghgFactor);
            }
        }
        
        if (!errMap.isEmpty()) {
            addErrorLines(newList, errMap, journeyPosMap);
            return;
        }
        
        for (Carbon_Emission__c emission : [select Id, Tech_Travel_Distance_GHG_Factor__c 
                                            from Carbon_Emission__c 
                                            where Tech_Travel_Distance_GHG_Factor__c IN :fromToCabinClassFlightTypeList]){
            carbonEmissionTechTypeMap.put(emission.Tech_Travel_Distance_GHG_Factor__c, emission);
        }

        Carbon_Emission__c emission;

        // Catch no Carbon Emission, create one if needed
        for (Integer i = 0; i < fromToCabinClassFlightTypeList.size(); ++i) {
            emission = carbonEmissionTechTypeMap.get(fromToCabinClassFlightTypeList.get(i));
            journeyId = journeyIdList.get(i);
            if (emission == null) {
                insertEmissionList.add(new Carbon_Emission__c (
                    GHG_Factor__c = ghgFactorMap.get(journeyId).Id,
                    Travel_Distance__c = travelDistanceMap.get(journeyId).Id
                ));
                insertEmissionIdList.add(journeyId);
            } else {
                carbonEmissionMap.put(journeyId, emission);
            }
        }

        if (!insertEmissionList.isEmpty()) {
            insert insertEmissionList;
            for (Integer i = 0; i < insertEmissionList.size(); ++i) {
                carbonEmissionMap.put(insertEmissionIdList.get(i), insertEmissionList.get(i));
            }
        }
        
        for (Travel_Application__c ta : [select Id, Applicant__c, On_Behalf_of__c, On_Behalf_of__r.Employee__c, On_Behalf_of__r.Employee__r.Name,
                                                On_Behalf_of_Function__c, Apply_Date__c, From_Site__c, On_Behalf_of__r.employee__r.travel_policy__r.Name,
                                                status__c
                                            from Travel_Application__c
                                            where Id IN :travelApplicationIdList ]){
            travelApplicationMap.put(ta.Id, ta);
        }

        Id travelAppId;
        for (Id journeyItemId : journeyIdList){
            // Build up journey log
            travelAppId = journeyMap.get(journeyItemId).Travel_Application__c;
            logToInsertList.add(new Journey_Log__c (
                Name = journeyMap.get(journeyItemId).Name,
                Journey__c = journeyItemId,
                Applicant__c = travelApplicationMap.get(travelAppId).On_Behalf_of__r.Employee__r.Name,
                Department__c = travelApplicationMap.get(travelAppId).On_Behalf_of_Function__c,
                Departure_Date__c = detailedJourneyMap.get(journeyItemId).Departure_Date__c,
                Claim_Date__c = travelApplicationMap.get(travelAppId).Apply_Date__c,
                Cabin_Class__c = detailedJourneyMap.get(journeyItemId).Cabin_Class__r.Name,
                Location__c = travelApplicationMap.get(travelAppId).From_Site__c,
                Trip_From__c = detailedJourneyMap.get(journeyItemId).From_Airport__r.Travel_Location__r.City__c,
                Trip_From_City_Code__c = detailedJourneyMap.get(journeyItemId).From_Airport__r.Airport_Code__c,
                Trip_To__c = detailedJourneyMap.get(journeyItemId).To_Airport__r.Travel_Location__r.City__c,
                Trip_To_City_Code__c = detailedJourneyMap.get(journeyItemId).To_Airport__r.Airport_Code__c,
                Flight_Type__c = travelDistanceMap.get(journeyItemId).Flight_Type__r.Name,
                Distance__c = travelDistanceMap.get(journeyItemId).Distance__c,
                Carbon_Emission__c = carbonEmissionMap.get(journeyItemId).Id,
                Travel_Application__c = travelAppId,
                Status__c =  travelApplicationMap.get(travelAppId).status__c,
                Travel_Policy_Name__c = travelApplicationMap.get(travelAppId).On_Behalf_of__r.employee__r.travel_policy__r.Name
            ));
        }
        if (!logToInsertList.isEmpty()) {
            insert logToInsertList;
        }     
        //TEManualSharingCtrl.journeyLogSharing(newList,true);
    }
    */
    /** 
     * Add new journey logs upon update
     * to offset the existing log and log the new one
     */
    public static void updateJourneyLog(List<Journey__c> newList, Map<ID, Journey__c> oldMap){
        List<Journey__c> cancelledJourneyList = new List<Journey__c>();
        List<Journey__c> updatedJourneyList = new List<Journey__c>();
        
        for (Journey__c journey : newList) {
            //if (oldMap.get(journey.Id).Status__c == TEConstant.STATUS_CONFIRMED && journey.Status__c == TEConstant.STATUS_CANCELLED){
            if (oldMap.get(journey.Id).Status__c != journey.Status__c && journey.Status__c == TEConstant.STATUS_CANCELLED){
                cancelledJourneyList.add(journey);
            }
            /**
            else if ((journey.Status__c == TEConstant.STATUS_CONFIRMED)&&
                    ((oldMap.get(journey.Id).From_Airport__c != journey.From_Airport__c)||
                     (oldMap.get(journey.Id).To_Airport__c != journey.To_Airport__c)||
                     (oldMap.get(journey.Id).Cabin_Class__c != journey.Cabin_Class__c))) {
                updatedJourneyList.add(journey);
            }
            **/
        }
        addOffsetJourneyLog(cancelledJourneyList, 'CN');
        //addOffsetJourneyLog(updatedJourneyList, 'D');
        //addJourneyLog(updatedJourneyList);   
    }
    /** 
     * Add new journey logs upon delete/insert
     * to offset the existing logs
     * type: deleted, cancelled
     */
    Public static Void addOffsetJourneyLog(List<Journey__c> oldList, string type){
        List<String> journeyNameList = new List<String>();
        //List<Id> journeyIdList = new List<Id>();
        List<Journey_Log__c> jlList = new List<Journey_Log__c>();
        List<Journey_Log__c> toOffsetList = new List<Journey_Log__c>();
        List<Journey_Log__c> logToInsertList = new List<Journey_Log__c>();
        
        if (oldList.isempty()){
            return;
        }
        for (Journey__c journey : oldList) {
                journeyNameList.add(journey.Name);
        }
        
        for (Journey_Log__c jl : [SELECT Id, Name, Journey__c, Applicant__c, Department__c, Departure_Date__c, Claim_Date__c, Cabin_Class__c,
                                        Location__c, Trip_From__c, Trip_From_City_Code__c, Trip_To__c, Trip_To_City_Code__c,
                                        Flight_Type__c, Distance__c, Carbon_Emission__c, Travel_Application__c, Status__c, 
                                        Travel_Policy_Name__c, Is_Error__c, Remarks__c
                                            FROM Journey_Log__c WHERE Name IN :journeyNameList 
                                                                AND 
                                                                Status__c = :TEConstant.STATUS_CONFIRMED
                                            ORDER BY Name, CreatedDate DESC]){
            jlList.add(jl);
        }
               
        for (String jName : journeyNameList){
            for (Journey_Log__c jl : jlList) {
                if (jName == jl.Name) {
                    toOffsetList.add(jl);
                    break;
                }
            }
        }
        
        string status;
        if (type == 'D') {
            status = STATUS_DELETED;
        }
        else {
            status = TEConstant.STATUS_CANCELLED;
        }
        for (Journey_Log__c jl : toOffsetList) {
            
            logToInsertList.add(new Journey_Log__c (
                Name = jl.Name,
                Journey__c = jl.Journey__c,
                Applicant__c = jl.Applicant__c,
                Department__c = jl.Department__c,
                Departure_Date__c = jl.Departure_Date__c,
                Claim_Date__c = jl.Claim_Date__c,
                Cabin_Class__c = jl.Cabin_Class__c,
                Location__c = jl.Location__c,
                Trip_From__c = jl.Trip_From__c,
                Trip_From_City_Code__c = jl.Trip_From_City_Code__c,
                Trip_To__c = jl.Trip_To__c,
                Trip_To_City_Code__c = jl.Trip_To_City_Code__c,
                Flight_Type__c = jl.Flight_Type__c,
                Distance__c = jl.Distance__c,
                Carbon_Emission__c = jl.Carbon_Emission__c,
                Travel_Application__c = jl.Travel_Application__c,
                Status__c =  status,
                Travel_Policy_Name__c = jl.Travel_Policy_Name__c,
                Is_Error__c = jl.Is_Error__c,
                Remarks__c = jl.Remarks__c
            ));
        }
        if (!logToInsertList.isempty()){
            insert logToInsertList;
        }
    }
    
    
    Public static Void addEmptyJourneyLog(List<Journey__c> newList){
        if(newList.isempty()){
            return;
        }
        List<Journey_Log__c> logToInsertList = new List<Journey_Log__c>();
        Map<Id, Journey__c> journeyMap = new Map<Id, Journey__c>();
        Map<Id, Journey__c> detailedJourneyMap = new Map<Id, Journey__c>();
        List<Id> journeyIdList = new List<Id>();
        Map<Id, Integer> journeyPosMap = new Map<Id, Integer>();
        List<Id> airportIdList = new List<Id>();
        Map<Id, String> airportNameMap = new Map<Id, String>();
        List<String> siteNamePairList = new List<String>();
        List<String> flightClassShortNameList = new List<String>();
        List<String> fromToCabinClassFlightTypeList = new List<String>();
        Map<String, Travel_Distance__c> travelDistanceTechNameMap = new Map<String, Travel_Distance__c>();
        Map<String, Ghg_Factor__c> ghgFactorTechTypeMap = new Map<String, Ghg_Factor__c>();
        List<String> cabinClassFlightTypePairList = new List<String>();
        Map<Id, GHG_Factor__c> ghgFactorMap = new Map<Id, GHG_Factor__c>();
        Map<String, Carbon_Emission__c> carbonEmissionTechTypeMap = new Map<String, Carbon_Emission__c>();
        List<Carbon_Emission__c> insertEmissionList = new List<Carbon_Emission__c>();
        List<Id> insertEmissionIdList = new List<Id>();
        
        Map<Id, Travel_Application__c> travelApplicationMap = new Map<Id, Travel_Application__c>();
        List<Id> travelApplicationIdList = new List<Id>();
         
        Map<Id, Travel_Distance__c> travelDistanceMap = new Map<Id, Travel_Distance__c>();
        Map<Id, Carbon_Emission__c> carbonEmissionMap = new Map<Id, Carbon_Emission__c>();
        string err;
        Map<Id, String> errMap = new Map<Id, String>();
        integer count = 0;
        
        for (Journey__c journey : newList) {
            travelApplicationIdList.add(journey.Travel_Application__c);
        }
        
        for (Travel_Application__c ta : [select Id, Applicant__c, On_Behalf_of__c, On_Behalf_of__r.Employee__c, On_Behalf_of__r.Employee__r.Name,
                                                On_Behalf_of_Function__c, Apply_Date__c, From_Site__c, On_Behalf_of__r.employee__r.travel_policy__r.Name,
                                                status__c
                                            from Travel_Application__c
                                            where Id IN :travelApplicationIdList ]){
            travelApplicationMap.put(ta.Id, ta);
        }

        Id travelAppId;
        for (Journey__c j: newList){
            // Build up journey log
            travelAppId = j.Travel_Application__c;
            logToInsertList.add(new Journey_Log__c (
                Name = j.Name,
                Journey__c = j.Id,
                Applicant__c = travelApplicationMap.get(travelAppId).On_Behalf_of__r.Employee__r.Name,
                Department__c = travelApplicationMap.get(travelAppId).On_Behalf_of_Function__c,
                Departure_Date__c = j.Departure_Date__c,
                Claim_Date__c = travelApplicationMap.get(travelAppId).Apply_Date__c,
                //Cabin_Class__c = detailedJourneyMap.get(journeyItemId).Cabin_Class__r.Name,
                Location__c = travelApplicationMap.get(travelAppId).From_Site__c,
                //Trip_From__c = detailedJourneyMap.get(journeyItemId).From_Airport__r.Travel_Location__r.City__c,
                //Trip_From_City_Code__c = detailedJourneyMap.get(journeyItemId).From_Airport__r.Airport_Code__c,
                //Trip_To__c = detailedJourneyMap.get(journeyItemId).To_Airport__r.Travel_Location__r.City__c,
                //Trip_To_City_Code__c = detailedJourneyMap.get(journeyItemId).To_Airport__r.Airport_Code__c,
                //Flight_Type__c = travelDistanceMap.get(journeyItemId).Flight_Type__r.Name,
                //Distance__c = travelDistanceMap.get(journeyItemId).Distance__c,
                //Carbon_Emission__c = carbonEmissionMap.get(journeyItemId).Id,
                Travel_Application__c = travelAppId,
                //Status__c =  travelApplicationMap.get(travelAppId).status__c,
                Travel_Policy_Name__c = travelApplicationMap.get(travelAppId).On_Behalf_of__r.employee__r.travel_policy__r.Name
            ));
        }
        if (!logToInsertList.isEmpty()) {
            insert logToInsertList;
        }     
        //TEManualSharingCtrl.journeyLogSharing(newList,true);
    }
    
    
}