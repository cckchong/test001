/**
 * IDPBrowseCatalogVFPCtrl 
 * @description 
 after developed
 1. company policy
 2. mass add not redirect
 3. check whether user is in catalog owner queue's group or not
 4. change exchange price local currency to based on the Expense Policy
 */
 
 
 
////////////////////IDPBrowseCatalogVFP finished company policy 
public without sharing class IDPBrowseCatalogVFPCtrl {

    public Map<String, Shopping_Cart_Item__c> existingShoppingCartItemMap {get; set;}
    public Map<String, Favourite_Item__c> existingFavouriteItemMap {get; set;}
    public Map<String, Exchange_Rate__c> fromToCurrencyIdExchangeRateMap {get; set;}
    public Map<Id, Set<Id>> userIsCatalogOwnerCatalogMap {get;set;}
    public List<SelectOption>  catalogSelectOptionList {get; set;}    //the catalog SelectOption picklist in header
    public List<SelectOption> SortingSelectOptionList {get;set;}    //SelectOption List for sorting the DataTable, assoicate with selectedSortingFieldName
    public List<SelectOption> displayCurrencySelectOptionList {get;set;}    //SelectOption List for changing the display of price in different currency, assoicate with selectedDisplayCurrencyName 
    public List<Employee__c> employeeList {get;set;}  

   
    public static final string DEFAULT_SORTING_FIELD_KEY = IDPConstant.DEFAULT_SORTING_FIELD_KEY;
    public static final string DEFAULT_DISPLAY_CURRENCY_KEY = IDPConstant.DEFAULT_DISPLAY_CURRENCY_KEY;
    public static final String NAVBAR_QUANTITY_REPLACE_KEYWORD = '@number';
    
    public String catalogJSON {get; set;}    //the json string used in the sidebar
    public String selectedSearchingCatalogId {get; set;}    //the selected catalog Id in the header's picklist
    public String selectedQueryCatalogId {get; set;}    //the selected catalog Id in sidebar and sorting
    public String queryInput {get; set;}    //the inputted string in the searchbox of header
    public String selectedSortingFieldName {get;set;}     //the selected selectOption of SortingSelectOptionList
    public String selectedDisplayCurrencyName {get;set;}      //the selected selectOption of displayCurrencySelectOptionList     
    public String message {get; set;}       //the string displayed message after pressed Mass Add to Cart or Favouite Button
    public String shoppingCartLabelwithQuanity {get;set;} //the shopping cart label with existing shopping cart item quantity
    public String favouriteListLabelwithQuanity {get;set;} //the favourite Item label with existing favourite item quantity
    public String companyCatalogPolicy {get;set;}
    public String breadcrumbs{get;set;}    
    public String redirectPage {get;set;}    

    public String levelOneCatalogJSON {get; set;}
    public String levelTwoCatalogJSON {get; set;}

    public String debugString {get; set;}  
    
    public String existingFavouriteItemJSON {get;set;}  // the json string to initial load the favourite item button image, which is either add or remove
    public String fromToCurrencyIdExchangeRateMapJSON {get;set;} 
    public String catalogPermissionJSON {get;set;}
    public Integer dataTablePageNumber {get;set;}
    public Integer dataTablePageLength {get;set;}
    public Boolean isCatalogOwner {get;set;}
    public Boolean savedIsSearch {get;set;}
    
// ==============================================================================================================================================================
 
    public IDPBrowseCatalogVFPCtrl() {       
        initial();

    }

// ==============================================================================================================================================================

    Public void initial(){
        
        //set<String> catalogItemCurrencyIdSet = new set<String> ();
        Set<Id> tempUserIdSet = new Set<Id> ();
        userIsCatalogOwnerCatalogMap = new Map<Id, Set<Id>> ();
        selectedQueryCatalogId = '';
        queryInput = '';
        message ='';
        companyCatalogPolicy = '';
        breadcrumbs = '';
        redirectPage = '';
        //catalogSelectionList = loadCatalogSelectionList ();
        levelOneCatalogJSON = '';
        levelTwoCatalogJSON  = '';
        isCatalogOwner = false;
        dataTablePageNumber = 0;
        dataTablePageLength = 10;
        savedIsSearch = false;
        employeeList = [SELECT IDP_Policy__c, IDP_Policy__r.Name, //IDP_Policy__r.Currency__c,IDP_Policy__r.Currency__r.Name,
                            Expense_Policy__c, Expense_Policy__r.Name, Expense_Policy__r.Local_Currency__c,Expense_Policy__r.Local_Currency__r.Name,     
                            Tech_IDP_Policy_Function_Department__c // ,Tech_Policy_Function_Department__c 
                        FROM Employee__c WHERE User__c = :UserInfo.getUserId() LIMIT 1]; 
        
        tempUserIdSet.add(UserInfo.getUserId());
        //Map<UserId, Set<CatalogIds>>
        userIsCatalogOwnerCatalogMap = IDPCommonUtils.getUserCatalogs(tempUserIdSet); 
        
        isCatalogOwner = isCatalogOwner();
        
        generateCatalogJSONAndSelectOptionAndDefaultCatalogId();
        
        SortingSelectOptionList = IDPCommonUtils.loadSortingSelectOptionList();
        selectedSortingFieldName =  DEFAULT_SORTING_FIELD_KEY;
        
        displayCurrencySelectOptionList = IDPCommonUtils.loadDisplayCurrencySelectOptionList();
        selectedDisplayCurrencyName = DEFAULT_DISPLAY_CURRENCY_KEY; 

        existingShoppingCartItemMap = new Map<String, Shopping_Cart_Item__c> ();
        existingFavouriteItemMap = new Map<String, Favourite_Item__c> (); 
        
        
        existingShoppingCartItemMap = getExistingShoppingCartItemMap();
        existingFavouriteItemMap = getExistingFavouriteItemMap();
        /*
        for(Shopping_Cart_Item__c reader : [SELECT Id, Name, User__c, Catalog_Item__c, Quantity__c, Status__c, Unit_Of_Measure__c FROM Shopping_Cart_Item__c WHERE User__c = :UserInfo.getUserId() AND Status__c = 'OP']) {
            existingShoppingCartItemMap.put(reader.Catalog_Item__c + '_' + reader.Unit_Of_Measure__c, reader);
        }

        for(Favourite_Item__c reader : [SELECT Id, Name, User__c, Catalog_Item__c FROM Favourite_Item__c WHERE User__c = :UserInfo.getUserId()]) {
            existingFavouriteItemMap.put(reader.Catalog_Item__c, reader);
        }
        */        
        existingFavouriteItemJSON = JSON.serializePretty(existingFavouriteItemMap);

        /*
        if(employeeList.size() > 0) {
        
            fromToCurrencyIdExchangeRateMap = IDPCommonUtils.loadExchangeRateMap(catalogItemCurrencyIdSet, employeeList.get(0).Expense_Policy__r.Local_Currency__c);
        }
        else {

        }

        fromToCurrencyIdExchangeRateMapJSON = JSON.serializePretty(fromToCurrencyIdExchangeRateMap );
        */
        shoppingCartLabelwithQuanity = Label.IDP_Nav_Shopping_Cart_Label.replace(NAVBAR_QUANTITY_REPLACE_KEYWORD ,String.valueOf(existingShoppingCartItemMap.size()));
        favouriteListLabelwithQuanity = Label.IDP_Nav_Favourite_List_Label.replace(NAVBAR_QUANTITY_REPLACE_KEYWORD ,String.valueOf(existingFavouriteItemMap.size()));
        
        Map<String, IDP_General_Setting__c> idpGeneralSettingMap = IDP_General_Setting__c.getAll();
        
        if(IDP_General_Setting__c.getInstance('Catalog Policy Link') != null) {
            companyCatalogPolicy = IDP_General_Setting__c.getInstance('Catalog Policy Link').Value__c;
        }
                
        String tempQueryCatalog = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Catalog);
        String tempqueryInput = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Input);
        String tempCurrencyName = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Display_Currency);
        String tempSortFieldName = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Sorting_Field);
        String tempPageNumber = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_DataTable_Page_Number); 
        String tempPageLength = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_DataTable_Page_Length);        
        String tempIsSearch = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Is_Search);        
        String tempParentCatalogName = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Breadcrumbs_Parent_Catalog);
        String tempSubCatalogName = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Breadcrumbs_Sub_Catalog);
        String tempBreadcrumbs = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Breadcrumbs);
        
        if(tempIsSearch != null && tempIsSearch != '') {
            savedIsSearch = Boolean.valueOf(tempIsSearch);
        }
        
        selectedSearchingCatalogId = Label.IDP_Shopping_Catalog_Search_Catalog_All;
        if(tempQueryCatalog != null && tempQueryCatalog != '') {
        
            selectedQueryCatalogId = tempQueryCatalog;
            if(savedIsSearch == true) {
                selectedSearchingCatalogId = tempQueryCatalog;
            }
            
        }

            
       
        
        if(tempqueryInput != null && tempqueryInput != '') {
            queryInput = tempqueryInput;
        }
        if(tempCurrencyName != null && tempCurrencyName != '') {
            selectedDisplayCurrencyName = tempCurrencyName;
        }
        if(tempSortFieldName != null && tempSortFieldName != '') {
            selectedSortingFieldName = tempSortFieldName;
        }
        if(tempPageNumber != null && tempPageNumber != '') {
            dataTablePageNumber = Integer.valueOf(tempPageNumber);
        }        
        if(tempPageLength != null && tempPageLength != '') {
            dataTablePageLength = Integer.valueOf(tempPageLength );
        }
        
        if(tempBreadcrumbs != null && tempBreadcrumbs != '') {
            breadcrumbs = tempBreadcrumbs ;
        }   
        
        /*           
        if(tempParentCatalogName != null && tempParentCatalogName!= '') {
            breadcrumbsParentCatalogName = tempParentCatalogName;
        }           
        if(tempSubCatalogName != null && tempSubCatalogName != '') {
            breadcrumbsSubCatalogName = tempSubCatalogName ;
        }
        */           
    }



// ==============================================================================================================================================================

    /*
        1. Generate a list of catalog and convert the list to a JSON string for sidebar 
        2. Generate a list of SelectOption of Catalog__c Id and Name to the Picklist in the header for searching function
        3. Set the first sub-catalog (level catalog) as the default value of selectedQueryCatalogId, so every time the page will load that calotag at first by default 
    */    

    public void generateCatalogJSONAndSelectOptionAndDefaultCatalogId() {
///*
        Map<String,Catalog__c> levelTwoCatalogIdCatalogMap = new Map<String,Catalog__c> ();
        Map<String, Map<String,Catalog__c>> ParentCatalogIdSubCatalogIdCatalogMapMap = new Map<String, Map<String,Catalog__c>> ();
        Map<String, Map<String,Catalog__c>> tempMap = new Map<String, Map<String,Catalog__c>> ();
        Map<String,String> parenteCatalogNameIdMap = new Map<String, String> (); 
        List<String> sortedLevelOneCatalogNameList = new List<String> ();
        List<SelectOption> options = new List<SelectOption>();
        Set<String> permittedCatalogIdSet = new Set<String> ();
        String sortedlevelOneCatalogName = '';
        String sortedlevelOneCatalogId = '';
         String tempTechUniqueFunctionDepartmentKey = '';
        try{
            //tempTechUniqueFunctionDepartmentKey = employeeList.get(0).Tech_Policy_Function_Department__c + '%';
            tempTechUniqueFunctionDepartmentKey = employeeList.get(0).Tech_IDP_Policy_Function_Department__c + '%';

        }
        catch (Exception e){
            //String error = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have an employee record.'));
        }
        
        for(Catalog_Item_Permission__c cip : [SELECT Catalog__c, Catalog_Item__r.Catalog__c,Function_Department__c,Unique_Key__c,
                                                     IsDepartmentLevel__c , IsUserLevel__c , IsCatalogLevel__c, IsCatalogItemLevel__c 
                                                FROM Catalog_Item_Permission__c 
                                                WHERE 
                                                    (IsDepartmentLevel__c = true
                                                    AND IsCatalogLevel__c = true
                                                //    AND Function_Department__c = :tempTechUniqueFunctionDepartmentKey)
                                                    AND Unique_Key__c like : tempTechUniqueFunctionDepartmentKey)
                                                OR
                                                    (User__c = :UserInfo.getUserId() 
                                                    AND IsUserLevel__c = true
                                                    AND IsCatalogLevel__c = true)
                                                OR
                                                    (User__c = :UserInfo.getUserId() 
                                                    AND IsUserLevel__c = true
                                                    AND IsCatalogItemLevel__c = true)]){
                                                    
            if((cip.IsDepartmentLevel__c == true && cip.IsCatalogLevel__c == true) ||
                (cip.IsUserLevel__c == true && cip.IsCatalogLevel__c == true) ) {
                    permittedCatalogIdSet.add(cip.Catalog__c);
                    system.debug(cip.Function_Department__c);
                    system.debug(cip.Unique_Key__c);
            }
            else if(cip.IsUserLevel__c == true && cip.IsCatalogItemLevel__c == true) {
                    permittedCatalogIdSet.add(cip.Catalog_Item__r.Catalog__c);
            
            }
            
                                 
        }

        system.debug(permittedCatalogIdSet);
        system.debug(userIsCatalogOwnerCatalogMap);
        system.debug(userIsCatalogOwnerCatalogMap.size());
        system.debug(userIsCatalogOwnerCatalogMap.isEmpty());
        List<Catalog__c> relatedCatalogList = new List<Catalog__c> ();
        if(userIsCatalogOwnerCatalogMap.isEmpty()) {
            relatedCatalogList = [SELECT Id ,is_Group_Catalog__c , Parent_Catalog__c, Parent_Catalog__r.Catalog_Name__c, Catalog_Name__c, // Tech_Is_Owner__c,
                                        (SELECT Id , Parent_Catalog__c, Parent_Catalog__r.Catalog_Name__c, Catalog_Name__c ,
                                         Parent_Catalog__r.is_Group_Catalog__c 
                                        FROM Catalogs__r 
                                        ORDER BY Catalog_Name__c DESC)     
                                    FROM Catalog__c
                                    WHERE 
                                    Id in :permittedCatalogIdSet
                                    //OR 
                                    //Id in :userIsCatalogOwnerCatalogMap.get(UserInfo.getUserId())
                                    ORDER BY is_Group_Catalog__c DESC , Catalog_Name__c DESC];        
        }
        else {
            relatedCatalogList = [SELECT Id , is_Group_Catalog__c, Parent_Catalog__c, Parent_Catalog__r.Catalog_Name__c, Catalog_Name__c, // Tech_Is_Owner__c,
                                        (SELECT Id , Parent_Catalog__c, Parent_Catalog__r.Catalog_Name__c, Catalog_Name__c,
                                        Parent_Catalog__r.is_Group_Catalog__c 
                                        FROM Catalogs__r 
                                        ORDER BY Catalog_Name__c DESC)     
                                    FROM Catalog__c
                                    WHERE 
                                    Id in :permittedCatalogIdSet
                                    OR 
                                    Id in :userIsCatalogOwnerCatalogMap.get(UserInfo.getUserId())
                                    ORDER BY is_Group_Catalog__c DESC , Catalog_Name__c DESC];
        }
        
        //ORDER BY Catalog_Name__c DESC in the map, but the json order will be automatically reversed in VFP
        for(Catalog__c reader: relatedCatalogList){ 

            
            //handling department to level two catalog/user to level two catalog/user to catalog item catalog(level two) permission  
            if(reader.Parent_Catalog__c != null) {
               //initial
               if(ParentCatalogIdSubCatalogIdCatalogMapMap.get(reader.Parent_Catalog__c) == null){
                    levelTwoCatalogIdCatalogMap = new Map<String,Catalog__c> ();
                    levelTwoCatalogIdCatalogMap.put(reader.Id, reader);
                    ParentCatalogIdSubCatalogIdCatalogMapMap.put(reader.Parent_Catalog__c, levelTwoCatalogIdCatalogMap);                
               }
                else {
                    ParentCatalogIdSubCatalogIdCatalogMapMap.get(reader.Parent_Catalog__c).put(reader.Id, reader);
               }
            }
            
            //handling department to level one catalog/user to level one catalog/user to catalog item catalog(level two)'s parent catalog(level one) permission  
            else {
                //key does not exist
                if(ParentCatalogIdSubCatalogIdCatalogMapMap.containsKey(reader.Id) == false) {
                    levelTwoCatalogIdCatalogMap = new Map<String,Catalog__c> ();
                    for(Catalog__c subCatalog: reader.Catalogs__r) {
                        levelTwoCatalogIdCatalogMap.put(subCatalog.Id, subCatalog);
                    }
                    ParentCatalogIdSubCatalogIdCatalogMapMap.put(reader.id , levelTwoCatalogIdCatalogMap);

                }
                else {
                    levelTwoCatalogIdCatalogMap = new Map<String,Catalog__c> ();
                    for(Catalog__c subCatalog: reader.Catalogs__r) {
                        levelTwoCatalogIdCatalogMap.put(subCatalog.Id, subCatalog);
                    }
                    
                    ParentCatalogIdSubCatalogIdCatalogMapMap.put(reader.id, levelTwoCatalogIdCatalogMap);
                    
                }
            }
        }

        
        for(String levelOneCatalogId : ParentCatalogIdSubCatalogIdCatalogMapMap.keySet()){
            
            for(Catalog__c levelTwoCatalog : ParentCatalogIdSubCatalogIdCatalogMapMap.get(levelOneCatalogId).values()){
                parenteCatalogNameIdMap.put(levelTwoCatalog.Parent_Catalog__r.Catalog_Name__c, levelTwoCatalog.Parent_Catalog__c);
                break;
            }
        }
        sortedLevelOneCatalogNameList.addAll(parenteCatalogNameIdMap.keySet());
        sortedLevelOneCatalogNameList.sort();

        tempMap = ParentCatalogIdSubCatalogIdCatalogMapMap.clone();
        ParentCatalogIdSubCatalogIdCatalogMapMap.clear();


        for(Integer i = sortedlevelOneCatalogNameList.size() - 1; i >= 0 ; i--) {
            
            //sort the map according the level one catalog's catalog name
            sortedlevelOneCatalogName = sortedlevelOneCatalogNameList.get(i);
            sortedlevelOneCatalogId = parenteCatalogNameIdMap.get(sortedlevelOneCatalogName);
            ParentCatalogIdSubCatalogIdCatalogMapMap.put(sortedlevelOneCatalogId, tempMap.get(sortedlevelOneCatalogId));
            
            //set the 1st level one catalog as the defualt value of selectedQueryCatalogId equal      
            if(i == 0){
                selectedQueryCatalogId = sortedlevelOneCatalogId;
            }


            /*
            //set the 1st level one catalog's 1st level two catalog as the default value of selectedQueryCatalogId equal       
            if(i == 0){
                Integer levelTwoCatalogCounter = 0;
                for(String levelTwoCatalogId : tempMap.get(sortedlevelOneCatalogId).keySet()) {
                    levelTwoCatalogCounter ++;
                    if(levelTwoCatalogCounter == tempMap.get(sortedlevelOneCatalogId).keySet().size()) {
                        selectedQueryCatalogId = levelTwoCatalogId;
                    }
                }
                

            }*/
            
        }
        options.add(new SelectOption(Label.IDP_Shopping_Catalog_Search_Catalog_All,Label.IDP_Shopping_Catalog_Search_Catalog_All));
        for(Integer i = 0; i < sortedlevelOneCatalogNameList.size(); i++) {
            sortedlevelOneCatalogName = sortedlevelOneCatalogNameList.get(i);
            sortedlevelOneCatalogId = parenteCatalogNameIdMap.get(sortedlevelOneCatalogName);
            options.add(new SelectOption(sortedlevelOneCatalogId ,sortedlevelOneCatalogName));
        }
                    

        catalogSelectOptionList = options;
        catalogJSON = JSON.serializePretty(ParentCatalogIdSubCatalogIdCatalogMapMap);
        if(ParentCatalogIdSubCatalogIdCatalogMapMap.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not permitted to view any catalogs'));
        }

    }

    
// ==============================================================================================================================================================


    public void singleAddtoCart(){
        String CatalogItemId= Apexpages.currentPage().getParameters().get('addToCartCatalogItemId');
        Integer AddToCartQuantity = Integer.valueOf(Apexpages.currentPage().getParameters().get('addToCartQuantity'));
        String AddToCartUOM = Apexpages.currentPage().getParameters().get('addToCartUOM');
        existingShoppingCartItemMap = IDPCommonUtils.singleAddtoCart(existingShoppingCartItemMap, CatalogItemId, AddToCartQuantity, AddToCartUOM);
        
        //after putting the new added item to the existing map, update navigation label
        shoppingCartLabelwithQuanity = Label.IDP_Nav_Shopping_Cart_Label.replace(NAVBAR_QUANTITY_REPLACE_KEYWORD ,String.valueOf(existingShoppingCartItemMap.size()));
        favouriteListLabelwithQuanity = Label.IDP_Nav_Favourite_List_Label.replace(NAVBAR_QUANTITY_REPLACE_KEYWORD ,String.valueOf(existingFavouriteItemMap.size()));
    }

// ==============================================================================================================================================================
    
    public void singleAddRemoveFavouriteItem(){
        String CatalogItemId = Apexpages.currentPage().getParameters().get('addToFavouriteCatalogItemId');
        existingFavouriteItemMap = IDPCommonUtils.singleAddRemoveFavouriteItem(existingFavouriteItemMap, CatalogItemId);

        system.debug('CatalogItemId:'+CatalogItemId);
        system.debug('existingFavouriteItemMap:'+existingFavouriteItemMap);
        //after putting the new added item to the existing map, update navigation label
        shoppingCartLabelwithQuanity = Label.IDP_Nav_Shopping_Cart_Label.replace(NAVBAR_QUANTITY_REPLACE_KEYWORD ,String.valueOf(existingShoppingCartItemMap.size()));
        favouriteListLabelwithQuanity = Label.IDP_Nav_Favourite_List_Label.replace(NAVBAR_QUANTITY_REPLACE_KEYWORD ,String.valueOf(existingFavouriteItemMap.size()));

    }
    
// ==============================================================================================================================================================
    
    
    public void massAction() {
        String jsonString = Apexpages.currentPage().getParameters().get('checkedCatalogItemIdQuantityJSON');
        String massMode= Apexpages.currentPage().getParameters().get('mMode');
        message = IDPCommonUtils.massAction(existingShoppingCartItemMap, existingFavouriteItemMap, jsonString, massMode);
        existingShoppingCartItemMap = getExistingShoppingCartItemMap();
        existingFavouriteItemMap = getExistingFavouriteItemMap();

        //after putting the new added item to the existing map, update navigation label
        shoppingCartLabelwithQuanity = Label.IDP_Nav_Shopping_Cart_Label.replace(NAVBAR_QUANTITY_REPLACE_KEYWORD ,String.valueOf(existingShoppingCartItemMap.size()));
        favouriteListLabelwithQuanity = Label.IDP_Nav_Favourite_List_Label.replace(NAVBAR_QUANTITY_REPLACE_KEYWORD ,String.valueOf(existingFavouriteItemMap.size()));        
    }

    
// ==============================================================================================================================================================

    public void singleInactivateCatalogItem(){
        String CatalogItemId = Apexpages.currentPage().getParameters().get('inactivateCatalogItemId');
        List<Catalog_Item__c> inactiveCatalogItemList = [SELECT Name, Id, Status__c FROM Catalog_Item__c WHERE Id = :CatalogItemId Limit 1];
        
        inactiveCatalogItemList.get(0).Status__c = IDPConstant.CATALOG_ITEM_STATUS_INACTIVE;
        
        update inactiveCatalogItemList;
    }

// ==============================================================================================================================================================

    public PageReference redirectToCreateCatalogItem() {
    
        PageReference CreateCatalogItemVFP = new PageReference(Label.IDP_Path_IDPCreateAdHocCatalogItemVFP);
        CreateCatalogItemVFP.getParameters().put(Label.IDP_Create_Catalog_Item_Mode_Parameter_Name, Label.IDP_Create_Catalog_Item_Mode_Standard);
        
        return CreateCatalogItemVFP;

    }
    
// ==============================================================================================================================================================
    public PageReference redirectToCreateNonCatalogItem() {
    
        PageReference CreateCatalogItemVFP = new PageReference(Label.IDP_Path_IDPCreateAdHocCatalogItemVFP);
        CreateCatalogItemVFP.getParameters().put(Label.IDP_Create_Catalog_Item_Mode_Parameter_Name, Label.IDP_Create_Catalog_Item_Mode_Non_Catalog_Item);
        
        return CreateCatalogItemVFP;
    }
// ==============================================================================================================================================================
    public Boolean isCatalogOwner() {
       
       Boolean tempIsCatalogOwner = false;
       if(userIsCatalogOwnerCatalogMap.containsKey(UserInfo.getUserId())) {
           if(userIsCatalogOwnerCatalogMap.get(UserInfo.getUserId()).size() > 0) {
               tempIsCatalogOwner = true;
           }       
       }

       return tempIsCatalogOwner;
   }
   
// ==============================================================================================================================================================

    public Map<String, Shopping_Cart_Item__c> getExistingShoppingCartItemMap() {
    
        Map<String, Shopping_Cart_Item__c> tmpExistingShoppingCartItemMap = new Map<String, Shopping_Cart_Item__c> ();
        

        for(Shopping_Cart_Item__c reader : [SELECT Id, Name, User__c, Catalog_Item__c, Quantity__c, Status__c, Unit_Of_Measure__c FROM Shopping_Cart_Item__c WHERE Catalog_Item__c != null and User__c = :UserInfo.getUserId() AND Status__c = 'OP']) {
            tmpExistingShoppingCartItemMap.put(reader.Catalog_Item__c + '_' + reader.Unit_Of_Measure__c, reader);
        }
        
        return tmpExistingShoppingCartItemMap;
    
    }    
    
// ==============================================================================================================================================================

    public Map<String, Favourite_Item__c> getExistingFavouriteItemMap() {

        Map<String, Favourite_Item__c> tmpExistingFavouriteItemMap = new Map<String, Favourite_Item__c> ();

        for(Favourite_Item__c reader : [SELECT Id, Name, User__c, Catalog_Item__c FROM Favourite_Item__c WHERE User__c = :UserInfo.getUserId()]) {
            tmpExistingFavouriteItemMap.put(reader.Catalog_Item__c, reader);
        }
        
        return tmpExistingFavouriteItemMap;
    }
    
// ==============================================================================================================================================================

    
    public PageReference redirectToPage() {
        PageReference VFP = null;
        if(redirectPage == Label.IDP_Path_IDPFavouriteListVFP) {
            VFP = new PageReference(Label.IDP_Path_IDPFavouriteListVFP);
        }
        else if(redirectPage == Label.IDP_Path_IDPShoppingCartVFP) {
            VFP = new PageReference(Label.IDP_Path_IDPShoppingCartVFP);
        }
        VFP.getParameters().put(Label.IDP_Parameter_Name_Catalog, selectedQueryCatalogId);
        VFP.getParameters().put(Label.IDP_Parameter_Name_Input, queryInput);
        VFP.getParameters().put(Label.IDP_Parameter_Name_Display_Currency, selectedDisplayCurrencyName);
        VFP.getParameters().put(Label.IDP_Parameter_Name_Sorting_Field, selectedSortingFieldName);
        VFP.getParameters().put(Label.IDP_Parameter_Name_DataTable_Page_Number, String.valueOf(dataTablePageNumber));
        VFP.getParameters().put(Label.IDP_Parameter_Name_DataTable_Page_Length, String.valueOf(dataTablePageLength));
        VFP.getParameters().put(Label.IDP_Parameter_Name_Is_Search, String.valueOf(savedIsSearch));
        VFP.getParameters().put(Label.IDP_Parameter_Name_Breadcrumbs, breadcrumbs);
        //VFP.getParameters().put(Label.IDP_Parameter_Name_Redirect_Page, pPage );
        return VFP;
    }
    
}