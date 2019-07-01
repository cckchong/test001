public without sharing class IDPPurchaseRequestCtrl{
    Public static String VIEW_MODE = 'v';
    Public static String SAVE_MODE = 's';
    Public Purchase_Request__c pr {get;set;}
    Public Employee__c emp {get;set;}
    Public Budget__c budget{get;set;}
    Public IDP_Budget__c IDPbudget{get;set;}
    Public DisplayBudget displayedBudget {get;set;}
    Public String pid {get;set;}
    Public String mode {get;set;}
    Public String currencyType {get;set;}
    Public Boolean isSave {set;}
    Public Boolean isSaveReceived {set;}
    Public Boolean isEditReceived {set;}
    Public Boolean showSaveReceivedSave {get;set;}
    Public Boolean isEdit {set;}
    Public Boolean isSubmit {set;}
    Public Boolean isSubmitted {set;}
    Public Boolean isView {set;}
    Public Boolean isRecall {set;}
    Public Boolean isMyself {set;get;}
    Public Boolean isPurchaser {set;get;}
    Public Boolean isCatalogOwner {set;get;}
    Public Boolean isApprover {set;get;}
    Public Boolean isCurrentApprover {set;get;}
    Public Boolean isDisplayedMessage {set;get;}
    Public Boolean isShowStatus {set;}
    Public Map <Id, List<Purchase_Cost__c>> priIdPCListMap {set;get;}    
    Public List <selectOption> applicantOptList {get;set;}
    Public List <selectOption> currencyOptList {get;set;}
    Public List <selectOption> costItemOptList {get;set;}
    Public List <selectOption> deliverySiteOptList {get;set;}   
    Public List <selectOption> currencyList {get;set;}
    Public List <SelectOption> userSelectionList{get;set;}
    Public List <SelectOption> userSelectionList1{get;set;}
    Public List <SelectOption> userSelectionList2{get;set;}
    Public List <SelectOption> userSelectionList3{get;set;}
    Public List <SelectOption> userSelectionList4{get;set;}
    Public List <SelectOption> userSelectionList5{get;set;}
    Public List <SelectOption> userSelectionList6{get;set;}
    Public List <SelectOption> userSelectionList7{get;set;}
    Public List <SelectOption> userSelectionList8{get;set;}
    Public List <SelectOption> userSelectionList9{get;set;}    
    Public List <User> userList {get;set;}
    Public List<IDPPurchaseRequestLineCtrl> PRLineList {get;set;}
    Public Map<id, Site__c> siteMap {get;set;}    
    Public Map<id, Currency__c> currencyMap {get;set;}
    Public Map<id, Supplier__c> supplierMap {get;set;}
    Public Map<Id, List<Supplier_Item__c>> SupplierItemMap{get;set;}
    Public Map<String, Map<String, Supplier_Item__c>> catalogItemSupplierSourceMap {get;set;}
    Public Map<String, double> exchangeRateMap {get;set;}
    Public Map<String, Map<String, double>> supplierCost {get;set;}
    Public Map<String, Map<String, double>> supplierTaxShipOtherCost {get;set;}
    Public Map<String, Map<String, Boolean>> pripcIdFieldNameIsBlankMessageMap {get;set;}
    Public Map<String, Set<String>> last3OrderedSupplierMap {get;set;}
    Public Map<String,Exchange_Rate__c> exRateMap {get;set;}
    public Map<Id, Employee_Administrator__c> employeeAdminRecords {get;set;}
    Public IDPPurchaseRequestInitCtrl prInit;
    Public IDPPurchaseRequestActionCtrl prAction;
    Public String message {get;set;}
    Public String approvalComment {get;set;}
    Public String emailList {get;set;}
    Public String tmp {get;set;}
    Public List<ContentDocument> attachmentList {get;set;}
    Public String tempMode {get;set;}
    Public Date budgetDate {get;set;}
    Public Double usedBudgetWithoutCurrentPR {get;set;}
    Public Double yearUsedBudgetWithoutCurrentPR {get;set;}
    
    Public IDPPurchaseRequestCtrl(){
        //DisplayBudget displayedBudget = null;
        this.priIdPCListMap = new Map <Id, List<Purchase_Cost__c>> ();
        this.applicantOptList = new List <selectOption>();
        this.currencyOptList = new List <selectOption>();
        this.costItemOptList = new List <selectOption>();
        this.deliverySiteOptList = new List <selectOption>();
        this.currencyList = new List <selectOption>();       
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
        this.employeeAdminRecords = new Map<Id, Employee_Administrator__c>();
        this.exchangeRateMap = new Map<String, Double>();
        this.exRateMap = new Map<String,Exchange_Rate__c>();
        this.userList = new List<User> ();
        this.PRLineList = new List<IDPPurchaseRequestLineCtrl>();
        this.pripcIdFieldNameIsBlankMessageMap = new Map<String, Map<String, Boolean>> ();
        this.pid = ApexPages.currentPage().getParameters().get('prid');
        this.mode = ApexPages.currentPage().getParameters().get('mode');
        this.currencyType = '';
        this.message = '';
        this.approvalComment = '';
        this.emaillist = '';
        this.isDisplayedMessage = false;
        this.isMyself = false;
        this.isPurchaser = false;
        this.isCatalogOwner = false;
        this.isApprover = false;
        this.isCurrentApprover = false;
        this.isShowStatus = false;
        this.prInit = new IDPPurchaseRequestInitCtrl(this, pid);
        this.prAction = new IDPPurchaseRequestActionCtrl(this, pid);
        this.attachmentList = new List<ContentDocument> ();
        this.attachmentList = this.prAction.getPRAttachment(this.pr);
        this.budgetDate = pr.budget_Date__c;
        this.usedBudgetWithoutCurrentPR = 0;
        this.yearUsedBudgetWithoutCurrentPR  = 0;
        
        for(Purchase_Request_Item__c reader : pr.Purchase_Request_Items__r){

            this.PRLineList.add(new IDPPurchaseRequestLineCtrl(reader, this));
            if(this.priIdPCListMap.containsKey(reader.Id)) {
                for(Purchase_Cost__c pc : priIdPCListMap.get(reader.Id)) {
                    this.PRLineList.add(new IDPPurchaseRequestLineCtrl(pc, this));
                }
            }
        }
        tempMode = this.mode;
        if(String.isBlank(this.mode)){
            this.mode = VIEW_MODE;
        }
        if(getisSubmitted() && !(this.isCatalogOwner || this.isPurchaser)){
            this.mode = VIEW_MODE;
        }
        if(pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_DELIVERED) {
            this.mode = VIEW_MODE;
        }
        if((pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_ORDERED ||
            pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_PARTIAL_ORDERED || 
            pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_PARTIAL_DELIVERED)){
            if(isMyself) {
                if(isCatalogOwner || isPurchaser){
                    this.mode = VIEW_MODE;
                }
            }
            else {
                this.mode = VIEW_MODE;
            }
        }

        if(this.IDPbudget != null){
            this.usedBudgetWithoutCurrentPR = displayedBudget.unused;
            this.yearUsedBudgetWithoutCurrentPR = displayedBudget.yearunused;
            if(budgetDate.year() == System.Today().year() || budgetDate.month() == System.Today().month()){
                this.usedBudgetWithoutCurrentPR += pr.Estimated_Total_Price__c;
                this.yearUsedBudgetWithoutCurrentPR  += pr.Estimated_Total_Price__c;
            }
            /*
            if (displayedBudget.unused < 0 || displayedBudget.yearUnused < 0 || 
                ((budgetDate.year() != System.Today().year() || budgetDate.month() != System.Today().month()) && 
                 (displayedBudget.unused + pr.Estimated_Total_Price__c < 0 || displayedBudget.yearUnused + pr.Estimated_Total_Price__c < 0 ))
               ){
                this.usedBudgetWithoutCurrentPR = displayedBudget.unused - pr.Estimated_Total_Price__c;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.warning,'Overbudget: Insufficient budget for procurement'));
            }
            */
        }
    }
    
    Public Boolean getisEdit(){
        if(pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED ||
           pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED){
            return false;
        }
        if((isPurchaser || isCatalogOwner) && pr.Current_Approver__c == null && (pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL)){
            return this.mode == VIEW_MODE;
        }
        else if(isMyself){
            return this.mode == VIEW_MODE && !getisSubmitted();
        }
        return false;
    }
    
    Public Boolean getisView(){
        return this.mode == VIEW_MODE;
    }
    
    Public Boolean getisSave(){
        if(pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED){
            return false;
        }      
        if(isCatalogOwner || isPurchaser ){
            return this.mode == SAVE_MODE;
        }
        else if(isMyself){
            return this.mode == SAVE_MODE && !getisSubmitted();
        }
        else{
            return false;
        }
    }
    
    Public Boolean getisShowStatus(){
        return !(pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_DRAFT || pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_PENDING_PURCHASE_CONFIRMATION || pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_PENDING_APPROVAL || pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_REJECTED  || pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_NOT_SUBMITTED);
    }
    
    Public Boolean getisSaveReceived(){
        return (
                (pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_ORDERED ||
                 pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_PARTIAL_ORDERED || 
                 pr.status__c == IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_PARTIAL_DELIVERED) 
                 && isMyself 
                 && tempMode == 's');
    }  
    
    Public Boolean getisEditReceived(){
        return (
                (pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_ORDERED ||
                 pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PARTIAL_ORDERED || 
                 pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PARTIAL_DELIVERED) 
                 && isMyself 
                 && tempMode == 'v');
    }      
        
    Public Boolean getisSubmitted(){
         return !(pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT  || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED );
    }
    
    Public Boolean getisSubmit(){
         return isMyself && (pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT  || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED );
    }
    
    Public Boolean getisRecall(){
        return isMyself && 
                !(pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT || 
                pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED || 
                pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED || 
                pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED || 
                pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_ORDERED ||
                pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PARTIAL_ORDERED || 
                pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PARTIAL_DELIVERED ||
                pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DELIVERED);
    }
    
    Public Boolean getisApproval(){
        return !(pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT  || pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED);
    }
    
    Public DateTime getApplyDate(){
        return pr.Apply_Date__c;
    }
    
    public void updateEmployee() {
        Employee_Administrator__c ea = null;
        this.pr.Need_By_Date__c = Date.newInstance(2017, 1, 1);
        ea = this.employeeAdminRecords.get(this.pr.On_Behalf_Of__c);


        this.emp = this.prInit.getEmployeeRecord(ea.Employee__c);
        system.debug(this.pr.On_Behalf_Of__c);
        system.debug(ea.Employee__c);
        system.debug(this.emp);
        this.message ='test';

    }

    Public PageReference saveAction(){
        return prAction.saveAction();
    }

    //Public void saveReceivedAction(){
    //    prAction.saveReceivedAction();
        
        
    //    showSaveReceivedSave = false;
    //    PageReference link = prAction.saveReceivedAction();
    //    this.pr = prInit.getPR(this.pr.Id);
    //    this.PRLineList.clear();
    //    for(Purchase_Request_Item__c reader : this.pr.Purchase_Request_Items__r) {
    //        this.PRLineList.add(new IDPPurchaseRequestLineCtrl(reader, this)); 
    //    }    
            
    //    return link;    
                 
    //}
    
    //Public PageReference editReceivedAction(){
    //    showSaveReceivedSave = true;
    //    return prAction.editAction();             
    //}    
    
    Public PageReference submitAction(){
        return prAction.submitAction();
    }
    
    Public PageReference editAction(){
        return prAction.editAction();
    }
    
    Public PageReference cancelAction(){
        return prAction.cancelAction();
    }
    
    Public PageReference recallAction(){
        return prAction.recallAction();
    }
    
    Public PageReference approveAction(){
        return prAction.approvalAction('Approve');
    }
    
    Public PageReference rejectAction(){
        system.debug(approvalComment);
        return prAction.approvalAction('Reject');
    }
    
    Public PageReference cloneAction(){
        return prAction.cloneAction();
    }

    Public PageReference backAction(){
        return prAction.backAction();
    }
    
    Public void changeSite() {
        system.debug('changesite');
        boolean isDummyDate = false;

        if (pr.Need_by_Date__c == null) {
            pr.Need_by_Date__c = Date.newInstance(1900, 1, 1);
            isDummyDate = true;
        }
        
        prAction.getDeliveryAddress();

        if (isDummyDate) {
            pr.Need_by_Date__c = null;
        }
    }
    
    Public void changeSupplierAction() {
        String priId = '';
        String supplierId = '';
        priId = ApexPages.currentPage().getParameters().get('PRItemID');
        supplierId = ApexPages.currentPage().getParameters().get('SupplierID');
        for(supplier__c supplier : [select id,  Name, Currency__c, Currency__r.Name, Tax__c from supplier__c where id = :supplierId]){
            supplierMap.put(supplier.id, supplier);
        }
        if(!String.isBlank(priId)) {
            prAction.changeItemDetails(priId);
        }        
    }
    
   @RemoteAction
   Public static  String  uploadFileAction(String name , String contentType, String body, string attachid, String pid) {
       Attachment attach = new Attachment();
       if ( attachid != ''){
           for(Attachment atm : [select Id, Body from Attachment where Id = :attachid]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachid, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + body));
            }
           return attachid;
       }
       attach.Name = name;
       attach.ContentType = contentType;
       attach.ParentId = pid;//'a0sp0000002sia1';//pid;
       attach.Body = EncodingUtil.Base64Decode(body);
       upsert attach;  
       body = null;
       
       contentType = '';
       name = '';
       return attach.id;
   }
    
   Public class DisplayBudget {
        
        Public String functionCode {get;set;}
        Public String departmentCode {get;set;}
        Public String sectionCode {get;set;}
        Public String year {get;set;}
        Public String expenseCategoryName {get;set;}
        Public String currencyName {get;set;}
        Public double budget {get;set;}
        Public double used {get;set;}
        public double withheld {get;set;}
        public double unused {get;set;}
        public double PendingPR {get;set;}

        Public double yearBudget {get;set;}
        Public double yearPendingPR {get;set;}
        Public double yearUsed {get;set;}
        public double yearWithheld {get;set;}
        public double yearUnused {get;set;}

        Public String month{get;set;}
        Public DisplayBudget() {}
        Public DisplayBudget(IDP_Budget__c pBudget) {
            if(pBudget != null) {                
                functionCode = pBudget.Function_Code__c;
                departmentCode =pBudget.Department_Code__c;
                sectionCode = pBudget.Section_Code__c;
                year = pBudget.Year__c;
                expenseCategoryName = pBudget.Catalog_Name__c;

                budget = pBudget.Current_Month_Budget__c;
                used = pBudget.Current_Month_Used_Budget__c;
                withheld = pBudget.Current_Month_Reserve_Budget__c;
                unused = pBudget.Current_Month_Remaining_Budget__c;
                PendingPR = pBudget.Current_Month_Pending_PR_Budget__c;
                currencyName = pBudget.Currency__r.Name;

                yearBudget = pBudget.Year_Budget__c;
                yearUsed = pBudget.Year_Used_Budget__c;
                yearPendingPR = pBudget.Year_Pending_PR_Budget__c;
                yearWithheld = pBudget.Year_Reserve_Budget__c;
                yearUnused = pBudget.Year_Remaining_Budget__c;

                Integer mon = Date.today().month();
                switch on mon {
                    when 1 {
                        month = 'January';
                    }   
                    when 2 {
                        month = 'February';
                    }
                    when 3 {
                        month = 'March';
                    }
                    when 4 {
                        month = 'April';
                    }
                    when 5 {
                        month = 'May';
                    }
                    when  6 {
                        month = 'June';
                    }
                    when 7 {
                        month = 'July';
                    }
                    when 8 {
                        month = 'August';
                    }
                    when 9 {
                        month = 'September';
                    }
                    when 10 {
                        month = 'October';
                    }
                    when 11 {
                        month = 'November';
                    }
                    when 12 {
                        month = 'December';
                    }
                }              
            }
        }
    }

    public void refreshPRAttachment() {
        this.attachmentList = this.prAction.getPRAttachment(this.pr);
    }

    public void deletePRAttachment() {
        
        String attId = ApexPages.CurrentPage().getParameters().get('attId');
        system.debug('delete pr att:'+attId);
        prAction.deletePRAttachemnt(attId);
        refreshPRAttachment();
    }

}