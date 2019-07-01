public without sharing class IDPPurchaseRequestOverwriteViewCtrl
{    

    public String textId{get;set;}
    
    
    public IDPPurchaseRequestOverwriteViewCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {        return new PageReference('/apex/IDPPurchaseRequestVFP' + '?prid=' + textId +'&mode='+IDPPurchaseRequestCtrl.VIEW_MODE); 
    }
     
}