public without sharing class LibraryItemPageHitRateExtension{
    
    
    private String TARGET_FUNCTION = Label.Library_Hit_Rate_Target_Function;
    Public Id itemId {get;set;}
    public LibraryItemPageHitRateExtension(ApexPages.StandardController controller) {
        itemId = controller.getId();
    }

    Public void updateCounter() {
        
        String userId = '';
        Library_item__c item = null;
        User currentUser = null;
        userId = UserInfo.getUserId();
        if(!String.isBlank(userId)) {
            currentUser = [SELECT Id, Function_short__c FROM User WHERE Id = :userId];
        }
        if(currentUser != null) {
            if(currentUser.Function_short__c  == TARGET_FUNCTION) {
                if(itemId != null) {
                    item = [SELECT Id, Record_View_Count__c FROM Library_Item__c WHERE Id = :itemId LIMIT 1];
                }
                
                if(item != null) {
                    if(item.Record_View_Count__c == null) {
                        item.Record_View_Count__c = 0;
                    }
                    item.Record_View_Count__c ++;
                    update item;
                }
            }
        }

       
    }
}