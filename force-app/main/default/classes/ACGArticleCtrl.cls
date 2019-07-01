/*****************************************************
Controller for Articles

1. Get a list of articles to be shown to the user
2. Wrap up with ACGArticleWrapper class to show on visualforce
a. get the thumbnail of each article
b. get the number of comments of each article
3. Get the URL of article list page that the user navigate to
4. Get the URL of full article page that the user navigate to 

******************************************************/
public without sharing class ACGArticleCtrl {
    public String panelTitle {get;set;}    
    public String articleDetailPage {get;set;}    
    public String articleListPage {get;set;}    
    public Set<Id> setArticleIds {get;set;}    
    public Id recordID {get;set;} 
    public Integer iNoOfArticle {get;set;}
    User usr = new User();    
    String userPreferLanguage = '';     
    public Portal_Content__c basePage {get;set;}    
    public String pageContentCategory {get;set;} 
    public String pageDistLevel {get;set;} 
    public String pageDistTarget {get;set;}    
    public Boolean bSalesforceOne {get;set;}
    
    public ACGArticleCtrl (){
        usr = SystemUtil.getCurrentUserInfo();
        userPreferLanguage = usr.Portal_Language__c;    
	    bSalesforceOne = SystemUtil.isMobileDevice();
    }   
    
    public String articleDetailPageURL {get {        
        Portal_Content__c template = ACGUtil.getACGSettingByUniquePageName(articleDetailPage);
        String url = '';        
        if (template != null){            
            url = 'apex/'+template.Template_ID__r.Template_Name__c+'?uniquePageName='+template.Unique_Page_Name__c;
        }        
        return url;
    }set;}    
    
    public String articleListPageURL {get {    	
    	Portal_Content__c template = ACGUtil.getACGSettingByUniquePageName(articleListPage);
        String url = '';
        if (template != null){            
            url = 'apex/'+template.Template_ID__r.Template_Name__c+'?uniquePageName='+template.Unique_Page_Name__c;
        }        
        return url;
    }set;}    
        
    public List<Portal_Content__c> getLocalPageArticleFeeds(){
        Integer numberArticles = 5; //Default 5
        try {
            numberArticles = Integer.valueOf(Label.Tech_Num_Articles_On_Feed);
        } catch (Exception e) { /*die silently*/ }        
        List<Portal_Content__c> articleFeed = new List<Portal_Content__c>();
        List<Portal_Content__c> totalArticleFeeds = new List<Portal_Content__c>();
        this.basePage = ACGUtil.getACGSettingById(recordID, 'Settings');
        if(basePage != null) {
	        pageContentCategory = basePage.Content_Category__c;
	        pageDistLevel = basePage.Distribution_Level__c;
	        pageDistTarget = basePage.Distribution_Target__c;
	        articleFeed = ACGUtil.getPageArticleFeeds(basePage.Content_Category__c, basePage.Distribution_Level__c, basePage.Distribution_Target__c, numberArticles, true);
        	//Get total number of article feeds
        	totalArticleFeeds = ACGUtil.getPageArticleFeeds(basePage.Content_Category__c, basePage.Distribution_Level__c, basePage.Distribution_Target__c, 10000, true);
        	iNoOfArticle = totalArticleFeeds.size();
        }
        return articleFeed;
    }
    
    public List<ACGArticleWrapper> getArticleFeed() {
        if(setArticleIds == null) {
            setArticleIds = new Set<Id>();
        }
        List<Portal_Content__c> articleFeed = new List<Portal_Content__c>();
        articleFeed = getLocalPageArticleFeeds();
        
        for(Portal_Content__c pc :articleFeed) {
            //system.debug('### articleFeed :' + pc.Title__c + ' - ' + pc.Title_en__c + ' - ' + pc.Sub_Category__c + ' - ' + pc.Name + ' - ' + pc.Share_to_Group__c);
            pc = ACGUtil.getUserPreferLanguageArticle(pc, userPreferLanguage);
            setArticleIds.add(pc.Id);
        }
        List<ACGArticleWrapper> customArticleFeeds = new List<ACGArticleWrapper>();
        Integer index=0;                
        //Get Chatter Feeds of each article
        //Map<Id, List<FeedItem>> mapChatterFeeds = SystemUtil.getChatterFeeds(setArticleIds);
        Map<Id, Integer> mapChatterComments = SystemUtil.getCommentCount(articleFeed);
        //Get thumbnail of each article
        Map<Id, String> mapArticleThumbnails = SystemUtil.getArticleThumbnail(setArticleIds);
        //Get Likes
        Map<Id, Integer> mapChatterLikes = ACGArticleCtrl.getChatterLikes(articleFeed);
        //get Article         
        for(Portal_Content__c pc :articleFeed) {
            customArticleFeeds.add(new ACGArticleWrapper(pc, index, mapChatterComments, mapArticleThumbnails, mapChatterLikes)); 
        }
        
        return customArticleFeeds;
    }

    /**
     * @description given a list of ACG Announcements, get the Like Count
     */
    public static Map<Id, Integer> getChatterLikes(List<Portal_Content__c> pcList) {
        List<Id> feedItemIds = new List<Id>();
        Map<String, Id> feedItemIdToAcgId = new Map<String, Id>();
        
        Map<Id, Integer> acgIdToLikes = new Map<Id, Integer>();
        
        for(Portal_Content__c pc : pcList) {
            if(pc.Tech_Feed_Item_Id__c != '') {
                feedItemIds.add(pc.Tech_Feed_Item_Id__c);
                feedItemIdToAcgId.put(pc.Tech_Feed_Item_Id__c, pc.Id);
            }
        }
        
        for(FeedItem fi : [SELECT Id, ParentId, LikeCount FROM FeedItem WHERE Id IN: feedItemIds]) {
            if(feedItemIdToAcgId.get(fi.Id) != null) {
                acgIdToLikes.put(feedItemIdToAcgId.get(fi.Id), fi.LikeCount);
            }
        }
        
        return acgIdToLikes;
    }
    
    //Get Picklist Labels in the Languages Field
    public Map<String, String> getLanguagesLabel() {
        return SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Language__c');
    }
    
    //Get Picklist Labels in the Languages Field
    public Map<String, String> getContentCategoryLabel() {
        return SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Content_Category__c');
    }
}