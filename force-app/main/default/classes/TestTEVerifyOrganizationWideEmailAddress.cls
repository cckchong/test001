@isTest 
public class TestTEVerifyOrganizationWideEmailAddress{
    @isTest 
    public static void test() {
    
        TEVerifyOrganizationWideEmailAddress ver = new TEVerifyOrganizationWideEmailAddress();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.htmlBody = 'test';
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result = ver.handleInboundEmail(email, null);
        
        system.assertNotEquals(null,result);
    }
}