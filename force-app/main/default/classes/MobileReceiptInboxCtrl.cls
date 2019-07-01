/**
 * @description Controller / Data access functions for MobileReceiptInbox
 */ 
public without sharing class MobileReceiptInboxCtrl {

    private class ExpenseApplicationVO {
        public Expense_Application__c ea {get;set;}
        public List<Expense_Detail__c> edList {get;set;} {edList = new List<Expense_Detail__c>();}
        public List<ExpenseAttachmentVO> eaAttachmentList {get;set;} {eaAttachmentList = new List<ExpenseAttachmentVO>();}
    }
    
    private class ExpenseAttachmentVO {
        public String imageUrl {get;set;}
        public String fileName {get;set;}
        public String fileId {get;set;}
        public Datetime lastModifiedDate {get;set;}
    }
    
    /**
     * @description get the ID of the user's Mobile Receipt Inbox, if it doesn't exist, create one.
     */
    @RemoteAction
    public static String getMobileReceiptInbox() {
        String result = '';
        
        List<Mobile_Receipt_Inbox__c> mri = [SELECT Id FROM Mobile_Receipt_Inbox__c WHERE OwnerId =: UserInfo.getUserId()];
        
        if(mri == null || mri.isEmpty()) {
            Mobile_Receipt_Inbox__c newMri = new Mobile_Receipt_Inbox__c();
            insert newMri;
            
            result = newMri.Id;
        } else {
            result = mri[0].Id;
        }
        
        return result;
    }
    
    /**
     * @description get a list of FeedItems from MobileReceiptInbox Chatter feed
     */
    @RemoteAction
    public static List<FeedItem> getFeedItems() {
        List<FeedItem> feedItemList = new List<FeedItem>();
        Id myInbox = MobileReceiptInboxCtrl.getMyMobileReceiptInbox();
        
        if(myInbox != null) {
            List<FeedItem> inboxFeedItems = [SELECT Id, CreatedDate, RelatedRecordId, Title, Body, Type, ParentId FROM FeedItem WHERE ParentId =: myInbox AND Type = 'ContentPost'];
            if(inboxFeedItems != null && !inboxFeedItems.isEmpty()) {
                feedItemList = inboxFeedItems;
            }
        }
        
        return feedItemList;
    }
    
    /**
     * @description get my Mobile Receipt Inbox ID, e.g. a0lO00000024gqAIAQ
     */
    @RemoteAction
    public static Id getMyMobileReceiptInbox() {
        Id result;
        
        List<Mobile_Receipt_Inbox__c> mobileReceiptInboxes = 
            [
                SELECT Id 
                FROM Mobile_Receipt_Inbox__c 
                WHERE OwnerId =: UserInfo.getUserId()
                LIMIT 1
            ];
        
        if(mobileReceiptInboxes != null && !mobileReceiptInboxes.isEmpty()) {
            result = mobileReceiptInboxes[0].Id;
        }
        
        return result;
    }

    /**
     * @description get a list of expense details from my expenses
     */
    @RemoteAction
    public static List<ExpenseApplicationVO> getExpenseDetails() {
        List<Expense_Detail__c> expenseDetailsList = new List<Expense_Detail__c>();
        //List<Expense_Application__c> myExpenses = MobileReceiptInboxCtrl.getExpenses();
        
        Map<String, ExpenseApplicationVO> eaVOMap = new Map<String, ExpenseApplicationVO>();
        List<String> eaOrderedKeys = new List<String>();
        List<ExpenseApplicationVO> eaVOList = new List<ExpenseApplicationVO>();
        
            // Get the Core Data first

            for(Expense_Application__c ea :
                [
                    SELECT Id, Remarks__c, toLabel(Status__c), Name, CreatedDate, (
                        	SELECT Id, Name, Amount__c, Receipt_Currency__r.Name, Description__c, Exchange_Rate__c, Receipt_Date__c, Local_Amount__c, toLabel(Status__c), Expense_Type__r.Name
                        	FROM Expense_Details__r
                        	WHERE (Status__c = 'NS' OR Status__c = 'DF')
                        )
                    FROM Expense_Application__c
                    WHERE OwnerId =: UserInfo.getUserId()
                	ORDER BY Name DESC
                    LIMIT 30
                ])
            {
                if(ea.Expense_Details__r != null && !ea.Expense_Details__r.isEmpty()) {
                    ExpenseApplicationVO eaVO = new ExpenseApplicationVO();
                    eaVO.ea = ea;
                    eaVOMap.put(ea.Id, eaVO);
                    
                    eaOrderedKeys.add(ea.Id);
                }
            }
            
            // Now get the Attachments
            for(Attachment a : 
                [
                    SELECT Id, Name, ParentId, BodyLength, LastModifiedDate 
                    FROM Attachment 
                    WHERE parentid IN: eaVOMap.keySet()
                    ORDER BY lastModifiedDate DESC
                ]) 
            {
				ExpenseApplicationVO eaVO = eaVOMap.get(a.ParentId);
                ExpenseAttachmentVO eAttVO = new ExpenseAttachmentVO();
                eAttVO.fileName = a.Name;
                eAttVO.fileId = a.Id;
                //eAttVO.imageUrl = a.Id;
                eAttVO.lastModifiedDate = a.lastModifiedDate;
                eaVO.eaAttachmentList.add(eAttVO);
            }
            
        for(String s : eaOrderedKeys) {
            eaVOList.add(eaVOMap.get(s));
        }
        
        return eaVOList;
    }
    
    /**
     * @description get my expenses
     */
    private static List<Expense_Application__c> getExpenses() {
        List<Expense_Application__c> result;
        
        List<Expense_Application__c> expenses = 
            [
                SELECT Id
                FROM Expense_Application__c
                WHERE OwnerId =: UserInfo.getUserId()
            ];
        
        if(expenses != null && !expenses.isEmpty()) {
            result = expenses;
        }
        
        return result;
    }
    
    /**
     * @description get a list of expense details ID from my expenses
     */
    private static List<Expense_Detail__c> getExpenseDetailsId() {
        List<Expense_Detail__c> expDetailsIdList = new List<Expense_Detail__c>();
        List<Expense_Application__c> myExpenses = MobileReceiptInboxCtrl.getExpenses();
        if(myExpenses != null) {
            List<Expense_Detail__c> expDetailsIds = 
            [
                SELECT Id FROM Expense_Detail__c WHERE Expense_Application__C IN :myExpenses
                AND (Status__c = 'NS' OR Status__c = 'DF')
                ORDER BY Expense_Application__r.Name DESC
            ];
            if(expDetailsIds != null && !expDetailsIds.isEmpty()) {
                expDetailsIdList = expDetailsIds;
            }
        }
        
        return expDetailsIdList;
    }

    /**
     * @description get a list of FeedItem from expense details Chatter feed
     */
    @RemoteAction
    public static List<Expense_Detail__Feed> getExpenseDetailsFeedItems() {
        List<Expense_Detail__Feed> feedItemList = new List<Expense_Detail__Feed>();
        List<Expense_Detail__c> expDetailsIdList = MobileReceiptInboxCtrl.getExpenseDetailsId();
        if(expDetailsIdList != null && !expDetailsIdList.isEmpty()) {
            List<Expense_Detail__Feed> expDetailsFeedItems = 
            [
                SELECT Id, CreatedDate, RelatedRecordId, Title, Body, Type, ParentId 
                FROM Expense_Detail__Feed 
                WHERE ParentId IN :expDetailsIdList AND Type = 'ContentPost' 
            ];
            if(expDetailsFeedItems != null && !expDetailsFeedItems.isEmpty()) {
                feedItemList = expDetailsFeedItems;
            }
        }
        
        return feedItemList;
    }
    
    static FeedItem feedItemToUpdate;
    
    /**
     * @description delete FeedItem specified by getId from mobile receipt inbox Chatter feed and insert a cloned one to expense detail Chatter feed specified by parentId
     */
    @RemoteAction
    public static FeedItem setParentId(String getId, String parentId) {
        // Update account
        FeedItem tempItem;
        FeedItem feedItem = [select Id, ParentId, Title, Body, ContentDescription, RelatedRecordId, Type,
                                  ContentSize, ContentType, HasContent, HasLink, InsertedById, LinkUrl, Revision, CreatedById
                                  from FeedItem where Id=:getId LIMIT 1];
        tempItem=feedItem.clone(false,false);
        tempItem.ContentDescription = null;
        tempItem.parentId = parentId;
        if(feedItem.Revision > 1) {
            tempItem.lasteditbyid = feedItem.CreatedById;
            tempItem.LastEditDate = System.Now();
        }
        insert tempItem;
        delete feedItem;
        return tempItem;
    }
    
}