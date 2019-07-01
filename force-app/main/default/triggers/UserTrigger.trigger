trigger UserTrigger on User (after insert, before update, after update) {
    
    if ( Trigger.isInsert && Trigger.isAfter ) {
        ELeaveUserTriggerHandler.handleELeave(Trigger.newMap);
    }
    
    if ( Trigger.isUpdate  && Trigger.isBefore ) {
        ELeaveUserTriggerHandler.handleELeave(Trigger.oldMap, Trigger.newMap);
    }

    if((Trigger.isInsert && Trigger.isAfter) || (Trigger.isUpdate && Trigger.isBefore)) {               
        //Set<User> updateUsersChatter = new Set<User>();
        Set<Id> updateUserIdsChatter = new Set<Id>();        
        Set<Id> updateUserIdsPublicGroup = new Set<Id>();
        Set<String> setLandingPages = new Set<String>();
        
        Set<Id> updateAppUserIdsPublicGroup = new Set<Id>();//Added by TAL (Twinkle Li) @20170817
        
        for(User usr: trigger.new) {
            updateAppUserIdsPublicGroup.add(usr.Id);//Added by TAL (Twinkle Li) @20170817
            
            //Follow Chatter Group of the Landing Page
            if(usr.Default_Landing_Page__c != '' && usr.Default_Landing_Page__c != null) {
                if(Trigger.isInsert) {
                    //updateUsersChatter.add(usr);
                    updateUserIdsChatter.add(usr.Id);
                    setLandingPages.add(usr.Default_Landing_Page__c);
                } else if(Trigger.isUpdate) {
                    if(usr.Default_Landing_Page__c !=  trigger.oldMap.get(usr.Id).Default_Landing_Page__c) {
                        //updateUsersChatter.add(usr);
                        updateUserIdsChatter.add(usr.Id);
                        setLandingPages.add(usr.Default_Landing_Page__c);
                    }
                }
            }           
            //Join Public Group of related Administrative Content Category & Landing Pages
            if((usr.Administrative_Category__c != '' && usr.Administrative_Category__c != null) || (usr.Administrative_Target__c != '' && usr.Administrative_Target__c != null)) {
                if(Trigger.isInsert) {
                    updateUserIdsPublicGroup.add(usr.Id);
                } else if(Trigger.isUpdate) {
                    if((usr.Administrative_Category__c !=  trigger.oldMap.get(usr.Id).Administrative_Category__c) || (usr.Administrative_Target__c !=  trigger.oldMap.get(usr.Id).Administrative_Target__c)) {
                        updateUserIdsPublicGroup.add(usr.Id);
                    }
                }
            }
        }
        //system.debug('### updateUsers ' + updateUsersChatter);
        system.debug('### setLandingPages ' + setLandingPages);
        system.debug('### updateUserIdsPublicGroup ' + updateUserIdsPublicGroup);
        if(!updateUserIdsChatter.isEmpty()) {
            //Manage Chatter Group
            //UserTriggerHandler.manageACGChatterGroup(updateUsersChatter, updateUserIdsChatter, setLandingPages);
            UserTriggerHandler.manageACGChatterGroup(updateUserIdsChatter, setLandingPages);
        }
        if(!updateUserIdsPublicGroup.isEmpty()) {
            //Manage Public Group
            UserTriggerHandler.manageACGPublicGroup(updateUserIdsPublicGroup);
        }
        
        //Added by TAL (Twinkle Li) @20170817
        if(!updateAppUserIdsPublicGroup.isEmpty()){
            //Manage Application Public Group
            UserTriggerHandler.manageAppPublicGroup(updateAppUserIdsPublicGroup);
        }
    }

    if (Trigger.isUpdate && Trigger.isAfter)
    {
        System.debug('### syncing');
        UserSyncEmployeeActiveTriggerHandler.syncStatus(Trigger.oldMap, Trigger.new);
    }
}