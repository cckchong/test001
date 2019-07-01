/*
  
  This is the Common Constand Class used across the IDP project-specific classes

*/

public without sharing class IDPConstant {

    //DataTable sorting picklist's selectOption key and value, loadSortingSelectOptionList method in IDPCommonUtils class if new constant is added.
    //The keys should equal to '[the field API Name] [Asc or Desc]' because they are directly used in the query order by
    
    //changed to used label, would be confirmed to delete later
    /*
    public static final string SORTING_FIELD_NAME_ASC_KEY = 'Name Asc';
    public static final string SORTING_FIELD_NAME_ASC_VALUE = 'Name Asc.';
    public static final string SORTING_FIELD_NAME_DESC_KEY = 'Name Desc';
    public static final string SORTING_FIELD_NAME_DESC_VALUE = 'Name Desc.';
        
    public static final string SORTING_FIELD_Last_SUPPLIER_ASC_KEY = 'Last_Supplier__c Asc';
    public static final string SORTING_FIELD_Last_SUPPLIER_ASC_VALUE = 'Last Supplier Asc.';
    public static final string SORTING_FIELD_Last_SUPPLIER_DESC_KEY = 'Last_Supplier__c Desc';
    public static final string SORTING_FIELD_Last_SUPPLIER_DESC_VALUE = 'Last Supplier Desc.';    

    public static final string SORTING_FIELD_REFERENCE_PRICE_ASC_KEY = 'Reference_Price__c Asc';
    public static final string SORTING_FIELD_REFERENCE_PRICE_ASC_VALUE = 'Reference Price Asc.';
    public static final string SORTING_FIELD_REFERENCE_PRICE_DESC_KEY = 'Reference_Price__c Desc';
    public static final string SORTING_FIELD_REFERENCE_PRICE_DESC_VALUE = 'Reference Price Desc.'; 
    
    public static final string SORTING_FIELD_UNIT_OF_MEASURE_ASC_KEY = 'Unit_of_Measure__c Asc';
    public static final string SORTING_FIELD_UNIT_OF_MEASURE_ASC_VALUE = 'Unit of Measure Asc.';
    public static final string SORTING_FIELD_UNIT_OF_MEASURE_DESC_KEY = 'Unit_of_Measure__c Desc';
    public static final string SORTING_FIELD_UNIT_OF_MEASURE_DESC_VALUE = 'Unit of Measure Desc.'; 
    */
    
    
    public static final string DEFAULT_SORTING_FIELD_KEY = Label.IDP_Sorting_Field_Name_Asc_Key; 

    //DataTable Display Currency Picklist's selectOption key and value
/*
    public static final string DISPLAY_FOREIGN_CURRENCY_KEY = 'Foreign'; 
    public static final string DISPLAY_FOREIGN_CURRENCY_VALUE = 'Foreign'; 

    public static final string DISPLAY_LOCAL_CURRENCY_KEY = 'Local'; 
    public static final string DISPLAY_LOCAL_CURRENCY_VALUE = 'Local'; 
*/
    public static final string DEFAULT_DISPLAY_CURRENCY_KEY = Label.IDP_Display_Currency_Original; 
    
    public static final string CATALOG_ITEM_STATUS_ACTIVE = 'ACT';
    public static final string CATALOG_ITEM_STATUS_INACTIVE = 'INACT';
    
    //Shopping Cart Status
    public static final String SHOPPING_CART_STATUS_OPEN = 'OP';
    public static final String SHOPPING_CART_STATUS_CLOSED = 'CL';


    //Purchase Cost Type
    public static final String PURCHASE_COST_TYPE_TAX = 'TAX';
    public static final String PURCHASE_COST_TYPE_SHIPPING = 'SHIP';
    public static final String PURCHASE_COST_TYPE_OTHER_COST = 'OTHERS';

    //Purchase Request Status
    public static final String PURCHASE_REQUEST_STATUS_DRAFT = 'DF';
    public static final String PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION = 'PPC';
    public static final String PURCHASE_REQUEST_STATUS_PENDING_APPROVAL = 'PA';
    public static final String PURCHASE_REQUEST_STATUS_APPROVED = 'AP';
    public static final String PURCHASE_REQUEST_STATUS_REJECTED = 'RJ';
    public static final String PURCHASE_REQUEST_STATUS_NOT_SUBMITTED = 'NS';
    public static final String PURCHASE_REQUEST_STATUS_CANCELLED = 'CN';
    public static final String PURCHASE_REQUEST_STATUS_SUBMITTED = 'SB';
    public static final String PURCHASE_REQUEST_STATUS_ORDERED = 'ORD';
    public static final String PURCHASE_REQUEST_STATUS_PARTIAL_ORDERED = 'PO';
    public static final String PURCHASE_REQUEST_STATUS_PARTIAL_DELIVERED = 'PD';
    public static final String PURCHASE_REQUEST_STATUS_DELIVERED = 'DEL';
    public static final String PURCHASE_REQUEST_STATUS_CLOSED = 'CL';

    

    //Purchase Request Item Status
    public static final String PURCHASE_REQUEST_ITEM_STATUS_DRAFT = 'DF';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_PENDING_PURCHASE_CONFIRMATION = 'PPC';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_PENDING_APPROVAL = 'PA';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_APPROVED = 'AP';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_REJECTED = 'RJ';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_NOT_SUBMITTED = 'NS';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_CANCELLED = 'CN';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_SUBMITTED = 'SB';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_ORDERED = 'ORD';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_DELIVERED = 'DEL';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_PARTIAL_ORDERED = 'PO';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_PARTIAL_DELIVERED = 'PD';
    public static final String PURCHASE_REQUEST_ITEM_STATUS_CLOSED = 'CL';
    
    //Purchase Order Status
    public static final String PURCHASE_ORDER_STATUS_DRAFT = 'DF';
    public static final String PURCHASE_ORDER_STATUS_ORDERED = 'ORD';
    public static final String PURCHASE_ORDER_STATUS_DELIVERED = 'DEL';
    public static final String PURCHASE_ORDER_STATUS_PARTIAL_ORDERED = 'PO';
    public static final String PURCHASE_ORDER_STATUS_PARTIAL_DELIVERED = 'PD';
    public static final String PURCHASE_ORDER_STATUS_CLOSED = 'CL';
    public static final String PURCHASE_ORDER_STATUS_CANCELLED = 'CN';
    public static final String PURCHASE_ORDER_STATUS_INVOICED = 'INV';
    
    //Purchase Order Item Status
    public static final String PURCHASE_ORDER_ITEM_STATUS_DRAFT = 'DF';
    public static final String PURCHASE_ORDER_ITEM_STATUS_ORDERED = 'ORD';
    public static final String PURCHASE_ORDER_ITEM_STATUS_DELIVERED = 'DEL';
    public static final String PURCHASE_ORDER_ITEM_STATUS_PARTIAL_ORDERED = 'PO';
    public static final String PURCHASE_ORDER_ITEM_STATUS_PARTIAL_DELIVERED = 'PD';
    public static final String PURCHASE_ORDER_ITEM_STATUS_CLOSED = 'CL';
    public static final String PURCHASE_ORDER_ITEM_STATUS_CANCEL = 'CN';
    public static final String PURCHASE_ORDER_ITEM_STATUS_INVOICED = 'INV';

    //Expense Category
    public static final String EXPENSE_CATEGORY_GENERAL = 'General';

    //Create Catalog item Mode
    public static final String CREATE_CATALOG_ITEM_MODE_PARAMETER_NAME = 'mode';
    public static final String CREATE_CATALOG_ITEM_MODE_STANDARD = 'Standard';
    public static final String CREATE_CATALOG_ITEM_MODE_NON_CATALOG_ITEM = 'nonCatalogitem';
    
    //Random Number
    Public static final String RANDOM_STRING = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    
    //public Queue
    Public static final String PROCUREMENT_QUEUE = 'IDP_Procurement_@policy';
    Public static final String CATALOG_QUEUE = 'IDP_Catalog_@name';
    


}