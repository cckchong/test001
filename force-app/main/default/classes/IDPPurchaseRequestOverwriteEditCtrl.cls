public without sharing class IDPPurchaseRequestOverwriteEditCtrl
{    

    public String textId{get;set;}
    
    
    public IDPPurchaseRequestOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {        return new PageReference('/apex/IDPPurchaseRequestVFP' + '?prid=' + textId +'&mode='+IDPPurchaseRequestCtrl.SAVE_MODE); 
    }
     
}