public without sharing class IDPPurchaseOrderLineCtrl{
   
    Public Purchase_Order_Item__c poi {get;set;}
    Public Decimal receivedQuantity {get;set;}
    Public Boolean isChecked {get;set;} 
    Public Boolean isDelivered {set;}
    //Public Boolean isExceededToleranceLevel {set;}
    Public Boolean isExceededOrderedQuantity {set;} 
    Public Boolean isReduceReceivedQuantity {set;} 
    Public Boolean isLessThanMoq {set;}
    Public Decimal moq {set;}

    //Public Boolean isDeliveried {set;}
    //Public Boolean isCancel {set;}

    Private IDPPurchaseOrderCtrl poCtrl;
    //Public IDPPurchaseOrderActionCtrl poAction;
    Public String leadTime{set;}
    
        
    Public IDPPurchaseOrderLineCtrl(Purchase_Order_Item__c poi, IDPPurchaseOrderCtrl poCtrl){
        this.poCtrl = poCtrl;
        this.poi = poi;
        this.isChecked = false;
        this.receivedQuantity = poi.Received_Quantity__c;
        this.receivedQuantity.setScale(0);
    }    
    
    //Delete a specific POI and put the related PRI back to the available PRI pool
    Public void removeSinglePOIAction() {
        
        List<IDPPurchaseOrderLineCtrl> tempPOLineList = new List<IDPPurchaseOrderLineCtrl>(); 
        this.poCtrl.poAction.removeSinglePOIAction(this);
        
        if(!this.poCtrl.isDisplayedMessage) {
            this.poCtrl.po = this.poCtrl.poInit.getPO(this.poCtrl.po.Id);
            tempPOLineList = this.poCtrl.POLineList.clone();
            this.poCtrl.POLineList.clear();
            
            if(tempPOLineList.size() > 1) {
                for(Purchase_Order_Item__c reader : this.poCtrl.po.Purchase_Order_Items__r) {
                    this.poCtrl.POLineList.add(new IDPPurchaseOrderLineCtrl(reader, this.poCtrl)); 
                }
            }         
        }       
    }
    
    Public void preInputReceivedQtyAction() {
        this.poCtrl.poAction.preInputReceivedQtyAction(this);
    }
    
    public boolean getisDelivered(){
        return poi.Status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_DELIVERED;
    }
    
    /*public Boolean getisExceededToleranceLevel(){
    
        Double newPrice = this.poi.Price__c;
        Double acceptableUpperLimit = this.poi.Tech_Price__c *(1 + this.poCtrl.po.Delivery_Site__r.Tolerance_Level__c / 100);
        Double acceptableLowerLimit = this.poi.Tech_Price__c *(1 - this.poCtrl.po.Delivery_Site__r.Tolerance_Level__c / 100);

        return (newPrice > acceptableUpperLimit || newPrice < acceptableLowerLimit);
    }*/
    
    Public Boolean getisExceededOrderedQuantity(){
        return (this.receivedQuantity > this.poi.Quantity__c);
    }
    
    Public Boolean getisReduceReceivedQuantity(){
        return (this.receivedQuantity < this.poi.Received_Quantity__c);
    }
        
    Public void applyDeliveredDate(){
        this.poCtrl.poAction.applyDeliveredDate(this);
    }    

    Public Decimal getMoq() {

        if (poCtrl.catalogItemSupplierSourceMap.containsKey(poi.Catalog_Item__c)) {
           
           Map<String, Supplier_Item__c> siMap = poCtrl.catalogItemSupplierSourceMap.get(poi.Catalog_Item__c);
            
            if (siMap.containsKey(poi.Supplier__c)) {
                return siMap.get(poi.Supplier__c).Minimum_Order_Quantity__c;
            }
        }

        return 0;
    }

    Public String getLeadTime() {

        String leadTime = '';

        if (poCtrl.catalogItemSupplierSourceMap.containsKey(poi.Catalog_Item__c)) {
            Map<String, Supplier_Item__c> siMap = poCtrl.catalogItemSupplierSourceMap.get(poi.Catalog_Item__c);

            if (siMap.containsKey(poi.Supplier__c)) {
                Supplier_Item__c si = siMap.get(poi.Supplier__c);

                if (si.Lead_Time_Days__c != null && String.isNotEmpty(si.Lead_Time_Format__c))
                    leadTime = Integer.valueOf(si.Lead_Time_Days__c) + ' ' + si.Lead_Time_Format__c + '(s)';
            }                
        }

        return leadTime;
    }

    Public Boolean getIsLessThanMoq(){

        Decimal moq = getMoq();
        Decimal totalQty = 0;

        for(Purchase_Order_Item__c tempPoi : poCtrl.po.Purchase_Order_Items__r){
            if (tempPoi.Catalog_Item__c == poi.Catalog_Item__c) {
                totalQty += tempPoi.Quantity__c;
            }
        }

        return totalQty < moq;
    }

    //Original Delivered Function is removed on 04/01/2017 i.e. once clicked, the POI status will change to delivered even the total receiving qty < ordered qty
    //Cancel POI function is removed on 04/01/2017
    /*
    
    //Original Delivered Function 
    public boolean getisDeliveried(){
        return poi.Status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_DELIVERED;
    }
    Public void deliveriedPOI(){
        system.debug('calling');
        this.poCtrl.poAction.deliveriedPOI(this);
    }    
    
    //Cancel POI function    
    public boolean getisCancel(){
        return poi.Status__c ==  IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CANCEL;
    }  
    Public void cancelPOI(){
        this.cpoCtrl.poAction.cancelPOI(this);
    }
    */
}