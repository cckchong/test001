/*****************************************************
Handler for Feed Item
1. Check if the user is allowed to post in the Chatter Group
   Only Manager of the Chatter Group is allowed to post

******************************************************/
public without sharing class FeedCommentTriggerHandler {
    
    /**
     * @description restrict editing of comments
     */
    public static void restrictCommentEditAccessToOwners(List<FeedComment> feedCommentList) {
        ChatterSecurityUtils.restrictCommentEditAccessToOwners(feedCommentList);
    }
    
    /**
     * @description this is an amazing feature in which it synchronizes the comments on a
     * 				Chatter Post with that of an ACG Post. Brilliant!
     */
    public static void syncAcgComments(List<FeedComment> feedCommentList) {
        ACGCommentSyncUtil.syncAcgArticleToPost(feedCommentList);
    }
    
    public static void updateServiceNowTicket(Map<Id, FeedComment> feedCommentMap) {
    	ServiceNowUtil.updateServiceNowTicket(feedCommentMap);
    }
    /*
    public static void updateServiceNowTicket(Map<Id, FeedComment> feedCommentMap) {
        // Find the SNOW user
        List<User> users = [Select id from User where email = :Label.ServiceNow_Email_Address limit 1];
        
        User user;
        if (users.size() > 0) {
            user = [Select id from User where email = :Label.ServiceNow_Email_Address];
        } else {
            for (FeedComment comment : feedCommentMap.values()) {
                comment.addError('SNOW user not found, please properly configure the SNOW user');
            }
        }
        
        
        // Find related FeedItem
        Map<Id, List<FeedComment>> feedItemCommentMap = new Map<Id, List<FeedComment>>();
        Set<ID> feedItemIds = new Set<ID>();
        
        for (FeedComment feedComment : feedCommentMap.values()) {
            if (user != null && feedComment.CreatedById != user.id) {
                List<FeedComment> feedComments = feedItemCommentMap.get(feedComment.FeedItemId);
                
                if (feedComments == null) {
                    feedComments = new List<FeedComment>();
                    feedItemCommentMap.put(feedComment.FeedItemId, feedComments);
                }
                
                feedComments.add(feedComment);
            }
            feedItemIds.add(feedComment.feedItemId);
        }
        
        Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>([Select Id, ParentId from FeedItem where id in :feedItemIds]);

        // Find incidents and urgents        
        List<TopicAssignment> incidents = [Select EntityId from topicAssignment where Topic.Name = 'HELP' and EntityId in :feedItemCommentMap.keySet()];
        List<TopicAssignment> urgents = [Select EntityId from topicAssignment where Topic.Name = 'HELP' and EntityId in :feedItemCommentMap.keySet()];
        Map<Id, Integer> urgentIncidents = new Map<Id, Integer>();
        
        for (TopicAssignment urgent : urgents) {
            urgentIncidents.put(urgent.EntityId, 1);
        }

        // Find attachments
        Set<Id> contentVersionId = new Set<Id>();
        for (FeedComment feedComment : feedCommentMap.values()) {
            contentVersionId.add(feedComment.RelatedRecordId);
        }
        
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([Select Id, VersionData, Title, FileExtension, ContentSize from ContentVersion where id in :contentVersionId]);

        // Prepare email to Service-Now
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
        
        Map<String, ObjectAppMapping__c> objectAppMapping = ObjectAppMapping__c.getAll();
        
        for (TopicAssignment incident : incidents) {
            List<FeedComment> feedComments = feedItemCommentMap.get(incident.EntityId);
            
            if (feedComments != null) {
                for (FeedComment feedComment : feedComments) {
                    FeedItem feedItem = feedItemMap.get(incident.EntityId);
                    String sobjectType = feedItem.ParentId.getSObjectType().getDescribe().getName();
                    String subject;
                    if (!feedComment.commentBody.contains('#HELP') && feedComment.createdById != user.Id) {
                        //subject = 'Update Incident for ChatterFeedId: ' + incident.EntityId;
                        feedComment.addError('Please visit Service-Now to continue work on the ticket');
                    } else {
                        subject = 'Incident for ChatterFeedId: ' + incident.EntityId;
                    }
                    
                    ContentVersion contentVersion = contentVersionMap.get(feedComment.relatedRecordId);
                    
                    if (contentversion != null && contentVersion.ContentSize > 5 * 1024 * 1024) {
                        feedcomment.addError('Attachment cannot be larger than 5MB');
                    } else {
                        emails.add(ChatterToServiceNowIncident.prepareEmail(user, sobjectType, '', feedComment.commentBody, subject, urgentIncidents.get(incident.EntityId) != null, objectAppMapping, contentVersion));
                    }
                }
            }
        }

        Messaging.sendEmail(emails);
    }
    */
    
    public static void validatePostingRightCustomPermissions(List<FeedComment> listNewFeedComment)
    {
        if(ChatterSecurityUtils.canCurrentUserUpdateGroup()) {
            return;
        }
        
        Map<Id, ChatterSecurityUtils.ChatterSecurityUser> userIdWithChatterSecurity = ChatterSecurityUtils.getUsersWithChatterSecurity();
        set<Id> setGroupIds = new set<Id>();
        
        Map<Id, Set<Id>> mapGroupManagers = new Map<Id, Set<Id>>();
        
        for (FeedComment comment : listNewFeedComment)
        {
            setGroupIds.add(comment.parentId);
        }

        // Fetch the Chatter Groups and the Owner Ids
        Set<Id> setACGGroupIds = new Set<Id>();
        Set<Id> setUserOwnerIds = new Set<Id>();
        Map<Id, Id> groupIdToGroupOwnerId = new Map<Id, Id>();
        
        String ignoreGroupName = '';
        if(DMS_Settings__c.getValues('managerGroup') != null) {
        	ignoreGroupName = DMS_Settings__c.getValues('managerGroup').Value__c;    
        }
        
        For(CollaborationGroup cg: [Select Id, OwnerId, Name From CollaborationGroup 
                                    Where Id IN :setGroupIds AND Name <> :ignoreGroupName]) {
                                        
            setACGGroupIds.add(cg.Id);
            groupIdtoGroupOwnerId.put(cg.Id, cg.OwnerId);
        }
        
        List<CollaborationGroupMember> listMembers = 
             [Select c.Id, c.CollaborationRole, c.CollaborationGroupId, c.CollaborationGroup.Name, c.MemberId  From CollaborationGroupMember c
                Where c.CollaborationGroupId IN:setACGGroupIds 
                And c.MemberId =:UserInfo.getUserId()
                And c.CollaborationRole ='Admin' ]; //Admin indicates that a user is a group manager.
        
        for(CollaborationGroupMember cgm: listMembers)
        {
            if(mapGroupManagers.containsKey(cgm.CollaborationGroupId))
            {
                mapGroupManagers.get(cgm.CollaborationGroupId).add(cgm.MemberId);
            }
            else
            {
                Set<Id> members = new Set<Id>();
                members.add(cgm.MemberId);
                mapGroupManagers.put(cgm.CollaborationGroupId, members);
            }
            
        }
        system.debug('@@@ mapGroupManagers ' + mapGroupManagers);
        for (FeedComment comment : listNewFeedComment) {
			// First check if this Group is in scope for Security Check
            Id ownerId = groupIdtoGroupOwnerId.get(comment.parentId);
            ChatterSecurityUtils.ChatterSecurityUser csu = userIdWithChatterSecurity.get(ownerId);
            if(ownerId != UserInfo.getUserId() && csu != null && csu.applySecurity) {
                // Security enabled, check if the current user is a manager of the group
                
                boolean currentUserNotManager = false;
                if(mapGroupManagers.containskey(comment.parentId)) {
                    if(!mapGroupManagers.get(comment.parentId).contains(UserInfo.getUserId())) {
                        currentUserNotManager = true;
                    }
                } else {
                    // No managers in this group
                    currentUserNotManager = true;
                }
                
                // Now check what type of FeedItem this is
                if(currentUserNotManager) {
                    if(!csu.canComment) {
                        comment.addError(System.Label.ChatterGroupPostingError);
                    }
                } else {
                    // Check permissions for Manager
                    if(!csu.managerCanComment) {
                        comment.addError(System.Label.ChatterGroupPostingError);
                    }
                }
            }
        }
    }
    
    // @deprecated
    public static void validatePostingRight(List<FeedComment> listNewFeedComment)
    { 
       
    }
}