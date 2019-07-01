/*used in uat, v0.3
update 
1.check user is in the owner queue
2. upload photo button will be displayed when select item to photo mapping/ photo to item mapping
*/
public without sharing class IDPPhotoMappingMainCtrl {
    
    public String mode{get;set;}
    public Map<Id, Set<Id>> userOwnerCatalogSetMap {get;set;}
    public List<Catalog_Item__c> catItemList {get;set;}
    public List<Catalog_Item__c> catItemByCatList {get;set;}
    public List<Catalog__c> catList {get;set;}
    public List<Document> docList {get;set;}
    public Set<Id> userIdSet {get;set;}
    public String searchItemString {get;set;}
    public String searchPhotoString {get;set;}
    public String userId {get;set;}
    public String iframeSrc {get;set;}
    public Boolean isDisplayUploadPhotoButton {get;set;}
    public String seletedCatItem {get;set;}
    
    public IDPPhotoMappingMainCtrl(){
        mode = '';
        iframeSrc = '/apex/IDPPhotoMapping';
        catItemList = new List<Catalog_Item__c>();
        catItemByCatList = new List<Catalog_Item__c>();
        docList = new List<Document>();
        searchItemString='';
        searchPhotoString='';
        isDisplayUploadPhotoButton = false;
        userId = '';
        userIdSet = new Set<Id> ();
        userOwnerCatalogSetMap = new Map<Id, Set<Id>> ();
        userId = UserInfo.getUserId();
        userIdSet.add(userId);
        userOwnerCatalogSetMap = IDPCommonUtils.getUserCatalogs(userIdSet); 
    }

    public void showUploadPhotoPage(){
        isDisplayUploadPhotoButton = false;
        iframeSrc = '/apex/IDPPhotoMapping';
        //docList.clear();
        //catItemList.clear();
    }

    public List<SelectOption> getCatalogOpt() {

    catList = [select Id,Catalog_Name__c,Description__c,Display_Name__c from Catalog__c where id in:userOwnerCatalogSetMap.get(userId) AND Parent_Catalog_Name__c != null Order by Catalog_Name__c ASC limit 1000];
    
    List<SelectOption> catOptions = new List<SelectOption>();
    catOptions.add(new SelectOption('default','----- Select Catalog -----'));
    for(Catalog__c cat:catList){
        catOptions.add(new SelectOption(cat.Catalog_Name__c,cat.Display_Name__c));    
    }

    system.debug(seletedCatItem);
        return catOptions;
    }
    
    public void changeMode(){
        if (mode=='Item to Photo'){
            isDisplayUploadPhotoButton = true;
            iframeSrc = '';
            seletedCatItem = 'One';
            getCatItemToMap();
            docList.clear();
        }else if (mode=='Photo to Item'){
            isDisplayUploadPhotoButton = true;
            iframeSrc = '';
            getPhotoToMap();
            catItemList.clear();
            catItemByCatList.clear(); 
        }else{
            isDisplayUploadPhotoButton = false;
            iframeSrc = '/apex/IDPPhotoMapping';
            docList.clear();
            catItemList.clear();
            catItemByCatList.clear(); 
        }
    }
    
    public void gotoPage(){
        isDisplayUploadPhotoButton = true;
        iframeSrc = apexpages.currentpage().getparameters().get('itemSelected');
    }
    
    public void getCatItemToMap(){
        Set<Id> catItemIDSet = new Set<Id>();
        Set<Id> tempSet = new Set<Id>();
        tempSet.add(UserInfo.getUserId());
        Map<Id, Map<Id, Catalog_Item_Permission__c>> userIdCatItemMapMap = IDPCommonUtils.getUserCatalogItems(tempSet, null);
        for (Id uId : userIdCatItemMapMap.keySet()){
            Map<Id, Catalog_Item_Permission__c> catItemCIPMap = userIdCatItemMapMap.get(uId);
            for (Id catId : catItemCIPMap.keyset()){
                catItemIDSet.add(catId);
            }
        }
        
        String searchStr = '%' + searchItemString + '%';
        
        //if (catItemIDSet!=null && catItemIDSet.size()>0)  
        catItemList = [select Id, Catalog__c,  Description__c, Item_Name__c, Is_Catalog__c, //Item_Code__c,
                                                                                Photo_Name__c, Photo_Doc_Id__c, Status__c, Catalog__r.Catalog_Name__c, Catalog__r.Parent_Catalog_Name__c 
                                                                            from Catalog_Item__c
                                                                            where status__c = :IDPConstant.CATALOG_ITEM_STATUS_ACTIVE  
                                                                            AND (Item_Name__c LIKE :searchStr
                                                                                OR Catalog__r.Catalog_Name__c LIKE :searchStr
                                                                                OR Catalog__r.Parent_Catalog_Name__c LIKE :searchStr)
                                                                            AND (Catalog__r.Parent_Catalog__c != null
                                                                                AND Catalog__c in :userOwnerCatalogSetMap.get(userId))
                                                                            Order by Item_Name__c asc
                                                                            limit 1000];
    
    } 
 
    public void getCatalogItemList(){
        system.debug(searchItemString);
        String searchStr = '%' + searchItemString + '%';
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

        system.debug(searchStr);
        system.debug(catItemByCatList);
    }

    public void getPhotoToMap(){
        String searchStr = '%' + searchPhotoString + '%';
        docList = [Select d.Type, d.Name, d.Id, d.AuthorId, d.lastModifiedDate
                    From Document d 
                    WHERE FolderId = :Label.IDP_Catalog_Photos_Folder_Id  // hardcoded document folder id for tal idp photos
                    AND AuthorId = :UserInfo.getUserId()
                    //AND lastModifiedDate = TODAY
                    AND Name LIKE :searchStr
                    order by Name desc
                    ];
    }

    public void showSelectedItem() {

        String cId = Apexpages.currentPage().getParameters().get('cId');
        isDisplayUploadPhotoButton = true;

        if (!String.isBlank(cId))
            iframeSrc = '/apex/IDPPhotoMappingItemToPhoto?cId=' + cId;

        else
            iframeSrc = '/apex/IDPPhotoMapping';

    }
}