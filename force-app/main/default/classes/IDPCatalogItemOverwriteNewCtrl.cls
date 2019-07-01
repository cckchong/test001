/**
 * IDPCatalogItemOverwriteNewCtrl
 * @description override new button of Catalog Item
 */
public without sharing class IDPCatalogItemOverwriteNewCtrl
{    

    public PageReference redirect() {
        Boolean isCatalogOwner = false;
        String url = '';
        
        isCatalogOwner = isCatalogOwner();
        url = Label.IDP_Path_IDPCreateAdHocCatalogItemVFP + '?';
        url += Label.IDP_Create_Catalog_Item_Mode_Parameter_Name + '=';
        if(isCatalogOwner) {
            url += Label.IDP_Create_Catalog_Item_Mode_Standard;
        }
        else {
            url += Label.IDP_Create_Catalog_Item_Mode_Non_Catalog_Item;
        }
        return new PageReference(url);
    }
    
    /**
     * @description contructor with StandardController
     */
    public IDPCatalogItemOverwriteNewCtrl (ApexPages.StandardController controller) {
         
    }

    public IDPCatalogItemOverwriteNewCtrl () {}
    
    private Boolean isCatalogOwner() {
    
        Boolean tempIsCatalogOwner = false;
        
        Map<Id, Set<Id>> userIsCatalogOwnerCatalogMap = new Map<Id, Set<Id>> ();
        Set<Id> tempUserIdSet = new Set<Id> ();                   
        
        tempUserIdSet.add(UserInfo.getUserId());
        userIsCatalogOwnerCatalogMap = IDPCommonUtils.getUserCatalogs(tempUserIdSet); 
        
        if(userIsCatalogOwnerCatalogMap.containsKey(UserInfo.getUserId())) {
           if(userIsCatalogOwnerCatalogMap.get(UserInfo.getUserId()).size() > 0) {
               tempIsCatalogOwner = true;
           }       
        }
        
        return tempIsCatalogOwner;
   }    
    
}