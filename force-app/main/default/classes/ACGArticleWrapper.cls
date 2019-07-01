/*****************************************************
Article Wrapper Class

Constructor
1. Construct Article Wrapper includes additional attribute
    a. picture URL 
    b. associated chatter feeds
    c. feedsize
    d. default language
    
******************************************************/

public without sharing class ACGArticleWrapper {
    public Portal_Content__c objpc {get;set;}
    public String imageURL {get;set;}
    public List<FeedItem> chatterFeeds {get;set;}
    public Integer feedsize {get;set;}
    public Integer feedlikes {get;set;}
    
    public boolean showDefault {get;set;}
    public ACGArticleWrapper (Portal_Content__c pc, Map<Id, String> mapId2Image){
        objpc = pc;
        imageURL = '';
        showDefault = true;
    }
    public ACGArticleWrapper (Portal_Content__c pc, integer i,  Map<Id, Integer> mapChatterComments, Map<Id, String> mapId2Image, Map<Id, Integer> chatterLikes){
    	this.init(pc, i, new Map<Id, List<FeedItem>>(), mapId2Image);
        
        if(chatterLikes.get(pc.Id) != null) {
            feedlikes = chatterLikes.get(pc.Id);
        } else if(chatterLikes.get(pc.Tech_Id__c) != null) {
            feedlikes = chatterLikes.get(pc.Tech_Id__c);
        }
        
        if(mapChatterComments.get(pc.Id) != null) {
            feedsize = mapChatterComments.get(pc.Id);
        } else if(mapChatterComments.get(pc.Tech_Id__c) != null) {
            feedsize = mapChatterComments.get(pc.Tech_Id__c);
        }
    }
    
    public ACGArticleWrapper (Portal_Content__c pc, integer i,  Map<Id, List<FeedItem>> mapFeedItems, Map<Id, String> mapId2Image){
		this.init(pc, i, mapFeedItems, mapId2Image);        
    }
    
    public void init(Portal_Content__c pc, integer i,  Map<Id, List<FeedItem>> mapFeedItems, Map<Id, String> mapId2Image){
        objpc = pc;
        imageURL = '';
        //get Picture of each article
        if(mapId2Image.containsKey(objpc.Id)) {
            imageURL = mapId2Image.get(objpc.Id);
        } else if(mapId2Image.containsKey(objpc.Tech_Id__c)) {
            imageURL = mapId2Image.get(objpc.Tech_Id__c);
        }
        //get chatter feeds of each article
        chatterFeeds = mapFeedItems.containsKey(objpc.Id) ? 
        					mapFeedItems.get(objpc.Id): (mapFeedItems.containsKey(objpc.Tech_Id__c) ? 
        													mapFeedItems.get(objpc.Tech_Id__c):null);
        feedsize = chatterFeeds == null? 0:chatterFeeds.size(); 
    }
}