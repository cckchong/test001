/*****************************************************
Controller for Article Detail

1. Check if the user is allowed to edit the article
2. Get a list of article Ids for Button "Next" and "Previous"
3. Get the thumbnail URL of the article
4. Get the desired translated version for user

******************************************************/
public without sharing class ACGArticleDetailCtrl {
    
    public String articleID {get; set;}    
    public String panelTitle {get;set;}
    public Integer index {get;set;}    
    public String userPreferLanguage {get;set;}
    public Boolean bPreview {get;set;}      
    public String strPreviousId {get;set;}    
    public String strNextId {get;set;}    
    public Boolean bNext {get;set;}    
    public Boolean bPrevious {get;set;}    
    public Boolean bReadArticle {get;set;}    
    public Boolean bEditArticle {get;set;}
    public Boolean bFollowing {get;set;}    
    public Id recordID {get;set;}
    User usr = new User();
    public String pageContentCategory {get;set;} 
    public String pageDistLevel {get;set;} 
    public String pageDistTarget {get;set;} 
    public Portal_Content__c article {get;set;}
    
    // For Chatter Post Integration
    public boolean hasLiked {get;set;} { hasLiked = false; }
    public Integer numLikes {get;set;} { numLikes = 0; }
    
    public ACGArticleDetailCtrl(){   	
    	//init
    	usr = SystemUtil.getCurrentUserInfo();
        bNext = true;
        bPrevious = true;
        articleID = ApexPages.currentPage().getParameters().get('Id') == null ? '' : ApexPages.currentPage().getParameters().get('Id');     
        bPreview = ApexPages.currentPage().getParameters().get('preview') == null ? false : Boolean.valueof(ApexPages.currentPage().getParameters().get('preview'));
        
        pageContentCategory = ApexPages.currentPage().getParameters().get('ContentCategory') == null ? '' : ApexPages.currentPage().getParameters().get('ContentCategory');
        pageDistLevel = ApexPages.currentPage().getParameters().get('DistLevel') == null ? '' : ApexPages.currentPage().getParameters().get('DistLevel');
        pageDistTarget = ApexPages.currentPage().getParameters().get('DistTarget') == null ? '' : ApexPages.currentPage().getParameters().get('DistTarget');
                
        userPreferLanguage = SystemUtil.getCurrentUserInfo().Portal_Language__c;
        
        //system.debug('@@@ Id ' + articleID);
        this.article = ACGUtil.getfullArticle(articleID);
        //check if user is allowed to edit the article
		getRecordSecurity();
		//check if in preview mode
        if(bPreview == true) {
            bNext = false;
            bPrevious = false;
        } else { //Get the list of article Id to construct a list for Button "Next" and "Previous"
            list<String> listString;
            listString = getAllArticleFeedIds();            
            
            if(listString == null || listString.size()==0) {
                bNext = false;
                bPrevious = false;
            }  else {
                if(index+1 >= listString.size()) {
                    bNext = false;
                    strNextId = listString.get(index);
                } else {
                    strNextId = listString.get(index+1);
                }
                if(index-1 <0) {
                    bPrevious = false;
                    strPreviousId = listString.get(index);
                } else {
                    strPreviousId = listString.get(index-1);
                }                
                String pageURL = ApexPages.currentPage().getUrl();
                strNextId = pageURL.replace(articleID, strNextId);
                strPreviousId = pageURL.replace(articleID, strPreviousId);
            }            
        }
        
        this.initLikes();
    }
    
    //Check if the user is allowed to read, edit or follow the article
    public void getRecordSecurity() {
       	List<UserRecordAccess> ura = 
       		[
       			SELECT RecordId, HasEditAccess, HasReadAccess, HasTransferAccess, MaxAccessLevel
				FROM UserRecordAccess
				WHERE RecordId  = :articleID
				AND UserId = :UserInfo.getUserId()
				limit 1
			];
		bEditArticle = ura.size()>0?ura.get(0).HasEditAccess:false;	
		if(bPreview || article != null) {
			bReadArticle = true;
		}	
		List<EntitySubscription> entSubs = 
			[
				SELECT e.SubscriberId, e.ParentId 
				FROM EntitySubscription e 
				WHERE e.SubscriberId = :usr.Id 
				AND e.ParentId = :articleID 
				limit 1
			];		
		bFollowing = entSubs.size()>0;                         	
    }
       
    public List<String> getAllArticleFeedIds() {
        Integer i=0;  
        index = 0;
        List<String> listIds = new  List<String>();
        List<Portal_Content__c> articleFeeds = new List<Portal_Content__c>();
        if(pageContentCategory != '') {
        	articleFeeds = ACGUtil.getPageArticleFeeds(pageContentCategory, pageDistLevel, pageDistTarget, 0, false);
        }
        for(Portal_Content__c pc: articleFeeds) {
            listIds.add(pc.Id);
            if(pc.Id == articleID) {
                index =i;
            }
            i++;               		     
        }
        return listIds;
    }
    
    public ACGArticleWrapper fullArticle {get {
    	Portal_Content__c article = ACGUtil.getfullArticle(articleID);
        try {
            if (article == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Article Not Found'));                
            } else {
            	Portal_Content__c pc = new Portal_Content__c();
            	pc = article;
            	//Find the list of article Id
            	Set<Id> setArticleIds = new Set<Id>();
                setArticleIds.add(pc.Id);
                //Find out the thumbnail URL of article
                Map<Id, String> mapArticleThumbnails = SystemUtil.getArticleThumbnail(setArticleIds);
                //get User Prefer langauge before constucting Wrapper                
                pc = ACGUtil.getUserPreferLanguageArticle(pc, userPreferLanguage);                    
                //Construct Article Wrapper with thumbnail            
                ACGArticleWrapper customArticle = new ACGArticleWrapper(pc, mapArticleThumbnails);
                //customArticle = ACGUtil.getUserPreferLanguageArticleWrapper(customArticle ,userPreferLanguage);
                return customArticle;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }        
        return null;
    }set;}
    
    //Get Picklist Values in the Languages Field
    public List<String> getLanguages() {
    	return SystemUtil.getPicklistValues('Portal_Content__c', 'Language__c');
    }
    
    //Get Picklist Labels in the Languages Field
    public Map<String, String> getLanguagesLabel() {
    	return SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Language__c');
    }
    
    //Get the API Name of the title field for each language
	public Map<String, String> getTitleLangVar() {
		Map<String, String> mapLang = new Map<String, String>();
		for(String strLang: getLanguages()) {
			mapLang.put(strLang, 'title_' + strLang + '__c');
		}
    	return mapLang;
	}
	
	//Get the API Name of the contents field for each language
	public Map<String, String> getContentsLangVar() {
		Map<String, String> mapLang = new Map<String, String>();
		for(String strLang: getLanguages()) {
			mapLang.put(strLang, 'contents_' + strLang + '__c');
		}
    	return mapLang;
	}
	
	//Get the API Name of the mark as revised field for each language
	public Map<String, String> getRevisedLangVar() {
		Map<String, String> mapLang = new Map<String, String>();
		for(String strLang: getLanguages()) {
			mapLang.put(strLang, 'revised_' + strLang + '__c');
		}
    	return mapLang;
	}
    
    @RemoteAction
    public static boolean likeChatterPost(String feedItemId) {
    	ConnectApi.ChatterLike chatterLike = ConnectApi.ChatterFeeds.likeFeedElement(null, feedItemId);
        return true;
    }
    
    @RemoteAction
    public static ACGFeedItemUtil.ArticleLikeInfo getNumLikes(String feedItemId) {
    	ACGFeedItemUtil.ArticleLikeInfo ali = new ACGFeedItemUtil.ArticleLikeInfo();
        if(feedItemId != null) {
			List<FeedItem> numLikes = [SELECT LikeCount, (SELECT FeedItemId FROM FeedLikes WHERE InsertedById = :UserInfo.getUserId()) FROM FeedItem WHERE Id = :feedItemId];       
            if(numLikes != null && !numLikes.isEmpty()) {
                ali.likes = numLikes[0].LikeCount;
                
                if(numLikes[0].FeedLikes != null && !numLikes[0].FeedLikes.isEmpty()) {
                    ali.userHasLiked = true;
                }
            }
            
            
        }
        return ali;
    }
    
    public void initLikes() {
        if(this.article.Tech_Feed_Item_Id__c != null) {
			List<FeedItem> numLikes = [SELECT LikeCount FROM FeedItem WHERE Id = :this.article.Tech_Feed_Item_Id__c];       
            if(numLikes != null && !numLikes.isEmpty()) {
                this.numLikes = numLikes[0].LikeCount;
            }
        }

    }
}