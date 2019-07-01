/**
 * Handler for EmailMessageTrigger
 * @author William Cheng
 * @date 16/02/2015
 * 
 * Updated 24/03/2016 by James, for formatting.
 */
public class EmailMessageTriggerHandler
{
    // USA case record type suffix
    private static final String USA_CASE_RECORD_TYPE_SUFFIX = '_USA';
    
    // Status for Case created from email to closed case
    private static final String CASE_CREATED_FROM_EMAIL_TO_CLOSED_CASE_STATUS = 'New';

    // Case origin for Case created from email to closed case
    private static final String CASE_CREATED_FROM_EMAIL_TO_CLOSED_CASE_ORIGIN = 'Email';
    
    // Unclassified Case developer name for Case created from email to closed case
    private static final String UNCLASSIFIED_CASE_DEVELOPER_NAME = 'Unclassified_Case_USA';

    /**
     * Hand incoming email send to TAG cases
     * @param emailMessageMap the email message map
     */
    public static void handleTagCaseEmail(Map<Id, EmailMessage> emailMessageMap)
    {
        Map<ID, EmailMessage> caseToEmailMessage = new Map<ID, EmailMessage>();
        Set<ID> outgoingEmailCaseIds = new Set<ID>();
        
        // Filter incoming email only
        for (EmailMessage emailMessage : emailMessageMap.values())
        {
            if (emailMessage.incoming)
            {
                caseToEmailMessage.put(emailMessage.parentId, emailMessage);
            }
            else
            {
                outgoingEmailCaseIds.add(emailMessage.parentId);
            }
        }

        // Look for unclassified case record type
        List<RecordType> unclassifiedCaseRecordType = [
            SELECT id
            FROM RecordType
            WHERE SobjectType = 'Case'
            AND developerName = :UNCLASSIFIED_CASE_DEVELOPER_NAME
            LIMIT 1
        ];
        
        Id unclassifiedCaseRecordTypeId;
        if (!unclassifiedCaseRecordType.isEmpty())
        {
            unclassifiedCaseRecordTypeId = unclassifiedCaseRecordType.get(0).id;
        }
        else
        {
            throw new TALException('Unclassified Case Record Type not found');
        }

        // Filter TAG Case only
        Map<ID, Case> caseMap = new Map<Id, Case>([
            SELECT id, isClosed, Subject, AccountId, Priority, Description, ContactId, OwnerId
            FROM Case
            WHERE id IN :caseToEmailMessage.keySet()
            AND recordType.developerName LIKE :('%' + USA_CASE_RECORD_TYPE_SUFFIX)]);

        DateTime now = DateTime.now();
        List<Case> upsertCases = new List<Case>();
        
        for (Case c : caseMap.values())
        {
            // Update the last inbound emai timestamp
            Case parentCase = new Case(id = c.id, Last_Inbound_Email_Time__c = now);
            upsertCases.add(parentCase);
            
            if (c.isClosed)
            {
                EmailMessage emailMessage = caseToEmailMessage.get(c.id);

                upsertCases.add(new Case(Subject = '[CC] ' + emailMessage.Subject
                                        , AccountId = c.AccountId
                                        , Priority = c.Priority
                                        , Description = emailMessage.TextBody
                                        , ContactId = c.ContactId
                                        , OwnerId = c.OwnerId
                                        , Status = CASE_CREATED_FROM_EMAIL_TO_CLOSED_CASE_STATUS
                                        , Origin = CASE_CREATED_FROM_EMAIL_TO_CLOSED_CASE_ORIGIN
                                        , IsEscalated = false
                                        , ParentId = c.id
                                        , RecordTypeId = unclassifiedCaseRecordTypeId
                                        , Created_from_Email_to_Closed_Case_USA__c = true
                                        ));
            }
        }
        
        // Filter TAG Case only
        Map<ID, Case> outgoingEmailCaseMap = new Map<Id, Case>([
            SELECT id
            FROM Case
            WHERE id IN :outgoingEmailCaseIds
            AND First_Outgoing_Email_Timestamp__c = null
            AND recordType.developerName LIKE :('%' + USA_CASE_RECORD_TYPE_SUFFIX)
        ]);

        for (Case c : outgoingEmailCaseMap.values())
        {
            c.First_Outgoing_Email_Timestamp__c = now;
            upsertCases.add(c);
        }
        
        // Update
        upsert upsertCases;
    }
}