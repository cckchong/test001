/**
 * IDPShoppingCartVFPCtrl
 * @description 

Update
  1. change exchange price local currency to based on the Expense Policy
  2. receive parameter passed from Shopping Catalog page
 */
public without sharing class IDPShoppingCartVFPCtrl {

    public Map<String, Shopping_Cart_Item__c> existingShoppingCartItemMap {get; set;}
    public Map<String, Favourite_Item__c> existingFavouriteItemMap {get; set;}
    public Map<String, Exchange_Rate__c> fromToCurrencyIdExchangeRateMap {get; set;}
    public Map<String, boolean> catalogItemIdIsExpiredBooleanMap {get; set;}
    public Map<String, List<SelectOption>> catalogIdPurchaseRequestMap {get;set;}
    public Map<String, String> photoDocIdUrlMap {get;set;}
//    public Map<String, List<SelectOption>> catalogItemIdUOMSelectOptionListMap {get;set;}


    public List<SelectOption> SortingSelectOptionList {get;set;}    //SelectOption List for sorting the DataTable, assoicate with selectedSortingFieldName
    public List<SelectOption> displayCurrencySelectOptionList {get;set;}    //SelectOption List for changing the display of price in different currency, assoicate with selectedDisplayCurrencyName 
    public List<SelectOption> catalogSelectOptionList {get;set;}   
    public List<Employee__c> employeeList {get;set;}  

    public static final string DEFAULT_SORTING_FIELD_KEY = Label.IDP_Sorting_Field_Catalog_Asc_Key;//IDPConstant.DEFAULT_SORTING_FIELD_KEY;
    public static final string DEFAULT_DISPLAY_CURRENCY_KEY = IDPConstant.DEFAULT_DISPLAY_CURRENCY_KEY;
    
    public String selectedSortingFieldName {get;set;}     //the selected selectOption of SortingSelectOptionList
    public String selectedDisplayCurrencyName {get;set;}      //the selected selectOption of displayCurrencySelectOptionList  
    public String selectedCatalogName {get;set;}
    public String selectedPurchaseRequest {get;set;}
    public String redirectPage {get;set;}
    public String message {get; set;}       //the string displayed message after pressed Mass Add to Cart or Favouite Button

    //public String debugString {get; set;}  
    
    public String existingShoppingCartItemJSON {get;set;}
    public String existingFavouriteItemJSON {get;set;}  // the json string to initial load the favourite item button image, which is either add or remove
    public String fromToCurrencyIdExchangeRateMapJSON {get;set;} 
    public Boolean isRelatedCatalogPRExisted {set;}
    public Boolean displayShoppingCart {get;set;}
    public static final string PR_PICKLIST_DATE_REPLACE = '@DATE';
    public static final string PR_PICKLIST_PR_NAME_REPLACE = '@RECORDNAME';
    public static final string PR_PICKLIST_PRI_NUMBER_REPLACE = '@NUMBER';

 
// ==============================================================================================================================================================
 
    public IDPShoppingCartVFPCtrl() {       
        initial();
        
    }

// ==============================================================================================================================================================

    Public void initial(){
    
        set<String> catalogItemCurrencyIdSet = new set<String> ();
        Set<String> catalogItemPhotoDocIdSet = new Set<String> ();
        message ='';
        selectedCatalogName = '';
        selectedPurchaseRequest = '';
        redirectPage = '';
        displayShoppingCart = true;
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
        catalogIdPurchaseRequestMap = new Map<String, List<SelectOption>>();
        photoDocIdUrlMap = new Map<String, String> ();
//        catalogItemIdUOMSelectOptionListMap = new Map<String, List<SelectOption>> ();
         

        for(Shopping_Cart_Item__c reader : [SELECT Id, Name, User__c, Catalog_Item__c, Unit_Of_Measure__c, Catalog_Item__r.Item_Name__c,
                                                Quantity__c, Status__c, Catalog_Item__r.Catalog__r.Name, Catalog_Item__r.Name,
                                                Catalog_Item__r.Catalog__r.Catalog_Name__c, Catalog_Item__r.Catalog__r.Parent_Catalog__c,  Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c,
                                                Catalog_Item__r.Catalog__r.Tech_Catalog_Owner_Queue_Name__c,
                                                Catalog_Item__r.Description__c, Catalog_Item__r.Last_Supplier__c,  Catalog_Item__r.Last_Supplier__r.Name, Catalog_Item__r.Last_Supplier__r.Supplier_Name__c,
                                                Catalog_Item__r.Currency__c,Catalog_Item__r.Currency__r.Name, Catalog_Item__r.Reference_Price__c,
                                                Catalog_Item__r.Catalog__r.Parent_Catalog__r.Name, Catalog_Item__r.Unit_Of_Measure__c, Catalog_Item__r.Catalog__r.Display_Name__c,
                                                Catalog_Item__r.Expiry_Date__c, Catalog_Item__r.Photo_Doc_Id__c,
                                                Catalog_Item__r.Is_Catalog__c
                                            FROM Shopping_Cart_Item__c 
                                            WHERE User__c = :UserInfo.getUserId() 
                                            AND Status__c = :IDPConstant.SHOPPING_CART_STATUS_OPEN 
                                            AND Catalog_Item__c != null
                                            ORDER BY Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c ASC NULLS LAST, Catalog_Item__r.Catalog__r.Catalog_Name__c]) {
            
            existingShoppingCartItemMap.put(reader.Catalog_Item__c + '_' + reader.Unit_Of_Measure__c, reader);
            if(reader.Catalog_Item__r.Expiry_Date__c < System.Today()) {
                catalogItemIdIsExpiredBooleanMap.put(reader.Catalog_Item__c + '_' + reader.Unit_Of_Measure__c, true);
            }
            else {
                catalogItemIdIsExpiredBooleanMap.put(reader.Catalog_Item__c + '_' + reader.Unit_Of_Measure__c, false);
            }
            catalogItemPhotoDocIdSet.add(reader.Catalog_Item__r.Photo_Doc_Id__c);
            catalogItemCurrencyIdSet.add(reader.Catalog_Item__r.Currency__c);

 /*
            //change of UOM
            List<SelectOption> tempUOMSelectOptionList = new List<SelectOption> ();
            for(String uom : reader.Catalog_Item__r.Unit_Of_Measure__c.split(';')) {
                tempUOMSelectOptionList.add(new SelectOption(uom, uom));
            }
            catalogItemIdUOMSelectOptionListMap.put(reader.Catalog_Item__c, tempUOMSelectOptionList );
*/
        }
        
            if(existingShoppingCartItemMap.isEmpty()) {
                displayShoppingCart = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.IDP_Shopping_Cart_Empty_Message));
            }
        
        system.debug('existingShoppingCartItemMap:'+existingShoppingCartItemMap);
        existingShoppingCartItemJSON = JSON.serializePretty(existingShoppingCartItemMap);
        
        for(Favourite_Item__c reader : [SELECT Id, Name, User__c, Catalog_Item__c, Catalog_Item__r.Item_Name__c,
                                            Catalog_Item__r.Catalog__r.Name, Catalog_Item__r.Name, Catalog_Item__r.Description__c, Catalog_Item__r.Last_Supplier__r.Supplier_Name__c,
                                            Catalog_Item__r.Last_Supplier__c,  Catalog_Item__r.Last_Supplier__r.Name,Catalog_Item__r.Currency__c,
                                            Catalog_Item__r.Currency__r.Name, Catalog_Item__r.Reference_Price__c , Catalog_Item__r.Unit_Of_Measure__c 
                                        FROM Favourite_Item__c 
                                        WHERE User__c = :UserInfo.getUserId()]) {
            existingFavouriteItemMap.put(reader.Catalog_Item__c, reader);
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
        
        fromToCurrencyIdExchangeRateMapJSON = JSON.serializePretty(fromToCurrencyIdExchangeRateMap);

        catalogSelectOptionList  = loadExistingCatalogItemCatalog();
        
        photoDocIdUrlMap = IDPCommonUtils.loadPhotoUrlMap(catalogItemPhotoDocIdSet);
        
        catalogIdPurchaseRequestMap = getExistingPurchaseRequest();
    }


    
// ==============================================================================================================================================================
    
    public void singleRemoveFromCart(){

        String CatalogItemId= Apexpages.currentPage().getParameters().get('removeFromCartCatalogItemId');
        CatalogItemId= CatalogItemId.split('_').get(0);
        system.debug('CatalogItemId' + CatalogItemId);
        String UserId = UserInfo.getUserId();
        
        
        List<Shopping_Cart_Item__c> scItemList = [SELECT Id, Name, User__c, Catalog_Item__c, Quantity__c, Status__c, Unit_Of_Measure__c 
                                                FROM Shopping_Cart_Item__c
                                                WHERE User__c = :UserId
                                                AND Catalog_Item__c = :CatalogItemId
                                                AND Status__c = 'OP'
                                                LIMIT 1];
                                    
        if(scItemList.size() > 0) {
            existingShoppingCartItemMap.remove(scItemList.get(0).Catalog_Item__c + '_' + scItemList.get(0).Unit_Of_Measure__c);
            delete scItemList;
        }
        
    }
    
// ==============================================================================================================================================================
    
    public void massAction() {
    
        String jsonString = Apexpages.currentPage().getParameters().get('checkedCatalogItemIdQuantityJSON');
        
        system.debug('jsonString jsonString:'+jsonString);

        String massMode= Apexpages.currentPage().getParameters().get('mMode');
        message = IDPCommonUtils.massAction(existingShoppingCartItemMap, existingFavouriteItemMap, jsonString, massMode);    
    }
    
    public List<SelectOption> loadExistingCatalogItemCatalog() {
        
        List<SelectOption> option = new List<SelectOption> ();
        Map<String, String> CatalogIdNameMap = new Map<String, String> ();
        for(Shopping_Cart_Item__c reader :existingShoppingCartItemMap.values()) {

           system.debug('sci:'+reader);
           system.debug('sci.Catalog_Item__r:'+reader.Catalog_Item__r);
           system.debug('sci.Catalog_Item__r.Catalog__r:'+reader.Catalog_Item__r.Catalog__r);
           system.debug('sci.Catalog_Item__r.Catalog__r.Parent_Catalog__r.:'+reader.Catalog_Item__r.Catalog__r.Parent_Catalog__r);
           system.debug('sci.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c:'+reader.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c);

           if(!CatalogIdNameMap.containsKey(reader.Catalog_Item__r.Catalog__r.Parent_Catalog__c)) {
               CatalogIdNameMap.put(reader.Catalog_Item__r.Catalog__r.Parent_Catalog__c, '/' + reader.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c + '/' + reader.Catalog_Item__r.Catalog__r.Catalog_Name__c);
               system.debug(reader.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c);
               option.add(new SelectOption(reader.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c, reader.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c));
               
               if(String.isBlank(selectedCatalogName)) {
                   selectedCatalogName = reader.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c;
               }
           }
        }
        /*
        if(option.isEmpty()) {
           selectedCatalogName = Label.IDP_List_Empty_Label;
           option.add(new SelectOption(Label.IDP_List_Empty_Label, Label.IDP_List_Empty_Label));
        }
        */
        return option ;
    }
    
    public void updateShoppingCartItemQuantity() {    
        String catalogItemIdUOM = Apexpages.currentPage().getParameters().get('updateQuantityCatalogItemId');
        Integer updateQuantity = Integer.valueOf(Apexpages.currentPage().getParameters().get('updateCatalogItemQuantity'));
        Shopping_Cart_Item__c updateSCI = null;

        existingShoppingCartItemMap.get(catalogItemIdUOM).Quantity__c = updateQuantity;
        updateSCI = new Shopping_Cart_Item__c ( id = existingShoppingCartItemMap.get(catalogItemIdUOM).id, Quantity__c = updateQuantity);
        //update existingShoppingCartItemMap.get(catalogItemIdUOM);
        update updateSCI;
    }
    
    
    public void updateShoppingCartAssignTo() {    
        String updateAddignCartCItemId = Apexpages.currentPage().getParameters().get('updateAddignCartCItemId');
        Shopping_Cart_Item__c updateSCI = null;
        updateSCI = new Shopping_Cart_Item__c ( id = existingShoppingCartItemMap.get(updateAddignCartCItemId).id, 
                                                user__c = existingShoppingCartItemMap.get(updateAddignCartCItemId ).user__c,
                                                ownerid = existingShoppingCartItemMap.get(updateAddignCartCItemId ).user__c
                                              );
        update updateSCI;
    }
    
    public PageReference closeShoppingCartItems() {
        
        List<Shopping_Cart_Item__c> updateShoppingCartItemList = new List<Shopping_Cart_Item__c>();
        Map<String, Shopping_Cart_Item__c> updatedShoppingCartItemMap = new Map<String, Shopping_Cart_Item__c>();
        Purchase_Request__c purchaserRequest = new Purchase_Request__c ();
        String mode = '';
        String jsonString = '';
        
        mode = Apexpages.currentPage().getParameters().get(Label.IDP_Create_Purchase_Request_Mode_Parameter_Name); 
        jsonString = Apexpages.currentPage().getParameters().get('checkedCatalogItemIdQuantityJSON');  
        if(mode == Label.IDP_Create_Purchase_Request_Mode_Add_To_Existing && selectedPurchaseRequest == Label.IDP_List_Empty_Label) {
            message = Label.IDP_Shopping_Cart_Not_Available_Existing_PR_Message;
            return new PageReference('javascript:alert(\'' + message + '\');');
        }
        /*
        if(mode == Label.IDP_Create_Purchase_Request_Mode_Create_New && selectedCatalogName == Label.IDP_List_Empty_Label) {
            return null;
        }
        */
        IDPCommonUtils.EditedCatalogItems items = (IDPCommonUtils.EditedCatalogItems) JSON.deserialize(jsonString, IDPCommonUtils.EditedCatalogItems.class);
        //Loop the edited catalog item in shopping cart page i.e. (checked or unchecked) and (changed the quantity) catalog item         
        for(IDPCommonUtils.EditedCatalogItemWrapper reader : items.editedCatalogItemList) {
            //if the edited catalog Item is checked
            if(reader.checked == true) {
                if(mode == Label.IDP_Create_Purchase_Request_Mode_Add_To_Existing) {
                    existingShoppingCartItemMap.get(reader.catalogItemId).Tech_Purchase_Request__c = selectedPurchaseRequest;
                }
                if(existingShoppingCartItemMap.containsKey(reader.catalogItemId)){
                    existingShoppingCartItemMap.get(reader.catalogItemId).Status__c = IDPConstant.SHOPPING_CART_STATUS_CLOSED;
                    updateShoppingCartItemList.add(existingShoppingCartItemMap.get(reader.catalogItemId));
                }
            }    
        }
        
        update updateShoppingCartItemList;
        
        for(Shopping_Cart_item__c scItem: updateShoppingCartItemList) {
            updatedShoppingCartItemMap.put(scItem.Id, scItem);
        }
        purchaserRequest = IDPCommonUtils.createAddToPurchaseRequest(UserInfo.getUserId(), updatedShoppingCartItemMap);
        
        
        if(updateShoppingCartItemList.isEmpty()) {
            message = Label.IDP_Have_Not_Selected_An_Item_Message;
            return new PageReference('javascript:alert(\'' + message + '\');');        
        }
        else {
            if(purchaserRequest != null) {
            //    return new PageReference('/' + purchaserRequest.Id);
                return new PageReference(Label.IDP_Path_IDPPurchaseRequestVFP + '?mode=s&prid=' + purchaserRequest.Id);
            }        
            else {
               if(selectedPurchaseRequest != Label.IDP_List_Empty_Label) {
               //     return new PageReference('/' + selectedPurchaseRequest);
                   return new PageReference(Label.IDP_Path_IDPPurchaseRequestVFP + '?mode=s&prid=' + selectedPurchaseRequest);
               }   
            }
        }

        return null;
    }


    public Map<String, List<SelectOption>> getExistingPurchaseRequest() {
        Map<String, List<SelectOption>> tempCatalogIdPurchaseRequestMap = new Map<String, List<SelectOption>> ();
        List<Purchase_Request__c> purchaseRequestList = new List<Purchase_Request__c> ();
        List<SelectOption> tempPurchaseRequestIdSelectOptionList = new List<SelectOption> ();
        purchaseRequestList = [SELECT Id, Name, Catalog__c, Catalog__r.Catalog_Name__c, OwnerId ,CreatedDate, PR_Item_Count__c
                                FROM Purchase_Request__c 
                                WHERE OwnerID = : UserInfo.getUserId()
                                AND (Status__c = : IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT 
                                    OR Status__c = :IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED )];
        
        for(Purchase_Request__c reader : purchaseRequestList) {
            String displayFormat = Label.IDP_Shopping_Cart_PR_Picklist_Format;
            DateTime displayCreatedDate = DateTime.newInstance(reader.createdDate.year(), reader.createdDate.month(), reader.createdDate.day(), 0, 0, 0);

            displayFormat = displayFormat.replace(PR_PICKLIST_DATE_REPLACE, String.valueOf(displayCreatedDate.format('dd/MM/yyyy')));
            displayFormat = displayFormat.replace(PR_PICKLIST_PR_NAME_REPLACE, reader.Name);
            displayFormat = displayFormat.replace(PR_PICKLIST_PRI_NUMBER_REPLACE , String.valueOf(reader.PR_Item_Count__c));
            if(!tempCatalogIdPurchaseRequestMap.containsKey(reader.Catalog__r.Catalog_Name__c)) {
                tempPurchaseRequestIdSelectOptionList = new List<SelectOption> ();
                tempPurchaseRequestIdSelectOptionList.add(new SelectOption(reader.Id, displayFormat));
                tempCatalogIdPurchaseRequestMap.put(reader.Catalog__r.Catalog_Name__c, tempPurchaseRequestIdSelectOptionList);            
            }
            else {
                //tempCatalogIdPurchaseRequestMap.get(reader.Catalog__r.Catalog_Name__c).add(new SelectOption(reader.Id, reader.Name));
                tempCatalogIdPurchaseRequestMap.get(reader.Catalog__r.Catalog_Name__c).add(new SelectOption(reader.Id, displayFormat));
            }
        }
        
        /*
        if(!existingShoppingCartItemMap.values().isEmpty()) {
            for(Shopping_Cart_Item__c reader :existingShoppingCartItemMap.values()) {
                if(!tempCatalogIdPurchaseRequestMap.containsKey(reader.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c)) {
                    tempPurchaseRequestIdSelectOptionList = new List<SelectOption> ();
                    tempPurchaseRequestIdSelectOptionList.add(new SelectOption(Label.IDP_List_Empty_Label, Label.IDP_List_Empty_Label));
                    tempCatalogIdPurchaseRequestMap.put(reader.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c, tempPurchaseRequestIdSelectOptionList);            
                }
    
            }
        }
        */
        /*
        else {
                    tempPurchaseRequestIdSelectOptionList = new List<SelectOption> ();
                    tempPurchaseRequestIdSelectOptionList.add(new SelectOption(Label.IDP_List_Empty_Label, Label.IDP_List_Empty_Label));
                    tempCatalogIdPurchaseRequestMap.put(Label.IDP_List_Empty_Label, tempPurchaseRequestIdSelectOptionList);
        }
        */
        
        for(List<SelectOption> optionlist : tempCatalogIdPurchaseRequestMap.values()) {
            optionlist.sort();
        }
        
        
        
        return tempCatalogIdPurchaseRequestMap;
    }
    
    
    public Boolean getisRelatedCatalogPRExisted() {
        return (catalogIdPurchaseRequestMap.containsKey(selectedCatalogName));
    }
    public PageReference viewExistingPurchaseRequest() {
    
        if(selectedPurchaseRequest != Label.IDP_List_Empty_Label) {
            return new PageReference('/' + selectedPurchaseRequest);
        }
        else {
            message = Label.IDP_Shopping_Cart_Not_Available_Existing_PR_Message;
            return new PageReference('javascript:alert(\'' + message + '\');');
        } 
    }
   
    public PageReference redirectToPage(){
        return IDPCommonUtils.redirectToPage(redirectPage);
    }
}