/**
 * @description Handle the conversion of Chatter Feed Items into ACG Announcements
 */
public class ACGFeedItemUtil {
    
    /**
     * @description Used in ACGArticleDetailCtrl
     */
    public class ArticleLikeInfo {
        
        public Integer likes {get;set;} {likes = 0;}
        public boolean userHasLiked {get;set;} {userHasLiked = false;}
    }
    
    /**
     * @description Helper, for a given list of Chatter Group Ids, check if the current user is an Owner or Manager of that group
     */
    public static Map<Id, boolean> userCanConvertArticles(Set<Id> chatterGroupIds) {
        Map<Id, boolean> chatterGroupIdToPermission = new Map<Id, boolean>();
        
        for(Id s : chatterGroupIds) {
			chatterGroupIdToPermission.put(s, false);
        }
        
        for(CollaborationGroupMember cgm : 
            [
                SELECT Id, CollaborationGroupId, MemberId 
                FROM CollaborationGroupMember 
                WHERE MemberId = :UserInfo.getUserId() 
                AND CollaborationGroupId IN :chatterGroupIds
                AND CollaborationRole = 'Admin'
            ]) {
			
           chatterGroupIdToPermission.put(cgm.CollaborationGroupId, true);     
                
        }
        
        return chatterGroupIdToPermission;
    }
    
    /**
     * @description Helper, given a list of feed items, extract out the relevant ContentVersions
     */
    public static Map<Id, ContentVersion> relatedContentVersionToObject(List<FeedItem> fiList) {
        Map<Id, ContentVersion> relatedContentVersionToObjectMap = new Map<Id, ContentVersion>();
        
        List<Id> contentVersionIdList = new List<Id>();
        
        for(FeedItem fi : fiList) {
			if(fi.Type == 'ContentPost') {
                contentVersionIdList.add(fi.RelatedRecordId);
            }
        }
        
        for(ContentVersion cv : [SELECT Id, Title, Description FROM ContentVersion WHERE Id IN: contentVersionIdList AND IsLatest = true]) {
			relatedContentVersionToObjectMap.put(cv.Id, cv);
        }
        
        return relatedContentVersionToObjectMap;
    }
    
    /**
     * @description Helper to get a mapping of Content Categories for this user and this chatter group
     */
    public static Map<Id, ACG_Article_Conversion_Content_Category__c> getGroupIdToDefaultContentCategoryMap(Set<Id> chatterGroupIds) {
        Map<Id, ACG_Article_Conversion_Content_Category__c> groupIdToDefaultContentCategoryMap = new Map<Id, ACG_Article_Conversion_Content_Category__c>();
        Map<String, Id> chatterGroupNameToIdMap = new Map<String, Id>();
        for(CollaborationGroup cg : [SELECT Id, Name FROM CollaborationGroup WHERE Id IN :chatterGroupIds]) {
            chatterGroupNameToIdMap.put(cg.Name, cg.Id);
        }
        
        for(ACG_Article_Conversion_Content_Category__c cc : 
            [
                SELECT Chatter_Group_Name__c, Content_Category__c 
                FROM ACG_Article_Conversion_Content_Category__c 
                WHERE Username__c = :UserInfo.getUserName() 
                AND Chatter_Group_Name__c IN :chatterGroupNameToIdMap.keySet()
            ]) {
           
			if(chatterGroupNameToIdMap.get(cc.Chatter_Group_Name__c) != null) {
            	groupIdToDefaultContentCategoryMap.put(chatterGroupNameToIdMap.get(cc.Chatter_Group_Name__c), cc);
            }
        }
        
        return groupIdToDefaultContentCategoryMap;
    }
    
    /**
     * @description Get the list of Feed Item types that should be convertable
     */
    public static boolean isConvertableType(FeedItem fi) {
        boolean result = false;
    	Set<String> types = new Set<String>();
        
        types.add('ContentPost');
        types.add('TextPost');
        types.add('LinkPost');

        //types.add('AdvancedTextPost'); // Disable

        if(types.contains(fi.Type)) {
            result = true;
        }
        
        return result;
    }
    
    public static void validateGroupMentionRights(Map<Id, List<Id>> feedItemIdToGroupId, List<FeedItem> fiList) {
		Set<Id> groupIds = new Set<Id>();
        for(List<Id> groupIdList : feedItemIdToGroupId.values()) {
            groupIds.addAll(groupIdList);
        }
        
        Map<Id, boolean> groupIdToCanUserMention = new Map<Id, boolean>();
        Map<Id, boolean> groupIsAcgGroup = new Map<Id, boolean>();
        
        System.debug('>>>> ACGFeedItemUtil.validateGroupMentionRights() | feedItemIdToGroupId? ' + feedItemIdToGroupId);
        
        for(CollaborationGroup cg : 
            [
                SELECT Id, Owner.Name
                FROM CollaborationGroup
                WHERE Id IN: groupIds 
            ]
           ) {
		
               if(cg.Owner.Name == Label.ACGMentionUser) {
                    
               		groupIsAcgGroup.put(cg.Id, true);
               	}
        }
        for(CollaborationGroupMember cgm : 
            [
                SELECT Id, CollaborationRole, CollaborationGroupId, CollaborationGroup.Owner.Name
                FROM CollaborationGroupMember 
                WHERE CollaborationGroupId IN: groupIds 
                AND MemberId =: UserInfo.getUserId()
                AND CollaborationRole = 'Admin'
            ]
           ) {
                
                groupIdToCanUserMention.put(cgm.CollaborationGroupId, true);
           }
        
        for(FeedItem fi : fiList) {
            boolean addError = false;
            
            if(feedItemIdToGroupId.get(fi.Id) != null) {
                List<Id> checkGroupIds = feedItemIdToGroupId.get(fi.Id);
                for(Id groupId : checkGroupIds) {
                    if(groupIsAcgGroup.get(groupId) != null && groupIdToCanUserMention.get(groupId) == null) {
                        addError = true;
                        break;
                    }
                }
                
                if(addError) {
                    fi.addError(Label.ACGOnlyManagersCanMention);
                }
            }
        }
    }
        
    /**
     * @description If a user makes a post an @mentions a group, check if that Group is linked to an ACG page,
     * 				if it is, synchronize an announcement
     */
    public static void createACGArticleFromGroupMention(List<FeedItem> fiList) {

        // -- Get the Mentioned Elements -- //
        Map<Id, List<String>> feedItemIdMentionedElementMap = new Map<Id, List<String>>();
		
		/*
		 * This is a map of [FeedItem's ID --> @Mention]
		 */
        feedItemIdMentionedElementMap = ACGFeedItemUtil.getFeedItemIdMentionedElementMap(fiList);
        System.debug('>>>> ACGFeedItemUtil.createACGArticleFromGroupMention() | feedItemIdMentionedElementMap? ' + feedItemIdMentionedElementMap);
        
        // -- Query the Groups -- //
        Map<String, Id> groupNameToId = new Map<String, Id>();
        
        Set<String> groupNames = new Set<String>();
        for(List<String> gNameList : feedItemIdMentionedElementMap.values()) {
            groupNames.addAll(gNameList);
        }
        
        for(CollaborationGroup cg : [SELECT Id, Name FROM CollaborationGroup WHERE Name IN :groupNames]) {
            groupNameToId.put(cg.Name, cg.Id);

        }
        
        
        System.debug('>>>> ACGFeedItemUtil.createACGArticleFromGroupMention() | groupNameToId? ' + groupNameToId);
        
        // -- Get mapping of FeedItems to Groups -- //
        Map<Id, List<Id>> feedItemIdToGroupId = new Map<Id, List<Id>>();
        List<FeedItem> filteredFiList = new List<FeedItem>();
        
        for(FeedItem fi : fiList) {
        	
        	// First use the FeedItemId and get the @mention
        	// Use the @mention and get the GroupId
        	
            if(feedItemIdMentionedElementMap.get(fi.Id) != null) {
                List<String> groupNameList = feedItemIdMentionedElementMap.get(fi.Id);
                
                for(String groupName : groupNameList) {
                    if(groupNameToId.get(groupName) != null) {
                        //feedItemIdToGroupId.put(fi.Id, groupNameToId.get(groupName)); @deprecated
                        
                        // Prepare the map
                        if(feedItemIdToGroupId.get(fi.Id) != null) {
                            List<Id> groupIds = feedItemIdToGroupId.get(fi.Id);
                            groupIds.add(groupNameToId.get(groupName));
                            feedItemIdToGroupId.put(fi.Id, groupIds);
                        } else {
                            List<Id> groupIds = new List<Id>();
                            groupIds.add(groupNameToId.get(groupName));
                            feedItemIdToGroupId.put(fi.Id, groupIds);
                        	filteredFiList.add(fi);
                        }
                        
                        
                    }
                }
            }
        }
        
        System.debug('>>>> ACGFeedItemUtil.createACGArticleFromGroupMention() | filteredFiList? ' + filteredFiList);
        
        if(!filteredFiList.isEmpty()) {
            ACGFeedItemUtil.validateGroupMentionRights(feedItemIdToGroupId, filteredFiList);
            
            ACGFeedItemUtil.createACGArticleNew(filteredFiList, feedItemIdToGroupId);
        }
    }
    
    /**
     * @description Given a list of FeedItems, check if they mentioned anything. If so, put it in a map and return
     * 				this mapping
     */
    public static Map<Id, List<String>> getFeedItemIdMentionedElementMap(List<FeedItem> fiList) {
        Map<Id, List<String>> feedItemIdToGroupName = new Map<Id, List<String>>();
        //Map<String, Id> groupNameToFeedItemId = new Map<String, Id>();
        
        for(FeedItem fi : fiList) {
            String body = fi.Body;
            if(body != null && body.contains('@')) {
                
                Pattern p = Pattern.compile('@([a-zA-Z0-9-_]+)');
                //Pattern p = Pattern.compile('@(\\w+|\\W+)');
                
                Matcher pm = p.matcher(body);
                while(pm.find()) {
                    System.debug('Match = ' + pm.group(1));
                    String mentionedElement = pm.group(1);
                	//feedItemIdToGroupName.put(fi.Id, mentionedElement);
                    
                    if(feedItemIdToGroupName.get(fi.Id) != null) {
                        List<String> mentions = feedItemIdToGroupName.get(fi.Id);
                        mentions.add(mentionedElement);
                        feedItemIdToGroupName.put(fi.Id, mentions);
                    } else {
                        List<String> mentions = new List<String>();
                        mentions.add(mentionedElement);
                        feedItemIdToGroupName.put(fi.Id, mentions);
                    }
                }
            }
        }
        
        // We assume that at maximum it's one group to one ACG page mapping
        
        return feedItemIdToGroupName;
    }
    
    
    /**
     * @description Given a list of FeedItems, check if they are inscope for conversion, if so, convert them to ACG Articles
     */
	public static void createACGArticleNew(List<FeedItem> listNewFeedItem, Map<Id, List<Id>> feedItemIdToGroupId) {
    	boolean isAtMentionGroup = (feedItemIdToGroupId != null);
        
        // -- Setup Data Structures -- //
    	List<Portal_Content__c> newArticles = new List<Portal_Content__c>();
    	Set<Id> chatterIds = new Set<Id>(); 
        Set<Id> fiIds = new Set<Id>();
        List<Portal_Content__c> chatterAnnouncementsToUpdate = new List<Portal_Content__c>();
        List<ACG_Content_Post__c> acgContentPosts = new List<ACG_Content_Post__c>();
        
        // -- Create a list of Chatter Group Ids associated to the Feed Items -- //
        if(!isAtMentionGroup) {
            for(FeedItem fi: listNewFeedItem) {
                if(fi.ParentId.getSObjectType() == CollaborationGroup.sObjectType) {
                    chatterIds.add(fi.parentId);
                    fiIds.add(fi.Id);
                }
            }
        } else {
            for(List<Id> idList : feedItemIdToGroupId.values()) {
            	chatterIds.addAll(idList);
            }
            
            fiIds.addAll(feedItemIdToGroupId.keySet());
        }
        
        // -- Setup our Maps -- //
    	Map<String, Portal_Content__c> mapChatterGroup = new Map<String, Portal_Content__c>();
    	Map<Id, boolean> chatterGroupIdToPermission = new Map<Id, boolean>();
        Map<Id, ContentVersion> relatedContentVersionToObjectMap = new Map<Id, ContentVersion>();
        Map<Id, ACG_Article_Conversion_Content_Category__c> groupIdToDefaultContentCategoryMap = new Map<Id, ACG_Article_Conversion_Content_Category__c>();

        if(chatterIds != null && !chatterIds.isEmpty()) {
            mapChatterGroup = ACGUtil.getAssociatedChatterGroup(chatterIds);
            chatterGroupIdToPermission = ACGFeedItemUtil.userCanConvertArticles(chatterIds);
            relatedContentVersionToObjectMap = ACGFeedItemUtil.relatedContentVersionToObject(listNewFeedItem);
            groupIdToDefaultContentCategoryMap = ACGFeedItemUtil.getGroupIdToDefaultContentCategoryMap(chatterIds);    
        }
        
        // -- Start the reverse posting -- //
		System.debug('>>>> ACGFeedItemUtil.createACGArticleNew() | listNewFeedItem? ' + listNewFeedItem);
        
    	for(FeedItem fi: listNewFeedItem) {
    		system.debug('### fi.Title ' + fi.Title);
    		system.debug('### fi.parentId ' + fi.parentId);
            
            if(!isAtMentionGroup && fi.ParentId.getSObjectType() != CollaborationGroup.sObjectType) {
            	continue;
            }
            
    		// -- Check if it is in publishing process to prevent an infinite loop --//
			if(!(fi.Title != null && fi.Title.contains(Label.ACGPublishKeyword)) && !(fi.Title != null && fi.Title.contains('[Read More]'))) {
                
    			// -- Check if the chatter group is linked to any ACG Landing Page AND the user has permission to do this kind of shenanigans --//
				Set<Id> theGroupIdList = new Set<Id>();
                
                if(isAtMentionGroup) {
                    theGroupIdList.addAll(feedItemIdToGroupId.get(fi.Id));
                } else {
                	theGroupIdList.add(fi.parentId);
                }
                
                System.debug('>>>> ACGFeedItemUtil.createACGArticleNew() | theGroupIdList? ' + theGroupIdList);
                
                for(Id theGroupId : theGroupIdList) {
                    if( ACGFeedItemUtil.isConvertableType(fi) && 
                        mapChatterGroup.containsKey(theGroupId) && 
                        chatterGroupIdToPermission.get(theGroupId)
                    ) {
                        Portal_Content__c pc = new Portal_Content__c();
                        
                        if(mapChatterGroup.get(theGroupId).Content_Category__c.contains('General') && 
                            (groupIdToDefaultContentCategoryMap.get(theGroupId) != null)) {
                                
                            pc.Content_Category__c = groupIdToDefaultContentCategoryMap.get(theGroupId).Content_Category__c;
                                
                        } else {
                            pc.Content_Category__c = mapChatterGroup.get(theGroupId).Content_Category__c;
                            
                        }
                                            
                        pc.Distribution_Level__c = mapChatterGroup.get(theGroupId).Distribution_Level__c;
                        pc.Distribution_Target__c = mapChatterGroup.get(theGroupId).Distribution_Target__c;
                        
                        pc.Article_Type__c = 'Article';
                        if(pc.Content_Category__c != null && pc.Content_Category__c.contains('Blog')) {
                            pc.Article_Type__c = 'Blog';
                        }
                        
                        pc.Status__c = 'Published';
                        pc.Publish_Datetime__c = datetime.now();
                        pc.Sticky_Scale__c = ACGFeedItemUtil.populateStickyScale(fi);
                        pc.Expiry_Date__c = AcgFeedItemUtil.populateExpiryDate(fi);
                        pc.Language__c = 'en';
                        pc.Title_en__c = ACGFeedItemUtil.populateArticleTitle(fi, relatedContentVersionToObjectMap);
                        pc.Summary_en__c = ACGFeedItemUtil.populateArticleSummary(fi, relatedContentVersionToObjectMap);
                        pc.Contents_en__c = ACGFeedItemUtil.populateArticleContents(fi, relatedContentVersionToObjectMap);
                        
                        pc.Title__c = ACGFeedItemUtil.populateArticleTitle(fi, relatedContentVersionToObjectMap);
                        pc.Summary__c = ACGFeedItemUtil.populateArticleSummary(fi, relatedContentVersionToObjectMap);
                        pc.Contents__c = ACGFeedItemUtil.populateArticleContents(fi, relatedContentVersionToObjectMap);
                        pc.Article_Thumbnail__c = fi.RelatedRecordId;
                        pc.Tech_Feed_Item_Id__c = fi.Id; // Use this still to keep the original Chatter Post
                        
                        
                        newArticles.add(pc);
                        
                        if(fi.Type == 'AdvancedTextPost') {
                            chatterAnnouncementsToUpdate.add(pc);
                        }
                    }
                }
    		}
    	}
        
        System.debug('>>>> ACGFeedItemUtil.createACGArticleNew() | newArticles? ' + newArticles);
    	system.debug('### newArticles ' + newArticles);
		
        if(!newArticles.isEmpty()) {

			insert newArticles;
            
            List<ACG_Content_Post__c> placeholderContentPosts = ACGFeedItemUtil.createPlaceholderComment(newArticles);
            
            for(Portal_Content__c pc : newArticles) {
                acgContentPosts.add(new ACG_Content_Post__c(Acg_Content__c = pc.Id , Post_Id__c = pc.Tech_Feed_Item_Id__c));
            }
            
            acgContentPosts.addAll(placeholderContentPosts);
            
            if(!acgContentPosts.isEmpty()) {
            	insert acgContentPosts;    
            }
            
            if(!chatterAnnouncementsToUpdate.isEmpty()) {
                List<Id> idsToUpdate = new List<Id>();
                for(Portal_Content__c pc : chatterAnnouncementsToUpdate) {
                    idsToUpdate.add(pc.Id);
                }
                
                ACGFeedItemUtil.updateAnnouncementExpiry(idsToUpdate);
            }
            
            
            
		}
    }
    
    /**
     * @description Given a list of FeedItems, check if they are inscope for conversion, if so, convert them to ACG Articles
     */
	public static void createACGArticle(List<FeedItem> listNewFeedItem) {
    	
        // Setup
    	List<Portal_Content__c> newArticles = new List<Portal_Content__c>();
    	Set<Id> chatterIds = new Set<Id>(); 
        Set<Id> fiIds = new Set<Id>();
        List<Portal_Content__c> chatterAnnouncementsToUpdate = new List<Portal_Content__c>();
        List<ACG_Content_Post__c> acgContentPosts = new List<ACG_Content_Post__c>();
        
        // Create a list of Chatter Group Ids associated to the Feed Items
    	for(FeedItem fi: listNewFeedItem) {
            if(fi.ParentId.getSObjectType() == CollaborationGroup.sObjectType) {
                chatterIds.add(fi.parentId);
                fiIds.add(fi.Id);
            }
    	}
        
    	Map<String, Portal_Content__c> mapChatterGroup = new Map<String, Portal_Content__c>();
    	Map<Id, boolean> chatterGroupIdToPermission = new Map<Id, boolean>();
        Map<Id, ContentVersion> relatedContentVersionToObjectMap = new Map<Id, ContentVersion>();
        Map<Id, ACG_Article_Conversion_Content_Category__c> groupIdToDefaultContentCategoryMap = new Map<Id, ACG_Article_Conversion_Content_Category__c>();

        if(chatterIds != null && !chatterIds.isEmpty()) {
            mapChatterGroup = ACGUtil.getAssociatedChatterGroup(chatterIds);
            chatterGroupIdToPermission = ACGFeedItemUtil.userCanConvertArticles(chatterIds);
            relatedContentVersionToObjectMap = ACGFeedItemUtil.relatedContentVersionToObject(listNewFeedItem);
            groupIdToDefaultContentCategoryMap = ACGFeedItemUtil.getGroupIdToDefaultContentCategoryMap(chatterIds);    
        }
        
        System.debug('### mapChatterGroup ' + mapChatterGroup);
        
    	for(FeedItem fi: listNewFeedItem) {
    		system.debug('### fi.Title ' + fi.Title);
    		system.debug('### fi.parentId ' + fi.parentId);
            
            if(fi.ParentId.getSObjectType() != CollaborationGroup.sObjectType) {
            	continue;
            }
            
    		// Check if it is in publishing process to prevent an infinite loop
			if(!(fi.Title != null && fi.Title.contains(Label.ACGPublishKeyword)) && !(fi.Title != null && fi.Title.contains('[Read More]'))) {
                
    			// Check if the chatter group is linked to any ACG Landing Page AND the user has permission to do this kind of shenanigans
    			if(ACGFeedItemUtil.isConvertableType(fi) && mapChatterGroup.containsKey(fi.parentId) && chatterGroupIdToPermission.get(fi.parentId)) {
	    			Portal_Content__c pc = new Portal_Content__c();
                    
                    if(mapChatterGroup.get(fi.parentId).Content_Category__c.contains('General') && 
                       	(groupIdToDefaultContentCategoryMap.get(fi.parentId) != null)) {
						pc.Content_Category__c = groupIdToDefaultContentCategoryMap.get(fi.parentId).Content_Category__c;
                    } else {
                        pc.Content_Category__c = mapChatterGroup.get(fi.parentId).Content_Category__c;
                    }
                    	    			
	    			pc.Distribution_Level__c = mapChatterGroup.get(fi.parentId).Distribution_Level__c;
	    			pc.Distribution_Target__c = mapChatterGroup.get(fi.parentId).Distribution_Target__c;
                    
	    			pc.Article_Type__c = 'Article';
	    			if(pc.Content_Category__c != null && pc.Content_Category__c.contains('Blog')) {
	    				pc.Article_Type__c = 'Blog';
	    			}
                    
	    			pc.Status__c = 'Published';
	    			pc.Publish_Datetime__c = datetime.now();
	    			pc.Sticky_Scale__c = ACGFeedItemUtil.populateStickyScale(fi);
	    			pc.Expiry_Date__c = AcgFeedItemUtil.populateExpiryDate(fi);
	    			pc.Language__c = 'en';
	    			pc.Title_en__c = ACGFeedItemUtil.populateArticleTitle(fi, relatedContentVersionToObjectMap);
	    			pc.Summary_en__c = ACGFeedItemUtil.populateArticleSummary(fi, relatedContentVersionToObjectMap);
	    			pc.Contents_en__c = ACGFeedItemUtil.populateArticleContents(fi, relatedContentVersionToObjectMap);
                    
	    			pc.Title__c = ACGFeedItemUtil.populateArticleTitle(fi, relatedContentVersionToObjectMap);
	    			pc.Summary__c = ACGFeedItemUtil.populateArticleSummary(fi, relatedContentVersionToObjectMap);
	    			pc.Contents__c = ACGFeedItemUtil.populateArticleContents(fi, relatedContentVersionToObjectMap);
	    			pc.Article_Thumbnail__c = fi.RelatedRecordId;
                    pc.Tech_Feed_Item_Id__c = fi.Id; // Use this still to keep the original Chatter Post
                    
                    
	    			newArticles.add(pc);
                    
                    if(fi.Type == 'AdvancedTextPost') {
                        chatterAnnouncementsToUpdate.add(pc);
                    }
    			}
    		}
    	}
        
    	system.debug('### newArticles ' + newArticles);
		
        if(!newArticles.isEmpty()) {			
			insert newArticles;
            
            List<ACG_Content_Post__c> placeholderContentPosts = ACGFeedItemUtil.createPlaceholderComment(newArticles);
            
            for(Portal_Content__c pc : newArticles) {
                acgContentPosts.add(new ACG_Content_Post__c(Acg_Content__c = pc.Id , Post_Id__c = pc.Tech_Feed_Item_Id__c));
            }
            
            acgContentPosts.addAll(placeholderContentPosts);
            
            if(!acgContentPosts.isEmpty()) {
            	insert acgContentPosts;    
            }
            
            if(!chatterAnnouncementsToUpdate.isEmpty()) {
                List<Id> idsToUpdate = new List<Id>();
                for(Portal_Content__c pc : chatterAnnouncementsToUpdate) {
                    idsToUpdate.add(pc.Id);
                }
                
                ACGFeedItemUtil.updateAnnouncementExpiry(idsToUpdate);
            }
            
            
            
		}
    }
    
    /**
     * @description Given a list of FeedItems, check if they are inscope for conversion, if so, convert them to ACG Articles
     */
	public static void updateACGArticle(List<FeedItem> listNewFeedItem) {
    	
        // ----- Start Setup  ----- //
    	List<Portal_Content__c> newArticles = new List<Portal_Content__c>();
    	Set<Id> chatterIds = new Set<Id>(); 
        Set<Id> fiIds = new Set<Id>();
        List<Portal_Content__c> chatterAnnouncementsToUpdate = new List<Portal_Content__c>();
        List<ACG_Content_Post__c> acgContentPosts = new List<ACG_Content_Post__c>();
        
        // Create a list of Chatter Group Ids associated to the Feed Items
    	for(FeedItem fi: listNewFeedItem) {
            if(fi.ParentId.getSObjectType() == CollaborationGroup.sObjectType) {
                chatterIds.add(fi.parentId);
                fiIds.add(fi.Id);
            }
    	}
        
    	Map<String, Portal_Content__c> mapChatterGroup = new Map<String, Portal_Content__c>();
    	Map<Id, boolean> chatterGroupIdToPermission = new Map<Id, boolean>();
        Map<Id, ContentVersion> relatedContentVersionToObjectMap = new Map<Id, ContentVersion>();
        Map<Id, ACG_Article_Conversion_Content_Category__c> groupIdToDefaultContentCategoryMap = new Map<Id, ACG_Article_Conversion_Content_Category__c>();

        if(chatterIds != null && !chatterIds.isEmpty()) {
            mapChatterGroup = ACGUtil.getAssociatedChatterGroup(chatterIds);
            chatterGroupIdToPermission = ACGFeedItemUtil.userCanConvertArticles(chatterIds);
            relatedContentVersionToObjectMap = ACGFeedItemUtil.relatedContentVersionToObject(listNewFeedItem);
            groupIdToDefaultContentCategoryMap = ACGFeedItemUtil.getGroupIdToDefaultContentCategoryMap(chatterIds);    
        }
        
        // ACG Announcement ID --> Source Chatter Post ID
        Map<String, String> acgPostIdToFeedItemId = new Map<String, String>();
        for(ACG_Content_Post__c acp : [SELECT Id, Post_Id__c, ACG_Content__c FROM ACG_Content_Post__c WHERE Post_Id__c IN: fiIds]) {
            acgPostIdToFeedItemId.put(acp.ACG_Content__c, acp.Post_Id__c); // We assume it's always 1 to 1
        }
        
        // Source Chatter Post ID --> ACG Announcement Object
        Map<String, Portal_Content__c> feedItemIdToPortalContent = new Map<String, Portal_Content__c>();
        for(Portal_Content__c pc : [SELECT Id FROM Portal_Content__c WHERE Id IN: acgPostIdToFeedItemId.keySet()]) {
            feedItemIdToPortalContent.put(acgPostIdToFeedItemId.get(pc.Id), pc);
        }
        
        // ----- Setup Complete ----- //
        
    	for(FeedItem fi: listNewFeedItem) {
            
            if(fi.ParentId.getSObjectType() != CollaborationGroup.sObjectType) {
            	continue;
            }
            
    		// Check if it is in publishing process to prevent an infinite loop
			if(!(fi.Title != null && fi.Title.contains(Label.ACGPublishKeyword)) && !(fi.Title != null && fi.Title.contains('[Read More]'))) {
                
    			// Check if the chatter group is linked to any ACG Landing Page AND the user has permission to do this kind of shenanigans
    			if(ACGFeedItemUtil.isConvertableType(fi) && mapChatterGroup.containsKey(fi.parentId) && chatterGroupIdToPermission.get(fi.parentId)) {
	    			Portal_Content__c pc = feedItemIdToPortalContent.get(fi.Id);
                    if(pc != null) {
                        if(mapChatterGroup.get(fi.parentId).Content_Category__c.contains('General') && 
                            (groupIdToDefaultContentCategoryMap.get(fi.parentId) != null)) {
                            pc.Content_Category__c = groupIdToDefaultContentCategoryMap.get(fi.parentId).Content_Category__c;
                        } else {
                            if(mapChatterGroup.get(fi.parentId) != null) {
                                
                                pc.Content_Category__c = mapChatterGroup.get(fi.parentId).Content_Category__c;
                            }
                        }
                                            
                        pc.Distribution_Level__c = mapChatterGroup.get(fi.parentId).Distribution_Level__c;
                        pc.Distribution_Target__c = mapChatterGroup.get(fi.parentId).Distribution_Target__c;
                        
                        pc.Article_Type__c = 'Article';
                        if(pc.Content_Category__c != null && pc.Content_Category__c.contains('Blog')) {
                            pc.Article_Type__c = 'Blog';
                        }
                        
                        pc.Status__c = 'Published';
                        pc.Publish_Datetime__c = datetime.now();
                        pc.Sticky_Scale__c = ACGFeedItemUtil.populateStickyScale(fi);
                        pc.Expiry_Date__c = AcgFeedItemUtil.populateExpiryDate(fi);
                        pc.Language__c = 'en';
                        pc.Title_en__c = ACGFeedItemUtil.populateArticleTitle(fi, relatedContentVersionToObjectMap);
                        pc.Summary_en__c = ACGFeedItemUtil.populateArticleSummary(fi, relatedContentVersionToObjectMap);
                        pc.Contents_en__c = ACGFeedItemUtil.populateArticleContents(fi, relatedContentVersionToObjectMap);
                        
                        pc.Title__c = ACGFeedItemUtil.populateArticleTitle(fi, relatedContentVersionToObjectMap);
                        pc.Summary__c = ACGFeedItemUtil.populateArticleSummary(fi, relatedContentVersionToObjectMap);
                        pc.Contents__c = ACGFeedItemUtil.populateArticleContents(fi, relatedContentVersionToObjectMap);
                        pc.Article_Thumbnail__c = fi.RelatedRecordId;
                        pc.Tech_Feed_Item_Id__c = fi.Id; // Use this still to keep the original Chatter Post
                        
                        
                        newArticles.add(pc);
                    }
    			}
    		}
    	}
		
        if(!newArticles.isEmpty()) {			
			update newArticles;
		}
    }
    
    public static List<ACG_Content_Post__c> createPlaceholderComment(List<Portal_Content__c> pcs) {

        Map<Id, FeedItem> pcIdToFeedItem = new Map<Id, FeedItem>();
        List<ACG_Content_Post__c> placeholderContentPosts = new List<ACG_Content_Post__c>();
        
        for(Portal_Content__c pc : pcs) {
            FeedItem f = new FeedItem();
            f.ParentId = pc.Id;
            f.Body = 'Chatter Post Comments';
            f.type = 'TextPost';
            f.CreatedById = Label.ServiceAccountUserId;
            
            pcIdToFeedItem.put(pc.Id, f);
        }
        
        if(!pcIdToFeedItem.isEmpty()) {
            insert pcIdToFeedItem.values();
            
            for(Portal_Content__c pc : pcs) {
                pc.Tech_Article_Feed_Item_Id__c = pcIdToFeedItem.get(pc.Id).Id;
            }
            
            update pcs;
            
            for(Portal_Content__c pc : pcs) {
            	placeholderContentPosts.add(new ACG_Content_Post__c(Acg_Content__c = pc.Id , Post_Id__c = pcIdToFeedItem.get(pc.Id).Id));
            }
        }
        
        return placeholderContentPosts;
    }
    
    /**
     * @description logic for populating the Sticky scale
     */
    public static String populateStickyScale(FeedItem fi) {
        String result = '';
        
        if(fi.Type == 'AdvancedTextPost') {
			result = '3';	
        } else {
            result = '5';
        }
        
        return result;
    }
    
    /**
     * @description logic for populating the Expiry Date
     */
    public static Date populateExpiryDate(FeedItem fi) {
        Date result = Date.today() + AcgUtil.getDefaultStickyExpiryDays();
        return result;
    }
    
    /**
     * @description logic for populating the Article Title
     */
    public static String populateArticleTitle(FeedItem fi, Map<Id, ContentVersion> relatedContentVersionToObjectMap) {
        String result = '';

        if(fi.Body != null && fi.Body.length() > 240) {
            result = fi.Body.substring(0, 240) + '...';
        } else {
            result = fi.Body;
        }
        
        // Strip HTML
        if(result != null) {
        	result = result.replaceAll('<[^>]+>',' ');
        }
        
		if(fi.Type == 'TextPost') {

        } else if(fi.Type == 'ContentPost') {
			result = relatedContentVersionToObjectMap.get(fi.RelatedRecordId).Title;
            
        } else if(fi.Type == 'LinkPost') {
			result = fi.Title;
            
        } else if(fi.Type == 'AdvancedTextPost') {
		
        }
        
        return result;
    }
    
    /**
     * @description logic for populating the Article Summary
     */
    public static String populateArticleSummary(FeedItem fi, Map<Id, ContentVersion> relatedContentVersionToObjectMap) {
        String result = '';
        
        if(fi.Body != null && fi.Body.length() > 240) {
            result = fi.Body.substring(0, 240) + '...';
        } else {
            result = fi.Body;
        }

        if(result != null) {
        	result = result.replaceAll('<[^>]+>',' ');
        }
        
        return result;
    }
    
    /**
     * @description logic for populating the Article Body or Contents
     */
    public static String populateArticleContents(FeedItem fi, Map<Id, ContentVersion> relatedContentVersionToObjectMap) {
        String result = '';
        if(fi.Body != null) {
            result = fi.Body.replace('\n', '<br/>');
        } else {
            result = fi.Body;
        }
        
        if(fi.Type == 'TextPost') {

        } else if(fi.Type == 'ContentPost') {
            String title = relatedContentVersionToObjectMap.get(fi.RelatedRecordId).Title;
            String description = relatedContentVersionToObjectMap.get(fi.RelatedRecordId).Description;
            
			result = result + 
                		'<br/><br/>' +
                		'<div class="tal-file-preview">' + 
                		'<a href="/' + fi.RelatedRecordId + '">' + 
                		'<img src="/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' + fi.RelatedRecordId + '"/></a><br/><br/>' + 
                		title + (description == null ? '' : ': ' + description) + 
                		'</div>';
            
        } else if(fi.Type == 'LinkPost') {
			result = result +
                		'<br/><br/>' +
                		'<a href="' + fi.LinkUrl + '">' + fi.LinkUrl + '</a>';
            
        } else if(fi.Type == 'AdvancedTextPost') {

        }
        
        return result;
    }
    
    /**
     * @description Used to correct the Expiry Date of an Announcement. We need to Future this, because the
     * Announcement may not be inserted yet at the time of the trigger.
     * 
     * @deprecated
     */
    @future
    public static void updateAnnouncementExpiry(List<Id> acgContentIds) {
        List<Id> feedItemIds = new List<Id>();
        Map<Id, Portal_Content__c> feedItemIdToPc = new Map<Id, Portal_Content__c>();
		List<Portal_Content__c> pcToUpdate = new List<Portal_Content__c>();
        
        for(Portal_Content__c pc : [SELECT Id, Tech_Feed_Item_Id__c FROM Portal_Content__c WHERE Id IN: acgContentIds AND Tech_Feed_Item_Id__c <> '']) {
            feedItemIds.add(pc.Tech_Feed_Item_Id__c);
            feedItemIdToPc.put(pc.Tech_Feed_Item_Id__c, pc);
        }

        for(Announcement a : [SELECT ExpirationDate, FeedItemId FROM Announcement WHERE FeedItemId IN: feedItemIds]) {
            if(feedItemIdToPc.get(a.FeedItemId) != null && a.ExpirationDate != null) {
                Portal_Content__c pc = feedItemIdToPc.get(a.FeedItemId);
                pc.Expiry_Date__c = a.ExpirationDate.date();
                pcToUpdate.add(pc);
            }
        }
        
        if(!pcToUpdate.isEmpty()) {
            update pcToUpdate;
        }
    }
    
    // End of Class
}