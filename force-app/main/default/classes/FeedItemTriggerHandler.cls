/**
 * @description Handler for Feed Item
 * 				(1) Check if the user is allowed to post in the Chatter Group
 *  			Only Manager of the Chatter Group is allowed to post 
 */
public without sharing class FeedItemTriggerHandler {
    
    /**
     * @description we should only run this trigger if the ParentId of the FeedItem is a CollaborationGroup
     */
    public static boolean runIfParentIsGroup(List<FeedItem> recordList) {
        boolean runThisHandler = false;
        
        for(FeedItem fi : recordList) {
            if(fi.ParentId != null) {
                Id theParentId = fi.ParentId;
                
                if(theParentId.getSObjectType() == CollaborationGroup.sObjectType) {
                    runThisHandler = true;
                    return runThisHandler;
                }
            }
        }
        
        return runThisHandler;
    }  
    
    public static void createServiceNowTicket(Map<Id, FeedItem> feedItemMap) {
    	ServiceNowUtil.createServiceNowTicket(feedItemMap);
    }
    
   	public static void handleAcgArticleConversion(List<FeedItem> listNewFeedItem) {
    	ACGFeedItemUtil.createACGArticle(listNewFeedItem); // Insert
        ACGFeedItemUtil.createACGArticleFromGroupMention(listNewFeedItem);
    }
    
    public static void handleAcgArticleConversionUpdate(List<FeedItem> listNewFeedItem) {
    	ACGFeedItemUtil.updateACGArticle(listNewFeedItem); // Update
    }
    
    public static void restrictPostEditAccessToOwners(List<FeedItem> feedItemList) {
        ChatterSecurityUtils.restrictPostEditAccessToOwners(feedItemList);
    }
    
    /**
     * @description uses the new Custom Permissions to define if users can post to a group
     * @author Andrew Ng
     */
    public static void validatePostingRightCustomPermissions(List<FeedItem> listNewFeedItem)
    {

        List<FeedItem> feedItemsToCheck = new List<FeedItem>();
        
        // Exit if this user can bypass all security
        for(FeedItem item : listNewFeedItem) {
            // Bypass Security if we see the ACGPublishKeyword
            if (item.Title != null && item.Title != '' && item.ParentId.getSObjectType() == CollaborationGroup.sObjectType) {
                if (item.Title.contains(Label.ACGPublishKeyword)) {
                    item.Title = item.Title.replace(Label.ACGPublishKeyword, '');
                } else {
                    feedItemsToCheck.add(item);
                }
            } else {
                feedItemsToCheck.add(item);
            }
        }
        
        if(ChatterSecurityUtils.canCurrentUserUpdateGroup()) {        
            return;
        }
        
        Map<Id, ChatterSecurityUtils.ChatterSecurityUser> userIdWithChatterSecurity = ChatterSecurityUtils.getUsersWithChatterSecurity();
        
        Set<Id> setGroupIds = new Set<Id>();
        Map<Id, Set<Id>> mapGroupManagers = new Map<Id, Set<Id>>();
        for (FeedItem Item : feedItemsToCheck) {
            setGroupIds.add(Item.parentId);
        }
        
        // Fetch the Chatter Groups and the Owner Ids
        Set<Id> setACGGroupIds = new Set<Id>();
        Set<Id> setUserOwnerIds = new Set<Id>();
        Map<Id, Id> groupIdToGroupOwnerId = new Map<Id, Id>();
        
        
        String ignoreGroupName = '';
        if(DMS_Settings__c.getValues('managerGroup') != null) {
        	ignoreGroupName = DMS_Settings__c.getValues('managerGroup').Value__c;    
        }
        
        for(CollaborationGroup cg: 
            [
            	SELECT Id, OwnerId 
                FROM CollaborationGroup 
                WHERE Id IN :setGroupIds
                AND Name <> :ignoreGroupName
            ]) {
            
            setACGGroupIds.add(cg.Id);
            groupIdtoGroupOwnerId.put(cg.Id, cg.OwnerId);
        }
        
        // Define a map of Chatter Group Id to Manager Members
        List<CollaborationGroupMember> listMembers = 
             [
                Select c.Id, c.CollaborationRole, c.CollaborationGroupId, c.CollaborationGroup.Name, c.MemberId  From CollaborationGroupMember c
                Where c.CollaborationGroupId IN:setACGGroupIds 
                And c.MemberId =:UserInfo.getUserId()
                And c.CollaborationRole ='Admin'
             ]; //Admin indicates that a user is a group manager. 
        
        for(CollaborationGroupMember cgm: listMembers) {
            if(mapGroupManagers.containsKey(cgm.CollaborationGroupId)) {
                mapGroupManagers.get(cgm.CollaborationGroupId).add(cgm.MemberId);
            } else {
                Set<Id> members = new Set<Id>();
                members.add(cgm.MemberId);
                mapGroupManagers.put(cgm.CollaborationGroupId, members);
            }
        }
        
        System.debug('@@@ mapGroupManagers ' + mapGroupManagers);

        for (FeedItem Item : feedItemsToCheck) {
            // First check if this Group is in scope for Security Check
            Id ownerId = groupIdtoGroupOwnerId.get(item.parentId);
            ChatterSecurityUtils.ChatterSecurityUser csu = userIdWithChatterSecurity.get(ownerId);
            if(ownerId != UserInfo.getUserId() && csu != null && csu.applySecurity) {
                
                // Security enabled, check if the current user is a manager of the group
                
                boolean currentUserNotManager = false;
                if(mapGroupManagers.containskey(item.parentId)) {
                    if(!mapGroupManagers.get(item.parentId).contains(UserInfo.getUserId())) {
                        currentUserNotManager = true;
                    }
                } else {
                    // No managers in this group
                    currentUserNotManager = true;
                }
                
                // Now check what type of FeedItem this is
                if(currentUserNotManager) {
                    
                    if(Item.Type == 'TextPost') {
                        if(!csu.canPost) {
                        	Item.addError(System.Label.ChatterGroupPostingError);
                        }
                    } else if(Item.Type == 'ContentPost') {
                        if(!csu.canPostFile) {
                        	Item.addError(System.Label.ChatterGroupPostingError);    
                        }
                    } else if(Item.Type == 'LinkPost') {
                        if(!csu.canPostLink) {
                        	Item.addError(System.Label.ChatterGroupPostingError);    
                        }
                    } else if(!csu.canOtherActions) {
                        Item.addError(System.Label.ChatterGroupPostingError);
                    }
                } else {
                    // Check permissions for Manager
                    if(Item.Type == 'TextPost') {
                        if(!csu.managerCanPost) {
                        	Item.addError(System.Label.ChatterGroupPostingError);
                        }
                    } else if(Item.Type == 'ContentPost') {
                        if(!csu.managerCanPostFile) {
                        	Item.addError(System.Label.ChatterGroupPostingError);    
                        }
                    } else if(Item.Type == 'LinkPost') {
                        if(!csu.managerCanPostLink) {
                        	Item.addError(System.Label.ChatterGroupPostingError);    
                        }
                    } else if(!csu.managerCanOtherActions) {
                        Item.addError(System.Label.ChatterGroupPostingError);
                    }
                }
            }               
        }
    }
    //@deprecated
    public static void validatePostingRight(List<FeedItem> listNewFeedItem)
    {
       // Deprecated
    }
}