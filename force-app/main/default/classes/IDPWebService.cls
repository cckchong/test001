public without sharing class IDPWebService {
    public IDPWebService() {
        
    }

    public static String submitNewPOtoMule(Purchase_Order__c po, List<Purchase_Order_Item__c> poiList) {
        String result = '';
        /*
        Purchase_Order__c newPO = [SELECT Name, Delivery_Site__r.Warehouse__c, 
                                     Delivery_Site__r.Name, Supplier__r.Name, Status__c, 
                                     Applicant__r.User__r.sAMAccountName__c, Submitted_Date__c, 
                                     Delivery_Date__c, Delivery_Terms__c, Delivery_Method__c, 
                                     Payment_Terms__c, Payment_Method__c, Currency__r.Name, 
                                     Supplier__r.Media_Profile__c, Shipping_Address__c 
                                     FROM Purchase_Order__c WHERE Id = :po.Id];
        */
        system.debug('newPO:'+getPOJson(po, poiList));
        try{
             HttpRequest req = new HttpRequest();
             //req.setEndpoint('http://testsfdcpush.cloudhub.io');
             req.setEndpoint(Label.IDP_Mule_Create_PO);
             req.setMethod('POST');
             req.setHeader('Content-Type', 'application/json');
             req.setBody(getPOJson(po, poiList));
             //req.setTimeout(100000);
             req.setTimeout(50000);

             Http http = new Http();
             HTTPResponse res = http.send(req);
             Integer statusCode = res.getStatusCode();

             System.debug('Mulesoft response:'+res.getBody());
             result = res.getBody();

             if (statusCode != 200){
                system.debug(res.getBody());
                throw new IDPWebServiceException ('Mulesoft - ' + res.getBody());
            
            }
             
        } catch (Exception e) {
            throw new IDPWebServiceException (e.getMessage());
            system.debug(e.getMessage());
        }

        return result;
    }

    //public static String updatePOtoMule(Purchase_Order__c po) {

    //  system.debug(LoggingLevel.ERROR, '@updatePOtoMule()');
    //  system.debug('newPO:'+getPOJson(po, new List<Purchase_Order_Item__c>()));

    //  try{
    //       HttpRequest req = new HttpRequest();
    //       req.setEndpoint('http://testsfdcpush.cloudhub.io');
    //       req.setMethod('POST');
    //       req.setHeader('Content-Type', 'application/json');
    //       //req.setBody(getPOJson(newPO));
    //       req.setTimeout(3000);

    //       Http http = new Http();
    //       HTTPResponse res = http.send(req);
    //       Integer statusCode = res.getStatusCode();

    //       System.debug(LoggingLevel.ERROR, res.getBody());
             
    //  } catch (Exception e) {
    //      throw new IDPWebServiceException ('Mulesoft Error: ' + e.getMessage());
    //  }

    //  return '';
    //}

    public static String getPOJson(Purchase_Order__c po, List<Purchase_Order_Item__c> poiList) {
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(po));
        String ADAccountName = '';
        if(String.isBlank(po.Applicant__r.User__r.sAMAccountName__c)){
            ADAccountName = '';
        }
        else{
            ADAccountName = po.Applicant__r.User__r.sAMAccountName__c;
        }        
        m.put('Currnecy_Name__c',           po.Currency__r.Name);
        m.put('Warehouse__c',               po.Delivery_Site__r.Warehouse__c);
        m.put('Delivery_Site_Name__c',      po.Delivery_Site__r.Name);
        m.put('Supplier_Code__c',           po.Supplier__r.Supplier_Code__c);
        m.put('Supplier_Name__c',           po.Supplier__r.Name);
        m.put('Purchase_AD_Account_Name__c',ADAccountName.toUpperCase());
        m.put('Media_Profile__c',           po.Supplier__r.Media_Profile__c);
        m.put('country_code__c',           po.Delivery_Site__r.country_code__c);
        //m.put('Submitted_Date__c', System.today().format());

        for(String mKey : m.keySet()) {
            if (mKey.lastIndexOf('__r') > 0) {
                m.remove(mKey);
            }
        }

        List<Map<String, Object>> poiMapList = new List<Map<String, Object>>();
        //List<Purchase_Order_Item__c> poiList = [SELECT Name, Purchase_Order__r.Name, Purchase_Order__r.Delivery_Site__r.Warehouse__c, Purchase_Order__r.Supplier__r.Name, M3_PO_NO__c, Number__c, Catalog__c, Quantity__c, Unit_of_Measure__c, Price__c, Currency__r.Name, Delivery_Date__c, Catalog_Item__r.Item_Name__c, Catalog_item__r.Description__c, Buyer_Remark__c, Received_Quantity__c FROM Purchase_Order_Item__c WHERE Purchase_Order__c = :po.Id];
        for (Purchase_Order_Item__c poi : poiList) {
            Map<String, Object> poiMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(poi));
            poiMap.put('PO_NO',                 po.Name);
            poiMap.put('Warehouse__c',          po.Delivery_Site__r.Warehouse__c);
            poiMap.put('Supplier_Code__c',      po.Supplier__r.Supplier_Code__c);
            poiMap.put('Supplier_Name__c',      po.Supplier__r.Name);
            poiMap.put('Catalog_Code__c',       poi.Catalog_Item__r.Catalog__r.M3_Catalog_Code__c);
            poiMap.put('Catalog_Item_Name__c',  poi.Catalog_Item__r.Item_Name__c);
            poiMap.put('Catalog_Item_Desc__c',  poi.Catalog_Item__r.Description__c);
            poiMap.put('Currnecy_Name__c',      poi.Currency__r.Name);

            for(String mKey : poiMap.keySet()) {
                if (mKey.lastIndexOf('__r') > 0) {
                    poiMap.remove(mKey);
                }
            }

            poiMapList.add(poiMap);
        }

        m.put('POLineItem', poiMapList);

        return JSON.serialize(m);       
    }
/*

    public static String sendReceivingQtyToMule(Purchase_Order__c po, List<Receiving_History__c> newReceivingHistList) {
        String result = '';

        // Produce json format
        // jsonStr:[{"Received_Quantity__c":5,"Number__c":1,"M3_PO_No__c":null},{"Received_Quantity__c":2,"Number__c":2,"M3_PO_No__c":null},{"Received_Quantity__c":2,"Number__c":3,"M3_PO_No__c":null}]
        String jsonStr = getReceivingHistJson(po, newReceivingHistList);
        system.debug('newReceivingHistList:'+newReceivingHistList);
        system.debug('jsonStr:'+jsonStr);

        try{
             HttpRequest req = new HttpRequest();
             //req.setEndpoint('http://testsfdcpush.cloudhub.io');
             req.setEndpoint(Label.IDP_Mule_Update_Receiving_Qty);
             req.setMethod('POST');
             req.setHeader('Content-Type', 'application/json');
             req.setBody(getReceivingHistJson(po, newReceivingHistList));
             req.setTimeout(100000);
             Http http = new Http();
             HTTPResponse res = http.send(req);
             Integer statusCode = res.getStatusCode();
             System.debug('Mulesoft response:'+res.getBody());
             result = res.getBody();
             if (statusCode != 200)
                throw new IDPWebServiceException ('Mulesoft - ' + res.getBody());
        } catch (Exception e) {
            throw new IDPWebServiceException (e.getMessage());
        }

        return result;

        

        return '';
    }

    public static String getReceivingHistJson(Purchase_Order__c po, List<Receiving_History__c> receivingHistList) {

        Map<String, Object> finalMap = new Map<String, Object>();
        List<Map<String, Object>> jsonList = new List<Map<String, Object>>();
        DateTime TransDate = System.today();
        for (Receiving_History__c rh : receivingHistList) {
            Map<String, Object> m = new Map<String, Object>();
            m.put('M3_PO_No__c', po.M3_PO_No__c);
            m.put('Number__c', rh.Purchase_Order_Item__r.Number__c);
            m.put('Received_Quantity__c', rh.Quantity__c);
            m.put('TransDate__c', TransDate.format('M/dd/yyyy'));

            jsonList.add(m);
        }

        finalMap.put('Receipts',jsonList);

        return JSON.serialize(finalMap);        
    }
*/

    //@future(callout=true)
    //public static void sendRequestToMuleWithFuture(String poId) {

    //  Purchase_Order__c po = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Estimated_Total_Price__c, Est_Tot_Price_Incl_Tax_Ship__c, Applicant__c, Submitted_Date__c, Supplier__c, Status__c, Delivery_Site__c, Currency__c, Shipping_Address__c, Tech_PO_Num_To_M3__c, Delivery_To__c, Delivery_Date__c, PO_Item_Count__c, Original_Total_Shipping_Cost__c, Original_Total_Tax__c, Total_Tax__c, Total_Shipping_Cost__c, Number_of_Draft__c, Number_of_Ordered__c, Number_of_Delivered__c, Number_of_Partial_Delivered__c, Number_of_Closed__c, Number_of_Cancelled__c, Delivery_Method__c, Payment_Method__c, Payment_Terms__c, Tech_PO_Item_Total_Unit_Price__c, Delivery_Terms__c, M3_PO_NO__c, Is_All_Delivered__c, Payment_Remark__c, Total_Other_Cost__c, Original_Total_Other_Cost__c, Original_Total_Amount__c FROM Purchase_Order__c WHERE Id = :poId LIMIT 1];
    //  String webServiceResult = sendRequestToMule(po);
    ////    system.debug('future webServiceResult:'+webServiceResult);
    //}
    //
    



    public class IDPWebServiceException extends Exception {}

}