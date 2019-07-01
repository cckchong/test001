/*****************************************************
Controller for ArticleListPage

1. Get a list of articles to be shown to the user using StandardSetController
2. Wrap up with ACGArticleWrapper class to show on visualforce
	a. get the thumbnail of each article
	b. get the number of comments of each article
3. Get the URL of article list page that the user navigate to
4. Get the URL of full article page that the user navigate to 

******************************************************/
public without sharing class ACGArticleListCtrl {
    public String panelTitle {get;set;}    
    public String articleDetailPage {get;set;}    
    public String articleListPage {get;set;}    
    public Set<Id> setArticleIds {get;set;}
    String userPreferLanguage = '';   
    public String pageContentCategory {get;set;} 
    public String pageDistLevel {get;set;} 
    public String pageDistTarget {get;set;}   
    public String articleDetailPageURL {get {        
        List<Portal_Content__c> template = 
        	[
        		SELECT Id, Template_ID__c, Template_ID__r.Template_Name__c, Unique_Page_Name__c 
				FROM Portal_Content__c 
				WHERE RecordType.DeveloperName = 'Settings' 
				AND Unique_Page_Name__c = :articleDetailPage 
				limit 1
			];
        String url = '';
        if (!template.isEmpty()){        	
            url = 'apex/'+template.get(0).Template_ID__r.Template_Name__c+'?uniquePageName='+template.get(0).Unique_Page_Name__c;
        }
		return url;
    }set;}
    List<Portal_Content__c> listAllArticleFeeds = new List<Portal_Content__c>();    
    User usr = new User();
    public Boolean bSalesforceOne {get;set;}
    
    public ACGArticleListCtrl(){
    	usr = SystemUtil.getCurrentUserInfo();
        userPreferLanguage = usr.Portal_Language__c;         
	    bSalesforceOne = SystemUtil.isMobileDevice();
        if(!bSalesforceOne) {
        	bSalesforceOne = ApexPages.currentPage().getParameters().get('isMobileDevice') == null ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get('isMobileDevice'));
        }
        panelTitle = ApexPages.currentPage().getParameters().get('title') == null ? '' : ApexPages.currentPage().getParameters().get('title');
        articleDetailPage = ApexPages.currentPage().getParameters().get('articleDetailPage') == null ? '' : ApexPages.currentPage().getParameters().get('articleDetailPage');
        articleListPage='';
        size = 20;
        pageContentCategory = ApexPages.currentPage().getParameters().get('ContentCategory') == null ? '' : ApexPages.currentPage().getParameters().get('ContentCategory');
        pageDistLevel = ApexPages.currentPage().getParameters().get('DistLevel') == null ? '' : ApexPages.currentPage().getParameters().get('DistLevel');
        pageDistTarget = ApexPages.currentPage().getParameters().get('DistTarget') == null ? '' : ApexPages.currentPage().getParameters().get('DistTarget');
    }
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}            
        
    public List<SelectOption> availablePageSize {get{
        Set<SelectOption> options = new Set<SelectOption>();
        options.add(new SelectOption('5', '5'));
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('20', '20', true));
        options.add(new SelectOption('50', '50'));
        options.add(new SelectOption('100', '100'));        
        return new List<SelectOption>(options);
    }
    set;}
    
    public ApexPages.StandardSetController setCon {get{
        if(setCon == null){      
            String recordTypeDeveloperName = 'Rich_Text';
            String contentCategory = pageContentCategory;
            String level = pageDistLevel;
            String target = pageDistTarget;
            
            //FIXME: Combine this section with that in ACGUtil
            //Find Content Category & Division / Site
	    	Set<String> relatedConCats = new Set<String>();
	    	String relatedDiv = '';
	    	List<ACG_Hierarchy__c> acgs = new List<ACG_Hierarchy__c>();
	    	if(level == 'Site') {
		    	acgs = 
		    		[
		                SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Location__c
		                FROM ACG_Hierarchy__c
		                WHERE Type__c = :level
	                	AND isHierarchySetting__c = true		                
		            ];
				for(ACG_Hierarchy__c acg: acgs) {
		    		relatedConCats.add(acg.Content_Category__c);
		    		relatedDiv = acg.Division__c + ';' + acg.Group__c;
				}
				relatedDiv += ';'+target;
			}
            
            String query = String.format(
				'SELECT {0} FROM Portal_Content__c WHERE RecordType.DeveloperName = :recordTypeDeveloperName AND {1} ORDER BY {2}',
				new List<String>{ String.join(ACGUtil.getArticleFields(), ','),
				String.join(ACGUtil.getArticleFeedConditions(contentCategory, level, target, relatedDiv), ' AND '),  
				ACGUtil.getArticleOrderBy() });   
            system.debug('### query ' + query);
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
        }
        return setCon;
    }set;}    
    
    public List<ACGArticleWrapper> getArticleFeeds() {
        if(setArticleIds == null) {
        	setArticleIds = new Set<Id>();
        }
        List<Portal_Content__c> articleFeed = (List<Portal_Content__c>)setCon.getRecords();        
        List<Portal_Content__c> newArticleFeed = articleFeed.deepClone();		
        List<ACGArticleWrapper> customArticleFeeds = new List<ACGArticleWrapper>();
        Integer index=0;
		for(Portal_Content__c pc :articleFeed) {
        	setArticleIds.add(pc.Id);
        }
        //Map<Id, List<FeedItem>> mapChatterFeeds = SystemUtil.getChatterFeeds(setArticleIds);
        Map<Id, Integer> mapChatterComments = SystemUtil.getCommentCount(articleFeed);
        //Get Likes
        Map<Id, Integer> mapChatterLikes = ACGArticleCtrl.getChatterLikes(articleFeed);
        System.debug('HERE#### ' + mapChatterLikes);
        
        Map<Id, String> mapArticleThumbnails = SystemUtil.getArticleThumbnail(setArticleIds);
        //get Article         
        for(Portal_Content__c pc :newArticleFeed) {
        	//system.debug('### articleFeed new before ' + i +' : techId ' + pc.Tech_Id__c + ' - ' + pc.Id + ' - ' + pc.title_en__c );
        	pc = ACGUtil.getUserPreferLanguageArticle(pc, userPreferLanguage);
        	//system.debug('### articleFeed new after' + i +' : techId ' + pc.Tech_Id__c + ' - ' + pc.Id + ' - ' + pc.title_en__c );
        	customArticleFeeds.add(new ACGArticleWrapper(pc, index, mapChatterComments, mapArticleThumbnails, mapChatterLikes)); 
        	index++;
        }            
        return customArticleFeeds;
    }
    
    public Integer getPageNumber(){ 
        return this.setCon.getPageNumber(); 
    }
 
    public Integer getTotalPages(){ 
        Decimal totalSize = this.setCon.getResultSize();
        Decimal pageSize = this.setCon.getPageSize(); 
        Decimal pages = totalSize/pageSize; 
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    /*
    *   advance to next page
    */
    public void doNext(){ 
        if(this.setCon.getHasNext())
            this.setCon.next(); 
    }
 
    /*
    *   advance to previous page
    */
    public void doPrevious(){ 
        if(this.setCon.getHasPrevious())
            this.setCon.previous(); 
    }
    /*
    *   return whether previous page exists
    */
    public Boolean getHasPrevious(){ 
        return this.setCon.getHasPrevious();
    }
 
    /*
    *   return whether next page exists
    */
    public Boolean getHasNext(){ 
        return this.setCon.getHasNext(); 
    }
    
    public pageReference refresh() {
        setCon = null;
        getArticleFeeds();
        setCon.setPageNumber(size);
        return null;
    }
}