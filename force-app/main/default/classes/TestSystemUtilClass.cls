@isTest
private class TestSystemUtilClass {

    static testMethod void myUnitTest() {
        
        User u = SystemUtil.getCurrentUserInfo();
        
        String groupName = 'Test Group' + TestClassUtil.generateRandomString();
        
        CollaborationGroup chatterGroup = TestClassUtil.getChatterGroup();
		chatterGroup.Name = groupName;
		try {
			insert chatterGroup;
		} catch (exception ex) {
			//chatterGroup = [Select Id, Name From CollaborationGroup Where Name = :groupName limit 1];
		}	
		
        List<FeedItem> listTextPostToCreate = new List<FeedItem>(); 
        FeedItem TextPost = TestClassUtil.getChatterTextPost();
        TextPost.ParentId=chatterGroup.Id;
        listTextPostToCreate.add(TextPost);
        FeedItem TextPost2 = TestClassUtil.getChatterTextPost();
        TextPost2.Title='Hello 2';
        TextPost2.ParentId=chatterGroup.Id;
        listTextPostToCreate.add(TextPost2);
        insert listTextPostToCreate;
        
        List<Portal_Content__c> listToCreate = new List<Portal_Content__c>();        
        Portal_Content__c announcement = TestClassUtil.getAnnouncement();
        listToCreate.add(announcement);
        
        Portal_Content__c HTMLSiteMap = TestClassUtil.getHTML();
        HTMLSiteMap.System_Setting__c ='SiteMap';	        
        listToCreate.add(HTMLSiteMap);
        
        Portal_Content__c HTMLBlank = TestClassUtil.getHTML();
        HTMLBlank.System_Setting__c ='BlankHTML';	        
        listToCreate.add(HTMLBlank);
        insert listToCreate;        
        
        Attachment att = new Attachment(
        	Name='Test.jpg',
        	ParentId=announcement.Id,
        	Body=EncodingUtil.base64Decode('fluffykittens'),
        	ContentType='image');
        insert att;
                
		String returnString1 = SystemUtil.DMLUpdate(announcement);
		System.assertEquals('', returnString1);
		announcement.Sub_Category__c = null;
		String returnString2 = SystemUtil.DMLUpdate(announcement);
		//System.assertEquals('You must define a Distribution Site!', returnString2);
		
		String returnString3 = SystemUtil.getSiteMapId();
		System.assertEquals(HTMLSiteMap.Id, returnString3);
		String returnString4 = SystemUtil.getBlankHTMLId();
		System.assertEquals(HTMLBlank.Id, returnString4);
		
		//Portal_Content__c returnPC = SystemUtil.PortalContentDetermineLang(announcement, 'zhhk');
		
		Map<Id, String> mapId2PicUrl = new Map<Id, String>();
	    mapId2PicUrl.put(announcement.Id, '/test.png');
	    //ACGArticleWrapper ann1 = new ACGArticleWrapper(announcement, mapId2PicUrl);
	    //ann1 = SystemUtil.ArticleWrapperDetermineLang(ann1, 'zhhk');
	    
	    Set<Id> setIds = new Set<Id>();
	    setIds.add(chatterGroup.Id);
	    Map<Id, List<FeedItem>> returnMap3 = SystemUtil.getChatterFeeds(setIds);
	    System.assertEquals(1, returnMap3.size());
	    System.assertEquals(2, returnMap3.get(chatterGroup.Id).size());
	    
	    Set<Id> setIdsAtt = new Set<Id>();
	    setIdsAtt.add(announcement.Id);	    
	    Map<Id, String> returnMap4 = SystemUtil.getArticleThumbnail(setIdsAtt);
	    System.assertEquals(att.Id, returnMap4.get(announcement.Id));	    
	    
	    Map<String, String> returnMap5 = SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Language__c');
	    
	    
	    Profile p = SystemUtil.getCurrentUserProfile();
	    //
	    List<String> strLangs = SystemUtil.getPicklistValues('Portal_Content__c', 'Language__c');
	    
	    List<String> strs = SystemUtil.availRecordTypes ('Portal_Content__c', true);
	    System.assertEquals(5, strs.size());
	    strs = SystemUtil.availRecordTypes ('Portal_Content__c', false);
	    System.assertEquals(5, strs.size());
	    
	    List<SelectOption> selectOptions = SystemUtil.availRecordTypesSO('Portal_Content__c');
	    System.assertEquals(5, selectOptions.size());
	    
	    Boolean bMobile = SystemUtil.isMobileDevice();
	    System.assertEquals(false, bMobile);
	    
	    List<Portal_Content__c> pcs = new List<Portal_Content__c>();
	    Portal_Content__c pc = new Portal_Content__c();
	    SystemUtil.SafeInsert(pc);
	    SystemUtil.SafeInsert(pcs);
	    SystemUtil.SafeUpdate(pc);
	    SystemUtil.SafeUpdate(pcs);
	    String strDMLUpdate = SystemUtil.DMLUpdate(pcs);
	    strDMLUpdate = SystemUtil.DMLUpdate(pc);    
	    SystemUtil.SafeDelete(pc);
	    SystemUtil.SafeDelete(pcs);
    }
    
    static testMethod void testEmployeeCheck() {
		System.assertEquals(SystemUtil.getUserEmployeeMatch(), false);    
    }
}