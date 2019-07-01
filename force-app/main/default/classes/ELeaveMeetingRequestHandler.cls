/**
 * Utility class for sending Outlook Meeting Request from a Leave Request
 * @author William Cheng
 * @date 04/02/2015
 */
public without sharing class ELeaveMeetingRequestHandler {
    
    // Event's subject
    private static final String EVENT_SUBJECT = ' on leave, Request No: ';
    
    // Cancel Event's subject
    private static final String CANCEL_EVENT_SUBJECT = ' leave cancelled, Request No: ';
    
    // Event's description
    private static final String EVENT_DESCRIPTION = '';
    
    // Number of minutes in a hour
    private static final Integer MINUTES_IN_HOUR = 60;

    /**
     * Send meeting requestes for leave requests just being approved, others are ignored
     * @param oldLeaveRequests id to leave request map before changes
     * @param newLeaveRequests id to leave request map after changes
     *
     * @return the event
     */
    public static void process(Map<Id, Leave_Request__c> oldLeaveRequests, Map<Id, Leave_Request__c> newLeaveRequests) {
        List<String> uids = new List<String>();
        List<Event> events = new List<Event>();
        List<Boolean> isCancels = new List<Boolean>();
        List<String> sites = new List<String>();
        List<String> departments = new List<String>();
        
        List<String> tempUids = new List<String>();
        List<Event> tempEvents = new List<Event>();
        List<Boolean> tempIsCancels = new List<Boolean>();
        
        newLeaveRequests = new Map<Id, Leave_Request__c>([Select id, On_Behalf_of__r.User__c, On_Behalf_of__r.Leave_Bypass_Approvals__c, Status__c, From_Date__c, To_Date__c, From_Hour__c, To_Hour__c, From_Minute__c, To_Minute__c, On_Behalf_of__r.leave_policy__r.time_zone_offset__c, recordType.developerName, Name, On_Behalf_of__r.Leave_Policy__r.Name, On_Behalf_of_Site__c, On_Behalf_of_Department__c, On_Behalf_of_Full_Name__c, On_Behalf_of__r.Full_Department__c, Original_Start_Time_Display__c, Adj_Start_Time_Display__c, adjusted_end_hour__c, adjusted_end_minute__c, original_end_hour__c, original_end_minute__c, original_start_hour__c, original_start_minute__c, adjusted_start_hour__c, adjusted_start_minute__c, Date__c from Leave_Request__c where id in :newLeaveRequests.keySet()]);

        for (Id id : oldLeaveRequests.keySet()) {
            Leave_Request__c oldLeaveRequest = oldLeaveRequests.get(id);
            Leave_Request__c newLeaveRequest = newLeaveRequests.get(id);
            
            // Only process approved
            if (isApprove(oldLeaveRequest, newLeaveRequest)) {
                System.debug('Is approve = y');
                System.debug('isApprove');
                uids.add(newLeaveRequest.id);
                events.add(prepareEvent(newLeaveRequest));
                isCancels.add(isCancel(newLeaveRequest));
                sites.add(newLeaveRequest.On_Behalf_of_Site__c);
                departments.add(newLeaveRequest.On_Behalf_of__r.Full_Department__c);
            } else {
                System.debug('Is approve = n');
            }
        }
        
        Map<String, Public_Calendar__c> publicCalendars = Public_Calendar__c.getAll();
        
        List<Event> createEvents = new List<Event>();
        List<Event> createSiteEvents = new List<Event>();
        List<Event> createDepartmentEvents = new List<Event>();
        
        Set<ID> cancelLeaveRequestIds = new Set<ID>();
        
        for (Integer i = 0; i < isCancels.size(); i++)  {
            Leave_Request__c leaveRequest = newLeaveRequests.get(uids.get(i));
            Boolean nonSalesforceUser = leaveRequest.On_Behalf_of__r.user__c == null;
            if (!isCancels.get(i)) {
                // Personal Calendar
                if (!nonSalesforceUser) {
                    createEvents.add(events.get(i));
                }
                
                // Site public calendar
                Event siteEvent = events.get(i).clone();
                Public_Calendar__c calendar = publicCalendars.get(leaveRequest.On_Behalf_of_Site__c);
                if (calendar != null)  {
                    siteEvent.OwnerId = calendar.calendar_id__c;
                    createSiteEvents.add(siteEvent);
                }
                    
                // Department public calendar
                Event departmentEvent = events.get(i).clone();
                calendar = publicCalendars.get(leaveRequest.On_Behalf_of__r.Full_Department__c);
                if (calendar != null) {
                    departmentEvent.OwnerId = calendar.calendar_id__c;
                    createDepartmentEvents.add(departmentEvent);
                }
            } else {
                cancelLeaveRequestIds.add(uids.get(i));
            }
            
            if(!nonSalesforceUser) {
                tempUids.add(uids.get(i));
                tempEvents.add(events.get(i));
                tempIsCancels.add(isCancels.get(i));
            }
            
            /*
            if (nonSalesforceUser) {
                uids.remove(i);
                events.remove(i);
                isCancels.remove(i);
            }*/
        }
        
        System.debug(createEvents);
        
        SFDCEventUtil.createEvents(createEvents);
        SFDCEventUtil.createEvents(createSiteEvents);
        SFDCEventUtil.createEvents(createDepartmentEvents);
                
        List<Event> cancelEvents = [Select Id from Event where WhatId in :cancelLeaveRequestIds];
        delete cancelEvents;
        
        //System.debug('Meeting request sending result = ' + MeetingRequestUtil.send(uids, events, isCancels, sites, departments));
        System.debug('Meeting request sending result = ' + MeetingRequestUtil.send(tempUids, tempEvents, tempIsCancels, sites, departments));
    }
    
    /**
     * Prepare an event from a leave request
     * @param leaveRequest leaveRequest
     *
     * @return the event
     */
    public static Event prepareEvent(Leave_Request__c leaveRequest) {
        Event event = new Event();
        
        event.WhatId = leaveRequest.id;
        event.ownerId = leaveRequest.On_Behalf_of__r.User__c;
        event.subject = (!isCancel(leaveRequest) ? leaveRequest.On_Behalf_of_Full_Name__c + EVENT_SUBJECT : leaveRequest.On_Behalf_of_Full_Name__c + CANCEL_EVENT_SUBJECT) + ' ' + leaveRequest.name;
        event.description = EVENT_DESCRIPTION;        
        event.ShowAs = 'OutOfOffice';
        Integer startHour = 0;
        Integer startMinute = 0;
        Integer endHour = 0;
        Integer endMinute = 0;
        Date startDate;
        Date endDate;
        
        if (isLeave(leaveRequest)) {
            startDate = leaveRequest.from_date__c;
            endDate = leaveRequest.to_date__c;
            
            startHour = Integer.valueOf(leaveRequest.from_hour__c);
            startMinute = Integer.valueOf(leaveRequest.from_minute__c);
            endHour = Integer.valueOf(leaveRequest.to_hour__c);
            endMinute = Integer.valueOf(leaveRequest.to_minute__c);
        } else if (isFlexibleTime(leaveRequest)) {
            startDate = leaveRequest.date__c;
            endDate = leaveRequest.date__c;
        
            if (leaveRequest.Original_Start_Time_Display__c > leaveRequest.Adj_Start_Time_Display__c) {
                // start working early
                startHour = (Integer) leaveRequest.adjusted_end_hour__c;
                startMinute = (Integer) leaveRequest.adjusted_end_minute__c;
                endHour = (Integer) leaveRequest.original_end_hour__c;
                endMinute = (Integer) leaveRequest.original_end_minute__c;
            } else {
                // start working late
                startHour = (Integer) leaveRequest.original_start_hour__c;
                startMinute = (Integer) leaveRequest.original_start_minute__c;
                endHour = (Integer) leaveRequest.adjusted_start_hour__c;
                endMinute = (Integer) leaveRequest.adjusted_start_minute__c;
            }
        }
        
        System.debug('abc startDate = ' + startDate);
        System.debug('abc Original_Start_Time_Display__c = ' + leaveRequest.Original_Start_Time_Display__c);
        System.debug('abc Adj_Start_Time_Display__c = ' + leaveRequest.Adj_Start_Time_Display__c);
        System.debug('abc startHour = ' + startHour);
        System.debug('abc startMinute = ' + startMinute);

        event.startDateTime = DateTime.newInstanceGmt(startDate.year(), startDate.month(), startDate.day(), startHour, startMinute, 0);
        event.endDateTime = DateTime.newInstanceGmt(endDate.year(), endDate.month(), endDate.day(), endHour, endMinute, 0);
        
        Integer minutesOffset = (Integer) (leaveRequest.On_Behalf_of__r.leave_policy__r.time_zone_offset__c * MINUTES_IN_HOUR * -1);
        
        event.startDateTime = event.startDateTime.addMinutes(minutesOffset);
        event.endDateTime = event.endDateTime.addMinutes(minutesOffset);
        
        return event;
    }
    
    /**
     * Is the leave request just being approved?
     * @param oldLeaveRequest leaveRequest before changes
     * @param newLeaveRequest leaveRequest after chagnes
     *
     * @return Is the leave request just being approved
     */
    public static Boolean isApprove(Leave_Request__c oldLeaveRequest, Leave_Request__c newLeaveRequest) {
        // Handle leave
        if (isLeave(newLeaveRequest)) {
            if (!newLeaveRequest.On_Behalf_of__r.Leave_Bypass_Approvals__c) {
                // Handle leave requestes require approval
                
                if (oldLeaveRequest.status__c == LeaveRequestConstant.STATUS_PENDING_APPROVAL && newLeaveRequest.status__c == LeaveRequestConstant.STATUS_APPROVED) {
                    return true;
                }
                
                if (oldLeaveRequest.status__c == LeaveRequestConstant.STATUS_PENDING_CANCELLATION && newLeaveRequest.status__c == LeaveRequestConstant.STATUS_CANCELLED) {
                    return true;
                }
            } else {
                // Handle leave requestes bypass approval
                
                if (oldLeaveRequest.status__c == LeaveRequestConstant.STATUS_DRAFT
                    && newLeaveRequest.status__c == LeaveRequestConstant.STATUS_APPROVED) {
                    return true;
                }
                
                if (oldLeaveRequest.status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED
                    && newLeaveRequest.status__c == LeaveRequestConstant.STATUS_APPROVED) {
                    return true;
                }
                
                if (oldLeaveRequest.status__c == LeaveRequestConstant.STATUS_CANCEL_NOT_SUBMITTED
                    && newLeaveRequest.status__c == LeaveRequestConstant.STATUS_CANCELLED) {
                    return true;
                }
            }
        }
        
       if (isFlexibleTime(newLeaveRequest)) {
            if (oldLeaveRequest.status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED && newLeaveRequest.status__c == LeaveRequestConstant.STATUS_SUBMITTED) {
                return true;
            }
            if (oldLeaveRequest.status__c == LeaveRequestConstant.STATUS_SUBMITTED && newLeaveRequest.status__c == LeaveRequestConstant.STATUS_CANCEL_NOT_SUBMITTED) {
                return true;
            }
            if (oldLeaveRequest.status__c == LeaveRequestConstant.STATUS_SUBMITTED && newLeaveRequest.status__c == LeaveRequestConstant.STATUS_CANCELLED) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Is the leave request a cancellation request?
     * @param leaveRequest leaveRequest
     *
     * @return Is the leave request a cancellation request
     */
    public static Boolean isCancel(Leave_Request__c leaveRequest) {
        return leaveRequest.status__c == LeaveRequestConstant.STATUS_CANCELLED || leaveRequest.status__c == LeaveRequestConstant.STATUS_CANCEL_NOT_SUBMITTED;
    }
    
    /**
     * Is the request a leave request
     * @param leaveRequest leaveRequest
     *
     * @return Is the request a leave request
     */
    public static Boolean isLeave(Leave_Request__c leaveRequest) {
        return leaveRequest.recordType.developerName == LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST;
    }
    
    /**
     * Is the request a flexible time request
     * @param leaveRequest leaveRequest
     *
     * @return Is the request a flexible time request
     */
    public static Boolean isFlexibleTime(Leave_Request__c leaveRequest) {
        return leaveRequest.recordType.developerName == LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST;
    }
}