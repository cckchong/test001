public without sharing class IDPPurchaseRequestLineCtrl{

    Public Boolean isAddAction{set;}
    Public Boolean isDelAction{set;}
    Public Boolean isCostItem{set;get;}
    Public String receivedQuantityString {get;set;}
    Public Double receivedQuantity {get { return Double.valueOf(receivedQuantityString);}set;}
    Public Boolean isValidReceivedQuantity {set;}
    Public Boolean isLessThanMOQ {set;}
    Public String supplierId{set;}
    Private IDPPurchaseRequestCtrl prCtrl;
    Private IDPPurchaseRequestLineCtrl prLineCtrl;
    Public String PRItemID{set;get;}
    Public String PCID{set;get;}
    Public String currencyId {get;set;}   
    Private String PRID;
    Private Integer len = 18;
    Public Purchase_Request_Item__c pri{set;get;}
    Public Purchase_Cost__c pc {set;get;}
    Public List <selectOption> supppliertList {get;set;}
    Public Decimal supplierTax{set;get;}
    Public Decimal priAmount{set;get;}
    Public Boolean isTax{set;}
    Public Decimal moq = 0;
    Public Set<String> last3OrderedSupplier{set;}
    Public String leadTime{set;}
    
    Public IDPPurchaseRequestLineCtrl(Purchase_Request_Item__c pri, IDPPurchaseRequestCtrl prCtrl){
        this.pri = pri;
        this.currencyId = pri.currency__c;
        this.receivedQuantityString = String.valueOf(pri.Received_Qty__c);
        this.PRID = pri.Purchase_Request__c;
        this.PRItemID = pri.id;
        this.prCtrl = prCtrl;
        this.supppliertList = new List <selectOption>();
        this.isCostItem = false;
        //this.supplierId = pri.supplier__c;
        if(pri.Catalog_Item__c != null){
            for(Supplier_Item__c reader : prCtrl.SupplierItemMap.get(pri.Catalog_Item__c)){
                if(reader.supplier__c != null  && pri.supplier__c != reader.supplier__c){
                    supppliertList.add(new selectOption(reader.supplier__c, reader.supplier__r.Name + ' (Tax: ' + reader.supplier__r.Tax__c + '%)'));
                }
            }
            if(!String.isBlank(pri.supplier__c)){
                supppliertList.add(new selectOption(pri.supplier__c, pri.supplier__r.Name + ' (Tax: ' + pri.supplier__r.Tax__c + '%)'));
            }
        }
        else{
            this.isCostItem = true;
        }

        if(pri.Supplier__c != null){
            this.supplierTax = prCtrl.supplierMap.get(pri.Supplier__c).Tax__c;
        }
    }
    
    Public IDPPurchaseRequestLineCtrl(Purchase_Request__c pr, IDPPurchaseRequestCtrl prCtrl){
        this.PRID = pr.id;
        this.pri = new Purchase_Request_Item__c (Purchase_Request__c = pr.id, Quantity__c = 1);
        this.PRItemID = generateRandomString(len);
        this.prCtrl = prCtrl;
        this.isCostItem = true;
        this.receivedQuantity = 0;
    }
     
              
    //Public IDPPurchaseRequestLineCtrl(Purchase_cost__c pc, Purchase_Request_Item__c pri, IDPPurchaseRequestCtrl prCtrl){
    Public IDPPurchaseRequestLineCtrl(IDPPurchaseRequestLineCtrl prLineCtrl){
        this.PRID = prLineCtrl.PRID;
        this.PRItemID = prLineCtrl.PRItemID;
        this.PCID = generateRandomString(len); 
        this.prCtrl = prLineCtrl.prCtrl;
        this.supppliertList = prLineCtrl.supppliertList;
        //supplierId = prLineCtrl.supplierId;
        //this.pc = new Purchase_cost__c (Purchase_Request_Item__c = prLineCtrl.PRItemID, Supplier__c = prLineCtrl.supplierId);
        this.pc = new Purchase_cost__c (Purchase_Request_Item__c = prLineCtrl.pri.Id, Supplier__c = prLineCtrl.pri.Supplier__c);
        if(prCtrl.supplierMap.containsKey(this.pc.Supplier__c)){
            this.pc.Currency__c = prCtrl.supplierMap.get(pc.Supplier__c).Currency__c;
        }
        this.pc.type__c = IDPConstant.PURCHASE_COST_TYPE_SHIPPING;
        this.pc.price__c = 0;
        this.isCostItem = true;
        this.receivedQuantity = 0;
    }
  
    Public IDPPurchaseRequestLineCtrl(Purchase_Cost__c pc, IDPPurchaseRequestCtrl prCtrl){
        this.pc = pc;
        this.currencyId = pc.currency__c;
        this.PRID = pc.Purchase_Request_Item__r.Purchase_Request__c;
        this.PRItemID = pc.Purchase_Request_Item__r.id;
        this.PCID = pc.Id;
        this.prCtrl = prCtrl;
        this.supppliertList = new List <selectOption>();
        this.isCostItem = true;
        this.receivedQuantity = 0;
        
        if(pc.Purchase_Request_Item__r.supplier__c != null){

            for(Supplier_Item__c reader : prCtrl.SupplierItemMap.get(pc.Purchase_Request_Item__r.Catalog_Item__c)){
                //if(reader.supplier__c != null  && pc.Purchase_Request_Item__r.supplier__c != reader.supplier__c){
                    supppliertList.add(new selectOption(reader.supplier__c, reader.supplier__r.Name + ' (Tax: ' + reader.supplier__r.Tax__c + '%)'));
                //}
            }
            //supppliertList.add(new selectOption(this.pc.Purchase_Request_Item__r.supplier__c, this.pc.Purchase_Request_Item__r.supplier__r.Name + ' (Tax: ' + this.pc.Purchase_Request_Item__r.supplier__r.Tax__c + '%)'));
            //supplierId = this.pc.Purchase_Request_Item__r.supplier__c;
            this.pc.Supplier__c = this.pc.Purchase_Request_Item__r.supplier__c;
        }
        
        if(supppliertList.isEmpty()){
            this.pc.supplier__c = null;
        }

    }
    
    Public Boolean getisAddAction(){
        return (this.prCtrl.isPurchaser || this.prCtrl.isCatalogOwner) && this.prCtrl.getisSubmitted();
        //return true;
    }
    
    Public Boolean getisDelAction(){
        return true;
    }
    
    Public Boolean getisValidReceivedQuantity(){        
        Boolean isValid = false;
        Boolean isPRIValid = false;
        Boolean isPOIValid = false;
        Double receivedQuantityChanges = 0;
        Double newPOTotalReceivedQuantity = 0;
        //Double oldPOTotalReceivedQuantity = 0;
        if(this.pri.Purchase_Order_Item__c != null) {        
            receivedQuantityChanges  = this.receivedQuantity - this.pri.Received_Qty__c;
            newPOTotalReceivedQuantity = receivedQuantityChanges  + this.pri.Purchase_Order_Item__r.Received_Quantity__c;
            //oldPOTotalReceivedQuantity = this.pri.Purchase_Order_Item__r.Received_Quantity__c;            
            isPRIValid = (0 <= this.receivedQuantity && this.receivedQuantity <= this.pri.Quantity__c);
            isPOIValid = (0 <= newPOTotalReceivedQuantity && newPOTotalReceivedQuantity <= this.pri.Purchase_Order_Item__r.Quantity__c);
            isValid = isPRIValid  && isPOIValid;
        }
        else {
            isValid = true;
        }
        return isValid;
    }
        
    Public void addRow(){
        //this.prCtrl.prAction.addRowAction(PRItemID);
        //this.prCtrl.prAction.addRowAction(this.pri);
        // Test
        //this.prCtrl.prAction.addTaxRowAction(this);       
        this.prCtrl.prAction.addRowAction(this);

    }
    
    Public void delRow(){
        this.prCtrl.prAction.delRowAction(PRItemID);
    }
    
    Public void delPCRow(){
        Set<String> toBeDeletedPCIdSet = new Set<String> ();
        toBeDeletedPCIdSet.add(PCID);
        this.prCtrl.prAction.delPCRowAction(toBeDeletedPCIdSet);
        //this.prCtrl.prAction.delPCRowAction(PCID);

    }    
    Public void changefulfillment(){

        if(pri.Is_Direct_fulfillment__c){
            //supplierId = null;
            pri.Supplier__c = null;
            pri.Currency__c = null;
            pri.Price__c = 0;
        }
        
        this.prCtrl.prAction.changefulfillmentAction(pri.Id);
    }    
    /*
    before once checked Is_Direct_fulfillment__c, disable currency, price, quantity
    Public void changefulfillment(){
        if(pri.Is_Direct_fulfillment__c){
            pri.price__c = 0;
        }
    }
    */
    Public void preInputReceivedQtyAction() {
        this.prCtrl.prAction.preInputReceivedQtyAction(this);
    }    
    
        
    private String generateRandomString(Integer len) {
        final String chars = IDPConstant.RANDOM_STRING ;
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    Public String getsupplierId() {        
        if(!this.isCostItem) {
            return pri.Supplier__c;
        }
        else {
            return pc.Supplier__c;
        }
                
    }

    Public IDPPurchaseRequestLineCtrl getPriCtrl(String pPRIId) {
        for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList) {
            if(reader.PRItemID == pPRIId) {
                if(reader.pri != null) {
                    return reader;
                }
            }
        }
        return null;
    }

    Public void calculateTax(){
        if(isCostItem) { 
            if (!String.isBlank(pc.Supplier__c)) {   
                supplierTax = prCtrl.supplierMap.get(pc.Supplier__c).Tax__c;

                IDPPurchaseRequestLineCtrl priCtrl = getPriCtrl(PRItemID);

                if (supplierTax != null && priCtrl.pri.price__c != null)
                    pc.price__c = priCtrl.pri.price__c * priCtrl.pri.Quantity__c * (supplierTax / 100);
            }
        }
    }

    Public Boolean getIsTax() {
        return this.pc.type__c == IDPConstant.PURCHASE_COST_TYPE_TAX;
    }

    Public Decimal getMoq() {

        if (!isCostItem) {

            system.debug('prCtrl.catalogItemSupplierSourceMap:'+prCtrl.catalogItemSupplierSourceMap);

            if (prCtrl.catalogItemSupplierSourceMap.containsKey(pri.Catalog_Item__c)) {
               
               Map<String, Supplier_Item__c> siMap = prCtrl.catalogItemSupplierSourceMap.get(pri.Catalog_Item__c);
                
                if (siMap.containsKey(pri.Supplier__c)) {
                    return siMap.get(pri.Supplier__c).Minimum_Order_Quantity__c;
                }
            }
        }

        return 0;
    }

    Public Set<String> getLast3OrderedSupplier() {
        Set<String> last3OrderedSupplierList = new Set<String>();

        if (!isCostItem) {
            if (prCtrl.last3OrderedSupplierMap.containsKey(pri.Catalog_Item__c)) {
                last3OrderedSupplierList = prCtrl.last3OrderedSupplierMap.get(pri.Catalog_Item__c);
            }
        }

        return last3OrderedSupplierList;
    }

    Public String getLeadTime() {

        String leadTime = '';

        if (!isCostItem) {
            if (prCtrl.catalogItemSupplierSourceMap.containsKey(pri.Catalog_Item__c)) {
                Map<String, Supplier_Item__c> siMap = prCtrl.catalogItemSupplierSourceMap.get(pri.Catalog_Item__c);
                system.debug('siMap:'+siMap);

                if (siMap.containsKey(pri.Supplier__c)) {
                    Supplier_Item__c si = siMap.get(pri.Supplier__c);

                    if (si.Lead_Time_Days__c != null && String.isNotEmpty(si.Lead_Time_Format__c))
                        leadTime = Integer.valueOf(si.Lead_Time_Days__c) + ' ' + si.Lead_Time_Format__c + '(s)';
                }                
            }
        }

        return leadTime;
    }


    //Public Boolean getIsLessThanMOQ() {
    //    Decimal moq = pri.Catalog_Item__r.Minimum_Order_Quantity__c;

    //    if (moq == null)
    //        return false;

    //    system.debug('pri.Quantity__c :'+(pri.Quantity__c ));
    //    system.debug('pri.Quantity__c < moq:'+(pri.Quantity__c < moq));
    //    return pri.Quantity__c < moq;
    //}
}