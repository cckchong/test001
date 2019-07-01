/**
 * IDPBrowseCatalogVFPCtrl 
 * @description 
 
 Update
 1. change exchange price local currency to based on the Expense Policy

 */
public without sharing class IDPFavouriteListVFPCtrl {

    public Map<String, Shopping_Cart_Item__c> existingShoppingCartItemMap {get; set;}
    public Map<String, Favourite_Item__c> existingFavouriteItemMap {get; set;}
    public Map<String, Exchange_Rate__c> fromToCurrencyIdExchangeRateMap {get; set;}
    public Map<String, boolean> catalogItemIdIsExpiredBooleanMap {get; set;}
    public Map<String, String> photoNameUrlMap {get;set;}
    public Map<String, String> photoDocIdUrlMap {get;set;}
    public Map<String, List<String>> catalogItemIdUOMSelectOptionStringListMap {get;set;}

    public List<SelectOption> SortingSelectOptionList {get;set;}    //SelectOption List for sorting the DataTable, assoicate with selectedSortingFieldName
    public List<SelectOption> displayCurrencySelectOptionList {get;set;}    //SelectOption List for changing the display of price in different currency, assoicate with selectedDisplayCurrencyName 
    public List<Employee__c> employeeList {get;set;}  

    public static final string DEFAULT_SORTING_FIELD_KEY = Label.IDP_Sorting_Field_Catalog_Asc_Key;//IDPConstant.DEFAULT_SORTING_FIELD_KEY;
    public static final string DEFAULT_DISPLAY_CURRENCY_KEY = IDPConstant.DEFAULT_DISPLAY_CURRENCY_KEY;
    
    public String selectedSortingFieldName {get;set;}     //the selected selectOption of SortingSelectOptionList
    public String selectedDisplayCurrencyName {get;set;}      //the selected selectOption of displayCurrencySelectOptionList    
    public String viewShoppingCartButtonLabel {get; set;} 
    public String redirectPage {get;set;}
        
    public String message {get; set;}       //the string displayed message after pressed Mass Add to Cart or Favouite Button

    public String debugString {get; set;}  
    
    public String existingFavouriteItemJSON {get;set;}  // the json string to initial load the favourite item button image, which is either add or remove
    public String fromToCurrencyIdExchangeRateMapJSON {get;set;} 
 
    public static final string TEXT_REPLACE = '@';  
// ==============================================================================================================================================================
 
    public IDPFavouriteListVFPCtrl() {       
        initial();
    }

// ==============================================================================================================================================================

    Public void initial(){
    
        set<String> catalogItemCurrencyIdSet = new set<String> ();
        Set<String> catalogItemPhotoDocIdSet= new Set<String> ();
        message ='';
        viewShoppingCartButtonLabel = '';
        redirectPage = '';
        SortingSelectOptionList = new List<SelectOption>();
        SortingSelectOptionList.add(new SelectOption(Label.IDP_Sorting_Field_Catalog_Asc_Key, Label.IDP_Sorting_Field_Catalog_Asc_Value));
        SortingSelectOptionList.add(new SelectOption(Label.IDP_Sorting_Field_Catalog_Desc_Key, Label.IDP_Sorting_Field_Catalog_Desc_Value));

        SortingSelectOptionList.addAll(IDPCommonUtils.loadSortingSelectOptionList());
        selectedSortingFieldName =  DEFAULT_SORTING_FIELD_KEY;
        
        displayCurrencySelectOptionList = IDPCommonUtils.loadDisplayCurrencySelectOptionList();
        selectedDisplayCurrencyName = DEFAULT_DISPLAY_CURRENCY_KEY; 

        existingShoppingCartItemMap = new Map<String, Shopping_Cart_Item__c> ();
        existingFavouriteItemMap = new Map<String, Favourite_Item__c> (); 
        catalogItemIdIsExpiredBooleanMap = new Map<String, Boolean> (); 
        photoDocIdUrlMap = new Map<String, String> ();
        catalogItemIdUOMSelectOptionStringListMap = new Map<String, List<String>> ();

        existingShoppingCartItemMap = loadExistingShoppingCartItemMap();
        
        viewShoppingCartButtonLabel = Label.IDP_View_Shopping_Cart_Button.replace(TEXT_REPLACE, String.valueOf(existingShoppingCartItemMap.size()));
        
        for(Favourite_Item__c reader : [SELECT Id, Name, User__c, Catalog_Item__c, Catalog_Item__r.Item_Name__c, 
                                            Catalog_Item__r.Catalog__r.Catalog_Name__c, Catalog_Item__r.Catalog__r.Name, Catalog_Item__r.Name, Catalog_Item__r.Description__c,
                                            Catalog_Item__r.Last_Supplier__c,  Catalog_Item__r.Last_Supplier__r.Name, Catalog_Item__r.Last_Supplier__r.Supplier_Name__c,
                                            Catalog_Item__r.Currency__c,Catalog_Item__r.Currency__r.Name, Catalog_Item__r.Reference_Price__c,
                                            Catalog_Item__r.Expiry_Date__c, Catalog_Item__r.Photo_Doc_Id__c , Catalog_Item__r.Unit_Of_Measure__c,
                                            Catalog_Item__r.Is_Catalog__c, Catalog_Item__r.Catalog__r.Display_Name__c
                                        FROM Favourite_Item__c 
                                        WHERE User__c = :UserInfo.getUserId()]) {
            existingFavouriteItemMap.put(reader.Catalog_Item__c, reader);
            if(reader.Catalog_Item__r.Expiry_Date__c < System.Today()) {
                catalogItemIdIsExpiredBooleanMap.put(reader.Catalog_Item__c, true);
            }
            else {
                catalogItemIdIsExpiredBooleanMap.put(reader.Catalog_Item__c, false);
            }
            catalogItemCurrencyIdSet.add(reader.Catalog_Item__r.Currency__c);
            catalogItemPhotoDocIdSet.add(reader.Catalog_Item__r.Photo_Doc_Id__c);
            
            List<String> tempUOMSelectOptionStringList = new List<String> ();

            for(String uom : reader.Catalog_Item__r.Unit_Of_Measure__c.split(';')) {
                tempUOMSelectOptionStringList.add(uom);
            }
        
            catalogItemIdUOMSelectOptionStringListMap.put(reader.Catalog_Item__c, tempUOMSelectOptionStringList);
        }
                
        
        existingFavouriteItemJSON = JSON.serializePretty(existingFavouriteItemMap);

        //employeeList = [SELECT IDP_Policy__r.Currency__c,IDP_Policy__r.Currency__r.Name FROM Employee__c WHERE User__c = :UserInfo.getUserId() LIMIT 1]; 
        employeeList = [SELECT Expense_Policy__r.Local_Currency__c, Expense_Policy__r.Local_Currency__r.Name
                            //IDP_Policy__r.Currency__c,IDP_Policy__r.Currency__r.Name 
                        FROM Employee__c 
                        WHERE User__c = :UserInfo.getUserId() LIMIT 1];
                        
        if(employeeList.size() > 0) {
        
            fromToCurrencyIdExchangeRateMap = IDPCommonUtils.loadExchangeRateMap(catalogItemCurrencyIdSet, employeeList.get(0).Expense_Policy__r.Local_Currency__c);
        }
        
        fromToCurrencyIdExchangeRateMapJSON = JSON.serializePretty(fromToCurrencyIdExchangeRateMap );
        
        photoDocIdUrlMap = IDPCommonUtils.loadPhotoUrlMap(catalogItemPhotoDocIdSet);
        
    }
    
    
    
// ==============================================================================================================================================================
    
    public void singleAddtoCart(){

        String CatalogItemId= Apexpages.currentPage().getParameters().get('addToCartCatalogItemId');
        Integer AddToCartQuantity = Integer.valueOf(Apexpages.currentPage().getParameters().get('addToCartQuantity'));
        String AddToCartUOM = Apexpages.currentPage().getParameters().get('addToCartUOM');
        existingShoppingCartItemMap = IDPCommonUtils.singleAddtoCart(existingShoppingCartItemMap, CatalogItemId, AddToCartQuantity, AddToCartUOM );
        //existingShoppingCartItemMap = loadExistingShoppingCartItemMap();
        viewShoppingCartButtonLabel = Label.IDP_View_Shopping_Cart_Button.replace(TEXT_REPLACE, String.valueOf(existingShoppingCartItemMap.size()));
    }
    
// ==============================================================================================================================================================

    public void singleRemoveFavouriteItem(){
        String UserId = UserInfo.getUserId();
        String CatalogItemId= Apexpages.currentPage().getParameters().get('removeFromFavouriteCatalogItemId');

        Favourite_Item__c newItem = new Favourite_Item__c();
        
        List<Favourite_Item__c> favItemList = [SELECT Id, Name, User__c, Catalog_Item__c
                                                FROM Favourite_Item__c
                                                WHERE User__c = :UserId
                                                AND Catalog_Item__c = :CatalogItemId
                                                LIMIT 1];
 
        if(favItemList.size() > 0) {
            existingFavouriteItemMap.remove(favItemList.get(0).Catalog_Item__c);
            delete favItemList;
        }
    }    

// ==============================================================================================================================================================
    
    public void massAction() {
    
        String jsonString = Apexpages.currentPage().getParameters().get('checkedCatalogItemIdQuantityJSON');
        String massMode= Apexpages.currentPage().getParameters().get('mMode');
        system.debug(existingShoppingCartItemMap);
        message = IDPCommonUtils.massAction(existingShoppingCartItemMap, existingFavouriteItemMap, jsonString, massMode);
        
        existingShoppingCartItemMap = loadExistingShoppingCartItemMap();
        viewShoppingCartButtonLabel = Label.IDP_View_Shopping_Cart_Button.replace(TEXT_REPLACE, String.valueOf(existingShoppingCartItemMap.size()));
    
    }
    
// ==============================================================================================================================================================
    public Map<String, Shopping_Cart_Item__c> loadExistingShoppingCartItemMap() {
        Map<String, Shopping_Cart_Item__c> tempMap = new Map<String, Shopping_Cart_Item__c> ();
        for(Shopping_Cart_Item__c reader : [SELECT Id, Name, User__c, Catalog_Item__c, Catalog_Item__r.Item_Name__c , Unit_Of_Measure__c,
                                                Quantity__c, Status__c, Catalog_Item__r.Catalog__r.Name, Catalog_Item__r.Name,
                                                Catalog_Item__r.Description__c, Catalog_Item__r.Last_Supplier__c,  Catalog_Item__r.Last_Supplier__r.Name, Catalog_Item__r.Last_Supplier__r.Supplier_Name__c,
                                                Catalog_Item__r.Currency__c,Catalog_Item__r.Currency__r.Name, Catalog_Item__r.Reference_Price__c ,Catalog_Item__r.Unit_Of_Measure__c
                                            FROM Shopping_Cart_Item__c 
                                            WHERE User__c = :UserInfo.getUserId() AND Status__c = 'OP']) {
            tempMap.put(reader.Catalog_Item__c + '_' + reader.Unit_Of_Measure__c, reader);
        }  
        
        return tempMap;  
    }   
// ==============================================================================================================================================================
   public PageReference redirectToPage(){
  
        return IDPCommonUtils.redirectToPage(redirectPage);
    }

}