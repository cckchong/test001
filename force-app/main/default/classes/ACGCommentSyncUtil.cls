/**
 * @description class to synchronize the syncing of the ACG post's comments with
 * 				that of the Chatter post that gets posted to the Chatter Group
 * 
 */
public class ACGCommentSyncUtil {

    private static boolean executedSyncAcgArticleToPost = false;
    private static boolean executedSyncPostToAcgArticle = false;
    
    /**
     * @description this is where the source is Tech_Article_Feed_Item_Id__c (ACG Announcement to Chatter Posts)
     */
    public static void syncAcgArticleToPost(List<FeedComment> feedCommentList) {
        if(executedSyncAcgArticleToPost || executedSyncPostToAcgArticle) {
            return;
        }
        
        List<String> feedItemIds = new List<String>();
        List<FeedComment> feedCommentsToUpsert = new List<FeedComment>();
        
        // Get the relevant FeedItem IDs
        for(FeedComment fc : feedCommentList) {
            feedItemIds.add(fc.FeedItemId);
        }
        
        // Get the ACG Posts this might be associated with

        Map<String, String> feedItemToAcgArticleId = new Map<String, String>();
        Map<String, List<String>> acgContentIdToFeedItemList = new Map<String, List<String>>();
        List<String> acgContentIdList = new List<String>();

		// Construct mapping of Feed Item ID to ACG Content Id        
        for(ACG_Content_Post__c acp : [
            SELECT Id, Acg_Content__c, Post_Id__c FROM ACG_Content_Post__c WHERE Post_Id__c IN: feedItemIds
        ]) {
            feedItemToAcgArticleId.put(acp.Post_Id__c, acp.Acg_Content__c); // This only gets the ones being edited
            acgContentIdList.add(acp.Acg_Content__c);
        }
        
       // Construct mapping of ACG Content Id to List of all relevant Feed Item Ids
       for(ACG_Content_Post__c acp : [
            SELECT Id, Acg_Content__c, Post_Id__c FROM ACG_Content_Post__c WHERE Acg_Content__c IN: acgContentIdList
           	AND Post_Id__c NOT IN: feedItemToAcgArticleId.keySet()
        ]) {
            if(acgContentIdToFeedItemList.get(acp.Acg_Content__c) != null) {
                List<String> feedIds = acgContentIdToFeedItemList.get(acp.Acg_Content__c);
                feedIds.add(acp.Post_Id__c);
             	acgContentIdToFeedItemList.put(acp.Acg_Content__c, feedIds);   
            } else {
                List<String> feedIds = new List<String>();
                feedIds.add(acp.Post_Id__c);
             	acgContentIdToFeedItemList.put(acp.Acg_Content__c, feedIds);   
            }
        }
        
        if(feedItemToAcgArticleId != null && !feedItemToAcgArticleId.isEmpty()) {
            
            for(FeedComment fc : feedCommentList) {
                if(feedItemToAcgArticleId.get(fc.FeedItemId) != null && 
                  	feedItemToAcgArticleId.get(fc.FeedItemId) != ''
                ) {
					
                    String acgContentId = feedItemToAcgArticleId.get(fc.FeedItemId);
                    if(acgContentIdToFeedItemList.get(acgContentId) != null) {
                        
                        for(String feedItemId : acgContentIdToFeedItemList.get(acgContentId)) {
                            FeedComment newFc = fc.clone(false, true);
                            newFc.FeedItemId = feedItemId;
                            feedCommentsToUpsert.add(newFc);
                            
                            System.debug('### Comment Cloned: ' + newFc);
                        }
                        
                    }    
                }
                
                System.debug('### Comment Not Cloned: ' + fc);
            }
            
        }
        
        if(!feedCommentsToUpsert.isEmpty()) {
            executedSyncAcgArticleToPost = true;
            upsert feedCommentsToUpsert;
        }
    }
    
    /**
     * @description this is where the source is Tech_Article_Feed_Item_Id__c (ACG Announcement to Chatter Posts)
     * @deprecated
     */
    public static void syncAcgArticleToPostOld(List<FeedComment> feedCommentList) {
    /*    if(executedSyncAcgArticleToPost || executedSyncPostToAcgArticle) {
            return;
        }
        
        List<String> feedItemIds = new List<String>();
        List<FeedComment> feedCommentsToUpsert = new List<FeedComment>();
        
        // Get the relevant FeedItem IDs
        for(FeedComment fc : feedCommentList) {
            feedItemIds.add(fc.FeedItemId);
        }
        
        // Get the ACG Posts this might be associated with
		Map<String, Portal_Content__c> feedItemToAcgArticle = new Map<String, Portal_Content__c>();
        
        for(Portal_Content__c pc : [
            SELECT Tech_Article_Feed_Item_Id__c, Id, Tech_Feed_Item_Id__c
            FROM Portal_Content__c
            WHERE Tech_Article_Feed_Item_Id__c IN: feedItemIds
        ]) {
            feedItemToAcgArticle.put(pc.Tech_Article_Feed_Item_Id__c, pc);
        }
        
        System.debug('### feedItemToAcgArticle: ' + feedItemToAcgArticle);
        
        if(feedItemToAcgArticle != null && !feedItemToAcgArticle.isEmpty()) {
            for(FeedComment fc : feedCommentList) {
                if(feedItemToAcgArticle.get(fc.FeedItemId) != null && 
                   	feedItemToAcgArticle.get(fc.FeedItemId).Tech_Feed_Item_Id__c != null &&
                  	feedItemToAcgArticle.get(fc.FeedItemId).Tech_Feed_Item_Id__c != '') {

                    FeedComment newFc = fc.clone(false, true);
                    newFc.FeedItemId = feedItemToAcgArticle.get(fc.FeedItemId).Tech_Feed_Item_Id__c;
                    feedCommentsToUpsert.add(newFc);

                    System.debug('### Comment Cloned: ' + newFc);
                }
                
                System.debug('### Comment Not Cloned: ' + fc);
            }
        }
        
        if(!feedCommentsToUpsert.isEmpty()) {
            executedSyncAcgArticleToPost = true;
            upsert feedCommentsToUpsert;
        }*/
    }
        
    /**
     * @description this is where the source is Tech_Feed_Item_Id__c (Chatter Posts to ACG Announcement)
     * @deprecated
     */
    public static void syncPostToAcgArticleOld(List<FeedComment> feedCommentList) {
        /*if(executedSyncPostToAcgArticle || executedSyncAcgArticleToPost) {
            return;
        }
        
        List<String> feedItemIds = new List<String>();
        List<FeedComment> feedCommentsToUpsert = new List<FeedComment>();
        
        // Get the relevant FeedItem IDs
        for(FeedComment fc : feedCommentList) {
            feedItemIds.add(fc.FeedItemId);
        }
        
        // Get the ACG Posts this might be associated with
		Map<String, Portal_Content__c> feedItemToAcgArticle = new Map<String, Portal_Content__c>();
        
        for(Portal_Content__c pc : [
            SELECT Tech_Article_Feed_Item_Id__c, Id, Tech_Feed_Item_Id__c
            FROM Portal_Content__c
            WHERE Tech_Feed_Item_Id__c IN: feedItemIds
        ]) {
            feedItemToAcgArticle.put(pc.Tech_Feed_Item_Id__c, pc);
        }
        
        System.debug('### feedItemToAcgArticle: ' + feedItemToAcgArticle);
        
        if(feedItemToAcgArticle != null && !feedItemToAcgArticle.isEmpty()) {
            for(FeedComment fc : feedCommentList) {
                if(feedItemToAcgArticle.get(fc.FeedItemId) != null && 
                   	feedItemToAcgArticle.get(fc.FeedItemId).Tech_Article_Feed_Item_Id__c != null &&
                  	feedItemToAcgArticle.get(fc.FeedItemId).Tech_Article_Feed_Item_Id__c != '') {

                    FeedComment newFc = fc.clone(false, true);
                    newFc.FeedItemId = feedItemToAcgArticle.get(fc.FeedItemId).Tech_Article_Feed_Item_Id__c;
                    feedCommentsToUpsert.add(newFc);

                    System.debug('### Comment Cloned: ' + newFc);
                }
                
                System.debug('### Comment Not Cloned: ' + fc);
            }
        }
        
        if(!feedCommentsToUpsert.isEmpty()) {
            executedSyncPostToAcgArticle = true;
            upsert feedCommentsToUpsert;
        }*/
    }
}