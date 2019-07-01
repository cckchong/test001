/**
 * TEEducationApplicationTriggerHandler
 * @author Kelvin Wong and Ted Pang
 * @description Send emails to all HCM users after approval and initialize the field values when Status is Pending Approval
 */
public class TEEducationApplicationTriggerHandler {
    
    private Messaging.SingleEmailMessage [] mails;
    private Static String INDICATOR = '@name';
    private Static String INDICATOR1 = '@eid';
    
    private void setEmail(String fromEmail, String name, String toEmail, ID recipient, ID candidate, ID template) {
    
        // New instance of a single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // The email template ID used for the email
        mail.setTemplateId(template);
        mail.saveAsActivity = false;
        // Who you are sending the email to
        mail.setTargetObjectId(recipient);
        mail.setWhatId(candidate);
        mails.add(mail);
        
    }
    
    /**
     * @description delete all the contacts for sending emails
     */
    public static void deleteContacts(List<Contact> contactList){
        delete contactList;
    }
    
    /**
     * @description get HCM users list
     * @return list of Contacts of HCM users for sending emails
     */
    public static List<Contact> getHCMUsers(){
        List<Id> groupMemberList = new List<Id>();
        for (GroupMember gm : [select UserOrGroupId from GroupMember where GroupId IN (select Id from Group where DeveloperName = :TEConstant.EDUCATION_HCM_HKO)]){
            groupMemberList.add(gm.UserOrGroupId);
        }
        List<User> userList = new List<User>();
        for (User user : [SELECT Id, FirstName, LastName, Username, Email, IsActive FROM User where id in :groupMemberList ]){
            userList.add(user);
        }
        List<Contact> contactList = new List<Contact>();
        for (User user : userList){
            contactList.add(new Contact(
                LastName = user.LastName,
                FirstName = user.FirstName,
                Email = user.Email));
        }
        upsert contactlist;
        return contactList;
    }
    
    /**
     * @description get the email template
     * @return ID of the email template
     */
    public static Id getEmailTemplate(){
        Id emailTemplateId = null;
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        for (EmailTemplate et : [select id from EmailTemplate where DeveloperName = :TEConstant.EDUCATION_APPLICATION_STATUS_CHANGED_EMAIL_TEMPLATE]){
            emailTemplateList.add(et);
        }
        if (!emailTemplateList.isEmpty()) {
            emailTemplateId = emailTemplateList[0].Id;
        }
        return emailTemplateId;
    }
    
    /**
     * @description send the email to all HCM users after approval
     */
    public static void sendHCMAfterApproval(List<Education_Application__c> newList, Map<Id, Education_Application__c> oldMap){
        TEEducationApplicationTriggerHandler handler = new TEEducationApplicationTriggerHandler();
        List<Id> eduAppIdList = new List<Id>();
        List<Contact> hcmContacts = getHCMUsers();
        handler.mails = new Messaging.SingleEmailMessage [] {};
        for (Education_Application__c eduApp : newList){
            if ((oldMap.get(eduApp.Id).Status__c != eduApp.Status__c) && 
                (eduApp.Status__c == TEConstant.STATUS_APPROVED || eduApp.Status__c == TEConstant.STATUS_CANCEL_NOT_SUBMITTED
                 || eduApp.Status__c == TEConstant.STATUS_CANCELLED || eduApp.Status__c == TEConstant.STATUS_REJECT)){
                     eduAppIdList.add(eduApp.Id);
                 }
        }
        Id emailTemplate = getEmailTemplate();
        for (Id eduAppId : eduAppIdList){
            for (Contact contact : hcmContacts){
                handler.setEmail(TEConstant.EDUCATION_APPLICATION_EMAIL, TEConstant.EDUCATION_APPLICATION_EMAIL_NAME, 
                          contact.Email, contact.Id, eduAppId, emailTemplate);
            }
        }
        Messaging.sendEmail(handler.mails);
        deleteContacts(hcmContacts);
    }
    
    /**
     * @description Initialize the field values when education application's status is Pending Approval
     */    
    public static void initFieldValues(Map <Id, Education_Application__c> newEducationApplicationMap, Map <Id, Education_Application__c> oldEducationApplicationMap){
        
        Map <Id, Education_Application__c > employeeAdministratorMap = new Map <Id, Education_Application__c >();
        Map <Id, recordtype> recordtypeMap = null;
        List <Education_Application__c> EducationApplicationList= new List <Education_Application__c> ();
        String educationRecordTypeId = '';
        String msg = '';
        
        recordtypeMap = new Map <Id, recordtype>([select id, Name, DeveloperName from recordtype where SobjectType = :TEConstant.EDUCATION_APPLICATION_OBJECT_NAME]);
        for (recordtype reader :recordtypeMap.values()){
            if(reader.DeveloperName == TEConstant.EDUCATION_APPLICATION_EDUCATION){
                educationRecordTypeId = reader.id;
            }
        }
        
        for (Education_Application__c reader : newEducationApplicationMap.Values()){
            if ( reader.status__c == TEConstant.STATUS_REJECT && reader.status__c == oldEducationApplicationMap.get(reader.id).status__c  ){
                reader.status__c = TEConstant.STATUS_NOT_SUBMITTED;
                reader.Tech_Education_Policy_Name__c = '';
            }
            if ( reader.status__c == TEConstant.STATUS_NOT_SUBMITTED || reader.status__c == TEConstant.STATUS_DRAFT || reader.status__c == TEConstant.STATUS_PENDING_APPROVAL){
                EducationApplicationList.add(reader);
                reader.Tech_Education_Policy_Name__c = '';
            }
            if(!EducationApplicationList.isempty()){
                //defValues(EducationApplicationList);
            }
            EducationApplicationList= new List <Education_Application__c> ();
            if (  reader.status__c == TEConstant.STATUS_PENDING_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION){
                reader.Couse_Type__c = oldEducationApplicationMap.get(reader.id).Couse_Type__c;
                reader.Education__c = oldEducationApplicationMap.get(reader.id).Education__c;
                reader.Program_Course_Title__c = oldEducationApplicationMap.get(reader.id).Program_Course_Title__c;
                reader.Start_Date__c = oldEducationApplicationMap.get(reader.id).Start_Date__c;
                reader.Course_URL__c = oldEducationApplicationMap.get(reader.id).Course_URL__c;
                reader.End_Date__c = oldEducationApplicationMap.get(reader.id).End_Date__c;
                reader.Currency__c = oldEducationApplicationMap.get(reader.id).Currency__c;
                reader.Tuition_Fee__c = oldEducationApplicationMap.get(reader.id).Tuition_Fee__c;
                reader.Payment_Method__c = oldEducationApplicationMap.get(reader.id).Payment_Method__c;
                reader.Name_of_Child__c = oldEducationApplicationMap.get(reader.id).Name_of_Child__c;
                reader.Length_of_Program_Year__c = oldEducationApplicationMap.get(reader.id).Length_of_Program_Year__c;
                reader.On_Behalf_Of__c = oldEducationApplicationMap.get(reader.id).On_Behalf_Of__c;
            }
            //if ( reader.status__c == TEConstant.STATUS_REJECT){
            if ( reader.status__c == TEConstant.STATUS_PENDING_APPROVAL ){
                reader.Relevancy_to_work__c = oldEducationApplicationMap.get(reader.id).Relevancy_to_work__c;
                reader.Reliability_of_Course_Institute__c = oldEducationApplicationMap.get(reader.id).Reliability_of_Course_Institute__c;
                reader.Tuition_Fee_Recommended_Currency__c = oldEducationApplicationMap.get(reader.id).Tuition_Fee_Recommended_Currency__c;
                reader.Tuition_Fee_Recommended__c = oldEducationApplicationMap.get(reader.id).Tuition_Fee_Recommended__c;
                reader.Remarks__c = oldEducationApplicationMap.get(reader.id).Remarks__c;
                reader.Tech_Approver_1_Email__c = null;
                reader.Tech_Approver_2_Email__c = null;
                reader.Tech_Approver_3_Email__c = null;
                reader.Tech_Approver_4_Email__c = null;
                reader.Tech_Applicant_Email__c = null;
                reader.Tech_On_Behalf_Of_Email__c = null;
                reader.Tech_HCM_Email__c = null;
                reader.Tech_Applicant__c = null;
            }
            /*
            if ( reader.status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION){
                 reader.On_Behalf_Of__c = oldEducationApplicationMap.get(reader.id).On_Behalf_Of__c;
                 reader.Education__c= oldEducationApplicationMap.get(reader.id).Education__c;
                 reader.Start_Date__c= oldEducationApplicationMap.get(reader.id).Start_Date__c;
                 reader.End_Date__c= oldEducationApplicationMap.get(reader.id).End_Date__c;
                 reader.Name_of_Child__c= oldEducationApplicationMap.get(reader.id).Name_of_Child__c;
                 reader.Program_Course_Title__c= oldEducationApplicationMap.get(reader.id).Program_Course_Title__c;
                 reader.Length_of_Program_Year__c= oldEducationApplicationMap.get(reader.id).Length_of_Program_Year__c;
                 reader.Tuition_Fee__c= oldEducationApplicationMap.get(reader.id).Tuition_Fee__c;
                 reader.Currency__c= oldEducationApplicationMap.get(reader.id).Currency__c;
                 reader.Relevancy_to_work__c= oldEducationApplicationMap.get(reader.id).Relevancy_to_work__c;
                 reader.Tuition_Fee_Recommended__c= oldEducationApplicationMap.get(reader.id).Tuition_Fee_Recommended__c;
                 reader.Couse_Type__c= oldEducationApplicationMap.get(reader.id).Couse_Type__c;
                 reader.Degree_Course_Title__c= oldEducationApplicationMap.get(reader.id).Degree_Course_Title__c;
                 reader.Tuition_Fee_Recommended_Currency__c= oldEducationApplicationMap.get(reader.id).Tuition_Fee_Recommended_Currency__c;
                 reader.Reliability_of_Course_Institute__c= oldEducationApplicationMap.get(reader.id).Reliability_of_Course_Institute__c;
                 reader.Apply_Date__c= oldEducationApplicationMap.get(reader.id).Apply_Date__c;
                 reader.Course_URL__c= oldEducationApplicationMap.get(reader.id).Course_URL__c;
                 reader.Payment_Method__c= oldEducationApplicationMap.get(reader.id).Payment_Method__c;
            } 
			*/
            if ( reader.status__c == TEConstant.STATUS_APPROVED){
                System.Debug('*************Tuition_Fee_Recommended__c ');
                System.Debug(reader.Tuition_Fee_Recommended__c);
                if (oldEducationApplicationMap.get(reader.id).status__c == TEConstant.STATUS_NOT_SUBMITTED || oldEducationApplicationMap.get(reader.id).status__c == TEConstant.STATUS_DRAFT){
                    reader.Tuition_Fee_Recommended__c = reader.Tuition_Fee__c;
                }
                if (reader.Tuition_Fee_Recommended_Currency__c == null){
                    reader.Tuition_Fee_Recommended_Currency__c = reader.Currency__c;
                }
            }   
            
            /**       
            if ( reader.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL && reader.status__c != oldEducationApplicationMap.get(reader.id).status__c){
                reader.Reliability_of_Course_Institute__c  = '';     
                reader.Relevancy_to_work__c  = '';
                reader.Tuition_Fee_Recommended_Currency__c = null;            
                reader.Tuition_Fee_Recommended__c = null;
                reader.remarks__c = '';
            }*/
            
            if ( oldEducationApplicationMap.get(reader.id).status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL && 
                reader.status__c != TEConstant.STATUS_REJECT && reader.status__c != TEConstant.STATUS_NOT_SUBMITTED &&
                reader.status__c != oldEducationApplicationMap.get(reader.id).status__c){
                if (reader.recordtypeid == educationRecordTypeId){
                    if( reader.Reliability_of_Course_Institute__c == null || reader.Reliability_of_Course_Institute__c == ''){
                        msg = Label.TE_Empty_Value_Error.replace(INDICATOR, Education_Application__c.Reliability_of_Course_Institute__c.getDescribe().getlabel());
                        msg = msg.replace(INDICATOR1, reader.name);
                        reader.Reliability_of_Course_Institute__c.adderror(msg);                        
                    }
                    if( reader.Relevancy_to_work__c == null || reader.Relevancy_to_work__c == ''){
                        msg = Label.TE_Empty_Value_Error.replace(INDICATOR, Education_Application__c.Relevancy_to_work__c.getDescribe().getlabel());
                        msg = msg.replace(INDICATOR1, reader.name);
                        reader.Reliability_of_Course_Institute__c.adderror(msg);
                    }
                    if( reader.Tuition_Fee_Recommended_Currency__c == null ){
                        msg = Label.TE_Empty_Value_Error.replace(INDICATOR, Education_Application__c.Tuition_Fee_Recommended_Currency__c.getDescribe().getlabel());
                        msg = msg.replace(INDICATOR1, reader.name);
                        reader.Reliability_of_Course_Institute__c.adderror(msg);
                    }
                    if( reader.Tuition_Fee_Recommended__c == null || reader.Tuition_Fee_Recommended__c == 0){
                        msg = Label.TE_Empty_Value_Error.replace(INDICATOR, Education_Application__c.Tuition_Fee_Recommended__c.getDescribe().getlabel());
                        msg = msg.replace(INDICATOR1, reader.name);
                        reader.Reliability_of_Course_Institute__c.adderror(msg);
                    }
                }
            }
        }
        
        for (Education_Application__c reader : newEducationApplicationMap.Values()){
            if ((reader.status__c == TEConstant.STATUS_PENDING_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL) && reader.status__c != oldEducationApplicationMap.get(reader.id).status__c){
                EducationApplicationList.add(reader);
            }
        }
        if ( !EducationApplicationList.isempty()){   
            for (Education_Application__c reader : [
                select id, status__c,
                On_Behalf_Of__r.Employee__r.Approver_1__c, On_Behalf_Of__r.Employee__r.Approver_2__c,
                On_Behalf_Of__r.Employee__r.Approver_3__c, On_Behalf_Of__r.Employee__r.Approver_4__c,
                On_Behalf_Of__r.Employee__r.Acting_Approver_1__c, On_Behalf_Of__r.Employee__r.Acting_Approver_2__c,
                On_Behalf_Of__r.Employee__r.Acting_Approver_3__c, On_Behalf_Of__r.Employee__r.Acting_Approver_4__c,
                On_Behalf_Of__r.Employee_Administrator__r.User__c,
                On_Behalf_Of__r.Employee__r.Education_Policy__r.Name
                from Education_Application__c where id in :EducationApplicationList]){
                    employeeAdministratorMap.put(reader.id, reader);                
            }
            
            for (Education_Application__c reader : newEducationApplicationMap.values() ){
                if ( reader.status__c != oldEducationApplicationMap.get(reader.id).status__c && (reader.status__c == TEConstant.STATUS_PENDING_APPROVAL || reader.status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL)){
                    reader.Tech_Education_Policy_Name__c = employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Education_Policy__r.Name;
                    reader.Actual_Approver_1__c = (employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_1__c == null)? employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Approver_1__c : employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_1__c ;
                    reader.Actual_Approver_2__c = (employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_2__c == null)? employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Approver_2__c : employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_2__c ;
                    reader.Actual_Approver_3__c = (employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_3__c == null)? employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Approver_3__c : employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_3__c ;
                    reader.Actual_Approver_4__c = (employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_4__c == null)? employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Approver_4__c : employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee__r.Acting_Approver_4__c ;
                    reader.Tech_Applicant__c = employeeAdministratorMap.get(reader.id).On_Behalf_Of__r.Employee_Administrator__r.user__c;
                }
            }
            TEManualSharingCtrl.TEEducationApplicationSharing(EducationApplicationList, true);
        }
    }
    
    /**
     * @description def the field values when education application's status is Pending Approval
     */    
    /*
    public static void defValues(List <Education_Application__c> newEducationApplicationList){
        String tmp = '';
        for(Education_Application__c reader : newEducationApplicationList){
            tmp = Education_Application__c.Reliability_of_Course_Institute__c.getDescribe().getDefaultValueFormula();
            tmp = tmp.replace('"','');
            reader.Reliability_of_Course_Institute__c = tmp;            
            tmp = Education_Application__c.Relevancy_to_work__c.getDescribe().getDefaultValueFormula();
            tmp = tmp.replace('"','');
            reader.Relevancy_to_work__c = tmp;            
            reader.Tuition_Fee_Recommended_Currency__c = null;            
            reader.Tuition_Fee_Recommended__c = Double.Valueof(Education_Application__c.Tuition_Fee_Recommended__c.getDescribe().getDefaultValueFormula());
            tmp = Education_Application__c.Remarks__c.getDescribe().getDefaultValueFormula();
            tmp = tmp.replace('"','');
            reader.Remarks__c = tmp;            
        }
    }
	*/
    
}