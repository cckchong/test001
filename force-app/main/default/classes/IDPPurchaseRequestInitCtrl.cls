public without sharing class IDPPurchaseRequestInitCtrl{

    private String PROCUREMENT_GROUP_POLICY = '@policy';
    private String CATALOG_GROUP_NAME = '@name';
    private Purchase_Request__c pr;
    private Employee__c emp;
    //private Budget__c budget;
    private IDP_Budget__c IDPbudget;
    private Map<Id, Employee_Administrator__c> employeeAdminRecords;
    private Map<Id, List<Supplier_Item__c>> SupplierItemMap;
    private Map<String, Map<String, Supplier_Item__c>> catalogItemSupplierSourceMap;
    private Map<Id, Supplier__c> supplierMap;
    private Map<Id, Currency__c> currencyMap;
    private Map<Id, Site__c> siteMap;
    private Map<String, Map<String, double>> supplierCost;
    private Map<String, Map<String, double>> supplierTaxShipOtherCost;
    private Map<Id, List<Purchase_Cost__c>> priIdPCListMap;
    private Map<String, Set<String>> last3OrderedSupplierMap;
    private Map<String,Exchange_Rate__c> exRateMap;
    private List <ID> CatalogItemIdList;
    private List <User> userList;
    private List <selectOption> applicantOptList;
    private List <selectOption> costItemOptList;
    private List <selectOption> currencyOptList;
    private List <selectOption> deliverySiteOptList;    
    private List <selectOption> currencyList;
    Public List <SelectOption> userSelectionList;
    Public List <SelectOption> userSelectionList1;
    Public List <SelectOption> userSelectionList2;
    Public List <SelectOption> userSelectionList3;
    Public List <SelectOption> userSelectionList4;
    Public List <SelectOption> userSelectionList5;
    Public List <SelectOption> userSelectionList6;
    Public List <SelectOption> userSelectionList7;
    Public List <SelectOption> userSelectionList8;
    Public List <SelectOption> userSelectionList9;   
    
    private IDPPurchaseRequestCtrl prCtrl;
    //private double withheldAmount;
    private String pid;
    
    Public IDPPurchaseRequestInitCtrl(IDPPurchaseRequestCtrl prCtrl, String pid){
        this.pid = pid;
        setupInitSetting();
        prCtrl.pr = this.pr;
        prCtrl.priIdPCListMap = this.priIdPCListMap;
        prCtrl.emp = this.emp;
        prCtrl.applicantOptList = this.applicantOptList;
        prCtrl.currencyOptList = this.currencyOptList; 
        prCtrl.currencyList = this.currencyList;
        prCtrl.userList = this.userList;
        prCtrl.userSelectionList = this.userSelectionList;
        prCtrl.userSelectionList1 = this.userSelectionList1;
        prCtrl.userSelectionList2 = this.userSelectionList2;
        prCtrl.userSelectionList3 = this.userSelectionList3;
        prCtrl.userSelectionList4 = this.userSelectionList4;
        prCtrl.userSelectionList5 = this.userSelectionList5;
        prCtrl.userSelectionList6 = this.userSelectionList6;
        prCtrl.userSelectionList7 = this.userSelectionList7;
        prCtrl.userSelectionList8 = this.userSelectionList8;
        prCtrl.userSelectionList9 = this.userSelectionList9;
        prCtrl.supplierMap = this.supplierMap;
        prCtrl.currencyMap = this.currencyMap;
        prCtrl.siteMap = this.siteMap;
        prCtrl.exRateMap = this.exRateMap;
        prCtrl.employeeAdminRecords = this.employeeAdminRecords;
        prCtrl.costItemOptList = this.costItemOptList;
        prCtrl.deliverySiteOptList = this.deliverySiteOptList;
        prCtrl.supplierCost = this.supplierCost;
        prCtrl.supplierTaxShipOtherCost = this.supplierTaxShipOtherCost;
        prCtrl.last3OrderedSupplierMap = this.last3OrderedSupplierMap;
        //prCtrl.budget = this.budget;
        prCtrl.IDPbudget = this.IDPbudget;
        prCtrl.displayedBudget = new IDPPurchaseRequestCtrl.DisplayBudget(prCtrl.IDPbudget);
        if(prCtrl.pr.On_Behalf_of__r.Employee__r.user__c == UserInfo.getUserId() || prCtrl.pr.On_Behalf_of__r.Employee_Administrator__r.user__c == UserInfo.getUserId()){
            prCtrl.isMyself = true;
        }
        if(prCtrl.pr.Tech_C_Level_Approver__c == UserInfo.getUserId() || prCtrl.pr.Tech_ROI_Approver__c == UserInfo.getUserId() || 
           prCtrl.pr.Actual_Approver_1__c == UserInfo.getUserId() || prCtrl.pr.Actual_Approver_2__c == UserInfo.getUserId() ||
           prCtrl.pr.Actual_Approver_3__c == UserInfo.getUserId() || prCtrl.pr.Actual_Approver_4__c == UserInfo.getUserId()
          ){
            prCtrl.isApprover = true;
        }
        prCtrl.isCatalogOwner = getIsCatalogOwner(prCtrl.pr.Tech_Catalog_Owner_Queue_Name__c);
        prCtrl.isPurchaser = getIsPurchaser(prCtrl.pr.Tech_IDP_Policy_Name__c, prCtrl.isCatalogOwner);
        prCtrl.isCurrentApprover = getisCurrentApprover();
        prCtrl.SupplierItemMap = this.SupplierItemMap;
        prCtrl.catalogItemSupplierSourceMap = this.catalogItemSupplierSourceMap;
        //prCtrl.withheldAmount= this.withheldAmount;        
        this.prCtrl = prCtrl;
        chagneCurrency();


    }
    
    Public void setupInitSetting(){
        this.applicantOptList = new List <selectOption>();
        this.currencyOptList = new List <selectOption>();
        this.deliverySiteOptList= new List<selectOption>();
        this.userSelectionList = new List <SelectOption>();
        this.userSelectionList1 = new List <SelectOption>();
        this.userSelectionList2 = new List <SelectOption>();
        this.userSelectionList3 = new List <SelectOption>();
        this.userSelectionList4 = new List <SelectOption>();
        this.userSelectionList5 = new List <SelectOption>();
        this.userSelectionList6 = new List <SelectOption>();
        this.userSelectionList7 = new List <SelectOption>();
        this.userSelectionList8 = new List <SelectOption>();
        this.userSelectionList9 = new List <SelectOption>();                
        this.CatalogItemIdList = new List <ID>();
        this.userList = getUserList();
        getAllUserSelectionList();
        //this.supplierMap = getsupplierMap();
        this.currencyMap = getcurrencyMap();
        this.siteMap = getSiteMap();
        this.pr = getPR(pid);
        this.supplierMap = getsupplierMap(pr);
        this.priIdPCListMap = getPRIPCListMap(pid);
        this.emp = getEmployeeRecord(pr.On_Behalf_of__r.Employee__c);
        this.employeeAdminRecords = getEmployeeAdminRecord(pr.On_Behalf_of__r.Employee_Administrator__c);     
        for(Employee_Administrator__c reader : employeeAdminRecords.values()){
            applicantOptList.add(new selectOption(reader.id, reader.Name));
        }
        this.currencyOptList.add(new selectOption('o', 'Original'));
        this.currencyOptList.add(new selectOption('l', 'Local'));
        for(Purchase_Request_Item__c reader : this.pr.Purchase_Request_Items__r){
            CatalogItemIdList.add(reader.Catalog_Item__c);
        }
        this.SupplierItemMap = getSupplierItem(CatalogItemIdList);
        this.catalogItemSupplierSourceMap = getCatalogItemSupplierSourceMap(CatalogItemIdList);
        this.last3OrderedSupplierMap = getLast3OrderedSupplierMap(CatalogItemIdList);
        this.exRateMap = getCurrentExchangeRate();
        this.costItemOptList = getCostItem();
        this.deliverySiteOptList = getDeliverySite();
        this.currencyList = getAllCurrency();
        this.supplierCost = getSupplierCost(this.pr.Purchase_Request_Items__r);
        this.supplierTaxShipOtherCost = getSupplierTaxShipOtherCost(this.pr.Purchase_Request_Items__r);
        //this.budget = getBudget(this.pr.Catalog__c);
        
        if(this.pr.Status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_PENDING_PURCHASE_CONFIRMATION ||
            this.pr.Status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_PENDING_APPROVAL) {
            
                //this.budget = getBudget(this.pr.Catalog__r.Catalog_Name__c);
                
                //TO BE Done 
                this.IDPbudget = getBudget(this.pr.Catalog__c);
        }
        else {
        
            //TO BE Done 
            //this.IDPbudget
            this.IDPbudget = getBudgetById(this.pr.IDP_budget__c);
            //this.budget = getBudgetById(this.pr.budget__c);
        }
        //this.withheldAmount = this.budget.Withheld_Amount__c; //getWithheldAmount();
    }
    
    Public Boolean getisCurrentApprover(){
        List <String> userGroupList = new List <String>();
        String userGroupId = '';        
        for(ProcessInstanceWorkitem reader : [ select id, OriginalActorId
                                               from ProcessInstanceWorkitem 
                                               where ProcessInstance.TargetObjectId = :pid
                                             ]){
            userGroupId = reader.OriginalActorId;
        }
        if (userGroupId == UserInfo.getUserId()){
            return true;
        }
        for(GroupMember reader :[select id, UserOrGroupId from GroupMember 
                                 where GroupId = :userGroupId 
                                ]){
            userGroupList.add(reader.UserOrGroupId);
        }
        for(GroupMember reader :[select id, UserOrGroupId from GroupMember 
                                 where GroupId in :userGroupList and UserOrGroupId = :UserInfo.getUserId()
                                 limit 1
                                ]){
            return true;
        }
        return false;
    }
    
    Public Boolean getIsCatalogOwner(String catalogQueueName){
        Boolean isCatalogOwner = false;
        List <String> userGroupList = new List <String>();
        if(String.isBlank(catalogQueueName)){
            return isCatalogOwner ;
        }
        for(GroupMember reader :[select id, UserOrGroupId from GroupMember 
                                 where GroupId in (select id from Group where DeveloperName = :catalogQueueName and type = 'Queue')
                                ]){
            userGroupList.add(reader.UserOrGroupId);
        }
        for(GroupMember reader :[select id, UserOrGroupId from GroupMember 
                                 where GroupId in :userGroupList and UserOrGroupId = :UserInfo.getUserId()
                                 limit 1
                                ]){
            isCatalogOwner = true;
        }
        return isCatalogOwner ;
    }
    
    Public Boolean getIsPurchaser(String policyName, Boolean pIsCatalogOwner){
        Boolean isPurchaser = false;
        Boolean isGroupProcurement = false;
        String procurmentQueue = IDPConstant.PROCUREMENT_QUEUE;
        List <String> userGroupList = new List <String>();
        if(String.isBlank(policyName)){
            return isPurchaser;
        }
        
        for(IDP_Policy__c reader : [Select Id, Name, Is_Group_Procurement__c from IDP_Policy__c where Name =: policyName]) {
            isGroupProcurement = reader.Is_Group_Procurement__c;
            break;
        }
        if(isGroupProcurement) {
            isPurchaser = pIsCatalogOwner;    
        }
        else {       
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
        }
        return isPurchaser;
    }
    
    Public Map<Id, Employee_Administrator__c> getEmployeeAdminRecord(Id adminId){
        Map<Id, Employee_Administrator__c> eaMap = new Map<Id, Employee_Administrator__c>(
                                                   [select id, Name, Employee__c
                                                    from Employee_Administrator__c
                                                    where Employee_Administrator__c = :adminId
                                                    AND Application__c INCLUDES ('IDP')
                                                   ]);
        return eaMap;
    }
    
    Public Employee__c getEmployeeRecord(Id empid){
        Employee__c emp = null;
        for(Employee__c reader : [select id, expense_policy__r.local_currency__c,
                                  expense_policy__r.local_currency__r.Name,
                                  Function__c, Department__c, Section__c, 
                                  Site__c, Site__r.Name
                                  from Employee__c 
                                  where id = :empid] ){
            emp = reader;
        }
        return emp;
    }
 
    //Public Budget__c getBudget(String catId){
   Public IDP_Budget__c getBudget(String catId){
        //String PolicyFunctionDepartment = '';
        //String PolicyFunctionDepartmentSection = '';
        Map<String, IDP_Budget__c> IDPBudgetMap= new Map<String, IDP_Budget__c> ();
        Set <String> targetBudgetKey = new Set <String>();
        String siteID = '';
        String catalogID = '';
        String function = '';
        String department = '';
        String section = '';
        String siteFunctionDepartmentSectionCatalogYear = '';
        String siteFunctionDepartmentCatalogYear = '';
        String siteFunctionDepartmentSectionYear = '';
        String siteFunctionDepartmentYear = '';
        String year = String.valueOf(System.Today().year());
        IDP_Budget__c IDPBudget = null;
        
        siteID = this.pr.On_Behalf_of__r.Employee__r.site__r.Site_ID_18__c;
        catalogID = catId;
        function = this.pr.On_Behalf_of__r.Employee__r.Function__c;
        department = this.pr.On_Behalf_of__r.Employee__r.Department__c;
        section = this.pr.On_Behalf_of__r.Employee__r.Section__c;
        siteFunctionDepartmentSectionCatalogYear = siteID +'_'+ function +'_'+ department +'_'+ section +'_'+ catalogID +'_'+ year;
        siteFunctionDepartmentCatalogYear = siteID +'_'+ function +'_'+ department +'_'+ catalogID +'_'+ year;
        siteFunctionDepartmentSectionYear = siteID +'_'+ function +'_'+ department +'_'+ section +'_'+ year;
        siteFunctionDepartmentYear = siteID +'_'+ function +'_'+ department +'_'+ year;
        targetBudgetKey.add(siteFunctionDepartmentSectionCatalogYear);
        targetBudgetKey.add(siteFunctionDepartmentCatalogYear);
        targetBudgetKey.add(siteFunctionDepartmentSectionYear);
        targetBudgetKey.add(siteFunctionDepartmentYear);
        
        for(IDP_Budget__c reader: [select id, Department_Code__c, Function_Code__c, Section_Code__c, Site__c, 
                                   Current_Month_Budget__c, Current_Month_Remaining_Budget__c, year__c,
                                   Current_Month_Reserve_Budget__c, Current_Month_Used_Budget__c, Catalog__c,
                                   Catalog__r.Name, Ext_ID__c , Catalog_Name__c, currency__c, currency__r.Name,Year_Budget__c,
                                   Year_Remaining_Budget__c,Year_Reserve_Budget__c,Year_Used_Budget__c, Current_Month_Pending_PR_Budget__c,
                                   Year_Pending_PR_Budget__c
                                   from IDP_Budget__c
                                   where Ext_ID__c in :targetBudgetKey
                                   ORDER BY Section_Code__c DESC NULLS LAST, Catalog__c DESC NULLS LAST 
                                  ]){
            if(IDPBudget == null){
                IDPBudget = reader;
            }
        }
        
        /*
        String PolicyFunctionDepartment = '';
        PolicyFunctionDepartment += this.pr.On_Behalf_of__r.Employee__r.site__r.Name + '_';
        PolicyFunctionDepartment += this.pr.On_Behalf_of__r.Employee__r.Function__c + '_';
        PolicyFunctionDepartment += this.pr.On_Behalf_of__r.Employee__r.Department__c;

        String PolicyFunctionDepartmentSection = PolicyFunctionDepartment;
        if(!String.isBlank(this.pr.On_Behalf_of__r.Employee__r.Section__c)){
            PolicyFunctionDepartmentSection += '_' + this.pr.On_Behalf_of__r.Employee__r.Section__c;
        }

        List<Expense_Category__c> ExpenseCatalogyId = new List<Expense_Category__c>([SELECT Id , Name,  Expense_Category_ID__c FROM Expense_Category__c WHERE Expense_Category_ID__c = : catName OR Expense_Category_ID__c = :IDPConstant.EXPENSE_CATEGORY_GENERAL]);
        
        system.debug('ExpenseCatalogyId:'+ExpenseCatalogyId);
        
        for(Budget__c budget :[select id, Remaining_Amount__c, Budget__c, Expense_Amount__c,
                               Department_Code__c, Function_Code__c, Section_Code__c, Site__c,Currency__c,Currency__r.name,
                               Year__c,Effective_Start_Date__c,Effective_End_Date__c,Expense_Category__c, Expense_Category__r.Name,
                               Withheld_Amount__c, Tech_Policy_Function_Department_Section__c
                               from Budget__c 
                               //where Catalog__c = :catId
                               //and Catalog__c  != null
                               where Expense_Category__c in :ExpenseCatalogyId 
                               and Expense_Category__c != null
                               and Effective_Start_Date__c < :system.today()
                               and Effective_end_Date__c > :system.today()
                               //and Tech_Policy_Function_Department_Section__c = :PolicyFunctionDepartment
                               order by Budget_Level__c
                              ]){

            System.debug('budget:'+budget);
            System.debug('PolicyFunctionDepartmentSection:'+PolicyFunctionDepartmentSection);
            System.debug('PolicyFunctionDepartment:'+PolicyFunctionDepartment);

            if (budget.Tech_Policy_Function_Department_Section__c == PolicyFunctionDepartmentSection) {
                return budget;
            }
            else if (budget.Tech_Policy_Function_Department_Section__c == PolicyFunctionDepartment) {
                return budget;
            }
        }
        */
        return IDPBudget;
    }
    
   Public IDP_Budget__c getBudgetById(String pBudgetId){
       IDP_Budget__c  budget = null;

        for(IDP_Budget__c reader :[select id, Department_Code__c, Function_Code__c, Section_Code__c, Site__c, 
                                   Current_Month_Budget__c, Current_Month_Remaining_Budget__c, year__c,
                                   Current_Month_Reserve_Budget__c, Current_Month_Used_Budget__c, Catalog__c,
                                   Catalog__r.Name, Ext_ID__c , Catalog_Name__c, currency__c, currency__r.Name,
                                   Year_Budget__c,Year_Remaining_Budget__c,Year_Reserve_Budget__c,Year_Used_Budget__c,
                                   Year_Pending_PR_Budget__c, Current_Month_Pending_PR_Budget__c
                                   from IDP_Budget__c
                                   where Id = : pBudgetId]) {
                               
           budget = reader;                       
       }
       
       return budget;
   }
    
    Public Double getWithheldAmount(){
        Double amount = 0;
        for(AggregateResult reader :[select sum(Budget_Amount__c) budgetAmount 
                                     from Purchase_Request_Item__c 
                                     where Purchase_Request__r.status__c in (:IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION, :IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL)
                                    ]){
            amount = Double.valueof(reader.get('budgetAmount'));
        }
        return amount;
    }
    
    public Purchase_Request__c  getPR(String pid){
        Purchase_Request__c pr;
        for(Purchase_Request__c reader : [select id, apply_date__c, Name, CreatedBy.Name,  Project_Name__c, Quote__c, Quote_Remark__c, Budget_Date__c, CreatedDate,
                                          Status__c, Need_by_Date__c, Delivery_To__c, Estimated_Total_Price__c, Standard_Exchange_Rate__c,
                                          On_Behalf_of__r.Name, On_Behalf_of__r.Employee__r.idp_policy__r.Name, On_Behalf_of__r.Employee__r.site__r.Site_ID_18__c,
                                          On_Behalf_of__r.Employee__c, On_Behalf_of__r.Employee__r.expense_policy__r.local_currency__c,
                                          On_Behalf_of__r.Employee__r.expense_policy__r.local_currency__r.Name, On_Behalf_of__r.Employee__r.site__c,
                                          On_Behalf_of__r.Administrator__c,On_Behalf_of__r.Employee_Administrator__c, 
                                          On_Behalf_of__r.Employee__r.site__r.Name, On_Behalf_of__r.Employee__r.Function__c, On_Behalf_of__r.Employee__r.Department__c,
                                          Applicant_Function__c, Applicant_Department__c, Applicant_Section__c,
                                          On_Behalf_of__r.Employee__r.Section__c, Catalog__r.Parent_Catalog__c,
                                          comment__c, Catalog__c, Catalog__r.Name, Catalog__r.Catalog_Name__c,
                                          On_Behalf_of__r.Employee__r.user__c, On_Behalf_of__r.Employee_Administrator__r.user__c,
                                          IDP_Policy__c, Tech_IDP_Policy_Name__c, Tech_Catalog_Owner_Queue_Name__c, Tech_C_Level_Approver__c,Repeat_Purchase__c,
                                          Tech_ROI_Approver__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c,
                                          Delivery_Site__c, Delivery_Site__r.Name, //Budget__c, Budget__r.Id, Budget__r.Expense_Category__r.Expense_Category_Id__c,
                                          Estimated_Local_Total_Price__c, Current_Approver__c,
                                          Copy_to_1__c, Copy_to_2__c, Copy_to_3__c, Copy_to_4__c, Copy_to_5__c,
                                          Copy_to_6__c, Copy_to_7__c, Copy_to_8__c, Copy_to_9__c, Copy_to_10__c, 
                                          Budget_Forecast__c, Prev_Purchase_Request__c, Prev_Purchase_Request__r.Name, IDP_Budget__c,  Reason_of_Request__c ,Purchase_Request__c.Assign_to_Local_Purchaser__c,
                                          (select id, Catalog_Item__r.Description__c, Purchase_Request__c, Budget_Exchange_Rate__c ,
                                              Currency__r.Name, Price__c, Catalog_Item__r.item_name__c, Currency__c,
                                              Catalog_Item__r.Unit_Of_Measure__c, Catalog_Item__r.Minimum_Order_Quantity__c, Quantity__c,
                                              Catalog_Item__r.Name, Catalog_Item__r.Catalog_Name__c, Tax_Standard_Total_Amount__c,
                                              Catalog_Item__r.Catalog__r.Catalog_Name__c, Amount__c, Used_Standard_Exchange_Rate__c, Standard_Exchange_Rate__c,
                                              Unit_of_Measure__c, Is_Direct_fulfillment__c, number__c,Standard_Currency__c,Standard_Amount__c,
                                              Remark__c, Supplier__c, Supplier__r.Name, Supplier__r.Tax__c, Cost_Item__c,
                                              Total_Received_Qty__c,Total_Requested_Qty__c,Received_Qty__c, 
                                              Status__c , Purchase_Order_Item__c, Purchase_Order_Item__r.Purchase_Order__c, Purchase_Order_Item__r.Purchase_Order__r.Name,
                                              Purchase_Order_Item__r.Received_Quantity__c, Purchase_Order_Item__r.Quantity__c,
                                              Catalog_Item__r.Reference_Price__c, Catalog_Item__r.Last_Supplier__r.currency__r.Name,Repeat_Purchase__c
                                              from Purchase_Request_Items__r
                                              order by number__c
                                          )
                                          from Purchase_Request__c  where id = :pid]){
            pr = reader;
        }
        return pr;
    }
    
    public Map<Id, List<Purchase_Cost__c>> getPRIPCListMap (String pid) {
        Map<Id, List<Purchase_Cost__c>> priIdPCListMap = new Map<Id, List<Purchase_Cost__c>> ();
        
        List<Purchase_Cost__c> tempPCList = new List<Purchase_Cost__c> ();
        for(Purchase_Cost__c pc: [SELECT Id, Purchase_Request_Item__c, Purchase_Request_Item__r.Number__c, Standard_Price__c,
                                        Purchase_Request_Item__r.Purchase_Request__c, Purchase_Request_Item__r.supplier__c, 
                                        Purchase_Request_Item__r.Catalog_Item__c,
                                        Purchase_Request_Item__r.supplier__r.Name, Purchase_Request_Item__r.Supplier__r.Tax__c, Purchase_Request_Item__r.amount__c,
                                        Name, Type__c, Currency__c, Currency__r.Name, Price__c, Supplier__c, Supplier__r.Name, Remark__c,
                                        Standard_Currency__c, Standard_Exchange_Rate__c, //Used_Standard_Exchange_Rate__c ,
                                        Purchase_Request_Item__r.status__c                                       
                                    FROM Purchase_Cost__c    
                                    WHERE Purchase_Request_Item__r.Purchase_Request__c = :pid
                                    ORDER BY Purchase_Request_Item__r.Number__c ASC, Type__c ASC, CreatedDate ASC]) {
            
            tempPCList = new List<Purchase_Cost__c> ();
            if(priIdPCListMap.containsKey(pc.Purchase_Request_Item__c)) {
                tempPCList = priIdPCListMap.get(pc.Purchase_Request_Item__c);
                tempPCList.add(pc);
            }
            else {
                tempPCList.add(pc);
            }           
            priIdPCListMap.put(pc.Purchase_Request_Item__c, tempPCList);                             
        }
        
        return priIdPCListMap;
    }
            
    public List<SelectOption> getCostItem()
    {
      List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = Purchase_Cost__c.Type__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
      for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(), f.getLabel()));
      }       
      return options;
    }
    
    
    Public void chagneCurrency(){
        Set <Id> currencyIDSet = new Set <Id>();
        Id localCurrency = this.emp.expense_policy__r.local_currency__c;       
        for(Purchase_Request_Item__c reader : pr.Purchase_Request_Items__r){
            currencyIDSet.add(reader.Currency__c);
        }
        for(exchange_rate__c reader : [ select id, rate__c, Tech_From_To_Currency_ID__c,
                                        From_Currency__c, To_Currency__c 
                                        from exchange_rate__c 
                                        where type__c = :TEConstant.EXCHANGE_RATE_TYPE_BOOK_RATE 
                                        //and from_currency__c in :currencyIDSet
                                        and to_currency__c = :localCurrency
                                        and Is_Latest__c = true
                                      ]){
            this.prCtrl.exchangeRateMap.put(String.valueof(reader.From_Currency__c) + String.valueof(reader.To_Currency__c), reader.rate__c);
        }    
    }

    private Map<String, Map<String, double>> getSupplierTaxShipOtherCost(List<Purchase_Request_Item__c> priList) {
        String supplierId = '';
        

        Map<String, Map<String, double>> supplierTaxShipOtherCostMap = new Map<String, Map<String, double>>();
        Map<String, double> amountMap = new Map<String, double>();

        for(Purchase_Request_Item__c reader : priList){
            double tax = 0;
            double ship = 0;
            double others = 0;
            supplierId = reader.supplier__c;
            priIdPCListMap = getPRIPCListMap(pid);
        
            if (priIdPCListMap.keySet().size() > 0) {
                if(priIdPCListMap.containsKey(reader.Id)) {

                  for(Purchase_Cost__c pc : priIdPCListMap.get(reader.id)) {
                      if (pc.Type__c == IDPConstant.PURCHASE_COST_TYPE_SHIPPING) {
                        ship += pc.Price__c;
                      }

                      if (pc.Type__c == IDPConstant.PURCHASE_COST_TYPE_TAX) {
                        tax += pc.Price__c;
                      }

                      if (pc.Type__c == IDPConstant.PURCHASE_COST_TYPE_OTHER_COST) {
                        others += pc.Price__c;
                      }
                  }
                }

                if(!supplierTaxShipOtherCostMap.containsKey(supplierId)){
                    amountMap = new Map<String, double>();
                    amountMap.put('TAX', tax);
                    amountMap.put('SHIP', ship);
                    amountMap.put('OTHERS', others);
                    supplierTaxShipOtherCostMap.put(supplierId, amountMap);
                }
                else{
                    amountMap = supplierTaxShipOtherCostMap.get(supplierId);
                    
                    double totalTax = amountMap.containsKey('TAX') ? amountMap.get('TAX') + tax : tax;
                    double totalShip = amountMap.containsKey('SHIP') ? amountMap.get('SHIP') + ship : ship;
                    double totalOthers = amountMap.containsKey('OTHERS') ? amountMap.get('OTHERS') + others : others;
                    amountMap.put('TAX', totalTax);
                    amountMap.put('SHIP', totalShip);
                    amountMap.put('OTHERS', totalOthers);

                    supplierTaxShipOtherCostMap.put(supplierId, amountMap);
                }
            }
            else {
                amountMap = new Map<String, double>();
                amountMap.put('TAX', tax);
                amountMap.put('SHIP', ship);
                amountMap.put('OTHERS', others);
                supplierTaxShipOtherCostMap.put(supplierId, amountMap);
            }
      }
      return supplierTaxShipOtherCostMap;
    }
    
    private Map<String, Map<String, double>> getSupplierCost(List<Purchase_Request_Item__c> priList){
        String supplierId = '';
        String currencyId = '';
        double amount = 0;
        
        Map<String, Map<String, double>> SupplierCostMap = new Map<String, Map<String, double>>();
        Map<String, double> amountMap = new Map<String, double>();
        for(Purchase_Request_Item__c reader : priList){
            supplierId = reader.supplier__c;
            currencyId = reader.currency__C;
            amount = reader.amount__c;
              

            if(!SupplierCostMap.containsKey(supplierId)){
                amountMap = new Map<String, double>();
                amountMap.put(currencyId, amount);
                SupplierCostMap.put(supplierId, amountMap);
            }
            else{
                amountMap = SupplierCostMap.get(supplierId);
                if(amountMap.containskey(currencyId)){
                    amountMap.put(currencyId, amountMap.get(currencyId) + amount);
                }
                else{
                    amountMap.put(currencyId, amount);
                }

                SupplierCostMap.put(supplierId, amountMap);
            }
        }

        return SupplierCostMap;
    }
    
    private Map<Id, List<Supplier_Item__c>> getSupplierItem(List<String> itemIdList){
        Map<Id, List<Supplier_Item__c>> SupplierItemMap = new Map<Id, List<Supplier_Item__c>>();
        for(Catalog_Item__c reader :[ select id, (select id, name, supplier__c, supplier__r.Name, supplier__r.Tax__c  from Supplier_Items__r order by Name) 
                                      from Catalog_Item__c
                                      where id in :itemIdList
                                     ]){
             SupplierItemMap.put(reader.id, reader.Supplier_Items__r);
        }
        return SupplierItemMap;
    }
    
    private Map<id, Supplier__c> getsupplierMap(Purchase_Request__c pr){
        List<Id> supplierIdList = new List<Id>();
        for(Purchase_Request_Item__c reader : pr.Purchase_Request_Items__r){
            supplierIdList.add(reader.supplier__c);
        }
        Map<id, Supplier__c> tmp = new Map<id, Supplier__c>([select id,  Name, Currency__c, Currency__r.Name, Tax__c 
                                                             from supplier__c
                                                             where id in :supplierIdList
                                                             //or status__c = 'ACT'
                                                             order by Name 
                                                            ]);
        return tmp;
    }
    
    private List<selectOption> getAllCurrency(){
        List <selectOption> currencyOpt = new List <selectOption>();
        currencyOpt.add(new selectOption('', ''));
        for(currency__c reader : this.currencyMap.values()){
        //for(currency__c reader : [select id, Name from currency__c order by Name]){
            currencyOpt.add(new selectOption(reader.id, reader.Name));   
        }
        return currencyOpt;
    }
    
    private Map<Id, Currency__c> getcurrencyMap(){
        Map<Id, Currency__c> temp = new Map<Id, Currency__c> ();
        
        for(currency__c reader : [select id, Name from currency__c order by Name]){
            temp.put(reader.Id, reader);
        }
        
        return temp;
    }
    private Map<Id, Site__c> getSiteMap(){
        Map<id, Site__c> tmp = new Map<id, Site__c>([select id, Name, address_1__c, address_2__c, address_3__c, address_4__c from Site__c order by Name]);
        return tmp;
    }
    
    private List<selectOption> getDeliverySite(){
        List <selectOption> siteOpt = new List <selectOption>();
        for(Site__c reader : siteMap.values()){
            siteOpt.add(new selectOption(reader.id, reader.Name));   
        }
        return siteOpt;
    }
    
    private List<user> getUserList(){
        List<user> temp = new List<user> ();
        temp.addAll([select id, Name, Name_display__c from user where isactive= true and Profile.UserType  in ( 'Standard', 'CsnOnly' ) order by Name]);
        return temp;
    }  
        
        
    private void getAllUserSelectionList() {
        String name = '';
        Integer i = 1;
        for (user reader : this.userList){
            name = reader.Name_Display__c;
            if(String.isblank(name)){
                name = reader.Name;
            }
            if( i <= 1000){
                this.userSelectionList.add(new SelectOption(reader.Id, name));
            }
            if( i > 1000 && i <= 2000){
                this.userSelectionList1.add(new SelectOption(reader.Id, name));
            }
            if( i > 2000 && i <= 3000){
                this.userSelectionList2.add(new SelectOption(reader.Id, name));
            }
            if( i > 3000 && i <= 4000){
                this.userSelectionList3.add(new SelectOption(reader.Id, name));
            }
            if( i > 4000 && i <= 5000){
                this.userSelectionList4.add(new SelectOption(reader.Id, name));
            }
            if( i > 5000 && i <= 6000){
                this.userSelectionList5.add(new SelectOption(reader.Id, name));
            }
            if( i > 6000 && i <= 7000){
                this.userSelectionList6.add(new SelectOption(reader.Id, name));
            }
            if( i > 7000 && i <= 8000){
                this.userSelectionList7.add(new SelectOption(reader.Id, name));
            }
            if( i > 8000 && i <= 9000){
                this.userSelectionList8.add(new SelectOption(reader.Id, name));
            }
            if( i > 9000 && i <= 10000){
                this.userSelectionList9.add(new SelectOption(reader.Id, name));
            }
            i++;
        }
        
    } 

    public Map<String, Map<String, Supplier_Item__c>> getCatalogItemSupplierSourceMap(List<String> catalogItemList) {
        // Map<CatalogItemId, Map<SupplierId, Supplier_Item__c>>
        Map<String, Map<String, Supplier_Item__c>> supplierItemMap = new Map<String, Map<String, Supplier_Item__c>>();

        for (String ci : catalogItemList) {
            Map<String, Supplier_Item__c> siMap = new Map<String, Supplier_Item__c>();

            for (Supplier_Item__c si : [SELECT Supplier__c, Id, Name, Catalog_Item__c, Minimum_Order_Quantity__c, Currency__c, Price__c, Expiry_Date__c, Lead_Time_Days__c, toLabel(Lead_Time_Format__c) 
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

    private Map<String, Set<String>> getLast3OrderedSupplierMap(List<String> itemIdList){

        Map<String, Set<String>> last3OrderedSupplierMap = new Map<String, Set<String>>();

        for (String itemId : itemIdList) {

            if (!last3OrderedSupplierMap.containsKey(itemId)) {
                Set<String> last3OrderedSupplierList = new Set<String>();
                for (Purchase_Order__c po : [SELECT Id, Supplier__r.Name, createdDate
                                             From Purchase_Order__c
                                             Where Id In (SELECT Purchase_Order__c FROM Purchase_Order_Item__c Where Catalog_Item__c = :itemId)
                                             Order by createdDate DESC
                                             Limit 50]) {

                    last3OrderedSupplierList.add(po.Supplier__r.Name);

                    if (last3OrderedSupplierList.size() >= 3)
                        break;
                }

                last3OrderedSupplierMap.put(itemId, last3OrderedSupplierList);
            }

        }

        return last3OrderedSupplierMap;
    }
    
    Public Map<String, exchange_rate__c> getCurrentExchangeRate(){
       Map<String, exchange_rate__c> exRateMap = new Map<String, exchange_rate__c>();
       for(exchange_rate__c er : [select id, Rate__c , from_Currency__c, to_currency__c
                                  from exchange_rate__c
                                  where 
                                  Is_Latest__c = true
                                  //and  From_Currency__c in :frCurrency
                                  and Is_Book_Rate__c = true
                                  and To_Currency__r.Is_Standard_Currency__c = true
                                  and Date__c <=  :this.pr.createdDate.DATE()
                                 ]){
           exRateMap.put(er.From_Currency__c, er);
       }
       return exRateMap; 
    }
}