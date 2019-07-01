/**
 * IDPPurchaseRequestValidationsController 
 * @description validations controller for Purchase Request
 */
public without Sharing class IDPPurchaseRequestValidationsController{
    Public Static String KEY_TYPE = Label.IDP_Purchase_Request_Validation_Type;
    Public Static String KEY_CURRENCY = Label.IDP_Purchase_Request_Validation_Currency;
    Public Static String KEY_PRICE = Label.IDP_Purchase_Request_Validation_Price;
    Public Static String KEY_QUANTITY = Label.IDP_Purchase_Request_Validation_Quantity;
    Public Static String KEY_SUPPLIER = Label.IDP_Purchase_Request_Validation_Supplier;
    
    Public static List<String> PRValidationMessage(Purchase_Request__c  pr){
        List <String> messageList = new List <String>();
        if(pr.Need_by_Date__c < Date.today()){
            messageList.add('The need-by date must not be earlier than today');
        }
        
        return messageList;
    }
    
    public static Map<String, Map<String, Boolean>>  validatePurchaseRequestItemInput(Map<Id, SObject> pripcMap) {
        Map<String, Map<String, Boolean>> pripcIdFieldNameIsBlankMessageMap = new Map<String, Map<String, Boolean>> ();
        Map<String, Boolean> fieldNameIsBlankMessageMap = new Map<String, Boolean> ();
        Purchase_Request_Item__c priReader = null;
        Purchase_Cost__c pcReader = null;
        Boolean isTypeBlank = false;
        Boolean isCurrencyBlank = false;
        Boolean isPriceBlank = false;
        Boolean isQuantityBlank = false;
        Boolean isSupplierBlank = false;
        Schema.sObjectType priObjectType = Schema.Purchase_Request_Item__c.getSObjectType();
        Schema.sObjectType pcObjectType= Schema.Purchase_Cost__c.getSObjectType();        
        for(SObject reader : pripcMap.values() ) {
            fieldNameIsBlankMessageMap = new Map<String, Boolean> ();
            isTypeBlank = false;
            isCurrencyBlank = false;
            isPriceBlank = false;
            isQuantityBlank = false;
            isSupplierBlank = false;
            if(reader.getSObjectType() == priObjectType) {
                priReader = (Purchase_Request_Item__c) reader;
                if(priReader.Is_Direct_fulfillment__c) {
                    continue;
                }
                isCurrencyBlank = String.isBlank(priReader.Currency__c);            
                isPriceBlank = String.isBlank(String.valueOf(priReader.Price__c));
                isQuantityBlank = String.isBlank(String.valueOf(priReader.Quantity__c));
                isSupplierBlank = String.isBlank(priReader.Supplier__c);            
            }            
            else if(reader.getSObjectType() == pcObjectType) {
                pcReader = (Purchase_Cost__c) reader;
                isTypeBlank = String.isBlank(String.valueOf(pcReader.Type__c));
                isCurrencyBlank = String.isBlank(pcReader.Currency__c);            
                isPriceBlank = String.isBlank(String.valueOf(pcReader.Price__c));
                isSupplierBlank = String.isBlank(pcReader.Supplier__c);      
            }
            fieldNameIsBlankMessageMap.put(KEY_TYPE, isTypeBlank);
            fieldNameIsBlankMessageMap.put(KEY_CURRENCY, isCurrencyBlank);
            fieldNameIsBlankMessageMap.put(KEY_PRICE, isPriceBlank);
            fieldNameIsBlankMessageMap.put(KEY_QUANTITY, isQuantityBlank);
            fieldNameIsBlankMessageMap.put(KEY_SUPPLIER, isSupplierBlank);
            pripcIdFieldNameIsBlankMessageMap.put(reader.Id, fieldNameIsBlankMessageMap);            
        }     
        return pripcIdFieldNameIsBlankMessageMap;
    }
}