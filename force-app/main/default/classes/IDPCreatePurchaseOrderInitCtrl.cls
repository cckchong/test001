public without sharing class IDPCreatePurchaseOrderInitCtrl{

    Public static String SEPARATOR = ',';
    Public static Integer SIZE_LIMIT = 1000;
    Public static String REPLACE = '[^a-zA-Z0-9_,-]';
    
    public static final string PO_PICKLIST_DATE_REPLACE = '@DATE';
    public static final string PO_PICKLIST_PO_RECORD_REPLACE = '@RECORDNAME';
    public static final string PO_PICKLIST_PRI_NUMBER_REPLACE = '@NUMBER';

    //Private Map<String, List<SelectOption>> deliverySiteSupplierSelectOptionListMap;
    //Private Map<String, List<SelectOption>> deliverySiteSupplierDraftPOSelectOptionListMap;
    private List<SelectOption> deliverySiteSelectOptionList;
    private List<SelectOption> supplierSelectOptionList;
    private List<SelectOption> costCenterSelectOptionList;
    private List<SelectOption> draftPurchaseOrderSelectOptionList;
    private List<SelectOption> catalogSelectOptionList;

    //private Employee__c userEmployee;
    private String selectedDeliverySite;
    private String selectedSupplier;
    private String selectedPurchaseOrder;
    private String selectedCostCenter;
    private String message;
    private Boolean isDraftPOExisted;
    private Boolean isAvaliablePRIExisted;
    

    private IDPCreatePurchaseOrderCtrl cpoCtrl;

    public IDPCreatePurchaseOrderInitCtrl(IDPCreatePurchaseOrderCtrl cpoCtrl) {
        //Moved to Init() Method for Clear search criteria button
        Init(cpoCtrl);
    }


    public void Init(IDPCreatePurchaseOrderCtrl cpoCtrl) {
        setupInitSetting();
        cpoCtrl.deliverySiteSelectOptionList = this.deliverySiteSelectOptionList;
        cpoCtrl.supplierSelectOptionList = this.supplierSelectOptionList;
        cpoCtrl.costCenterSelectOptionList = this.costCenterSelectOptionList;
        cpoCtrl.draftPurchaseOrderSelectOptionList = this.draftPurchaseOrderSelectOptionList;
        cpoCtrl.catalogSelectOptionList = this.catalogSelectOptionList;
        //cpoCtrl.deliverySiteSupplierSelectOptionListMap = this.deliverySiteSupplierSelectOptionListMap;
        //cpoCtrl.deliverySiteSupplierDraftPOSelectOptionListMap = this.deliverySiteSupplierDraftPOSelectOptionListMap;
        cpoCtrl.selectedDeliverySite = this.selectedDeliverySite;
        cpoCtrl.selectedSupplier = this.selectedSupplier;
        cpoCtrl.selectedPurchaseOrder = this.selectedPurchaseOrder;
        cpoCtrl.message = this.message;
        cpoCtrl.isDraftPOExisted = this.isDraftPOExisted;
        cpoCtrl.isAvaliablePRIExisted = this.isAvaliablePRIExisted;
        this.cpoCtrl = cpoCtrl;
    }

    Public void setupInitSetting(){
        //this.deliverySiteSupplierSelectOptionListMap = new Map<String, List<SelectOption>> ();
        //this.deliverySiteSupplierDraftPOSelectOptionListMap = new Map<String, List<SelectOption>> ();
        this.deliverySiteSelectOptionList = new List<SelectOption> ();
        this.supplierSelectOptionList = new List<SelectOption> ();
        this.draftPurchaseOrderSelectOptionList = new List<SelectOption> ();
        this.catalogSelectOptionList = new List<SelectOption> ();
        this.costCenterSelectOptionList = new List<SelectOption> ();
        this.selectedDeliverySite = '';
        this.selectedCostCenter = '';
        this.selectedSupplier = '';
        this.selectedPurchaseOrder = '';
        this.message = '';
        this.isDraftPOExisted = false;
        this.isAvaliablePRIExisted = false;
        //getfilterSelectOptionList();
        
        deliverySiteSelectOptionList = getDeliverySiteSelectOptionList();
        
        if(!this.deliverySiteSelectOptionList.isEmpty()) {
            this.selectedDeliverySite = this.deliverySiteSelectOptionList.get(0).getValue();
        }
       
        if(!String.isBlank(this.selectedDeliverySite)) {
            this.supplierSelectOptionList = getSupplierSelectOptionList();
        }
        
        if(!this.supplierSelectOptionList.isEmpty()) {
            this.selectedSupplier = this.supplierSelectOptionList.get(0).getValue();
        }
        
        if (!String.isBlank(this.selectedDeliverySite) || !String.isBlank(this.selectedSupplier)){
            this.costCenterSelectOptionList = getCostCenterOptionList();
        }
        
        if(!this.costCenterSelectOptionList .isEmpty()) {
            this.selectedCostCenter = this.costCenterSelectOptionList.get(0).getValue();
        }
        
        
        if(!String.isBlank(this.selectedDeliverySite) && !String.isBlank(this.selectedSupplier)) {
            this.draftPurchaseOrderSelectOptionList = getDraftPurchaseOrderelectOptionList();
        }
        
        if(!draftPurchaseOrderSelectOptionList.isEmpty()){
            this.selectedPurchaseOrder = this.draftPurchaseOrderSelectOptionList.get(0).getValue();
            this.isDraftPOExisted = true;
        }
        else {
            this.isDraftPOExisted = false;
        }
        
        system.debug('supplierSelectOptionList:'+supplierSelectOptionList);
        system.debug('deliverySiteSelectOptionList:'+deliverySiteSelectOptionList);

        if(this.supplierSelectOptionList.isEmpty() || this.deliverySiteSelectOptionList.isEmpty()) {
            this.isAvaliablePRIExisted = false;
            this.message = Label.IDP_Create_PO_Not_Available_PRI_Message;
        }
        else if(!this.supplierSelectOptionList.isEmpty() && !this.deliverySiteSelectOptionList.isEmpty()) {
            this.isAvaliablePRIExisted = true;
        }

        //this.catalogSelectOptionList = getCatalogSelectOptionList(this.selectedDeliverySite);
        
        if(!this.isAvaliablePRIExisted) {
             ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.INFO,this.message));
        }

    }

    public List<SelectOption> getDeliverySiteSelectOptionList() {
        
        IDPCreatePurchaseOrderSearchClass sr = new IDPCreatePurchaseOrderSearchClass();
        return sr.getDeliverySiteSelectOptionList();
    
    }
    
    //public List<SelectOption> getCatalogSelectOptionList(String pSelectedDeliverySite) {
    //    SearchResult sr = new SearchResult();
    //    return sr.getCatalogSelectOptionList(pSelectedDeliverySite);
    //}
    
    public List<SelectOption> getSupplierSelectOptionList() {
        IDPCreatePurchaseOrderSearchClass sr = new IDPCreatePurchaseOrderSearchClass();
        return sr.updateSupplierSelectOptionListAction(this.selectedDeliverySite);

        //SearchResult sr = new SearchResult();
        //return sr.getSupplierSelectOptionList(this.selectedDeliverySite);
        
    }
    
     public List<SelectOption> getCostCenterOptionList() {
        IDPCreatePurchaseOrderSearchClass sr = new IDPCreatePurchaseOrderSearchClass();
        return sr.updateCostCenterSelectOptionListAction(this.selectedDeliverySite, this.SelectedSupplier);
    }
    
    public List<SelectOption> getDraftPurchaseOrderelectOptionList() {
        IDPCreatePurchaseOrderSearchClass sr = new IDPCreatePurchaseOrderSearchClass();
        return sr.updateDraftPurchaseOrderSelectOptionListAction(this.selectedDeliverySite, this.selectedSupplier); 
        //SearchResult sr = new SearchResult();
        //return sr.getDraftPurchaseOrderelectOptionList(this.selectedDeliverySite, this.selectedSupplier);
        
    }


    
    //private with sharing class SearchResult {
        
    //    private List<SelectOption> getDeliverySiteSelectOptionList() {
            
    //        Map<String, SelectOption> existingDeliverySiteSelectOptionMap = new  Map<String, SelectOption>();
    //        List<SelectOption> tempDeliverySiteSelectOptionList = new List<SelectOption> ();
    //        SelectOption tempSelectOption = null;
                
    //        for(Purchase_Request_item__c reader : [SELECT Id, Status__c, Is_Direct_fulfillment__c, Purchase_Order_Item__c,
    //                                                        Purchase_Request__r.Tech_Applicant_Site_Id__c , Purchase_Request__r.Tech_Applicant_Site_Name__c,
    //                                                        Supplier__c, Supplier__r.name
    //                                                    FROM Purchase_Request_Item__c
    //                                                    WHERE Status__c = :IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED
    //                                                    AND Is_Direct_fulfillment__c = false
    //                                                    AND Purchase_Order_Item__c = null
    //                                                    //AND Purchase_Request__r.Delivery_Site__c != null
    //                                                    AND Purchase_Request__r.Tech_Applicant_Site_Id__c != null
    //                                                    ORDER BY Purchase_Request__r.Delivery_Site__r.Name ASC, Supplier__r.Name ASC] ){
                                                        
    //            if(reader.Purchase_Request__r.Tech_Applicant_Site_Id__c != null  &&  !String.isBlank(reader.Purchase_Request__r.Tech_Applicant_Site_Name__c )) {
    //                if(!existingDeliverySiteSelectOptionMap.containsKey(reader.Purchase_Request__r.Tech_Applicant_Site_Id__c  )) {
                        
    //                    tempSelectOption = new SelectOption(reader.Purchase_Request__r.Tech_Applicant_Site_Id__c  , reader.Purchase_Request__r.Tech_Applicant_Site_Name__c );
    //                    existingDeliverySiteSelectOptionMap.put(reader.Purchase_Request__r.Tech_Applicant_Site_Id__c  , tempSelectOption);
                        
    //                    tempDeliverySiteSelectOptionList.add(tempSelectOption);   
    //                }                        
    //            }                                        
    //        }
            
    //        system.debug(tempDeliverySiteSelectOptionList);
            
    //        return tempDeliverySiteSelectOptionList;
    //    }
        
    //    private List<SelectOption> getSupplierSelectOptionList(String pSelectedDeliverySite) {
            
    //        Map<String, SelectOption> existingSupplierSelectOptionMap = new  Map<String, SelectOption>();
    //        List<SelectOption> tempDeliverySiteSelectOptionList = new List<SelectOption> ();
    //        SelectOption tempSelectOption = null;
            
    //        pSelectedDeliverySite = pSelectedDeliverySite.replaceAll(REPLACE,'');
    //        List<String> pSelectedDeliverySiteList = pSelectedDeliverySite.split(SEPARATOR);
                
    //        for(Purchase_Request_item__c reader : [SELECT Id, Status__c, Is_Direct_fulfillment__c, Purchase_Order_Item__c,
    //                                                        Purchase_Request__r.Tech_Applicant_Site_Id__c , Purchase_Request__r.Tech_Applicant_Site_Name__c ,
    //                                                        Supplier__c, Supplier__r.name
    //                                                    FROM Purchase_Request_Item__c
    //                                                    WHERE Status__c = :IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED
    //                                                    AND Is_Direct_fulfillment__c = false
    //                                                    AND Purchase_Order_Item__c = null
    //                                                    //AND Purchase_Request__r.Delivery_Site__c = : pSelectedDeliverySite
    //                                                    AND Purchase_Request__r.Tech_Applicant_Site_Id__c  in : pSelectedDeliverySiteList
    //                                                    AND Supplier__c != null
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
        
    //    private List<SelectOption> getDraftPurchaseOrderelectOptionList(String pSelectedDeliverySite, String pSelectedSupplier) {
        
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
                
    //            String displayFormat = Label.IDP_Shopping_Cart_PR_Picklist_Format;
    //            DateTime displayCreatedDate = DateTime.newInstance(reader.createdDate.year(), reader.createdDate.month(), reader.createdDate.day(), 0, 0, 0);

    //            displayFormat = displayFormat.replace(PO_PICKLIST_DATE_REPLACE, String.valueOf(displayCreatedDate.format('dd/MM/yyyy')));
    //            displayFormat = displayFormat.replace(PO_PICKLIST_PO_RECORD_REPLACE, reader.Name);
    //            displayFormat = displayFormat.replace(PO_PICKLIST_PRI_NUMBER_REPLACE , String.valueOf(reader.PO_Item_Count__c));
                
    //            tempDraftPurchaseOrderSelectOptionList.add(new SelectOption(reader.Id, displayFormat));
    //        }
            
    //        return tempDraftPurchaseOrderSelectOptionList;
    //    } 
        

    //    private List<SelectOption> getCatalogSelectOptionList(String pSelectedDeliverySite) {      
    //        List<SelectOption> tempCatalogSelectOptionList = new List<SelectOption> ();
    //        List<String> pSelectedDeliverySiteList = new List<String> ();
    //        Set<String> catalogIdSet = new Set<String> ();
    //        String path = '';

    //        pSelectedDeliverySite = pSelectedDeliverySite.replaceAll(REPLACE,'');
    //        pSelectedDeliverySiteList = pSelectedDeliverySite.split(SEPARATOR);

    //        for(Purchase_Request_item__c reader : [SELECT Id, Status__c, Is_Direct_fulfillment__c, Purchase_Order_Item__c,
    //                                                        Purchase_Request__r.Tech_Applicant_Site_Id__c , Purchase_Request__r.Tech_Applicant_Site_Name__c,
    //                                                        Supplier__c, Supplier__r.name, 
    //                                                        Catalog_Item__r.Catalog__c, Catalog_Item__r.Catalog__r.Display_Name__c, 
    //                                                        Catalog_Item__r.Catalog__r.Parent_Catalog__c, Catalog_Item__r.Catalog__r.Parent_Catalog__r.Display_Name__c
    //                                                    FROM Purchase_Request_Item__c
    //                                                    WHERE Status__c = :IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED
    //                                                    AND Is_Direct_fulfillment__c = false
    //                                                    AND Purchase_Order_Item__c = null
    //                                                    AND Purchase_Request__r.Delivery_Site__c in :pSelectedDeliverySiteList
    //                                                    AND Purchase_Request__r.Tech_Applicant_Site_Id__c != null
    //                                                    ORDER BY Purchase_Request__r.Delivery_Site__r.Name ASC, Supplier__r.Name ASC] ){
                
    //            if(reader.Catalog_Item__r.Catalog__r.Parent_Catalog__c != null) {
    //                catalogIdSet.add(reader.Catalog_Item__r.Catalog__r.Parent_Catalog__c);
    //            }
    //            catalogIdSet.add(reader.Catalog_Item__r.Catalog__c);
    //        }

    //        tempCatalogSelectOptionList.add(new SelectOption('All', 'All'));

    //        for(Catalog__c reader : [SELECT id, Name, Display_Name__c
    //                                 FROM Catalog__c 
    //                                 WHERE Id in : catalogIdSet
    //                                 ORDER BY Display_Name__c asc]){
    //            tempCatalogSelectOptionList.add(new SelectOption(reader.Id, reader.Display_Name__c));
    //        }

    //        return tempCatalogSelectOptionList;

    //    }
    //}
   
}