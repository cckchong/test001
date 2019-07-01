public without sharing class IDPPurchaseOrderItemOverwriteViewCtrl
{    

    public String textId{get;set;}
    
    
    public IDPPurchaseOrderItemOverwriteViewCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {        
    
        List<Purchase_Order_Item__c> poiList = [SELECT id, Purchase_Order__c 
                                                FROM Purchase_Order_Item__c
                                                WHERE id = :textId limit 1];      
                                                
        Purchase_Order_Item__c poi = poiList.size()>0 ? poiList.get(0) : null;    
                    
        return new PageReference(Label.IDP_Path_IDPPurchaseOrderVFP + '?' + Label.IDP_Path_Parameter_POId + '=' + poi.Purchase_Order__c  + '&' + Label.IDP_Path_Parameter_Mode + '=' + IDPPurchaseOrderCtrl.VIEW_MODE);
    }
     
}