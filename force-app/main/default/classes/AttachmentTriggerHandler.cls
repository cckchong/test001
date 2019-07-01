/**
 * AttachmentTriggerHandler
 * @description assist attachment trigger
 */
public without sharing class AttachmentTriggerHandler {
    
    /**
     * @description update Tech_Thumbnail_Id in Library_Item__c 
     */
	public static void updateThumbnailId(List<Attachment> attachments, String action)
	{		
		//Get keyPrefix
		Schema.DescribeSObjectResult r = Library_Item__c.sObjectType.getDescribe();
		String keyPrefix = r.getKeyPrefix();
		List<Library_Item__c> libItemLists= new List<Library_Item__c>();
		Set<Id> libItemIds = new Set<Id>();
		Map<Id, Library_Item__c> mapLibItems = new Map<Id, Library_Item__c>();
		
		Map<Id, Id> mapLibItemImageIds = new Map<Id, Id>();
		Set<Id> attIds = new Set<Id>();
		//Only 'Delete' action need to query the Tech_Thumbnail_Id__c of existing record
		if(action == 'Delete')
		{
			for(Attachment a:attachments)
			{
			    //if Parent Object is Library_Item__c
			    if(String.Valueof(a.ParentId).substring(0,3) == keyPrefix)
			    {
			    	libItemIds.add(a.ParentId);
			    	attIds.add(a.Id);
			    }
			}			
			for(Library_Item__c libItem: [Select Id, Name, Tech_Thumbnail_Id__c From Library_Item__c Where Id IN:libItemIds])
			{
				mapLibItems.put(libItem.Id, libItem);
			}
			//Map to get Id of other images of the Item in case the image deleted is the primary image
			for(Attachment a: [Select Id, ParentId From Attachment Where ParentId IN:libItemIds And Id NOT IN:attIds Order by CreatedDate]) {
				mapLibItemImageIds.put(a.ParentId, a.Id);
			}
		}			
		
		for(Attachment a:attachments)
		{
		    //if Parent Object is Library_Item__c
		    if(String.Valueof(a.ParentId).substring(0,3) == keyPrefix)
		    {
		    	//if the attachment type is image
		    	if(a.ContentType == 'image/png' || a.ContentType == 'image/jpeg')
		    	{
		    		Library_Item__c li = new Library_Item__c(Id=a.ParentId);
			    	if(action == 'Insert' || action == 'Update' )
			    	{
			    		li.Tech_Thumbnail_Id__c = a.Id;
			    	}
			    	else if(action == 'Delete')
			    	{
			    		//if the deleted attachment is the current image
			    		if(mapLibItems.containskey(a.ParentId))
			    		{
			    			if(mapLibItems.get(a.ParentId).Tech_Thumbnail_Id__c == a.Id)
				    		{
				    			//li.Tech_Thumbnail_Id__c = '';
				    			if(mapLibItemImageIds.containsKey(a.ParentId)) {
				    				li.Tech_Thumbnail_Id__c = mapLibItemImageIds.get(a.ParentId);
				    			} else {
				    				li.Tech_Thumbnail_Id__c = '';
				    			}
				    		}
			    		}				    					    		
			    	}
			        libItemLists.add(li);
		    	}			    	
		    }
		}		
		SystemUtil.DMLUpdate(libItemLists);
	}
    
    /**
     * @description update isAttachment in Expense_Detail__c
     */
    public static void checkIsAttachment(Map<Id, Attachment> oldAttachmentMap, List<Attachment> newAttachmentList, boolean isDelete) {
        
        //Get keyPrefix
        Schema.DescribeSObjectResult r = Expense_Detail__c.sObjectType.getDescribe();
		String keyPrefix = r.getKeyPrefix();
        Map<Id, Integer> AttachmentCountMap = new Map<Id, Integer>();
        Map<Id, Attachment> ExpenseDetailIdAttachmentMap = new Map<Id, Attachment>();
        List<Id> updateExpenseDetailIdList = new List<Id>();
        Map<Id, AggregateResult> existExpenseDetailIdMap = new Map<Id, AggregateResult>();
        List<Expense_Detail__c> updateExpDetailList = new List<Expense_Detail__c>(), updatedExpDetailList = new List<Expense_Detail__c>();
        if (isDelete) {
            // Delete: check if there is no attachment, isAttachment = false
            for (Attachment am : oldAttachmentMap.values()) {
                //if Parent Object is Expense_Detail__c
                if(String.Valueof(am.ParentId).substring(0,3) == keyPrefix)
                {
                    ExpenseDetailIdAttachmentMap.put(am.ParentId, am);
                }
            }
            // check whether attachment still exists in related expense details
            for (AggregateResult am : [select ParentId, count(Id) count_id from Attachment where ParentId IN :ExpenseDetailIdAttachmentMap.keySet() and isDeleted = false group by ParentId]) {
                existExpenseDetailIdMap.put((ID) am.get('ParentId'), am);
            }
            // filter out those expense details without any attachments
            for (Id key : ExpenseDetailIdAttachmentMap.keySet()) {
                if (!existExpenseDetailIdMap.containsKey(key)) {
            		updateExpenseDetailIdList.add(key);
                } else {
                    if ((Integer) ((existExpenseDetailIdMap.get(key)).get('count_id')) == 1) {
                        updateExpenseDetailIdList.add(key);
                    }
                }
            }
            // update expense details
            for (Expense_Detail__c ed : [select Id, With_Attachment__c from Expense_Detail__c where Id IN :updateExpenseDetailIdList]) {
                ed.With_Attachment__c = false;
                updatedExpDetailList.add(ed);
            }
            update updatedExpDetailList;
        } else {
            // Insert: withAttachment = true
            for (Attachment am : newAttachmentList) {
                //if Parent Object is Expense_Detail__c
                if(String.Valueof(am.ParentId).substring(0,3) == keyPrefix)
                {
                    ExpenseDetailIdAttachmentMap.put(am.ParentId, am);
                }
            }
            // update expense details
            for (Expense_Detail__c ed : [select Id, With_Attachment__c from Expense_Detail__c where Id IN :ExpenseDetailIdAttachmentMap.keySet()]) {
                ed.With_Attachment__c = true;
                updateExpDetailList.add(ed);
            }
            update updateExpDetailList;
        }
    }
	
}