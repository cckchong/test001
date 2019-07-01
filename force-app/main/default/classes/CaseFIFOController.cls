public class CaseFIFOController
{
    public static final String UNCLASSIFIED = 'Unclassified_Case_USA';
    private static final String CSR = 'CSR';
    private static final String CSR_3PL = '3PL-CSR';
    
    // Mapping between brand and email template
    private static final Map<String, Brand_to_Email_Template__c> brandEmailTemplate = Brand_to_Email_Template__c.getAll();

    public Case currentCase;
    private String queue;
    
    // Constructor
    public CaseFIFOController(ApexPages.StandardController standardController)
    {
        // Claim case directly from case itself.
        currentCase = [
            SELECT id, assignment_timestamp_USA__c, brand_USA__c, contactId, contact.email, SuppliedName, SuppliedEmail, First_Acknowledge_by_USA__c
            FROM Case
            WHERE id = :standardController.getRecord().id
        ];
    }
    public CaseFIFOController(ApexPages.StandardSetController stdSetController)
    {
        // Claim latest case from queue.
    }
    
    public Pagereference executeCSR()
    {
        queue = CSR;
        return executeListView();
    }
    
    public PageReference execute3PLCSR()
    {
        queue = CSR_3PL;
        return executeListView();
    }
    
    private boolean isMemberOfQueue()
    {
        Group g = [
            SELECT Id
            FROM Group
            WHERE Name = :queue
            AND Type = 'Queue'
            LIMIT 1
        ];
        
        Set<Id> idSet = getUserIdsFromGroup(g.Id);
        
        for (Id uid : idSet)
        {
            if (uid == UserInfo.getUserId())
            {
                return true;
            }
        }
        
        List<User> u = [
            SELECT id
            FROM user
            WHERE id = :UserInfo.getUserId()
            AND userRoleId IN :getRolesInGroup(idSet)
        ];
        
        if (!u.isEmpty())
        {
            return true;
        }
        
        return false;
    }
    
    private PageReference executeListView()
    {
        try
        {
            /*
            Group g = [
                SELECT Id
                FROM Group
                WHERE Name = :queue
                AND Type = 'Queue'
            ];
            
            for (Id uid : getUserIdsFromGroup(g.Id))
            {
                if (uid == UserInfo.getUserId())
                {
                    return new PageReference(
                        'javascript: ' + 
                        'alert(\'You are not a member of this queue.\');' + 
                        'window.history.back();'
                    );
                }
            }
			*/
            
            // Check if user belongs to queue.
            if (!isMemberOfQueue())
            {
                return new PageReference(
                    'javascript: ' + 
                    'alert(\'You are not a member of this queue.\');' + 
                    'window.history.back();'
                );
            }
        }
        catch (QueryException qe)
        {
            return new PageReference(
                'javascript: ' + 
                'alert(\'Queue ' + queue + ' not found.\');' + 
                'window.location=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/500/o\';'
            );
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        
        // Retrieve appropriate case belonging to queue.
        try
        {
            currentCase = [
                SELECT id, assignment_timestamp_USA__c, brand_USA__c, contactId, contact.email, SuppliedName, SuppliedEmail, First_Acknowledge_by_USA__c
                FROM Case
                WHERE status != 'Closed'
                //AND subject = 'Deloitte testing do not touch'
                AND OwnerId IN (
                    SELECT Id
                    FROM Group
                    WHERE Name = :queue
                    AND Type = 'Queue'
                )
                ORDER BY CreatedDate ASC // Get the oldest case meeting requirements.
                LIMIT 1
            ];
        }
        catch (QueryException qe)
        {
            return new PageReference(
                'javascript: ' + 
                'alert(\'Congrats! All ' + queue + ' cases have been claimed.\');' + 
                'window.history.back();'
            );
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        
        return executeFIFO();
    }
    
    // Execute the FIFO logic
    private PageReference executeFIFO()
    {
        PageReference pageReference = new PageReference('/' + currentCase.id);
        
        // Customer already notified, skip the email and return to the case.
        if (currentCase.assignment_timestamp_USA__c != null)
        {
            return pageReference;
        }
        
        assignCase();
        
        // Check for brand.
        if (currentCase.brand_USA__c == null)
        {
            return new PageReference(
                'javascript: ' + 
                'alert(\'Brand not assigned, customer notification email will not be sent.\');' + 
                'window.location=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentCase.Id + '\';'
            );
        }
        
        // Lookup the corresponding email template.
        if (brandEmailTemplate.get(currentCase.brand_USA__c) == null)
        {
            System.debug('### Brand: ' + currentCase.brand_USA__c);
            System.debug('### Brands: ' + brandEmailTemplate);
            return new PageReference(
                'javascript: ' + 
                'alert(\'Brand not configured in custom settings, email will not be sent.\');' + 
                'window.location=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentCase.Id + '\';'
            );
        }
        
        String emailTemplate = brandEmailTemplate.get(currentCase.brand_USA__c).Email_Template__c;
        String etid;
        
        try
        {
            EmailTemplate et = [
                SELECT id
                FROM EmailTemplate 
                WHERE developerName = :emailTemplate
                LIMIT 1
            ];
            
            etid = et.Id;
        }
        catch (QueryException qe)
        {
            return new PageReference(
                'javascript: ' + 
                'alert(\'Email template ' + emailTemplate + ' not found, email will not be sent.\');' + 
                'window.location=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentCase.Id + '\';'
            );
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        emails.add(email);
        
        email.setWhatId(currentCase.id);
        email.setTemplateId(etid);
        
        String emailId = brandEmailTemplate.get(currentCase.brand_USA__c).Org_Wide_Email_Id__c;
        if (emailId != null && emailId != '')
        {
            email.setOrgWideEmailAddressId(emailId);
        }
        
        if (currentCase.ContactId == null || currentCase.contact.Email == null || currentCase.contact.Email == '')
        {
            String accountId = brandEmailTemplate.get(currentCase.brand_USA__c).Account_Id__c;
            
            Contact c = new Contact();
            c.LastName = currentCase.SuppliedName == null? '<Name>' : currentCase.SuppliedName;
            c.Email = currentCase.SuppliedEmail;
            c.AccountId = accountId;
            
            insert c;
            
            currentCase.ContactId = c.Id;
            update currentCase;
        }
        
        email.setTargetObjectId(currentCase.contactId);
        //email.setToAddresses(new List<String>{currentCase.SuppliedEmail});
        
        try
        {
            if (!Test.isRunningTest())
            {
                Messaging.sendEmail(emails);
            }
        }
        catch (Exception e)
        {
            System.debug('### ' + e.getMessage());
            System.debug('### ' + e.getStackTraceString());
            
            return new PageReference(
                'javascript: ' + 
                'alert(\'Organization-Wide Email Address for ' + currentCase.brand_USA__c + ' has not be verified, email will not be sent.\');' + 
                'window.location=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentCase.Id + '\';'
            );
        }
        
        return pageReference;
    }
    
    // Execute the FIFO logic
    public PageReference execute()
    {
        PageReference pageReference = new PageReference('/' + currentCase.id);
    
        if (currentCase.assignment_timestamp_USA__c != null)
        {
            return pageReference;
        }
        
        // Check for brand
        if (currentCase.brand_USA__c == null)
        {
            return new PageReference(
                'javascript: ' + 
                'alert(\'No brand selected\');' + 
                'window.history.back();'
            );
        }
        
        // Lookup the corresponding email template
        String emailTemplate = '';
        if (brandEmailTemplate.get(currentCase.brand_USA__c) != null)
        {
            emailTemplate = brandEmailTemplate.get(currentCase.brand_USA__c).Email_Template__c;
        }

        List<EmailTemplate> emailTemplates = [
            SELECT id
            FROM EmailTemplate
            WHERE developerName = :emailTemplate
        ];
        
        // Action only if a corresponding email template is found
        if (emailTemplates.size() > 0)
        {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            emails.add(email);
            
            email.setWhatId(currentCase.id);
            email.setTemplateId(emailTemplates.get(0).id);
            
            String emailId = brandEmailTemplate.get(currentCase.brand_USA__c).Org_Wide_Email_Id__c;
            if (emailId != null && emailId != '')
            {
                email.setOrgWideEmailAddressId(emailId);
            }
            
            System.debug('currentCase.contactId = ' + currentCase.contactId);
            System.debug('currentCase.contact.Email = ' + currentCase.contact.Email);
            
            if (currentCase.contactId == null)
            {
                return new PageReference(
                    'javascript: ' +
                    'alert(\'No contact associated with this case\');' + 
                    'window.history.back();'
                );
            }
            else if (currentCase.contact.Email == null || currentCase.contact.Email == '')
            {
                return new PageReference(
                    'javascript: ' + 
                    'alert(\'Missing email address for the contact associated with this case.\');' + 
                    'window.history.back();'
                );
            }
            
            email.setTargetObjectId(currentCase.contactId);
            Messaging.sendEmail(emails);
            
            assignCase();
        }
        
        return pageReference;
    }
    
    private void assignCase()
    {
        // Set the first respondant.
        if (currentCase.First_Acknowledge_by_USA__c == null)
        {
        	currentCase.First_Acknowledge_by_USA__c = UserInfo.getUserId();
        }
        
        // Set the owner to the current login user.
        currentCase.ownerId = UserInfo.getUserId();
        
        // Set the assignment timestamp to now.
        currentCase.assignment_timestamp_USA__c = DateTime.now();
        
        update currentCase;
        
        
        // Add case as claimed in custom object.
        Case_Claim__c cc = new Case_Claim__c();
        cc.case__c = currentCase.Id;
        cc.claimant__c = UserInfo.getUserId();
        
        insert cc;
	}
    
    /*
     * Recursively checks all groups within a group to retrieve the list of all member ids.
     */
    public static Set<id> getUserIdsFromGroup(Id groupId)
    {
        // Store the results in a set so we don't get duplicates
        Set<Id> result = new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        
        System.debug('### userType ' + userType);
        System.debug('### groupType ' + groupType);
        
        System.debug('### group info :' + [SELECT id, name, relatedid from group where relatedid = :groupid]);
        
        // Loop through all group members in a group
        for (GroupMember m : [
            SELECT Id, UserOrGroupId, group.name, groupid
            FROM GroupMember
            WHERE GroupId = :groupId])
        {
            System.debug('### ' + m.userorgroupid);
            System.debug('### group name: ' + m.group.name);
            System.debug('### group id: ' + m.groupid);
            System.debug('### user? ' + ((String) m.UserOrGroupId).startsWith(userType));
            System.debug('### group? ' + ((String) m.UserOrGroupId).startsWith(groupType));
            
            // If the user or group id is a user
            if (((String) m.UserOrGroupId).startsWith(userType))
            {
                System.debug('### adding member ' + m.UserOrGroupId);
                
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String) m.UserOrGroupId).startsWith(groupType))
            {
                System.debug('================================================');
                System.debug('### adding members from group ' + m.UserOrGroupId);
                // Call this function again but pass in the group found within this group
                result.add(m.UserOrGroupId);
                result.addAll(getUserIdsFromGroup(m.UserOrGroupId));
            }
        }
        System.debug('### results: ' + result);
        
        return result;  
    }
    
    public static Set<Id> getRolesInGroup(Set<Id> ids)
    {
        String roleType = Schema.SObjectType.UserRole.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        
        System.debug('### roleType ' + roleType);
        System.debug('### groupType ' + groupType);
        
        Set<Id> groupIds = new Set<Id>();
        for (Id i : ids)
        {
			if (((String) i).startsWith(groupType))
            {
				groupIds.add(i);
            }
        }
        
        List<Group> groups = [
            SELECT Id, name, relatedId 
            FROM Group
            WHERE id IN :groupIds
        ];
        Set<Id> roles = new Set<Id>();
        for (Group g : groups)
        {
			if (((String) g.RelatedId).startsWith(roleType))
            {
				roles.add(g.RelatedId);
            }
        }
        
        return getAllSubordinateRoleIDs(roles);
    }
    
    public static Set<Id> getAllSubordinateRoleIDs(Set<Id> roleId)
    {
        Set<Id> result = new Set<Id>();
        
        System.debug('### roleID: ' + roleId);
        
        List<UserRole> urs = [
            SELECT Id
            FROM UserRole
            Where ParentRoleId IN :roleId
        ];
        
        if (urs.isEmpty())
        {
            return result;
        }
        
        Set<Id> children = new Set<Id>();
        for (UserRole ur : urs)
        {
			children.add(ur.id);
        }
        
        result.addAll(getAllSubordinateRoleIDs(children));
        
        return result;
    }
}