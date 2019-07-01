public without sharing class TEEducationApplicationCtrl {
    public string test{get;set;}

    /****page configuration variables****/
    private ApexPages.StandardController standardController;    
    public boolean eligible{get;set;} {eligible = true;}
    public boolean staffType{get;set;} {staffType = true;} // if true, staff education; if false, child education
    public boolean isSalesforceOne{get;set;} {isSalesforceOne = SystemUtil.isMobileDevice();} 
    /****access control variables****/
    public boolean renderSave{get;set;} {renderSave = true;}
    public boolean renderSubmit{get;set;} {renderSubmit = true;} 
    public boolean renderApprove{get;set;} {renderApprove = false;} 
    public boolean applicantTabReadOnly{get;set;} {applicantTabReadOnly = false;} // if true, read only; if false, can view & edit
    public boolean renderHCMTab{get;set;} {renderHCMTab = false;}
    public boolean HCMTabReadOnly{get;set;} {HCMTabReadOnly = true;}
    /****custom fields variables****/
    public String textId{get;set;}
    public Education_Application__c ea{get;set;}
    public string createdBy{get;set;}
    public List<selectOption> applicants{get;set;}
    public string paymentMethod{get;set;}
    //public string status{get;set;}
    public String tmp{get;set;}

    public TEEducationApplicationCtrl(ApexPages.StandardController controller) {       
        this.standardController=controller; 
        textId = ApexPages.currentPage().getParameters().get('id');
                
        if (textId  == null){
            ea = new Education_Application__c ();
            ea.Apply_Date__c = Date.Today();
            ea.Currency__c = [SELECT Expense_Policy__r.Local_Currency__c FROM Employee__c WHERE User__r.Id = :UserInfo.getUserId() LIMIT 1].Expense_Policy__r.Local_Currency__c;
            createdBy = getEmployeeName(UserInfo.getUserId());
            ea.Status__c = getDefaultStatus();
            applicants = getApplicants();
            if (ApexPages.currentPage().getParameters().get('rt') == 'staff'){
                ea.RecordTypeId = getRecordType('Staff Education').getRecordTypeId();
            }
            else if (ApexPages.currentPage().getParameters().get('rt') == 'child'){
                ea.RecordTypeId = getRecordType('Child Education').getRecordTypeId();
                staffType = false;
            }
        }
        else{
            ea =  educationApplicationRecord(textId);
            createdBy = ea.Applicant__c;
            if (ea.RecordType.DeveloperName == 'Child_Education'){
                staffType = false;
            }
            if (!((ea.Status__c == TEConstant.STATUS_DRAFT || ea.Status__c == TEConstant.STATUS_NOT_SUBMITTED || ea.Status__c == TEConstant.STATUS_CANCELLED || ea.Status__c == TEConstant.STATUS_REJECT) && isApplicantOrCreator())){
                applicantTabReadOnly = true;
                renderSubmit = false;
                renderSave = false;
            }
            if (ea.Status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION || ea.Status__c == TEConstant.STATUS_APPROVED || ea.Status__c == TEConstant.STATUS_CANCELLED || ea.Status__c == TEConstant.STATUS_REJECT){
                renderHCMTab = true;
            }
            //if status == pending hcm, -> only if HCM, render&edit = true
            if (ea.Status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL && isHCM() && !isApplicantOrCreator()){//
                renderHCMTab = true;
                HCMTabReadOnly= false;
                renderApprove = true;
                renderSave = true;
                if (ea.Tuition_Fee_Recommended_Currency__c == NULL){
                    ea.Tuition_Fee_Recommended_Currency__c = ea.Currency__c;
                }
                if (ea.Tuition_Fee_Recommended__c == NULL || ea.Tuition_Fee_Recommended__c == 0){
                    ea.Tuition_Fee_Recommended__c = ea.Tuition_Fee__c;
                }
            }
            if (!applicantTabReadOnly){
                applicants = getApplicants();
            }
            //check if it is approver : renderApprove
            if (isApprover() && ea.Status__c == TEConstant.STATUS_PENDING_APPROVAL){
                renderApprove = true;
            }
            //
            if (isApplicantOrCreator() && ea.Status__c == TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION){
                renderApprove = true;
            }
            //ea.Tech_Payment_Method__c = getPaymentMethod(ea.Payment_Method__c);
            paymentMethod = getPaymentMethod(ea.Payment_Method__c);
        } 
    }
     
    private Education_Application__c  educationApplicationRecord(String id){
        return [select id, Name, RecordType.DeveloperName, Applicant__c, Status__c, On_Behalf_Of__c, On_Behalf_Of__r.Name, On_Behalf_Of__r.Employee_UserId__c, //label(Payment_Method__c),
                Apply_Date__c, CreatedBy.Id, Couse_Type__c, Education__c, Program_Course_Title__c, On_Behalf_Of__r.Administrator__c, 
                Start_Date__c, Course_URL__c, End_Date__c, Tuition_Fee__c, Payment_Method__c, Reason_of_Studying__c, Relevancy_to_work__c, 
                Name_of_Child__c, Length_of_Program_Year__c, Applied_Tuition_Fee__c, Approved_Tuition_Fee__c,
                Reliability_of_Course_Institute__c, Tuition_Fee_Recommended__c, Tuition_Fee_Recommended_Currency__c, Remarks__c, Currency__c,
                Actual_Approver_1__c, Actual_Approver_2__c , Actual_Approver_3__c , Actual_Approver_4__c, Current_Approver__c
                from Education_Application__c where id = :id];
    }
    
    //This redirects if a different landing tab/page is needed
    public PageReference redirect() {     
        if (ea.Status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL && isHCM() && !isApplicantOrCreator()){
            if (ApexPages.currentPage().getParameters().get('redirected') == 'true'){
                /*
                if (ApexPages.currentPage().getParameters().get('error') == 'tuition_fee'){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.TE_Education_Application_Recommended_Tuition_Fee_Error));
                }*/
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.TE_Education_Application_Cannot_Submit));
                return null;
            }       
             PageReference HCMTabPage = new PageReference(ApexPages.currentPage().getUrl() + '&redirected=true#tabs-2');       
             HCMTabPage.setRedirect(true);        
             return HCMTabPage;
        }
        else {
            return null;
        }
    }
    
    private Schema.RecordTypeInfo getRecordType(string rtname){
         try {
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{TEConstant.EDUCATION_APPLICATION_OBJECT_NAME});
            Schema.DescribeSObjectResult schemaResults = descResult[0];
            Map<String, Schema.RecordTypeInfo> mapRecordTypeInfos = schemaResults.getRecordTypeInfosByName();
            return mapRecordTypeInfos.get(rtname);         
            }
         catch(Exception ex) { 
             return null;
            //die silently 
         }
    } 
  
    private string getEmployeeName(String id){
        string name = '';
        for (Employee__c emp : [ SELECT Name, Full_Name__c FROM Employee__c WHERE User__r.id = :id LIMIT 1]){
                name = emp.Full_Name__c;
        }
        return name;     
    } 
    
    private string getPaymentMethod(String pm){
       Schema.DescribeFieldResult fieldResult = Education_Application__c.Payment_Method__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
           if (f.getValue() == pm){
               return f.getLabel();
           }
       }       
       return '';
    }
    
    private string getDefaultStatus(){
        Schema.DescribeFieldResult F = Education_Application__c.Status__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = F.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals) {
            if (pv.isDefaultValue()) {
                return pv.getValue();
            }    
        }
        return TEConstant.STATUS_DRAFT;
    }
    
    private boolean isApplicantOrCreator(){
        if (textId  == null){
            return true;
        }
        else{
            //if (ea.CreatedBy.Id == UserInfo.getUserId()){
            if (ea.On_Behalf_Of__r.Administrator__c == UserInfo.getUserId()){
                return true;
            }
            if (ea.On_Behalf_Of__r.Employee_UserId__c == String.valueOf(UserInfo.getUserId()).subString(0, 15)){
                return true;
            }
            return false;
        }
    }
    
    private boolean isApprover(){
        /**
        if (ea.Actual_Approver_1__c == UserInfo.getUserId() || ea.Actual_Approver_2__c == UserInfo.getUserId() || 
            ea.Actual_Approver_3__c == UserInfo.getUserId() || ea.Actual_Approver_4__c == UserInfo.getUserId()){
            return true;
        }**/
        Id userId = UserInfo.getUserId();
        if (ea.Current_Approver__c == userId ){
            return true;
        }
        else{
            return false;
        }
    }
    
    private boolean isHCM(){
        //Get the ID of the custom permission
        List<Id> customPermissionIds = new List<Id>();
        for (CustomPermission cp : [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'TE_Is_HCM']){
            customPermissionIds.add(cp.Id);
        }                                                                          
        //Query whether the custom permissions have been assigned to the logged in user
        List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess 
                                                                    WHERE SetupEntityId in :customPermissionIds AND
                                                                         ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment
                                                                                       WHERE AssigneeId = :UserInfo.getUserId())];
        if (setupEntities.isEmpty()){
            return false;
        }
        else{
            return true;
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
    
    //builds a picklist of applicants (on_behalf_of__c)
    public List<selectOption> getApplicants() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        //check eligibility according to education policy 
        Double minStaffGrade, maxStaffGrade, minChildGrade, maxChildGrade;
        Double minGrade, maxGrade;
        /**
        String employeeSite;
        for (Employee__c emp: [SELECT User__r.Id, Site__r.Name FROM Employee__c WHERE User__r.Id =:UserInfo.getUserId()]) {
            employeeSite = emp.Site__r.Name;    
        }
        
        for (Education_Policy__c ep: [SELECT Name, Education_Application_Min_Grade__c, Education_Application_Max_Grade__c FROM Education_Policy__c 
                                      WHERE Name = :employeeSite ]) {
            minGrade = ep.Education_Application_Min_Grade__c;
            maxGrade = ep.Education_Application_Max_Grade__c;
        }    
        **/
        for (Employee__c emp : [Select Tech_Grade__c, Education_Policy__c, Education_Policy__r.Child_Education_Application_Min_Grade__c, 
                                        Education_Policy__r.Child_Education_Application_Max_Grade__c, Education_Policy__r.Education_Application_Min_Grade__c,
                                        Education_Policy__r.Education_Application_Max_Grade__c
                                        From Employee__c
                                Where User__r.Id = :UserInfo.getUserId() LIMIT 1]){
            minStaffGrade = emp.Education_Policy__r.Education_Application_Min_Grade__c;
            maxStaffGrade = emp.Education_Policy__r.Education_Application_Max_Grade__c;
            minChildGrade = emp.Education_Policy__r.Child_Education_Application_Min_Grade__c;
            maxChildGrade = emp.Education_Policy__r.Child_Education_Application_Max_Grade__c;
        }
        
        if (ApexPages.currentPage().getParameters().get('rt') != 'child'){
            minGrade = minStaffGrade;
            maxGrade = maxStaffGrade;
        }
        else {
            minGrade = minChildGrade;
            maxGrade = maxChildGrade;
        }
                    
        for (Employee_Administrator__c eas: [SELECT Id, Name, Employee_UserId__c, Administrator__c, Employee__r.Tech_Grade__c FROM Employee_Administrator__c 
                                             WHERE Administrator__c = :String.valueOf(UserInfo.getUserId()).subString(0, 15)
                                             AND Employee__r.Tech_Grade__c >= :minGrade 
                                             AND Employee__r.Tech_Grade__c <= :maxGrade]) { //query for Employee Administrators
            options.add(new selectOption(eas.Id, eas.Name)); //for all records found - add them to the picklist options
            if ((textId  == null)&&(eas.Employee_UserId__c == String.valueOf(UserInfo.getUserId()).subString(0, 15))){
                    ea.On_Behalf_Of__c = eas.Id;
            }
        }
        if (options.isEmpty()){
            eligible = false;
        }
        return options; //return the picklist options
    }
    
    //builds a picklist of currencies
    public List<selectOption> getCurrencies() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('', Label.TE_Picklist_Default_Value)); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        for (Currency__c currencies: [SELECT Id, Name, Description__c FROM Currency__c ORDER BY Description__c ]) { //query for Currency
            options.add(new selectOption(currencies.Id, currencies.Description__c + ' (' + currencies.name + ')')); //for all records found - add them to the picklist options
        }
        return options; //return the picklist options
    }
    
    /**
    private String getCurrencyPicklistValue(Id currencyId) {
        Currency__c c = [Select Id, Name, Description__c FROM Currency__c Where Id = :currencyId Limit 1];
        return c.Description__c + ' (' + c.name + ')';
    }
    
    public String getAppliedCurrency() {
        return getCurrencyPicklistValue(ea.Currency__c);
    }
    
    //builds a picklist of payment methods
    public List<selectOption> getPaymentMethods() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('', Label.TE_Picklist_Default_Value)); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        
        if (ea.Couse_Type__c != null){
            Schema.DescribeFieldResult paymentMethodsFieldDescription = Education_Application__c.Payment_Method__c.getDescribe();
            options.add(new selectOption(ea.Couse_Type__c, ea.Couse_Type__c));
            for (Schema.Picklistentry picklistEntry: paymentMethodsFieldDescription.getPicklistValues()) {
                if (picklistEntry.getValue() == 'a' && ea.Couse_Type__c == 'd'){
                    options.add(new selectOption(picklistEntry.getValue(),picklistEntry.getLabel())); //for all records found - add them to the picklist options
                }
                else if (picklistEntry.getValue() == 'o'){
                    options.add(new selectOption(picklistEntry.getValue(),picklistEntry.getLabel()));
                }
            }
        }
        return options; //return the picklist options
    }
    **/
      
    //builds a picklist of course types
    /**
    public List<selectOption> getCourseTypes() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('', Label.TE_Picklist_Default_Value)); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        Schema.DescribeFieldResult courseTypeFieldDescription = Education_Application__c.Couse_Type__c.getDescribe();
        
        for (Schema.Picklistentry picklistEntry: courseTypeFieldDescription.getPicklistValues()) {
            options.add(new selectOption(pickListEntry.getValue(),pickListEntry.getLabel())); //for all records found - add them to the picklist options
        }
        return options; //return the picklist options
    }
    **/
       
       
    public PageReference saveAndRedirect(){   
        string textId;
        try{
            if (ea.Status__c == TEConstant.STATUS_CANCELLED || ea.Status__c == TEConstant.STATUS_REJECT){
                ea.Status__c = TEConstant.STATUS_NOT_SUBMITTED;
            }
            upsert ea;
            //PageReference newPage = new PageReference('/' + ea.id);
            PageReference newPage = new PageReference('/apex/' + Label.EducationApplicationVFP+ '?id=' + ea.Id);
            newPage.setRedirect(true);
            return newPage;  
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            /**
            if (ea.Status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL && isHCM() && !isApplicantOrCreator()){
                //PageReference newPage = new PageReference(ApexPages.currentPage().getUrl() + '&redirected=true#tabs-2');
                PageReference newPage = new PageReference('/apex/' + Label.EducationApplicationVFP+ '?id=' + ea.Id + '&redirected=true&error=tuition_fee#tabs-2');
                newPage.setRedirect(true);
                ApexPages.addMessages(ex);
                return newPage;
            }
            */
            return null;
        }     
    }
    
    public PageReference saveAndSubmit(){       
        String msg;
 
        if (ea.Status__c == TEConstant.STATUS_DRAFT || ea.Status__c == TEConstant.STATUS_NOT_SUBMITTED || ea.Status__c == TEConstant.STATUS_CANCELLED || ea.Status__c == TEConstant.STATUS_REJECT){
            try{
                if (ea.Status__c == TEConstant.STATUS_CANCELLED || ea.Status__c == TEConstant.STATUS_REJECT){
                   ea.Status__c = TEConstant.STATUS_NOT_SUBMITTED;
                }
                upsert ea;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(ea.id); 
                Approval.process(req);
                //msg = Label.TE_Education_Application_Submitted + ' ' + ea.Name;
            }
            catch(Exception ex){
                tmp = String.valueof(ex);
                ApexPages.addMessages(ex);
                return null;
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.TE_Education_Application_Cannot_Submit));
            //msg = Label.TE_Education_Application_Cannot_Submit;
        }     
        //String returnURL = ea.Id + '?msg=' + msg.replace(' ', '+');
        return new PageReference('/' + ea.Id);
    }

    /***For executing approval action in Apex***/
    private PageReference approvalAction(string action){     
        try{
            upsert ea;
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            //req.setComments(ea.Remarks__c);
            req.setAction(action);      
            req.setWorkitemId(getWorkItemId(ea.Id));  
            Approval.process(req);       
        }
        catch(Exception ex){
            tmp = String.valueOf(ex);
            ApexPages.addMessages(ex);
            return null;
        }
        return new PageReference('/' + ea.Id);
    }
    /***For Approve action in HCM edit page***/
    public PageReference saveAndApprove(){
        return approvalAction('Approve');
    }
    /***For Reject action in HCM edit page***/
    /**
    public PageReference saveAndReject(){
        return approvalAction('Reject');
    }
    **/
        
    public PageReference cancel(){
        if (textId  == null){
            String preFix = '';
            Schema.DescribeSObjectResult r = Education_Application__c.sObjectType.getDescribe();
            preFix  = r.getKeyPrefix();
            return new PageReference('/' + prefix + '/o');
        }
        else{
            return new PageReference('/' + textId);
        }
    }
}