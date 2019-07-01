trigger FeedCommentTrigger on FeedComment (before insert, after insert, before update, after update, before delete) {
	if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isDelete)) {
        if(Trigger.isUpdate) {
            FeedCommentTriggerHandler.restrictCommentEditAccessToOwners(Trigger.new);
                       
        } else if(Trigger.isDelete) {
            FeedCommentTriggerHandler.restrictCommentEditAccessToOwners(Trigger.old);
        }
    }
    
    if(Trigger.isBefore && Trigger.isInsert) {
        //Label.ServiceAccountUserId 
        List<FeedComment> feedComments = new List<FeedComment>();
        for(FeedComment fc: trigger.new) {
            if(fc.CreatedById != Label.ServiceAccountUserId) {
                feedComments.add(fc);
            }
        }
        if(!feedComments.isEmpty()) {
            //Validate if the user is allowed to post on the ACG Chatter Group
            FeedCommentTriggerHandler.validatePostingRightCustomPermissions(feedComments); //New!
        }            
    }    
    if (Trigger.isAfter && Trigger.isInsert) {
        FeedCommentTriggerHandler.updateServiceNowTicket(Trigger.newMap);
        
        FeedCommentTriggerHandler.syncAcgComments(Trigger.new);
    }
        
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        if ( Trigger.isInsert ){
            EleaveFeedTriggerHandler.FeedUpdate(trigger.new, trigger.oldmap, 'FeedComment', 'Insert');
        }
         if ( Trigger.isUpdate){
            EleaveFeedTriggerHandler.FeedUpdate(trigger.new, trigger.oldmap, 'FeedComment', 'Update');
        }
        
    }
    
    if (Trigger.isbefore  && Trigger.isDelete) {
        EleaveFeedTriggerHandler.FeedDelete(trigger.old, 'FeedComment');
    }
    
    
}