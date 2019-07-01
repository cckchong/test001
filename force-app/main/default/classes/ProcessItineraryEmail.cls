global class ProcessItineraryEmail implements Messaging.InboundEmailHandler {

  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    Messaging.SingleEmailMessage forwardemail= new Messaging.SingleEmailMessage ();   
    Messaging.EmailFileAttachment forwardemailAttachment;
    List<Messaging.EmailFileAttachment> forwardemailAttachmentList;

    Travel_Application__c travelApplication = null;
    Attachment attachment = null;
    String emailsubject = null;
    String referenceNo = null;
    String recordId = null;
    Integer referenceNoLength = 11;
    Integer recordIdLength = 15;
    String matchReferenceNo = Label.TE_SendEmail_matchReferenceNo; //'TA-';
    String matchRecordId = 'a18O';
    String matchContentType = 'text/plain';
    String matchFileExtension = '.txt';
    String travelApplicationStatus = null;
    List<String> toAddresses;
    Map<String, String> keywordMap = new Map<String, String> ();
    keywordMap.put(Label.TE_Email_Accept,TEConstant.STATUS_CONFIRMED);
    //keywordMap.put(Label.TE_Email_Reject,TEConstant.STATUS_REJECT);
    
    emailsubject = email.subject;
    referenceNo = emailsubject.substring(emailsubject.indexOf(matchReferenceNo), emailsubject.indexOf(matchReferenceNo) + referenceNoLength);
    
    //handling travel agency's txt attachment
    if (email.binaryAttachments != null && email.binaryAttachments.size() > 0 && email.toAddresses != null) {

        if(referenceNo != null){
            
            forwardemailAttachmentList = new List<Messaging.EmailFileAttachment>();
                for (Integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                    attachment = new Attachment();
                    forwardemailAttachment = new Messaging.EmailFileAttachment();
                    //attachment.ParentId = recordId;               
                    attachment.Name = email.binaryAttachments[i].filename;
                    attachment.Body = email.binaryAttachments[i].body;
                    
                    if(attachment.Name.toupperCase().contains(matchFileExtension.toupperCase())) {
                            attachment.ContentType = matchContentType;
                    }
                        if(travelApplication == null) {
                            travelApplication = [SELECT Id, Name, RecordTypeId, Created_By_Email__c, Applicant_Email__c, On_Behalf_Of_UserId__c, UserId_Created_By__c
                                                 FROM Travel_Application__c WHERE Name =: referenceNo];

                        }
                        if(travelApplication != null) {
                            //attachment.ParentId = recordId;    
                            attachment.ParentId = travelApplication.Id;
                            //set ContentType for filling the requirments of attachment trigger to read the body of attachment and insert corresponding records 
                            insert attachment;
                            
                            forwardemailAttachment.setFileName(attachment.Name);
                            forwardemailAttachment.setInline(false);
                            forwardemailAttachment.setBody(attachment.Body);
                            forwardemailAttachmentList.add(forwardemailAttachment);
                    }
                }
                //Forward Email to Applicant
                /*
                forwardemail.setTargetObjectId(travelApplication.UserId_Created_By__c);                
                forwardemail.setTreatTargetObjectAsRecipient(true); 
                forwardemail.setSubject (emailsubject);
                forwardemail.setHtmlBody (email.htmlBody);
                forwardemail.setPlainTextBody(email.plainTextBody);
                forwardemail.saveAsActivity = false;
                
                forwardemail.setFileAttachments(forwardemailAttachmentList);
                Messaging.sendEmail(new Messaging.SingleEmailMessage [] {forwardemail});
                if (travelApplication.On_Behalf_Of_UserId__c != null && travelApplication.On_Behalf_Of_UserId__c != travelApplication.UserId_Created_By__c){
                   forwardemail.setTargetObjectId(travelApplication.On_Behalf_Of_UserId__c);
                   Messaging.sendEmail(new Messaging.SingleEmailMessage [] {forwardemail});
                }
                */
            }
    }
    //changing the status when the body contains keyword and no attachment
    //email.binaryAttachments == null && email.binaryAttachments.size() == 0 && 
    else if (email.binaryAttachments == null && email.toAddresses != null) {
        //if(email.plainTextBody.toupperCase().contains(replyKeyword.toupperCase())) {

        for(string reader: keywordMap.keyset()){
            if(email.plainTextBody.toupperCase().contains(reader.toupperCase())) {
                travelApplicationStatus  = keywordMap.get(reader);
            }
        }
        if((travelApplicationStatus  != null) && (referenceNo != null)) {
            travelApplication = [SELECT Id, Name, RecordTypeId, status__c,Trip_Remarks__c FROM Travel_Application__c WHERE Name =: referenceNo  LIMIT 1];
            if(travelApplication != null){
                travelApplication.status__c = travelApplicationStatus;
                update travelApplication;
            }
        }
    }
    return result;
  }
}