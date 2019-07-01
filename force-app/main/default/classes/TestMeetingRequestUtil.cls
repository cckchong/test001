@isTest
public class TestMeetingRequestUtil {
    
    @isTest
    public static void shouldCreateEvent() {
        Event event = new Event(ownerId = UserInfo.getUserId()
                                , subject = 'UNIT_TEST_SUBJECT'
                                , description = 'UNIT_TEST_DESCRIPTION'
                                , startDateTime = DateTime.newInstance(2015, 1, 13, 9, 30, 0)
                                , endDateTime = DateTime.newInstance(2015, 1, 14, 17, 30, 0)
                                );

        List<Messaging.SingleEmailMessage> emails = MeetingRequestUtil.createEvent('UNIT_TEST_UID', event, false, 'UNIT_TEST_SITE', 'UNIT_TEST_SITE_UNIT_TEST_DEPARTMENT', DateTime.newInstance(2015, 2, 4, 17, 21, 0));
        
        String expectedICS =  'BEGIN:VCALENDAR'+ '\n'
                                + 'METHOD:REQUEST'+ '\n'
                                + 'VERSION:2.0' + '\n'
                                + 'BEGIN:VEVENT' + '\n'
                                + 'DTSTART:20150113T013000Z' + '\n'
                                + 'DTEND:20150114T093000Z' + '\n'
                                + 'UID:UNIT_TEST_UID' + '\n'
                                + 'DTSTAMP:20150204T092100Z' + '\n'
                                + 'SEQUENCE:0' + '\n'
                                + 'X-MICROSOFT-CDO-BUSYSTATUS:OOF' + '\n'
                                + 'END:VEVENT' + '\n'
                                + 'END:VCALENDAR' + '\n';

        System.assertEquals(3, emails.size());
        System.assertEquals('UNIT_TEST_SUBJECT', emails.get(0).getSubject());
        System.assertEquals(1, emails.get(0).getFileAttachments().size());
        System.assert(String.isNotBlank(emails.get(0).getFileAttachments().get(0).getFileName()));
        System.assertEquals(expectedICS, emails.get(0).getFileAttachments().get(0).getBody().toString());
        System.assertEquals(UserInfo.getUserId(), emails.get(0).getTargetObjectId());
        
        System.assertEquals('UNIT_TEST_SUBJECT {UNIT_TEST_SITE}', emails.get(1).getSubject());
        System.assertEquals('UNIT_TEST_SUBJECT {UNIT_TEST_SITE_UNIT_TEST_DEPARTMENT}', emails.get(2).getSubject());
    }
}