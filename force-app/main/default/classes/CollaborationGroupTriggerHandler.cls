public class CollaborationGroupTriggerHandler {

    public static void validateOnlyOwnerCanUpdateGroup(Map<Id, CollaborationGroup> oldMap, Map<Id, CollaborationGroup> newMap) {

        // Can this person bypass this?
        if(ChatterSecurityUtils.canCurrentUserUpdateGroup()) {
            return;
        }
        List<CollaborationGroup> groupsInScope = new List<CollaborationGroup>();
        
        for(CollaborationGroup cg : newMap.values()) {

			if(cg.Name != oldMap.get(cg.Id).Name ||
              	cg.Description != oldMap.get(cg.Id).Description ||
                cg.IsAutoArchiveDisabled != oldMap.get(cg.Id).IsAutoArchiveDisabled ||
                cg.CollaborationType != oldMap.get(cg.Id).CollaborationType || 
              	cg.CanHaveGuests != oldMap.get(cg.Id).CanHaveGuests ||
              	cg.OwnerId != oldMap.get(cg.Id).OwnerId) {
                   
            	groupsInScope.add(cg);
                System.debug('### In Scope: ' + cg.Name);
                    
        	}
        }

        Map<Id, ChatterSecurityUtils.ChatterSecurityUser> userIdWithChatterSecurity = ChatterSecurityUtils.getUsersWithChatterSecurity();
        Map<Id, Id> groupIdToGroupOwnerId = new Map<Id, Id>();
        Map<Id, Set<Id>> mapGroupManagers = new Map<Id, Set<Id>>();
        
        for(CollaborationGroup cg : groupsInScope) {
        	groupIdtoGroupOwnerId.put(cg.Id, cg.OwnerId);    
        }
        
        // Define a map of Chatter Group Id to Manager Members
        List<CollaborationGroupMember> listMembers = 
             [
                Select c.Id, c.CollaborationRole, c.CollaborationGroupId, c.CollaborationGroup.Name, c.MemberId  From CollaborationGroupMember c
                Where c.CollaborationGroupId IN: groupsInScope 
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
        
        for(CollaborationGroup cg : groupsInScope) {
            // First check if this Group is in scope for Security Check
            Id ownerId = groupIdtoGroupOwnerId.get(cg.Id);
            ChatterSecurityUtils.ChatterSecurityUser csu = userIdWithChatterSecurity.get(ownerId);
            if(ownerId != UserInfo.getUserId() && csu != null && csu.applySecurity) {
                // Security enabled, check if the current user is a manager of the group
                
                // No one can change Owner except for the Owner of the group or someone with Bypass all security
                if(cg.OwnerId != oldMap.get(cg.Id).OwnerId) {
                	cg.addError(System.Label.ChatterGroupOwnerChangeError);
            	}
                
                boolean currentUserNotManager = false;
                if(mapGroupManagers.containskey(cg.Id)) {
                    if(!mapGroupManagers.get(cg.Id).contains(UserInfo.getUserId())) {
                        currentUserNotManager = true;
                    }
                } else {
                    // No managers in this group
                    currentUserNotManager = true;
                }
                
                // Now check what type of FeedItem this is
                if(!currentUserNotManager) {
                    // Check permissions for Manager
                    if(!csu.managerCanUpdateGroup) {
                        // Check if they have rights to edit Description
                        if(csu.managerCanUpdateGroupDescription && (
                        		cg.Name == oldMap.get(cg.Id).Name &&
                                cg.Description != oldMap.get(cg.Id).Description &&
                                cg.IsAutoArchiveDisabled == oldMap.get(cg.Id).IsAutoArchiveDisabled &&
                                cg.CollaborationType == oldMap.get(cg.Id).CollaborationType &&
                                cg.CanHaveGuests == oldMap.get(cg.Id).CanHaveGuests
                        )) {
							continue;
 
                        } else {
                           	cg.addError(System.Label.ChatterGroupUpdateError);   
                        }
                    }
                    
                } else {
                    if(!csu.managerCanUpdateGroup) {
                        // Only Managers can do anything
						cg.addError(System.Label.ChatterGroupUpdateError);
                    }
                }
            }               
        }
    }
}