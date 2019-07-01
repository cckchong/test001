public with sharing class UserTriggerHandler {
    
    //Add user to the chatter group
    @future
    //public static void manageACGChatterGroup(Set<User> users, Set<Id> userIds, Set<String> setLandingPages) {
    public static void manageACGChatterGroup(Set<Id> userIds, Set<String> setLandingPages) {
        List<User> users = [Select Id, Administrative_Category__c, Administrative_Target__c, Default_Landing_Page__c From User Where Id IN: userIds];
        Map<String, Set<Id>> mapExistingMembers = new Map<String, Set<Id>>();
        Set<CollaborationGroupMember> newMembers = new Set<CollaborationGroupMember>();     
        //Set<String> concats = new Set<String>();
        //Get related chatter group Ids of related landing pages
        Map<String, Id> mapLandingPagesChatterGroupId = ACGUtil.getAssociatedChatterGroup(setLandingPages, 'General', true, false, false);      
        system.debug('### mapLandingPagesChatterGroupId size ' + mapLandingPagesChatterGroupId.size());
        
        //Check memberships in related chatter groups
        List<CollaborationGroupMember> existingMembers = 
            [
                SELECT Id, CollaborationGroupId, MemberId, CollaborationRole, CollaborationGroup.Name
                FROM CollaborationGroupMember 
                WHERE CollaborationGroupId IN :mapLandingPagesChatterGroupId.values()
            ];
        system.debug('### existingMembers ' + existingMembers);
        for(CollaborationGroupMember member: existingMembers) {
            //Store Chatter Group Members
            if(mapExistingMembers.containsKey(member.CollaborationGroupId)) {
                mapExistingMembers.get(member.CollaborationGroupId).add(member.MemberId);
            } else {
                Set<Id> tmp = new Set<Id>();
                tmp.add(member.MemberId);
                mapExistingMembers.put(member.CollaborationGroupId,tmp);                
            }   
        }
        system.debug('### mapExistingMembers ' + mapExistingMembers);
        
        for(User usr: users) {
            if(userIds.contains(usr.Id)) {
                if(mapLandingPagesChatterGroupId.containsKey(usr.Default_Landing_Page__c)) {
                    String tmpId = mapLandingPagesChatterGroupId.get(usr.Default_Landing_Page__c);
                    if(mapExistingMembers.containsKey(tmpId)) {
                        if(!mapExistingMembers.get(tmpId).contains(usr.Id)) {
                            CollaborationGroupMember m = new CollaborationGroupMember();
                            m.MemberId = usr.Id;
                            m.CollaborationGroupId = tmpId;
                            newMembers.add(m);                      
                        }
                    }
                }
            }               
        }
        system.debug('### newMembers ' + newMembers);
        if(!newMembers.isEmpty()) {
            List<CollaborationGroupMember> tmpListInsert = new List<CollaborationGroupMember>(newMembers);
            insert tmpListInsert;
        }
    }
        
    //Add user to the public group so that they can modify the contents of the corresponding sites
    @future
    public static void manageACGPublicGroup(Set<Id> userIds) {
        Set<String> userAdminRegionPublicGroups = new Set<String>();
        Set<String> userAdminRegionBlogPublicGroups = new Set<String>();
        Set<String> tmpConCat = new Set<String>();
        Set<String> tmpTarget = new Set<String>();
        
        List<User> users = [Select Id, Administrative_Category__c, Administrative_Target__c From User Where Id IN: userIds];
        for (User usr: users){
            if(usr.Administrative_Category__c != '' && usr.Administrative_Category__c != null){
                tmpConCat.addAll(usr.Administrative_Category__c.split(';'));
            }
            if(usr.Administrative_Target__c != '' && usr.Administrative_Target__c != null){
                tmpTarget.addAll(usr.Administrative_Target__c.split(';'));
            }
        }
        Set<String> setACG = new Set<String>();
        List<ACG_Hierarchy__c> acgs = 
            [
                Select Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Location__c, Level__c, isPageListSetting__c, isDepartmentSetting__c
                From ACG_Hierarchy__c
                Where isDepartmentSetting__c = true
                AND Content_Category__c IN :tmpConCat
                AND (Site__c IN :tmpTarget OR (Division__c IN :tmpTarget AND Site__c = null))
            ];
        for(ACG_Hierarchy__c acg :acgs) {
            if(!(acg.Content_Category__c.contains('Blog') && acg.Content_Category__c.contains('Office'))) {
                if(acg.Site__c == null) {
                    //Division Level
                    setACG.add(acg.Content_Category__c + '-' + acg.Division__c);
                } else {
                    //Site Level
                    setACG.add(acg.Content_Category__c + '-' + acg.Site__c);
                }
            }
        }
        //Get all the Groups for the corresponding regions and blogs
        for (User usr: users){
            if(usr.Administrative_Category__c != '' && usr.Administrative_Category__c != null) {
                for(String strConCat: usr.Administrative_Category__c.split(';')) {
                    if(strConCat.contains('Blog') || strConCat.contains('Office')) {
                        userAdminRegionBlogPublicGroups.add(Label.ACGPublicGroupPrefix + strConCat + Label.ACGContentAdminPublicGroupSuffix);
                    } else if(usr.Administrative_Target__c != '' && usr.Administrative_Target__c != null){
                        for(String strTarget: usr.Administrative_Target__c.split(';')) {
                            if(setACG.contains(strConCat + '-' + strTarget)) {
                                userAdminRegionPublicGroups.add(Label.ACGPublicGroupPrefix + strConCat + '-' + strTarget + Label.ACGContentAdminPublicGroupSuffix);
                            }
                        }
                    }
                }
            }
        }
        //system.debug('@@@ userAdminRegionPublicGroups ' + userAdminRegionPublicGroups);
        //system.debug('@@@ userAdminRegionBlogPublicGroups ' + userAdminRegionBlogPublicGroups);
        
        //Check if the group exist
        List<Group> existingGroups = 
            [
                SELECT Id, Name, DeveloperName 
                FROM Group 
                WHERE Type='Regular' 
                AND (Name In :userAdminRegionPublicGroups OR Name In :userAdminRegionBlogPublicGroups)
            ];
        Map<String, Group> mapExistingGroup = new Map<String, Group>();
        for(Group grp: existingGroups) {
            mapExistingGroup.put(grp.Name, grp);
        }
        //system.debug('@@@ mapExistingGroup ' + mapExistingGroup.size());
        
        //Create non-existing groups
        List<Group> newGroups = new List<Group>();
        Set<String> allGroups = new Set<String>();
        Boolean resultAddSet1 = allGroups.addAll(userAdminRegionPublicGroups);
        Boolean resultAddSet2 = allGroups.addAll(userAdminRegionBlogPublicGroups);
        
        for(String str: allGroups) {
            if(!mapExistingGroup.containskey(str)) {
                Group grp = new Group();
                grp.Name = str;
                grp.type = 'Regular';
                newGroups.add(grp);
            }
        }   
        //system.debug('@@@ newGroups ' + newGroups);   
        if(!newGroups.isEmpty()) {
            insert(newGroups);
        }       
        
        //Add the newly created group to the map
        for(Group grp: newGroups) {
            mapExistingGroup.put(grp.Name, grp);
        }
        //system.debug('@@@ mapExistingGroup NEW' + mapExistingGroup);  
        
        //Find all memberships
        Map<String, GroupMember> mapExistingGroupMember = new Map<String, GroupMember>();
        Set<Id> grpIds = new Set<Id>();
        for(Group grp: mapExistingGroup.values()) {
            grpIds.add(grp.Id);
        }
        
        for(GroupMember grpMem: 
            [
                Select Id, GroupId, UserOrGroupId 
                From GroupMember
                Where GroupId In :grpIds
                And UserOrGroupId In: userIds
            ]) {
            mapExistingGroupMember.put(grpMem.GroupId + '-' + grpMem.UserOrGroupId, grpMem);
        }
        
        /** 
            Add Members 
        */      
        //Add Members to the Group
        Set<String> correctGroupMembership = new Set<String>();
        List<GroupMember> newGroupMembers = new List<GroupMember>();
        for (User usr: users) {
            if(usr.Administrative_Category__c != '' && usr.Administrative_Category__c != null) {
                for(String strConCat: usr.Administrative_Category__c.split(';')) {                  
                    if(strConCat.contains('Blog') || strConCat.contains('Office')) {
                        String strBlogChatterGroupName = Label.ACGPublicGroupPrefix + strConCat + Label.ACGContentAdminPublicGroupSuffix;
                        if(mapExistingGroup.containsKey(strBlogChatterGroupName)) {
                            //Check if the user is already the member of the group
                            if(!mapExistingGroupMember.containsKey(mapExistingGroup.get(strBlogChatterGroupName).Id + '-' + usr.Id)) {
                                //Not current member
                                GroupMember gmBlog = new GroupMember();
                                gmBlog.GroupId = mapExistingGroup.get(strBlogChatterGroupName).Id;
                                gmBlog.UserOrGroupId = usr.Id;
                                newGroupMembers.add(gmBlog);
                            }
                            //Used for membership removal, if any
                            correctGroupMembership.add(mapExistingGroup.get(strBlogChatterGroupName).Id + '-' + usr.Id);
                        }   
                    } else if(usr.Administrative_Target__c != '' && usr.Administrative_Target__c != null){
                        for(String strTarget: usr.Administrative_Target__c.split(';')) {                            
                            String strChatterGroupName = Label.ACGPublicGroupPrefix + strConCat + '-' + strTarget + Label.ACGContentAdminPublicGroupSuffix;
                            if(mapExistingGroup.containsKey(strChatterGroupName)) {
                                //Check if the user is already the member of the group
                                if(!mapExistingGroupMember.containsKey(mapExistingGroup.get(strChatterGroupName).Id + '-' + usr.Id)) {
                                    //Not current member
                                    GroupMember gm = new GroupMember();
                                    gm.GroupId = mapExistingGroup.get(strChatterGroupName).Id;
                                    gm.UserOrGroupId = usr.Id;
                                    newGroupMembers.add(gm);
                                }
                                //Used for membership removal, if any
                                correctGroupMembership.add(mapExistingGroup.get(strChatterGroupName).Id + '-' + usr.Id);
                            }                           
                        }
                    }
                }
            }
        }
        //system.debug('@@@ newGroupMembers size ' + newGroupMembers.size());       
        if(!newGroupMembers.isEmpty()) {
            insert(newGroupMembers);
        }
        /** 
            Remove Members 
        */      
        //system.debug('@@@ correctGroupMembership size ' + correctGroupMembership.size());
        //Find all memberships in all groups
        Map<String, GroupMember> mapAllGroupMembers = new Map<String, GroupMember>();
        for(GroupMember grpMem: 
            [
                SELECT Id, GroupId, UserOrGroupId 
                FROM GroupMember
                WHERE UserOrGroupId IN: userIds
            ]) {
            mapAllGroupMembers.put(grpMem.GroupId + '-' + grpMem.UserOrGroupId, grpMem);
        }
        
        //Remove obsolete Members from the Public Group
        for(String str :correctGroupMembership) {
            mapAllGroupMembers.remove(str);
        }
        //system.debug('@@@ mapAllGroupMembers size ' + mapAllGroupMembers.size());
        
        List<GroupMember> obsoleteGroupMembers = new List<GroupMember>();
        for(GroupMember gm: mapAllGroupMembers.values()) {
            obsoleteGroupMembers.add(gm);
        }
        //system.debug('@@@ obsoleteGroupMembers size ' + obsoleteGroupMembers.size());
        if(!obsoleteGroupMembers.isEmpty()) {
            delete(obsoleteGroupMembers);
        }       
    }
    
    //Added By TAL (Twinkle Li) @20170817
    //Add user to the APP public group so that they can view/edit Applications
    @future
    public static void manageAppPublicGroup(Set<Id> userIds) {
        Map<String, String> mapPickListValues_AppVisibleTo = getPickListValues_AppVisibleTo();
        List<GroupMember> newGroupMembers = new List<GroupMember>();
        
        //Retrieve APP Groups Id
        Map<String, Group> mapExistingGroup = new Map<String, Group>();
        for(Group grp: [SELECT Id, Name, DeveloperName FROM Group WHERE Name LIKE 'APP_%']) {
            mapExistingGroup.put(grp.Name, grp);
        }
        system.debug('Existing Groups: '+mapExistingGroup);
        
        if(!mapExistingGroup.isEmpty()){
            //Assign user into appropraite groups
            for (User usr: [Select Id, Function_short__c, Department__c, Section_short__c From User Where Id IN: userIds]) {
                if(!String.isEmpty(usr.Function_short__c) && mapPickListValues_AppVisibleTo.containsKey(usr.Function_short__c)){
                    GroupMember gmBlog = new GroupMember();
                    gmBlog.GroupId = mapExistingGroup.get('APP-'+usr.Function_short__c).Id;
                    gmBlog.UserOrGroupId = usr.Id;
                    newGroupMembers.add(gmBlog);            
                }
                else if(!String.isEmpty(usr.Department__c) && mapPickListValues_AppVisibleTo.containsKey(usr.Department__c)){
                    GroupMember gmBlog = new GroupMember();
                    gmBlog.GroupId = mapExistingGroup.get('APP-'+usr.Department__c).Id;
                    gmBlog.UserOrGroupId = usr.Id;
                    newGroupMembers.add(gmBlog);          
                }
                else if(!String.isEmpty(usr.Section_short__c) && mapPickListValues_AppVisibleTo.containsKey(usr.Section_short__c)){
                    GroupMember gmBlog = new GroupMember();
                    gmBlog.GroupId = mapExistingGroup.get('APP-'+usr.Section_short__c).Id;
                    gmBlog.UserOrGroupId = usr.Id;
                    newGroupMembers.add(gmBlog);          
                }
                if(!Test.isRunningTest()){
                if(!newGroupMembers.isEmpty()) {
                    insert(newGroupMembers);
                    }
                }
            }
        }
    }
    
    //Added By TAL (Twinkle Li) @20170818
    //Get picklist values from Application - Visible To
    
    public static Map<String, String> getPickListValues_AppVisibleTo(){
       
        Map<String, String> pickListValuesList = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Application__c.Visible_To__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.put(pickListVal.getValue(), pickListVal.getValue());
        }    
        system.debug('Picklist Value: '+pickListValuesList);
        
        return pickListValuesList;
        
        
        
    }

}