/**
 * @description Utility methods for Chatter Security
 * @author Andrew Ng
 */ 
public class ChatterSecurityUtils {

    public class ChatterSecurityUser {
        public Id userId {get;set;}
        public boolean applySecurity {get;set;} {applySecurity = false;}
        public boolean canPost {get;set;} {canPost = false;}
        public boolean canComment {get;set;} {canComment = false;}
        public boolean canPostFile {get;set;} {canPostFile = false;}
        public boolean canPostLink {get;set;} {canPostLink = false;}
        public boolean canOtherActions {get;set;} {canOtherActions = false;}
        public boolean canFollowUnfollow {get;set;} {canFollowUnfollow = false;}
        
		public boolean managerCanPost {get;set;} {managerCanPost = false;}
        public boolean managerCanComment {get;set;} {managerCanComment = false;}
        public boolean managerCanPostFile {get;set;} {managerCanPostFile = false;}
        public boolean managerCanPostLink {get;set;} {managerCanPostLink = false;}
        public boolean managerCanOtherActions {get;set;} {managerCanOtherActions = false;}
        
        public boolean managerCanUpdateGroup {get;set;} {managerCanUpdateGroup = false;}
        public boolean managerCanUpdateGroupDescription {get;set;} {managerCanUpdateGroupDescription = false;}
        public boolean managerCanUpdateGroupMembership {get;set;} {managerCanUpdateGroupMembership = false;}
    }
    
    private static Map<Id, ChatterSecurityUser> usersWithChatterSecurity;
    private static boolean canCurrentUserUpdateGroup;
    
    public class ChatterSecurityPermissionSet {
        public Id permissionSetId {get;set;}
        public boolean applySecurity {get;set;} {applySecurity = false;}
        public boolean canPost {get;set;} {canPost = false;}
        public boolean canComment {get;set;} {canComment = false;}
        public boolean canPostFile {get;set;} {canPostFile = false;}
        public boolean canPostLink {get;set;} {canPostLink = false;}
        public boolean canOtherActions {get;set;} {canOtherActions = false;}
        public boolean canFollowUnfollow {get;set;} {canFollowUnfollow = false;}
        
        public boolean managerCanPost {get;set;} {managerCanPost = false;}
        public boolean managerCanComment {get;set;} {managerCanComment = false;}
        public boolean managerCanPostFile {get;set;} {managerCanPostFile = false;}
        public boolean managerCanPostLink {get;set;} {managerCanPostLink = false;}
        public boolean managerCanOtherActions {get;set;} {managerCanOtherActions = false;}
        
        public boolean managerCanUpdateGroup {get;set;} {managerCanUpdateGroup = false;}
        public boolean managerCanUpdateGroupDescription {get;set;} {managerCanUpdateGroupDescription = false;}
        public boolean managerCanUpdateGroupMembership {get;set;} {managerCanUpdateGroupMembership = false;}
    }
    
    public static boolean canCurrentUserUpdateGroup() {
        return canCurrentUserUpdateGroup(null);
    }
    
    public static boolean canCurrentUserUpdateGroup(Id theUserId) {
        
       if(ChatterSecurityUtils.canCurrentUserUpdateGroup != null) {
           return ChatterSecurityUtils.canCurrentUserUpdateGroup;
       }

        boolean result = false;
        Set<Id> permissionSetIdSet = new Set<Id>();
        if(theUserId == null) {
            theUserId = UserInfo.getUserId();
        }
        for(CustomPermission cp :
            [
                SELECT Id, DeveloperName,
                (select Id, ParentId, Parent.Name, Parent.ProfileId from SetupEntityAccessItems)
                FROM CustomPermission
                WHERE DeveloperName = 'Chatter_Group_Update_Bypass_Restrictions'
            ]) {
                
                for(SetupEntityAccess sea : cp.SetupEntityAccessItems) {
                    permissionSetIdSet.add(sea.ParentId);
                }
            }
        
        List<PermissionSetAssignment> psaList = 
            [
                SELECT AssigneeId, Assignee.Name, PermissionSet.Id
                FROM PermissionSetAssignment
                WHERE PermissionSetId
                IN :permissionSetIdSet
                AND AssigneeId =: theUserId
            ];
        
        if(psaList != null && !psaList.isEmpty()) {
            result = true;
        }
        
        ChatterSecurityUtils.canCurrentUserUpdateGroup = result;
        return result;
    }
    
    /**
     * @description get users with Chatter Security applied
     */ 
    public static Map<Id, ChatterSecurityUser> getUsersWithChatterSecurity() {
        //if(ChatterSecurityUtils.usersWithChatterSecurity != null) {
        //    return ChatterSecurityUtils.usersWithChatterSecurity;
        //}
        
        Map<Id, ChatterSecurityUser> userIdToChatterSecurity = new Map<Id, ChatterSecurityUser>();       
        Map<Id, ChatterSecurityPermissionSet> permSetToWrapper = new Map<Id, ChatterSecurityPermissionSet>();
        
        for(CustomPermission cp :
            [
                SELECT Id, DeveloperName,
                (select Id, ParentId, Parent.Name, Parent.ProfileId from SetupEntityAccessItems)
                FROM CustomPermission
                WHERE DeveloperName = 'Chatter_Group_Apply_Security'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_Post'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_Comment'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_File_Post'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_All_Other_Actions'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_Post_Manager'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_Comment_Manager'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_File_Post_Manager'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_All_Other_Actions_Manager'
                OR DeveloperName = 'Chatter_Group_Allow_Managers_Update_All_Group_Attributes'
                OR DeveloperName = 'Chatter_Group_Allow_Managers_Update_Group_Description'
                OR DeveloperName = 'Chatter_Group_Allow_Managers_Update_Group_Membership'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_Link_Post_Manager'
                OR DeveloperName = 'Chatter_Group_Owner_Allow_Link_Post'
                OR DeveloperName = 'Chatter_Group_Allow_Users_Follow_and_Unfollow'
            ]) {
                
            for(SetupEntityAccess sea : cp.SetupEntityAccessItems) {
                // Get the Permission Set out
                ChatterSecurityPermissionSet csps = new ChatterSecurityPermissionSet();
                csps.permissionSetId = sea.ParentId;
                
                if(permSetToWrapper.get(sea.ParentId) != null) {
                    csps = permSetToWrapper.get(sea.ParentId);
                }
                
                if(cp.DeveloperName == 'Chatter_Group_Apply_Security') {
                    csps.applySecurity = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_Post') {
                	csps.canPost = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_Comment') {
                	csps.canComment = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_File_Post') {
                	csps.canPostFile = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_All_Other_Actions') {
                	csps.canOtherActions = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_Post_Manager') {
                	csps.managerCanPost = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_Comment_Manager') {
                	csps.managerCanComment = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_File_Post_Manager') {
                	csps.managerCanPostFile = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_All_Other_Actions_Manager') {
                	csps.managerCanOtherActions = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Allow_Managers_Update_All_Group_Attributes') {
                	csps.managerCanUpdateGroup = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Allow_Managers_Update_Group_Description') {
                	csps.managerCanUpdateGroupDescription = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Allow_Managers_Update_Group_Membership') {
                	csps.managerCanUpdateGroupMembership = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_Link_Post_Manager') {
                	csps.managerCanPostLink = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Owner_Allow_Link_Post') {
                	csps.canPostLink = true;
                } else if(cp.DeveloperName == 'Chatter_Group_Allow_Users_Follow_and_Unfollow') {
                	csps.canFollowUnfollow = true;
                }
                
                permSetToWrapper.put(sea.ParentId, csps);
            }
        }

            
        for(PermissionSetAssignment psa : 
            [
                SELECT AssigneeId, Assignee.Name, PermissionSet.Id
                FROM PermissionSetAssignment
                WHERE PermissionSetId
                IN :permSetToWrapper.keyset()
        ]) {
            
			// Get the User
			ChatterSecurityUser csu = new ChatterSecurityUser();
            csu.userId = psa.AssigneeId;
            if(userIdToChatterSecurity.get(psa.AssigneeId) != null) {
            	csu = userIdToChatterSecurity.get(psa.AssigneeId);  
            }
            
            // Now get this Permission Set's mappings
            if(permSetToWrapper.get(psa.PermissionSetId) != null) {
                ChatterSecurityPermissionSet csps = permSetToWrapper.get(psa.PermissionSetId);
				csu.applySecurity = csps.applySecurity;
                csu.canPost = csps.canPost;
                csu.canComment = csps.canComment;
                csu.canPostFile = csps.canPostFile;
                csu.canPostLink = csps.canPostLink;
                csu.canOtherActions = csps.canOtherActions;
                csu.canFollowUnfollow = csps.canFollowUnfollow;
                
                csu.managerCanPost = csps.managerCanPost;
                csu.managerCanComment = csps.managerCanComment;
                csu.managerCanPostFile = csps.managerCanPostFile;
                csu.managerCanPostLink = csps.managerCanPostLink;
                csu.managerCanOtherActions = csps.managerCanOtherActions;
                
                csu.managerCanUpdateGroup = csps.managerCanUpdateGroup;
                csu.managerCanUpdateGroupDescription = csps.managerCanUpdateGroupDescription;
                csu.managerCanUpdateGroupMembership = csps.managerCanUpdateGroupMembership;
            }
			
            userIdToChatterSecurity.put(psa.AssigneeId, csu);    
        }
        
        ChatterSecurityUtils.usersWithChatterSecurity = userIdToChatterSecurity;
        
        return userIdToChatterSecurity;
    }
    
    /**
     * @description Restrict editing / deleting of posts
     */ 
    public static void restrictPostEditAccessToOwners(List<FeedItem> feedItemList) {
        List<Profile> systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        boolean continueTrigger = false;
        try {
            continueTrigger = Boolean.valueOf(Label.Tech_Restrict_Edit_Chatter_Posts_to_Owners);
        } catch (Exception e) {}
        
        if((systemAdministratorProfile != null && 
           	!systemAdministratorProfile.isEmpty() && 
           	UserInfo.getProfileId() == systemAdministratorProfile[0].Id) || !continueTrigger ) {
            return;
        }
        
        if(Trigger.isUpdate || Trigger.isDelete) {
            for(FeedItem fi : feedItemList) {
                if(UserInfo.getUserId() != fi.CreatedById) {
                    fi.addError(Label.Chatter_You_Cannot_Edit_Others_Posts);
                }
            }
        }
    }
    
    /**
     * @description Restrict editing / deleting of comments
     */ 
    public static void restrictCommentEditAccessToOwners(List<FeedComment> feedCommentList) {
        List<Profile> systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        boolean continueTrigger = false;
        try {
            continueTrigger = Boolean.valueOf(Label.Tech_Restrict_Edit_Chatter_Posts_to_Owners);
        } catch (Exception e) {}
        
        if((systemAdministratorProfile != null && 
           !systemAdministratorProfile.isEmpty() && 
           UserInfo.getProfileId() == systemAdministratorProfile[0].Id) || !continueTrigger ) {
            return;
        }
        
        if(Trigger.isUpdate || Trigger.isDelete) {
            for(FeedComment fi : feedCommentList) {
                if(UserInfo.getUserId() != fi.CreatedById) {
                    fi.addError(Label.Chatter_You_Cannot_Edit_Others_Posts);
                }
            }
        }
    }
}