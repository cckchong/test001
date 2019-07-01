global class TEVerifyOrganizationWideEmailAddress implements Messaging.InboundEmailHandler {

  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        List<String> toAddress = new List<String> ();
        toAddress.add('tagenuser@gmail.com');      
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName(email.fromName);        
        mail.setSubject(email.subject);
        mail.setToAddresses(toAddress);
        //mail.setPlainTextBody(email.plainTextBody);
        mail.setHtmlBody(email.htmlbody);

        

        //Send the email you have created
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });     

    return result;

  }
}