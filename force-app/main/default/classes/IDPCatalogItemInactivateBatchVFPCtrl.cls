/**
 * IDPCatalogItemDeleteBatchVFPCtrl
 * @description Catalog Owner to inactive Catalog Item(s)
 */
public without sharing class IDPCatalogItemInactivateBatchVFPCtrl {
    //private ApexPages.StandardSetController standardController;
    private Id id;
    private Expense_Application__c  expenseApplication{get; set;}
    private Map<Id, String> recordtype;
    private static final String EXPENSEDETAILIDCODE = '@edlD';
    private static final String FINGROUOPNAMECODE = '@name';
    private static final String FIN_GROUOP_NAME= 'TE_@name_FIN';
    private boolean isQueue = false;    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}

    Public List<Catalog_Item__c> catalogItemList;
    Public List<Id> selectedCatalogItemIdList;
    
     
    
    /**
     * @description constructor with StandardController
    */
    
    public IDPCatalogItemInactivateBatchVFPCtrl (ApexPages.StandardController controller) {
         String textId = ApexPages.currentPage().getParameters().get('id');
         init(); 
         selectedCatalogItemIdList.add(textId);
         
    }
    
    /**
     * @description constructor with StandardSetController
    */
    
    public IDPCatalogItemInactivateBatchVFPCtrl (ApexPages.StandardSetController controller) {
        List<Catalog_Item__c> selectedRequests = (List<Catalog_Item__c>) controller.getSelected();
        init();
        for (Catalog_Item__c request : selectedRequests) {
            selectedCatalogItemIdList.add(request.id);
        }
    }
    

    
    Public Void init(){
        catalogItemList = new List<Catalog_Item__c>();
        selectedCatalogItemIdList = new List<Id>();
    }
    
    Public List<Catalog_Item__c> getCatalogItemList(List<ID> pSelectedCatalogItemIdList){
        return [SELECT Id, Is_Catalog__c, Name, Catalog__c, Catalog__r.Parent_Catalog__c
                FROM Catalog_Item__c 
                WHERE Id in :pSelectedCatalogItemIdList];
    }
    
Public PageReference inactivateCatalogItems(){
        //Map<UserId, Set<CatalogIds>>
        Map<Id, Set<Id>> userIsCatalogOwnerCatalogMap = new Map<Id, Set<Id>> ();
        List<Catalog_Item__c> catalogItemList = new List<Catalog_Item__c> ();
        Set<Id> tempUserIdSet = new Set<Id> ();
        String message = '';
        String path = '';
        Id userId = UserInfo.getUserId();
        Boolean isItemUnderOwnedCatalog = false;
        Boolean isAllowInactivate = false;
        

        if(selectedCatalogItemIdList.isEmpty()){
            return new PageReference('javascript: alert(\''+ Label.IDP_Catalog_Item_Empty_List +'\');window.history.back();');
        }

        tempUserIdSet.add(userId);

        userIsCatalogOwnerCatalogMap = IDPCommonUtils.getUserCatalogs(tempUserIdSet); 

        if(userIsCatalogOwnerCatalogMap.isEmpty()) {
            message = Label.IDP_Catalog_Item_No_Inactive_Access_Right;
            isAllowInactivate = false;

        }
        else {

            if(userIsCatalogOwnerCatalogMap.containsKey(userId)) {
                
                catalogItemList = getCatalogItemList(selectedCatalogItemIdList);

                for(Catalog_Item__c item : catalogItemList) {
                    isItemUnderOwnedCatalog = false;
                    for(Id  catalogId: userIsCatalogOwnerCatalogMap.get(userId)) {
                        if(item.Catalog__c == catalogId) {
                            isItemUnderOwnedCatalog = true;
                            break;
                        }

                        if(item.Catalog__r.Parent_Catalog__c == catalogId) {
                            isItemUnderOwnedCatalog = true;
                            break;
                        }
                    }

                    if(isItemUnderOwnedCatalog) {
                        item.status__c = IDPConstant.CATALOG_ITEM_STATUS_INACTIVE;
                        isAllowInactivate = true;
                    }
                    else {
                        message = Label.IDP_Catalog_Item_No_Inactive_Access_Right;
                        isAllowInactivate = false;
                        break;
                    }
                }
            }
        }

        if(isAllowInactivate) {
            update catalogItemList;  
            Schema.DescribeSObjectResult r = Catalog_Item__c.sObjectType.getDescribe();
            path = '/'+r.getKeyPrefix()+'?fcf='+Label.IDP_All_Catalog_Item_List_View;
        }
        else {
            path = 'javascript: alert(\''+ Label.TE_Expense_Application_Access_Right +'\');window.history.back();';
        }

        return new PageReference(path);        
        //List<Catalog_Item__c> catalogItemList = getCatalogItemList(this.selectedCatalogItemIdList);
        //Boolean allowInactivateCatalogItem = false;
        
        //if (catalogItemList.isempty()){
        //    return new PageReference('javascript: alert(\''+ Label.TE_Empty_List +'\');window.history.back();');
        //}
        
        
        //for(Catalog_Item__c reader :  catalogItemList){
            
        //    if(reader.Catalog__r.Tech_Is_Owner__c== true) {
        //        allowInactivateCatalogItem = true;
        //    }
        //    else {
        //        allowInactivateCatalogItem = false;
        //        break;
        //    }
        //}

        //if (!allowInactivateCatalogItem){
        //     return new PageReference('javascript: alert(\''+ Label.TE_Expense_Application_Access_Right +'\');window.history.back();');
        //}
        
        //for(Catalog_Item__c reader : catalogItemList){
        //        reader.status__c = IDPConstant.CATALOG_ITEM_STATUS_INACTIVE;
        //}
        
        //upsert catalogItemList;
    
    
        //Schema.DescribeSObjectResult r = Catalog_Item__c.sObjectType.getDescribe();

        //return new PageReference('/'+r.getKeyPrefix()+'?fcf='+Label.IDP_All_Catalog_Item_List_View);
    }

}