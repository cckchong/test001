public without sharing class IDPPurchaseOrderActionCtrl{

    Private IDPPurchaseOrderCtrl poCtrl;
    Private String pid;
    Private final Static String TOLERANCE_MESSAGE_REPLACEMENT = '@TOLERANCE';
    
    Public IDPPurchaseOrderActionCtrl(IDPPurchaseOrderCtrl poCtrl, String pid){
        this.pid = pid;
        this.poCtrl = poCtrl;
        
    }
 
     // active
     
    //*----------------requery map or list method(s)------------------------*//
    Public Map<Id, Purchase_Request_Item__c> getRelatedPRIMap() {
        
        Map<Id, Purchase_Request_Item__c> tempPurchaseRequestItemMap = new Map<Id, Purchase_Request_Item__c> ();
        Set<Id> purchaseOrerItemIdSet = new Set<Id> ();
        for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList) {
            purchaseOrerItemIdSet.add(reader.poi.Id);
        }
        for(Purchase_Request_Item__c reader : [SELECT Id, Name, Purchase_Request__c, Purchase_Order_Item__c, Purchase_Request__r.Name, CreatedDate,
                                                Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c, Catalog_Item__r.Catalog__r.Catalog_Name__c,
                                                Catalog_Item__r.Item_Name__c, quantity__c, price__c, Unit_Of_Measure__c, Standard_Sub_Total__c, Purchase_Request__r.On_Behalf_of__c, Purchase_Request__r.On_Behalf_of__r.Name,
                                                Purchase_Order_Item__r.Number__c, Status__c, Used_Standard_Exchange_Rate__c, Standard_Amount__c, Budget_Exchange_Rate__c 
                                            FROM Purchase_Request_Item__c 
                                            WHERE Purchase_Order_Item__c in :purchaseOrerItemIdSet
                                            ORDER BY Purchase_Order_Item__r.Number__c ASC , Purchase_Request__r.Name Asc]) {
            
            tempPurchaseRequestItemMap.put(reader.Id, reader);
        }
        
        return tempPurchaseRequestItemMap;
    }     
    
    Public List<ContentDocument> getPRAttachment(Map<Id, Purchase_Request_Item__c> pPurchaseRequestItemMap) {
    
        List<ContentDocument> tempAttachmentList = new List<ContentDocument> ();
        Set<Id> purchaseRequestIdSet = new Set<Id> ();
    
        for(Purchase_Request_item__c reader : pPurchaseRequestItemMap.values()) {
            purchaseRequestIdSet.add(reader.Purchase_Request__c);
        }

        if (purchaseRequestIdSet.size()>0) {
            Map<String, String> docIds = new Map<String, String>();
                for (ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId
                                                 FROM ContentDocumentLink
                                                 Where LinkedEntityId IN :purchaseRequestIdSet]) {

                docIds.put(link.ContentDocumentId, link.LinkedEntityId);
            }
        
            tempAttachmentList = [SELECT Id, Title, LastModifiedDate, ParentId, CreatedById, LatestPublishedVersionId 
                                  FROM ContentDocument
                                  WHERE Id IN :docIds.keySet()
                                  ORDER BY Title];
            
            for (ContentDocument doc : tempAttachmentList) {
                doc.ParentId = docIds.get(doc.Id);
            }
        }
        return tempAttachmentList;
    }   
    
    Public List<ContentDocument> getPOAttachment(Purchase_Order__c po) {
        List<ContentDocument> tempAttachmentList = new List<ContentDocument> ();

        if(po != null){
            List<String> docIds = new List<String>();
            for (ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId
                                             FROM ContentDocumentLink
                                             Where LinkedEntityId = :po.Id]) {

                system.debug('link:'+link);
                docIds.add(link.ContentDocumentId);

            }


            tempAttachmentList = [SELECT Id, Title, LastModifiedDate, ParentId, CreatedById, LatestPublishedVersionId 
                                    FROM ContentDocument
                                    WHERE Id IN :docIds
                                    ORDER BY Title];
        }
        else{
            return null;
        }
    
        return tempAttachmentList;
    }        
    
    Public void deletePOAttachemnt(String attId) {
        List<ContentDocument> att = [SELECT Id, Title, LastModifiedDate, ParentId, CreatedById, LatestPublishedVersionId 
                                    FROM ContentDocument
                                    WHERE Id = :attId
                                    ];

        system.debug('attId:'+attId);                            
        system.debug('deletePOAtt:'+att);
        delete att;
    }
    
    public List<Receiving_History__c> getReceivedHistory(List<Purchase_Order_Item__c> pPurchaseOrderItemList){
        
        List<Receiving_History__c> tempReceivingHistoryList = new List<Receiving_History__c> ();
        
        tempReceivingHistoryList = [SELECT Id, Name, Quantity__c, Purchase_Order_Item__c, Purchase_Order_Item__r.Name, Purchase_Order_Item__r.Number__c,
                                        Purchase_Order_Item__r.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c,
                                        Purchase_Order_Item__r.Catalog_Item__r.Catalog__r.Catalog_Name__c, Purchase_Order_Item__r.Catalog_Item__r.Item_Name__c,
                                        CreatedDate, CreatedById
                                    FROM Receiving_History__c 
                                    Where Purchase_Order_Item__c in :pPurchaseOrderItemList
                                    ORDER BY Purchase_Order_Item__r.Name, Purchase_Order_Item__r.Catalog_Item__r.Item_Name__c ASC NULLS LAST, CreatedDate Asc];

        return tempReceivingHistoryList;
    }
    
    


    //*----------------mass edit field method(s)------------------------*//
    /*
    Public PageReference massClosedPOPOI(){
        List <Purchase_Order_Item__c> poiList = new List <Purchase_Order_Item__c>();
        List <Purchase_Order__c> poList = new List <Purchase_Order__c>();
        PageReference prf = null; 
        
        for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList){
            if(reader.poi != null) {                
                reader.poi.Status__c = IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CLOSED;
                poiList.add(reader.poi);
            }
        }   
        
        this.poCtrl.po.Status__c = IDPConstant.PURCHASE_ORDER_STATUS_CLOSED;
        
        if(this.poCtrl.po!=null){
            update this.poCtrl.po;
            

            
        }
        if(poiList.size()>0){
            update poiList;
        }
        
            
        prf = new PageReference(Label.IDP_Path_IDPPurchaseOrderVFP + '?' + Label.IDP_Path_Parameter_POId +'=' + pid +'&' + Label.IDP_Path_Parameter_Mode +'=' + IDPPurchaseOrderCtrl.VIEW_MODE);
        prf.setRedirect(true);      
        poCtrl.isEdit = false;
        return prf;         
       
    }
    //*/
    /*
    Public void massEditCurrency(){
        
        Map<String, Exchange_Rate__c> fromToCurrencyIdExchangeRateMap = new Map<String, Exchange_Rate__c> ();            
        List <Purchase_Order_Item__c> poiList = new List <Purchase_Order_Item__c>();
        Set<String> fromToCurrencyIdSet = new Set<String> ();
        String toCurrencyId = null;
        String fromCurrencyId = null;
        String fromToCurrencyId = null;
        Decimal exchangeRate = null;
        
        this.poCtrl.isDisplayedMessage = false;
        this.poCtrl.message = '';
        
        
        if(this.poCtrl.po.Currency__c != null) {
            
            //toCurrencyId = String.valueOf(this.poCtrl.po.Currency__c).substring(0, 15);
            toCurrencyId = String.valueOf(this.poCtrl.selectedCurrency).substring(0, 15);
            fromCurrencyId = String.valueOf(this.poCtrl.po.Currency__c).substring(0, 15);
            fromToCurrencyId = fromCurrencyId + toCurrencyId;
            fromToCurrencyIdSet.add(fromToCurrencyId);
            
            if(!this.poCtrl.POLineList.isEmpty()){
                for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList){
                    if(reader.poi != null) {
                        if(reader.poi.Currency__c != null) {
                            fromCurrencyId = String.valueOf(reader.poi.Currency__c).substring(0, 15);
                            fromToCurrencyId = fromCurrencyId + toCurrencyId;
                            fromToCurrencyIdSet.add(fromToCurrencyId);
                        }
                    }
                }
                
                for(Exchange_Rate__c reader :[SELECT Tech_From_To_Currency_ID__c, Rate__c, From_Currency__c, To_Currency__c, To_Currency__r.Name 
                                                            FROM Exchange_Rate__c 
                                                            WHERE Is_Latest__c = true and Is_Book_Rate__c = true 
                                                            AND Tech_From_To_Currency_ID__c in :fromToCurrencyIdSet]) {
                    
                    fromToCurrencyIdExchangeRateMap.put(reader.Tech_From_To_Currency_ID__c, reader);                                           
                }
                
                if(!fromToCurrencyIdExchangeRateMap.isEmpty()) {

                    //exchange PO header Tax and Shipping Cost Original and the updated price
                    toCurrencyId = String.valueOf(this.poCtrl.selectedCurrency).substring(0, 15);
                    fromCurrencyId = String.valueOf(this.poCtrl.po.Currency__c).substring(0, 15);
                    fromToCurrencyId = fromCurrencyId + toCurrencyId;
                    
                    if(fromToCurrencyIdExchangeRateMap.containsKey(fromToCurrencyId)) {  
                        this.poCtrl.po.Currency__c = this.poCtrl.selectedCurrency;
                        exchangeRate = fromToCurrencyIdExchangeRateMap.get(fromToCurrencyId).Rate__c;              
                        this.poCtrl.po.Total_Shipping_Cost__c = this.poCtrl.po.Total_Shipping_Cost__c * exchangeRate;
                        this.poCtrl.po.Total_Tax__c = this.poCtrl.po.Total_Tax__c * exchangeRate; 
                    }
                    for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList){
                        if(reader.poi != null) {
                            if(reader.poi.Currency__c != null) {
                                fromCurrencyId = String.valueOf(reader.poi.Currency__c).substring(0, 15);
                                fromToCurrencyId = fromCurrencyId + toCurrencyId;
                                
                                if(fromToCurrencyIdExchangeRateMap.containsKey(fromToCurrencyId)) {
                                    exchangeRate = fromToCurrencyIdExchangeRateMap.get(fromToCurrencyId).Rate__c;
                                    reader.poi.Currency__c = toCurrencyId;
                                    reader.poi.Price__c = reader.poi.Price__c*exchangeRate;
                                    reader.poi.Tech_Price__c = reader.poi.Tech_Price__c*exchangeRate;
                                    reader.poi.Tech_PO_Currency_PRI_Shipping__c = reader.poi.Tech_PO_Currency_PRI_Shipping__c*exchangeRate;
                                    reader.poi.Tech_PO_Currency_PRI_Tax__c = reader.poi.Tech_PO_Currency_PRI_Tax__c*exchangeRate;
                                    system.debug(reader.poi.Tech_Price__c);
                                    system.debug(exchangeRate);
                                    poiList.add(reader.poi);
                                }
                                else {
                                    this.poCtrl.isDisplayedMessage = true;
                                    this.poCtrl.message = Label.IDP_PO_No_Exchange_Rate_Records_Message;
                                    poiList.clear();
                                    break;
                                }                                      
                            }
                        }
                    }
                }
                else {
                    this.poCtrl.isDisplayedMessage = true;
                    this.poCtrl.message = Label.IDP_PO_No_Exchange_Rate_Records_Message;
                    poiList.clear();
                }                
            }
        }
        
        if(!poiList.isEmpty()) {
            this.poCtrl.poAction.saveAction();
            //update this.poCtrl.po;
            //update poiList;
            this.poCtrl.POLineList.clear();
            this.poCtrl.po = this.poCtrl.poInit.getPO(this.poCtrl.po.Id);
            for(Purchase_Order_Item__c reader : this.poCtrl.po.Purchase_Order_Items__r){
                this.poCtrl.POLineList.add(new IDPPurchaseOrderLineCtrl(reader, this.poCtrl)); 
            }                    
        }
                
        if(this.poCtrl.isDisplayedMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.poCtrl.message));
            return;
        }        
    }
        
    Public void massEditDate(){
        
        List <Purchase_Order_Item__c> poiList = new List <Purchase_Order_Item__c>();
        
        this.poCtrl.isDisplayedMessage = false;
        this.poCtrl.message = '';
        
        if(!String.isBlank(String.valueof(this.poCtrl.po.Delivery_Date__c))) {
            for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList){
                if(reader.poi != null) {                
                    reader.poi.Delivery_Date__c = this.poCtrl.po.Delivery_Date__c;
                    poiList.add(reader.poi);
                }
            }
        }
        else {
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = Label.IDP_PO_Blank_Delivery_Date_Error_Message; 
            poiList.clear();
        }
        
        if(!poiList.isEmpty()) {
            update this.poCtrl.po;
            update poiList;
        }  

        if(this.poCtrl.isDisplayedMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.poCtrl.message));
            return;
        }
        


    }
    */
    //*----------------Edit line data method(s)------------------------*//

    Public void mergePOIAction(){

        List<Purchase_Request_Item__c> toBeUpdatedPRIList = new List<Purchase_Request_Item__c>();
        List<Purchase_Order_Item__c> toBeUpdatedPOIList = new List<Purchase_Order_Item__c>();
        List<Purchase_Order_Item__c> toBeDeletedPOIList = new List<Purchase_Order_Item__c>();
        Purchase_Order_Item__c mergedPOI = null;
        Purchase_Order_Item__c earliestPOI = null;
        Decimal totalQty = 0;
        Decimal totalPrice = 0;
        Decimal totalAmount = 0;
        Decimal totalShipping = 0;
        Decimal totalTax = 0;
        Decimal totalOtherCost = 0;
        Integer counter = 1;
        String buyer_remark = '';
        Boolean isValid = true;

        this.poCtrl.isDisplayedMessage = false;
        this.poCtrl.message = '';
        

        isValid = validateToleranceLevel();

        if(this.poCtrl.isDisplayedMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.poCtrl.message));
            return;
        }

        if(!this.poCtrl.POLineList.isEmpty()){
            for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList){     
                if(reader.isChecked == true) {
                    if(reader.poi != null) {
                        if(earliestPOI == null) {
                            earliestPOI = reader.poi;
                        }
                        
                        if(earliestPOI.Catalog_Item__c != reader.poi.Catalog_Item__c) {
                            this.poCtrl.isDisplayedMessage = true;
                            this.poCtrl.message = Label.IDP_PO_Not_Allowed_To_Merge_Message;
                            break;
                        }
                        
                        if(earliestPOI.Tech_PRI_Create_Date__c < reader.poi.Tech_PRI_Create_Date__c) {
                            earliestPOI = reader.poi;    
                        }
                        totalQty += reader.poi.Quantity__c;
                        totalPrice += reader.poi.Price__c * reader.poi.Quantity__c;
                        totalAmount += reader.poi.Tech_PO_Currency_PRI_Amount__c;
                        totalShipping += reader.poi.Tech_PO_Currency_PRI_Shipping__c;
                        totalTax += reader.poi.Tech_PO_Currency_PRI_Tax__c;
                        totalOtherCost += reader.poi.Tech_PO_Currency_PRI_Other_Cost__c;
                        buyer_remark += reader.poi.Buyer_Remark__c != null ? reader.poi.Buyer_Remark__c + ',' : '';
                        toBeDeletedPOIList.add(reader.poi); 
                    }
                }
                else {
                    reader.poi.Number__c = counter;
                    toBeUpdatedPOIList.add(reader.poi);
                    counter++;
                }
            }
        }
        
        if(toBeDeletedPOIList.isEmpty()) {
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = Label.IDP_Have_Not_Selected_An_Item_Message;        
        }
        if(this.poCtrl.isDisplayedMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.poCtrl.message));
            return;
        }
        
        
        if(earliestPOI != null) {
            mergedPOI = new Purchase_Order_Item__c();

            if (buyer_remark.length()>255)
                buyer_remark = buyer_remark.substring(0, 254);
            else {
                // Remove last comma
                if (buyer_remark.length()>0)
                    buyer_remark = buyer_remark.substring(0, buyer_remark.length()-1); 
            }

            mergedPOI.Buyer_Remark__c = buyer_remark;
            mergedPOI.Catalog_Item__c = earliestPOI.Catalog_Item__c; 
            mergedPOI.Currency__c = earliestPOI.Currency__c; 
            mergedPOI.Delivery_Address__c = earliestPOI.Delivery_Address__c; 
            mergedPOI.Delivery_Date__c = earliestPOI.Delivery_Date__c; 
            mergedPOI.Number__c = counter;            
            //mergedPOI.Order_Date__c = earliestPOI.Order_Date__c; 
            //mergedPOI.Price__c = earliestPOI.Price__c;
            mergedPOI.Price__c = (totalPrice / totalQty).setScale(2); 
            mergedPOI.Purchase_Order__c = earliestPOI.Purchase_Order__c; 
            mergedPOI.Quantity__c= totalQty;
            mergedPOI.Received_Quantity__c = earliestPOI.Received_Quantity__c; 
            mergedPOI.Status__c = earliestPOI.Status__c; 
            mergedPOI.Supplier__c = earliestPOI.Supplier__c; 
            //mergedPOI.Tech_Price__c = earliestPOI.Tech_Price__c;
            mergedPOI.Tech_Price__c = (totalPrice / totalQty).setScale(2); 
            mergedPOI.Tech_PRI_Create_Date__c= earliestPOI.Tech_PRI_Create_Date__c;
            mergedPOI.Tech_PO_Currency_PRI_Amount__c = totalAmount;
            mergedPOI.Tech_PO_Currency_PRI_Shipping__c = totalShipping;
            mergedPOI.Tech_PO_Currency_PRI_Tax__c = totalTax;
            mergedPOI.Tech_PO_Currency_PRI_Other_Cost__c = totalOtherCost;
            mergedPOI.Unit_of_Measure__c = earliestPOI.Unit_of_Measure__c;  
            
            insert mergedPOI;
        }
        
        if(mergedPOI != null) {
            for(Purchase_Request_Item__c priReader: this.poCtrl.relatedPRIMap.values()){
                for(Purchase_Order_Item__c poiReader : toBeDeletedPOIList) {
                    if(priReader.Purchase_Order_Item__c == poiReader.Id) {
                        priReader.Purchase_Order_Item__c =mergedPOI.Id;
                        toBeUpdatedPRIList.add(priReader);
                    }
                }
            }
        }
        
        if(!toBeUpdatedPRIList.isEmpty()) {
            update toBeUpdatedPRIList;
        }
        
        if(!toBeDeletedPOIList.isEmpty()) {
            delete toBeDeletedPOIList;
        }
        
        if(!toBeUpdatedPOIList.isEmpty()) {
            update toBeUpdatedPOIList;
        }

    /* Original
        Decimal EarliestPriPrice = 0;
        Datetime  EarliestCreatePriDate = null;
        Decimal totalQty = 0;
        String oldCatalogItem = null;
        Purchase_Order_Item__c mergedPOI = new Purchase_Order_Item__c();
        
        Purchase_Order_Item__c mergedPri = new Purchase_Order_Item__c();
        if(!this.poCtrl.POLineList.isEmpty()){
        
            for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList){
                if(reader.isChecked == true){
                    if(reader.poi.Catalog_Item__c != oldCatalogItem && oldCatalogItem != null ){
                        return null;
                    }
                    else{
                        oldCatalogItem = reader.poi.Catalog_Item__c;
                    }
                }
            }
        
            Set<ID> selectedPOISet = new Set<ID>();
            
            for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList){
                if(reader.isChecked == true){
                    if(reader.poi != null){
                        totalQty += reader.poi.Quantity__c;
                        if(reader.poi.Tech_PRI_Create_Date__c> EarliestCreatePriDate && EarliestCreatePriDate!=null){
                            EarliestCreatePriDate = reader.poi.Tech_PRI_Create_Date__c;
                            mergedPOI.Buyer_Remark__c = reader.poi.Buyer_Remark__c; 
                            mergedPOI.Catalog_Item__c = reader.poi.Catalog_Item__c; 
                            mergedPOI.Currency__c = reader.poi.Currency__c; 
                            mergedPOI.Delivery_Address__c = reader.poi.Delivery_Address__c; 
                            mergedPOI.Delivery_Date__c = reader.poi.Delivery_Date__c; 
                            mergedPOI.Item_Description__c = reader.poi.Item_Description__c; 
                            mergedPOI.Order_Date__c = reader.poi.Order_Date__c; 
                            mergedPOI.Price__c = reader.poi.Price__c; 
                            mergedPOI.Purchase_Order__c = reader.poi.Purchase_Order__c; 
                            mergedPOI.Received_Quantity__c = reader.poi.Received_Quantity__c; 
                            mergedPOI.Status__c = reader.poi.Status__c; 
                            mergedPOI.Supplier__c = reader.poi.Supplier__c; 
                            mergedPOI.Unit_of_Measure__c = reader.poi.Unit_of_Measure__c;  
                            mergedPOI.Tech_PRI_Create_Date__c= reader.poi.Tech_PRI_Create_Date__c;  
                        }
                        if(EarliestCreatePriDate == null){
                            mergedPOI.Buyer_Remark__c = reader.poi.Buyer_Remark__c; 
                            mergedPOI.Catalog_Item__c = reader.poi.Catalog_Item__c; 
                            mergedPOI.Currency__c = reader.poi.Currency__c; 
                            mergedPOI.Delivery_Address__c = reader.poi.Delivery_Address__c; 
                            mergedPOI.Delivery_Date__c = reader.poi.Delivery_Date__c; 
                            mergedPOI.Item_Description__c = reader.poi.Item_Description__c; 
                            mergedPOI.Order_Date__c = reader.poi.Order_Date__c; 
                            mergedPOI.Price__c = reader.poi.Price__c; 
                            mergedPOI.Purchase_Order__c = reader.poi.Purchase_Order__c; 
                            mergedPOI.Received_Quantity__c = reader.poi.Received_Quantity__c; 
                            mergedPOI.Status__c = reader.poi.Status__c; 
                            mergedPOI.Supplier__c = reader.poi.Supplier__c; 
                            mergedPOI.Unit_of_Measure__c = reader.poi.Unit_of_Measure__c;  
                            mergedPOI.Tech_PRI_Create_Date__c= reader.poi.Tech_PRI_Create_Date__c;  
                        }
                        selectedPOISet.add(reader.poi.id);
                    }
                }
            }
            
            mergedPOI.Quantity__c = totalQty;    
            if(mergedPOI != null){
                insert mergedPOI;
            }
            
           
            // update related PRI's POI fields
            //Map<Id, Purchase_Request_Item__c> relatedPRIMap = getRelatedPRIMap();
            
            system.debug(selectedPOISet);
            system.debug(this.poCtrl.relatedPRIMap);
            
            for(string relatedPRI : this.poCtrl.relatedPRIMap.keySet()){
                
                for(string selectedPOI:selectedPOISet){
                    //system.debug('selectedPOI: ' + selectedPOI +' '+'Purchase_Order_Item__c: '+relatedPRIMap.get(relatedPRI).Purchase_Order_Item__c );
                    if(this.poCtrl.relatedPRIMap.get(relatedPRI).Purchase_Order_Item__c == selectedPOI){
                        this.poCtrl.relatedPRIMap.get(relatedPRI).Purchase_Order_Item__c = mergedPOI.id;
                    }
                }
            }
            
            system.debug(this.poCtrl.relatedPRIMap);
            
            if(this.poCtrl.relatedPRIMap.size() > 0){
                update this.poCtrl.relatedPRIMap.values();
            }               
        }
        return mergedPOI;
        
        */
     }

    public void removePOIAction() {
    
        List<Purchase_Order_Item__c> toBeUpdatedPOIList = new List<Purchase_Order_Item__c> ();
        List<Purchase_Order_Item__c> toBeDeletedPOIList = new List<Purchase_Order_Item__c> ();
        List<Purchase_Request_Item__c> toBeUpdatedPRIList = new List<Purchase_Request_Item__c> ();
        Purchase_Order__c tempPO = null;
        Integer counter = 1;
        
        this.poCtrl.isDisplayedMessage = false;
        this.poCtrl.message = ''; 
                
        for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList){
            if(reader.isChecked) {
                toBeDeletedPOIList.add(reader.poi);
            }
            else {
                reader.poi.Number__c = counter;
                toBeUpdatedPOIList.add(reader.poi);
                counter++;
            }
        }
    
        for(Purchase_Request_Item__c priReader : this.poCtrl.relatedPRIMap.values()) {
            for(Purchase_Order_Item__c poiReader : toBeDeletedPOIList) {
                if(priReader.Purchase_Order_Item__c == poiReader.Id) {
                    priReader.Purchase_Order__c = null;
                    priReader.Status__c = IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_APPROVED;
                    toBeUpdatedPRIList.add(priReader);
                    break;
                }
            }
        }
    
        if(!toBeDeletedPOIList.isEmpty() && !toBeUpdatedPRIList.isEmpty()) {
            update toBeUpdatedPRIList;
            delete toBeDeletedPOIList;
            this.poCtrl.relatedPRIMap = getRelatedPRIMap();
            this.poCtrl.attachmentList = getPRAttachment(this.poCtrl.relatedPRIMap);            
        }
        else {
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = Label.IDP_Have_Not_Selected_An_Item_Message; 
        
        }
        
        if(!toBeUpdatedPOIList.isEmpty()) {
            update toBeUpdatedPOIList;
        }
        
        if(this.poCtrl.isDisplayedMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.poCtrl.message));
        }

    }
    
    /*
    public void deliveriedPOI(IDPPurchaseOrderLineCtrl PRIIdLineItem){

        PRIIdLineItem.poi.status__c = IDPConstant.PURCHASE_ORDER_ITEM_STATUS_DELIVERED;
        
        system.debug(PRIIdLineItem.poi.status__c);
        if(PRIIdLineItem.poi != null){
            
            update PRIIdLineItem.poi;
            system.debug(PRIIdLineItem.poi);
        }
    }
    */
    
    //*----------------IDPPurchaseOrderLineCtrl class method(s)------------------------*//
    
    Public void removeSinglePOIAction(IDPPurchaseOrderLineCtrl pToBeRemovedLine){
        
        for(IDPPurchaseOrderLineCtrl  reader : this.poCtrl.POLineList) {
            if(reader == pToBeRemovedLine) {
                reader.isChecked = true;
            }
        }
        
        removePOIAction();
    }
    Public void preInputReceivedQtyAction(IDPPurchaseOrderLineCtrl pToBeRemovedLine){
         
        for(IDPPurchaseOrderLineCtrl  reader : this.poCtrl.POLineList) {
            if(reader == pToBeRemovedLine) {
                reader.receivedQuantity = reader.poi.Quantity__c;
            }
        }     
    }
    
    Public void applyDeliveredDate(IDPPurchaseOrderLineCtrl Line){
         
        List<Purchase_Order_Item__c> updateLineList = new List<Purchase_Order_Item__c>();
        for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList) {
               reader.poi.Delivery_Date__c = Line.poi.Delivery_Date__c;
               updateLineList.add(reader.poi);
        }     
        
       update updateLineList;
    }    
    
    
    //Cancel POI function is removed on 04/01/2017
    /*
    Public PageReference cancelPOI(IDPPurchaseOrderLineCtrl PRIIdLineItem){
    
        PageReference pof = null;
        
        PRIIdLineItem.poi.status__c = IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CANCEL;
        
        if(PRIIdLineItem.poi != null){
            update PRIIdLineItem.poi;
        }
        
        return pof;
    }
    */    
    
    //*----------------form edit method(s)------------------------*//   
    
     Public PageReference backAction(){
        PageReference prf = null;
        String preFix = '';
        Schema.DescribeSObjectResult r = Purchase_Order__c.sObjectType.getDescribe();
        preFix = r.getKeyPrefix();
        prf = new PageReference('/'+preFix);
        prf.setRedirect(true);
        return prf;
    }        


    Public PageReference cancelAction(){
        PageReference prf = null;     
        prf = new PageReference(Label.IDP_Path_IDPPurchaseOrderVFP + '?' + Label.IDP_Path_Parameter_POId +'=' + pid +'&' + Label.IDP_Path_Parameter_Mode +'=' + IDPPurchaseOrderCtrl.VIEW_MODE);
        prf.setRedirect(true);      
        poCtrl.isEdit = false;
        return prf;
    } 
    
    /*
    Public PageReference cancelPOAction(){
        
        List<Purchase_Order_Item__c> toBeUpdatedPOIList = new List<Purchase_Order_Item__c> ();
        PageReference prf = null;
        
        
        if(this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DRAFT ||
            this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED) {       
            
            this.poCtrl.po.Status__c = IDPConstant.PURCHASE_ORDER_STATUS_CANCELLED;
            
            
            for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList){
                if(reader.poi != null) {
                    if(reader.poi.Status__c == IDPConstant.PURCHASE_ORDER_ITEM_STATUS_DRAFT || 
                        reader.poi.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED) {
                        reader.poi.Status__c = IDPConstant.PURCHASE_ORDER_ITEM_STATUS_CANCEL;
                        toBeUpdatedPOIList.add(reader.poi);
                    }
                }
            }        
            
            if(!toBeUpdatedPOIList.isEmpty()) {
                update this.poCtrl.po;
                update toBeUpdatedPOIList;
            }
        }
        
        prf = new PageReference('/apex/IDPPurchaseOrderVFP?poid='+pid); 
        prf.setRedirect(true);      
        poCtrl.isEdit = false;
        return prf; 
    } 
    */  
    Public PageReference editAction(){
         PageReference prf = null;
         //poCtrl.isEdit = true;
         prf = new PageReference(Label.IDP_Path_IDPPurchaseOrderVFP + '?' + Label.IDP_Path_Parameter_POId +'=' + pid +'&' + Label.IDP_Path_Parameter_Mode +'=' + IDPPurchaseOrderCtrl.SAVE_MODE);
         prf.setRedirect(true);
         return prf;
    }

    Public void saveAction(){
        Boolean isValid = true;        
        this.poCtrl.isDisplayedMessage = false;
        this.poCtrl.message = '';
        if(this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED || 
            this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_PARTIAL_DELIVERED ||
            this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DELIVERED) {
            isValid = validateReceivedQuantity();
        }        
        else {

            isValid = validateToleranceLevel() && validateHeaderShippingDelivery();
        }
        if(isValid) {
            //moved to POI trigger
            /*
            if(this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED || 
                this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_PARTIAL_DELIVERED) {
                insertReceivingHistory();
            }
            */
            updatePOPOI('Save');
        }
        
        if(this.poCtrl.isDisplayedMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.poCtrl.message));
        }
    }
    Public void submitAction(){
        Boolean isValid = true;
        this.poCtrl.isDisplayedMessage = false;
        //this.poCtrl.isAttemptedToSubmit = true;
        isValid = validateToleranceLevel() && validateHeaderShippingDelivery();
        if(isValid) {
            for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList) {
                if(reader.poi != null){
                    reader.poi.Status__c = IDPConstant.PURCHASE_ORDER_STATUS_ORDERED;
                    this.poCtrl.po.Submitted_Date__c = date.today();
                }
            }
            //orderPRI();
            updatePOPOI('Submit');
            update orderPRI();
        }
        if(this.poCtrl.isDisplayedMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.poCtrl.message));
        }  
    }

    Public void updatePOPOI(String action){
        List <Purchase_Order_Item__c> tobeUpdatedPOIList = new List <Purchase_Order_Item__c>();
        //this.poCtrl.po.Delivery_Date__c = this.poCtrl.getEarliestDeliDate();
        
        List<Receiving_History__c> receivingHistList = getInsertReceivingHistory();

        for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList) {            
            reader.poi.Received_Quantity__c = reader.receivedQuantity;            
            tobeUpdatedPOIList.add(reader.poi);
        }

        // Call Web Service - Submit / Update po to Mule
         
        system.debug('updatePOPOI action:'+action);
        boolean isValid = true;
        if (action == 'Submit') {           
            isValid = callSubmitActionWebService(this.poCtrl.po, tobeUpdatedPOIList);
        }
        else if (action == 'Save') {
            isValid = callSaveActionWebService(this.poCtrl.po, tobeUpdatedPOIList, receivingHistList);
        }
        // Update SFDC records
        if (isValid) {
            update this.poCtrl.po;
            update tobeUpdatedPOIList;
        }
    }

    public boolean callSaveActionWebService(Purchase_Order__c po, List<Purchase_Order_Item__c> poi, List<Receiving_History__c> receivingHistList) {
        return true;
        /*
        try {   
            system.debug(LoggingLevel.ERROR, '@callSaveActionWebService():'+po.Status__c);
            if (po.Status__c != IDPConstant.PURCHASE_ORDER_STATUS_DRAFT)    
                IDPWebService.sendReceivingQtyToMule(po, receivingHistList);
    
            return true;

        } catch (Exception e) {
            system.debug('saveAction catch:'+e.getMessage());
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = e.getMessage();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.poCtrl.message));
        
            return false;
        }
        */
    }

    public boolean callSubmitActionWebService(Purchase_Order__c po, List<Purchase_Order_Item__c> poiList) {

        try { 
            po.Submitted_Date__c = System.today();
            po.M3_PO_No__c = IDPWebService.submitNewPOtoMule(po, poiList);
            po.Status__c = IDPConstant.PURCHASE_ORDER_STATUS_ORDERED;
            system.debug('New update m3 po no : '+po.M3_PO_No__c );
            //update po;
            return true;
        } catch (Exception e) {
            system.debug('submitAction catch:'+e.getMessage());
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = e.getMessage();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.message));
            return false;
        }
    }


    //Public void updatePOPOI(){
    //    List <Purchase_Order_Item__c> tobeUpdatedPOIList = new List <Purchase_Order_Item__c>();
    //    this.poCtrl.po.Delivery_Date__c = this.poCtrl.getEarliestDeliDate();
    //    update this.poCtrl.po;
    //    for(IDPPurchaseOrderLineCtrl  reader : this.poCtrl.POLineList) {
            
    //        reader.poi.Received_Quantity__c = reader.receivedQuantity;
            
            //moved to workflow 
            /*
            if(reader.poi.Status__c != IDPConstant.PURCHASE_ORDER_STATUS_DRAFT){
                if(reader.poi.Received_Quantity__c == 0) {
                    reader.poi.Status__c = IDPConstant.PURCHASE_ORDER_STATUS_ORDERED;
                } 
                
                if(reader.poi.Received_Quantity__c > 0) {
                    reader.poi.Status__c = IDPConstant.PURCHASE_ORDER_STATUS_PARTIAL_DELIVERED;
                }
                             
                if(reader.poi.Quantity__c == reader.poi.Received_Quantity__c) {
                    reader.poi.Status__c = IDPConstant.PURCHASE_ORDER_STATUS_DELIVERED;
                }
            }
            */
            
    //        tobeUpdatedPOIList.add(reader.poi);
    //    }
        
    //    update tobeUpdatedPOIList;
    //}
    
    Public List<Purchase_Request_Item__c> orderPRI(){
        List<Purchase_Request_Item__c> toBeUpdatedPRIList = new List<Purchase_Request_Item__c> ();
        
        for(Purchase_Request_Item__c reader : this.poCtrl.relatedPRIMap.values()) {
            if(reader.Status__c != IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_CANCELLED) {
                reader.Status__c = IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_ORDERED;
                toBeUpdatedPRIList.add(reader);
            }
        }
        
        return toBeUpdatedPRIList;
    }

    Public List <Receiving_History__c> getInsertReceivingHistory() {
        system.debug('@getInsertReceivingHistory()');
        List <Receiving_History__c> tobeInsertReceivingHistoryList = new List <Receiving_History__c> ();
        Receiving_History__c tempReceivingHistory = null;
        
        for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList) {

            system.debug('reader.poi:'+reader.poi);
            system.debug('reader.receivedQuantity:'+reader.receivedQuantity );
            system.debug('reader.poi.Received_Quantity__c:'+reader.poi.Received_Quantity__c );

            if(reader.poi != null) {
                if(reader.receivedQuantity != reader.poi.Received_Quantity__c) {
                    tempReceivingHistory = new Receiving_History__c ();
                    tempReceivingHistory.Purchase_Order_item__c = reader.poi.Id;
                    tempReceivingHistory.Purchase_Order_item__r = reader.poi;
                    tempReceivingHistory.quantity__c = reader.receivedQuantity - reader.poi.Received_Quantity__c;
                    tobeInsertReceivingHistoryList.add(tempReceivingHistory);
                }
            }        
        }
        
        return tobeInsertReceivingHistoryList;
    }
    



    /*
    Public void insertReceivingHistory() {
        List <Receiving_History__c> tobeInsertReceivingHistoryList = new List <Receiving_History__c> ();
        Receiving_History__c tempReceivingHistory = null;
        
        for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList) {
            if(reader.poi != null) {
                if(reader.receivedQuantity != reader.poi.Received_Quantity__c) {
                    tempReceivingHistory = new Receiving_History__c ();
                    tempReceivingHistory.Purchase_Order_item__c = reader.poi.Id;
                    tempReceivingHistory.quantity__c = reader.receivedQuantity - reader.poi.Received_Quantity__c;
                    tobeInsertReceivingHistoryList.add(tempReceivingHistory);
                }
            }        
        }
        
        if(!tobeInsertReceivingHistoryList.isEmpty()){
            insert tobeInsertReceivingHistoryList;
        }
    }
    */    
    Public Boolean validateReceivedQuantity() {
        Boolean isValid = true;
        this.poCtrl.isDisplayedMessage = false;
        this.poCtrl.message= '';

        for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList) {
            if(reader.getisExceededOrderedQuantity()) {
                isValid = false;
                this.poCtrl.isDisplayedMessage = true;
                this.poCtrl.message = Label.IDP_PO_Received_Quantity_Error_Message;
                break;
            }
            
            if(reader.getisReduceReceivedQuantity()) {
                isValid = false;
                this.poCtrl.isDisplayedMessage = true;
                this.poCtrl.message = Label.IDP_PO_Reduce_Received_Quantity_Error_Message;
                break;
            }
        }            
        return isValid;
    }
            
    /*Public Boolean validateToleranceLevel() {
        Boolean isValid = true;
        this.poCtrl.isDisplayedMessage = false;
        this.poCtrl.message = '';
        isValid = validateTotalAmountToleranceLevel();
        //isValid = (validateHeaderToleranceLevel() && validateLineToleranceLevel());
    
        if(!isValid) {
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = Label.IDP_PO_Exceed_Tolerance_Level_Warning.replace('@TOTALPRICE@', );
            //this.poCtrl.message = Label.IDP_PO_Exceed_Tolerance_Level_Message.replace(TOLERANCE_MESSAGE_REPLACEMENT, String.valueOf(this.poCtrl.po.Delivery_Site__r.Tolerance_Level__c)) ;             
        }
    
        return isValid;
    }*/

    Public Boolean validateToleranceLevel() {
        Boolean isValid = true;
        String currencyName = poCtrl.po.currency__r.name;
        Decimal toleranceAmount = 100; // USD
        Decimal currentEXRate = poCtrl.currentEXRate;
        Decimal oriTotalAmount = poCtrl.po.Original_Total_Amount__c;
        Decimal oriTotalTax = poCtrl.po.Original_Total_Tax__c;
        Decimal oriTotalShip = poCtrl.po.Original_Total_Shipping_Cost__c;
        Decimal oriTotalOther = poCtrl.po.Original_Total_Other_Cost__c;
        Decimal oriTotalPriceInclTaxShip = oriTotalAmount + oriTotalTax + oriTotalShip + oriTotalOther;  
        if(Math.abs( (poCtrl.getTotalPriceInclTaxShip() - oriTotalPriceInclTaxShip)* currentEXRate) > toleranceAmount){
            isValid = false;
        }
        if(!isValid) {
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = Label.IDP_PO_Exceed_Tolerance_Level_Warning
                                        //.replace('@TOTALPRICE@', poCtrl.po.Currency__r.Name + ' ' + poCtrl.po.Est_Tot_Price_Incl_Tax_Ship__c)
                                        .replace('@ORITOTALPRICE@', currencyName  + ' ' + oriTotalPriceInclTaxShip)
                                        .replace('@TOLERANCEAMOUNT@', 'USD' + ' ' + toleranceAmount.setScale(2));
        }
        
        
        /*
        this.poCtrl.isDisplayedMessage = false;
        this.poCtrl.message = '';

        Decimal toleranceAmount = 100; // USD
        Decimal totalPriceInclTaxShip = poCtrl.getTotalPriceInclTaxShip();
        Decimal oriTotalAmount = poCtrl.po.Original_Total_Amount__c;
        Decimal oriTotalTax = poCtrl.po.Original_Total_Tax__c;
        Decimal oriTotalShip = poCtrl.po.Original_Total_Shipping_Cost__c;
        Decimal oriTotalOther = poCtrl.po.Original_Total_Other_Cost__c;
        
        system.debug('oriTotalAmount:'+oriTotalAmount);
        system.debug('oriTotalTax:'+oriTotalTax);
        system.debug('oriTotalShip:'+oriTotalShip);
        system.debug('oriTotalOther:'+oriTotalOther);
        Decimal oriTotalPriceInclTaxShip = oriTotalAmount + oriTotalTax + oriTotalShip + oriTotalOther;
        Currency__c usdCurrency = [SELECT id FROM Currency__c WHERE Name = 'USD' LIMIT 1];
        Id fromCurrency = usdCurrency.Id;
        Id toCurrency = poCtrl.po.Currency__c;
        


        system.debug('totalPriceInclTaxShip:'+totalPriceInclTaxShip);
        system.debug('oriTotalPriceInclTaxShip:'+oriTotalPriceInclTaxShip);

        Exchange_Rate__c exchangeRate = [SELECT Tech_From_To_Currency_ID__c, Rate__c, From_Currency__c, To_Currency__c, To_Currency__r.Name 
                                        FROM Exchange_Rate__c 
                                        WHERE Is_Latest__c = true and Is_Book_Rate__c = true 
                                        AND From_Currency__c = :fromCurrency
                                        AND To_Currency__c = :toCurrency
                                        LIMIT 1
                                        ];
        
        toleranceAmount = toleranceAmount * exchangeRate.Rate__c;
        system.debug('toleranceAmount:'+toleranceAmount);
        system.debug('validateTotalAmountToleranceLevel:'+totalPriceInclTaxShip + '< ('+oriTotalPriceInclTaxShip+'+'+toleranceAmount+'):'+(totalPriceInclTaxShip < (oriTotalPriceInclTaxShip + toleranceAmount)));
        
        isValid = totalPriceInclTaxShip <= (oriTotalPriceInclTaxShip + toleranceAmount);

        if(!isValid) {
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = Label.IDP_PO_Exceed_Tolerance_Level_Warning
                                        .replace('@TOTALPRICE@', poCtrl.po.Currency__r.Name + ' ' + totalPriceInclTaxShip)
                                        .replace('@ORITOTALPRICE@', poCtrl.po.Currency__r.Name + ' ' + oriTotalPriceInclTaxShip)
                                        .replace('@TOLERANCEAMOUNT@', poCtrl.po.Currency__r.Name + ' ' + toleranceAmount.setScale(2));
        }
        */
        return isValid;
    }

    /*Public Boolean validateHeaderToleranceLevel() {
        Boolean isValid = true;
        
        if(this.poCtrl.getisTaxExceededToleranceLvl() || this.poCtrl.getisShippingExceededToleranceLvl() || this.poCtrl.getIsOtherCostExceededToleranceLvl()) {
            isValid = false;
        }
        return isValid;
    }*/
    
    /*Public Boolean validateLineToleranceLevel() {
        Boolean isValid = true;
        
        for(IDPPurchaseOrderLineCtrl  reader : this.poCtrl.POLineList) {
            if(reader.getisExceededToleranceLevel()) {
                isValid = false;
                break;
            }
        }
        return isValid;
    }*/
    
    
    
    Public Boolean validateHeaderShippingDelivery() {
        Boolean isValid = true;
        
        if(poCtrl.getisDeliveryAddressBlank()) {
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = Label.IDP_PO_Blank_Shipping_Address_Message;
            isValid = false;
        }
        if(this.poCtrl.po.Delivery_Date__c != null && this.poCtrl.po.Delivery_Date__c < System.today()){
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = 'The expected delivery date must not be earlier than today';
            isValid = false;            
        }
        /*
        if(poCtrl.getisShippingAddressBlank()) {
            this.poCtrl.isDisplayedMessage = true;
            this.poCtrl.message = Label.IDP_PO_Blank_Shipping_Address_Message;
            isValid = false;
        }
        */
        return isValid;
    }


   Public void getDeliveryAddress(){
        if(poCtrl.siteMap.containskey(poCtrl.po.Delivery_Site__c)){
            //poCtrl.po.Delivery_To__c = poCtrl.siteMap.get(poCtrl.po.Delivery_Site__c).Address__c;
            poCtrl.po.Shipping_Address_1__c = poCtrl.siteMap.get(poCtrl.po.Delivery_Site__c).Address_1__c;
            poCtrl.po.Shipping_Address_2__c = poCtrl.siteMap.get(poCtrl.po.Delivery_Site__c).Address_2__c;
            poCtrl.po.Shipping_Address_3__c = poCtrl.siteMap.get(poCtrl.po.Delivery_Site__c).Address_3__c;
            poCtrl.po.Shipping_Address_4__c = poCtrl.siteMap.get(poCtrl.po.Delivery_Site__c).Address_4__c;
        }
    }
    
    /*
    Public void submitAction(){
    
        List<Purchase_Order_Item__c> toBeUpdatedPOIList = new List<Purchase_Order_Item__c> ();
        PageReference prf = null;
        
        if(this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DRAFT) {
            this.poCtrl.po.Status__c = IDPConstant.PURCHASE_ORDER_STATUS_ORDERED;
            
            this.poCtrl.po.Submitted_Date__c = date.today();
            saveAction();
        }
               
    }      
    
    Public void saveAction(){
       
       
        List <Purchase_Order_Item__c> tobeUpdatedPOIList = new List <Purchase_Order_Item__c>();
        List <Receiving_History__c> tobeInsertReceivingHistoryList = new List <Receiving_History__c> ();
        Receiving_History__c tempReceivingHistory = null;
        PageReference prf = null;
        
        this.poCtrl.isDisplayedMessage = false;
        this.poCtrl.message = '';
        
        //saveAction will only be available 
        //for for warehouse public group
        //when PO Status is 
        // 1. Draft to save the changed Currency, Price, Delivery Date, Shipping Cost, Tax
        // 2. or Ordered to save the updated received quantity
        if(this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_DRAFT) {
        
            if(this.poCtrl.getisTaxExceededToleranceLvl() || this.poCtrl.getisShippingExceededToleranceLvl()) {
                this.poCtrl.isDisplayedMessage = true;
                this.poCtrl.message = Label.IDP_PO_Exceed_Tolerance_Level_Message.replace(TOLERANCE_MESSAGE_REPLACEMENT, String.valueOf(this.poCtrl.po.Delivery_Site__r.Tolerance_Level__c)) ;
            }
            if(!this.poCtrl.getisTaxExceededToleranceLvl() && !this.poCtrl.getisShippingExceededToleranceLvl()) {

                if(!this.poCtrl.POLineList.isEmpty()){
                    for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList) {
                        if(reader.poi != null) {
                            
                            if(reader.getisExceededToleranceLevel() || reader.getisExceededOrderedQuantity()) {
                                this.poCtrl.isDisplayedMessage = true;
                                this.poCtrl.message = Label.IDP_PO_Exceed_Tolerance_Level_Message.replace(TOLERANCE_MESSAGE_REPLACEMENT, String.valueOf(this.poCtrl.po.Delivery_Site__r.Tolerance_Level__c)) ;
                                tobeUpdatedPOIList.clear();
                                break;
                            }
                            
                            tobeUpdatedPOIList.add(reader.poi);
                        }
                    }
                }
            }               
        }
        else if(this.poCtrl.po.Status__c == IDPConstant.PURCHASE_ORDER_STATUS_ORDERED) {
            if(!this.poCtrl.POLineList.isEmpty()){
            
                for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.POLineList) {
                    
                    if(reader.poi != null) {
                        if(reader.receivedQuantity > reader.poi.Quantity__c){
                            this.poCtrl.isDisplayedMessage = true;
                            this.poCtrl.message = Label.IDP_PO_Received_Quantity_Error_Message;
                            tobeUpdatedPOIList.clear();
                            tobeInsertReceivingHistoryList.clear();
                            break;
                        }
                        else if(reader.receivedQuantity <= reader.poi.Quantity__c){
                            if(reader.receivedQuantity != reader.poi.Received_Quantity__c) {
                                tempReceivingHistory = new Receiving_History__c ();
                                tempReceivingHistory.Purchase_Order_item__c = reader.poi.Id;
                                tempReceivingHistory.quantity__c = reader.receivedQuantity - reader.poi.Received_Quantity__c;
                                
                                if(reader.poi.Received_Quantity__c != 0){
                                    reader.poi.status__c = IDPConstant.PURCHASE_ORDER_ITEM_STATUS_PARTIAL_DELIVERED;
                                }
                                
                                reader.poi.Received_Quantity__c = reader.receivedQuantity;
                                    
                                if(reader.receivedQuantity  == reader.poi.Quantity__c && reader.receivedQuantity  != 0){
                                    reader.poi.status__c = IDPConstant.PURCHASE_ORDER_ITEM_STATUS_DELIVERED;
                                } 
                                if(reader.receivedQuantity  == 0){
                                     reader.poi.status__c = IDPConstant.PURCHASE_ORDER_ITEM_STATUS_ORDERED ;
                                }                                   
                                                            
                                tobeUpdatedPOIList.add(reader.poi);
                                tobeInsertReceivingHistoryList.add(tempReceivingHistory);
                            }
                        }
                    }
                }
            }
        }


        if(this.poCtrl.isDisplayedMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.poCtrl.message));
        }
        else {
            //referesh earliest Delivery Date 
            this.poCtrl.po.Delivery_Date__c = this.poCtrl.poInit.getEariestDeliDate(pid);
            update this.poCtrl.po;        
        }
        
        if(!tobeUpdatedPOIList.isEmpty()) {
            update tobeUpdatedPOIList;
        }
        
        if(!tobeInsertReceivingHistoryList.isEmpty()) {
            insert tobeInsertReceivingHistoryList;
        }
    }     
     
     */       
/*
    Public void getDeliveryAddress(){
        if(prCtrl.siteMap.containskey(prCtrl.po.Delivery_Site__c)){
            prCtrl.po.Delivery_To__c = prCtrl.siteMap.get(prCtrl.po.Delivery_Site__c).Address__c;
        }
    }
*/

   
   
    /*
    Public Map<Id, Purchase_Order_Item__c> getPRIIdPOMap(Map<Id, Purchase_Request_Item__c> pPurchaseRequestItemMap) {
        
        Map<Id, Purchase_Order_Item__c> tempPRIdPOIMap = new Map<Id, Purchase_Order_Item__c> ();
        Map<Id, Purchase_Order_Item__c> POIMap = new Map<Id, Purchase_Order_Item__c> ();
        Map<Id, Id> priIdPOIIdMap = new Map<Id, Id> ();
        Purchase_Order_Item__c tempPOI = null;
        Id tempPOId = null;
        
        for(IDPPurchaseOrderLineCtrl reader : this.poCtrl.poLineList) {
            POIMap.put(reader.poi.Id, reader.poi);
        }
        
        for(Purchase_Request_Item__c reader : pPurchaseRequestItemMap.values()) {
            priIdPOIIdMap.put(reader.Id, reader.Purchase_Order_Item__c);
        }
        
        for(Id priId : priIdPOIIdMap.keySet()) {
            
            tempPOId = priIdPOIIdMap.get(priId);
            if(tempPOId != null) {
                if( POIMap.containsKey(tempPOId) ) {
                    tempPOI = POIMap.get(tempPOId);
                }
                if(tempPOI != null) {
                    tempPRIdPOIMap.put(priId, tempPOI );
                }
            }
        }
      
        return tempPRIdPOIMap;
    } 
    */     
    
}