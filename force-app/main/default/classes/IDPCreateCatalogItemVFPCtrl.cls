public without sharing class IDPCreateCatalogItemVFPCtrl {

    public Map<String, Catalog_Item__c> keyCatalogItemListMap {get;set;}
    public Map<String, Boolean> keyCheckboxDisableMap {get;set;}
    public Map<String, Map<String,Boolean>> keyRequiredMap {get;set;}
    public Map<String, Shopping_Cart_Item__c> keyShoppingCartItemMap {get;set;}
    public Map<String, Catalog_Item__c> keyInsertCatalogItemMap {get; set;}
    public Map<String, Supplier_Item__c> keySupplierItemMap {get; set;}
    public Map<String, Supplier__c> supplierMap {get;set;}
    public List<SelectOption> createStandardCatalogSelectOptionList {get; set;}
    public List<SelectOption> createNonCatalogSelectOptionList {get; set;}
    public List<SelectOption> currencySelectOptionList {get;set;}
    public List<SelectOption> catalogItemAvailableUOMSelectOptionList {get;Set;}
    /*
    public transient List<SelectOption> supplierSelectOptionList {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList1 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList2 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList3 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList4 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList5 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList6 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList7 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList8 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList9 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList10 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList11 {get;Set;}
    public transient List<SelectOption> supplierSelectOptionList12 {get;Set;}    
    */
    public List<SelectOption> leadTimeFormatSelectOptionList {get;Set;}
    
    public Integer insertedCatalogItemSize {get;set;}
    public Integer insertedShoppingCartItemSize {get;set;}
    public Integer numberOfRows {get;set;}
    public String userId {get;set;}
    public String message {get;set;}
    public String mode {get;set;}
    
    public IDPCreateCatalogItemVFPCtrl() {    
        initial();
    }
    
    public void initial() {

        insertedCatalogItemSize = 0;
        insertedShoppingCartItemSize = 0;
        numberOfRows = 10;
        //Catalog_Item__c cItem = null;
        //Shopping_Cart_Item__c scItem = null;
        keyCheckboxDisableMap = new Map<String, Boolean> ();
        keyCatalogItemListMap = new Map<String, Catalog_Item__c> (); 
        keyRequiredMap = new Map<String, Map<String,Boolean>> ();
        keyShoppingCartItemMap = new Map<String, Shopping_Cart_Item__c> ();
        keySupplierItemMap =  new Map<String, Supplier_Item__c> ();
        supplierMap = new Map<String, Supplier__c> ();
        currencySelectOptionList = new  List<SelectOption> ();
        currencySelectOptionList = loadCurrencySelectOptionList();
        createStandardCatalogSelectOptionList = new List<SelectOption> ();
        createNonCatalogSelectOptionList = new List<SelectOption> ();
        catalogItemAvailableUOMSelectOptionList = new List<SelectOption> ();
        /*
        supplierSelectOptionList = new List<SelectOption> ();
        supplierSelectOptionList1 = new List<SelectOption> ();
        supplierSelectOptionList2 = new List<SelectOption> ();       
        supplierSelectOptionList3 = new List<SelectOption> ();
        supplierSelectOptionList4 = new List<SelectOption> ();
        supplierSelectOptionList5 = new List<SelectOption> ();
        supplierSelectOptionList6 = new List<SelectOption> ();
        supplierSelectOptionList7 = new List<SelectOption> ();
        supplierSelectOptionList8 = new List<SelectOption> ();
        supplierSelectOptionList9 = new List<SelectOption> ();
        supplierSelectOptionList10 = new List<SelectOption> ();
        supplierSelectOptionList11 = new List<SelectOption> ();
        supplierSelectOptionList12 = new List<SelectOption> ();
        */
        leadTimeFormatSelectOptionList = new List<SelectOption> ();
        
        mode = '';
        userid = Userinfo.getUserId();
        mode = ApexPages.currentPage().getParameters().get(Label.IDP_Create_Catalog_Item_Mode_Parameter_Name);
        
        
        loadCatalogSelectOptionList();
        catalogItemAvailableUOMSelectOptionList = loadCatalogItemAvailableUOMSelectOptionList();
        leadTimeFormatSelectOptionList = loadLeadTimeFormatSelectOptionList();
        //supplierMap = loadSupplierMap();
        
        
        
        //supplierSelectOptionList = loadSupplierFormatSelectOptionList();       
        /*
        Integer counter = 1;
        for(SelectOption supplierReader  : loadSupplierFormatSelectOptionList()){
            if( counter >= 1 && counter < 1000){
                supplierSelectOptionList1.add(supplierReader);
            }
            if( counter >= 1000 && counter < 2000){
                supplierSelectOptionList2.add(supplierReader);
            }
            if( counter >= 2000 && counter < 3000){
                supplierSelectOptionList3.add(supplierReader);
            }
            if( counter >= 3000 && counter < 4000){
                supplierSelectOptionList4.add(supplierReader);
            }
            if( counter >= 4000 && counter < 5000){
                supplierSelectOptionList5.add(supplierReader);
            }
            if( counter >= 5000 && counter < 6000){
                supplierSelectOptionList6.add(supplierReader);
            }
            if( counter >= 6000 && counter < 7000){
                supplierSelectOptionList7.add(supplierReader);
            }
            if( counter >= 7000 && counter < 8000){
                supplierSelectOptionList8.add(supplierReader);
            }
            if( counter >= 8000 && counter < 9000){
                supplierSelectOptionList9.add(supplierReader);
            }
            if( counter >= 9000 && counter < 10000){
                supplierSelectOptionList10.add(supplierReader);
            }
            counter ++;
        }
        */
        
        
        createTempRow(numberOfRows);
        /*
        for(Integer i = 0; i < 10; i++) {
            cItem = new Catalog_Item__c ();
            if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                cItem.Is_Catalog__c = true;
            }
            else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
               cItem.Is_Catalog__c = false;
            }
            cItem.Status__c = IDPConstant.CATALOG_ITEM_STATUS_ACTIVE;
            keyCheckboxDisableMap.put(String.valueOf(i), false);
            Map<String,Boolean> fieldRequiredMap = new Map<String,Boolean> ();

            fieldRequiredMap.put('itemName', false);
            fieldRequiredMap.put('catalog', false);
            fieldRequiredMap.put('description', false);
            fieldRequiredMap.put('unitOfMeasure', false);
            fieldRequiredMap.put('currency', false);
            fieldRequiredMap.put('referencePrice', false);
            fieldRequiredMap.put('quantity', false);
            keyRequiredMap.put(String.valueOf(i),fieldRequiredMap);
            keyCatalogItemListMap.put(String.valueOf(i), cItem);
            
            scItem =  new Shopping_Cart_Item__c ();
            scItem.User__c = UserInfo.getUserId();
            //scItem.Quantity__c = 1;//removed the default value i.e. 0 in shopping cart item quantity__c
            scItem.Status__c = IDPConstant.SHOPPING_CART_STATUS_OPEN;
            keyShoppingCartItemMap.put(String.valueOf(i), scItem);
        }
        */
    }
    
    public void createTempRow(Integer pNumberOfRows) {
        Catalog_Item__c cItem = null;
        Shopping_Cart_Item__c scItem = null;
        Supplier_Item__c siItem = null;
        for(Integer i = 0; i < pNumberOfRows; i++) {
            cItem = new Catalog_Item__c ();
            if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                cItem.Is_Catalog__c = true;
            }
            else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
               cItem.Is_Catalog__c = false;
            }
            cItem.Status__c = IDPConstant.CATALOG_ITEM_STATUS_ACTIVE;
            //keyCheckboxDisableMap.put(String.valueOf(i), false);
            keyCheckboxDisableMap.put(String.valueof('0'+ String.valueOf(i)).right(2), false);
            Map<String,Boolean> fieldRequiredMap = new Map<String,Boolean> ();

            fieldRequiredMap.put(Label.IDP_Create_Catalog_Item_Validation_Item_Details, false);
            fieldRequiredMap.put(Label.IDP_Create_Catalog_Item_Validation_Catalog, false);
            fieldRequiredMap.put(Label.IDP_Create_Catalog_Item_Validation_UOM, false);
            fieldRequiredMap.put(Label.IDP_Create_Catalog_Item_Validation_Quantity, false);
            fieldRequiredMap.put(Label.IDP_Create_Catalog_Item_Validation_Supplier, false);
            fieldRequiredMap.put(Label.IDP_Create_Catalog_Item_Validation_Reference_Price, false);
            fieldRequiredMap.put(Label.IDP_Create_Catalog_Item_Validation_MOQ, false);
            fieldRequiredMap.put(Label.IDP_Create_Catalog_Item_Validation_Lead_Time, false);

/*
            fieldRequiredMap.put('itemName', false);
            fieldRequiredMap.put('catalog', false);
            fieldRequiredMap.put('description', false);
            fieldRequiredMap.put('unitOfMeasure', false);
            fieldRequiredMap.put('quantity', false);
            fieldRequiredMap.put('minimumOrderQuantity', false);
            fieldRequiredMap.put('supplier', false);
            fieldRequiredMap.put('currency', false);
            fieldRequiredMap.put('referencePrice', false);
            fieldRequiredMap.put('priceExpiryDate', false);
*/            
            //keyRequiredMap.put(String.valueOf(i),fieldRequiredMap);
            //keyCatalogItemListMap.put(String.valueOf(i), cItem);
            keyRequiredMap.put(String.valueof('0'+ String.valueOf(i)).right(2),fieldRequiredMap);
            keyCatalogItemListMap.put(String.valueof('0'+ String.valueOf(i)).right(2), cItem);            
            
            
            scItem =  new Shopping_Cart_Item__c ();
            scItem.User__c = UserInfo.getUserId();
            //scItem.Quantity__c = 1;//removed the default value i.e. 0 in shopping cart item quantity__c
            scItem.Status__c = IDPConstant.SHOPPING_CART_STATUS_OPEN;
            //keyShoppingCartItemMap.put(String.valueOf(i), scItem);
            keyShoppingCartItemMap.put(String.valueof('0'+ String.valueOf(i)).right(2), scItem);
            siItem =  new Supplier_Item__c();
            keySupplierItemMap.put(String.valueof('0'+ String.valueOf(i)).right(2), siItem);
        }    
    
    }

    public void clearRow(){
        String copyRowNumber = '';
        copyRowNumber = ApexPages.currentPage().getParameters().get('rowNumber');
        // keyCatalogItemListMap.get('0'+copyRowNumber).clear();  
        keyCatalogItemListMap.get('0'+copyRowNumber).Catalog__c = null;
        keyCatalogItemListMap.get('0'+copyRowNumber).Item_Name__c= null;
        keyCatalogItemListMap.get('0'+copyRowNumber).Description__c= null;
        keyCatalogItemListMap.get('0'+copyRowNumber).Unit_Of_Measure__c= null;
        keyShoppingCartItemMap.get('0'+copyRowNumber).Quantity__c = null;
        keySupplierItemMap.get('0'+copyRowNumber).clear();
    }
 
    public void copyRow(){
        Map<String, Catalog_Item__c> tempKeyCatalogItemListMap = new Map<String, Catalog_Item__c> ();
        Map<String, Boolean> tempKeyCheckboxDisableMap = new Map<String, Boolean>();
        Map<String, Map<String,Boolean>> tempKeyRequiredMap = new  Map<String, Map<String,Boolean>>();
        Map<String, Shopping_Cart_Item__c> tempKeyShoppingCartItemMap = new Map<String, Shopping_Cart_Item__c> ();
        Map<String, Catalog_Item__c> tempKeyInsertCatalogItemMap = new Map<String, Catalog_Item__c>();
        Map<String, Supplier_Item__c> tempKeySupplierItemMap = new Map<String, Supplier_Item__c>();       
        
        
        String copyRowNumber = '';
        copyRowNumber = ApexPages.currentPage().getParameters().get('rowNumber');
        mode = ApexPages.currentPage().getParameters().get(Label.IDP_Create_Catalog_Item_Mode_Parameter_Name);

        if(copyRowNumber != null && copyRowNumber != '') {
            tempKeyCatalogItemListMap = keyCatalogItemListMap.clone();
            tempKeyCheckboxDisableMap = keyCheckboxDisableMap.clone();
            tempKeyRequiredMap = keyRequiredMap.clone();
            tempKeyShoppingCartItemMap = keyShoppingCartItemMap.clone();
            tempKeySupplierItemMap = keySupplierItemMap.clone();
            //tempKeyInsertCatalogItemMap = keyInsertCatalogItemMap.clone();
            keyCatalogItemListMap = new Map<String, Catalog_Item__c> (); 
            keyCheckboxDisableMap = new Map<String, Boolean> ();
            keyRequiredMap = new Map<String, Map<String,Boolean>> ();
            keyShoppingCartItemMap = new Map<String, Shopping_Cart_Item__c> ();      
            keySupplierItemMap = new Map<String, Supplier_Item__c>();    
            //numberOfRows++;
            
            //createTempRow(numberOfRows);
            //tempKeyCatalogItemListMap.size()
            for(Integer i = 0; i < tempKeyCatalogItemListMap.size(); i++) {
                /*
                String originalKey = String.valueOf(i);
                
                String beforeEqualCopyRowNewKey = String.valueOf(i);
                String afterCopyRowNewKey = String.valueOf(i + 1);
                String newInsertedRowKey = String.valueOf(Integer.valueOf(copyRowNumber) + 1);
                */
                String originalKey = String.valueof('0'+ String.valueOf(i)).right(2);
                String beforeEqualCopyRowNewKey = String.valueof('0'+ String.valueOf(i)).right(2);
                String afterCopyRowNewKey = String.valueof('0'+ String.valueOf(i + 1)).right(2);
                String newInsertedRowKey = String.valueof('0'+ String.valueOf(Integer.valueOf(copyRowNumber) + 1)).right(2);                
                //String.valueof('0'+ String.valueOf(i)).right(2)
                /*
                String beforeEqualCopyRowNewKey = '';
                String afterCopyRowNewKey = '';
                String newInsertedRowKey = '';                
                if(i >= 10) {
                beforeEqualCopyRowNewKey = '0' + String.valueOf(i);
                afterCopyRowNewKey = '0' + String.valueOf(i + 1);
                newInsertedRowKey = '0' + String.valueOf(Integer.valueOf(copyRowNumber) + 1);                
                
                }
                else {
                beforeEqualCopyRowNewKey = String.valueOf(i);
                afterCopyRowNewKey = String.valueOf(i + 1);
                newInsertedRowKey = String.valueOf(Integer.valueOf(copyRowNumber) + 1);                
                
                }
                */
                if(i <= Integer.valueOf(copyRowNumber)) {
                    keyCatalogItemListMap.put(beforeEqualCopyRowNewKey ,tempKeyCatalogItemListMap.get(originalKey).clone());
                    keyCheckboxDisableMap.put(beforeEqualCopyRowNewKey ,tempKeyCheckboxDisableMap.get(originalKey));
                    keyRequiredMap.put(beforeEqualCopyRowNewKey ,tempKeyRequiredMap.get(originalKey).clone());
                    keyShoppingCartItemMap.put(beforeEqualCopyRowNewKey ,tempKeyShoppingCartItemMap.get(originalKey).clone());
                    keySupplierItemMap.put(beforeEqualCopyRowNewKey ,tempKeySupplierItemMap.get(originalKey).clone());
                    
                }
                else {
                    keyCatalogItemListMap.put(afterCopyRowNewKey ,tempKeyCatalogItemListMap.get(originalKey).clone());
                    keyCheckboxDisableMap.put(afterCopyRowNewKey ,tempKeyCheckboxDisableMap.get(originalKey));
                    keyRequiredMap.put(afterCopyRowNewKey ,tempKeyRequiredMap.get(originalKey).clone());
                    keyShoppingCartItemMap.put(afterCopyRowNewKey ,tempKeyShoppingCartItemMap.get(originalKey).clone()); 
                    keySupplierItemMap.put(afterCopyRowNewKey ,tempKeySupplierItemMap.get(originalKey).clone());
                }
                
                if(i == Integer.valueOf(copyRowNumber)) {
                    keyCatalogItemListMap.put(newInsertedRowKey ,tempKeyCatalogItemListMap.get(originalKey).clone());
                    keyCheckboxDisableMap.put(newInsertedRowKey ,tempKeyCheckboxDisableMap.get(originalKey));
                    keyRequiredMap.put(newInsertedRowKey ,tempKeyRequiredMap.get(originalKey).clone());
                    keyShoppingCartItemMap.put(newInsertedRowKey ,tempKeyShoppingCartItemMap.get(originalKey).clone());  
                    keySupplierItemMap.put(newInsertedRowKey ,tempKeySupplierItemMap.get(originalKey).clone());                
                }
                
                
            }

        }
        else {
            return;
        }
    }    
    public void createCatalogItem() {
    
        List<Shopping_Cart_Item__c> insertshoppingCartList = new List<Shopping_Cart_Item__c>();
        List<Supplier_Item__c> insertSupplierItemList = new List<Supplier_Item__c> ();
        List<Catalog_Item_Permission__c> upsertPermissionList = new List<Catalog_Item_Permission__c> ();
        keyInsertCatalogItemMap = new Map<String, Catalog_Item__c> ();
        Set<Id> newCatalogItemIdSet = new Set<Id> ();
        Set<Id> userIdSet = new Set<Id> ();
        Catalog_Item_Permission__c tempCatalogItemPermission = new Catalog_Item_Permission__c ();

        keyInsertCatalogItemMap = validateInput();
        
        if(keyInsertCatalogItemMap.size() > 0) {

            insert keyInsertCatalogItemMap.values();
            insertedCatalogItemSize = keyInsertCatalogItemMap.values().size();
            if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                message = Label.IDP_Create_Catalog_Item_Message;
            }
            /*   
            //Create Catalog Permission
            userIdSet.add(userId);

            for(Catalog_Item__c reader : keyInsertCatalogItemMap.values()) {
                newCatalogItemIdSet.add(reader.Id);
                userIdSet.add(userId);
            }


            for(Catalog_Item__c reader : insertCatalogItemList) {

                tempCatalogItemPermission = new Catalog_Item_Permission__c ();
                tempCatalogItemPermission.isCatalogItemLevel__c = true;
                tempCatalogItemPermission.User__c = userId;
                //tempCatalogItemPermission.Department__c = u.Department__c;
                tempCatalogItemPermission.Catalog_Item__c =reader.Id;
                tempCatalogItemPermission.Catalog__c = reader.Catalog__c;
                upsertPermissionList.add(tempCatalogItemPermission);
            }
            */                       
                                        
            //upsertPermissionList = IDPCommonUtils.createCatalogItemPermissions(userIdSet, newCatalogItemIdSet);
            
            //upsert upsertPermissionList;
            
            //Create Shopping Cart Item Record
                        
                        
                

                for(String reader : keyInsertCatalogItemMap.keySet()) {
                    if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                        Boolean moqIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Minimum_Order_Quantity__c));
                        Boolean supplierIsFilled = !String.isBlank(keySupplierItemMap.get(reader).Supplier__c);
                        Boolean currencyIsFilled = !String.isBlank(keySupplierItemMap.get(reader).Currency__c);
                        Boolean referencePriceIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Price__c));
                        Boolean priceExpiryDateIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Expiry_Date__c));
                        if(moqIsFilled || supplierIsFilled || 
                            currencyIsFilled || referencePriceIsFilled || 
                            priceExpiryDateIsFilled) {
                                keySupplierItemMap.get(reader).Catalog_Item__c = keyInsertCatalogItemMap.get(reader).Id;
                                insertSupplierItemList.add(keySupplierItemMap.get(reader));
                        }
                        
                    }
                    else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
                        if(keyInsertCatalogItemMap.get(reader).Id != null) {
                            keyShoppingCartItemMap.get(reader).Catalog_Item__c = keyInsertCatalogItemMap.get(reader).Id;
                            keyShoppingCartItemMap.get(reader).Unit_Of_Measure__c = keyInsertCatalogItemMap.get(reader).Unit_Of_Measure__c;
                            insertshoppingCartList.add(keyShoppingCartItemMap.get(reader));
                        }
                    }
                }
                if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) { 
                    if(insertSupplierItemList.size() > 0) {
                        insert insertSupplierItemList;
                    }
                    
                }
                else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
                    insert insertshoppingCartList;
                    insertedShoppingCartItemSize = insertshoppingCartList.size();
                    message = Label.IDP_Add_Non_Catalog_Item_To_Cart_Message;

                }


                

            
        }
        else {
            message = Label.IDP_Have_Not_Entered_Any_Items_Message;
        }
/*
        if(keyInsertCatalogItemMap.values().size() > 0 || insertshoppingCartList.size() > 0){
            return redirectToBrowseCatalog();
        }
        else {
            return null;
        }
        */
    }
    
    public Map<String, Catalog_Item__c> validateInput() {
        Map<String, Catalog_Item__c> tempKeyInsertCatalogItemMap = new Map<String, Catalog_Item__c> ();
        
        for(String reader : keyCatalogItemListMap.keySet()) {

            Boolean itemNameIsFilled = !String.isblank(keyCatalogItemListMap.get(reader).Item_Name__c);
            Boolean catalogIsFilled = !String.isblank(keyCatalogItemListMap.get(reader).Catalog__c);
            Boolean descriptionIsFilled = !String.isblank(keyCatalogItemListMap.get(reader).Description__c);
            Boolean uomIsFilled = !String.isblank(keyCatalogItemListMap.get(reader).Unit_Of_Measure__c);
            Boolean quantityIsFilled = !String.isBlank(String.valueOf(keyShoppingCartItemMap.get(reader).Quantity__c));
            Boolean moqIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Minimum_Order_Quantity__c));
            Boolean supplierIsFilled = !String.isBlank(keySupplierItemMap.get(reader).Supplier__c);
            Boolean currencyIsFilled = !String.isBlank(keySupplierItemMap.get(reader).Currency__c);
            Boolean referencePriceIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Price__c));
            Boolean priceExpiryDateIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Expiry_Date__c));
            Boolean leadTimeFormatIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Lead_Time_Format__c));
            Boolean leadTimeDaysIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Lead_Time_Days__c));
            
            system.debug('reader:'+reader);
            system.debug('ctrl keySupplierItemMap:'+keySupplierItemMap);
            system.debug('ctrl ksi:'+keySupplierItemMap.get(reader));
            system.debug('itemNameIsFilled:'+itemNameIsFilled);
            system.debug('catalogIsFilled:'+catalogIsFilled);
            system.debug('descriptionIsFilled:'+descriptionIsFilled);
            system.debug('uomIsFilled:'+uomIsFilled);
            system.debug('quantityIsFilled:'+quantityIsFilled);
            system.debug('moqIsFilled:'+moqIsFilled);
            system.debug('supplierIsFilled:'+supplierIsFilled);
            system.debug('currencyIsFilled:'+currencyIsFilled);
            system.debug('referencePriceIsFilled:'+referencePriceIsFilled);
            system.debug('priceExpiryDateIsFilled:'+priceExpiryDateIsFilled);
            system.debug('leadTimeFormatIsFilled:'+leadTimeFormatIsFilled);
            system.debug('leadTimeDaysIsFilled:'+leadTimeDaysIsFilled);

            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Item_Details, false);
            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Catalog, false);
            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_UOM, false);
            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Quantity, false);
            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Supplier, false);
            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Reference_Price, false);
            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_MOQ, false);
            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Lead_Time, false);
            
            if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) { 
                if(itemNameIsFilled || catalogIsFilled ||
                    descriptionIsFilled || uomIsFilled ||
                    moqIsFilled || supplierIsFilled ||
                    currencyIsFilled || referencePriceIsFilled ||
                    priceExpiryDateIsFilled || leadTimeFormatIsFilled ||
                    leadTimeDaysIsFilled) {
                    
                    tempKeyInsertCatalogItemMap.put(reader, keyCatalogItemListMap.get(reader));


                    //1st column
                    if(!catalogIsFilled ) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Catalog, true);
                    }
                    //2nd column
                    if(!itemNameIsFilled) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Item_Details, true);
                    }
                    if(!descriptionIsFilled) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Item_Details, true);
                    }
                    
                    //3rd column
                    if(!uomIsFilled) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_UOM, true);    
                    }
                    
                    if(moqIsFilled) {
                        if(!supplierIsFilled) {
                            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Supplier, true);
                        }                    
                    }
                    
                    if(supplierIsFilled || currencyIsFilled || 
                       referencePriceIsFilled || priceExpiryDateIsFilled ||
                        leadTimeFormatIsFilled || leadTimeDaysIsFilled) {
                       
                        if(!supplierIsFilled) {
                            keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Supplier, true);
                        
                        }
                        if(currencyIsFilled || referencePriceIsFilled || priceExpiryDateIsFilled ) {
                            if(!currencyIsFilled) {
                                keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Reference_Price, true);
                            }
                            
                            if(!referencePriceIsFilled) {
                                keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Reference_Price, true);
                            }                        
                        }

                        
                        if(leadTimeFormatIsFilled || leadTimeDaysIsFilled) {
                            
                            if(!leadTimeFormatIsFilled) {
                                keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Lead_Time, true);
                            }
                            if(!leadTimeDaysIsFilled) {
                                keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Lead_Time, true);
                            }                        
                        }                                                
                    }
                }
                else if(!itemNameIsFilled && !catalogIsFilled &&
                    !descriptionIsFilled && !uomIsFilled &&
                    !moqIsFilled && !supplierIsFilled &&
                    !currencyIsFilled && !referencePriceIsFilled &&
                    !priceExpiryDateIsFilled && !leadTimeFormatIsFilled && 
                    !leadTimeDaysIsFilled) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Item_Details, false);
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Catalog, false);
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_UOM, false);
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Quantity, false);
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Supplier, false);
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Reference_Price, false);
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_MOQ, false);
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Lead_Time, false);
                }
            }
            else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM){
                if(itemNameIsFilled || catalogIsFilled ||
                    descriptionIsFilled || uomIsFilled ||
                    quantityIsFilled) {
                    
                    tempKeyInsertCatalogItemMap.put(reader, keyCatalogItemListMap.get(reader));
                    
                    if(!catalogIsFilled ) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Catalog, true);
                    }
                    if(!itemNameIsFilled) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Item_Details, true);
                    }
                    

                    
                    if(!descriptionIsFilled) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Item_Details, true);
                    }
                    
                    if(!uomIsFilled) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_UOM, true);
                    }      
                    
                    if(!quantityIsFilled) {
                        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Quantity, true);
                    }              
                } 
                
                system.debug('non catalog Item keyRequiredMap:'+keyRequiredMap);
            }                        
       }  
       

       for(Map<String,Boolean> reader : keyRequiredMap.values()) {
           
           if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                if( reader.get(Label.IDP_Create_Catalog_Item_Validation_Catalog) == true || reader.get(Label.IDP_Create_Catalog_Item_Validation_Item_Details) == true  ||
                    reader.get(Label.IDP_Create_Catalog_Item_Validation_UOM) == true  || reader.get(Label.IDP_Create_Catalog_Item_Validation_Supplier) == true ||
                    reader.get(Label.IDP_Create_Catalog_Item_Validation_Reference_Price) == true  || reader.get(Label.IDP_Create_Catalog_Item_Validation_MOQ) == true ||
                    reader.get(Label.IDP_Create_Catalog_Item_Validation_Lead_Time) == true) {

                    tempKeyInsertCatalogItemMap.clear();
                    break;
                }

           }
           else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
                if(reader.get(Label.IDP_Create_Catalog_Item_Validation_Catalog) == true || reader.get(Label.IDP_Create_Catalog_Item_Validation_Item_Details) == true  ||
                    reader.get(Label.IDP_Create_Catalog_Item_Validation_UOM) == true  || reader.get(Label.IDP_Create_Catalog_Item_Validation_Quantity) == true) {
                    tempKeyInsertCatalogItemMap.clear();
                    break;                
                
                }
            }
       }
       return tempKeyInsertCatalogItemMap;
    }
    //public Map<String, Catalog_Item__c> validateInput_before_lead_Time() {
    //   Map<String, Catalog_Item__c> tempKeyInsertCatalogItemMap = new Map<String, Catalog_Item__c> ();
    //   for(String reader : keyCatalogItemListMap.keySet()) {
            
    //        Boolean itemNameIsFilled = !String.isblank(keyCatalogItemListMap.get(reader).Item_Name__c);
    //        Boolean catalogIsFilled = !String.isblank(keyCatalogItemListMap.get(reader).Catalog__c);
    //        Boolean descriptionIsFilled = !String.isblank(keyCatalogItemListMap.get(reader).Description__c);
    //        Boolean uomIsFilled = !String.isblank(keyCatalogItemListMap.get(reader).Unit_Of_Measure__c);
    //        Boolean moqIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Minimum_Order_Quantity__c));
    //        Boolean supplierIsFilled = !String.isBlank(keySupplierItemMap.get(reader).Supplier__c);
    //        Boolean currencyIsFilled = !String.isBlank(keySupplierItemMap.get(reader).Currency__c);
    //        Boolean referencePriceIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Price__c));
    //        Boolean priceExpiryDateIsFilled = !String.isBlank(String.valueOf(keySupplierItemMap.get(reader).Expiry_Date__c));
    //        Boolean quantityIsFilled = !String.isBlank(String.valueOf(keyShoppingCartItemMap.get(reader).Quantity__c));
            
    //        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Item_Details, false);
    //        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Catalog, false);
    //        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_UOM, false);
    //        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Quantity, false);
    //        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_MOQ, false);
    //        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Supplier, false);
    //        keyRequiredMap.get(reader).put(Label.IDP_Create_Catalog_Item_Validation_Reference_Price, false);

    //        /*
    //        keyRequiredMap.get(reader).put('itemName', false);
    //        keyRequiredMap.get(reader).put('catalog', false);
    //        keyRequiredMap.get(reader).put('description', false);
    //        keyRequiredMap.get(reader).put('unitOfMeasure', false);
    //        keyRequiredMap.get(reader).put('quantity', false);
    //        keyRequiredMap.get(reader).put('minimumOrderQuantity', false);
    //        keyRequiredMap.get(reader).put('supplier', false);
    //        keyRequiredMap.get(reader).put('currency', false);
    //        keyRequiredMap.get(reader).put('referencePrice', false);
    //        keyRequiredMap.get(reader).put('priceExpiryDate', false);
    //        */
    //        if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) { 
    //            if(itemNameIsFilled || catalogIsFilled ||
    //                descriptionIsFilled || uomIsFilled ||
    //                moqIsFilled || supplierIsFilled ||
    //                currencyIsFilled || referencePriceIsFilled ||
    //                priceExpiryDateIsFilled ) {
                    
    //                tempKeyInsertCatalogItemMap.put(reader, keyCatalogItemListMap.get(reader));

    //                if(!itemNameIsFilled) {
    //                    keyRequiredMap.get(reader).put('itemName', true);
    //                }
                    
    //                if(!catalogIsFilled ) {
    //                    keyRequiredMap.get(reader).put('catalog', true);
    //                }
                    
    //                if(!descriptionIsFilled) {
    //                    keyRequiredMap.get(reader).put('description', true);
    //                }
                    
    //                if(!uomIsFilled) {
    //                    keyRequiredMap.get(reader).put('unitOfMeasure', true);    
    //                }
                    
    //                if(supplierIsFilled || currencyIsFilled || referencePriceIsFilled || priceExpiryDateIsFilled ) {
    //                    if(!supplierIsFilled) {
    //                        keyRequiredMap.get(reader).put('supplier', true);
                        
    //                    }
    //                    if(!currencyIsFilled) {
    //                        keyRequiredMap.get(reader).put('currency', true);
    //                    }
                        
    //                    if(!referencePriceIsFilled) {
    //                        keyRequiredMap.get(reader).put('referencePrice', true);
    //                    }
    //                }
    //            }
    //            else if(!itemNameIsFilled && !catalogIsFilled &&
    //                !descriptionIsFilled && !uomIsFilled &&
    //                !moqIsFilled && !supplierIsFilled &&
    //                !currencyIsFilled && !referencePriceIsFilled &&
    //                !priceExpiryDateIsFilled ) {
    //                        keyRequiredMap.get(reader).put('itemName', false);    
    //                        keyRequiredMap.get(reader).put('catalog', false);    
    //                        keyRequiredMap.get(reader).put('description', false);   
    //                        keyRequiredMap.get(reader).put('unitOfMeasure', false);                    
    //                        keyRequiredMap.get(reader).put('minimumOrderQuantity', false);  
    //                        keyRequiredMap.get(reader).put('supplier', false);   
    //                        keyRequiredMap.get(reader).put('currency', false);   
    //                        keyRequiredMap.get(reader).put('referencePrice', false);   
    //                        keyRequiredMap.get(reader).put('priceExpiryDate', false);   
    //            }

    //        }
    //        else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM){
    //            if(itemNameIsFilled || catalogIsFilled ||
    //                descriptionIsFilled || uomIsFilled ||
    //                quantityIsFilled) {
                    
    //                tempKeyInsertCatalogItemMap.put(reader, keyCatalogItemListMap.get(reader));

    //                if(!itemNameIsFilled) {
    //                    keyRequiredMap.get(reader).put('itemName', true);
    //                }
                    
    //                if(!catalogIsFilled ) {
    //                    keyRequiredMap.get(reader).put('catalog', true);
    //                }
                    
    //                if(!descriptionIsFilled) {
    //                    keyRequiredMap.get(reader).put('description', true);
    //                }
                    
    //                if(!uomIsFilled) {
    //                    keyRequiredMap.get(reader).put('unitOfMeasure', true);    
    //                }      
                    
    //                if(!quantityIsFilled) {
    //                    keyRequiredMap.get(reader).put('quantity', true);
    //                }              
    //            } 
            
    //        }
            
            
    //   }
       

    //   for(Map<String,Boolean> reader : keyRequiredMap.values()) {
           
    //       if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
    //            if( reader.get('itemName') == true || reader.get('catalog') == true  ||
    //                reader.get('description') == true  || reader.get('unitOfMeasure') == true ||
    //                reader.get('minimumOrderQuantity') == true  || reader.get('supplier') == true ||
    //                reader.get('currency') == true  || reader.get('referencePrice') == true ||
    //                reader.get('priceExpiryDate') == true ) {

    //                tempKeyInsertCatalogItemMap.clear();
    //                break;
    //            }

    //       }
    //       else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
    //            if( reader.get('itemName') == true || reader.get('catalog') == true  ||
    //            reader.get('description') == true  || reader.get('unitOfMeasure') == true ||
    //            reader.get('quantity') == true) {
    //                tempKeyInsertCatalogItemMap.clear();
    //                break;                
                
    //            }
    //        }
    //   }
            
    //   return tempKeyInsertCatalogItemMap;    
    //}    

    //outdated
    //public Map<String, Catalog_Item__c> validateInput_beforeSupplier() {
    //   Map<String, Catalog_Item__c> tempKeyInsertCatalogItemMap = new Map<String, Catalog_Item__c> ();
    //   for(String reader : keyCatalogItemListMap.keySet()) {
    //        if(String.isblank(keyCatalogItemListMap.get(reader).Item_Name__c)) {
    //            keyRequiredMap.get(reader).put('itemName', true);
    //        }
    //        else {
    //            keyRequiredMap.get(reader).put('itemName', false);    
    //        }
            
    //        if(String.isblank(keyCatalogItemListMap.get(reader).Catalog__c)) {
    //            keyRequiredMap.get(reader).put('catalog', true);
    //        }
    //        else {
    //            keyRequiredMap.get(reader).put('catalog', false);    
    //        } 
                      
    //        if(String.isblank(keyCatalogItemListMap.get(reader).Description__c)) {
    //            keyRequiredMap.get(reader).put('description', true);
    //        }
    //        else {
    //            keyRequiredMap.get(reader).put('description', false);    
    //        }
            
    //        //if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
    //            if(String.isblank(keyCatalogItemListMap.get(reader).Unit_Of_Measure__c)) {
    //                keyRequiredMap.get(reader).put('unitOfMeasure', true);
    //            }
    //            else {
    //                keyRequiredMap.get(reader).put('unitOfMeasure', false);    
    //            }
    //        //}
    //        /*
    //        else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
    //            if(keyCatalogItemListMap.get(reader).Unit_Of_Measure__c == '[]') {
    //                keyRequiredMap.get(reader).put('unitOfMeasure', true);
    //            }
    //            else {
    //                keyRequiredMap.get(reader).put('unitOfMeasure', false);    
    //            }
    //        }
    //        */
            
    //        if(String.isblank(keyCatalogItemListMap.get(reader).Currency__c)) {
    //                keyRequiredMap.get(reader).put('currency', true);
    //        }
    //        else {
    //            keyRequiredMap.get(reader).put('currency', false); 
    //        }
            
    //        if(String.isblank(String.valueOf(keyCatalogItemListMap.get(reader).Reference_Price__c))) {
    //            keyRequiredMap.get(reader).put('referencePrice', true);
    //        }         
    //        else {
    //            keyRequiredMap.get(reader).put('referencePrice', false);    
    //        }
            
    //        if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
    //            if(String.isblank(String.valueOf(keyShoppingCartItemMap.get(reader).Quantity__c))) {
    //                keyRequiredMap.get(reader).put('quantity', true);
    //            }         
    //            else {
    //                keyRequiredMap.get(reader).put('quantity', false);    
    //            }
    //        }
            
    //        if((keyRequiredMap.get(reader).get('currency') == true && keyRequiredMap.get(reader).get('referencePrice') == true) ||
    //            (keyRequiredMap.get(reader).get('currency') == false && keyRequiredMap.get(reader).get('referencePrice') == false) ) {
                 
    //            keyRequiredMap.get(reader).put('currency', false);   
    //            keyRequiredMap.get(reader).put('referencePrice', false);
                
    //            if( keyRequiredMap.get(reader).get('itemName') == true && keyRequiredMap.get(reader).get('catalog') == true &&
    //                keyRequiredMap.get(reader).get('description') == true && keyRequiredMap.get(reader).get('unitOfMeasure') == true) {

    //                if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
    //                    if(keyRequiredMap.get(reader).get('quantity') == true) {
    //                        keyRequiredMap.get(reader).put('itemName', false);    
    //                        keyRequiredMap.get(reader).put('catalog', false);    
    //                        keyRequiredMap.get(reader).put('description', false);   
    //                        keyRequiredMap.get(reader).put('unitOfMeasure', false);
    //                        keyRequiredMap.get(reader).put('quantity', false); 
    //                    }
    //                }
    //                else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
    //                    keyRequiredMap.get(reader).put('itemName', false);    
    //                    keyRequiredMap.get(reader).put('catalog', false);    
    //                    keyRequiredMap.get(reader).put('description', false);   
    //                    keyRequiredMap.get(reader).put('unitOfMeasure', false);
    //                }
    //            }
    //            else if( keyRequiredMap.get(reader).get('itemName') == false && keyRequiredMap.get(reader).get('catalog') == false &&
    //                keyRequiredMap.get(reader).get('description') == false && keyRequiredMap.get(reader).get('unitOfMeasure') == false) {
                    
    //                if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
    //                    if(keyRequiredMap.get(reader).get('quantity') == false) {
    //                        tempKeyInsertCatalogItemMap.put(reader, keyCatalogItemListMap.get(reader));
    //                    }
    //                }
    //                else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
    //                    tempKeyInsertCatalogItemMap.put(reader, keyCatalogItemListMap.get(reader));
    //                }
    //            }
                
                            
    //        }
            

    //   }
       
    //   for(Map<String,Boolean> reader : keyRequiredMap.values()) {
    //        if( reader.get('itemName') == true || reader.get('catalog') == true  ||
    //            reader.get('description') == true  || reader.get('unitOfMeasure') == true ||
    //            reader.get('currency') == true  || reader.get('referencePrice') == true ) {
    //            if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
    //                tempKeyInsertCatalogItemMap.clear();
    //                break;
    //            }
    //            if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
    //                if(reader.get('quantity') == true) {
    //                    tempKeyInsertCatalogItemMap.clear();
    //                    break;
    //                }
    //            }
    //        }
    //   }
    //    if(tempKeyInsertCatalogItemMap.size() > 0) {
    //        if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
    //            for(String reader : keyCatalogItemListMap.keySet()) {
    //                //system.debug(keyCatalogItemListMap.get(reader).Unit_Of_Measure__c);
    //                //keyCatalogItemListMap.get(reader).Unit_Of_Measure__c = keyCatalogItemListMap.get(reader).Unit_Of_Measure__c.right(keyCatalogItemListMap.get(reader).Unit_Of_Measure__c.length() - 1); 
    //                //keyCatalogItemListMap.get(reader).Unit_Of_Measure__c = keyCatalogItemListMap.get(reader).Unit_Of_Measure__c.left(keyCatalogItemListMap.get(reader).Unit_Of_Measure__c.length() - 1); 
    //                //keyCatalogItemListMap.get(reader).Unit_Of_Measure__c = keyCatalogItemListMap.get(reader).Unit_Of_Measure__c.replace(',',';');
    //                //system.debug(keyCatalogItemListMap.get(reader).Unit_Of_Measure__c);

    //            }
    //        }
    //    }
                      
    //   return tempKeyInsertCatalogItemMap;    
    //}
    
    
    /*
    public Map<String, Catalog_Item__c> validateInputOLD() {
    
       Map<String, Catalog_Item__c> tempKeyInsertCatalogItemMap = new Map<String, Catalog_Item__c> ();
       for(String reader : keyCatalogItemListMap.keySet()) {


            if(String.isblank(keyCatalogItemListMap.get(reader).Item_Name__c)) {
                keyRequiredMap.get(reader).put('itemName', true);
            }
            else {
                keyRequiredMap.get(reader).put('itemName', false);    
            }
            
            if(String.isblank(keyCatalogItemListMap.get(reader).Catalog__c)) {
                keyRequiredMap.get(reader).put('catalog', true);
            }
            else {
                keyRequiredMap.get(reader).put('catalog', false);    
            } 
                      
            if(String.isblank(keyCatalogItemListMap.get(reader).Description__c)) {
                keyRequiredMap.get(reader).put('description', true);
            }
            else {
                keyRequiredMap.get(reader).put('description', false);    
            }
            
            
            //else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
              if(String.isblank(keyCatalogItemListMap.get(reader).Unit_Of_Measure__c)) {
                    keyRequiredMap.get(reader).put('unitOfMeasure', true);
                }
                else {
                    keyRequiredMap.get(reader).put('unitOfMeasure', false);    
                }
            //}

            if(String.isblank(keyCatalogItemListMap.get(reader).Currency__c)) {
                    keyRequiredMap.get(reader).put('currency', true);
            }
            else {
                keyRequiredMap.get(reader).put('currency', false); 
            }
            
            if(String.isblank(String.valueOf(keyCatalogItemListMap.get(reader).Reference_Price__c))) {
                keyRequiredMap.get(reader).put('referencePrice', true);
            }         
            else {
                keyRequiredMap.get(reader).put('referencePrice', false);    
            }
            
            if(String.isblank(String.valueOf(keyShoppingCartItemMap.get(reader).Quantity__c))) {
                keyRequiredMap.get(reader).put('quantity', true);
            }         
            else {
                keyRequiredMap.get(reader).put('quantity', false);    
            } 
            
            

            
            // all the fields (or except currency and reference price fields) are filled in 
            if( keyRequiredMap.get(reader).get('itemName') == false && keyRequiredMap.get(reader).get('catalog') == false &&
                keyRequiredMap.get(reader).get('description') == false && keyRequiredMap.get(reader).get('unitOfMeasure') == false &&
                ((keyRequiredMap.get(reader).get('currency') == false && keyRequiredMap.get(reader).get('referencePrice') == false) ||
                (keyRequiredMap.get(reader).get('currency') == true && keyRequiredMap.get(reader).get('referencePrice') == true))) {
                
                if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                    tempKeyInsertCatalogItemMap.put(reader, keyCatalogItemListMap.get(reader));
                }
                else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
                    if(keyRequiredMap.get(reader).get('quantity') == false) {
                        tempKeyInsertCatalogItemMap.put(reader, keyCatalogItemListMap.get(reader));
                    }
                }
                
            }
            //all the fields are not filled in 
            if( keyRequiredMap.get(reader).get('itemName') == true && keyRequiredMap.get(reader).get('catalog') == true  &&
                keyRequiredMap.get(reader).get('description') == true  && keyRequiredMap.get(reader).get('unitOfMeasure') == true &&
                keyRequiredMap.get(reader).get('currency') == true && keyRequiredMap.get(reader).get('referencePrice') == true) {
                //set all the message flag to false
                keyRequiredMap.get(reader).put('itemName', false);    
                keyRequiredMap.get(reader).put('catalog', false);    
                keyRequiredMap.get(reader).put('description', false);   
                keyRequiredMap.get(reader).put('unitOfMeasure', false);
                  
                if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
                    if(keyRequiredMap.get(reader).get('quantity') == true) {
                        keyRequiredMap.get(reader).put('quantity', false);                    
                    }
                }                
            }
            
            //both currency and reference price fields are empty
            if(String.isblank(keyCatalogItemListMap.get(reader).Currency__c) && String.isblank(String.valueOf(keyCatalogItemListMap.get(reader).Reference_Price__c))) {
                keyRequiredMap.get(reader).put('currency', false); 
                keyRequiredMap.get(reader).put('referencePrice', false);  
            }
            
       }
       
        for(Map<String,Boolean> reader : keyRequiredMap.values()) {
            if( reader.get('itemName') == true || reader.get('catalog') == true  ||
                reader.get('description') == true  || reader.get('unitOfMeasure') == true ||
                reader.get('currency') == true  || reader.get('referencePrice') == true ) {
                if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                    tempKeyInsertCatalogItemMap.clear();
                    break;
                }
                if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
                    if(reader.get('quantity') == true) {
                        tempKeyInsertCatalogItemMap.clear();
                        break;
                        }
                }
            }
        }
        

        return tempKeyInsertCatalogItemMap;
    }
    */
    
    public List<SelectOption> loadCurrencySelectOptionList() {
        List<SelectOption> tempCurrencySelectOptionList = new List<SelectOption>();

        for(Currency__c reader: [SELECT Id, Name, Available__c FROM Currency__c WHERE Available__c = true ORDER BY NAME]) {
            tempCurrencySelectOptionList.add(new SelectOption(reader.Id, reader.Name));
        }
        
        return tempCurrencySelectOptionList;
    }
    
    public void loadCatalogSelectOptionList () {
        //List<SelectOption> tempCatalogSelectOptionList = new List<SelectOption> ();
        Map<String, String> catalogNamecatalogIdMap = new Map<String, String> ();
        Map<Id, Set<Id>> tempUserOwnerCatalogSetMap = new Map<Id, Set<Id>> ();
        List<Catalog_Item_Permission__c> userAllPermissionList = new List<Catalog_Item_Permission__c>();
        List<String> sortedCatalogNameList = new List<String> ();
        Set<String> levelOneCatalogIdSet = new Set<String> ();
        Set<Id> tempUserIdSet = new Set<Id> (); 

        createStandardCatalogSelectOptionList.add( new SelectOption('', ''));
        createNonCatalogSelectOptionList.add( new SelectOption('', ''));    
        tempUserIdSet.add(userId);
                   
        tempUserOwnerCatalogSetMap = IDPCommonUtils.getUserCatalogs(tempUserIdSet); 
            
        if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
       
            userAllPermissionList = IDPCommonUtils.getUserAllPermission(userId);
            for(Catalog_Item_Permission__c cip: userAllPermissionList) {
                
                if(cip.isCatalogLevel__c == true) {
                    if(cip.Catalog__r.Parent_Catalog__c == null) {
                        system.debug('cip.Catalog__c' + cip.Catalog__c);
                        system.debug('cip.Catalog__r.Catalog_Name__c' + cip.Catalog__r.Catalog_Name__c);
                        levelOneCatalogIdSet.add(cip.Catalog__c);       
                    }
                    else if(cip.Catalog__r.Parent_Catalog__c != null) {
                        catalogNamecatalogIdMap.put('/' + cip.Catalog__r.Parent_Catalog__r.Catalog_Name__c+'/' + cip.Catalog__r.Catalog_Name__c, cip.Catalog__c);
                    }
                }
                else if(cip.isCatalogItemLevel__c == true) {
                    catalogNamecatalogIdMap.put('/' + cip.Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c+'/' + cip.Catalog_Item__r.Catalog__r.Catalog_Name__c, cip.Catalog_Item__r.Catalog__c);
                }
            }
            system.debug(levelOneCatalogIdSet);
            system.debug(tempUserOwnerCatalogSetMap);
            system.debug(tempUserOwnerCatalogSetMap.get(userId));
            if(tempUserOwnerCatalogSetMap.containsKey(userId)) {
                for(Catalog__c reader : [SELECT Id, Name, Catalog_Name__c,Parent_Catalog__c, Parent_Catalog__r.Catalog_Name__c 
                                        FROM Catalog__c 
                                        WHERE (Parent_Catalog__c in :levelOneCatalogIdSet
                                                OR (
                                                    Parent_Catalog__c in : tempUserOwnerCatalogSetMap.get(userId)
                                                    AND Parent_Catalog__c  != null
                                                    )
                                            )]) { 
                    system.debug('/' + reader.Parent_Catalog__r.Catalog_Name__c+'/' + reader.Catalog_Name__c);
                    catalogNamecatalogIdMap.put('/' + reader.Parent_Catalog__r.Catalog_Name__c+'/' + reader.Catalog_Name__c, reader.Id);
                }
           }
           else if(!tempUserOwnerCatalogSetMap.containsKey(userId)) {
                for(Catalog__c reader : [SELECT Id, Name, Catalog_Name__c,Parent_Catalog__c, Parent_Catalog__r.Catalog_Name__c 
                                        FROM Catalog__c 
                                        WHERE Parent_Catalog__c in :levelOneCatalogIdSet]) { 
                    system.debug('/' + reader.Parent_Catalog__r.Catalog_Name__c+'/' + reader.Catalog_Name__c);
                    catalogNamecatalogIdMap.put('/' + reader.Parent_Catalog__r.Catalog_Name__c+'/' + reader.Catalog_Name__c, reader.Id);
                }
           }           
           
        }
        else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) { 
          
            for(Catalog__c reader : [SELECT Id, Name, Catalog_Name__c,Parent_Catalog__c, Parent_Catalog__r.Catalog_Name__c, 
                                        (SELECT Id, Name, Catalog_Name__c,Parent_Catalog__c, Parent_Catalog__r.Catalog_Name__c 
                                            FROM Catalogs__r)
                                    FROM Catalog__c 
//                                    WHERE OwnerId = : userId]){
                                    WHERE Parent_Catalog__c in : tempUserOwnerCatalogSetMap.get(userId)
                                    AND Parent_Catalog__c != null]) { 
                 if(reader.Parent_Catalog__c == null) {
                     
                     for(Catalog__c levelTwoCatalog : reader.Catalogs__r) {

                        catalogNamecatalogIdMap.put('/' + levelTwoCatalog.Parent_Catalog__r.Catalog_Name__c+'/' + levelTwoCatalog.Catalog_Name__c, levelTwoCatalog.Id);
                     }
                 }
                 else if(reader.Parent_Catalog__c != null) {
                    catalogNamecatalogIdMap.put('/' + reader.Parent_Catalog__r.Catalog_Name__c+'/' + reader.Catalog_Name__c, reader.Id);
                 }                  
            }
        
        }
        
        
        sortedCatalogNameList.addAll(CatalogNamecatalogIdMap.keySet());
        sortedCatalogNameList.sort();
        String selectOptionCatalogIdKey = '';
        String selectOptionCatalogNameValue = '';
        
        for(Integer i = 0; i < sortedCatalogNameList.size(); i++) {
            selectOptionCatalogIdKey = CatalogNamecatalogIdMap.get(sortedCatalogNameList.get(i));            
            selectOptionCatalogNameValue = sortedCatalogNameList.get(i);
            if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
                createNonCatalogSelectOptionList.add(new SelectOption(selectOptionCatalogIdKey,selectOptionCatalogNameValue));
            }
            else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                createStandardCatalogSelectOptionList.add(new SelectOption(selectOptionCatalogIdKey,selectOptionCatalogNameValue));
            }             
        }
        
        
                    /*
        String tempSelectOptionCatalogNameValue = '';
        String tempSelectOptionLevelOneCatalogNamValue = '';
        for(Integer i = 0; i < sortedCatalogNameList.size(); i++) {
            selectOptionCatalogIdKey = CatalogNamecatalogIdMap.get(sortedCatalogNameList.get(i));
            selectOptionCatalogNameValue  = '';
            tempSelectOptionCatalogNameValue = sortedCatalogNameList.get(i);
            
            for(Integer j = 0 ; j < tempSelectOptionCatalogNameValue.split('/').size() ; j ++) {
                
                if(j > 0) {
                    if( j == 1) {
                        if(tempSelectOptionLevelOneCatalogNamValue != tempSelectOptionCatalogNameValue.split('/').get(j)) {
                            SelectOption opt =new SelectOption('','<optgroup label=\'' + tempSelectOptionCatalogNameValue.split('/').get(j)+ '\'></optgroup>');
                            opt.setEscapeItem(false);
                            if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
                                createNonCatalogSelectOptionList.add(opt);
                            }
                            else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                                createStandardCatalogSelectOptionList.add(opt);
                            } 
                            tempSelectOptionLevelOneCatalogNamValue = tempSelectOptionCatalogNameValue.split('/').get(j);
                        }                            
                    }
                    else {
                        selectOptionCatalogNameValue +=  '/' + tempSelectOptionCatalogNameValue.split('/').get(j);
                    }
                }
            }
            if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM) {
                createNonCatalogSelectOptionList.add(new SelectOption(selectOptionCatalogIdKey,selectOptionCatalogNameValue));
            }
            else if(mode == IDPConstant.CREATE_CATALOG_ITEM_MODE_STANDARD) {
                createStandardCatalogSelectOptionList.add(new SelectOption(selectOptionCatalogIdKey,selectOptionCatalogNameValue));
            } 
        }
        */
        
        //createStandardCatalogSelectOptionList.add( new SelectOption('', 'Please Select'));                      
        //createNonCatalogSelectOptionList.add( new SelectOption('', 'Please Select'));                      

            
        //return tempCatalogSelectOptionList;
    }

    public List<SelectOption> loadCatalogItemAvailableUOMSelectOptionList(){
        List<SelectOption> tempCatalogItemAvailableUOMSelectOptionList = new List<SelectOption>();
        Schema.DescribeFieldResult optionFieldDescription = Catalog_Item__c.Unit_Of_Measure__c.getDescribe();
    
        for(Schema.PicklistEntry pleOptions : optionFieldDescription.getPicklistValues()){
         tempCatalogItemAvailableUOMSelectOptionList.add(new SelectOption(pleOptions.getvalue(),pleOptions.getLabel()));
        }
        return tempCatalogItemAvailableUOMSelectOptionList;
    }

    public List<SelectOption> loadLeadTimeFormatSelectOptionList(){
        
        List<SelectOption> tempLeadTimeFormatSelectOptionList = new List<SelectOption>();
        
        Schema.DescribeFieldResult optionFieldDescription = Supplier_Item__c.Lead_Time_Format__c.getDescribe();
    
        for(Schema.PicklistEntry pleOptions : optionFieldDescription.getPicklistValues()){
            tempLeadTimeFormatSelectOptionList.add(new SelectOption(pleOptions.getvalue(), pleOptions.getLabel()));
        }
        return tempLeadTimeFormatSelectOptionList;
    }


    public Map<String, Supplier__c> loadSupplierMap(){
    
        Map<String, Supplier__c> temp = new Map<String, Supplier__c>();
        
        for(supplier__c supplierReader : [select id,  Name, Currency__c, Currency__r.Name 
                                          from supplier__c 
                                          order by Name
                                          //limit 1000
                                         ]) {
            temp.put(supplierReader.Id, supplierReader);
        }
        
        return temp;
    }
        
    public List<SelectOption> loadSupplierFormatSelectOptionList(){
    
        List<SelectOption> temp = new List<SelectOption>();
        for(supplier__c supplierReader : this.supplierMap.values()) {
            temp.add(new SelectOption(supplierReader.Id, supplierReader.Name));
        
        }
        return temp;
    }
    
    Public void supplierOnChnageAction() {
        String PAGE_KEY = 'supplierKey';
        String tempKey = ApexPages.currentPage().getParameters().get(PAGE_KEY);
        String supplierId = '';
        Boolean isValid = false;
        
       
        if(!String.isBlank(tempKey)) {
            if(keySupplierItemMap.containsKey(tempKey)) {
                if(keySupplierItemMap.get(tempKey).supplier__c != null) {
                
                    supplierId = keySupplierItemMap.get(tempKey).supplier__c;
                    for(supplier__c reader : [select id, Currency__c, Currency__r.Name from supplier__c where id = :supplierId ]){
                        supplierMap.put(reader.id, reader);
                    }
                    if(supplierMap.containsKey(supplierId)) {
                        keySupplierItemMap.get(tempKey).Currency__c = supplierMap.get(supplierId).Currency__c;
                        isValid = true;
                    }
                }
            }
        }
       
        if(!isValid) {
            keySupplierItemMap.get(tempKey).Currency__c = null;
        }
        
            
    }
}