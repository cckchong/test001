public without sharing class IDPPurchaseOrderOverwriteViewCtrl
{    

    public String textId{get;set;}
    
    
    public IDPPurchaseOrderOverwriteViewCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {        
    
        return new PageReference(Label.IDP_Path_IDPPurchaseOrderVFP + '?' + Label.IDP_Path_Parameter_POId + '=' + textId + '&' + Label.IDP_Path_Parameter_Mode + '=' + IDPPurchaseOrderCtrl.VIEW_MODE);
    }
     
}