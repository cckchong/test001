public class CollaborationGroupMemberTriggerHandler {
    
    /**
     * @description users should only be able to change a Chatter Member based on certain restrictions
     * @author Andrew Ng
     */
    public static void validateOnlyOwnerCanUpdateGroup(Map<Id, CollaborationGroupMember> oldMap, Map<Id, CollaborationGroupMember> newMap, List<CollaborationGroupMember> newList) {
        // Can this person bypass this?
        if(ChatterSecurityUtils.canCurrentUserUpdateGroup()) {
            return;
        }
        List<CollaborationGroupMember> groupMembersInScope = new List<CollaborationGroupMember>();
        List<Id> groupIdList = new List<Id>();
        
        List<CollaborationGroupMember> cgmToIterate;
        if(Trigger.isInsert) {
            cgmToIterate = newList;
        } else if(Trigger.isDelete) {
            cgmToIterate = oldMap.values();
        } else {
            cgmToIterate = newMap.values();
        }
        
        for(CollaborationGroupMember cgm : cgmToIterate) {           
            groupIdList.add(cgm.CollaborationGroupId);
            groupMembersInScope.add(cgm);
        }

        Map<Id, ChatterSecurityUtils.ChatterSecurityUser> userIdWithChatterSecurity = ChatterSecurityUtils.getUsersWithChatterSecurity();
        Map<Id, Id> groupIdToGroupOwnerId = new Map<Id, Id>();
        Map<Id, Set<Id>> mapGroupManagers = new Map<Id, Set<Id>>();
        
        // Get the groups
        // 
        for(CollaborationGroup cg : [SELECT Id, OwnerId FROM CollaborationGroup WHERE Id IN: groupIdList]) {
            groupIdtoGroupOwnerId.put(cg.Id, cg.OwnerId);    
        }
        
        // Define a map of Chatter Group Id to Manager Members
        List<CollaborationGroupMember> listMembers = 
             [
                Select c.Id, c.CollaborationRole, c.CollaborationGroupId, c.CollaborationGroup.Name, c.MemberId  From CollaborationGroupMember c
                Where c.CollaborationGroupId IN: groupIdList 
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
        
        for(CollaborationGroupMember cgm : groupMembersInScope) {
            // First check if this Group is in scope for Security Check
            Id ownerId = groupIdtoGroupOwnerId.get(cgm.CollaborationGroupId);
            
            ChatterSecurityUtils.ChatterSecurityUser csu = userIdWithChatterSecurity.get(ownerId);
            
            if(ownerId != UserInfo.getUserId() && csu != null && csu.applySecurity) {
                // Security enabled, check if the current user is a manager of the group
                
                boolean currentUserNotManager = false;
                if(mapGroupManagers.containskey(cgm.CollaborationGroupId)) {
                    if(!mapGroupManagers.get(cgm.CollaborationGroupId).contains(UserInfo.getUserId())) {
                        currentUserNotManager = true;
                    }
                } else {
                    // No managers in this group
                    currentUserNotManager = true;
                }
                
                // Now check what type of FeedItem this is
                if(!currentUserNotManager) {
                    // Check permissions for Manager
                    
                    // Allow users to follow/un-follow
                    if((Trigger.isUpdate || csu.canFollowUnfollow) && cgm.MemberId == UserInfo.getUserId()) {
                        continue;
                    }
                    
                    if(!csu.managerCanUpdateGroupMembership) {
                        cgm.addError(System.Label.ChatterGroupUpdateError);   
                    }
                    
                } else {
                    // Allow users to follow/un-follow
                    if((Trigger.isUpdate || csu.canFollowUnfollow) && cgm.MemberId == UserInfo.getUserId()) {
                        continue;
                    }
                    
                    cgm.addError(System.Label.ChatterGroupUpdateError);
                }
            }               
        }
    }
}