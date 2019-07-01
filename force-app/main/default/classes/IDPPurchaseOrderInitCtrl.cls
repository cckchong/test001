public without sharing class IDPPurchaseOrderInitCtrl{

    private String PROCUREMENT_GROUP_POLICY = '@policy';
    private String CATALOG_GROUP_NAME = '@name';
    private String selectedCurrency;
    private Employee__c emp;
    private Budget__c budget;
    private Map<Id, Employee_Administrator__c> employeeAdminRecords;
    private Map<Id, List<Supplier_Item__c>> SupplierItemMap;
    private Map<Id, Supplier__c> supplierMap;
    private Map<String, Map<String, Supplier_Item__c>> catalogItemSupplierSourceMap;
    
    private Map<id, Map<id, double>> supplierCost;
    private Map<Id, List<Purchase_Cost__c>> priIdPCListMap;
    private List <ID> CatalogItemIdList;
    private List <selectOption> applicantOptList;
    private List <selectOption> costItemOptList;
    
    private List <selectOption> currencyList;
    
    private double withheldAmount;
    
    //active
    private IDPPurchaseOrderCtrl poCtrl;
    private Purchase_Order__c po;
    //private Date EariestDeliDate;
    private Purchase_Order_Item__c poi;
    private String pid;
    private Map<Id, Site__c> siteMap;
    private List <selectOption> currencyOptList;
    private List <selectOption> deliverySiteOptList;    
    private List <selectOption> deliveryMethodOptList;
    private List <selectOption> deliveryTermsOptList;
    private List <selectOption> paymentMethodOptList;    
    private List <selectOption> paymentTermsOptList; 
    
    Public IDPPurchaseOrderInitCtrl()
    {
     //This function is used for invoking by another function located in another class
     //add by Eric
    }
    Public IDPPurchaseOrderInitCtrl(IDPPurchaseOrderCtrl poCtrl, String pid){
    /*
        prCtrl.priIdPCListMap = this.priIdPCListMap;
        prCtrl.emp = this.emp;
        prCtrl.applicantOptList = this.applicantOptList;
        prCtrl.currencyOptList = this.currencyOptList; 
        prCtrl.supplierMap = this.supplierMap;
        
        prCtrl.costItemOptList = this.costItemOptList;
        
        prCtrl.supplierCost = this.supplierCost;
        prCtrl.budget= this.budget;
        if(prCtrl.pr.On_Behalf_of__r.Employee__r.user__c == UserInfo.getUserId() || prCtrl.po.On_Behalf_of__r.Employee_Administrator__r.user__c == UserInfo.getUserId()){
            prCtrl.isMyself = true;
        }
        if(prCtrl.pr.Tech_C_Level_Approver__c == UserInfo.getUserId() || prCtrl.po.Tech_ROI_Approver__c == UserInfo.getUserId() || 
           prCtrl.pr.Actual_Approver_1__c == UserInfo.getUserId() || prCtrl.pr.Actual_Approver_2__c == UserInfo.getUserId() ||
           prCtrl.pr.Actual_Approver_3__c == UserInfo.getUserId() || prCtrl.pr.Actual_Approver_4__c == UserInfo.getUserId()
          ){
            prCtrl.isApprover = true;
        }
        prCtrl.isPurchaser = getIsPurchaser(prCtrl.po.Tech_IDP_Policy_Name__c);
        prCtrl.isCatalogOwner = getIsCatalogOwner(prCtrl.po.Tech_Catalog_Owner_Queue_Name__c);
        //prCtrl.isCurrentApprover = getisCurrentApprover();
        prCtrl.SupplierItemMap = this.SupplierItemMap;
        prCtrl.withheldAmount= this.withheldAmount;        
        this.prCtrl = prCtrl;
        chagneCurrency();
        */
        
        
        // active
        
        
        this.pid = pid;
        setupInitSetting();
        poCtrl.siteMap = this.siteMap;
        poCtrl.currencyList = this.currencyList;
        poCtrl.deliverySiteOptList = this.deliverySiteOptList;
        poCtrl.deliveryMethodOptList= this.deliveryMethodOptList;
        poCtrl.deliveryTermsOptList= this.deliveryTermsOptList;
        poCtrl.paymentMethodOptList= this.paymentMethodOptList;
        poCtrl.paymentTermsOptList= this.paymentTermsOptList;
        
        poCtrl.isbeingShared = getIsbeingShared();
        poCtrl.po = this.po;
        //poCtrl.EariestDeliDate = this.EariestDeliDate;
        poCtrl.selectedCurrency = this.selectedCurrency;
        poCtrl.catalogItemSupplierSourceMap = this.catalogItemSupplierSourceMap;
        this.poCtrl= poCtrl;
        system.debug(po);
    }
    
    Public void setupInitSetting(){
        this.po = getPO(pid);
        //this.EariestDeliDate = getEariestDeliDate(pid);
        this.siteMap = getSiteMap();
        this.currencyList = getAllCurrency();
        this.deliverySiteOptList = getShippingSite();
        this.deliveryMethodOptList = getAllDeliveryMethod();
        this.deliveryTermsOptList = getAllDeliveryTerms();

        this.paymentMethodOptList = getAllPaymentMethod();
        this.paymentTermsOptList = getAllPaymentTerms();

        CatalogItemIdList = new List <ID>();
        for(Purchase_Order_Item__c reader : this.po.Purchase_Order_Items__r){
            CatalogItemIdList.add(reader.Catalog_Item__c);
        }
        this.catalogItemSupplierSourceMap = getCatalogItemSupplierSourceMap(CatalogItemIdList);
        
        if(this.po != null) {
            this.selectedCurrency = this.po.Currency__c;
        }
    }
    
    public Purchase_Order__c getPO(String pid){
            Purchase_Order__c po;
            for(Purchase_Order__c reader : [select id, Applicant__c, Name, CreatedBy.Name,Currency__c,Delivery_To__c, Department_Info__c,
                                            Delivery_Site__c,Estimated_Total_Price__c,Status__c,Submitted_Date__c, M3_PO_No__c,
                                            Supplier__c,Tech_PO_Num_To_M3__c,Supplier__r.name,Supplier__r.Tax__c,Currency__r.name,Delivery_Date__c,
                                            Total_Tax__c, Total_Shipping_Cost__c, Total_Other_Cost__c, Original_Total_Amount__c, Original_Total_Tax__c, Original_Total_Shipping_Cost__c, Original_Total_Other_Cost__c,
                                            Delivery_Site__r.Tolerance_Level__c, Delivery_Site__r.Name, Supplier__r.Supplier_Code__c,
                                            Delivery_Terms__c, Delivery_Method__c, Payment_Method__c, Payment_Terms__c, Payment_Remark__c, Est_Tot_Price_Incl_Tax_Ship__c, 
                                            Delivery_Site__r.Warehouse__c, Delivery_Site__r.country_code__c , Applicant__r.User__r.sAMAccountName__c, Supplier__r.Media_Profile__c,  cost_center__c, GL_Account__c,
                                            Shipping_Address_1__c, Shipping_Address_2__c, Shipping_Address_3__c, Shipping_Address_4__c,Total_Charge__c,
                                            (select id, name, currency__c,Currency__r.name, Price__c,Quantity__c,Unit_of_Measure__c, Tech_Price__c, Number__c,
                                            Item_Description__c,Status__c,Received_Quantity__c,Subtotal__c,Buyer_Remark__c,
                                            Catalog_Item__r.item_name__c,Delivery_Date__c,Tech_PRI_Create_Date__c,Delivery_Address__c,
                                            Purchase_Order__c,Supplier__c, createdDate,
                                            Tech_PO_Currency_PRI_Amount__c, Tech_PO_Currency_PRI_Shipping__c, Tech_PO_Currency_PRI_Tax__c, Tech_PO_Currency_PRI_Other_Cost__c,
                                            Catalog_Item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c, 
                                            Catalog_Item__r.Catalog__r.Catalog_Name__c,
                                            Catalog_Item__r.Catalog__r.Catalog_Code__c, Catalog_Item__r.Catalog__r.M3_Catalog_Code__c,
                                            cost_center__c, GL_Account__c,
                                            M3_PO_NO__c,  Catalog__c, Catalog_item__r.Description__c,
                                            Supplier__r.Supplier_Code__c, Budget_Exchange_Rate__c, additional_cost__c
                                            from Purchase_Order_Items__r
                                            ORDER BY Number__c ASC, Name ASC)
                                            from Purchase_Order__c  where id = :pid])
                                               
            po = reader;
            return po;
    }
    
    private List<selectOption> getAllCurrency(){
        List <selectOption> currencyOpt = new List <selectOption>();
        for(currency__c reader : [select id, Name from currency__c order by Name]){
            currencyOpt.add(new selectOption(reader.id, reader.Name));   
        }
        return currencyOpt;
    }
    
    private List<selectOption> getAllDeliveryMethod(){
        List <selectOption> options = new List <selectOption>();
        Schema.DescribeFieldResult result = Purchase_Order__c.Delivery_Method__c.getDescribe();
        List<Schema.PicklistEntry> picklist = result.getPicklistValues();
        
        for(Schema.PicklistEntry reader : picklist) {
            options.add(new selectOption(reader .getValue(), reader.getLabel()));
        }
        return options;
    }    

    private List<selectOption> getAllDeliveryTerms(){
        List <selectOption> options = new List <selectOption>();
        Schema.DescribeFieldResult result = Purchase_Order__c.Delivery_Terms__c.getDescribe();
        List<Schema.PicklistEntry> picklist = result.getPicklistValues();
        
        for(Schema.PicklistEntry reader : picklist) {
            options.add(new selectOption(reader .getValue(), reader.getLabel()));
        }
        return options;
    }    
    
    private List<selectOption> getAllPaymentMethod(){
        List <selectOption> options = new List <selectOption>();
        Schema.DescribeFieldResult result = Purchase_Order__c.Payment_Method__c.getDescribe();
        List<Schema.PicklistEntry> picklist = result.getPicklistValues();
        
        for(Schema.PicklistEntry reader : picklist) {
            options.add(new selectOption(reader .getValue(), reader.getLabel()));
        }
        return options;
    }
    
    private List<selectOption> getAllPaymentTerms(){
        List <selectOption> options = new List <selectOption>();
        Schema.DescribeFieldResult result = Purchase_Order__c.Payment_Terms__c.getDescribe();
        List<Schema.PicklistEntry> picklist = result.getPicklistValues();
        
        for(Schema.PicklistEntry reader : picklist) {
            options.add(new selectOption(reader .getValue(), reader.getLabel()));
        }
        return options;
    }   
    
    public Boolean getIsPurchaser(String policyName){
        Boolean isPurchaser = false;
        String procurmentQueue = IDPConstant.PROCUREMENT_QUEUE;
        List <String> userGroupList = new List <String>();
        if(String.isBlank(policyName)){
            return isPurchaser;
        }                             //changed by Eric
        procurmentQueue = procurmentQueue.replace(PROCUREMENT_GROUP_POLICY, policyName);
        for(GroupMember reader :[select id, UserOrGroupId from GroupMember 
                                 where GroupId in (select id from Group where DeveloperName = :procurmentQueue and type = 'Queue')
                                ]){
            userGroupList.add(reader.UserOrGroupId);
        }
        for(GroupMember reader :[select id, UserOrGroupId from GroupMember 
                                 where GroupId in :userGroupList and UserOrGroupId = :UserInfo.getUserId()
                                 limit 1
                                ]){
            isPurchaser = true;
        }
        
        return isPurchaser;
    }
    
    Private Boolean getIsbeingShared(){

        Set<ID> poShareQueueSet = new Set<ID>();
        List<Purchase_Order__Share> poSharingList = [SELECT Id,AccessLevel, RowCause, UserOrGroupId FROM Purchase_Order__Share where parentId =:pid and AccessLevel = 'Edit'];
        
        if(poSharingList.size()>0){
            for(Purchase_Order__Share poSharing:poSharingList){
                poShareQueueSet.add(poSharing.UserOrGroupId);
            }
        }
       
        List<Group> sharedGroupList = new List<Group>();
        Set<ID> poShareGroupSet = new Set<ID>();
        if(poSharingList.size()>0){
            sharedGroupList = [Select Id,name from Group where type = 'Queue' and id in:poShareQueueSet];
                if(sharedGroupList.size()>0){
                    for(Group sharedGroup:sharedGroupList){
                        poShareGroupSet.add(sharedGroup.id);
                    }
            }
        } 
        
        List<GroupMember> groupMemberList = [select id,UserorGroupId from GroupMember where GroupId in:poShareGroupSet];
        Set<ID> poShareUserSet = new Set<ID>();
        
        if(groupMemberList.size()>0){
            for(GroupMember groupMember:groupMemberList){
                poShareUserSet.add(groupMember.UserorGroupId);
            }
        }
        List<GroupMember> memberList = [select id,UserorGroupId from GroupMember where groupId in: poShareUserSet];
        
        Boolean Display = false;
        if(memberList.size()>0){
            for(GroupMember groupMember:memberList){
                if(groupMember.UserorGroupId == UserInfo.getUserId()){
                    return true;
                }
                Display = false;
            }
        }
        return Display ;
    }
    
     private Map<Id, Site__c> getSiteMap(){
        Map<id, Site__c> tmp = new Map<id, Site__c>([select id, Name, Address_1__c, Address_2__c, Address_3__c, Address_4__c from Site__c order by Name]);
        return tmp;
    }
    
    private List<selectOption> getShippingSite(){
        List <selectOption> siteOpt = new List <selectOption>();
        for(Site__c reader : siteMap.values()){
            siteOpt.add(new selectOption(reader.id, reader.Name));   
        }
        return siteOpt;
    }

    public Map<String, Map<String, Supplier_Item__c>> getCatalogItemSupplierSourceMap(List<String> catalogItemList) {
        // Map<CatalogItemId, Map<SupplierId, Supplier_Item__c>>
        Map<String, Map<String, Supplier_Item__c>> supplierItemMap = new Map<String, Map<String, Supplier_Item__c>>();

        for (String ci : catalogItemList) {
            Map<String, Supplier_Item__c> siMap = new Map<String, Supplier_Item__c>();

            for (Supplier_Item__c si : [SELECT Supplier__c, Id, Name, Catalog_Item__c, Minimum_Order_Quantity__c, Currency__c, Price__c, Expiry_Date__c, toLabel(Lead_Time_Format__c), Lead_Time_Days__c 
                                        FROM Supplier_Item__c
                                        WHERE Catalog_Item__c = :ci
                                        AND (Expiry_Date__c = null or Expiry_Date__c >= Today)
                                        ORDER BY Expiry_Date__c NULLS LAST]) {

                siMap.put(si.Supplier__c, si);
            }

            supplierItemMap.put(ci, siMap);
        }

        return supplierItemMap;
    }
    
    public Exchange_rate__c getCurrentBudgetEx(ID POcurrencyID){
        Exchange_rate__c er = null;
        for(Exchange_rate__c reader :[select id, Rate__c  from 
                                      Exchange_rate__c 
                                      where From_Currency__c = :POcurrencyID
                                      and Is_Book_Rate__c = true
                                      and Is_Latest__c = true
                                      and To_Currency__r.Is_IDP_Budget_Currency__c = true
                                      limit 1
                                     ]){
            er = reader;
        }
        return er;
    }
    
    
    /*
    public Date getEariestDeliDate(String pid){
            Purchase_Order__c po;
            po = getPO(pid);
            Date EariestDeliDate = null;
            for(Purchase_Order_Item__c reader : po.Purchase_Order_Items__r){
                                  
                 if(EariestDeliDate > reader.Delivery_Date__c && EariestDeliDate != null){
                     EariestDeliDate = reader.Delivery_Date__c;
                 }    
                 if(EariestDeliDate == null){
                     EariestDeliDate = reader.Delivery_Date__c;
                 }
            }   
            return EariestDeliDate;           
    }
    */

    /*
    Public Boolean getIsCatalogOwner(String catalogQueueName){
     
        return null;
    }
    
    Public Boolean getIsPurchaser(String policyName){

        
        return null;
    }
    
    Public Map<Id, Employee_Administrator__c> getEmployeeAdminRecord(Id adminId){


        return null;
    }
    
    Public Employee__c getEmployeeRecord(Id empid){


        return null;
    }
    
    Public Budget__c getBudget(String catId){



        return null;
    }
    
    Public Double getWithheldAmount(){


        return null;
    }
    

    public Map<Id, List<Purchase_Cost__c>> getPRIPCListMap (String pid) {


        return null;
    }
            
    public List<SelectOption> getCostItem()
    {


        return null;
    }
    
    
    Public void chagneCurrency(){


    }
    
    private Map<id, Map<id, double>> getSupplierCost(List<Purchase_Request_Item__c> priList){


        return null;
    }
    
    private Map<Id, List<Supplier_Item__c>> getSupplierItem(List<String> itemIdList){


        return null;
    }
    
    private Map<id, Supplier__c> getsupplierMap(){
    

        return null;
    }

   */
}