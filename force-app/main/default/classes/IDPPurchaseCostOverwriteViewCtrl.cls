public without sharing class IDPPurchaseCostOverwriteViewCtrl
{    

    public String pcId {get;set;}
    
    
    public IDPPurchaseCostOverwriteViewCtrl(ApexPages.StandardController controller) {
         pcId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {   

    List<Purchase_Cost__c> pclist = [SELECT id, Purchase_request_Item__r.Purchase_Request__c 
                    from Purchase_Cost__c
                    where id = :pcId limit 1];    

    Purchase_Cost__c pri = pclist.size()>0 ? pclist.get(0) : null;                

    return new PageReference('/apex/IDPPurchaseRequestVFP' + '?prid=' + pri.Purchase_request_Item__r.Purchase_Request__c +'&mode='+IDPPurchaseRequestCtrl.VIEW_MODE); 
    }
     
}