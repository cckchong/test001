/*****************************************************
Controller for Setting Up a Page

1. Get all the setting records using the Unique Page name
2. Get Site Navigation Information
3. Get the components in the setting records
4. Insert Blank HTML component to those incorrectly set component block to avoid error
******************************************************/
global without sharing class ACGCtrl {
     
    public ApexPages.Component [] portalComponent {get; set;}
    public Boolean bShowHeader {get;set;}    
    public String chatterFeedId {get;set;}
    public String firstArrow {get;set;}    
    public String SecondArrow {get;set;}    
    public String thirdArrow {get;set;}
    public Boolean bChatterMember {get;set;}  
    public Boolean bShowChatterGroup {get;set;}    
    public Boolean bShowChatterFile {get;set;}    
    public Boolean bShowChatterPhoto {get;set;}
    public Integer photoSlidesNum {get;set;}
    public Boolean bShouldRedirect {public get; private set;}    
    public String redirectUrl {public get; private set;}        
    public List<String> slideshowTopic {get;set;}    
    public List<String> topics {get;set;}        
    public Map<String, String> mapName2Topics {get;set;}    
    Set<Id> setItemsId = new Set<Id>();
    Set<Id> setCVsId = new Set<Id>();    
    public Boolean bFollowing {get{    	
		List<CollaborationGroupMember> members = 
			[
				SELECT Id
				FROM CollaborationGroupMember
				WHERE CollaborationGroupId = :chatterFeedId
				AND MemberId = :usr.Id
				limit 1
			];	
		return members.size()>0;
    }set;} 
    public Boolean bEditMode {get {        
        return (bEditMode == null?false:bEditMode);
    }set;}  
    public String strSiteMapId {get{        
        return SystemUtil.getSiteMapId();    
    }set;}  
    
    public Integer newArticleNum {get {        
        Integer iNum=0;
        Integer lastUpdateHours = 10;
        try {
            lastUpdateHours = Integer.valueOf(Label.Tech_New_Article_Hours);
        } catch (Exception e) { /*die silently*/ }
        if(!settings.isEmpty()) {
        	iNum = ACGUtil.getPageArticleFeedsCount(settings.get(0).Content_Category__c, settings.get(0).Distribution_Level__c, settings.get(0).Distribution_Target__c, lastUpdateHours);
        } 
        return iNum;
    }set;}       
	
	public String pageContentCategory {get;set;} 
    public String pageDistLevel {get;set;} 
    public String pageDistTarget {get;set;}
    public String pageDisivion {get;set;} 
    public String pageDisivionURL {get;set;}    
    public String pageSite {get;set;}
    public String pageSiteURL {get;set;}
    User usr = new User();
    List<Portal_Content__c> settings = getSettings();  
    public Boolean bSalesforceOne {get;set;}
    public Boolean bMainPage {get;set;}
    public Boolean bShowFollow {get;set;}
    
    public ACGCtrl(){
	    //Init
	    chatterFeedId ='';	   
	    photoSlidesNum = 5;
	    Integer totalComponents=0;
	    bShouldRedirect = false;
	    slideshowTopic = new List<String>();
	    topics = new List<String>();
	    mapName2Topics = new Map<String, String>();	    
	    usr = SystemUtil.getCurrentUserInfo();
	    bFollowing = false; 
	    bSalesforceOne = SystemUtil.isMobileDevice();
	    bMainPage = true;
	    bShowFollow = true;
		bEditMode = ApexPages.currentPage().getParameters().get('edit') == null ? false :  Boolean.valueOf(ApexPages.currentPage().getParameters().get('edit'));
	    bShowHeader = ApexPages.currentPage().getParameters().get('showHeader') == null ? false :  Boolean.valueOf(ApexPages.currentPage().getParameters().get('showHeader'));
		String uniquePageName = ApexPages.currentPage().getParameters().get('uniquePageName') == null ? '' :  String.valueOf(ApexPages.currentPage().getParameters().get('uniquePageName'));
		
	    if(settings.size()>0) {   
	    	pageContentCategory = settings.get(0).Content_Category__c;
        	pageDistLevel = settings.get(0).Distribution_Level__c;
        	pageDistTarget = settings.get(0).Distribution_Target__c;
	        totalComponents = Integer.ValueOf(settings.get(0).Template_ID__r.Tech_Total_Component__c);
			
			if(usr.Default_Landing_Page__c == pageDistTarget && pageContentCategory == 'General'){
				bShowFollow = false;
			}
			
	        //Create a list of component with the number of components in the template
	        portalComponent = new ApexPages.Component[totalComponents];
	
	        try {
	            for (Portal_Content__c s: settings) {
	                //system.debug('@@@ Start Content_Type__c ' + s.Content_Type__c);
	                //system.debug('@@@ portalComponent ' + portalComponent);
	                Integer index = Integer.Valueof(s.Component_Number__c) - 1;
	                //determine content type                
	                if (s.Fixed_Component__c=='List View') {
	                    String feedCat = ApexPages.currentPage().getParameters().get('feedCat') == null ? '' : ApexPages.currentPage().getParameters().get('feedCat');
	                    String title = ApexPages.currentPage().getParameters().get('title') == null ? '' : ApexPages.currentPage().getParameters().get('title');
	                    String tmpContentCategory = ApexPages.currentPage().getParameters().get('ContentCategory') == null ? '' : ApexPages.currentPage().getParameters().get('ContentCategory');
				        String tmpDistLevel = ApexPages.currentPage().getParameters().get('DistLevel') == null ? '' : ApexPages.currentPage().getParameters().get('DistLevel');
				        String tmpDistTarget = ApexPages.currentPage().getParameters().get('DistTarget') == null ? '' : ApexPages.currentPage().getParameters().get('DistTarget');
        
	                    portalComponent[index] = 	                    
		                    new Component.c.ACGArticleListComponent(
		                    	recordRef=s.Id, 
		                    	isEditable=bEditMode, 
		                    	title=title, 
		                    	childDetailPage=(s.Child_Unique_Page_Name__c == null ? '' : s.Child_Unique_Page_Name__c),
		                    	pageContentCategory = tmpContentCategory,
		                    	pageDistLevel = tmpDistLevel,
		                    	pageDistTarget = tmpDistTarget
		                    	);
		                bMainPage = false;
	                } else if (s.Fixed_Component__c=='Article Detail') {
	                    String title = ApexPages.currentPage().getParameters().get('title') == null ? '' : ApexPages.currentPage().getParameters().get('title');
	                    Id articleID = ApexPages.currentPage().getParameters().get('Id') == null ? '' : ApexPages.currentPage().getParameters().get('Id');
	                    portalComponent[index] = new Component.c.ACGArticleFullComponent(recordRef=s.Id, isEditable=bEditMode, articleRef=articleID, title=title);
	                    bMainPage = false;
	                } else  {
	                    if (s.Content_Type__c == 'Report') {
	                        portalComponent[index] = new Component.c.ReportComponent(rName=s.Report_Name__c, rId=s.Report_ID__c,recordRef=s.Id, isEditable=bEditMode );
	                    } else if (s.Content_Type__c == 'Chatter') {      
	                        chatterFeedId = s.Chatter_Feed_ID__c;                                              
	                        //all people can access
	                        bChatterMember = true;  
	                        //Show or Hide Section                      
	                        bShowChatterGroup = false;
	                        bShowChatterFile = false;
	                        bShowChatterPhoto = false;
	                        
	                        bShowChatterGroup = s.Show_Chatter_Group_On_Page__c;
	                        bShowChatterFile = s.Show_Chatter_File_On_Page__c;
	                        bShowChatterPhoto = s.Show_Chatter_Photo_On_Page__c;
	                        
	                        portalComponent[index] = new Component.c.ChatterComponent(chatterGroup=s.Chatter_Feed_ID__c, recordRef=s.Id, isEditable=bEditMode, isAccessible=bChatterMember, showChatterFeed=bShowChatterGroup);
	                        if(s.Number_of_Slides__c != null) {
	                            photoSlidesNum = Integer.valueof(s.Number_of_Slides__c);   
	                        }
	                        if(s.Slideshow_Topic__c != '' && s.Slideshow_Topic__c != null) {
	                            List<String> tmps = new List<String>();
	                            if(s.Slideshow_Topic__c != null) {
	                                for(String str: s.Slideshow_Topic__c.split(';')) {
	                                    tmps.add(str.trim());
	                                }
	                            }
	                            topics = tmps;
	                        }
	                    } else if (s.Content_Type__c == 'HTML') {
	                        portalComponent[index] = new Component.c.HTMLComponent(Id=s.HTML_Selected__c, recordRef=s.Id, isEditable=bEditMode);
	                    } else if (s.Content_Type__c == 'Rich Text') {
	                        String strArticleFeedTitle = s.Article_Feed_Title__c != null? s.Article_Feed_Title__c :'Feed Title Not Set';
	                        if(s.Content_Category__c != 'General') {
	                        	if(ACG_Hierarchy__c.getAll().containsKey(s.Content_Category__c)) {
	                        		strArticleFeedTitle = ACG_Hierarchy__c.getAll().get(s.Content_Category__c).Label__c;
	                        	}
	                        }	                        
	                        portalComponent[index] = new Component.c.ACGArticleFeedComponent(
	                        	title=strArticleFeedTitle, 
	                        	recordRef=s.Id, 
	                        	isEditable=bEditMode, 
		                        childListPage=(s.Child_List_Unique_Page_Name__c==null?'':s.Child_List_Unique_Page_Name__c), 
		                        childDetailPage=(s.Child_Unique_Page_Name__c==null?'':s.Child_Unique_Page_Name__c)
		                    );
	                    } else if (s.Content_Type__c == 'RSS') {
	                        portalComponent[index] = new Component.c.RSSFeedComponent(rssLink=s.RSS_Feed_URL__c, title=s.RSS_Title__c, recordRef=s.Id, isEditable=bEditMode);
	                    } else if (s.Content_Type__c == 'Video') {
	                        portalComponent[index] = new Component.c.VideoComponent(videoCode=s.Video_Selected__c, recordRef=s.Id, isEditable=bEditMode);
	                    } else  {
	                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The content type for '+s.Component_Number__c+' in Template '+s.Template_ID__r.Template_Name__c+' is specified incorrectly. Please check.'));
	                    }
	                }
	            }
	        } 
	        catch (Exception e)  {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	        }
	        //Insert an empty HTML Component to handle error page / incorrect record setting	
	        Integer i=0;
	        for(ApexPages.Component cmp: portalComponent) {           
	            if(cmp == null) {
	                portalComponent[i] = new Component.c.HTMLComponent(Id=SystemUtil.getBlankHTMLId(), recordRef=SystemUtil.getBlankHTMLId(), isEditable=false);
	            }
	            i++;
	        }
	
	        //Chatter Photo Section		
	        Map<String, String> setTmpString = new Map<String, String>();
	        //Slideshow Topic is defined
	        if(topics.size()>0 && topics.get(0) != '') {	
	            for(TopicAssignment ta: [Select t.TopicId, t.Id, t.EntityId, t.Topic.Name
	                                        From TopicAssignment t
	                                        Where Topic.Name IN :topics]) {
	                mapName2Topics.put(ta.Topic.Name, ta.TopicId);
	                if(topics.get(0) == ta.Topic.Name) {
	                    setItemsId.add(ta.EntityId);                    
	                }
	                setTmpString.put(ta.Topic.Name.toUpperCase(), ta.Topic.Name);
	            }
	            for (String t: topics) {
	                if(setTmpString.containsKey(t.toUpperCase())) {                   
	                    SlideshowTopic.add(setTmpString.get(t.toUpperCase()));
	                }
	            }
	            for(FeedItem  fi: [Select f.Title, f.ParentId, f.Id, f.Body, f.ContentType, f.RelatedRecordId
	                                From FeedItem f
	                                Where Id IN: setItemsId
	                                And parentId = :chatterFeedId
	                                Order By LastModifiedDate desc, CreatedDate desc]) {
	                if(fi.ContentType != null) {
	                    if(fi.ContentType.toLowerCase().contains('image')) {
	                        setCVsId.add(fi.RelatedRecordId);
	                    }
	                }               
	            }
	        } else {	//No Slideshow topic is defined
	            for(ContentDocumentLink cdl:
	            	[
						SELECT c.ContentDocument.LatestPublishedVersionId
						FROM ContentDocumentLink c
						WHERE LinkedEntityId = :chatterFeedId
					]) {
	                setCVsId.add(cdl.ContentDocument.LatestPublishedVersionId);	                
	            }
	            //system.debug('### chatterFeedId ' + chatterFeedId);
	            //system.debug('### setCVsId ' + setCVsId);
	        }
	        
	        Boolean bIsBlogOrOffice = false;
	        if(pageContentCategory != null) {
	        	bIsBlogOrOffice = pageContentCategory.contains('Blog') || pageContentCategory.contains('Office');
	        }
	        if(bIsBlogOrOffice) {
	        	pageSite = SystemUtil.getPicklistValues2Label('Portal_Content__c','Content_Category__c').get(pageContentCategory);
	        } else {
		        //SitePath
		        pageDisivion = ACGUtil.getDivisonName(pageDistTarget);
		        pageDisivionURL = ACGUtil.getPageURL(pageDisivion, 'Division');
		        pageSite = pageDistTarget;
		        pageSiteURL = ACGUtil.getPageURL(pageDistTarget, pageDistLevel=='Division'?pageDistLevel:'Site');
		        
		        //Site Path to Label
		        if(SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Distribution_Target__c').containsKey(pageDisivion)) {
		        	pageDisivion = SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Distribution_Target__c').get(pageDisivion);
		        }
		        if(SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Distribution_Target__c').containsKey(pageSite)) {
		        	pageSite = SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Distribution_Target__c').get(pageSite);
		        }
	        }
	    } else {
	        bShouldRedirect = true;
	        redirectUrl = '/apex/DefaultErrorPage';
	    }
	    //system.debug('@@@ portalComponent ' + portalComponent);
    }
    
    //Get the setting records of the Unique Page Name
    public List<Portal_Content__c> getSettings() {
        String profileName = [Select Name from Profile where Id = :UserInfo.getProfileId()].get(0).Name;
        String uniquePageName = ApexPages.currentPage().getParameters().get('uniquePageName') == null ? '' : ApexPages.currentPage().getParameters().get('uniquePageName');  
        List<Portal_Content__c> settings = 
        	[
        		SELECT
                //Page Setting
                Id, Unique_Page_Name__c, Content_Type__c, Fixed_Component__c,                
                //Distribution
                Content_Category__c, Distribution_Level__c, Distribution_Target__c,
                //Template
                Template_ID__c, Template_ID__r.Template_Name__c, Template_Unique_Name__c, Template_ID__r.Tech_Total_Component__c, Component_Number__c,
                //Child Page
                Child_List_Unique_Page_Name__c, Child_Unique_Page_Name__c,
                //Chatter
                Chatter_Feed_ID__c, Number_of_Slides__c, Slideshow_Topic__c,
                Show_Chatter_File_On_Page__c, Show_Chatter_Group_On_Page__c, Show_Chatter_Photo_On_Page__c,
                //Content Section
                Article_Feed_Title__c, HTML_Selected__c, Video_Selected__c, RSS_Title__c, RSS_Feed_URL__c, Report_Name__c, Report_ID__c
                FROM Portal_Content__c 
				WHERE RecordType.DeveloperName = 'Settings' 
				AND Unique_Page_Name__c = :uniquePageName
                AND Component_Number__c != null
                order By Component_Number__c
			];        
        return settings;
    }
    
    //Get Department List of the Local Site
    public List<DepartmentWrapper> getDepartmentList() {
        List<DepartmentWrapper> result = new List<DepartmentWrapper>();
        Map<String, ACG_Hierarchy__c> mapACG = ACG_Hierarchy__c.getAll();
        Set<String> tmpSet = new Set<String>();
        List<ACG_Hierarchy__c> acgs = ACGUtil.getPageListValues(pageDistTarget);
		for(ACG_Hierarchy__c acg: acgs) {
			system.debug('### acgs Content_Category__c ' + acg.Content_Category__c);
			system.debug('### acgs.Name ' + acg.Name);
			system.debug('### tmpSet ' + tmpSet);
			if(!tmpSet.contains(acg.Content_Category__c)) {
				system.debug('### cp1 ' + acg.Name);
				if(mapACG.containsKey(acg.Content_Category__c)) {
					system.debug('### cp2 ' + acg.Name);
					result.add(new DepartmentWrapper(acg.Content_Category__c, mapACG.get(acg.Content_Category__c).Label__c, mapACG.get(acg.Content_Category__c).Icon_Link__c));
				}
			}
			system.debug('### result.size() ' + result.size());
			system.debug('### result ' + result.size());
		}
		system.debug('### return result.size() ' + result.size());
        return result;
    } 
        
    //Get the list of chatter files in the chatter group
    public Set<Id> getChatterFilesIntheGroup() {
        Set<Id> listFiles = new Set<Id>();        
        //system.debug('### chatterFeedId ' + chatterFeedId);
        for(ContentDocumentLink files : 
        	[
        		Select c.LinkedEntityId, c.Id, c.ContentDocument.PublishStatus, c.ContentDocument.Title, c.ContentDocument.Id, c.ContentDocumentId 
                From ContentDocumentLink c
                WHERE LinkedEntityId = :chatterFeedId
			]) {
            listFiles.add(files.ContentDocumentId); 
        }       
        return listFiles;
    }
    
    
    private transient List<ContentVersionWrapper> listChatterFiles;
    public Integer iChatterfilesSize {get;set;} 
    public Integer iChatterPhotosSize {get;set;} 
    
    //Get the file type of each file in the group
    public List<ContentVersionWrapper> getChatterFiles() {
        iChatterfilesSize = 0;      
        if (listChatterFiles == null) {
           listChatterFiles = new List<ContentVersionWrapper>();
           for (ContentVersion cv : 
           			[
           				SELECT ContentDocument.Id, ContentDocument.Title, Description, FileType, TagCsv, ContentDocumentId, ContentDocument.LatestPublishedVersionId 
		                FROM ContentVersion
		                Where ContentDocument.Id In :getChatterFilesIntheGroup()
		                order BY LastModifiedDate DESC
					]) {
                if(cv.FileType != 'PNG' && cv.FileType != 'JPG') {
                    if(iChatterfilesSize < 5) {                   
                        listChatterFiles.add(new ContentVersionWrapper(cv));
                    }   
                    iChatterfilesSize++;        
                }
            }
        }       
        return listChatterFiles;
    }
    
    public PageReference refreshPage() {
    	return null;
    }
    
    public List<ContentVersionWrapper> getChatterPhotos() {
        List<ContentVersionWrapper> listChatterPhotos = new List<ContentVersionWrapper>();
        iChatterPhotosSize = 0;
        Integer i=0;
        for (ContentVersion cv : 
        	[
        		SELECT ContentDocument.Id, ContentDocument.Title, Description, FileType, TagCsv, ContentDocumentId, ContentDocument.LatestPublishedVersionId 
                FROM ContentVersion
                Where Id IN:setCVsId
                Order By LastModifiedDate desc, CreatedDate desc
                limit :photoSlidesNum
			]) {
            listChatterPhotos.add(new ContentVersionWrapper(cv, i));
            i++;
        }        
        iChatterPhotosSize =  [Select COUNT() FROM ContentVersion Where Id IN:setCVsId];
        return listChatterPhotos;
    }
    /**
    	Remote Action used to follow and unfollow page/blog
    */
	
    @RemoteAction
    global static PageReference followPage(String ChatterGroupId) {
        if(ChatterGroupId != null && ChatterGroupId != '') {
        	List<CollaborationGroupMember> members = 
        		[
        			SELECT Id
        			FROM CollaborationGroupMember
        			WHERE CollaborationGroupId = :ChatterGroupId
        			AND MemberId = :userInfo.getUserId()
        			limit 1
        		];
        	if(members.isEmpty()) {
        		CollaborationGroupMember grpMember = new CollaborationGroupMember();
				grpMember.CollaborationGroupId = ChatterGroupId;
				grpMember.MemberId = userInfo.getUserId();
				Insert grpMember;
        	}
        }
        return null;
    }
    
    @RemoteAction
    global static PageReference unfollowPage(String ChatterGroupId) {
        if(ChatterGroupId != null && ChatterGroupId != '') {
        	List<CollaborationGroupMember> members = 
        		[
        			SELECT Id
        			FROM CollaborationGroupMember
        			WHERE CollaborationGroupId = :ChatterGroupId
        			AND MemberId = :userInfo.getUserId()
        			limit 1
        		];
        	if(!members.isEmpty()) {
        		delete members.get(0);
        	}
        }
        return null;
    }
    
    /**
     * @description used to force a submit of view state
     */    
    public PageReference forceSubmit() {
    	return null;
    }
    

}