public without sharing class IDPPurchaseRequestItemOverwriteViewCtrl
{    

    public String priId {get;set;}
    
    
    public IDPPurchaseRequestItemOverwriteViewCtrl(ApexPages.StandardController controller) {
         priId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {   

		List<Purchase_Request_Item__c> priList = [SELECT id, Purchase_request__c 
										from Purchase_Request_Item__c
										where id = :priId limit 1];    

		Purchase_Request_Item__c pri = priList.size()>0 ? priList.get(0) : null;								

		return new PageReference('/apex/IDPPurchaseRequestVFP' + '?prid=' + pri.Purchase_Request__c +'&mode='+IDPPurchaseRequestCtrl.VIEW_MODE); 
    }
     
}