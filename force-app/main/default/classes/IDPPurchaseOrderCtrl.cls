public without sharing class IDPPurchaseOrderCtrl{


    Public Employee__c emp {get;set;}
    Public Budget__c budget{get;set;}
    Public String mode {get;set;}
    
    Public Boolean isRecall {set;}
    Public Boolean isMyself {set;get;}
    Public Boolean isPurchaser {set;get;}
    Public Boolean isCatalogOwner {set;get;}
    Public Boolean isApprover {set;get;}
    Public Boolean isCurrentApprover {set;get;}
    
    Public Boolean isbeingShared {set;get;}
    Public Map <Id, List<Purchase_Cost__c>> priIdPCListMap {set;get;}    
    Public List <selectOption> applicantOptList {get;set;}
    
    Public List <selectOption> costItemOptList {get;set;}
    Public List <selectOption> currencyList {get;set;}
    
    Public Map<id, Site__c> siteMap {get;set;}    
    Public Map<id, Supplier__c> supplierMap {get;set;}
    Public Map<Id, List<Supplier_Item__c>> SupplierItemMap{get;set;}
    Public Map<String, double> exchangeRateMap {get;set;}
    Public Map<id, Map<id, double>> supplierCost {get;set;}
    Public Map<String, Map<String, Boolean>> pripcIdFieldNameIsBlankMessageMap {get;set;}
    Public Map<String, Map<String, Supplier_Item__c>> catalogItemSupplierSourceMap {get;set;}

    Public String tmp {get;set;}
    Public Double withheldAmount {get;set;}
    
    //active now  
    Public static String VIEW_MODE {get {return 'v';}}
    Public static String SAVE_MODE {get {return 's';}}    
    Public Boolean isSave {set;}
    Public Boolean isEdit {set;}
    Public Boolean isSubmit {set;}   
    Public Boolean isView {set;}
    //Public Boolean isCancelPO {set;}    
    //Public Boolean isDraft {set;}    
    //Public Boolean isOrdered {set;}
    //Public Boolean isPartialDelivered {set;} 
    //Public Boolean isDelivered {set;}
    Public Boolean isClosed {set;}
    Public Boolean isSubmitted {set;}
    Public Boolean isBeforePartialDelivered {set;}
    //Public Boolean isAttemptedToSubmit {get;set;}
    Public Boolean isDisplayedMessage {set;get;}
    Public Boolean isDeliveryAddressBlank {set;}
    Public Boolean isShippingAddressBlank {set;}
    //Public Boolean isTaxExceededToleranceLvl {set;}
    //Public Boolean isShippingExceededToleranceLvl {set;}
    //Public Boolean isOtherCostExceededToleranceLvl {set;}
    Public Boolean isFullyReceived;
    Public String selectedCurrency {get;set;}  
    Public String pid {get;set;}
    Public String message {get;set;}
    //Public Date EariestDeliDate {get;set;}
    Public Date EarliestDeliDate {set;}
    Public Double priStandardAmount {set;}
    Public Decimal totalPrice {set;}
    Public Decimal tototPriceInclTaxShip {set;}
    Public Decimal currentEXRate {get; set;}
    Public Purchase_Order__c po {get;set;}  
    Public Purchase_Order_Item__c poi {get;set;}  
    Public List<Purchase_Order_Item__c> poiList {get;set;}  
    Public List<IDPPurchaseOrderLineCtrl> POLineList {get;set;}
    Public List <selectOption> currencyOptList {get;set;}
    Public List <selectOption> deliverySiteOptList {get;set;}   
    Public List <selectOption> deliveryMethodOptList {get;set;}
    Public List <selectOption> deliveryTermsOptList {get;set;}
    Public List <selectOption> paymentMethodOptList {get;set;}
    Public List <selectOption> paymentTermsOptList {get;set;}  
    Public Map<ID,currency__c> currencyIdMap{get;set;} 
    Public Map<Id, Purchase_Request_Item__c> relatedPRIMap {get;set;}
    Public Map<Id, Receiving_History__c> receivingHistoryMap {get;set;}
    Public List<Purchase_Request_Item__c> relatedPRIList;
    Public List<ContentDocument> attachmentList {get;set;}
    Public List<ContentDocument> poAttachmentList {get;set;}
    Public List<Receiving_History__c> receivingHistoryList {get;set;}
    //Public String currencyType {get;set;}
    //Public Map<Id, Purchase_Order_Item__c> priIdPOIMap {get;set;}
    
    
    Public IDPPurchaseOrderInitCtrl poInit;
    Public IDPPurchaseOrderActionCtrl poAction;    
    Public IDPPurchaseOrderLineCtrl poLine;

    Public IDPPurchaseOrderCtrl(){
        this.priIdPCListMap = new Map <Id, List<Purchase_Cost__c>> ();
        this.applicantOptList = new List <selectOption>();
        
        this.costItemOptList = new List <selectOption>();
        this.deliverySiteOptList = new List <selectOption>();
        this.currencyList = new List <selectOption>();
        this.deliveryMethodOptList = new List <selectOption>();
        this.deliveryTermsOptList = new List <selectOption> ();
        this.paymentMethodOptList = new List <selectOption>();
        this.paymentTermsOptList = new List <selectOption>();
        this.exchangeRateMap = new Map<String, double>();
        this.pripcIdFieldNameIsBlankMessageMap = new Map<String, Map<String, Boolean>> ();
        
        this.isMyself = false;
        this.isPurchaser = false;
        this.isCatalogOwner = false;
        this.isApprover = false;
        this.isCurrentApprover = false;
        this.isbeingShared =false;

        //active now 
        this.message = '';
        this.selectedCurrency = '';
        //this.isAttemptedToSubmit = false;
        this.isDisplayedMessage = false;        
        this.mode = ApexPages.currentPage().getParameters().get('mode'); 
        this.relatedPRIMap = new Map<Id, Purchase_Request_Item__c> ();
        this.receivingHistoryMap = new Map<Id, Receiving_History__c> ();
        this.attachmentList = new List<ContentDocument> ();
        this.poAttachmentList = new List<ContentDocument> ();
        
        this.receivingHistoryList = new List<Receiving_History__c> ();        
        //this.priIdPOIMap = new Map<Id, Purchase_Order_Item__c> ();
        //get po id from consolidated form 
        this.pid = ApexPages.currentPage().getParameters().get('poid');   
        
        //call exteranl apex class
        this.poInit = new IDPPurchaseOrderInitCtrl(this, pid);
        this.poAction = new IDPPurchaseOrderActionCtrl(this, pid);  
        this.currentEXRate = this.poInit.getCurrentBudgetEx(this.po.currency__c).rate__c;
        POLineList = new List<IDPPurchaseOrderLineCtrl>();

        for(Purchase_Order_Item__c reader : po.Purchase_Order_Items__r){
            this.POLineList.add(new IDPPurchaseOrderLineCtrl(reader, this)); 
        }             
        
        this.relatedPRIMap = this.poAction.getRelatedPRIMap();
        this.attachmentList = this.poAction.getPRAttachment(this.relatedPRIMap);
        this.poAttachmentList = this.poAction.getPOAttachment(this.po);
        
        this.receivingHistoryList = this.poAction.getReceivedHistory(po.Purchase_Order_Items__r);
        //this.priIdPOIMap = this.poAction.getPRIIdPOMap(this.relatedPRIMap);
        
        currencyIdMap = new Map<ID, currency__c>([SELECT Id, Name FROM currency__c]);
        if(po.Delivery_Date__c == null){
            po.Delivery_Date__c = getEarliestDeliDate();
        }
        if(String.isBlank(this.mode)){
            this.mode = VIEW_MODE;
        }   
    }
             
    //*------Line Mass Action Method----*//
    public void removePOIAction() {
        List<IDPPurchaseOrderLineCtrl> tempPOLineList = new List<IDPPurchaseOrderLineCtrl>(); 
        
        poAction.removePOIAction();
        
        if(!this.isDisplayedMessage) {
            this.po = this.poInit.getPO(this.po.Id);
            //this.po.Delivery_Date__c = getEarliestDeliDate();
            update this.po;
                    
            tempPOLineList = this.POLineList.clone();
            this.POLineList.clear();
            
            if(tempPOLineList.size() > 1) {
                for(Purchase_Order_Item__c reader : this.po.Purchase_Order_Items__r) {
                    this.POLineList.add(new IDPPurchaseOrderLineCtrl(reader, this)); 
                }
            }
            
            this.relatedPRIMap = this.poAction.getRelatedPRIMap();
            this.attachmentList = this.poAction.getPRAttachment(this.relatedPRIMap);       
        }         
    }  
    
    Public void mergePOIAction(){

        poAction.mergePOIAction();
        
        if(!this.isDisplayedMessage) {
            this.po = poInit.getPO(this.po.Id);
            this.POLineList.clear();
            for(Purchase_Order_Item__c reader : this.po.Purchase_Order_Items__r) {
                this.POLineList.add(new IDPPurchaseOrderLineCtrl(reader, this)); 
            }                 
        }
    }
    /*  
    Public void massEditCurrency(){
        poAction.massEditCurrency();
    }
    */
    /*
    Public void massEditDate(){
        poAction.massEditDate();
    }
    */
    

    //*------header Action Method----*//
    Public void saveAction(){
        poAction.saveAction(); 
    }
           
    //public void callSaveActionWebService() {
    //    system.debug(LoggingLevel.ERROR, '@1callSaveActionWebService()');
    //    try {   
    //        system.debug(LoggingLevel.ERROR, '@callSaveActionWebService():'+po.Status__c);

    //        //if (po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED)
    //            IDPWebService.updatePOtoMule(po);

    //        //if (po.Status__c != IDPConstant.PURCHASE_ORDER_STATUS_DRAFT)    
    //        //    IDPWebService.sendReceivingQtyToMule(this.po, receivingHistoryList, this.poAction.getReceivedHistory(po.Purchase_Order_Items__r));

    //    } catch (Exception e) {
    //        system.debug('saveAction catch:'+e.getMessage());
    //        //Database.rollback(sp);
    //        this.isDisplayedMessage = true;
    //        this.message = e.getMessage();
    //        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.message));
    //    }
    //}










    Public void submitAction(){
        poAction.submitAction();
    }   

    
    //public void callSubmitActionWebService() {

    //    try { 
    //        system.debug(LoggingLevel.ERROR, '@callSaveActionWebService()');
    //        if (po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED)
    //            IDPWebService.updatePOtoMule(po);

    //        if (po.Status__c != IDPConstant.PURCHASE_ORDER_STATUS_DRAFT)    
    //            IDPWebService.sendReceivingQtyToMule(this.po, receivingHistoryList, this.poAction.getReceivedHistory(po.Purchase_Order_Items__r));

    //    } catch (Exception e) {
    //        system.debug('saveAction catch:'+e.getMessage());
    //        //Database.rollback(sp);
    //        this.isDisplayedMessage = true;
    //        this.message = e.getMessage();
    //        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.message));
    //    }
    //}

    Public void callWebService() {
        //IDPWebService.sendRequestToMuleWithFuture(this.po.Id);

        //String webServiceResult = IDPWebService.sendRequestToMule(this.po);
        //if (webServiceResult != '') {
        //    this.isDisplayedMessage = true;
        //    this.message = webServiceResult;
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.message));
        //}
        //system.debug('webServiceResult:'+webServiceResult);
    }
      
    public PageReference massClosedPOPOI(){
         return null;
         //return poAction.massClosedPOPOI();
    }
    
    Public PageReference cancelAction(){
        return poAction.cancelAction();
    }    
    
    /*
    Public PageReference cancelPOAction() {
        return poAction.cancelPOAction();
    }
    */
    Public PageReference editAction(){
        return poAction.editAction();
    }
         
    Public PageReference backAction(){
        return poAction.backAction();
    }         
       
    Public void changeSite() {
        poAction.getDeliveryAddress();
    }    
   
   @RemoteAction
   Public static  String  uploadFileAction(String name , String contentType, String body, string attachid, String pid) {
       Attachment attach = new Attachment();
       if ( attachid != ''){
           for(Attachment atm : [select Id, Body from Attachment where Id = :attachid]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachid, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + body));
            }
           return attachid;
       }
       attach.Name = name;
       attach.ContentType = contentType;
       attach.ParentId = pid;//'a0sp0000002sia1';//pid;
       attach.Body = EncodingUtil.Base64Decode(body);
       upsert attach;  
       body = null;
       
       contentType = '';
       name = '';
       return attach.id;
   }

    //*------getter Method----*//
    
    //status getters 
    
    Public Boolean getisClosed(){
        return this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_CLOSED;
    }
    
    /*
    Public Boolean getisDraft(){
        return po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DRAFT;
    }
    
    Public Boolean getisOrdered(){
        return po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED;
    }
    
    Public Boolean getisDelivered(){
        return po.Status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_DELIVERED;
    }
    
    Public Boolean getisPartialDelivered(){
        return this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_PARTIAL_DELIVERED;
    }                        
    */
    
    //form visibility getters     
    Public Boolean getisSave(){
        return this.mode == SAVE_MODE && isbeingShared == true;
    }
    Public Boolean getisEdit(){
        return (this.mode == VIEW_MODE && isbeingShared == true &&
                (po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DRAFT ));
                /*
                ||po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED ||
                po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_PARTIAL_DELIVERED)
                */
    }    

    Public Boolean getisSubmit(){
        return this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DRAFT && isbeingShared == true;
    }    

    
    Public Boolean getisView(){
        return this.mode == VIEW_MODE;
    }    

        
    Public Boolean getisSubmitted(){
        return (this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED ||
                this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_PARTIAL_DELIVERED ||
                this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DELIVERED ||
                this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_CLOSED );
    }

    Public Boolean getisBeforePartialDelivered(){
        return (this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DRAFT ||
                this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED );
    }
    
    /*
    Public Boolean getisCancelPO(){
        if(this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DRAFT || this.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED) {
            return true;
        }
        else {
            return false;
        }
    }
    */
            
    //validation boolean getters
    /*Public Boolean getisTaxExceededToleranceLvl () {
        Double newPrice = this.po.Total_Tax__c;
        Double acceptableUpperLimit = this.po.Original_Total_Tax__c *(1 + this.po.Delivery_Site__r.Tolerance_Level__c / 100);
        Double acceptableLowerLimit = this.po.Original_Total_Tax__c *(1 - this.po.Delivery_Site__r.Tolerance_Level__c / 100);
            
        return (newPrice > acceptableUpperLimit || newPrice < acceptableLowerLimit);
    }*/

    /*Public Boolean getisShippingExceededToleranceLvl () {
        Double newPrice = this.po.Total_Shipping_Cost__c;
        Double acceptableUpperLimit = this.po.Original_Total_Shipping_Cost__c *(1 + this.po.Delivery_Site__r.Tolerance_Level__c / 100);
        Double acceptableLowerLimit = this.po.Original_Total_Shipping_Cost__c *(1 - this.po.Delivery_Site__r.Tolerance_Level__c / 100);
            
        return (newPrice > acceptableUpperLimit || newPrice < acceptableLowerLimit);
    }*/

    /*Public Boolean getIsOtherCostExceededToleranceLvl () {
        Double newPrice = this.po.Total_Other_Cost__c;
        Double acceptableUpperLimit = this.po.Original_Total_Other_Cost__c *(1 + this.po.Delivery_Site__r.Tolerance_Level__c / 100);
        Double acceptableLowerLimit = this.po.Original_Total_Other_Cost__c *(1 - this.po.Delivery_Site__r.Tolerance_Level__c / 100);
            
        return (newPrice > acceptableUpperLimit || newPrice < acceptableLowerLimit);
    }*/
    
    Public Boolean getisDeliveryAddressBlank() {
    
        Boolean isBlank = false;
        system.debug('this.po.Delivery_To__c):'+this.po.Delivery_To__c);
        isBlank = String.isBlank(this.po.Delivery_To__c);
        
        return isBlank;
    }
    
    Public Boolean getisShippingAddressBlank() {    
        Boolean isBlank = false;        
        isBlank = String.isBlank(this.po.Shipping_Address_1__c);
        return isBlank;        
    }
    
    //Other getters
    Public List<Purchase_Request_Item__c> getrelatedPRIList() {
        return relatedPRIMap.values();     
    }
    
    Public DateTime getSubmittedDate(){
        return po.Submitted_Date__c;
    }
    
    public Double getpriStandardAmount() {
        Double amount = 0;
        for(Purchase_Request_Item__c reader : relatedPRIMap.values()) {
            amount += reader.Standard_Amount__c;
        }
        return amount;
    }
    
    public Date getEarliestDeliDate(){
            Date tempDate = null;
            for(Purchase_Order_Item__c reader : po.Purchase_Order_Items__r){
                 if(tempDate == null){
                     tempDate = reader.Delivery_Date__c;
                 }
                                  
                 if(tempDate > reader.Delivery_Date__c){
                     tempDate = reader.Delivery_Date__c;
                 }    

            }   
            return tempDate;           
    }    

    public Decimal getTotalPrice() {

        Decimal price = 0;
        Decimal quantity = 0;
        Decimal totalPrice = 0;

        for (IDPPurchaseOrderLineCtrl polCtrl : POLineList) {

            price = polCtrl.poi.Price__c != null ? polCtrl.poi.Price__c : 0;
            quantity = polCtrl.poi.Quantity__c != null ? polCtrl.poi.Quantity__c : 0;

            totalPrice += price * quantity;
        }

        return totalPrice;
    }
    
    public Decimal getTotalAdditionalPrice() {

        Decimal totalAdditionalPrice = 0;
        for (IDPPurchaseOrderLineCtrl polCtrl : POLineList) {

            //price = polCtrl.poi.Price__c != null ? polCtrl.poi.Price__c : 0;
            //quantity = polCtrl.poi.Quantity__c != null ? polCtrl.poi.Quantity__c : 0;

            //totalAdditionalPrice  += price * quantity;
            totalAdditionalPrice += (polCtrl.poi.Additional_Cost__c !=null?polCtrl.poi.Additional_Cost__c : 0);
        }

        return totalAdditionalPrice ;
    }

    public Decimal getTotalPriceInclTaxShip() {

        Decimal totalTax = po.Total_Tax__c != null ? po.Total_Tax__c : 0;
        Decimal totalShip = po.Total_Shipping_Cost__c != null ? po.Total_Shipping_Cost__c : 0;
        Decimal totalOthers = po.Total_Other_Cost__c != null ? po.Total_Other_Cost__c : 0;

        return getTotalPrice() + getTotalAdditionalPrice() + totalTax + totalShip + totalOthers;
    }

    public void calculateTax(){

        Decimal supplierTax = po.Supplier__r.Tax__c != null ? po.Supplier__r.Tax__c : 0;

        po.Total_Tax__c = getTotalPrice() * (supplierTax / 100);
    }

    public void refreshPOAttachment() {
        this.poAttachmentList = this.poAction.getPOAttachment(this.po);
    }

    public void deletePOAttachment() {
        String attId = ApexPages.CurrentPage().getParameters().get('attId');

        poAction.deletePOAttachemnt(attId);
        refreshPOAttachment();
    }

    public void refreshTotalTaxAndCost() {
        this.po = poInit.getPO(po.Id);
        this.po.Total_Tax__c = this.po.Original_Total_Tax__c;
        this.po.Total_Shipping_Cost__c = this.po.Original_Total_Shipping_Cost__c;
        this.po.Total_Other_Cost__c = this.po.Original_Total_Other_Cost__c;
    }

    public boolean getIsFullyReceived() {
        if (POLIneList.size() == 0)
            return false;

        for (IDPPurchaseOrderLineCtrl polCtrl : POLineList) {
            if (polCtrl.poi.Quantity__c != polCtrl.receivedQuantity) {
                return false;
            }
        }

        return true;
    }


    /*
    
    Public Boolean getisEdit(){
        if(po.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED){
            return false;
        }
        if((isPurchaser || isCatalogOwner) && pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION){
            return this.mode == VIEW_MODE;
        }
        else if(isMyself){
            return this.mode == VIEW_MODE && !getisSubmitted();
        }
        return false;
    }  
   
    Public Boolean getisView(){
        return this.mode == VIEW_MODE;
    }
    
    Public Boolean getisSave(){
        if(pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED){
            return false;
        }
        if(isCatalogOwner || isPurchaser ){
            return this.mode == SAVE_MODE;
        }
        else if(isMyself){
            return this.mode == SAVE_MODE && !getisSubmitted();
        }
        else{
            return false;
        }
    }
    
    
    Public Boolean getisSubmitted(){
         return !(pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT  || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED );
    }
    
    Public Boolean getisSubmit(){
         return isMyself && (pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT  || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED );
    }
    
    Public Boolean getisRecall(){
        return isMyself && !(pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED);
    }
    
    Public Boolean getisApproval(){
        return !(pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT  || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED);
    }

    Public PageReference recallAction(){
        return poAction.recallAction();
    }
    
    Public PageReference approveAction(){
        return poAction.approvalAction('Approve');
    }
    
    Public PageReference rejectAction(){
        return poAction.approvalAction('Reject');
    }
    
    Public void changeSite() {
        poAction.getDeliveryAddress();
    }
    */
    
    // Active
    /*
    Public PageReference removePOItem(){
        PageReference POI = poAction.removePOItem(); 
        
        NewPOLineList = new List<IDPPurchaseOrderLineCtrl>();
        
        for(Purchase_Order_Item__c reader : po.Purchase_Order_Items__r){
           NewPOLineList.add(new IDPPurchaseOrderLineCtrl(reader, this)); 
        }  
        
        POLineList = NewPOLineList;
            
        return POI ;
    } //Test
    */


}