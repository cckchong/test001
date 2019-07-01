/*
    LibraryRecentItemsComponentCtrl Class
    Controller of library recent items component
*/
public without sharing class LibraryRecentItemsComponentCtrl {

	public String recordTypeName{get;set;}  
  	public Integer numItems{get;set;}
    
    public Map<String, Attachment> MostBorrowedPhotoMap {get;set;} { MostBorrowedPhotoMap = new Map<String, Attachment>(); }
  	public Map<String, Attachment> itemToPhotoMap {get;set;} { itemToPhotoMap = new Map<String, Attachment>(); }
  	public List<Library_Item__c> itemList {get;set;} { itemList = new List<Library_Item__c>(); }
  
    public Map<Id, Integer> MostBorrowedFeedMap {get;set;} { MostBorrowedFeedMap = new Map<Id, Integer>(); }
  	public Map<Id, Integer> libraryItemToFeedMap {get;set;} { libraryItemToFeedMap = new Map<Id, Integer>(); }
 	public boolean isSalesforceOne{get;set;}{isSalesforceOne = SystemUtil.isMobileDevice();}

	
	/*
		NickWu 23 Mar 2015
		Used to initialize the attachment associated with library item id
	*/
	public void initAttachment(List<ID> itemList, Map<String, Attachment> itemToPhotoMap){
		if(itemList!=null && !itemList.isEmpty()) {
			for(Attachment a : 
	        [SELECT Id, ParentId FROM Attachment 
	                WHERE ParentId IN: itemList AND (ContentType LIKE: Label.Library_Image_Format_JPEG OR 
	                                                 ContentType LIKE: Label.Library_Image_Format_GIF OR 
	                                                 ContentType LIKE: Label.Library_Image_Format_PNG)
	                ORDER BY CreatedDate
	             ]) {
	           
	             if(itemToPhotoMap.get(a.ParentId) == null) {
	               itemToPhotoMap.put(a.ParentId, a);
	             }
	           }
	           
	           for(ID li : itemList) {
	             if(itemToPhotoMap.get(li) == null) {
	               itemToPhotoMap.put(li, new Attachment());
	             }
	           }
	    }
	}
	
	/*
		NickWu 23 Mar 2015
		Used to retrieve all most borrowed library items
	*/
	public List<Library_Inventory__c> getMostBorrowedList(){
		//get the global custom settings for display size
		Integer num = Integer.valueOf(Label.Library_Recently_Item_Size);
		
		//get top 5 most borrowed inventory ids, filter: category = record type, status not equals to Not Submitted
		list<AggregateResult> itemlist = [
			SELECT Library_Request_Inventory__c
			FROM library_Item_request__c
			where 
			Item_Category_DevelopName__c =:recordTypeName AND
			Status__c <>: Label.Library_Request_Status_Not_Submitted
			GROUP BY Library_Request_Inventory__c
			order by COUNT(Library_Request_Inventory__c) desc
			LIMIT :num
		];
		
		List<ID> strList = new List<String>();
		for(AggregateResult ar : itemlist){
			strList.add( (String)ar.get('Library_Request_Inventory__c'));
        }
		
		List<Library_Inventory__c> borrowedList = [
			SELECT Library_Item_Master__c, Library_Item_Master__r.id, Library_Item_Master__r.name, Library_Item_Master__r.Book_Author__c, Library_Item_Master__r.Item_Name__c  From Library_Inventory__c where id IN: strList
		];
		
		List<ID> itemIDlist = new List<ID>();
		for(Library_Inventory__c li : borrowedList){
			itemIDlist.add(li.Library_Item_Master__r.id);
		}
		
		initFeedItems(itemIDlist);
		initAttachment(itemIDlist,itemToPhotoMap);
		
		return borrowedList;
	}

 /*
     NickWu added on 12 Dec 2014
     to pass parameters to query the items from Library_Item__c
     @recordTypeName -- RecordTypeName
     @numItems  -- # of items will be displayed
 */
	  public List<Library_Item__c> getList(){
	  
	      numItems = Integer.valueOf(Label.Library_Recently_Item_Size);
	
	      //set itemList
	      itemList = 
	      [
	        SELECT Id, Item_Name__c, Item_Description__c, Book_Author__c FROM Library_Item__c
	        WHERE RecordType.DeveloperName = :recordTypeName
	        AND Can_Be_Borrowed__c = true
	        ORDER BY CreatedDate DESC
	        LIMIT :numItems
	      ];
	      
	      //set itemToPhotoMap if itemList not empty
	      if(!ErrorUtils.isEmpty(itemList)) {
	      for(Attachment a : 
	        [SELECT Id, ParentId FROM Attachment 
	                WHERE ParentId IN: itemList AND (ContentType LIKE: Label.Library_Image_Format_JPEG OR 
	                                                 ContentType LIKE: Label.Library_Image_Format_GIF OR 
	                                                 ContentType LIKE: Label.Library_Image_Format_PNG)
	                ORDER BY CreatedDate
	             ]) {
	           
	             if(itemToPhotoMap.get(a.ParentId) == null) {
	               itemToPhotoMap.put(a.ParentId, a);
	             }
	           }
	           
	           for(Library_Item__c li : itemList) {
	             if(itemToPhotoMap.get(li.Id) == null) {
	               itemToPhotoMap.put(li.Id, new Attachment());
	             }
	           }
	    }
	    List<Id> itemIdList = new List<Id>();
	    for(Library_Item__c li : itemList) {
	        itemIdList.add(li.Id);
	    }
	    initFeedItems(itemIdList);
	    return itemList;
	  }
	  
	  //initial Feeds associated with library item
	  private void initFeedItems(List<Id> libraryItemIdList) {
	    for(Id li : libraryItemIdList) {
	        this.libraryItemToFeedMap.put(li, 0);
	    }
	    
	    for(FeedItem f : [SELECT Id, ParentId FROM FeedItem WHERE ParentId IN: libraryItemIdList]) {
	        Integer commentCount = this.libraryItemToFeedMap.get(f.ParentId);
	        commentCount++;
	        this.libraryItemToFeedMap.put(f.ParentId, commentCount);
	    }
	  }  
}