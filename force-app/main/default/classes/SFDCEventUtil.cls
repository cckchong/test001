public class SFDCEventUtil {
    private static final Integer MAX_CALENDAR_EVENT_DURATION_DAYS = 14;
    private static final Integer MAX_CALENDAR_EVENT_DURATION_SECONDS = MAX_CALENDAR_EVENT_DURATION_DAYS * 24 * 60 * 60;
    private static final Integer SECONDS_IN_A_DAY = 24 * 60 * 60;

    public static List<Event> createEvents(List<Event> events) {
        List<Event> createEvents = new List<Event>();
    
        for (Event event : events) {
            //Date startDate = event.startDateTime.dateGMT();
            //Date endDate = event.endDateTime.dateGMT();
            
            Integer secondsBetween = (Integer) ((event.endDateTime.getTime() - event.startDateTime.getTime()) / 1000);
            
            System.debug('event.endDateTime.getTime() = ' + event.endDateTime.getTime());
            System.debug('event.startDateTime.getTime() = ' + event.startDateTime.getTime());
            System.debug('secondsBetween = ' + secondsBetween);
            System.debug('MAX_CALENDAR_EVENT_DURATION_SECONDS = ' + MAX_CALENDAR_EVENT_DURATION_SECONDS);

            if (secondsBetween > MAX_CALENDAR_EVENT_DURATION_SECONDS) {
                for (Integer i = 0; i < secondsBetween; i += MAX_CALENDAR_EVENT_DURATION_SECONDS) {
                    Event e = event.clone();
                    
                    if (i == 0) {
                        e.startDateTime = event.startDateTime;
                    } else {
                        e.startDateTime = event.startDateTime.addSeconds(i - SECONDS_IN_A_DAY);
                    }
                    
                    e.endDateTime = event.startDateTime.addSeconds(i + MAX_CALENDAR_EVENT_DURATION_SECONDS - SECONDS_IN_A_DAY - 1);
                    
                    if (event.endDateTime < e.endDateTime) {
                        e.endDateTime = event.endDateTime;
                    }

                    createEvents.add(e);
                }
            } else {
                createEvents.add(event);
            }
        }
        
        System.debug(createEvents);
        
        insert createEvents;
        
        return createEvents;
    }
}