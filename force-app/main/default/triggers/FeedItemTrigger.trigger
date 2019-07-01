trigger FeedItemTrigger on FeedItem (before insert, after insert, after update, before delete, before update) {
    boolean runIfParentIsGroup = false;
    if(Trigger.isDelete) {
        runIfParentIsGroup = FeedItemTriggerHandler.runIfParentIsGroup(Trigger.old);
    } else {
        runIfParentIsGroup = FeedItemTriggerHandler.runIfParentIsGroup(Trigger.new);
    }
    
    // ----- Restrict Chatter Post Editing ----- //
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isDelete)) {
        if(Trigger.isUpdate) {
            FeedItemTriggerHandler.restrictPostEditAccessToOwners(Trigger.new);
                       
        } else if(Trigger.isDelete) {
            FeedItemTriggerHandler.restrictPostEditAccessToOwners(Trigger.old);
        }
    }
    
    // ----- Restrict Chatter Post Creation ----- //
    if(Trigger.isBefore && Trigger.isInsert) {
        if(runIfParentIsGroup) {
            FeedItemTriggerHandler.validatePostingRightCustomPermissions(Trigger.new);
        }
    }    
    
    // ----- Special Chatter Post Conversions ----- //
    if (Trigger.isAfter && Trigger.isInsert) {
        FeedItemTriggerHandler.createServiceNowTicket(Trigger.newMap);
        
        //if(runIfParentIsGroup) { // Always run because the post might happen on the person's Wall as well
        	FeedItemTriggerHandler.handleAcgArticleConversion(Trigger.new);
        //}
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        if(runIfParentIsGroup) {
            FeedItemTriggerHandler.handleAcgArticleConversionUpdate(Trigger.new);
        }
    }
    
    // ----- Special E-Leave Chatter Post Logic ----- //
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        boolean runThisHandler = EleaveFeedTriggerHandler.runThisHandler(trigger.new);
        
        if(runThisHandler) {
            if ( Trigger.isInsert ){
                EleaveFeedTriggerHandler.FeedUpdate(trigger.new, trigger.oldmap, 'FeedItem', 'Insert');
            }
            if ( Trigger.isUpdate){
                EleaveFeedTriggerHandler.FeedUpdate(trigger.new, trigger.oldmap, 'FeedItem', 'Update');
                EleaveChatterTriggerHandler.preventUserFromModifyingLeavePost(trigger.old);
            }
        }
        
    }
    
    if (Trigger.isBefore  && Trigger.isDelete) {
        boolean runThisHandler = EleaveFeedTriggerHandler.runThisHandler(trigger.old);
        
        if(runThisHandler) {
        	EleaveFeedTriggerHandler.FeedDelete(trigger.old, 'FeedItem');
            EleaveChatterTriggerHandler.preventUserFromModifyingLeavePost(trigger.old);
        }
    }
}