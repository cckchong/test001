public without sharing class IDPPurchaseRequestActionCtrl{

    Private IDPPurchaseRequestCtrl prCtrl;
    Private String pid;
    Private Static String APPROVAL_ACTION_REJECT = 'Reject';
    Private Static String OPEN_BRACKET =  '[';
    Private Static String CLOSE_BRACKET =  ']';
    Private Static String WHITESPACE= ' ';    
    Private Static String SINGLECOMMA = ',';
    
    Public IDPPurchaseRequestActionCtrl(IDPPurchaseRequestCtrl prCtrl, String pid){
        this.pid = pid;
        this.prCtrl = prCtrl;
        
    }
    
    Public PageReference backAction(){
        PageReference prf = null;
        String preFix = '';
        Schema.DescribeSObjectResult r = Purchase_Request__c.sObjectType.getDescribe();
        preFix = r.getKeyPrefix();
        prf = new PageReference('/'+preFix);
        prf.setRedirect(true);
        return prf;
    }
    
    Public PageReference editAction(){
        PageReference prf = null;
        prf = new PageReference('/apex/IDPPurchaseRequestVFP?prid='+pid + '&mode='+IDPPurchaseRequestCtrl.SAVE_MODE);
        prf.setRedirect(true);
        return prf;
    }
    
    Public PageReference saveAction(){
        PageReference prf = null;
        Integer counter = 1;
        List <Purchase_Request_Item__c> PRLineList = new List <Purchase_Request_Item__c>();
        List <Purchase_Cost__c> PRLineCostList = new List <Purchase_Cost__c>();
        List <String> CurrencyList = new List <String>();
        Map<String,Exchange_Rate__c> exRateMap = new Map<String,Exchange_Rate__c>();
        List <String> msgList;
        
        if(this.prCtrl.pr != null){
            msgList = IDPPurchaseRequestValidationsController.PRValidationMessage(this.prCtrl.pr);
            if(!msgList.isEmpty()){
                for(String msg : msgList){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,msg));
                }
                return null;
            }
            if(this.prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT ||
                this.prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED ||
                this.prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED) {
                saveCCEmailUser();
            }
            upsert this.prCtrl.pr;
        }
        if(!this.prCtrl.PRLineList.isEmpty()){
            for(IDPPurchaseRequestLineCtrl reader : this.prCtrl.PRLineList){
                if(reader.pri != null) {
                    reader.pri.number__c = counter;
                    if(this.prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT ||
                        this.prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED ||
                        this.prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION) {
                            CurrencyList.add(reader.pri.currency__c);                            
                    }
                    counter ++;
                }
                if(reader.pc != null) {
                    if(reader.pc.Purchase_Request_Item__r.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT ||
                        reader.pc.Purchase_Request_Item__r.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED ||
                        reader.pc.Purchase_Request_Item__r.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION) {
                            CurrencyList.add(reader.pc.currency__c);
                    }
                }
            }
            if(!CurrencyList.isEmpty()){
                exRateMap = prCtrl.exRateMap ;
            }
            
            for(IDPPurchaseRequestLineCtrl reader : this.prCtrl.PRLineList){
                if(reader.pri != null) {
                    if(this.prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT ||
                            this.prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED ||
                            this.prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION) {
                        if(exRateMap.containsKey(reader.pri.currency__c)){
                            reader.pri.Standard_Exchange_Rate__c = exRateMap.get(reader.pri.currency__c).id;
                            reader.pri.Standard_Currency__c = exRateMap.get(reader.pri.currency__c).to_currency__c;
                            reader.pri.Used_Standard_Exchange_Rate__c = exRateMap.get(reader.pri.currency__c).rate__c;
                        }
                    }
                }
                if(reader.pri != null){
                    PRLineList.add(reader.pri);
                }
                if(reader.pc != null) {
                    PRLineCostList.add(reader.pc);
                }
            }
            if(!PRLineList.isEmpty()){
                upsert PRLineList;
            }
            upsert PRLineCostList;
        }
        prf = new PageReference('/apex/IDPPurchaseRequestVFP?prid='+pid+'&mode='+IDPPurchaseRequestCtrl.VIEW_MODE);
        prf.setRedirect(true);
     
        return prf;
    }

    Public void changeItemDetails(String pPRIId){
        
        for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList) {
            if(reader.PRItemID == pPRIId) {
                if(reader.pri != null) {
                    if(!String.isBlank(reader.pri.Supplier__c)) {
                        system.debug('reader.pri.Supplier__c:'+reader.pri.Supplier__c);
                        reader.pri.Currency__c = prCtrl.supplierMap.get(reader.pri.Supplier__c).Currency__c;
                        reader.supplierTax = prCtrl.supplierMap.get(reader.pri.Supplier__c).Tax__c;
                    }
                    else {
                        reader.pri.Currency__c = null;
                        reader.supplierTax = 0;
                    }
                }
                else if(reader.pc != null) {
                    if(!String.isBlank(reader.pc.Supplier__c)) {
                        reader.pc.Currency__c = prCtrl.supplierMap.get(reader.pc.Supplier__c).Currency__c;
                        reader.supplierTax = prCtrl.supplierMap.get(reader.pc.Supplier__c).Tax__c;
                    }
                    /*
                    else {
                        reader.pc.Currency__c = null;
                    }
                    */
                }
            }
        }
    }
    
    Public PageReference submitAction(){
        PageReference prf = null;
        List <String> msgList = IDPPurchaseRequestValidationsController.PRValidationMessage(this.prCtrl.pr);
        if(!msgList.isEmpty()){
            for(String msg : msgList){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,msg));
            }
            return null;
        }
        system.debug('prCtrl.pr.status__c:'+prCtrl.pr.status__c);
        /*
        if (prCtrl.pr.status__c == IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT){
            autoCreateTaxRowBeforeSubmit();
        }
        */
        saveAction();
        upsert (new Purchase_Request__c ( id = this.pid, status__c = IDPConstant.PURCHASE_REQUEST_STATUS_SUBMITTED));
        Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
        psr.setObjectId(this.pid);
        Approval.process(psr);
        prf = new PageReference('/apex/IDPPurchaseRequestVFP?prid='+pid+'&mode='+IDPPurchaseRequestCtrl.VIEW_MODE);
        prf.setRedirect(true);
        return prf;
    }
    
    
    Public PageReference cancelAction(){
        PageReference prf = null;
        prf = new PageReference('/apex/IDPPurchaseRequestVFP?prid='+pid+'&mode='+IDPPurchaseRequestCtrl.VIEW_MODE);
        prf.setRedirect(true);
        return prf;
    }
    
    
    Public void delRowAction(String PRItemID){

        system.debug('PRItemID:'+PRItemID);

        Integer counter = 1;
        Purchase_Request_Item__c pri = null;
        List <Purchase_Request_Item__c> priList = new List<Purchase_Request_Item__c>();
        Set <Integer> removedCounterSet = new Set <Integer> ();
        //for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList.clone()){
        for(Integer i = 0; i < prCtrl.PRLineList.size() ; ) {
            if(prCtrl.PRLineList.get(i).PRItemID == PRItemID){
                if(prCtrl.PRLineList.get(i).pri != null) {
                    pri = prCtrl.PRLineList.get(i).pri;
                }
                this.prCtrl.PRLineList.remove(i);
                //break;
            }
            else {
             i ++;
            }
            //counter++;
        }
        if(pri != null && pri.id != null){
            delete pri;
            counter = 1;
            for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList){
                if(reader.pri != null) {
                    reader.pri.number__c = counter;
                    priList.add(reader.pri);
                }
                counter ++;
            }
            
            if(!priList.isEmpty()){
                upsert priList;
            }
            
        }
        
    }
    Public void changefulfillmentAction(String pPRItemID) {
        
        Set<String> toBeDeletedPCIDSet = new Set<String> ();
        
        for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList) {
            if(reader.PRItemID == pPRItemID) {
                if(!String.isBlank(reader.PCID)){
                    toBeDeletedPCIDSet.add(reader.PCID);
                }
            }
        
        }
        
        delPCRowAction(toBeDeletedPCIDSet);
    }
    
    Public void delPCRowAction(Set<String> pPCIDSet){
        Integer counter = 1;
        
        List<Purchase_Cost__c> toBeDeletedPCList = new List<Purchase_Cost__c> ();
            for(String pcIdReader : pPCIdSet) {   
                for(Integer i = 0; i < prCtrl.PRLineList.size() ; ) {
                    if(prCtrl.PRLineList.get(i).PCID == pcIdReader ) {
                        if(prCtrl.PRLineList.get(i).pc != null && prCtrl.PRLineList.get(i).pc.Id != null) {
                            toBeDeletedPCList.add(prCtrl.PRLineList.get(i).pc);
                        }
                        this.prCtrl.PRLineList.remove(i);
                    }
                    else {
                        i ++;
                    }
                }
            }
        if(!toBedeletedPCList.isEmpty()){
            delete toBedeletedPCList;
        }
    }
    /*
    Public void delPCRowAction(String PCID){
        Integer counter = 1;
        Purchase_Cost__c pc = null;
        List <Purchase_Cost__c> pcList = new List<Purchase_Cost__c>();
        for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList){
            if(reader.pc != null) {
                if(reader.PCID == PCID){
                    pc = reader.pc;
                    this.prCtrl.PRLineList.remove(counter-1);
                    break;
                }
               
            }
            counter++;
        }
        if(pc != null && pc.id != null){
            delete pc;
        }
        
    } 
    */   
    /*
    Public void addRowAction(String PRItemID){
        Integer counter = 1;
        Integer size = prCtrl.PRLineList.size();
        IDPPurchaseRequestLineCtrl tempPRCtrl = new IDPPurchaseRequestLineCtrl(this.prCtrl.pr, prCtrl);
        
        for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList){  
            tempPRCtrl.pri.Supplier__c = reader.pri.Supplier__c;
            if (counter == size){
                this.prCtrl.PRLineList.add(tempPRCtrl);
                break;
            }
            else if(reader.PRItemID == PRItemID){
                this.prCtrl.PRLineList.add(counter, tempPRCtrl);
                break;
            }
            counter++;
        } 
    }
    */
    
    Public void addRowAction(IDPPurchaseRequestLineCtrl prlineCtrl){
 
        Integer counter = 1;
        Integer size = prCtrl.PRLineList.size();
        Purchase_Cost__c pc = new Purchase_Cost__c ();
        IDPPurchaseRequestLineCtrl tempPRCtrl = new IDPPurchaseRequestLineCtrl(prlineCtrl); //new IDPPurchaseRequestLineCtrl(pc, prlineCtrl.pri, prCtrl);
        
        for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList){ 
           
            if (counter == size){
                this.prCtrl.PRLineList.add(tempPRCtrl);
                break;
            }
            else if(reader.PRItemID == prlineCtrl.PRItemID){
                this.prCtrl.PRLineList.add(counter, tempPRCtrl);
                break;
            }
            counter++;
        } 
         for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList){ 
             if(reader.pri != null){
                 reader.supplierid = reader.pri.supplier__c;
             }
             
             if(reader.pc!= null){
                 reader.supplierid = reader.pc.supplier__c;
             }               
         }
    }    
    Public void addTaxRowAction(IDPPurchaseRequestLineCtrl prlineCtrl){
 
        Integer counter = 1;
        Integer size = prCtrl.PRLineList.size();
        IDPPurchaseRequestLineCtrl tempPRCtrl = new IDPPurchaseRequestLineCtrl(prlineCtrl);
        tempPRCtrl.pc.type__c = 'TAX';

        system.debug('prlineCtrl.supplierTax:'+prlineCtrl.supplierTax);
        system.debug('prlineCtrl.pri.price__c:'+prlineCtrl.pri.price__c);
        system.debug('prlineCtrl.pri.Quantity__c:'+prlineCtrl.pri.Quantity__c);
        
        if (prlineCtrl.supplierTax != null)
            tempPRCtrl.pc.price__c = prlineCtrl.pri.price__c * prlineCtrl.pri.Quantity__c * (prlineCtrl.supplierTax / 100);

        for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList){ 
           
            if (counter == size){
                this.prCtrl.PRLineList.add(tempPRCtrl);
                break;
            }
            else if(reader.PRItemID == prlineCtrl.PRItemID){
                this.prCtrl.PRLineList.add(counter, tempPRCtrl);
                break;
            }
            counter++;
        } 
         for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList){ 
             if(reader.pri != null){
                 reader.supplierid = reader.pri.supplier__c;
             }             
             if(reader.pc!= null){
                 reader.supplierid = reader.pc.supplier__c;
             }               
         }
    }
    
    /*
    Public void autoCreateTaxRowBeforeSubmit() {

        List<IDPPurchaseRequestLineCtrl> priCtrlList = new List<IDPPurchaseRequestLineCtrl>();

        for(IDPPurchaseRequestLineCtrl priCtrl : this.prCtrl.PRLineList){
            if(priCtrl.pri != null) {
                priCtrlList.add(priCtrl);
            }
        }

        for (IDPPurchaseRequestLineCtrl tempPriCtrl : priCtrlList) {
            addTaxRowAction(tempPriCtrl);
        }
    } 
    */
       
    Public PageReference approvalAction(String action){
        PageReference prf = null;
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        Map<Id, SObject> pripcMap = new Map<Id, SObject> ();
        Map<String, Map<String, Boolean>> pripcIdFieldNameIsBlankMessageMap  = new Map<String, Map<String, Boolean>> ();          
      //Boolean is_Direct_fulfillment=false;
        this.prCtrl.isDisplayedMessage = false;
        this.prCtrl.message = '';
      /***  if(this.prCtrl.isCatalogOwner==true)
        {
            for(IDPPurchaseRequestLineCtrl reader : prCtrl.PRLineList)
                {
                    if(reader.pri!=null){
                        if(reader.pri.Is_Direct_fulfillment__c==false)
                            {
                                System.debug(1);
                                is_Direct_fulfillment=false;
                                break;
                                }
                         else{
                         is_Direct_fulfillment=true;
                         }       
                    }
                }
            }
        if(is_Direct_fulfillment==true){
        this.prCtrl.pr.Status__c=IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED;
        }
        System.debug(prCtrl.pr.Status__c);    ***/
        saveAction();
        req.setAction(action);
        req.setWorkitemId(getWorkItemId(pid));
        req.setComments(this.prCtrl.approvalComment);
        
        
        if(action != APPROVAL_ACTION_REJECT) { 
        
            for(IDPPurchaseRequestLineCtrl reader : this.prCtrl.prLineList) {
                if(reader.pri != null) {
                    pripcMap.put(reader.pri.Id, reader.pri);
                }
                else if(reader.pc != null) {
                    pripcMap.put(reader.pc.Id, reader.pc);
                }
            }
        
            if(pripcMap.size() > 0) {
                pripcIdFieldNameIsBlankMessageMap  = IDPPurchaseRequestValidationsController.validatePurchaseRequestItemInput(pripcMap);
            }
        
        
        if(pripcIdFieldNameIsBlankMessageMap.size() > 0) {
            this.prCtrl.pripcIdFieldNameIsBlankMessageMap  = pripcIdFieldNameIsBlankMessageMap ;
            for(Map<String, Boolean> reader : this.prCtrl.pripcIdFieldNameIsBlankMessageMap.values()) {
                for(Boolean isRequiredreader : reader.values()) {
                    if(isRequiredreader) {
                        this.prCtrl.isDisplayedMessage = true;
                        this.prCtrl.message = Label.IDP_Purchase_Request_Fill_in_Fields_Marked_In_Red_Message;
                        break;
                    }
                }
                if(this.prCtrl.isDisplayedMessage) {
                    break;
                }
            }
        }
        
        }
        
        if(this.prCtrl.isDisplayedMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.prCtrl.message));
            return null;
        }
        else { 
            Approval.process(req);
            prf = new PageReference('/apex/IDPPurchaseRequestVFP?prid='+pid+'&mode='+IDPPurchaseRequestCtrl.VIEW_MODE);
            prf.setRedirect(true);
            return prf;   
        }
     
    }
    
    
    Public PageReference recallAction(){
        PageReference prf = null;
        ProcessInstanceWorkitem[] workItems = [
             SELECT Id
               FROM ProcessInstanceWorkitem 
              WHERE ProcessInstance.TargetObjectId = :pid
                AND ProcessInstance.Status = 'Pending'];

        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
        pwr.setAction('Removed');
        pwr.setWorkItemId(workItems[0].id);

        system.debug('pwr:'+pwr);
        system.debug('pid:'+pid);
        system.debug('workItem[0].Id:'+workItems[0].id);

        Approval.ProcessResult result = Approval.process(pwr);
        prf = new PageReference('/apex/IDPPurchaseRequestVFP?prid='+pid+'&mode='+IDPPurchaseRequestCtrl.VIEW_MODE);
        prf.setRedirect(true);
        return prf;
    }



    Public PageReference cloneAction(){
        PageReference prf = null;
        Employee_Administrator__c applicant = IDPCommonUtils.getEmployeeAdministrator(UserInfo.getUserId());
        List <Purchase_Request_Item__c> PRLineList = new List <Purchase_Request_Item__c>();
        List <Purchase_Cost__c> PRLineCostList = new List <Purchase_Cost__c>();
        Map <Id, Purchase_Request_Item__c> priVersion = new Map<Id, Purchase_Request_Item__c>();


        // Clone PR
        Purchase_Request__c oldPr = prCtrl.pr;
        Purchase_Request__c newPr = oldPr.clone(false, false, false, false);
        newPr.Prev_Purchase_Request__c = oldPr.Id;
        newPr.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT;
        newPr.Actual_Approver_1__c = null;
        newPr.Actual_Approver_2__c = null;
        newPr.Actual_Approver_3__c = null;
        newPr.Actual_Approver_4__c = null;
        newPr.Apply_Date__c = system.today();
        newPr.Last_Approval_Action_Date__c = null;
        newPr.Submission_Date__c = null;
        insert newPr;
        system.debug('oldPr IDP_Policy__c:'+oldPr.IDP_Policy__c);
        system.debug('newPr IDP_Policy__c:'+newPr.IDP_Policy__c);
        system.debug('oldPr:'+oldPr);
        system.debug('newPr:'+newPr);

        newPr.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED;
        update newPr;

        // Clone PRI & Cost
        if(!this.prCtrl.PRLineList.isEmpty()){

            // Clone PRI
            for(IDPPurchaseRequestLineCtrl prLine : this.prCtrl.PRLineList){
                if(prLine.pri != null) {
                    Purchase_Request_Item__c oldPri = prLine.pri;
                    Purchase_Request_Item__c newPri = oldPri.clone(false, false, false, false);
                    newPri.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT;
                    newPri.Purchase_Request__c = newPr.Id;
                    priVersion.put(oldPri.Id, newPri);

                    PRLineList.add(newPri);
                }
                
            }
            insert PRLineList;


            // Clone PRI Cost
            for(IDPPurchaseRequestLineCtrl prLine : this.prCtrl.PRLineList){
                if(prLine.pc != null) {
                    Purchase_Cost__c oldPc = prLine.pc;
                    Purchase_Cost__c newPc = oldPc.clone(false, false, false, false);
                    newPc.Purchase_Request_Item__c = priVersion.get(oldPc.Purchase_Request_Item__c).Id;

                    PRLineCostList.add(newPc);
                }
            }
            insert PRLineCostList;
        }
        prf = new PageReference('/apex/IDPPurchaseRequestVFP?prid='+newPr.Id+'&mode='+IDPPurchaseRequestCtrl.SAVE_MODE);
        prf.setRedirect(true);
        return prf;
    }

    Public void getDeliveryAddress(){
        system.debug('getDeliveryAddress:'+prCtrl.pr.Delivery_Site__c);
        system.debug('map:'+prCtrl.siteMap);
        system.debug('contains?:'+prCtrl.siteMap.containsKey(prCtrl.pr.Delivery_Site__c));
        if(prCtrl.siteMap.containskey(prCtrl.pr.Delivery_Site__c)){
            prCtrl.pr.Delivery_To__c = '';
            if(!String.isBlank(prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_1__c)){
                prCtrl.pr.Delivery_To__c = prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_1__c + ' ';
            }
            if(!String.isBlank(prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_2__c)){
                prCtrl.pr.Delivery_To__c += prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_2__c + ' ';
            }
            if(!String.isBlank(prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_3__c)){
                prCtrl.pr.Delivery_To__c += prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_3__c + ' ';
            }
            if(!String.isBlank(prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_4__c)){
                prCtrl.pr.Delivery_To__c += prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_4__c + ' ';
            }
            //prCtrl.pr.Delivery_To__c += prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_2__c + ' ';
            //prCtrl.pr.Delivery_To__c += prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_3__c + ' ';
            //prCtrl.pr.Delivery_To__c += prCtrl.siteMap.get(prCtrl.pr.Delivery_Site__c).Address_4__c;
        }
    }
    
    private Id getWorkItemId(Id targetObjectId){
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select Id from ProcessInstanceWorkitem
            where ProcessInstance.TargetObjectId =: targetObjectId]){
            retVal  =  workItem.Id;
        }
        return retVal;
    }
    
    Public void preInputReceivedQtyAction(IDPPurchaseRequestLineCtrl pToBeRemovedLine){
    
        for(IDPPurchaseRequestLineCtrl  reader : this.prCtrl.PRLineList) {
            if(reader == pToBeRemovedLine) {

                 reader.receivedQuantityString = String.valueOf(reader.pri.Quantity__c);
                 
                  //system.debug(reader.pri.Quantity__c);
                 //system.debug(reader.receivedQuantity );
                // system.debug(reader.receivedQuantityString);

                //reader.receivedQuantityString = String.valueOf(reader.pri.Quantity__c);
            }
        }     
    }  
    Private void saveCCEmailUser() {

        String [] splitEmailList;
        String tmpEmailList = this.prCtrl.emailList;
        
        Integer emailListSize = 0;
        if (tmpEmailList == null){
            tmpEmailList = '';
        }
        tmpEmailList = tmpEmailList.replace(OPEN_BRACKET,'');
        tmpEmailList = tmpEmailList.replace(CLOSE_BRACKET,'');
        tmpEmailList = tmpEmailList.replaceAll(WHITESPACE,'');
        
        splitEmailList = tmpEmailList.split(SINGLECOMMA);
        emailListSize = splitEmailList.size();              
        this.prCtrl.pr.Copy_to_1__c = null;
        this.prCtrl.pr.Copy_to_2__c = null;
        this.prCtrl.pr.Copy_to_3__c = null;
        this.prCtrl.pr.Copy_to_4__c = null;
        this.prCtrl.pr.Copy_to_5__c = null;
        this.prCtrl.pr.Copy_to_6__c = null;
        this.prCtrl.pr.Copy_to_7__c = null;
        this.prCtrl.pr.Copy_to_8__c = null;
        this.prCtrl.pr.Copy_to_9__c = null;
        this.prCtrl.pr.Copy_to_10__c = null;
        
        if ( emailListSize > 0 && tmpEmailList.length() > 0){
        this.prCtrl.pr.Copy_to_1__c = splitEmailList[0];
        }               
        if ( emailListSize > 1){
        this.prCtrl.pr.Copy_to_2__c = splitEmailList[1];
        }
        if ( emailListSize > 2){
        this.prCtrl.pr.Copy_to_3__c = splitEmailList[2];
        }
        if ( emailListSize > 3){
        this.prCtrl.pr.Copy_to_4__c = splitEmailList[3];
        }
        if ( emailListSize > 4){
        this.prCtrl.pr.Copy_to_5__c = splitEmailList[4];
        }
        if ( emailListSize > 5){
        this.prCtrl.pr.Copy_to_6__c = splitEmailList[5];
        }
        if ( emailListSize > 6){
        this.prCtrl.pr.Copy_to_7__c = splitEmailList[6];
        }
        if ( emailListSize > 7){
        this.prCtrl.pr.Copy_to_8__c = splitEmailList[7];
        }
        if ( emailListSize > 8){
        this.prCtrl.pr.Copy_to_9__c = splitEmailList[8];
        }
        if ( emailListSize > 9){
        this.prCtrl.pr.Copy_to_10__c = splitEmailList[9];
        }        
        
    }           
    
    Public void deletePRAttachemnt(String attId) {
        List<ContentDocument> att = [SELECT Id, Title, LastModifiedDate, ParentId, CreatedById, LatestPublishedVersionId 
                                    FROM ContentDocument
                                    WHERE Id = :attId
                                    ];

        delete att;
    }  

    Public List<ContentDocument> getPRAttachment(Purchase_Request__c pr) {
    
        List<ContentDocument> tempAttachmentList = new List<ContentDocument> ();
    
        Map<String, String> docIds = new Map<String, String>();
            for (ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId
                                             FROM ContentDocumentLink
                                             Where LinkedEntityId = :pr.Id]) {

            docIds.put(link.ContentDocumentId, link.LinkedEntityId);
        }
    
        tempAttachmentList = [SELECT Id, Title, LastModifiedDate, ParentId, CreatedById, LatestPublishedVersionId 
                              FROM ContentDocument
                              WHERE Id IN :docIds.keySet()
                              ORDER BY Title];
        
        for (ContentDocument doc : tempAttachmentList) {
            doc.ParentId = docIds.get(doc.Id);
        }
        return tempAttachmentList;
    }   



    //In PR, Not handling receiving
    //Public void saveReceivedAction(){
    
    //    Boolean isValid = true;
        
    //    this.prCtrl.isDisplayedMessage = false;
    //    this.prCtrl.message = '';
    //    isValid = validateReceivedQty(); 
        
    //    if(isValid) {
    //        //updatePOReceivedQuantity();
    //        //insertReceivingHistory();
    //        updateReceivingPRI();
    //    }
    //    else {
    //        this.prCtrl.isDisplayedMessage = true;
    //        this.prCtrl.message = Label.IDP_PO_Received_Quantity_Error_Message;
    //    }

    //    if(this.prCtrl.isDisplayedMessage) {
    //        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,this.prCtrl.message));
    //    }
    //}
    
    //Private Boolean validateReceivedQty() {
    //    Boolean isValid = true;
        
    //    for(IDPPurchaseRequestLineCtrl  reader : prCtrl.PRLineList) {
    //        if(!reader.getisValidReceivedQuantity()) {
    //            isValid = false;
    //            break;
    //        }
    //    } 
    //    return isValid;
    
    //}
    
    //Private void updatePOReceivedQuantity() {
    //    Set<String> toBeUpdatedPOIIdSet = new Set<String>();
    //    Map<Id, Purchase_Order_Item__c> toBeUpdatedPOIMap = new Map<Id, Purchase_Order_Item__c>();
    //    Double changes = 0;
    //    for(IDPPurchaseRequestLineCtrl reader : this.prCtrl.PRLineList) {
    //        if(reader.pri != null) {
    //            if(reader.pri.Purchase_Order_Item__c != null) {
    //                toBeUpdatedPOIIdSet.add(reader.pri.Purchase_Order_item__c);
    //            }
    //        }
    //    }
        
    //    for(Purchase_Order_Item__c poi : [SELECT Id, Received_Quantity__c FROM Purchase_Order_Item__c WHERE Id in :toBeUpdatedPOIIdSet]) {
    //        toBeUpdatedPOIMap.put(poi.Id, poi);
    //    }        
        
    //    for(IDPPurchaseRequestLineCtrl reader : this.prCtrl.PRLineList) {
    //        if(reader.pri != null) {
    //            if(reader.pri.Purchase_Order_Item__c != null) {
    //                if(toBeUpdatedPOIMap.containsKey(reader.pri.Purchase_Order_Item__c)) {
    //                    changes = reader.ReceivedQuantity - toBeUpdatedPOIMap.get(reader.pri.Purchase_Order_Item__c).Received_Quantity__c; 
    //                    //if(toBeUpdatedPOIMap.get(reader.pri.Purchase_Order_Item__c).Received_Quantity__c + reader.receivedQuantity < toBeUpdatedPOIMap.get(reader.pri.Purchase_Order_Item__c).Quantity__c) {
    //                    toBeUpdatedPOIMap.get(reader.pri.Purchase_Order_Item__c).Received_Quantity__c += changes;
    //                    //}
    //                }
    //            }
    //        }
    //    }
        
    //    update toBeUpdatedPOIMap.values();      
    //}
    //Private void insertReceivingHistory() {
    
    //    List <Receiving_History__c> tobeInsertReceivingHistoryList = new List <Receiving_History__c> ();
    //    Receiving_History__c tempReceivingHistory = null;
        
    //    for(IDPPurchaseRequestLineCtrl reader : this.prCtrl.PRLineList) {
    //        if(reader.pri != null) {
    //            if(reader.receivedQuantity != reader.pri.Received_Qty__c) {
    //                tempReceivingHistory = new Receiving_History__c ();
    //                tempReceivingHistory.Purchase_Order_item__c = reader.pri.Purchase_Order_item__c;
    //                tempReceivingHistory.quantity__c = reader.receivedQuantity - reader.pri.Received_Qty__c;
    //                tobeInsertReceivingHistoryList.add(tempReceivingHistory);
    //            }
    //        }        
    //    }
        
    //    if(!tobeInsertReceivingHistoryList.isEmpty()){
    //        insert tobeInsertReceivingHistoryList;
    //    }
    //}

    //Private void updateReceivingPRI() {
    
    //    List <Purchase_Request_item__c> tobeUpdatedPRIList = new List <Purchase_Request_item__c> ();
        
    //    for(IDPPurchaseRequestLineCtrl reader : this.prCtrl.PRLineList) {
    //        if(reader.pri != null) {
    //            reader.pri.Received_Qty__c = reader.receivedQuantity;
    //           /*
    //           if(reader.pri.Received_Qty__c == 0) {
    //                reader.pri.Status__c = IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_ORDERED;
    //            } 
                
    //            if(reader.pri.Received_Qty__c > 0) {
    //                reader.pri.Status__c = IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_PARTIAL_DELIVERED;
    //            }
                             
    //            if(reader.pri.Quantity__c == reader.pri.Received_Qty__c ) {
    //                reader.pri.Status__c = IDPConstant.PURCHASE_REQUEST_ITEM_STATUS_DELIVERED;
    //            }
    //            */
    //            tobeUpdatedPRIList.add(reader.pri);
    //        }        
    //    }
        
    //    if(!tobeUpdatedPRIList.isEmpty()){
    //        update tobeUpdatedPRIList;
    //    }
    //}        
}