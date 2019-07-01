public without sharing class IDPCreatePurchaseOrderCtrl{
    public Map<String, Purchase_Request_Item__c> notOrderedPurchaseRequestItemMap {get;set;}
    public List<IDPCreatePurchaseOrderLineCtrl> cpoLineList {get;set;}
    public List<SelectOption> deliverySiteSelectOptionList {get;set;}
    public List<SelectOption> supplierSelectOptionList {get;set;}
    public List<SelectOption> draftPurchaseOrderSelectOptionList {get;set;}
    public List<SelectOption> catalogSelectOptionList {get;set;}
    public List<SelectOption> CostcenterSelectOptionList{get;set;}
    
    public String selectedDeliverySite {get;set;}
    public String selectedSupplier {get;set;}
    public String selectedCatalog {get;set;}
    public String selectedPurchaseOrder {get;set;}
    public String selectedCostcenter{get;set;}
    public String message {get;set;}
    public Boolean isDraftPOExisted {get;set;}
    public Boolean isAvaliablePRIExisted {get;set;}
    public Purchase_Request__c dummyPRSearchFromDate {get;set;}
    public Purchase_Request__c dummyPRSearchToDate {get;set;}
    public Date searchFromDate {set;}
    public Date searchToDate {set;}
    public IDPCreatePurchaseOrderInitCtrl cpoInit;
    public IDPCreatePurchaseOrderActionCtrl cpoAction;
    
    
    public IDPCreatePurchaseOrderCtrl(){

        this.notOrderedPurchaseRequestItemMap = new Map<String, Purchase_Request_Item__c> ();
        this.cpoLineList = new List<IDPCreatePurchaseOrderLineCtrl>();
        this.deliverySiteSelectOptionList = new List<SelectOption> ();
        this.supplierSelectOptionList = new List<SelectOption> ();
        this.draftPurchaseOrderSelectOptionList = new List<SelectOption> ();
        this.CostcenterSelectOptionList= new List<SelectOption> ();
        
        
        
        this.dummyPRSearchFromDate = new Purchase_Request__c();
        this.dummyPRSearchToDate = new Purchase_Request__c();
        this.selectedDeliverySite = '';
        this.selectedSupplier = '';
        this.selectedCatalog = '';
        this.selectedPurchaseOrder = '';
        this.isDraftPOExisted = false;
        this.isAvaliablePRIExisted = true;
        this.cpoInit = new IDPCreatePurchaseOrderInitCtrl(this);
        this.cpoAction = new IDPCreatePurchaseOrderActionCtrl(this);
    }
    

    Public void searchNotOrderedPurchaseRequestItemMap() {
        system.debug('searchNotOrderedPurchaseRequestItemMap');
        system.debug('selectedDeliverySite:'+selectedDeliverySite);
        system.debug('selectedCatalog:'+selectedCatalog);
        system.debug('selectedSupplier:'+selectedSupplier);

        this.notOrderedPurchaseRequestItemMap = this.cpoAction.getNotOrderedPurchaseRequestItemMap(selectedDeliverySite, selectedCatalog,selectedCostcenter,selectedSupplier, getsearchFromDate(), getsearchToDate());
        
        system.debug('notOrderedPurchaseRequestItemMap:'+notOrderedPurchaseRequestItemMap);

        
        this.cpoLineList.clear();
        for(Purchase_Request_Item__c pri : this.notOrderedPurchaseRequestItemMap.values()) {
            this.cpoLineList.add( new IDPCreatePurchaseOrderLineCtrl( pri, this));
        }
    }
        
    
    public PageReference createDraftPurchaseOrderAction() {
        return this.cpoAction.createDraftPurchaseOrderAction();
    }    
    
    public PageReference addToExistingPurchaseOrderAction() {
        return this.cpoAction.addToExistingPurchaseOrderAction(selectedPurchaseOrder);
    }        
    
    public void updateSupplierSelectOptionListAction() {
        System.debug('selectedDeliverySite:'+selectedDeliverySite);
        supplierSelectOptionList = this.cpoAction.updateSupplierSelectOptionListAction(selectedDeliverySite);
        if(!this.supplierSelectOptionList.isEmpty()) {
            this.selectedSupplier = this.supplierSelectOptionList.get(0).getValue();
        }    
    
    }
    
    public void updateDraftPurchaseOrderSelectOptionListAction() {
        this.draftPurchaseOrderSelectOptionList = this.cpoAction.updateDraftPurchaseOrderSelectOptionListAction(selectedDeliverySite, selectedSupplier);
        if(!this.draftPurchaseOrderSelectOptionList.isEmpty()) {
            this.selectedPurchaseOrder = this.draftPurchaseOrderSelectOptionList.get(0).getValue();
            this.isDraftPOExisted = true;
        }
        else {
            this.isDraftPOExisted = false;
        } 
    }
    
 
    public PageReference viewExistingPurchaseOrder() {
        
        return new PageReference('/' + selectedPurchaseOrder);
    }
    
    public void searchPurchaseCostcenterAction () {
    
      System.debug('selectedDeliverySite:'+selectedDeliverySite);
        costcenterSelectOptionList = this.cpoAction.searchPurchaseCostcenterAction(selectedDeliverySite,selectedSupplier);
         if(!this.costcenterSelectOptionList .isEmpty()) {
            this.selectedPurchaseOrder = this.costcenterSelectOptionList.get(0).getValue();
            this.isDraftPOExisted = true;
    
    }
    }
    public void cancelPurchaseRequestItemAction() {
        String priId = Apexpages.currentPage().getParameters().get('priId');
        cpoAction.cancelPurchaseRequestItemAction(priId);
    }
    
    public void clearSearchCriteria() {
        this.cpoInit.Init(this);
    }
    public Date getsearchFromDate() {
        return dummyPRSearchFromDate.Need_by_Date__c;
    }

    public Date getsearchToDate() {
        return dummyPRSearchToDate.Need_by_Date__c;
    }

    


}