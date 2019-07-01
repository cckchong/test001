/**
 * TETravelApplicationTriggerHandler
 * @description restrict, update related field or related line item records of Travel Application
 */

public without sharing class TETravelApplicationTriggerHandler {
    
    Public Static String SEPARATION = '^';
    Public Static String PUBLIC_GROUP_NAME_ADMIN = 'TE-*SITE_NAME*-ADMIN';
    Public Static String TO_REPLACE_SITE_NAME = '*SITE_NAME*';
    Public Static String FROM_HOUR = '09';
    Public Static String FROM_MINUTE = '00';
    Public Static String TO_HOUR = '18';
    Public Static String TO_MINUTE = '00';
    public static Set<String> chatterPostedSet = new Set<String>();
    public static Set<String> emailSentSet = new Set<String>();
    
    
    /**
    * @desciption sync up Travel Application Status with Cash Advance Status
    */     
    public static void synupTravelApplicationStatusWithCashAdvanceStatus (Map<Id, Travel_Application__c > newTravelApplicationMap, Map<Id, Travel_Application__c > oldTravelApplicationMap){
        
        List <Cash_Advance__c> cashAdvanceList = new List <Cash_Advance__c>();
        Map <ID, String> travelApplicationStatusMap = new Map <ID, String>();
        
        for (Travel_Application__c reader : newTravelApplicationMap.values()) {
            if (reader.Status__c != oldTravelApplicationMap.get(reader.id).status__c ) {
                travelApplicationStatusMap.put(reader.id, reader.status__c);
            }
        }
        
        if (!travelApplicationStatusMap.isEmpty()) { 
            for (Cash_Advance__c reader : [select id, Travel_Application__c, status__c from Cash_Advance__c where Travel_Application__c in :travelApplicationStatusMap.keySet()]){
                if((reader.Status__c != TEConstant.STATUS_PAID_OUT) || (reader.Status__c != TEConstant.STATUS_RETURN)) {
                    if (travelApplicationStatusMap.get(reader.Travel_Application__c) == TEConstant.STATUS_DRAFT) {
                        reader.Status__c = TEConstant.STATUS_DRAFT;
                    }
                    else if (travelApplicationStatusMap.get(reader.Travel_Application__c) == TEConstant.STATUS_NOT_SUBMITTED ) {
                        reader.Status__c = TEConstant.STATUS_NOT_SUBMITTED ;
                    }
                    else if (travelApplicationStatusMap.get(reader.Travel_Application__c) == TEConstant.STATUS_PENDING ) {
                        reader.Status__c = TEConstant.STATUS_PENDING;
                    }
                    cashAdvanceList.add(reader);    
                }
            }
    
            if ( !cashAdvanceList.isempty()){
                update cashAdvanceList;
            }  
        }
    }
    
    /**
    * @description initialize the field values when travel application's status is Pending Approval
    */
    public static void initFieldValues(List<Travel_Application__c> newTravelApplicationList, Map<Id, Travel_Application__c > oldTravelApplicationMap ) {
        Set<Id> setEmployeeAdministratorId =  new Set<Id> ();
        Map <id, Employee_Administrator__c> mapEmployeeAdministrator = new Map <id, Employee_Administrator__c>();
        Employee_Administrator__c taEmployeeAdministrator;
        Map <Id, List<Travel_Detail__c>> travelDetailMap = new Map <Id, List<Travel_Detail__c>>();
        Map <Id, List<Accommodation__c>> accommodationMap = new Map <Id, List<Accommodation__c>>();
        List<Travel_Detail__c> tmptravelDetailList = new List<Travel_Detail__c>();
        Set<String> sitToVisitSet = new Set<String>();
        List<String> sitToVisitList = null;
        String str = '';
        String[] strarray = null;
        for (Travel_Application__c reader : newTravelApplicationList){
            if( (oldTravelApplicationMap !=null && (reader.Status__c == TEConstant.STATUS_DRAFT || reader.Status__c == TEConstant.STATUS_NOT_SUBMITTED) && reader.status__c != oldTravelApplicationMap.get(reader.id).status__c)) {
                reader.Tech_Travel_Policy_Name__c = '';
                reader.Tech_Applicant_Email__c = '';
                reader.Tech_On_Behalf_of_Email__c = '';
                reader.Tech_All_Site_Name__c = '';
                reader.Tech_Travel_Agent_Email__c = '';
                reader.Tech_Send_Issue_Air_Ticket_Email__c = 0;
            }
            if( (oldTravelApplicationMap !=null && reader.Status__c == TEConstant.STATUS_PENDING && reader.status__c != oldTravelApplicationMap.get(reader.id).status__c) || (oldTravelApplicationMap == null)) {
                 setEmployeeAdministratorId.add(reader.On_Behalf_of__c);
                //reader.Tech_Travel_Policy_Name__c = taEmployeeAdministrator.Employee__r.travel_policy__r.Name;
                travelDetailMap.put(reader.id, null);
                accommodationMap.put(reader.id, null);
                reader.Submission_Date__c = Date.today(); 
                reader.Selected_Option_1__c = false;
                reader.Selected_Option_2__c = false;
                reader.Selected_Option_3__c = false;
                //reader.Option_Estimated_Currency__c = null;
                //reader.Option_Estimated_Price1__c = null;
                //reader.Option_Estimated_Price2__c = null;
                //reader.Option_Estimated_Price3__c = null;
            }
            
        }
        if (!setEmployeeAdministratorId.isempty()){
            for ( Employee_Administrator__c employeeAdministrator : [ select id, Employee__r.travel_policy__r.name, Employee__c,Employee_Administrator__r.User__r.Email, 
                                                                            Employee__r.User__r.Email, Employee__r.Expense_Policy__r.Finance_Email__c,
                                                                            Employee__r.Acting_Approver_1__c, Employee__r.Acting_Approver_2__c, Employee__r.Acting_Approver_3__c, Employee__r.Acting_Approver_4__c,
                                                                            Employee__r.Approver_1__c, Employee__r.Approver_2__c, Employee__r.Approver_3__c, Employee__r.Approver_4__c
                                                                      from Employee_Administrator__c where id in :setEmployeeAdministratorId ]){
                mapEmployeeAdministrator.put(employeeAdministrator.id, employeeAdministrator);
            }
        }
        //*
        if(!travelDetailMap.keyset().isempty() || !accommodationMap.keyset().isempty()){
            for(Travel_application__c reader :[select id, 
                                              (select id, Site_To_Visit__c, recordType.Name,
                                               Origin_Site__c, Origin_Site__r.Site__c
                                               from travel_details__r),
                                               (select id, site__c, site__r.Name from accommodations__r)
                                               from travel_application__c  where id in :travelDetailMap.keyset()]){
                if(!travelDetailMap.keyset().isempty()){
                    travelDetailMap.put(reader.id, reader.travel_details__r);
                }
                if(!accommodationMap.keyset().isempty()){
                    accommodationMap.put(reader.id, reader.accommodations__r);
                }
            }
        }
        //*/
        
        for (Travel_Application__c reader : newTravelApplicationList){
            if(mapEmployeeAdministrator.containsKey(reader.On_Behalf_of__c)){
                taEmployeeAdministrator = mapEmployeeAdministrator.get(reader.On_Behalf_of__c);
                reader.Tech_Travel_Policy_Name__c = taEmployeeAdministrator.Employee__r.travel_policy__r.Name;
                reader.Tech_Expense_Policy_Finance_Email__c = taEmployeeAdministrator.Employee__r.Expense_Policy__r.Finance_Email__c;
                reader.Actual_Approver_1__c = taEmployeeAdministrator.Employee__r.Acting_Approver_1__c;
                reader.Actual_Approver_2__c = taEmployeeAdministrator.Employee__r.Acting_Approver_2__c;
                reader.Actual_Approver_3__c = taEmployeeAdministrator.Employee__r.Acting_Approver_3__c;
                reader.Actual_Approver_4__c = taEmployeeAdministrator.Employee__r.Acting_Approver_4__c;
                if(String.isBlank(reader.Actual_Approver_1__c)){
                    reader.Actual_Approver_1__c = taEmployeeAdministrator.Employee__r.Approver_1__c;
                }
                if(String.isBlank(reader.Actual_Approver_2__c)){
                    reader.Actual_Approver_2__c = taEmployeeAdministrator.Employee__r.Approver_2__c;
                }
                if(String.isBlank(reader.Actual_Approver_3__c)){
                    reader.Actual_Approver_3__c = taEmployeeAdministrator.Employee__r.Approver_3__c;
                }
                if(String.isBlank(reader.Actual_Approver_4__c)){
                    reader.Actual_Approver_4__c = taEmployeeAdministrator.Employee__r.Approver_4__c;
                }
            }
            if(travelDetailMap.containsKey(reader.id)){
                for(travel_detail__c tdreader : travelDetailMap.get(reader.id)){
                    if (tdreader.Site_To_Visit__c != null){
                        sitToVisitList = tdreader.Site_To_Visit__c.split(',');
                        for(String sitReader : sitToVisitList){
                            sitToVisitSet.add(sitReader);
                        }
                    }
                    tdreader.Tech_Applicant_Email__c = mapEmployeeAdministrator.get(reader.On_Behalf_of__c).Employee__r.User__r.Email;
                    tmptravelDetailList.add(tdreader);
                }
                for(Accommodation__c accreader : accommodationMap.get(reader.id)){
                    if (accreader.Site__c != null){
                        sitToVisitSet.add(accreader.site__r.Name);
                    }
                }
                if(!sitToVisitSet.isEmpty()){
                    sitToVisitList = new List<String>(sitToVisitSet);
                    str = String.join(sitToVisitList, TETravelApplicationTriggerHandler.SEPARATION);
                    str += TETravelApplicationTriggerHandler.SEPARATION;
                    reader.Tech_All_Site_Name__c = str;
                }

                /*
                str = '';
                strarray = null;
                for(travel_detail__c tdreader : travelDetailMap.get(reader.id)){
                    if (tdreader.Site_To_Visit__c != null){
                        str += tdreader.Site_To_Visit__c;
                    }
                    tdreader.Tech_Applicant_Email__c = mapEmployeeAdministrator.get(reader.On_Behalf_of__c).Employee__r.User__r.Email;
                    tmptravelDetailList.add(tdreader);
                }
                if( str != ''){
                    strarray = str.split(',');
                    for (String sreader : strarray){
                        sitToVisitSet.add(sreader);
                    }
                    str = '';
                    for (String sreader : sitToVisitSet){
                        str += sreader+ TETravelApplicationTriggerHandler.SEPARATION;
                    }
                    reader.Tech_All_Site_Name__c = str;
                }
                */
            }
            upsert tmptravelDetailList;
        }
    }
    
    /**
    * @description set sharing when travel application's status is Pending
    */
    public static void taSharing (Map<Id, Travel_Application__c> newTravelApplicationMap, Map<Id, Travel_Application__c > oldTravelApplicationMap ) {
        List<Travel_Application__c> travelApplicationSharingList = new List<Travel_Application__c>();
        
        for(Travel_Application__c reader : newTravelApplicationMap.values()){
            if(reader.status__c != oldTravelApplicationMap.get(reader.id).status__c && reader.status__c == TEConstant.STATUS_PENDING){
                travelApplicationSharingList.add(reader);
            }
        }
        if(!travelApplicationSharingList.isEmpty()){
            TEManualSharingCtrl.TETravelRequestSharing(travelApplicationSharingList, true);
        }
    }
    
    /**
    * @description Compensation Leave Calculation
    */         
    public static void compensationLeavecalculation(List<Travel_Application__c> newTravelApplicationList, Map<Id, Travel_Application__c > oldTravelApplicationMap ) {
        List <Date> dateList = null;
        List <Travel_Application__c> vaildTravelApplicationList = new List <Travel_Application__c>();
        List <Id> leavePolicyList = new List <Id>();
        Set <Date> comLeaveDateList = null;
        Map <Id, Employee_Administrator__c> onBEhalfOfMap = new Map <Id, Employee_Administrator__c>();
        Map <String, List <Date>> policyHolidayMap = new Map <String, List <Date>>();
        Map <Id, Set<Date>> travelRequestComLeaveMap = new Map <Id, Set<Date>>();
        Date earliestDepartureDate = System.Today();
        Date latestReturnDate = System.Today();
        Id  leavePolicyId = null;
        Date defDate = Date.newInstance(1900,1,7);
        Integer integerDay  = 0;
        
        for (Travel_Application__c reader : newTravelApplicationList){
            if (reader.status__c != oldTravelApplicationMap.get(reader.id).status__c && reader.status__c == TEConstant.STATUS_CONFIRMED ){
                vaildTravelApplicationList.add(reader);
                onBEhalfOfMap.put(reader.on_behalf_of__c, null);
                
                if( reader.Departure_Date__c < earliestDepartureDate){
                    earliestDepartureDate = reader.Departure_Date__c;
                }
                if( reader.return_Date__c > latestReturnDate){
                    latestReturnDate = reader.return_Date__c;
                }
            }
            if (reader.status__c != oldTravelApplicationMap.get(reader.id).status__c && (reader.status__c == TEConstant.STATUS_REJECT ||reader.status__c == TEConstant.STATUS_CANCELLED || reader.status__c == TEConstant.STATUS_Not_SUBMITTED)){
                reader.Leave_Date__c = null;
            }
        }
        onBEhalfOfMap = new Map <Id, Employee_Administrator__c>( [select id, employee__r.leave_policy__c,
                                                                    employee__r.timeset__r.Is_Mon_Available__c,
                                                                    employee__r.timeset__r.Is_Tue_Available__c,
                                                                    employee__r.timeset__r.Is_Wed_Available__c,
                                                                    employee__r.timeset__r.Is_Thu_Available__c,
                                                                    employee__r.timeset__r.Is_Fri_Available__c,
                                                                    employee__r.timeset__r.Is_Sat_Available__c,
                                                                    employee__r.timeset__r.Is_Sun_Available__c
                                                                    from Employee_Administrator__c 
                                                                    where id in :onBEhalfOfMap.keyset()]);
        for (Employee_Administrator__c reader : onBEhalfOfMap.values()){
            leavePolicyList.add(reader.employee__r.leave_policy__c);
        } 
        for (Holiday__c reader :[select id, date__c, leave_policy__c from holiday__c where type__c = 'H' and date__c <= :latestReturnDate and date__c >= :earliestDepartureDate and leave_policy__c in :leavePolicyList]){
            if(policyHolidayMap.containsKey(reader.leave_policy__c)){
                dateList = policyHolidayMap.get(reader.leave_policy__c);
                dateList.add(reader.date__c);
                policyHolidayMap.put(reader.leave_policy__c, dateList);
            }
            else{
                dateList = new List <Date>();
                dateList.add(reader.date__c);
                policyHolidayMap.put(reader.leave_policy__c, dateList);
            }
        }
        for (Travel_Application__c reader : vaildTravelApplicationList){
            leavePolicyId = onBEhalfOfMap.get(reader.on_behalf_of__c).employee__r.leave_policy__c;
            if (policyHolidayMap.containsKey(leavePolicyId)){
                dateList = policyHolidayMap.get(leavePolicyId);
                for(Date dateReader : dateList){
                    if (reader.Departure_Date__c <= dateReader && reader.Return_Date__c >= dateReader){
                        addComLeaveToTravelRequest(travelRequestComLeaveMap, reader.id, dateReader);
                    }
                }
            }
        }
        
        for (Travel_Application__c reader : vaildTravelApplicationList){
            for(Date dateReader = reader.Departure_Date__c;  dateReader <= reader.return_Date__c; dateReader = dateReader.addDays(1)){
                integerDay = Math.Mod ( defDate.daysBetween(dateReader),7);
                if(!onBEhalfOfMap.get(reader.on_behalf_of__c).employee__r.timeset__r.Is_Sun_Available__c && integerDay == LeaveRequestConstant.SUNDAY){
                    addComLeaveToTravelRequest(travelRequestComLeaveMap, reader.id, dateReader);
                }
                if(!onBEhalfOfMap.get(reader.on_behalf_of__c).employee__r.timeset__r.Is_Mon_Available__c && integerDay == LeaveRequestConstant.MONDAY){
                    addComLeaveToTravelRequest(travelRequestComLeaveMap, reader.id, dateReader);
                }
                if(!onBEhalfOfMap.get(reader.on_behalf_of__c).employee__r.timeset__r.Is_Tue_Available__c && integerDay == LeaveRequestConstant.TUESDAY){
                    addComLeaveToTravelRequest(travelRequestComLeaveMap, reader.id, dateReader);
                }
                if(!onBEhalfOfMap.get(reader.on_behalf_of__c).employee__r.timeset__r.Is_Wed_Available__c && integerDay == LeaveRequestConstant.WEDNESDAY){
                    addComLeaveToTravelRequest(travelRequestComLeaveMap, reader.id, dateReader);
                }
                if(!onBEhalfOfMap.get(reader.on_behalf_of__c).employee__r.timeset__r.Is_Thu_Available__c && integerDay == LeaveRequestConstant.THURSDAY){
                    addComLeaveToTravelRequest(travelRequestComLeaveMap, reader.id, dateReader);
                }
                if(!onBEhalfOfMap.get(reader.on_behalf_of__c).employee__r.timeset__r.Is_Fri_Available__c && integerDay == LeaveRequestConstant.FRIDAY){
                    addComLeaveToTravelRequest(travelRequestComLeaveMap, reader.id, dateReader);
                }
                if(!onBEhalfOfMap.get(reader.on_behalf_of__c).employee__r.timeset__r.Is_Sat_Available__c && integerDay == LeaveRequestConstant.SATURDAY){
                    addComLeaveToTravelRequest(travelRequestComLeaveMap, reader.id, dateReader);
                }
            }
        }

        List<String> strtmpList = new List<String>();
        for (Travel_Application__c reader : vaildTravelApplicationList){
            strtmpList = new List<String>();
            if (travelRequestComLeaveMap.containskey(reader.id)){
                comLeaveDateList = travelRequestComLeaveMap.get(reader.id);
                //dateList.sort();
                for(Date dateReader : comLeaveDateList ){
                    strtmpList.add(((DateTime)dateReader).format('yyyyMMdd'));
                }
                reader.num_of_leave_days__c = strtmpList.size();
                reader.Leave_Date__c = String.join(strtmpList, ';');
            }
        }
    }
    
    
    private static void addComLeaveToTravelRequest(Map <Id, Set<Date>> travelRequestComLeaveMap, id travelRequestId, Date dateValue){
        Set <Date> comLeaveDateList = null;
        if(travelRequestComLeaveMap.containskey(travelRequestId)){
            comLeaveDateList = travelRequestComLeaveMap.get(travelRequestId);
            comLeaveDateList.add(dateValue);
        }
        else{
            comLeaveDateList = new Set <Date>();
            comLeaveDateList.add(dateValue);
            travelRequestComLeaveMap.put(travelRequestId, comLeaveDateList);
        }
    }
    
    
    
    Public static List<Id> activeUserIdList(List<Id> userIdList){
        List<Id> activeuserIDList = new List<Id>();
        for(user reader : [select id
                                  from user 
                                  where id in :userIdList and isactive = true] ){
            activeuserIDList.add(reader.id);
        }
        return activeuserIDList ;
    }
    
    public static void chatterPost( Map<Id, Travel_Application__c> newTravelApplicationMap, Map<Id,Travel_Application__c> oldTravelApplicationMap ){
        
        Map <Id, Travel_Application__c> travelApplicationMap = new Map<Id, Travel_Application__c>();
        Map <String, String> MapChatterPost = new Map <String, String>();
        Map <String, List<Id> > MapCopyTo = new Map <String, List<Id> >();
        Map <Id, String> travelApplicationSiteNamesMap = new Map<Id, String>();
        Map <Id, Set<String>> travelApplicationExclusiveSiteNamesMap = new Map<Id, Set<String>>();
        Map <Id, List<Id>> travelApplicationAdminUserMap = new Map<Id, List<Id>>();
        List <Id> travelApplicationIdList = new List <Id>();
        List <Id> employeeAdminstratorIdList = new List <Id>();
        List <Id> activeUserList = null;
        List <Id> userIdList = new List <Id>();
        List <FeedComment> listfcomment = new List <FeedComment>();
        List <Travel_Detail__c> travelDetailList = new List <Travel_Detail__c>();
        Map <String, String> groupNameSiteMap = new Map <String, String>();
        Map <String, String> groupIdSiteMap = new Map <String, String>();
        Map <String, Set<Id>> siteUserIdMap = new Map <String, Set<Id>>();
        Map <Id, Set<Id>> travelApplicationUserIdMap = new Map <Id, Set<Id>>();
        RecordType AirRecord = null;
        Set<Id> addTravelAgency = new Set<Id>();
        Set<Id> addSiteAdmin = new Set<Id>();
        List<Id> travelAgency = new List<Id>();
        String content = '';
        String Chatterid = '';
        Datetime tmpdateTime = null;
        
        for (Travel_Application__c reader : newTravelApplicationMap.values()){
            if (reader.status__c != oldTravelApplicationMap.get(reader.id).status__c && 
                (   
                    reader.status__c == TEConstant.STATUS_PENDING ||
                    reader.status__c == TEConstant.STATUS_CANCELLED ||
                    (reader.status__c == TEConstant.STATUS_NOT_SUBMITTED && oldTravelApplicationMap.get(reader.id).status__c == TEConstant.STATUS_PENDING) ||
                    reader.status__c == TEConstant.STATUS_CONFIRMED
                    
                ) 
                ){
                if (chatterPostedSet.contains(reader.Id + reader.status__c)){
                    continue;  
                }
                else{
                    chatterPostedSet.add(reader.Id + reader.status__c);
                    travelApplicationMap.put(reader.id, reader);
                    travelApplicationIdList.add(reader.id);
                }
            }
        }

        if (!travelApplicationMap.isempty()){
            boolean getAdminAgent = false;
            List<Id> feedIdList = new List<Id>();
            for (Travel_Application__c reader : travelApplicationMap.values()){
                if (reader.ChatterFeedId__c == null){
                    getAdminAgent = true;
                }
                else{
                    feedIdList.add(reader.ChatterFeedId__c);
                }
            }
            if (!getAdminAgent && !feedIdList.isEmpty()){
                if ([SELECT Count() FROM FeedItem Where Id = :feedIdList] < feedIdList.size()){
                    getAdminAgent = true;
                }
            }
            if (getAdminAgent){
                //get site admin
                //1.
                travelApplicationSiteNamesMap = getTravelApplicationSiteNamesMap(travelApplicationIdList);
                Set<String> tempSites = new Set<String>();
                //2.
                For (Id taId : travelApplicationSiteNamesMap.keySet()){
                    tempSites.clear();
                    if (travelApplicationSiteNamesMap.get(taId) != NULL){
                        For (String site : travelApplicationSiteNamesMap.get(taId).split(',')){
                            if (site != '' && !tempSites.contains(site)){
                                tempSites.add(site);
                            }
                        }
                    travelApplicationExclusiveSiteNamesMap.put(taId, tempSites);
                    }
                }   
                //3.
                For (String sites : travelApplicationSiteNamesMap.values()){
                    if (sites != NULL){
                        For (String site : sites.split(',')){
                            if (site != ''){
                                groupNameSiteMap.put(PUBLIC_GROUP_NAME_ADMIN.replace(TO_REPLACE_SITE_NAME , site), site);
                            }
                        }
                    }
                }
                //4.
                For (Group g : [Select Id, Name From Group Where Name in :groupNameSiteMap.keySet()]){
                    groupIdSiteMap.put(g.Id, groupNameSiteMap.get(g.Name));
                }
    
                //5.
                For (GroupMember gm : [Select Id, UserOrGroupId, GroupId From GroupMember Where GroupId in :groupIdSiteMap.keySet()]){
                      if (!siteUserIdMap.containsKey(groupIdSiteMap.get(gm.GroupId))){
                          siteUserIdMap.put(groupIdSiteMap.get(gm.GroupId), New Set<Id>{gm.UserOrGroupId});
                      }
                      else{
                          siteUserIdMap.get(groupIdSiteMap.get(gm.GroupId)).add(gm.UserOrGroupId);
                      }
                }
                //6.
                Set<Id> siteAdmins = new Set<Id>();
                For (Id taId : travelApplicationExclusiveSiteNamesMap.keySet()){
                    siteAdmins.clear();
                    For (String siteName : travelApplicationExclusiveSiteNamesMap.get(taId)){
                        if (siteUserIdMap.containsKey(siteName)){
                            For (Id user : siteUserIdMap.get(siteName)){
                                if (!siteAdmins.contains(user)){
                                    siteAdmins.add(user);
                                }
                            }
                        }
                    }
                    if (!siteAdmins.isEmpty()){
                        travelApplicationUserIdMap.put(taId, siteAdmins.clone());
                    }
                }
            
            }
                           
            for(Travel_Application__c reader : travelApplicationMap.values()){
                if(reader.status__c == TEConstant.STATUS_CANCELLED){
                    content = Label.TE_Travel_Application_Feed_Cancelled;
                }
                if(reader.status__c == TEConstant.STATUS_NOT_SUBMITTED && oldTravelApplicationMap.get(reader.id).status__c == TEConstant.STATUS_PENDING){
                    content = Label.TE_Travel_Application_Feed_Recalled;
                }
                if(reader.status__c == TEConstant.STATUS_CONFIRMED){
                    content = Label.TE_Travel_Application_Feed_Confirmed;
                }

                if(reader.status__c == TEConstant.STATUS_PENDING){
                    content  = Label.TE_Travel_Application_Feed_Submitted +'\n\n';
                    /*
                    tmpdateTime = reader.Departure_Date__c;                     
                    content += Label.TE_Travel_Application_Feed_Departure_Date + tmpdateTime.format('yyyy/MM/dd') + '\n\n';
                    tmpdateTime = reader.Return_Date__c;
                    content += Label.TE_Travel_Application_Feed_Return_Date + tmpdateTime.format('yyyy/MM/dd') + '\n\n';
                    */
                }
                content = content.unescapeJava().unescapeHtml4();
                if (reader.ChatterFeedId__c == null 
                    || [SELECT Count() FROM FeedItem Where Id = :reader.ChatterFeedId__c] < 1){
                    //){
                    if (reader.ChatterFeedId__c != null){
                        reader.ChatterFeedId__c = null;
                        content = content + '\n\n';
                    }
                    userIdList.add(reader.Actual_Approver_1__c);
                    userIdList.add(reader.copy_to_1__c);
                    userIdList.add(reader.copy_to_2__c);
                    userIdList.add(reader.copy_to_3__c);
                    userIdList.add(reader.copy_to_4__c);
                    userIdList.add(reader.copy_to_5__c);
                    userIdList.add(reader.copy_to_6__c);
                    userIdList.add(reader.copy_to_7__c);
                    userIdList.add(reader.copy_to_8__c);
                    userIdList.add(reader.copy_to_9__c);
                    userIdList.add(reader.copy_to_10__c);
                    
                    if (reader.Agent_Travel_Detail_Count__c > 0){
                        if (reader.Travel_Agency__c != null){
                            userIdList.add(reader.Travel_Agency__c);
                        }
                    }
                    if (reader.Site_Admin_Travel_Detail_Count__c > 0){
                        if (travelApplicationUserIdMap.containsKey(reader.Id)){
                            for (Id adminId : travelApplicationUserIdMap.get(reader.Id)){
                                userIdList.add(adminId); 
                            }
                        }
                    }
                    //userIdList.add(UserInfo.getUserId());
                    employeeAdminstratorIdList.add(reader.On_Behalf_of__c);
                }else{
                    listfcomment.add(new FeedComment(FeedItemId = reader.ChatterFeedId__c, CommentBody = content ));
                }
             }
            
             if (!employeeAdminstratorIdList.isempty()){
                 for( Employee_Administrator__c reader : [SELECT Id, Employee__r.User__r.Id FROM Employee_Administrator__c WHERE Id =: employeeAdminstratorIdList AND Employee__r.User__r.Id != null]) {
                   //userIdList.add(reader.Employee__r.User__r.Id);
                 }
             }
             for(Travel_Application__c reader : travelApplicationMap.values()){
                if (reader.ChatterFeedId__c == null){
                    activeUserList = activeUserIdList(userIdList);
                    MapChatterPost.put(reader.id, content);
                    if(!Test.isRunningTest()){
                        reader.ChatterFeedId__c = ChatterUtil.simpleTextPostWithMultipleMentions(reader.id, activeUserList, content, 'AllUsers');
                    }
                }
                else if (reader.status__c == TEConstant.STATUS_NOT_SUBMITTED){
                    reader.ChatterFeedId__c = null;
                }
             }
             if (!listfcomment.isempty()){
                upsert listfcomment;
            }
        }
    }

    
    /**
    * @description get site_to_visit for travel details
    */
    private static Map<Id, String> getTravelApplicationSiteNamesMap(List<Id> taIdList){
        Map<Id, String> travelApplicationSiteNamesMap = new Map<Id, String>();
        For (Travel_Detail__c td: [Select Site_To_Visit__c, Travel_Application__c From Travel_Detail__c Where Travel_Application__c in :taIdList]){
            if (td.Site_To_Visit__c == NULL){
                continue;
            }
            
            if (!travelApplicationSiteNamesMap.containsKey(td.Travel_Application__c)){
                travelApplicationSiteNamesMap.put(td.Travel_Application__c, td.Site_To_Visit__c);
            }
            else{
                travelApplicationSiteNamesMap.put(td.Travel_Application__c , travelApplicationSiteNamesMap.get(td.Travel_Application__c) + td.Site_To_Visit__c);
            }
        }
        
        return travelApplicationSiteNamesMap;
    }
    
    /**
    * @description get site admin email lists
    */
    private static Map<Id, Set<String>> getTravelApplicationSiteAdminEmailMap(List<Id> taIdList){
        if (taIdList.isEmpty()){
            return null;
        }
    
        Map<Id, String> travelApplicationSiteNamesMap = new Map<Id, String>();
        Set<String> exclusiveSiteNames = new Set<String>();
        Map<String, String> siteNameEmailMap = new Map<String, String>();
        Map<Id, Set<String>> results = new Map<Id, Set<String>>();
        
        //1. get site_to_visit for travel details
        travelApplicationSiteNamesMap = getTravelApplicationSiteNamesMap(taIdList);
        
        //2. make an exclusive site name set
        For (String sites: travelApplicationSiteNamesMap.values()){
            if (sites != NULL){
                For (String site: sites.split(',')){
                    if (site != '' && !exclusiveSiteNames.contains(site)){
                        exclusiveSiteNames.add(site);
                    }    
                }
            }
        }

        //3. make a site name -> its email map
        For (Site__c site: [Select Name, Admin_Email__c From Site__c Where Name in :exclusiveSiteNames]){
            if (site.Admin_Email__c != ''){
                siteNameEmailMap.put(site.Name, site.Admin_Email__c);
            }
        }
        
        //4. make the taID to list of emails map
        Set<String> emails = new Set<String>();
        For (Id taId : travelApplicationSiteNamesMap.keySet()){
            emails.clear();
            if (travelApplicationSiteNamesMap.get(taId) != NULL){
                For (String siteName: travelApplicationSiteNamesMap.get(taId).split(',')){
                    if (!emails.contains(siteNameEmailMap.get(siteName))){
                        emails.add(siteNameEmailMap.get(siteName));
                    }
                }
            }
            results.put(taId, emails);
        }
        return results;
    }

    /**
    * @description send a single email to travel agent
    */
    private static void sendSingleEmailAgent (Travel_Application__c ta, String fromDisplayName, List<String> toEmails, List<String> ccEmails, Id emailTemplateId){
        if (!toEmails.isEmpty()){
            TESendEmail.sendEmail(TEConstant.ORGANIZATION_WIDE_EMAIL_NAME, fromDisplayName, toEmails, ccEmails, emailTemplateId, toEmails[0], ta.Id, true);
        }
    }
    /**
    * @description send a single email to site admins
    */
    private static void sendSingleEmailAdmin (Travel_Application__c ta, String fromDisplayName, List<String> toEmails, List<String> ccEmails, Id emailTemplateId){
        List<String> toAddressList = new List<String> ();
        for (String email: toEmails){
            if (email != null){
                toAddressList.add(email);    
            }                                
        }
        if (!toAddressList.isEmpty()){
            TESendEmail.sendEmail(TEConstant.ORGANIZATION_WIDE_EMAIL_NAME , fromDisplayName,toAddressList, ccEmails, emailTemplateId, getTargetId(ta) , ta.Id, false);
        }
    }
    /**
    * @description send a single email to applicant & on behalf of
    */
    private static void sendSingleEmailApplicant (Travel_Application__c ta, String fromDisplayName, List<String> ccEmails, Id emailTemplateId){
        List<String> toAddressList = new List<String> ();
        //toAddressList.add('tagenuser@gmail.com'); // TO BE DELETED when Tech_Applicant_Email__c & Tech_On_Behalf_of_Email__c are ready            
        if (ta.Applicant_Email__c != NULL){
            toAddressList.add(ta.Applicant_Email__c);
        }
        if (ta.Created_By_Email__c!= NULL){
            toAddressList.add(ta.Created_By_Email__c);
        }
        /*
        if(!String.isBlank(ta.Actual_Approver_1__c)){
            ccEmails.add(ta.Actual_Approver_1__r.Email);
        }
        */
        if (!toAddressList.isEmpty()){
            TESendEmail.sendEmail(TEConstant.ORGANIZATION_WIDE_EMAIL_NAME , fromDisplayName,toAddressList,ccEmails, emailTemplateId, getTargetId(ta), ta.Id, true);
            /*
            if(!String.isBlank(ta.Actual_Approver_1__c)){
                toAddressList.clear();
                TESendEmail.sendEmail(TEConstant.ORGANIZATION_WIDE_EMAIL_NAME , fromDisplayName, toAddressList, ccEmails, emailTemplateId, ta.Actual_Approver_1__c, ta.Id, true);
            }
            */
        }  
    }
    /**
    * @description return the target to be used in the email template
    */
    private static String getTargetId (Travel_Application__c ta){
        if (ta.On_Behalf_Of_UserId__c != null){
            return ta.On_Behalf_Of_UserId__c;
        }
        else{
            return ta.UserId_Created_By__c;
        }
    }
    /**
    * @description return the list without null values
    */
    private static List<String> removeNullValueFromStringList (List<String> listToRemoveNull){
        Integer j = 0;
        while (j < listToRemoveNull.size())
        {
          if(listToRemoveNull.get(j) == null)
          {
            listToRemoveNull.remove(j);
          }else
          {
            j++;
          }
        }
        return listToRemoveNull;
    }

    /**
    * @description send email to travel agent and site admin
    */        
    public static void SendEmail(Map<Id, Travel_Application__c> newTravelApplicationMap, Map<Id,Travel_Application__c> oldTravelApplicationMap ){
        
        String fromDisplayName = null;
        RecordType airRecord = null;
        
        List<Id> travelApplicationIdList = new List<Id>();
        //3 maps:
        Map<Id, Travel_Application__c> newSubmittedTravelApplicationMap = new Map<Id, Travel_Application__c>();
        Map<Id, Travel_Application__c> majorStatusChangedTravelApplicationMap = new Map<Id, Travel_Application__c>();
        Map<Id, Travel_Application__c> minorStatusChangedTravelApplicationMap = new Map<Id, Travel_Application__c>();
        
        Map<Id, Travel_Application__c> sendTravelAgentTravelApplicationMap = new Map<Id, Travel_Application__c>();
        Map<Id, Travel_Application__c> sendLocalAdminTravelApplicationMap = new Map<Id, Travel_Application__c>();
        Map<Id, List<String>> travelApplicationCCUserEmailMap = new Map<Id, List<String>>(); 
        Map<Id, Set<String>> travelApplicationSiteAdminEmailMap = new Map<Id, Set<String>>();
        Map<Id, List<String>> travelApplicationTravelAgentEmailMap = new Map<Id, List<String>>(); 
        List<String> travelAgentEmailList = new List<String> ();
        
        List<String> emailTemplateNameList = new list<String> {'TravelApplicationTravelAgency', 'TravelApplicationLocalAdmin', 
                                                               'TravelApplicationRequireActionAgency' , 'TravelApplicationRequireActionApplicant',
                                                               'TravelApplicationStatusChangedAgency', 'TravelApplicationStatusChangedApplicant', 'TravelApplicationStatusChangedSiteAdmin'
                                                              };
        Map<String, EmailTemplate> emailTemplateNameMap = new Map<String, EmailTemplate> ();       
         
        List<Travel_Detail__c> TravelDetailList = new List<Travel_Detail__c>();
        
        List<String> toAddressList = new List<String> ();
        List<String> ccAddressList = new List<String> ();
        List<Id> AgentPermissionSetIdList = new List<Id> ();
        //Id target;
        
        for(Travel_Application__c reader : newTravelApplicationMap.values()){
            // I. Inform everyone: new application created
            if(reader.status__c != oldTravelApplicationMap.get(reader.id).status__c && reader.status__c == TEConstant.STATUS_PENDING){
                if (emailSentSet.contains(reader.id + reader.status__c)){
                    continue;
                }
                else{
                    emailSentSet.add(reader.id + reader.status__c);
                    newSubmittedTravelApplicationMap.put(reader.Id,reader);
                    travelApplicationIdList.add(reader.Id);
                }
            }
            // II. Inform everyone: any other major status change
            else if (reader.status__c != oldTravelApplicationMap.get(reader.id).status__c){
                if (emailSentSet.contains(reader.id + reader.status__c)){
                    continue;
                }
                else{
                    emailSentSet.add(reader.id + reader.status__c);
                    majorStatusChangedTravelApplicationMap.put(reader.Id,reader);
                    travelApplicationIdList.add(reader.Id);
                }
            }
            // III. Inform relevant party whose action is required
            else if (
                 
                     //reader.Pending_Applicant_Selection_Count__c > oldTravelApplicationMap.get(reader.id).Pending_Applicant_Selection_Count__c ||
                     //reader.Admin_Accommodation_Count__c > oldTravelApplicationMap.get(reader.id).Admin_Accommodation_Count__c ||
                     reader.Pending_Agent_Reservation_Count__c > oldTravelApplicationMap.get(reader.id).Pending_Agent_Reservation_Count__c ||
                     reader.Pending_Applicant_Confirmation__c > oldTravelApplicationMap.get(reader.id).Pending_Applicant_Confirmation__c ||
                     reader.Confirmed_Air_Travel_Detail_Count__c > oldTravelApplicationMap.get(reader.id).Confirmed_Air_Travel_Detail_Count__c ||
                     (reader.Pending_Confirm_Accommod_By_Admin_Count__c > oldTravelApplicationMap.get(reader.id).Pending_Confirm_Accommod_By_Admin_Count__c) 
                     ){
                    if (emailSentSet.contains(reader.id + reader.status__c) && !Test.isRunningTest()){
                        continue;
                    }
                    else{
                        minorStatusChangedTravelApplicationMap.put(reader.Id,reader);
                        travelApplicationIdList.add(reader.Id);
                        emailSentSet.add(reader.id + reader.status__c);
                    }
            }
            travelAgentEmailList.clear();
            if(!String.IsBlank(reader.Travel_Agency__c)){
                travelAgentEmailList.add(reader.Travel_Agency__c);
            }
            travelApplicationTravelAgentEmailMap.put(reader.id, travelAgentEmailList);
        }
        
        if (travelApplicationIdList.isEmpty()){
            return; //no need to send emails
        }
        //get email templates
        for (EmailTemplate et : [SELECT Id, DeveloperName, Name FROM EmailTemplate WHERE DeveloperName in : emailTemplateNameList]){
            emailTemplateNameMap.put(et.DeveloperName, et);
        }
        
        //get site admin emails
        travelApplicationSiteAdminEmailMap = getTravelApplicationSiteAdminEmailMap(travelApplicationIdList);
        
        //get cc list emails
        if (!newSubmittedTravelApplicationMap.isEmpty() || !majorStatusChangedTravelApplicationMap.isEmpty()){
            List<String> ccEmails = new List<String>();
            for (Travel_Application__c ta : [Select Id, Copy_to_1__r.Email, Copy_to_2__r.Email, Copy_to_3__r.Email, Copy_to_4__r.Email,
                                                    Copy_to_5__r.Email, Copy_to_6__r.Email, Copy_to_7__r.Email, Copy_to_8__r.Email,
                                                    Copy_to_9__r.Email, Copy_to_10__r.Email, 
                                                    On_Behalf_Of__r.Employee__r.user__c, On_Behalf_Of__r.Employee_administrator__r.user__c,
                                                    On_Behalf_Of__r.Employee__r.Approver_1__c, On_Behalf_Of__r.Employee__r.Acting_Approver_1__c, //query IM email here
                                                    On_Behalf_Of__r.Employee__r.Approver_1__r.Email, On_Behalf_Of__r.Employee__r.Acting_Approver_1__r.Email
                                                    
                                             From Travel_Application__c Where Id in : travelApplicationIdList]){
                ccEmails.clear();
                /*
                ccEmails.add(ta.Copy_to_1__r.Email);
                ccEmails.add(ta.Copy_to_2__r.Email);
                ccEmails.add(ta.Copy_to_3__r.Email);
                ccEmails.add(ta.Copy_to_4__r.Email);
                ccEmails.add(ta.Copy_to_5__r.Email);
                ccEmails.add(ta.Copy_to_6__r.Email);
                ccEmails.add(ta.Copy_to_7__r.Email);
                ccEmails.add(ta.Copy_to_8__r.Email);
                ccEmails.add(ta.Copy_to_9__r.Email);
                ccEmails.add(ta.Copy_to_10__r.Email);                
                */
                //add IM email here
                if (ta.On_Behalf_Of__r.Employee__r.Acting_Approver_1__c != NULL){
                    ccEmails.add(ta.On_Behalf_Of__r.Employee__r.Acting_Approver_1__r.Email);
                }
                else if (ta.On_Behalf_Of__r.Employee__r.Approver_1__c != NULL){
                    ccEmails.add(ta.On_Behalf_Of__r.Employee__r.Approver_1__r.Email);
                }
                ccEmails = removeNullValueFromStringList(ccEmails);
                travelApplicationCCUserEmailMap.put(ta.Id, ccEmails);                
            }
        }
        
        //send emails
        if (!newSubmittedTravelApplicationMap.isEmpty()){
            for (Travel_Application__c ta : newSubmittedTravelApplicationMap.values()){
                ccAddressList.clear(); //***change this if cc is needed
                //send to agent
                if (ta.Agent_Travel_Detail_Count__c > 0 && travelApplicationTravelAgentEmailMap.containskey(ta.id)){
                    if(!travelApplicationTravelAgentEmailMap.get(ta.id).isempty()){
                        sendSingleEmailAgent(ta, fromDisplayName, travelApplicationTravelAgentEmailMap.get(ta.id), ccAddressList, emailTemplateNameMap.get('TravelApplicationTravelAgency').Id);
                        if( Label.TE_debug_agency_email == '1'){
                            sendSingleEmailAgent(ta, fromDisplayName, new list<String> {Label.TE_debug_usrid}, ccAddressList, emailTemplateNameMap.get('TravelApplicationTravelAgency').Id);
                        }
                    }
                }
                //send to admin
                if (travelApplicationSiteAdminEmailMap.get(ta.Id) != null){
                    sendSingleEmailAdmin (ta, fromDisplayName, new List<String>(travelApplicationSiteAdminEmailMap.get(ta.Id)), ccAddressList, emailTemplateNameMap.get('TravelApplicationLocalAdmin').Id);
                }
                //**send to applicant
                //ccAddressList.addAll(travelApplicationCCUserEmailMap.get(ta.Id));
                sendSingleEmailApplicant (ta, fromDisplayName, ccAddressList, emailTemplateNameMap.get('TravelApplicationStatusChangedApplicant').Id);   
            }
        }
        if (!majorStatusChangedTravelApplicationMap.isEmpty()){
            for (Travel_Application__c ta : majorStatusChangedTravelApplicationMap.values()){
                ccAddressList.clear(); //***change this if cc is needed
                //send to agent
                if (ta.Agent_Travel_Detail_Count__c > 0 && travelApplicationTravelAgentEmailMap.containskey(ta.id) && ta.Tech_Send_Issue_Air_Ticket_Email__c == 1){
                    if(!travelApplicationTravelAgentEmailMap.get(ta.id).isempty()){
                        sendSingleEmailAgent(ta, fromDisplayName, travelApplicationTravelAgentEmailMap.get(ta.id), ccAddressList, emailTemplateNameMap.get('TravelApplicationRequireActionAgency').Id);
                        if( Label.TE_debug_agency_email == '1'){
                            sendSingleEmailAgent(ta, fromDisplayName, new list<String> {Label.TE_debug_usrid}, ccAddressList, emailTemplateNameMap.get('TravelApplicationRequireActionAgency').Id);
                        }
                    }
                    
                }
                //send to admin
                if (travelApplicationSiteAdminEmailMap.get(ta.Id) != null){
                    sendSingleEmailAdmin (ta, fromDisplayName, new List<String>(travelApplicationSiteAdminEmailMap.get(ta.Id)), ccAddressList, emailTemplateNameMap.get('TravelApplicationStatusChangedSiteAdmin').Id);
                }
                //**send to applicant
                //ccAddressList.addAll(travelApplicationCCUserEmailMap.get(ta.Id));
                sendSingleEmailApplicant (ta, fromDisplayName, ccAddressList, emailTemplateNameMap.get('TravelApplicationStatusChangedApplicant').Id);   
            }
        }
        
        
        if (!minorStatusChangedTravelApplicationMap.isEmpty()){
            for (Travel_Application__c ta : minorStatusChangedTravelApplicationMap.values()){

                ccAddressList.clear(); //***change this if cc is needed
                if (ta.Pending_Applicant_Selection_Count__c > oldTravelApplicationMap.get(ta.id).Pending_Applicant_Selection_Count__c ||
                    ta.Pending_Applicant_Confirmation__c > oldTravelApplicationMap.get(ta.id).Pending_Applicant_Confirmation__c ||
                    ta.Pending_Confirm_Accommod_By_Admin_Count__c > oldTravelApplicationMap.get(ta.id).Pending_Confirm_Accommod_By_Admin_Count__c
                    ){
                    sendSingleEmailApplicant (ta, fromDisplayName, ccAddressList, emailTemplateNameMap.get('TravelApplicationRequireActionApplicant').Id);  
                }
                if ( travelApplicationTravelAgentEmailMap.containskey(ta.id) && 
                    (ta.Pending_Agent_Reservation_Count__c > oldTravelApplicationMap.get(ta.id).Pending_Agent_Reservation_Count__c ||
                    ((ta.Confirmed_Air_Travel_Detail_Count__c > oldTravelApplicationMap.get(ta.id).Confirmed_Air_Travel_Detail_Count__c) &&
                     !(ta.Admin_Pending_Arrangement__c == 0 && ta.Pending_Agent_Reservation_Count__c == 0 && ta.Pending_Applicant_Confirmation__c == 0
                     && ta.Pending_Applicant_Selection_Count__c == 0 && ta.Pending_Confirm_Accommod_By_Admin_Count__c == 0
                     && ta.Pending_Reservation_Accommodation_Count__c == 0))
                    )
                   ){               
                        if(!travelApplicationTravelAgentEmailMap.get(ta.id).isempty()){
                            sendSingleEmailAgent(ta, fromDisplayName, travelApplicationTravelAgentEmailMap.get(ta.id), ccAddressList, emailTemplateNameMap.get('TravelApplicationRequireActionAgency').Id);
                            if( Label.TE_debug_agency_email == '1'){
                                sendSingleEmailAgent(ta, fromDisplayName, new list<String> {Label.TE_debug_usrid}, ccAddressList, emailTemplateNameMap.get('TravelApplicationRequireActionAgency').Id);
                            }
                        }
                    }
                /*
                if ( ta.Admin_Accommodation_Count__c > oldTravelApplicationMap.get(ta.id).Admin_Accommodation_Count__c){
                    sendSingleEmailAgent(ta, fromDisplayName, new list<String>(travelApplicationSiteAdminEmailMap.get(ta.Id)),  ccAddressList, emailTemplateNameMap.get('TravelApplicationLocalAdmin').Id);
                }
                */
            }
        }
    }
    
    public static void travelApplicationDaysLog(Map<Id, Travel_Application__c> newTravelApplicationMap, Map<Id, Travel_Application__c > oldTravelApplicationMap ) {
        List<Leave_Request_Log__c> logToInsertList = new List<Leave_Request_Log__c>();
        List<Travel_Application__c> taList = new List<Travel_Application__c>();
        
        for (Travel_Application__c ta : [Select Id, Name, OwnerId, Status__c, On_Behalf_of__r.Employee__c, On_Behalf_of__r.Employee_Department__c, On_Behalf_of__r.Employee_Full_Name__c,
                                                On_Behalf_of__r.Employee__r.Name, On_Behalf_of__r.Employee__r.Leave_Policy_Name__c, On_Behalf_of__r.Employee__r.Original_Employee_ID__c,
                                                On_Behalf_of__r.Employee__r.Site__r.Name, On_Behalf_of__r.Employee__r.User__c, On_Behalf_of__r.Employee__r.User__r.Id,
                                                On_Behalf_of__r.Employee__r.User__r.IsActive, Departure_Date__c, Return_Date__c
                                         From Travel_Application__c Where Id =: newTravelApplicationMap.keySet()]){
            taList.add(ta);
        }
        
        for(Travel_Application__c reader : taList){
            if(reader.status__c != oldTravelApplicationMap.get(reader.id).status__c &&
               (reader.status__c == TEConstant.STATUS_CONFIRMED || reader.status__c == TEConstant.STATUS_CANCELLED)
              ){
                logToInsertList.addAll(leaveRequestLogCreater(reader));
            }
        }
        
        if (!logToInsertList.isEmpty()) {
            insert logToInsertList;
        }     
    }
    
    private static List<Leave_Request_Log__c> leaveRequestLogCreater(Travel_Application__c ta){
        List<Leave_Request_Log__c> logToInsertList = new List<Leave_Request_Log__c>();
        Date dDate = ta.Departure_Date__c;
        
        Double deduction = 0;
        String type = '';
        Id logOwnerId;
        
        if (ta.Status__c == TEConstant.STATUS_CONFIRMED){
            deduction = 1;
            type = Label.TE_Leave_Request_Log_Type_Confirmed;
        }
        else if (ta.Status__c == TEConstant.STATUS_CANCELLED){
            deduction = -1;
            type = Label.TE_Leave_Request_Log_Type_Cancelled;
        }
        
        if (ta.On_Behalf_of__r.Employee__r.User__c != null && ta.On_Behalf_of__r.Employee__r.User__r.IsActive){
            logOwnerId = ta.On_Behalf_of__r.Employee__r.User__r.Id;
        }
        else{
            logOwnerId = ta.ownerId;
        }
        
        for(Date dateReader = dDate;  dateReader <= ta.Return_Date__c;  dateReader = dateReader.adddays(1)){
            logToInsertList.add(new Leave_Request_Log__c (
                //fill in log details
                Date__c = dateReader,
                Deduction__c = deduction,
                Employee__c = ta.On_Behalf_of__r.Employee__c,
                Employee_Department__c = ta.On_Behalf_of__r.Employee_Department__c,
                Employee_Full_Name__c = ta.On_Behalf_of__r.Employee_Full_Name__c,
                Employee_ID__c = ta.On_Behalf_of__r.Employee__r.Name,
                From_Hour__c = FROM_HOUR,
                From_Minute__c = FROM_MINUTE,
                Leave_Policy__c = ta.On_Behalf_of__r.Employee__r.Leave_Policy_Name__c,
                Leave_Request_ID__c = ta.Name,
                Leave_Type__c = Label.TE_Leave_Request_Log_Leave_Type,
                Original_Employee_ID__c = ta.On_Behalf_of__r.Employee__r.Original_Employee_ID__c,
                Site__c = ta.On_Behalf_of__r.Employee__r.Site__r.Name,
                To_Hour__c = TO_HOUR,
                To_Minute__c = TO_MINUTE,
                Type__c = type,
                OwnerId = logOwnerId 
                //will not write: Last_Export_Time__c, Transaction_ID__c
            ));
        }
        return logToInsertList;
    }
}