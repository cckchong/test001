/**
 * Utility class for sending Outlook Meeting Request from a Leave Request
 * @author Kong
 * @date 09/09/2015
 */
public without sharing class TEMeetingRequestHandler {
    
    // Event's description
    private static final String EVENT_DESCRIPTION = '';
    // Event's subject
    private static final String EVENT_SUBJECT = ' on trip, Travel Application No: ';
    // Cancel Event's subject
    private static final String CANCEL_EVENT_SUBJECT = ' trip cancelled, Travel Application No: ';
    // Number of minutes in a hour
    private static final Integer MINUTES_IN_HOUR = 60;
    public Static Boolean meetingRequestProcess = true;

    public static void process(Map<Id, Travel_Application__c> oldTravelApplication, Map<Id, Travel_Application__c> newTravelApplication){
        if (!meetingRequestProcess){
            return;
        }
        
        List <Travel_Application__c> newTravelApplicationList = null;
        List<Event> cancelEvents = null;
        List <Id> IdList = new List <Id>();
        List <Id> cancelTravelApplicationIdList = new List <Id>();
        List <Event> eventList = new List <Event>();
        List <Event> eventSiteList = new List <Event>();
        List <Event> eventDepList = new List <Event>();
        Map<String, Public_Calendar__c> publicCalendars = Public_Calendar__c.getAll();
        Public_Calendar__c calendar = null;
        List<String> uids = new List<String>();
        List<Event> events = new List<Event>();
        List<Boolean> isCancels = new List<Boolean>();
        List<String> sites = new List<String>();
        List<String> departments = new List<String>();
        
        for (Travel_Application__c reader : newTravelApplication.values()){
            if (reader.status__c != oldTravelApplication.get(reader.id).status__c && 
                (reader.status__c == 'CON' ||            
                reader.status__c == TEConstant.STATUS_CANCELLED)
            ){
                IdList.add(reader.id);
            }
        }
        if(!IdList.IsEmpty()){
            meetingRequestProcess = false;
            newTravelApplicationList = TravelApplicationList(IdList);
            for (Travel_Application__c reader : newTravelApplicationList){
                if ( reader.Tech_Earliest_Departure_Date__c == null || reader.Tech_Latest_Departure_Date__c == null){
                    continue;
                }
                uids.add(reader.id);
                if (reader.On_Behalf_of__r.Employee__r.User__c != null){
                    events.add(createEvent(reader, reader.On_Behalf_of__r.Employee__r.User__c));
                }
                isCancels.add(isCancel(reader));
                sites.add(reader.On_Behalf_of__r.Employee__r.Site__r.name);
                departments.add(reader.On_Behalf_of__r.Employee__r.Full_Department__c);
                if (!isCancel(reader)){
                    if (reader.On_Behalf_of__r.Employee__r.User__c != null){
                        eventList.add(createEvent(reader, reader.On_Behalf_of__r.Employee__r.User__c));
                    }
                    calendar = publicCalendars.get(reader.On_Behalf_of__r.Employee__r.Site__r.name);
                    if (calendar != null){
                        eventSiteList.add(createEvent(reader, calendar.calendar_id__c));
                    }
                    calendar = publicCalendars.get(reader.On_Behalf_of__r.Employee__r.Full_Department__c);
                    if (calendar != null){
                        eventDepList.add(createEvent(reader, calendar.calendar_id__c));
                    }
                }
                else{
                    cancelTravelApplicationIdList.add(reader.id);
                }
                 
            }
            if (!eventList.isEmpty()){
                SFDCEventUtil.createEvents(eventList);
            }
            if (!eventSiteList.isEmpty()){
                SFDCEventUtil.createEvents(eventSiteList);
            }
            if (!eventDepList.isEmpty()){
                SFDCEventUtil.createEvents(eventDepList);
            }
            if (!cancelTravelApplicationIdList.isEmpty()){
                cancelEvents = new List <Event> ([Select Id from Event where WhatId in :cancelTravelApplicationIdList]);
                if (!cancelEvents.isEmpty()){
                    delete cancelEvents;
                }
            }
            MeetingRequestUtil.send(uids, events, isCancels, sites, departments);   
        }
    }
    
     /**
     * Is the leave request a cancellation request?
     * @param leaveRequest leaveRequest
     *
     * @return Is the leave request a cancellation request
     */
    private static Boolean isCancel(Travel_Application__c ta) {
        return ta.status__c == TEConstant.STATUS_CANCELLED;
    }    
    private static Event createEvent(Travel_Application__c travelApplication, Id ownerId ){
        Event event = new Event();
        Date startDate;
        Date endDate;
        
        startDate = travelApplication.Tech_Earliest_Departure_Date__c.date();
        endDate = travelApplication.Tech_Latest_Departure_Date__c.date();
        if (travelApplication.Tech_Latest_Return_Date__c != null){
            endDate = travelApplication.Tech_Latest_Return_Date__c.date();
        }
        event.WhatId = travelApplication.id;
        event.ownerId = ownerId;
        event.subject = (!isCancel(travelApplication) ?  travelApplication.On_Behalf_of__r.Employee__r.Full_Name__c + EVENT_SUBJECT :  travelApplication.On_Behalf_of__r.Employee__r.Full_Name__c + CANCEL_EVENT_SUBJECT) + ' ' + travelApplication.name;
        event.description = EVENT_DESCRIPTION;        
        event.ShowAs = 'OutOfOffice';
        //event.IsAllDayEvent = true;
        event.startDateTime = DateTime.newInstanceGMT(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);
        event.endDateTime = DateTime.newInstanceGMT(endDate.year(), endDate.month(), endDate.day(), 23, 59, 59);  
        
        Integer minutesOffset = (Integer) (travelApplication.On_Behalf_of__r.Employee__r.leave_policy__r.time_zone_offset__c * MINUTES_IN_HOUR * -1);
        
        event.startDateTime = event.startDateTime.addMinutes(minutesOffset);
        event.endDateTime = event.endDateTime.addMinutes(minutesOffset);
              
        return event;
    }
    private static List<Travel_Application__c> TravelApplicationList(List<Id> IdList){
        return [
            select id, On_Behalf_of__r.Employee__r.Full_Name__c, status__c, Tech_Earliest_Departure_Date__c ,Tech_Latest_Departure_Date__c, Tech_Latest_Return_Date__c,
            Name, On_Behalf_of__r.Employee__r.User__c, On_Behalf_of__r.Employee__r.Site__c, On_Behalf_of__r.Employee__r.Site__r.name,
            On_Behalf_of__r.Employee__r.Full_Department__c ,
            On_Behalf_of__r.Employee__r.leave_policy__r.time_zone_offset__c 
            from Travel_Application__c
            where id in :IdList
            and On_Behalf_of__r.Employee__r.User__c != null
        ];
    }
}