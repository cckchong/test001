public without sharing class IDPPurchaseRequestOverwriteNewCtrl{    
    /**
     * @description contructor with StandardController
     */
    public IDPPurchaseRequestOverwriteNewCtrl(ApexPages.StandardController controller) {
         
    }
    
    public PageReference redirect() {
    
        return new PageReference(Label.IDP_Path_IDPShoppingCartVFP);
    }

}