/*
Updated
1. Use queue for Owner
*/

public class IDPAjaxDataTableCtrl{

    public ApexPages.StandardSetController setCon {get;set;}
    public Map<Id, Map<Id, Id>> userOwnerCatalogMapMap {get;set;}
    Public Integer noOfRecords {get; set;}
    Public Integer size {get;set;}
    Public Integer start {get;set;}
    Public String queryCatalogId {get;set;}
    Public String queryInput {get;set;}
    Public string dataTableJson {get;set;}
    private List<Employee__c> employeeList;
    private String queryString;
    private String userId;
   

         
    public IDPAjaxDataTableCtrl(){
        initial();
    }
 
    public void initial() {
        Map<Id, Set<Id>> tempUserOwnerCatalogSetMap = new Map<Id, Set<Id>> ();
        //Map<UserId, Set<CatalogIds>>
        Map<Id, Id> tempOwnerCatalogMap = new Map<Id, Id>();
        Set<Id> tempUserIdSet = new Set<Id> (); 
        userOwnerCatalogMapMap = new Map<Id, Map<Id, Id>>();
        employeeList = new List<Employee__c> ();
        
        userId = UserInfo.getUserId();
        
        employeeList = [SELECT Expense_Policy__r.Local_Currency__c, Expense_Policy__r.Local_Currency__r.Name
                            //IDP_Policy__r.Currency__c,IDP_Policy__r.Currency__r.Name 
                        FROM Employee__c 
                        WHERE User__c = :userId LIMIT 1];        
        system.debug('employeeList' + employeeList);
        
        tempUserIdSet.add(userId);
        tempUserOwnerCatalogSetMap = IDPCommonUtils.getUserCatalogs(tempUserIdSet); 
        for(String userId : tempUserOwnerCatalogSetMap.keyset()) {
            tempOwnerCatalogMap = new Map<Id, Id>();
            for(String catalogId : tempUserOwnerCatalogSetMap.get(userId)) {
                tempOwnerCatalogMap.put(catalogId,catalogId);
            
            }
            userOwnerCatalogMapMap.put(userId, tempOwnerCatalogMap);
        
        }
        
    }
     
    public void processData(){
        Map<String, Exchange_rate__c> fromToCurrencyIdExchangeRateMap = new Map<String, Exchange_rate__c> ();
        Map<Id, Map<Id, Catalog_Item_Permission__c>> userIdCatItemMapMap = new Map<Id, Map<Id, Catalog_Item_Permission__c>> ();
        Map<String, String> photoNameUrlMap = new Map<String, String> ();
        List<Catalog_Item_Permission__c> userPermission = new List<Catalog_Item_Permission__c> ();
        set<string> catalogItemPhotoDocIdSet = new set<string> ();
        set<String> catalogItemCurrencyIdSet = new set<String> ();
        String catalogItemIdconcatenatedString = '';
        String levelOneCatalogIdconcatenatedString = '';
        String levelTwoCatalogIdconcatenatedString = '';
        String OrderString;
        String displayCurrencyString;
        Boolean levelOneCatalog = false;
        Boolean setSidebarQuery = false;
        Boolean setSearchQuery = false;
        Boolean isCatalogOwner = false;
       
        queryString = 'SELECT Id, Name, Unit_Of_Measure__c, toLabel(Unit_Of_Measure__c) uom, Description__c, Reference_Price__c, ';
        queryString += 'Last_Supplier__c, Last_Supplier__r.Supplier_Name__c, Last_Supplier__r.Name, ';
        queryString += 'Item_Name__c, Currency__c, Currency__r.Name, Catalog__c, Is_Catalog__c, ';
        queryString += 'Expiry_Date__c, Status__c, ';
        queryString += 'Photo_Doc_Id__c ,Photo_Display__c, Photo_Link__c, Catalog__r.Parent_Catalog__c, Catalog__r.Display_Name__c ';
        queryString += 'FROM Catalog_Item__c ';
        queryString += 'WHERE Is_Catalog__c = true AND Status__c = \'' + IDPConstant.CATALOG_ITEM_STATUS_ACTIVE  + '\' ';

        // not applicable to description because it is a long text field, changed to line 208 method
        queryInput = String.valueOf(ApexPages.currentPage().getParameters().get('queryInput'));
        if(queryInput != null && queryInput.length() > 0) {
            queryString += 'AND (';
            queryString += 'Item_Name__c LIKE \'%' + queryInput + '%\' ';
            queryString += 'OR Tech_Keyword_1__c LIKE \'%' + queryInput + '%\' ';
            queryString += 'OR Tech_Keyword_2__c LIKE \'%' + queryInput + '%\' ';
            queryString += 'OR Tech_Keyword_3__c LIKE \'%' + queryInput + '%\' ';
            queryString += 'OR Tech_Keyword_4__c LIKE \'%' + queryInput + '%\' ';
            queryString += 'OR Tech_Keyword_5__c LIKE \'%' + queryInput + '%\' ';
            queryString += 'OR Tech_Keyword_6__c LIKE \'%' + queryInput + '%\' ';
            queryString += 'OR Tech_Keyword_7__c LIKE \'%' + queryInput + '%\' ';
            queryString += 'OR Last_Supplier__r.Supplier_Name__c LIKE \'%' + queryInput + '%\' ) ';
        }
        
        queryCatalogId = String.valueOf(ApexPages.currentPage().getParameters().get('queryCatalogId'));
        
        //It is used to get all user catalog permission records
        userPermission = IDPCommonUtils.getUserAllPermission(userId);

        //User is using search bar and select searching items from all catalogs
        if(queryCatalogId == Label.IDP_Shopping_Catalog_Search_Catalog_All) {
            
            //Using for loop to concatenate the level 1, level 2 catalog and catalog item Id for query string
            for(Catalog_Item_Permission__c cip : userPermission) {
                if(cip.IsCatalogLevel__c == true) {
                    if(cip.Catalog__r.Parent_Catalog__c == null) {
                        levelOneCatalogIdconcatenatedString += '\'' + cip.Catalog__c + '\', '; 
                    }
                    else if(cip.Catalog__r.Parent_Catalog__c != null) {
                        levelTwoCatalogIdconcatenatedString += '\'' + cip.Catalog__c + '\', '; 
                    }
                    
                }
                else if(cip.IsCatalogItemLevel__c == true) {
                    if(cip.Catalog_Item__c != null) {
                        catalogItemIdconcatenatedString += '\'' + cip.Catalog_Item__c + '\', '; 
                    }
                }
            }
            
            //If user is the catalog owner, also allow him/her to search all the items from the owned catalogs
            if(userOwnerCatalogMapMap.containsKey(userId)) {
                for(String ownedCatalogId : userOwnerCatalogMapMap.get(userId).keySet()) {
                    levelOneCatalogIdconcatenatedString += '\'' + ownedCatalogId  + '\', '; 
                }
            }
            queryString += 'AND (';
            
            if (levelOneCatalogIdconcatenatedString.length() == 0 
                && levelTwoCatalogIdconcatenatedString.length() == 0 
                && catalogItemIdconcatenatedString.length() == 0) {

                queryString += ' 1=0 ';
            }
            
            if(levelOneCatalogIdconcatenatedString.length() > 0){
            
                levelOneCatalogIdconcatenatedString += '@';
                levelOneCatalogIdconcatenatedString = levelOneCatalogIdconcatenatedString.replace(', @', '');
                queryString += 'Catalog__r.Parent_Catalog__c in (' + levelOneCatalogIdconcatenatedString + ') ';
                system.debug('catalogItemIdconcatenatedString ' + catalogItemIdconcatenatedString );
            }            
            if(levelTwoCatalogIdconcatenatedString.length() > 0){  
                          
                if(levelOneCatalogIdconcatenatedString.length() > 0){
                    queryString += 'OR ';
                }

                levelTwoCatalogIdconcatenatedString += '@';
                levelTwoCatalogIdconcatenatedString = levelTwoCatalogIdconcatenatedString .replace(', @', '');
                queryString += 'Catalog__c in (' + levelTwoCatalogIdconcatenatedString + ') ';
            }
            system.debug('catalogItemIdconcatenatedString ' + catalogItemIdconcatenatedString );                  
            if(catalogItemIdconcatenatedString.length() > 0){   
                         
                if(levelOneCatalogIdconcatenatedString.length() > 0 || levelTwoCatalogIdconcatenatedString.length() > 0){
                    queryString += 'OR ';
                }
                
                catalogItemIdconcatenatedString  += '@';
                catalogItemIdconcatenatedString = catalogItemIdconcatenatedString .replace(', @', '');
                catalogItemIdconcatenatedString = catalogItemIdconcatenatedString.replaceAll('\'', '');
                queryString += 'Id= \'' + catalogItemIdconcatenatedString + '\' ';
                system.debug('catalogItemIdconcatenatedString ' + catalogItemIdconcatenatedString );
            }

            queryString += ')';         
        }
        else {
        
            Set<String> levelOneTwoCatalogIdSet = new Set<String>();
            List<Catalog__c> selectedCatalogList = new List<Catalog__c> ();
            selectedCatalogList = [SELECT Id, Parent_Catalog__c, Tech_Is_Owner__c FROM Catalog__c WHERE Id =: queryCatalogId];
            system.debug(logginglevel.ERROR, 'selectedCatalogList:'+selectedCatalogList);
            if(selectedCatalogList.get(0).Parent_Catalog__c == null) {
                levelOneCatalog = true;
            }
            else {
                levelOneCatalog = false;
            }
            system.debug(logginglevel.ERROR, 'is levelOneCatalog:'+levelOneCatalog);
            //it means using sidebar                          
    
            if(userOwnerCatalogMapMap.containsKey(userId)) {
                if(userOwnerCatalogMapMap.get(userId).containsKey(queryCatalogId)) {
                    isCatalogOwner = true;
                    if(levelOneCatalog == false) {
                        queryString += 'AND Catalog__c = \'' + queryCatalogId + '\' ';
                    }
                    else {
                        queryString += 'AND Catalog__r.Parent_Catalog__c = \'' + queryCatalogId + '\' ';
                    
                    }            
                }
            
            }
            
            if(isCatalogOwner == false) {       
                for(Catalog_Item_Permission__c cip : userPermission) {
                    
                    //queryCatalogId is level two
                    //it means using sidebar
                    if(levelOneCatalog == false) {
                        if(cip.IsCatalogLevel__c == true) {
                            //queryCatalogId's Parent Catalog permission exists 
                            if(cip.Catalog__c == selectedCatalogList.get(0).Parent_Catalog__c) {
                                queryString += 'AND Catalog__c = \'' + queryCatalogId + '\' ';
                                setSidebarQuery = true;
                                break;
                            }
                            //queryCatalogId's Catalog permission exists 
                            else if(cip.Catalog__c == selectedCatalogList.get(0).Id) {
                                queryString += 'AND Catalog__c = \'' + queryCatalogId + '\' ';
                                setSidebarQuery = true;
                                break;
                            }
                        }
                        //queryCatalogId's Catalog item permission exists 
                        else if(cip.IsCatalogItemLevel__c == true) {
                            if(setSidebarQuery == false) {
                                if(cip.Catalog_Item__r.Catalog__c == selectedCatalogList.get(0).Id) {
                                    catalogItemIdconcatenatedString += '\'' + cip.Catalog_Item__c + '\', ';
                                }
                            }
                        }
                    }
                    else {
                    //queryCatalogId is level one
                    //it means using search
                        if(cip.IsCatalogLevel__c == true) {
                            //queryCatalogId's Catalog permission exists 
                            // query all catalog item from that level one catalog. i.e. Catalog__r.Parent_Catalog__c = queryCatalogId 
                            if(cip.Catalog__c == selectedCatalogList.get(0).Id) {
                                queryString += 'AND Catalog__r.Parent_Catalog__c = \'' + queryCatalogId + '\' ';
                                setSearchQuery = true;
                                break;
                            }
                            //queryCatalogId's Catalog permission does not exist
                            else if(cip.Catalog__c != selectedCatalogList.get(0).Id) {
                                if(setSearchQuery == false) {
                                    //if queryCatalogId related sub catalog (level two) permission exists
                                    //concatenate the level two catalog ids
                                    if(cip.Catalog__r.Parent_Catalog__c == selectedCatalogList.get(0).Id) {
                                        levelTwoCatalogIdconcatenatedString += '\'' + cip.Catalog__c + '\', ';
                                    }
                                }
                            }
                        }
                        //queryCatalogId's Catalog item permission exists 
                        else if(cip.IsCatalogItemLevel__c == true) {
                            //if queryCatalogId related sub catalog (level two)'s catalog item permission exists
                            //concatenate the catalog item ids                
                            if(setSearchQuery == false) {
                                if(cip.Catalog_Item__r.Catalog__r.Parent_Catalog__c == selectedCatalogList.get(0).Id) {
                                    catalogItemIdconcatenatedString += '\'' + cip.Catalog_Item__c + '\', ';
                                }
                            }
                        }
                    }
            
                }
                //level two catalog Id (using sidebar) but does not set the setSidebarQuery 
                if(levelOneCatalog == false && setSidebarQuery == false) {
                    if(catalogItemIdconcatenatedString.length() > 0){
                        catalogItemIdconcatenatedString += '@';
                        queryString += 'AND Catalog__c = \'' + queryCatalogId + '\' ';
                        catalogItemIdconcatenatedString = catalogItemIdconcatenatedString.replace(', @', '');
                        queryString += 'AND ( Catalog__c = \'' + queryCatalogId + '\' ';
                        queryString += 'AND Id in (' + catalogItemIdconcatenatedString  + ') )';
                    }
                    else {
                            //for handling error of not finding any catalog item permission, return an empty list by Id(Catalog Item  Id) = queryCatalogId 
                            queryString += 'AND Catalog__c = \'' + queryCatalogId + '\' ';
                            queryString += 'AND Id = \'' + queryCatalogId + '\' ';
                            system.debug('error: cannot find any catalog item permission');
                    }
                }
                                    system.debug('levelTwoCatalogIdconcatenatedString ' + levelTwoCatalogIdconcatenatedString );
        
                            system.debug('catalogItemIdconcatenatedString ' + catalogItemIdconcatenatedString );
                //level one catalog Id (using search) but does not set the setSearchQuery
                if(levelOneCatalog == true && setSearchQuery == false) {
        
                    if(levelTwoCatalogIdconcatenatedString.length() > 0) {
                        levelTwoCatalogIdconcatenatedString += '@';
                        levelTwoCatalogIdconcatenatedString = levelTwoCatalogIdconcatenatedString.replace(', @', '');            
                        if(catalogItemIdconcatenatedString.length() > 0){
                        catalogItemIdconcatenatedString += '@';
                            catalogItemIdconcatenatedString = catalogItemIdconcatenatedString.replace(', @', '');
                            queryString += 'AND (';
                            queryString += 'Catalog__c in (' + levelTwoCatalogIdconcatenatedString + ') ';
                            queryString += 'OR Id in (' + catalogItemIdconcatenatedString  + ')';
                            queryString += ' )';
                        }   
                        else {
                            queryString += 'AND Catalog__c in (' + levelTwoCatalogIdconcatenatedString + ') ';
                        }         
                    
                    }
                    else {
                        if(catalogItemIdconcatenatedString.length() > 0){
                            catalogItemIdconcatenatedString += '@';
                            catalogItemIdconcatenatedString = catalogItemIdconcatenatedString.replace(', @', '');
                            queryString += 'AND Id in (' + catalogItemIdconcatenatedString  + ')';
                        }
                        else {
                            //for handling error of not finding any catalog item permission, return an empty list by Id(Catalog Item  Id) = queryCatalogId 
                            queryString += 'AND Catalog__c = \'' + queryCatalogId + '\' ';
                            queryString += 'AND Id = \'' + queryCatalogId + '\' ';
                            system.debug('error: cannot find any catalog item permission');
                        }
                    }
                }
            }
        }
        orderString = String.valueOf(ApexPages.currentPage().getParameters().get('sortingFieldName'));        
        System.debug(orderString);
        if(orderString != null) {
            queryString += ' order by ' + orderString + ' NULLS LAST'; //'Is_Catalog__c Asc,' + 
        }
            
        system.debug('+++query'+queryString );
        //get starting record number for current view, this parametter will be send by datatable js
        start= Integer.valueOf(ApexPages.currentPage().getParameters().get('start'));
        //current number of records per page, it is also in avilable in get request
        size = Integer.valueOf(ApexPages.currentPage().getParameters().get('length'));
 
        //intialize standard controller with query
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
        setCon.setPageSize(size);
        noOfRecords= setCon.getResultSize();
        //set pagenumber
        setCon.setPageNumber((start/size)+1);
      
        //List<sobject> itemList = [SELECT Id, Name, Unit_of_Measure__c, Description__c, Reference_Price__c, Last_Supplier__c, Last_Supplier__r.Name, Item_Name__c, Currency__c, Catalog__c FROM Catalog_Item__c LIMIT :size OFFSET :start ];
        List<sobject> itemList = setCon.getRecords();
        
        
        // loop the itemList to get all the Cat Item's currency, save them to a set<String>
        for(sobject reader: itemList){
            catalogItemCurrencyIdSet.add(((Catalog_Item__c ) reader).Currency__c);
            catalogItemPhotoDocIdSet.add(((Catalog_Item__c ) reader).Photo_Doc_Id__c);
        }
        
        photoNameUrlMap = IDPCommonUtils.loadPhotoUrlMap(catalogItemPhotoDocIdSet);
        
        if(employeeList.size() > 0) {
            fromToCurrencyIdExchangeRateMap = IDPCommonUtils.loadExchangeRateMap(catalogItemCurrencyIdSet, employeeList[0].Expense_Policy__r.Local_Currency__c);
        }

        // use currency set of string to query the exchange rate, save to a map <String, Decimal> currency, the conversion rate
        // add a parameter to wrapper class to store the value for the converted or foreign price (catalog_Item__c.Price * (map.get(Catalog_Item__r.Currency__c));
        
        
        //CreateCatalogItemWrapper
        List<CatalogItemWrapper> itemWrapperList = new List<CatalogItemWrapper>();
        for(sobject reader: itemList){
            itemWrapperList.add(new CatalogItemWrapper((Catalog_Item__c ) reader, photoNameUrlMap.get(((Catalog_Item__c ) reader).Photo_Doc_Id__c), fromToCurrencyIdExchangeRateMap.get(((Catalog_Item__c ) reader).Currency__c)));
            //itemWrapperList.add(new CatalogItemWrapper((Catalog_Item__c ) reader));

        }

        //create DataTableWrapper
        DataTableWrapper datawrap = new DataTableWrapper(0,noOfRecords,noOfRecords,itemWrapperList);
        dataTableJson = JSON.serialize(datawrap);
        
    }
    public class DataTableWrapper{
        public Integer draw;
        public Integer recordsTotal;
        public Integer recordsFiltered;
        public List<CatalogItemWrapper> data;
        public DataTableWrapper(Integer draw,Integer recordsTotal,Integer recordsFiltered,list<CatalogItemWrapper> data){
            this.draw = draw;
            this.recordsTotal = recordsTotal;
            this.recordsFiltered = recordsFiltered ;
            this.data = data;
        }
         
    }
    public class CatalogItemWrapper{
        public Catalog_Item__c itemData = null;
        public String photoUrl = '';
        public Boolean isExpired = false;
//        public Boolean isAllowedToDelete = false;
//        public String originalReferencePrice;
        public String localReferencePrice = '';        
        public List<String> uomSelectOptionList = new List<String> ();

        public CatalogItemWrapper(Catalog_Item__c pData, String pPhotoUrl, Exchange_Rate__c pExchangeRate){
            this.itemData = pData;
            //this.photoUrl = 'https://talgroup--dttest--c.cs31.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=068p0000000x4fz&operationContext=CHATTER&contentId=05Tp0000003iaE9';
            this.photoUrl = pPhotoUrl;//'/servlet/servlet.FileDownload?file=015p00000006C6I';

            if(pData.Expiry_Date__c < System.Today()) {
                isExpired = true;
            }
            /*
            if(pData.Catalog__r.Catalog_Manager__c == UserInfo.getUserId() || pData.Owner__c == UserInfo.getUserId()) {
                isAllowedToDelete = true;
            }
            */
            if(pExchangeRate != null && pData.Reference_Price__c != null) {
                this.localReferencePrice = pExchangeRate.To_Currency__r.Name + ' ' + String.valueOf((pdata.Reference_Price__c*pExchangeRate.Rate__c).SetScale(2));
            }
            else {
                this.localReferencePrice =  Label.IDP_Not_Avaiable_Exchange_Rate_Message;
            }            
            
            uomSelectOptionList = IDPCommonUtils.loadUOMSelectOptionMap(pdata.Unit_Of_Measure__c);
        }
         
    }    
    
}