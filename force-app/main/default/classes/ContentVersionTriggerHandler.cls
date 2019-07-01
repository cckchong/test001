public without sharing class ContentVersionTriggerHandler {
    
    /**
     * Purely for DMS
     */
    
    public static void defaultShare(ContentVersion[] cvL) {
        try {
            List<Id> cdlList = new List<Id>();
            for (ContentVersion cv : cvL) {
                if(cv.Description != null && cv.Description.startsWith('Quickr: /')) {
                    cdlList.add(cv.ContentDocumentId);
                }
            }
            
            ContentVersionTriggerHandler.createShareFuture(cdlList);
            
        } catch (Exception e) { } 
    }
    
    @future
    public static void createShareFuture(List<Id> contentDocumentList) {
        String userId = DMS_Settings__c.getValues('manager_user').Value__c;
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        
        for (Id cd : contentDocumentList) {
            cdlList.add(
                new ContentDocumentLink(
                    LinkedEntityId = userId,
                    ContentDocumentId = cd,
                    ShareType = 'C'
                )
            );
        }
        
        insert cdlList;
    }
}