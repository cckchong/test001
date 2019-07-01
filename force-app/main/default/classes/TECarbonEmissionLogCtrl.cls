public without sharing class TECarbonEmissionLogCtrl {
    //testing purpose
    private ApexPages.StandardController standardController;

    public TECarbonEmissionLogCtrl (ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }

    public static void processLogs(){
        
        Map<Id, Journey__c> itineraryToProcessMap = new Map<Id, Journey__c>();
        Map<Id, Journey_Log__c> notProcessedLogMap = new Map<Id, Journey_Log__c>();
        Map<Id, Journey_Log__c> itineraryLogMap = new Map<Id, Journey_Log__c>();
        List<Id> itineraryToProcessIdList = new List<Id>();
        List<Id> itineraryToErrorLogIdList = new List<Id>();
        List<Journey__c> itineraryToUpdateList = new List<Journey__c>();
        //List<Journey__c> itineraryToLogList = new List<Journey__c>();
        //List<Journey__c> itineraryToErrorLogList = new List<Journey__c>();
        Map<Id, String> itiIdFromNameMap = new Map<Id, String>();
        Map<Id, String> itiIdToNameMap = new Map<Id, String>();
        Map<String, Id> airportNameIdMap = new Map<String, Id>();
        List<Journey_Log__c> logToUpdateList = new List<Journey_Log__c>();
        String err;
        
        //List<CO2_Error_Log__c> errorLogList = new List<CO2_Error_Log__c>(); 
    
        //1. get not processed or error journey logs
        For (Journey_Log__c jl : [Select Id, Name, Travel_Application__c, Journey__c
                              From Journey_Log__c 
                              Where Status__c = ''
                              ]){
            notProcessedLogMap.put(jl.Id, jl);
            itineraryLogMap.put(jl.Journey__c, jl);
            itineraryToProcessIdList.add(jl.Journey__c);
        }
        if (itineraryToProcessIdList.isEmpty()){
            return;
        }
        //......start processing
        //2.0pre-processing
        For (Journey__c it : [Select Id, Name, Travel_Application__c, From_Airport_Text__c, To_Airport_Text__c 
                              From Journey__c 
                              Where Travel_Application__r.Status__c = :TEConstant.STATUS_CONFIRMED
                              AND Id in : itineraryToProcessIdList
                              ]){
            if (it.From_Airport_Text__c == '' || it.To_Airport_Text__c == ''){
                //itineraryToErrorLogIdList.add(it.Id);
                logToUpdateList.add(new Journey_Log__c(
                                        Id = itineraryLogMap.get(it.Id).Id,
                                        Is_Error__c = True,
                                        Remarks__c = Label.TE_Travel_Application_Travel_Airport_Not_Found
                                        ));
            }
            else{
                itineraryToProcessMap.put(it.Id, it);
                itiIdFromNameMap.put(it.Id, it.From_Airport_Text__c.tolowercase());
                itiIdToNameMap.put(it.Id, it.To_Airport_Text__c.tolowercase());
            }
        }
        
        itineraryToProcessIdList.clear();
        If (!itineraryToProcessMap.isEmpty()){
            For (AirPort__c ap : [Select Id, Name 
                                  From AirPort__c 
                                  Where Name in : itiIdFromNameMap.values() OR Name in : itiIdToNameMap.values()]){
                airportNameIdMap.put(ap.Name.tolowercase(), ap.Id);
            }
            For (Id itiId : itiIdFromNameMap.keySet()){
                if (!airportNameIdMap.containsKey(itiIdFromNameMap.get(itiId)) || !airportNameIdMap.containsKey(itiIdToNameMap.get(itiId))){
                    //itineraryToErrorLogIdList.add(itiId);
                    err = Label.TE_Travel_Application_Travel_Airport_Not_Found;
                    if (!airportNameIdMap.containsKey(itiIdFromNameMap.get(itiId))){
                        err += itiIdFromNameMap.get(itiId);
                        if (!airportNameIdMap.containsKey(itiIdToNameMap.get(itiId))){
                            err += ', ';
                        }
                    }
                    if (!airportNameIdMap.containsKey(itiIdToNameMap.get(itiId))){
                        err += itiIdToNameMap.get(itiId);
                    }
                    logToUpdateList.add(new Journey_Log__c(
                                            Id = itineraryLogMap.get(itiId).Id,
                                            Is_Error__c = True,
                                            Remarks__c = err
                                            ));
                }
                else{
                    itineraryToProcessIdList.add(itiId);
                }
            }
        }
        //2.1 copy text to lookup
        If (!itineraryToProcessIdList.isEmpty()){
            For (Id itiId : itineraryToProcessIdList){
                itineraryToUpdateList.add(new Journey__c(
                                            Id = itiId,
                                            From_Airport__c = airportNameIdMap.get(itiIdFromNameMap.get(itiId)),
                                            To_Airport__c = airportNameIdMap.get(itiIdToNameMap.get(itiId))
                                            ));
            }
            upsert itineraryToUpdateList;
            
            itineraryToUpdateList.clear();
            For (Id itiId : itineraryToProcessIdList){
                itineraryToUpdateList.add(itineraryToProcessMap.get(itiId));
            }
            //itineraryToUpdateList = [Select Id, Name, Travel_Application__c
            //                         From Journey__c Where Id in : itineraryToProcessIdList];
            
            
            //2.2 do calculations
            //    if error ticked, untick, clear error messages   
            //    to be handled in updateJourneyLog
        
            //3. Update journey log
            logToUpdateList = updateJourneyLog(logToUpdateList, itineraryToUpdateList, itineraryLogMap);
        }
        if (!logToUpdateList.isEmpty()){
            upsert logToUpdateList;
        }
    }

    /** 
     * Update journey logs
     */
    Public static List<Journey_Log__c> updateJourneyLog(List<Journey_Log__c> logToUpdate, List<Journey__c> itineraryList, Map<Id, Journey_Log__c> itineraryLogMap){
        if(itineraryList.isempty()){
            return null;
        }        
        //List<Journey_Log__c> logToInsertList = new List<Journey_Log__c>();
        //Map<Id, Journey__c> journeyMap = new Map<Id, Journey__c>();
        Map<Id, Journey__c> detailedJourneyMap = new Map<Id, Journey__c>();
        List<Id> journeyIdList = new List<Id>();
        List<Id> validDistanceJourneyIdList = new List<Id>();
        List<Id> validGHGJourneyIdList = new List<Id>();
        //Map<Id, Integer> journeyPosMap = new Map<Id, Integer>();
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
        
        for (Journey__c journey : itineraryList) {
            journeyIdList.add(journey.Id);
            travelApplicationIdList.add(journey.Travel_Application__c);
        }
        for (Journey__c journey: [select Id, Name, Travel_Application__c, Travel_Application__r.Id, Cabin_Class__r.Tech_Keyword__c, Departure_Date__c,
                                    Cabin_Class__r.Name, From_Airport__r.Travel_Location__r.City__c, From_Airport__r.Airport_Code__c,
                                    To_Airport__r.Travel_Location__r.City__c, To_Airport__r.Airport_Code__c,
                                    From_Airport__r.Tech_Airport_Name__c, To_Airport__r.Tech_Airport_Name__c,
                                    From_Airport__r.Name, To_Airport__r.Name
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
                //err = TEValidationsController.checkExistingTravelDistance(detailedJourneyMap, journeyId, err);
                err = checkExistingTravelDistance(detailedJourneyMap, journeyId, err);
                errMap.put(journeyId, err);
            } else {
                
                distance = travelDistanceTechNameMap.get(siteNamePairList.get(i));
                cabinClassFlightTypePairList.add(distance.Flight_Type__r.Short_Name__c + flightClassShortNameList.get(i));
                validDistanceJourneyIdList.add(journeyId);
                travelDistanceMap.put(journeyId, distance);
            }
        }
        
        for (Ghg_Factor__c factor : [select Id, Tech_Flight_Type_Cabin_Class__c 
                                     from Ghg_Factor__c 
                                     where Tech_Flight_Type_Cabin_Class__c IN :cabinClassFlightTypePairList]) {
            ghgFactorTechTypeMap.put(factor.Tech_Flight_Type_Cabin_Class__c, factor);
        }

        Ghg_Factor__c ghgFactor;

        // Catch no GHG Factor

        for (Integer i = 0; i < cabinClassFlightTypePairList.size(); ++i) {
            //journeyId = journeyIdList.get(i);
            journeyId = validDistanceJourneyIdList.get(i);
            if (errMap.containsKey(journeyId)) {
                err = errMap.get(journeyId);
            } else {
                err = '';
            }
            
            if (!ghgFactorTechTypeMap.containsKey(cabinClassFlightTypePairList.get(i))) {
                //err = TEValidationsController.checkExistingGHGFactor(detailedJourneyMap, journeyId, err);
                err = checkExistingGHGFactor(detailedJourneyMap, journeyId, err);
                errMap.put(journeyId, err);
            } else if (!errMap.containsKey(journeyId)){
            
                ghgFactor = ghgFactorTechTypeMap.get(cabinClassFlightTypePairList.get(i));

                fromToCabinClassFlightTypeList.add(travelDistanceMap.get(journeyId).Tech_From_To__c + cabinClassFlightTypePairList.get(i));
                validGHGJourneyIdList.add(journeyId);
                ghgFactorMap.put(journeyId, ghgFactor);
            }
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
            journeyId = validGHGJourneyIdList.get(i);
            
            if (!errMap.containsKey(journeyId)){
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
            // Update journey log
            if (errMap.containsKey(journeyItemId)){
                logToUpdate.add(new Journey_Log__c(
                    Id = itineraryLogMap.get(journeyItemId).Id,
                    Is_Error__c = True,
                    Remarks__c = errMap.get(journeyItemId)
                    ));
            }
            else{
                travelAppId = detailedJourneyMap.get(journeyItemId).Travel_Application__r.Id;
                logToUpdate.add(new Journey_Log__c (
                    Id = itineraryLogMap.get(journeyItemId).Id,
                    Name = detailedJourneyMap.get(journeyItemId).Name,
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
                    Travel_Policy_Name__c = travelApplicationMap.get(travelAppId).On_Behalf_of__r.employee__r.travel_policy__r.Name,
                    Is_Error__c = False,
                    Remarks__c = ''
                ));
            }
        }
        //TEManualSharingCtrl.journeyLogSharing(itineraryList,true);
        
        return logToUpdate;
    }
    
     /**
     * @description check the existance of GHG Factor 
     */  
    public static String checkExistingGHGFactor(Map<Id, Journey__c> journeyMap, Id journeyId, String err){
        if (String.isBlank(err)) {
            err = Label.TE_Travel_Application_GHG_Factor_Not_Found;
        }
        //err = err + Label.TE_Travel_Application_GHG_Factor_Not_Found_From + ' ' + journeyMap.get(journeyId).Origin_Site__r.City__c + ' ' + Label.TE_Travel_Application_GHG_Factor_Not_Found_To + ' ' + journeyMap.get(journeyId).Destination__r.City__c + '; ';
        err = err + Label.TE_Travel_Application_GHG_Factor_Not_Found_From + ' ' + journeyMap.get(journeyId).From_Airport__r.Name + ' ' + Label.TE_Travel_Application_GHG_Factor_Not_Found_To + ' ' + journeyMap.get(journeyId).To_Airport__r.Name + '; ';
        return err;
    }
    
     /**
     * @description check the existance of travel distance
     */      
    public static String checkExistingTravelDistance(Map<Id, Journey__c> journeyMap, Id journeyId, String err){
        if (String.isBlank(err)) {
            err = Label.TE_Travel_Application_Travel_Distance_Not_Found;
        }
        //err = err + Label.TE_Travel_Application_Travel_Distance_Not_Found_From + ' ' + journeyMap.get(journeyId).Origin_Site__r.City__c + ' ' + Label.TE_Travel_Application_Travel_Distance_Not_Found_To + ' ' + journeyMap.get(journeyId).Destination__r.City__c + '; ';
        
        //err = err + Label.TE_Travel_Application_Travel_Distance_Not_Found_From + ' ' + journeyMap.get(journeyId).From_Airport__r.Tech_Airport_Name__c + ' ' + Label.TE_Travel_Application_Travel_Distance_Not_Found_To + ' ' + journeyMap.get(journeyId).To_Airport__r.Tech_Airport_Name__c + '; ';
        err = err + Label.TE_Travel_Application_Travel_Distance_Not_Found_From + ' ' + journeyMap.get(journeyId).From_Airport__r.Name + ' ' + Label.TE_Travel_Application_Travel_Distance_Not_Found_To + ' ' + journeyMap.get(journeyId).To_Airport__r.Name + '; ';
        return err;
    }

    //testing purpose
    public static PageReference testCO2Log(){

        processLogs();
        return null;
    }
}