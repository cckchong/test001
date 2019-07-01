public without sharing class IDPCreatePurchaseOrderActionCtrl{

    public static String SEPARATOR = ',';
    public static Integer SIZE_LIMIT = 1000;
    public static String REPLACE = '[^a-zA-Z0-9_,-]';

    public static final string PO_PICKLIST_DATE_REPLACE = '@DATE';
    public static final string PO_PICKLIST_PO_RECORD_REPLACE = '@RECORDNAME';
    public static final string PO_PICKLIST_PRI_NUMBER_REPLACE = '@NUMBER';

    Private IDPCreatePurchaseOrderCtrl cpoCtrl;

    Public IDPCreatePurchaseOrderActionCtrl(IDPCreatePurchaseOrderCtrl cpoCtrl) {
        this.cpoCtrl = cpoCtrl;
        
    }

    public boolean validateSearch(String pSelectedDeliverySite, String pSelectedCatalog, Date pSearchFromDate, Date pSearchToDate) {
        boolean isValid = true;

        isValid =   validateSelectedDeliverySite(pSelectedDeliverySite) && 
                    //validateSelectedCatalog(pSelectedCatalog) &&
                    validateSearchDate(pSearchFromDate,pSearchToDate);

        return isValid;

    }

    public boolean validateSearchDate(Date pSearchFromDate, Date pSearchToDate) {
        boolean isValid = true;

        if(pSearchFromDate!= null && pSearchToDate != null) {
            if( pSearchFromDate > pSearchToDate) {
                isValid = false;
                this.cpoCtrl.message =  Label.IDP_Create_PO_From_Date_After_To_Date_Error_Message;
            }
        }


        return isValid;
    }

    public boolean validateSelectedDeliverySite(String pSelectedDeliverySite) {
        boolean isValid = true;
        String tempSelectedDeliverySite = '';
        tempSelectedDeliverySite = pSelectedDeliverySite.replaceAll(REPLACE, '');

        if(String.isBlank(tempSelectedDeliverySite)) {
            isValid = false;
            this.cpoCtrl.message = Label.IDP_Create_PO_Not_Select_Site_Error_Message;
        }
        return isValid;
    }

    public boolean validateSelectedCatalog(String pSelectedCatalog) {
        boolean isValid = true;
        String tempSelectedCatalog = '';
        tempSelectedCatalog = pSelectedCatalog.replaceAll(REPLACE, '');

        if(String.isBlank(tempSelectedCatalog)) {
            isValid = false;
            this.cpoCtrl.message = Label.IDP_Create_PO_Not_Select_Catalog_Error_Message;
        }
        return isValid;
    }


    public Map<String, Purchase_Request_Item__c> getNotOrderedPurchaseRequestItemMap(String pSelectedDeliverySite, String pSelectedCatalog,String pSelectdCostsenter,String pSelectedSupplier,  Date pSearchFromDate, Date pSearchToDate) {

        Map<String, Purchase_Request_Item__c> tempNotOrderedPurchaseRequestItemMap = new Map<String, Purchase_Request_Item__c> ();
        boolean isValid = true;

        isValid = validateSearch(pSelectedDeliverySite, pSelectedCatalog, pSearchFromDate, pSearchToDate);

        if(isValid) {

            IDPCreatePurchaseOrderSearchClass sr = new IDPCreatePurchaseOrderSearchClass();
            tempNotOrderedPurchaseRequestItemMap = sr.getNotOrderedPurchaseRequestItemMap(pSelectedDeliverySite, pSelectedCatalog, pSelectdCostsenter, pSelectedSupplier, pSearchFromDate, pSearchToDate);
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, this.cpoCtrl.message));
        }

        return tempNotOrderedPurchaseRequestItemMap;

    }
    
    public List<SelectOption> searchPurchaseCostcenterAction(String pSelectedDeliverySite,String pSelectdsupplier) {
        IDPCreatePurchaseOrderSearchClass sr = new IDPCreatePurchaseOrderSearchClass ();
        //return null;
        return sr.updateCostCenterSelectOptionListAction(pSelectedDeliverySite,pSelectdsupplier);
        }
     
    //for updating Supplier SelectOption list after selecting the Delivery Site
    public List<SelectOption> updateSupplierSelectOptionListAction(String pSelectedDeliverySite) {
        IDPCreatePurchaseOrderSearchClass sr = new IDPCreatePurchaseOrderSearchClass ();
        return sr.updateSupplierSelectOptionListAction(pSelectedDeliverySite);
    }
    
    //for updating Purchase Order SelectOption list after selecting the Delivery Site and Supplier
    Public List<SelectOption> updateDraftPurchaseOrderSelectOptionListAction(String pSelectedDeliverySite, String pSelectedSupplier) {
        
        IDPCreatePurchaseOrderSearchClass sr = new IDPCreatePurchaseOrderSearchClass ();
        return sr.updateDraftPurchaseOrderSelectOptionListAction(pSelectedDeliverySite, pSelectedSupplier);

    }    
   
    public PageReference createDraftPurchaseOrderAction() {
        
        List<Purchase_Request_Item__c> selectedPRIList = new List<Purchase_Request_Item__c>();
        PageReference purchaseOrderVFP = null;
        Purchase_Order__c purchaseOrder;// = new Purchase_Order__c (); 
        List <Purchase_Order__c> newPOList = new List<Purchase_Order__c>();
        List <Purchase_Order__c> POList = new List<Purchase_Order__c>();
        Set <String> costCenterSet = new Set<String>();
        Map <String,String> cosstCenterGLMap = new Map <String,String>();
        Employee__c emp = null;
        Date tempDate = null;
        String batchId = datetime.now().format('YYYYMMddHHmmss');
        //String cost_center =purchaseOrder.Cost_Center__c;
        selectedPRIList = getSelectedPurchaseRequestItemIdList();
        Map<String,List<Purchase_Request_Item__c>> newPRIMap = new Map<String, List<Purchase_Request_Item__c>>(); 
        //Key = costCenter, value = prList      
        List<Purchase_Request_Item__c> tempPRIList;
        Map<String, String> costCenterDepartment = new Map<String, String>();
        
        for(Employee__c employee : [select id from employee__c where user__c = :UserInfo.getUserId()]){
            emp = employee;
        }
        if(!selectedPRIList.isEmpty()) {
            for(Purchase_Request_Item__c reader :selectedPRIList){
                costCenterSet.add(reader.Purchase_Request__r.Cost_Center__c);
                cosstCenterGLMap.put(reader.Purchase_Request__r.Cost_Center__c, reader.Purchase_Request__r.GL_Account__c);
            }
            
            
            for(cost_center__c cc : [select id, Tolabel(Department_Code__c), Name,
                                     Tolabel(Function_Code__c), Tolabel(Section_Code__c) 
                                     from cost_center__c where name in :cosstCenterGLMap.keyset()]){
                costCenterDepartment.put(cc.name, cc.Department_Code__c);
            }
            
            if(!costCenterSet.isempty()){
                for(String reader :costCenterSet){
                    purchaseOrder = new Purchase_Order__c ();
                    if(emp != null){
                        purchaseOrder.applicant__c = emp.id;
                    }
                    purchaseOrder.Supplier__c = selectedPRIList.get(0).Supplier__c;
                    purchaseOrder.Cost_Center__c = reader;
                    purchaseOrder.Department_Info__c = costCenterDepartment.get(reader);
                    purchaseOrder.GL_Account__c = cosstCenterGLMap.get(reader);
                    purchaseOrder.Delivery_Site__c = selectedPRIList.get(0).Purchase_Request__r.Delivery_Site__c;
                    purchaseOrder.Delivery_To__c = selectedPRIList.get(0).Purchase_Request__r.Delivery_To__c;
                    //purchaseOrder.Shipping_Address__c = selectedPRIList.get(0).Purchase_Request__r.Delivery_To__c;
                    purchaseOrder.Shipping_Address_1__c = selectedPRIList.get(0).Purchase_Request__r.Delivery_Site__r.Address_1__c;
                    purchaseOrder.Shipping_Address_2__c = selectedPRIList.get(0).Purchase_Request__r.Delivery_Site__r.Address_2__c;
                    purchaseOrder.Shipping_Address_3__c = selectedPRIList.get(0).Purchase_Request__r.Delivery_Site__r.Address_3__c;
                    purchaseOrder.Shipping_Address_4__c = selectedPRIList.get(0).Purchase_Request__r.Delivery_Site__r.Address_4__c;
                    purchaseOrder.Currency__c = selectedPRIList.get(0).Supplier__r.Currency__c;
                    purchaseOrder.Delivery_Method__c = selectedPRIList.get(0).Supplier__r.Delivery_Method__c;
                    purchaseOrder.Delivery_Terms__c = selectedPRIList.get(0).Supplier__r.Delivery_Terms__c;
                    purchaseOrder.Payment_Method__c= selectedPRIList.get(0).Supplier__r.Payment_Method__c;
                    purchaseOrder.Payment_Terms__c= selectedPRIList.get(0).Supplier__r.Payment_Terms__c;
                    purchaseOrder.Status__c = IDPConstant.PURCHASE_ORDER_STATUS_DRAFT; 
                    purchaseOrder.Batch_ID__c = batchId;
                    newPOList.add(purchaseOrder);
                     
                    //for prepare PR list
                    tempPRIList = new List<Purchase_Request_Item__c>();
                    for(Purchase_Request_Item__c tempReader :selectedPRIList){
                        if(reader ==  tempReader.Purchase_Request__r.Cost_Center__c){
                            tempPRIList.add(tempReader);
                        }
                    }
                    newPRIMap.put(reader, tempPRIList);             
                }            
            }
            if(!newPOList.isEmpty()){
                upsert newPOList;
            }
            for(Purchase_Order__c po : [select id, PO_Item_Count__c, Cost_Center__c, Currency__c
                                        from Purchase_Order__c where id in :newPOList]){
                POList.add(po);
            }
            
            for(Purchase_Order__c po : POList){
                createPurchaseOrderItem(po, newPRIMap.get(po.Cost_Center__c));
            }
            POList  = new List <Purchase_Order__c>();
            for(Purchase_Order__c po : [SELECT Id, PO_Item_Count__c, Currency__c, 
                                    Total_Shipping_Cost__c, Total_Tax__c, Total_Other_Cost__c,cost_center__c,
                                    Original_Total_Amount__c, Original_Total_Shipping_Cost__c, Original_Total_Tax__c, Original_Total_Other_Cost__c,
                                    (SELECT Id, Delivery_Date__c FROM Purchase_Order_Items__r)
                                    FROM Purchase_Order__c where id = :newPOList]){
                //po.Total_Shipping_Cost__c = po.Original_Total_Shipping_Cost__c;
                //po.Total_Tax__c = po.Original_Total_Tax__c;
                //po.Total_Other_Cost__c = po.Original_Total_Other_Cost__c;
                purchaseOrder.Total_Shipping_Cost__c = 0;
                purchaseOrder.Total_Tax__c = 0;
                purchaseOrder.Total_Other_Cost__c = 0;
                tempDate = null;
                for(Purchase_Order_Item__c poi : po.Purchase_Order_Items__r){
                     if(tempDate == null){
                         tempDate = poi.Delivery_Date__c;
                     }
                                      
                     if(tempDate > poi.Delivery_Date__c){
                         tempDate = poi.Delivery_Date__c;
                     }    
                }
                po.Delivery_Date__c = tempDate;      
                POList.add(po);
            }
            if(!POList.isEmpty()){
                update POList;
            }
            
            //createPurchaseOrderItem(purchaseOrder, selectedPRIList);
            
            /*
            for(Purchase_Order__c  po : [SELECT Id, PO_Item_Count__c, Currency__c ,cost_center__c
                                     FROM Purchase_Order__c 
                                    where id in :newPOList]){
                POList.add(po);
            }
        
            insert newPOList;
            //set po.id for New PR List
            List<Purchase_Request_Item__c> newPRIList = new List<Purchase_Request_Item__c>();
            for(Purchase_Order__c po : POList){
               List<Purchase_Request_Item__c> tempPRIList = newPRIMap.get(po.cost_center__c);
               if(!tempPRIList.isEmpty()){
                   for(Purchase_Request_Item__c pr : tempPRIList){
                       pr.Purchase_Order__c = po.id;
                       newPRIList.add(pr);
                   }
               }                 
            }
            insert newPOList;
            */
            
            /*
            purchaseOrder = [SELECT Id, PO_Item_Count__c, Currency__c FROM Purchase_Order__c where id = :purchaseOrder.Id Limit 1];

            createPurchaseOrderItem(purchaseOrder, selectedPRIList);
            
            purchaseOrder = [SELECT Id, PO_Item_Count__c, Currency__c, 
                                    Total_Shipping_Cost__c, Total_Tax__c, Total_Other_Cost__c,cost_center__c,
                                    Original_Total_Amount__c, Original_Total_Shipping_Cost__c, Original_Total_Tax__c, Original_Total_Other_Cost__c,
                                    (SELECT Id, Delivery_Date__c FROM Purchase_Order_Items__r)
                                    FROM Purchase_Order__c where id = :purchaseOrder.Id Limit 1];
            purchaseOrder.Total_Shipping_Cost__c = purchaseOrder.Original_Total_Shipping_Cost__c;
            purchaseOrder.Total_Tax__c = purchaseOrder.Original_Total_Tax__c;
            purchaseOrder.Total_Other_Cost__c = purchaseOrder.Original_Total_Other_Cost__c;
            
            for(Purchase_Order_Item__c reader : purchaseOrder.Purchase_Order_Items__r){
                 if(tempDate == null){
                     tempDate = reader.Delivery_Date__c;
                 }
                                  
                 if(tempDate > reader.Delivery_Date__c){
                     tempDate = reader.Delivery_Date__c;
                 }    
            }
            
            purchaseOrder.Delivery_Date__c = tempDate;              
            update purchaseOrder;
            */
            purchaseOrderVFP = new PageReference('/apex/IDPPurchaseOrderResultVFP'+'?bid='+batchId);
        }
        return purchaseOrderVFP;
    }
    

    
    
    
    
    Public PageReference addToExistingPurchaseOrderAction(String pSelectedPurchaseOrder) {
        
        List<Purchase_Request_Item__c> selectedPRIList = new List<Purchase_Request_Item__c>();
        PageReference purchaseOrderVFP = null;
        Purchase_Order__c purchaseOrder = null;
        Date tempDate = null;
        
        selectedPRIList = getSelectedPurchaseRequestItemIdList();
        
        if(!selectedPRIList.isEmpty()) {

            if(!String.isBlank(pSelectedPurchaseOrder)) {
                purchaseOrder = [SELECT Id, PO_Item_Count__c, Currency__c FROM Purchase_Order__c where id = :pSelectedPurchaseOrder  Limit 1];          
            }
            
            if(purchaseOrder != null) {
                createPurchaseOrderItem(purchaseOrder, selectedPRIList);
                
                purchaseOrder = [SELECT Id, PO_Item_Count__c, Currency__c, 
                                        Total_Shipping_Cost__c, Total_Tax__c, Total_Other_Cost__c,
                                        Original_Total_Amount__c, Original_Total_Shipping_Cost__c, Original_Total_Tax__c, Original_Total_Other_Cost__c,cost_center__c,
                                        (SELECT Id, Delivery_Date__c FROM Purchase_Order_Items__r)
                                        FROM Purchase_Order__c where id = :purchaseOrder.Id Limit 1];
                //purchaseOrder.Total_Shipping_Cost__c = purchaseOrder.Original_Total_Shipping_Cost__c;
                //purchaseOrder.Total_Tax__c = purchaseOrder.Original_Total_Tax__c;
                //purchaseOrder.Total_Other_Cost__c = purchaseOrder.Original_Total_Other_Cost__c;
                purchaseOrder.Total_Shipping_Cost__c = 0;
                purchaseOrder.Total_Tax__c = 0;
                purchaseOrder.Total_Other_Cost__c = 0;
                
                for(Purchase_Order_Item__c reader : purchaseOrder.Purchase_Order_Items__r){
                     if(tempDate == null){
                         tempDate = reader.Delivery_Date__c;
                     }
                                      
                     if(tempDate > reader.Delivery_Date__c){
                         tempDate = reader.Delivery_Date__c;
                     }    
                }
                purchaseOrder.Delivery_Date__c = tempDate;                
                update purchaseOrder;     
                           
                purchaseOrderVFP = new PageReference('/' + purchaseOrder.Id);        
            }
        }

        return purchaseOrderVFP;    
    }
    
    Public List<Purchase_Request_Item__c> getSelectedPurchaseRequestItemIdList() {
        
        List<Purchase_Request_Item__c> selectedPRIList = new List<Purchase_Request_Item__c>();
        for(IDPCreatePurchaseOrderLIneCtrl reader : this.cpoCtrl.cpoLineList) {
            if(reader.isChecked) {        
                selectedPRIList.add(reader.pri);   
            }
        }
        
        if(selectedPRIList.isEmpty()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.IDP_Have_Not_Selected_An_Item_Message));
        }
        return selectedPRIList;
    }
    
    
    public void createPurchaseOrderItem(Purchase_Order__c pPO, List<Purchase_Request_Item__c> pSelectedPRIList) {

        Map<String, Purchase_Order_Item__c> priIdinsertPOIMap = new Map<String, Purchase_Order_Item__c>();
        Map<String, Exchange_Rate__c> fromToCurIdERMap = new Map<String, Exchange_Rate__c> ();
        List<Purchase_Request_Item__c> updatePRIList = new List<Purchase_Request_Item__c> ();
        Set<String> techFromToCurrencyIdSet = new Set<String> ();
        Exchange_Rate__c taxCostExchangeRate = null;
        String fromCurrency = null;
        String toCurrency = null;
        Purchase_Order_Item__c tempPOI = null;

        Integer counter = Integer.valueOf(pPo.PO_Item_Count__c) + 1;
        //for manual sharing, need to update po Id in pri first
        for(Purchase_Request_Item__c reader : pSelectedPRIList) {
            reader.Purchase_Order__c = pPo.Id;
            updatePRIList.add(reader);
        }
        if(!updatePRIList.isEmpty()) {
            update updatePRIList;
        }
        
        
        
        for(Purchase_Request_Item__c reader : pSelectedPRIList) {    
            if(reader.Currency__c != null) {
                fromCurrency = reader.Currency__c;
                toCurrency = pPo.Currency__c;
                fromCurrency = fromCurrency.subString(0,15);
                toCurrency = toCurrency.subString(0,15);
                techFromToCurrencyIdSet.add(fromCurrency + toCurrency);
            }
        }

        fromToCurIdERMap = getExchangeRate(techFromToCurrencyIdSet);
        /*
        for(Exchange_Rate__c reader : [SELECT Tech_From_To_Currency_ID__c, Rate__c, From_Currency__c, To_Currency__c, To_Currency__r.Name 
                                                            FROM Exchange_Rate__c 
                                                            WHERE Is_Latest__c = true and Is_Book_Rate__c = true 
                                                            AND From_Currency__c = :fromCurrency 
                                                            AND To_Currency__c = :toCurrency  
                                                            LIMIT 1]) {
            taxCostExchangeRate = reader;                                                   
        }
        */
                                                          
        for(Purchase_Request_Item__c reader : pSelectedPRIList) {
            tempPOI = new Purchase_Order_Item__c();
            tempPOI.Purchase_Order__c = pPO.Id;
            //tempPOI.Order_Date__c = ;
            //tempPOI.Delivery_Date__c = ;
            tempPOI.Buyer_Remark__c = reader.remark__c;
            tempPOI.Delivery_Address__c = reader.Purchase_Request__r.Delivery_To__c;
            tempPOI.Delivery_Date__c = reader.Purchase_Request__r.Need_by_Date__c;
            tempPOI.Catalog_Item__c = reader.Catalog_Item__c;
            tempPOI.Item_Description__c = reader.Catalog_Item__r.Description__c ;
            tempPOI.Supplier__c = reader.Supplier__c;
            tempPOI.Currency__c = reader.Currency__c;
            tempPOI.Price__c = reader.Price__c;
            tempPOI.Tech_Price__c = reader.Price__c;
            tempPOI.Unit_of_Measure__c = reader.Unit_Of_Measure__c;            
            tempPOI.Quantity__c = reader.Quantity__c;
            tempPOI.Tech_PRI_Create_Date__c = reader.CreatedDate;
            //tempPOI.Received_Quantity__c = ;
            tempPOI.Status__c = IDPConstant.PURCHASE_ORDER_ITEM_STATUS_DRAFT;
            tempPOI.Number__c = counter;
            tempPOI.Orig_Other_Cost_Total_Amount__c = 0;
            tempPOI.Orig_Shipping_Cost_Total_Amount__c = 0;
            tempPOI.Orig_Tax_Total_Amount__c = 0;
            if(reader.Other_Cost_Original_Total_Amount__c != null){
                tempPOI.Orig_Other_Cost_Total_Amount__c = reader.Other_Cost_Original_Total_Amount__c;
            }
            if(reader.Shipping_Cost_Original_Total_Amount__c != null){
                tempPOI.Orig_Shipping_Cost_Total_Amount__c = reader.Shipping_Cost_Original_Total_Amount__c;
            }
            if(reader.Tax_Original_Total_Amount__c != null){
                tempPOI.Orig_Tax_Total_Amount__c = reader.Tax_Original_Total_Amount__c;
            }
            tempPOI.Additional_Cost__c = tempPOI.Orig_Other_Cost_Total_Amount__c + tempPOI.Orig_Shipping_Cost_Total_Amount__c + tempPOI.Orig_Tax_Total_Amount__c;            
            fromCurrency = reader.Currency__c;
            toCurrency = pPo.Currency__c;
            fromCurrency = fromCurrency.subString(0,15);
            toCurrency = toCurrency.subString(0,15);
            system.debug(fromToCurIdERMap);
            if(fromToCurIdERMap.containsKey(fromCurrency + toCurrency)) {
                Decimal rate = fromToCurIdERMap.get(fromCurrency + toCurrency).Rate__c;
                tempPOI.Tech_PO_Currency_PRI_Amount__c = reader.Amount__c * rate;
                tempPOI.Tech_PO_Currency_PRI_Tax__c = reader.Tax_Original_Total_Amount__c * rate;
                tempPOI.Tech_PO_Currency_PRI_Shipping__c = reader.Shipping_Cost_Original_Total_Amount__c * rate;
                tempPOI.Tech_PO_Currency_PRI_Other_Cost__c = reader.Other_Cost_Original_Total_Amount__c * rate;
            }
            system.debug('tempPR:'+reader);
            system.debug('tempPOI:'+tempPOI);

            priIdinsertPOIMap.put(reader.Id, tempPOI);  
            
            counter++;                         
        }
        
        updatePRIList = new List<Purchase_Request_Item__c> ();    
        if(!priIdinsertPOIMap.values().isEmpty()) {
            insert priIdinsertPOIMap.values();
            
            for(Purchase_Request_Item__c reader : pSelectedPRIList) {
                reader.Purchase_Order_Item__c = priIdinsertPOIMap.get(reader.Id).Id;
                updatePRIList.add(reader);
            }
            
            update updatePRIList;
        }
 
    }
    
    Public void cancelPurchaseRequestItemAction(String pPRIId) {
        Purchase_Request_Item__c updatePRI = null;
        Integer counter = 0;
        for(Integer i = 0; i < cpoCtrl.cpoLineList.size() ; i++) {
            if(cpoCtrl.cpoLineList.get(i).pri.Id == pPRIId){
                cpoCtrl.cpoLineList.get(i).pri.Status__c = IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_CANCELLED;
                updatePRI = cpoCtrl.cpoLineList.get(i).pri;
                system.debug(updatePRI);
                break;
            }
            counter++;
        }
        cpoCtrl.cpoLineList.remove(counter);

        if(updatePRI != null) {
            update updatePRI;
        }
    }
    
    Public Map<String, Exchange_Rate__c> getExchangeRate(Set<String> pTechFromToCurrencyIdSet) {
        
        Map<String, Exchange_Rate__c> tempFromToCurIdERMap = new Map<String, Exchange_Rate__c> ();
        
        for(Exchange_Rate__c reader : [SELECT Tech_From_To_Currency_ID__c, Rate__c, From_Currency__c, To_Currency__c, To_Currency__r.Name 
                                        FROM Exchange_Rate__c 
                                        WHERE Is_Latest__c = true and Is_Book_Rate__c = true 
                                        AND Tech_From_To_Currency_ID__c in : pTechFromToCurrencyIdSet
                                        ]) {
            tempFromToCurIdERMap.put(reader.Tech_From_To_Currency_ID__c, reader);                         
        }        
    
        return tempFromToCurIdERMap;
    }
    
    
    //private with sharing class SearchResultWrapperClass {
        

    //    private Map<String, Purchase_Request_Item__c> getNotOrderedPurchaseRequestItemMap(String pSelectedDeliverySite, String pSelectedCatalog, String pSelectedSupplier,  Date pSearchFromDate, Date pSearchToDate) {
    //        ApexPages.getMessages().clear();    
    //        Map<String, Purchase_Request_Item__c> tempNotOrderedPurchaseRequestItemMap = new Map<String, Purchase_Request_Item__c> ();
    //        String tempSelectedCatalog = '';
    //        List<String> catalogIdList = new List<String> ();

    //        if(pSearchFromDate == null) {
    //            pSearchFromDate = Date.newInstance(1900, 1, 1);
    //        }
    //        if(pSearchToDate == null) {
    //            pSearchToDate = Date.newInstance(2199, 12, 31);
    //        }

    //        tempSelectedCatalog = pSelectedCatalog.replaceAll(REPLACE, '');

    //        if(!String.isBlank(tempSelectedCatalog)) {
    //            catalogIdList = tempSelectedCatalog.split(SEPARATOR);

    //        }

    //        if(!String.isBlank(pSelectedDeliverySite) && !String.isBlank(pSelectedSupplier)) {
                
    //            pSelectedDeliverySite = pSelectedDeliverySite.replaceAll(REPLACE,'');
    //            List<String> pSelectedDeliverySiteList = pSelectedDeliverySite.split(SEPARATOR);
                
    //            for(Purchase_Request_item__c reader : [SELECT Id,  Purchase_Request__c, CreatedDate,
    //                                                        Name, Purchase_Request__r.Name,
    //                                                        Status__c,Catalog_Item__c, Catalog_Item__r.Description__c, Catalog_Item__r.Catalog__r.Display_Name__c,
    //                                                        Catalog_Item_Name__c, Currency__r.Name,
    //                                                        Currency__c, Price__c, Amount__c, 
    //                                                        Quantity__c, Unit_of_Measure__c, Remark__c, 
    //                                                        Local_Currency__c, Local_Exchange_Rate__c, Local_Amount__c,
    //                                                        Standard_Currency__c, Standard_Exchange_Rate__c, Standard_Amount__c,
    //                                                        Supplier__c, Supplier__r.Name, Supplier__r.Currency__c,
    //                                                        Supplier__r.Delivery_Method__c, Supplier__r.Delivery_Terms__c, Supplier__r.Payment_Method__c, Supplier__r.Payment_Terms__c,
    //                                                        Purchase_Request__r.Delivery_Site__c, Purchase_Request__r.Delivery_Site__r.Name,
    //                                                        Purchase_Request__r.Delivery_To__c, 
    //                                                        Purchase_Request__r.Tech_Applicant_Site_Id__c, Purchase_Request__r.Tech_Applicant_Site_Name__c,
    //                                                        Purchase_Request__r.On_Behalf_Of__r.Name, Purchase_Request__r.Catalog__r.Display_Name__c,
    //                                                        Is_Direct_fulfillment__c, Purchase_Request__r.Need_By_Date__c,
    //                                                        Tax_Standard_Total_Amount__c, Shipping_Cost_Standard_Total_Amount__c, Other_Cost_Standard_Total_Amount__c,
    //                                                        Tax_Original_Total_Amount__c , Shipping_Cost_Original_Total_Amount__c, Other_Cost_Original_Total_Amount__c
    //                                                        //Delivery_Site__c, Delivery_Site__r.Name,
    //                                                        //Delivery_To__c                                                        
    //                                                    FROM Purchase_Request_Item__c
    //                                                    WHERE Status__c = :IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED
    //                                                    AND Is_Direct_fulfillment__c = false
    //                                                    AND Purchase_Order_Item__c = null
    //                                                    //AND Purchase_Request__r.Delivery_Site__c in : pSelectedDeliverySiteList
    //                                                    AND Purchase_Request__r.Tech_Applicant_Site_Id__c in : pSelectedDeliverySiteList
    //                                                    AND Supplier__c = :pSelectedSupplier
    //                                                    AND Purchase_Request__r.Need_By_Date__c >= :pSearchFromDate
    //                                                    AND Purchase_Request__r.Need_By_Date__c <= :pSearchToDate
    //                                                    ORDER BY Purchase_Request__r.Name ASC, Name ASC] ){
                    
    //                tempNotOrderedPurchaseRequestItemMap.put(reader.Id, reader);
    //            }        
    //        }
    //        return tempNotOrderedPurchaseRequestItemMap;
    //    }      
        
    //    private List<SelectOption> updateDraftPurchaseOrderSelectOptionListAction(String pSelectedDeliverySite, String pSelectedSupplier) {
        
    //        List<SelectOption> tempDraftPurchaseOrderSelectOptionList = new List<SelectOption> ();
            
    //        pSelectedDeliverySite = pSelectedDeliverySite.replaceAll(REPLACE,'');
    //        List<String> pSelectedDeliverySiteList = pSelectedDeliverySite.split(SEPARATOR);
            
    //        for (Purchase_Order__c reader : [SELECT Id, Name, Supplier__c, Delivery_Site__c, Status__c, CreatedDate, PO_Item_Count__c
    //                                            FROM Purchase_Order__c 
    //                                            WHERE Status__c = : IDPConstant.PURCHASE_ORDER_STATUS_DRAFT 
    //                                            //AND Delivery_Site__c in :pSelectedDeliverySiteList
    //                                            AND Supplier__c = :pSelectedSupplier
    //                                            AND CreatedById = :UserInfo.getUserId()
    //                                            ORDER BY Name]) {
    //            //tempDraftPurchaseOrderSelectOptionList.add(new SelectOption(reader.Id, reader.Name));
                
    //            String displayFormat = Label.IDP_Shopping_Cart_PR_Picklist_Format;
    //            DateTime displayCreatedDate = DateTime.newInstance(reader.createdDate.year(), reader.createdDate.month(), reader.createdDate.day(), 0, 0, 0);

    //            displayFormat = displayFormat.replace(PO_PICKLIST_DATE_REPLACE, String.valueOf(displayCreatedDate.format('dd/MM/yyyy')));
    //            displayFormat = displayFormat.replace(PO_PICKLIST_PO_RECORD_REPLACE, reader.Name);
    //            displayFormat = displayFormat.replace(PO_PICKLIST_PRI_NUMBER_REPLACE , String.valueOf(reader.PO_Item_Count__c));
                
    //            tempDraftPurchaseOrderSelectOptionList.add(new SelectOption(reader.Id, displayFormat));
    //        }

    //        return tempDraftPurchaseOrderSelectOptionList;
    //    }      
        
    //    private List<SelectOption> updateSupplierSelectOptionListAction(String pSelectedDeliverySite) {
    //        Map<String, SelectOption> existingSupplierSelectOptionMap = new  Map<String, SelectOption>();
    //        List<SelectOption> tempDeliverySiteSelectOptionList = new List<SelectOption> ();
    //        SelectOption tempSelectOption = null;
            
    //        pSelectedDeliverySite = pSelectedDeliverySite.replaceAll(REPLACE,'');
    //        List<String> pSelectedDeliverySiteList = pSelectedDeliverySite.split(SEPARATOR);
              
    //        for(Purchase_Request_item__c reader : [SELECT Id, Status__c, Is_Direct_fulfillment__c, Purchase_Order_Item__c,
    //                                                        Purchase_Request__r.Delivery_Site__c, Purchase_Request__r.Delivery_Site__r.Name,
    //                                                        Supplier__c, Supplier__r.name
    //                                                    FROM Purchase_Request_Item__c
    //                                                    WHERE Status__c = :IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED
    //                                                    AND Is_Direct_fulfillment__c = false
    //                                                    AND Purchase_Order_Item__c = null
    //                                                    //AND Purchase_Request__r.Delivery_Site__c in : pSelectedDeliverySiteList
    //                                                    AND Purchase_Request__r.Tech_Applicant_Site_Id__c in : pSelectedDeliverySiteList
    //                                                    ORDER BY Supplier__r.Name ASC] ){
                
    //            if(reader.Supplier__c!= null  &&  !String.isBlank(reader.Supplier__r.Name)) {
    //                if(!existingSupplierSelectOptionMap.containsKey(reader.Supplier__c)) {
    //                    tempSelectOption = new SelectOption(reader.Supplier__c, reader.Supplier__r.name);
    //                    existingSupplierSelectOptionMap.put(reader.Supplier__c, tempSelectOption);
    //                    tempDeliverySiteSelectOptionList.add(tempSelectOption);                   
    //                }
                            
    //            }                                         
    //        }
            
    //        return tempDeliverySiteSelectOptionList;
    //    }
    //}

}