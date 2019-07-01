/**
 * @description update Tech_Supporting_Doc_Counter__c value when the feed item or comment is added, modified or removed
 */  
public without sharing class EleaveFeedTriggerHandler { 
    public static final String FEED_ITEM_TYPE = 'FeedItem';
    public static final String FEED_COMMENT_TYPE = 'FeedComment';
    public static final String FEED_ITEM_CONTENT = 'ContentPost';
    public static final String FEED_COMMENT_CONTENT = 'ContentComment';    
    public static final String UPDATE_ACTION = 'Update';
    public static final String INSERT_ACTION = 'Insert';    
    
    
    /**
     * @description we should only run this trigger if the ParentId of the FeedItem is a Leave Request
     */
    public static boolean runThisHandler(List<FeedItem> recordList) {
        boolean runThisHandler = false;
        
        for(FeedItem fi : recordList) {
            if(fi.ParentId != null) {
                Id theParentId = fi.ParentId;
                
                if(theParentId.getSobjectType() == Leave_Request__c.getSObjectType()) {
                    runThisHandler = true;
                    return runThisHandler;
                }
            }
        }
        
        return runThisHandler;
    }   
    
    /**
	 * @description update Tech_Supporting_Doc_Counter__c value when the feed item or comment is added or modified
     */  
    public static void FeedUpdate (List <Object> feedObjList, Map<Id,Object> oldfeedObjMap, String type, String action){
        List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
        Set <ID> parentIdSet = new Set <ID> ();
        FeedItem feedItem = null;
        FeedComment feedComment = null;
        FeedItem oldFeedItem = null;
        FeedComment oldFeedComment = null;
        Map <ID, Integer> feedCounterMap = new Map <ID, Integer>();
        
        for ( Object reader : feedObjList ){
            // Get the related leave requests and feed comments if it is a feed item. 
            if ( type == FEED_ITEM_TYPE ){
                feedItem = (FeedItem) reader;                
                if (  feedItem.HasContent && feedItem.Type == FEED_ITEM_CONTENT ){
                    parentIdSet.add( feedItem.ParentId );
                }
                if ( action == UPDATE_ACTION ){
                    oldFeedItem = (FeedItem) oldfeedObjMap.get(feedItem.id);
                    
                    //Supporting Doc counter = Supporting Doc counter + 1 if attachemnt in the feed comment is removed
                    if ( oldFeedItem.ContentType != feedItem.ContentType && feedItem.ContentType == null ){                       
                       if ( feedCounterMap.containskey(feedItem.ParentId) ){
                           feedCounterMap.put(feedItem.ParentId, feedCounterMap.get(feedItem.ParentId)+1 ); 
                       }
                       else {
                           feedCounterMap.put(feedItem.ParentId, 1); 
                       }
                   }
                }  
            }
            // Get the related leave requests if it is a feed comment. 
            if ( type == FEED_COMMENT_TYPE ){
                feedComment = (FeedComment) reader;               
                if ( feedComment.CommentType == FEED_COMMENT_CONTENT  ){
                    parentIdSet.add( feedComment.ParentId );
                }
                
                if ( action == UPDATE_ACTION ){
                    //Supporting Doc counter = Supporting Doc counter + 1 if attachemnt in the feed comment is removed
                    oldFeedComment = (FeedComment) oldfeedObjMap.get(feedComment.id);                    
                    if ( feedComment.RelatedRecordId != oldfeedComment.RelatedRecordId && feedComment.RelatedRecordId == null ){                       
                       if ( feedCounterMap.containskey(feedComment.ParentId) ){
                           feedCounterMap.put(feedComment.ParentId, feedCounterMap.get(feedComment.ParentId)+1 ); 
                       }
                       else {
                           feedCounterMap.put(feedComment.ParentId, 1); 
                       }
                    }
                    
                }                
            }
        }
        
        
        for ( Leave_Request__c reader : [Select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id in :parentIdSet ] ){
            if ( reader.Tech_Supporting_Doc_Counter__c == null ){
                reader.Tech_Supporting_Doc_Counter__c = 0;
            }
            if ( action == INSERT_ACTION ){
                //if the feed item/comment is attached by a new attachment, the supporting counter + 1
                reader.Tech_Supporting_Doc_Counter__c += 1;
            }
            if ( action == UPDATE_ACTION ){
                //if the attachemt isremoved, the supporting counter - 1
                if ( feedCounterMap.containskey(reader.id) ){
                    reader.Tech_Supporting_Doc_Counter__c -= feedCounterMap.get(reader.id);
                }
                
            }
            
            leaveRequestList.add(reader);
        }
        
        if ( !leaveRequestList.isEmpty() ){
            update leaveRequestList;
        }
    }
    
    /*
     *   @description when the feed item/comment is removed, the supporting doc counter will be updated
     */
    public static void FeedDelete (List <Object> feedObjList, String type){
    
        FeedItem feedItem = null;
        FeedComment feedComment = null;
        Set <ID> parentIdSet = new Set <ID> ();
        Set <ID> feedItemIdSet = new Set <ID> ();
        Set <ID> feedCommentIdSet = new Set <ID> ();
        Map <ID, Integer> feedCommentCounter = new Map <ID, Integer> ();
        List <Leave_Request__c> leaveRequestList = new List <Leave_Request__c> ();
        
        for ( Object reader : feedObjList ) {
            if ( type == FEED_ITEM_TYPE ){
                feedItem = (FeedItem) reader; 
                feedItemIdSet.add(feedItem.id);
            }
        }
        
        //get the feed comment list
        for ( FeedComment reader : [ 
            select id, RelatedRecordId 
            from FeedComment 
            where CommentType = :FEED_COMMENT_CONTENT  and feedItemId in :feedItemIdSet  
        ]){
            feedCommentIdSet.add(reader.id);  
        }
        
        //Get # of feed comment
        for ( Aggregateresult aggregateResultReader : [ 
            select ParentId, count(id) counter
            from FeedComment 
            where id in :feedCommentIdSet group by ParentId 
            having count(id) > 0
        ]){
            feedCommentCounter.put( (ID)aggregateResultReader.get('ParentId') , (Integer)aggregateResultReader.get('counter') );
        }
        
        
        for ( Object reader : feedObjList ) {
            if ( type == FEED_ITEM_TYPE ){
                feedItem = (FeedItem) reader;   
                if (  feedItem.HasContent && feedItem.Type == FEED_ITEM_CONTENT &&  feedItem.ContentType != null ){
                    parentIdSet.add( feedItem.ParentId );
                }
            }
            if ( type == FEED_COMMENT_TYPE  ){
                feedComment = (FeedComment) reader;
                if ( feedComment.CommentType == FEED_COMMENT_CONTENT  ){     
                    parentIdSet.add( feedComment.ParentId );
                }
            }            
        }
        
        //supporting doc counter -= # of feed commend + one feed item
        for ( Leave_Request__c reader : [Select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id in :parentIdSet ] ){
            
            if ( reader.Tech_Supporting_Doc_Counter__c == null ){
                reader.Tech_Supporting_Doc_Counter__c = 1;
            }
            reader.Tech_Supporting_Doc_Counter__c -= 1;
            if ( feedCommentCounter.containskey(reader.id) ){
                 reader.Tech_Supporting_Doc_Counter__c -= feedCommentCounter.get(reader.id);
            }            
            leaveRequestList.add(reader);
        }
        
        if ( !leaveRequestList.isEmpty() ){
            update leaveRequestList;
        }
    }
}