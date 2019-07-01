public without sharing class IDPPhotoMappingPhotoToItemCtrl{

    public Document docItem {get;set;}
    public List<CatItemWrapper> catItemWrapperList{get;set;}
    public String docItemId {get;set;}
    public Set<Id> preSelectedCatItemIdSet = new Set<Id>();
    public String searchPhotoString {get;set;}
    public List<Catalog_Item__c> catItemByCatList {get;set;}
    public List<Catalog__c> catList {get;set;}
    
    public Set<Id> catIDSet {get;set;}
    public  String searchStr {get;set;}
    public Map<Id, Set<Id>> userOwnerCatalogSetMap {get;set;}
    public Set<Id> userIdSet {get;set;}
    public String userId {get;set;}
    public String seletedCatItem {get;set;}
    
    
    public IDPPhotoMappingPhotoToItemCtrl(){
        userOwnerCatalogSetMap = new Map<Id, Set<Id>> ();
        userId = '';
        userId = UserInfo.getUserId();
        userIdSet = new Set<Id> ();
        userIdSet.add(userId);
        userOwnerCatalogSetMap = IDPCommonUtils.getUserCatalogs(userIdSet); 
        searchPhotoString = '';

        docItemId = apexpages.currentpage().getparameters().get('cId');        
        //getAllCatItems();
        init();
        
        try{
            docItem = [Select Type, Name, Id, FolderId, Body, AuthorId, lastModifiedDate, DeveloperName, 
                        CreatedDate, CreatedById
                        From Document
                        WHERE FolderId = :Label.IDP_Catalog_Photos_Folder_Id 
                        AND Id = :docItemId
                        order by Name desc
                        limit 1];
         
         }
         catch(DmlException e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error:There are no items');
                ApexPages.addMessage(myMsg);           
         }
               
        system.debug(docItem );            
        if (docItem!=null){
                for (Catalog_Item__c ci : [select id from Catalog_Item__c where Photo_Doc_Id__c = :docItemId]){
                    preSelectedCatItemIdSet.add(ci.Id);
                }
        }
    }

    public void init(){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Please select the catalog');
        ApexPages.addMessage(myMsg);           
    }

    public void save(){
        List<Catalog_Item__c> catItemsToUpdateList = new List<Catalog_Item__c>();
        
        if(catItemWrapperList == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No item is selected. Please select at least one.');
            ApexPages.addMessage(myMsg);
            return;           
        }
        for (CatItemWrapper ciw : catItemWrapperList){
            
            if (ciw.isSelected){
                ciw.ci.Photo_Name__c = docItem.Name;
                ciw.ci.Photo_Doc_Id__c = docItem.Id;
                catItemsToUpdateList.add(ciw.ci);
            }
            else if (ciw.isSelected==false && ciw.originalSelection==true){ // means item was unselected, clear the document id and name fields
                ciw.ci.Photo_Name__c = '';
                ciw.ci.Photo_Doc_Id__c = '';
                catItemsToUpdateList.add(ciw.ci);
            }
            
        }
        
        
        if (catItemsToUpdateList.size()>0)  {
            update catItemsToUpdateList;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'The Photo have been mapped');
            ApexPages.addMessage(myMsg);    
        }
    }

  
/*
    public void getAllCatItems(){    
        catItemWrapperList = new List<CatItemWrapper>();
        searchStr = '%' + searchPhotoString + '%';
        Set<Id> catItemIDSet = new Set<Id>();
        catIDSet = new Set<Id>();
        Set<Id> tempSet = new Set<Id>();
        tempSet.add(UserInfo.getUserId());
        Map<Id, Map<Id, Catalog_Item_Permission__c>> userIdCatItemMapMap = IDPCommonUtils.getUserCatalogItems(tempSet, null);
        for (Id uId : userIdCatItemMapMap.keySet()){
            Map<Id, Catalog_Item_Permission__c> catItemCIPMap = userIdCatItemMapMap.get(uId);
            for (Id catId : catItemCIPMap.keyset()){
                catItemIDSet.add(catId);
            }
        }
        
        catItemIDSet.clear();
   
        for (Catalog_Item_Permission__c cip : IDPCommonUtils.getUserAllPermission(userId)){
            if (cip.Catalog_Item__c!=null)  catItemIDSet.add(cip.Catalog_Item__c);
            if (cip.Catalog__c!=null)   catIDSet.add(cip.Catalog__c);
        }
        
        List<Catalog_Item__c> catItemList = new List<Catalog_Item__c>();    

        catItemList = [select Id, Catalog__c, Item_Code__c, Description__c, Item_Name__c, Is_Catalog__c, Name, Catalog__r.Name, Catalog__r.Display_Name__c,
                                                                                Photo_Name__c, Photo_Doc_Id__c, Status__c, Catalog__r.Catalog_Name__c, Catalog__r.Parent_Catalog_Name__c 
                                                                            from Catalog_Item__c
                                                                            where status__c = :IDPConstant.CATALOG_ITEM_STATUS_ACTIVE  
                                                                            AND (Catalog__c IN :catIdSet OR Catalog__r.Parent_Catalog__c IN :catIdSet OR Id IN :catItemIdSet)
                                                                            AND (Item_Name__c LIKE :searchStr
                                                                                OR Catalog__r.Catalog_Name__c LIKE :searchStr
                                                                                OR Catalog__r.Parent_Catalog_Name__c LIKE :searchStr)
                                                                            Order by Item_Name__c asc
                                                                            limit 1000];

        
        for (Catalog_Item__c ci : catItemList){
            catItemWrapperList.add(new CatItemWrapper(ci, preSelectedCatItemIdSet.contains(ci.Id)));             
        }
        
        if(catItemWrapperList.size() == 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error:There are no items');
            ApexPages.addMessage(myMsg);        
        }
    }
*/
    
    public List<SelectOption> getCatalogOpt() {
    system.debug('userId: ' +userId);
    try{
        catList = [select Id,Catalog_Name__c,Description__c,Display_Name__c from Catalog__c where id in:userOwnerCatalogSetMap.get(userId) AND Parent_Catalog_Name__c != null Order by Catalog_Name__c ASC limit 1000];
    }
    catch(DmlException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No record to display');
            ApexPages.addMessage(myMsg);           
    }
    
    List<SelectOption> catOptions = new List<SelectOption>();
    catOptions.add(new SelectOption('default','----- Select Catalog -----'));
    for(Catalog__c cat:catList){
        catOptions.add(new SelectOption(cat.Catalog_Name__c,cat.Catalog_Name__c));    
    }
        return catOptions;
    }
        
    public void getCatalogItemList(){
    
        ApexPages.getMessages().clear();
        catItemByCatList = new List<Catalog_Item__c>();
        catItemWrapperList = new List<CatItemWrapper>();
        system.debug(searchPhotoString );
        system.debug(seletedCatItem);
        //seletedCatItem = 'Hardware - AV Devices';
        searchStr = '%' + searchPhotoString + '%';
        try{
            catItemByCatList = [select Id, Catalog__c, Description__c, Item_Name__c, Is_Catalog__c,Catalog__r.Display_Name__c, // Item_Code__c,
                                                                                    Photo_Name__c, Photo_Doc_Id__c, Status__c, Catalog__r.Catalog_Name__c, Catalog__r.Parent_Catalog_Name__c 
                                                                                from Catalog_Item__c 
                                                                                where Catalog__r.Catalog_Name__c =:seletedCatItem
                                                                                AND status__c = :IDPConstant.CATALOG_ITEM_STATUS_ACTIVE  
                                                                                AND (
                                                                                Catalog__r.Parent_Catalog_Name__c LIKE :searchStr
                                                                                OR Item_Name__c LIKE :searchStr
                                                                                )
                                                                                AND (
                                                                                Catalog__r.Parent_Catalog__c != null
                                                                                AND Catalog__c in :userOwnerCatalogSetMap.get(userId)
                                                                                )
                                                                                Order by Item_Name__c asc
                                                                                limit 1000];            
        
        }
        catch(DmlException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No record to display');
            ApexPages.addMessage(myMsg);        
        }
                                         
        system.debug(catItemByCatList);       
                                                                                
        for (Catalog_Item__c ci : catItemByCatList){
            if(ci != null){
                catItemWrapperList.add(new CatItemWrapper(ci, preSelectedCatItemIdSet.contains(ci.Id)));
                system.debug(catItemWrapperList);         
            }    
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No record to display');
                ApexPages.addMessage(myMsg);   
            }
        }  
        system.debug(catItemWrapperList);
        system.debug(catItemWrapperList.size());                                                                                                                                               
    }
   
    public class CatItemWrapper{
        
        public Catalog_Item__c ci {get;set;}
        public boolean isSelected {get;set;}
        public boolean originalSelection {get;set;} // used to detect if the cat item was unselected
        
        public CatItemWrapper(Catalog_Item__c pCI, Boolean pSelected){
            ci = pCI;
            isSelected = (pSelected==true) ? true : false;
            originalSelection = (pSelected==true) ? true : false;
        }
    }
}