public without sharing class IDPCreatePurchaseOrderLineCtrl{

    Public Boolean isChecked {get;set;}
    Private IDPCreatePurchaseOrderCtrl cpoCtrl;
    Public Purchase_Request_Item__c pri {get;set;}
    
    Public IDPCreatePurchaseOrderLineCtrl(Purchase_Request_Item__c pri, IDPCreatePurchaseOrderCtrl cpoCtrl){
        
        this.cpoCtrl = cpoCtrl;
        this.pri = pri;
        this.isChecked = false;
    }
    
    Public void cancelPurchaseRequestItemAction() {
        this.cpoCtrl.cpoAction.cancelPurchaseRequestItemAction(pri.Id);
    }
}