/**
 * Utility class for sending Outlook Meeting Request from a SFDC standard Task object
 * @author William Cheng
 * @date 04/02/2015
 */
public class MeetingRequestUtil {

    // Calendar Integration User
    private static final User CALENDAR_INTEGRATION_USER;
    
    // ICS attachment content type
    private static final String ICS_CONTENT_TYPE = 'text/calendar; charset="utf-8"; method=REQUEST';
    
    // ICS attachment filename
    private static final String ICS_FILENAME = 'meeting.ics';
    
    // ICS date format
    private static final String UTC_DATE_FORMAT = 'yyyyMMdd\'T\'HHmmss\'Z\'';
    
    // ICS request method
    private static final String ICS_REQUEST_METHOD = 'REQUEST';
    
    // ICS cancel method
    private static final String ICS_CANCEL_METHOD = 'CANCEL';
    
    // SEQUENCE for request method
    private static final String ICS_REQUEST_SEQUENCE = '0';
    
    // SEQUENCE for cancelled method
    private static final String ICS_CANCEL_SEQUENCE = '1';
    
    // ICS Cancelled status
    private static final String ICS_CANCELLED_STATUS = 'STATUS:CANCELLED\n';
    
    // ICS template
    private static final String ICS = 'BEGIN:VCALENDAR'+ '\n'
                                + 'METHOD:{0}'+ '\n'
                                + 'VERSION:2.0' + '\n'
                                + 'BEGIN:VEVENT' + '\n'
                                + 'DTSTART:{1}' + '\n'
                                + 'DTEND:{2}' + '\n'
                                + 'UID:{3}' + '\n'
                                + 'DTSTAMP:{4}' + '\n'
                                + 'SEQUENCE:{5}' + '\n'
                                + '{6}'
                                + 'X-MICROSOFT-CDO-BUSYSTATUS:OOF' + '\n'
                                + 'END:VEVENT' + '\n'
                                + 'END:VCALENDAR' + '\n';
                                
    static {
       List<User> users = [Select id from User where email = :Label.Calendar_Integration_Email_Address];
       if (users.size() >= 1) {
           CALENDAR_INTEGRATION_USER = users.get(0);
       } else if (users.size() == 0) {
           throw new TalException('Please configure the Calendar Integration User properly');
       }
    }

    /**
     * Send Meeting Request emails
     * @param uid UID used in ICS
     * @param event Details of the meeting requeest
     * @param isCancel is it a cancellation?
     *
     * @return Meeting Request emails sending result
     */
    public static Messaging.SendEmailResult[] send(List<String> uids, List<Event> events, List<Boolean> isCancels, List<String> sites, List<String> departments) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Integer i = 0; i < uids.size(); i++) {
            emails.addAll(createEvent(uids.get(i), events.get(i), isCancels.get(i), sites.get(i), departments.get(i)));
        }

        return Messaging.sendEmail(emails);
    }

    /**
     * Prepare Meeting Request email with ICS attachment
     * @param uid UID used in ICS
     * @param event Details of the meeting requeest
     * @param isCancel is it a cancellation?
     *
     * @return The Meeting Request email with ICS attachment
     */
    public static List<Messaging.SingleEmailMessage> createEvent(String uid, Event event, Boolean isCancel, String site, String department) {
        return createEvent(uid, event, isCancel, site, department, DateTime.now());
    }

    /**
     * Prepare Meeting Request email with ICS attachment
     * @param uid UID used in ICS
     * @param event Details of the meeting requeest
     * @param isCancel is it a cancellation?
     * @param timeStamp the timeStamp
     *
     * @return The Meeting Request email with ICS attachment
     */
    public static List<Messaging.SingleEmailMessage> createEvent(String uid, Event event, Boolean isCancel, String site, String department, DateTime timeStamp) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage personalEmail = prepareEmail(event);
        Messaging.SingleEmailMessage siteEmail = prepareEmail(event, Label.Public_Calendar_Beginning_Escape_String + site + Label.Public_Calendar_Ending_Escape_String, CALENDAR_INTEGRATION_USER.Id);
        Messaging.SingleEmailMessage departmentEmail = prepareEmail(event, Label.Public_Calendar_Beginning_Escape_String + department + Label.Public_Calendar_Ending_Escape_String, CALENDAR_INTEGRATION_USER.Id);
        
        personalEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{prepareAttachment(uid, event, isCancel, timeStamp)});
        siteEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{prepareAttachment(uid, event, isCancel, timeStamp)});
        departmentEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{prepareAttachment(uid, event, isCancel, timeStamp)});

        emails.add(personalEmail);
        emails.add(siteEmail);
        emails.add(departmentEmail);

        return emails;
    }
    
    /**
     * Prepare email
     * @param event Details of the meeting requeest
     *
     * @return The email 
     */
    public static Messaging.SingleEmailMessage prepareEmail(Event event) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSaveAsActivity(false);
        email.setTargetObjectId(event.ownerId);
        email.setSubject(event.subject);
        email.setPlainTextBody(event.description);
        
        return email;
    }
    
    public static Messaging.SingleEmailMessage prepareEmail(Event event, String subjectSuffix, Id targetObjectId) {
        event = event.clone();
        event.subject = event.subject + ' ' + subjectSuffix;
        event.ownerId = targetObjectId;
        return prepareEmail(event);
    }

    /**
     * Prepare ICS file as email attachment
     * @param uid UID used in ICS
     * @param event Details of the meeting requeest
     * @param isCancel is it a cancellation?
     * @param timeStamp the timeStamp
     *
     * @return The ICS prepared as a format of email attachment 
     */
    public static Messaging.EmailFileAttachment prepareAttachment(String uid, Event event, Boolean isCancel, DateTime timeStamp) {
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.inline = true;
        attachment.ContentType = ICS_CONTENT_TYPE;
        attachment.setFileName(ICS_FILENAME);
        
        String method;
        String sequence;
        
        if (!isCancel)  {
            method = ICS_REQUEST_METHOD;
            sequence = ICS_REQUEST_SEQUENCE;
        } else {
            method = ICS_CANCEL_METHOD;
            sequence = ICS_CANCEL_SEQUENCE;
        }
        
        String startDateTime = event.startDateTime.formatGmt(UTC_DATE_FORMAT);
        String endDateTime = event.endDateTime.formatGmt(UTC_DATE_FORMAT);
        String timeStampString = timeStamp.formatGmt(UTC_DATE_FORMAT);
        
        String body = String.format(ICS, new String[]{method, startDateTime, endDateTime, uid, timeStampString, sequence, (isCancel ? ICS_CANCELLED_STATUS : '')});
                
        attachment.setBody(Blob.valueOf(body));
        
        return attachment;
    }
    
    /**
     * Prepare ICS file as email attachment
     * @param uid UID used in ICS
     * @param event Details of the meeting requeest
     * @param isCancel is it a cancellation?
     *
     * @return The ICS prepared as a format of email attachment 
     */
    public static Messaging.EmailFileAttachment prepareAttachment(String uid, Event event, Boolean isCancel) {
        return prepareAttachment(uid, event, isCancel, DateTime.now());
    }
}