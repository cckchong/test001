public without sharing class IDPPurchaseOrderResultCtrl{

    Public String batchid {get;set;}
    Public List<Purchase_Order__c> POList {get;set;}
    
    
    Public IDPPurchaseOrderResultCtrl(){
        batchid = ApexPages.currentPage().getParameters().get('bid');
        if( String.isBlank(batchid)){
            POList = new List<Purchase_Order__c>();
        }
        else{
            POList = getPOs(batchid);
        }
    }
    
    Public List<Purchase_Order__c> getPOs(String bid){
        List<Purchase_Order__c> POs = new List<Purchase_Order__c>();
        for(Purchase_Order__c PO :[select id, Name, cost_center__c, 
                                   Currency__r.Name, Estimated_Total_Price__c
                                   from Purchase_Order__c
                                   where Batch_ID__c = :bid
                                  ]){
            POs.add(po);
        }
        
        return POs;
    }
    
    Public PageReference backAction(){
        return new PageReference ('/apex/IDPCreatePurchaseOrderVFP');
    }
}