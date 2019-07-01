public with sharing class IDPCreatePurchaseOrderSearchClass {

    public static String SEPARATOR = ',';
    public static String REPLACE = '[^a-zA-Z0-9_,-]';
    public static final string PO_PICKLIST_DATE_REPLACE = '@DATE';
    public static final string PO_PICKLIST_PO_RECORD_REPLACE = '@RECORDNAME';
    public static final string PO_PICKLIST_PRI_NUMBER_REPLACE = '@NUMBER';

    public Map<String, Purchase_Request_Item__c> getNotOrderedPurchaseRequestItemMap(String pSelectedDeliverySite, String pSelectedCostcenter, String pSelectedSupplier,  Date pSearchFromDate, Date pSearchToDate) {
        String sql = '';
        Map<String, Purchase_Request_Item__c> tempNotOrderedPurchaseRequestItemMap = new Map<String, Purchase_Request_Item__c> ();
        Map<id, Purchase_Request_item__c> priMap = new Map<id, Purchase_Request_item__c>();
        Map<id, id> QueuesMap = new Map<id, id>();
        Map<id, boolean> isCatOwnerMap = new Map<id, boolean>();
        Map<id, id> GPQueuesMap = new Map<id, id>();        
        List<Purchase_Request_item__c> PRList = null;
        List<String> pSelectedDeliverySiteList = null;
        if(!String.isBlank(pSelectedDeliverySite)){
            pSelectedDeliverySite = pSelectedDeliverySite.replaceAll(REPLACE,'');
            pSelectedDeliverySiteList = pSelectedDeliverySite.split(SEPARATOR);
        }
        sql += 'SELECT Id,  Purchase_Request__c, CreatedDate,';
        sql += 'Name, Purchase_Request__r.Name, Catalog_Item__r.Catalog__r.ownerid,';
        sql += 'Status__c,Catalog_Item__c, Catalog_Item__r.Description__c, Catalog_Item__r.Catalog__r.Display_Name__c,';
        sql += 'Catalog_Item_Name__c, Currency__r.Name,';
        sql += 'Currency__c, Price__c, Amount__c, ';
        sql += 'Quantity__c, Unit_of_Measure__c, Remark__c, ';
        sql += 'Local_Currency__c, Local_Exchange_Rate__c, Local_Amount__c,';
        sql += 'Standard_Currency__c, Standard_Exchange_Rate__c, Standard_Amount__c,';
        sql += 'Supplier__c, Supplier__r.Name, Supplier__r.Currency__c,';
        sql += 'Supplier__r.Delivery_Method__c, Supplier__r.Delivery_Terms__c, Supplier__r.Payment_Method__c, Supplier__r.Payment_Terms__c,';
        sql += 'Purchase_Request__r.Delivery_Site__c, Purchase_Request__r.Delivery_Site__r.Name,';
        sql += 'Purchase_Request__r.Delivery_Site__r.address_1__c, Purchase_Request__r.Delivery_Site__r.address_2__c,';
        sql += 'Purchase_Request__r.Delivery_Site__r.address_3__c, Purchase_Request__r.Delivery_Site__r.address_4__c,';
        sql += 'Purchase_Request__r.Delivery_To__c, Purchase_Request__r.Assign_to_Local_Purchaser__c,';
        sql += 'Purchase_Request__r.Tech_Applicant_Site_Id__c, Purchase_Request__r.Tech_Applicant_Site_Name__c,';
        sql += 'Purchase_Request__r.On_Behalf_Of__r.Name, Purchase_Request__r.Catalog__r.Display_Name__c,Purchase_Request__r.IDP_Policy__r.Name,';
        sql += 'Is_Direct_fulfillment__c, Purchase_Request__r.Need_By_Date__c,';
        sql += 'Tax_Standard_Total_Amount__c, Shipping_Cost_Standard_Total_Amount__c, Other_Cost_Standard_Total_Amount__c,';
        sql += 'Tax_Original_Total_Amount__c , Shipping_Cost_Original_Total_Amount__c, Other_Cost_Original_Total_Amount__c,Purchase_Request__r.Cost_Center__c,';
        sql += 'Purchase_Request__r.GL_Account__c ';
        sql += 'FROM Purchase_Request_Item__c ';
        sql += 'WHERE Status__c = \'' +IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED +'\' ';
        sql += 'AND Is_Direct_fulfillment__c = false '; 
        sql += 'AND Purchase_Order_Item__c = null ';
        sql += 'AND Supplier__c != null ';
        sql += 'AND Supplier__r.Name != null ';
        sql += 'AND Purchase_Request__r.Tech_Applicant_Site_Id__c != null ';
        sql += 'AND Purchase_Request__r.Tech_Applicant_Site_Name__c != null ';
        
        if(pSearchFromDate != null){
            sql += 'AND Purchase_Request__r.Need_By_Date__c >= :pSearchFromDate ';
        }
        if(pSearchToDate != null){
            sql += 'AND Purchase_Request__r.Need_By_Date__c <= :pSearchToDate ';
        }
        if(!String.isBlank(pSelectedDeliverySite)){
            sql += 'AND Purchase_Request__r.Tech_Applicant_Site_Id__c in : pSelectedDeliverySiteList ';
        }
        if(!String.isBlank(pSelectedCostcenter)){
            sql += 'AND Purchase_Request__r.Cost_Center__c = :pSelectedCostcenter ';
        }
        if(!String.isBlank(pSelectedSupplier)){
            sql += 'AND Supplier__c = :pSelectedSupplier ';
        }
        sql += 'ORDER BY Purchase_Request__r.Name ASC, Name ASC ';
        System.debug('*****SQL :'+sql);
        System.debug('*****pSearchFromDate :'+pSearchFromDate );
        System.debug('*****pSearchToDate :'+pSearchToDate);
        System.debug('*****pSelectedDeliverySite :'+pSelectedDeliverySite);
        System.debug('*****pSelectedDeliverySiteList :'+pSelectedDeliverySiteList );
        System.debug('*****pSelectedCostcenter :'+pSelectedCostcenter);
        System.debug('*****pSelectedSupplier :'+pSelectedSupplier);
        PRList= Database.query(sql);
        System.debug('*****PRList :'+PRList);
        for(Purchase_Request_item__c reader : PRList){
            if(reader.Purchase_Request__r.Assign_to_Local_Purchaser__c){
               if(new IDPPurchaseOrderInitCtrl().getIsPurchaser(reader.Purchase_Request__r.IDP_Policy__r.Name)){
                   tempNotOrderedPurchaseRequestItemMap.put(reader.Id, reader);
               }
           }
           else{
               priMap.put(reader.Id, reader);
               QueuesMap.put(reader.Id, reader.Catalog_Item__r.Catalog__r.ownerid);
               isCatOwnerMap.put(reader.Catalog_Item__r.Catalog__r.ownerid, false);
           }
        }
        for(GroupMember gm :[SELECT GroupId, UserOrGroupId FROM GroupMember where GroupId in :QueuesMap.values()]){
            GPQueuesMap.put(gm.UserOrGroupId, gm.GroupId);
        }
        for(GroupMember gm :[SELECT GroupId , UserOrGroupId FROM GroupMember where GroupId in :GPQueuesMap.keySet()]){
            if(gm.UserOrGroupId == UserInfo.getUserId()){                    
                isCatOwnerMap.put(GPQueuesMap.get(gm.groupID), true);
            }
        }
        for(Purchase_Request_item__c pri : priMap.values()){
            if(isCatOwnerMap.get(pri.Catalog_Item__r.Catalog__r.ownerid)){
                tempNotOrderedPurchaseRequestItemMap.put(pri.Id, pri);
            }
        }
        System.debug('*****tempNotOrderedPurchaseRequestItemMap :'+tempNotOrderedPurchaseRequestItemMap);
        return tempNotOrderedPurchaseRequestItemMap;
    }
    public Map<String, Purchase_Request_Item__c> getNotOrderedPurchaseRequestItemMap(String pSelectedDeliverySite, String pSelectedCatalog,String pSelectedCostcenter, String pSelectedSupplier,  Date pSearchFromDate, Date pSearchToDate) {
        Map<String, Purchase_Request_Item__c> tempNotOrderedPurchaseRequestItemMap = getNotOrderedPurchaseRequestItemMap(pSelectedDeliverySite, pSelectedCostcenter, pSelectedSupplier, pSearchFromDate, pSearchToDate);
        return tempNotOrderedPurchaseRequestItemMap;
    }  

    public List<SelectOption> updateDraftPurchaseOrderSelectOptionListAction(String pSelectedDeliverySite, String pSelectedSupplier) {

        List<SelectOption> tempDraftPurchaseOrderSelectOptionList = new List<SelectOption> ();

        pSelectedDeliverySite = pSelectedDeliverySite.replaceAll(REPLACE,'');
        List<String> pSelectedDeliverySiteList = pSelectedDeliverySite.split(SEPARATOR);
        for (Purchase_Order__c reader : [SELECT Id, Name, Supplier__c, Delivery_Site__c, Status__c, CreatedDate, PO_Item_Count__c
                                        FROM Purchase_Order__c 
                                        WHERE Status__c = : IDPConstant.PURCHASE_ORDER_STATUS_DRAFT 
                                        //AND Delivery_Site__c in :pSelectedDeliverySiteList //Removed because PO can delivery to a complete different site
                                        AND Supplier__c = :pSelectedSupplier
                                        AND CreatedById = :UserInfo.getUserId()
                                        ORDER BY Name]) {
                //tempDraftPurchaseOrderSelectOptionList.add(new SelectOption(reader.Id, reader.Name));
                
                String displayFormat = Label.IDP_Shopping_Cart_PR_Picklist_Format;
                DateTime displayCreatedDate = DateTime.newInstance(reader.createdDate.year(), reader.createdDate.month(), reader.createdDate.day(), 0, 0, 0);

                displayFormat = displayFormat.replace(PO_PICKLIST_DATE_REPLACE, String.valueOf(displayCreatedDate.format('dd/MM/yyyy')));
                displayFormat = displayFormat.replace(PO_PICKLIST_PO_RECORD_REPLACE, reader.Name);
                displayFormat = displayFormat.replace(PO_PICKLIST_PRI_NUMBER_REPLACE , String.valueOf(reader.PO_Item_Count__c));
                
                tempDraftPurchaseOrderSelectOptionList.add(new SelectOption(reader.Id, displayFormat));
            }
            return tempDraftPurchaseOrderSelectOptionList;
    }      

    public List<SelectOption> getDeliverySiteSelectOptionList() {
        List<SelectOption> tempDeliverySiteSelectOptionList = new List<SelectOption> ();
        Map <String, Purchase_Request_item__c> priMap = getNotOrderedPurchaseRequestItemMap(null, null, null, null, null);
        Map <String, String> SiteMap = new Map <String, String>();
        List <String> siteList = new List<String>();
        for(Purchase_Request_item__c pri : priMap.values()){
            SiteMap.put(pri.Purchase_Request__r.Tech_Applicant_Site_Id__c, pri.Purchase_Request__r.Tech_Applicant_Site_Name__c);
        }
        for(String site : SiteMap.keySet()){
            tempDeliverySiteSelectOptionList.add(new SelectOption(site, SiteMap.get(site)));
        }
        return tempDeliverySiteSelectOptionList;
    }
    
    public List<SelectOption> updateSupplierSelectOptionListAction(String pSelectedDeliverySite) {
        
        Map <String, Purchase_Request_item__c> priMap = getNotOrderedPurchaseRequestItemMap(pSelectedDeliverySite, null, null, null, null);
        Map <String, String> SupplierMap = new Map <String, String>();
        List <SelectOption> tempSupplierSelectOptionList = new List<SelectOption> ();
        List <String> supplierList = new List<String>();
        for(Purchase_Request_item__c pri : priMap.values()){
            SupplierMap.put(pri.supplier__r.Name + '_' +pri.supplier__c, pri.supplier__r.Name);
        }
        if(!SupplierMap.isEmpty()){
            supplierList.addAll(SupplierMap.keySet());
            supplierList.sort();
        }
        for(String supplier : supplierList){
            tempSupplierSelectOptionList.add(new SelectOption(supplier.split('_')[1], SupplierMap.get(supplier)));
        }
        return tempSupplierSelectOptionList ;        
    }
    
    public List<SelectOption> updateCostCenterSelectOptionListAction(String pSelectedDeliverySite , String pSelectedSupplier) {
        Map <String, Purchase_Request_item__c> priMap = getNotOrderedPurchaseRequestItemMap(pSelectedDeliverySite, null, pSelectedSupplier, null, null);
        List<SelectOption> tempCostCenterSelectOptionList = new List<SelectOption> ();
        List <String> costCenterList = new List<String>();
        for(Purchase_Request_item__c pri : priMap.values()){
            if(!costCenterList.contains(pri.Purchase_Request__r.Cost_Center__c)){
                costCenterList.add(pri.Purchase_Request__r.Cost_Center__c);
            }
        }
        costCenterList.sort();
        for(String cc: costCenterList){
            tempCostCenterSelectOptionList.add(new SelectOption(cc, cc));
        }
        return tempCostCenterSelectOptionList;
    }
}