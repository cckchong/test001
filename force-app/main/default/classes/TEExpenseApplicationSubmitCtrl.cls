/**
 * TEExpenseApplicationSubmitCtrl
 * @author Kelvin Wong
 * @description to overwrite submit button of Expense Application(s)
 */
global without sharing class TEExpenseApplicationSubmitCtrl {
    
    /**
     * @description check whether the device is using Salesforce One
     */
    global static boolean isSalesforceOne{get;set;} {isSalesforceOne = SystemUtil.isMobileDevice();}
    /**
     * @description get expense detail list
     */
    global static List<Expense_Detail__c> expDetailList{get;set;}
    /**
     * @description output message
     */
    global static String msg{get;set;}
    
    /**
     * @description constructor with StandardController
     */
    global TEExpenseApplicationSubmitCtrl  (ApexPages.StandardController controller) {
    }
    
    /**
     * @description override action in VisualForce Page
     * @return the page to redirect, expecting null
     */
    public PageReference actionFunction(){
        return null;
    }
    
    /**
     * @desciption remote action to submit expense application
     * @return the URL to redirect
     */
    @RemoteAction
    public static String submitExpenseApp(Id recordId){
    
        List <Approval.ProcessSubmitRequest> listreq = new List <Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest req1 = null;
        expDetailList = new List<Expense_Detail__c>();
        String returnURL = recordId;
        String p = null;       
        String tmpmsg = Label.TE_Expense_Application_Submitted_Detail;
        
        for (Expense_Detail__c expDetail : [select Id, Name, Status__c from Expense_Detail__c where Expense_Application__c = :recordId and (Status__c = :TEConstant.STATUS_DRAFT or Status__c = :TEConstant.STATUS_NOT_SUBMITTED) and Mine__c = true]) {
            //expDetail.Status__c = TEConstant.STATUS_PENDING_APPROVAL;
            expDetailList.add(expDetail);            
            req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(expDetail.id );
            listreq.add(req1);            
            tmpmsg += ' ' + expDetail.Name + ',';
        } 
        //Submit to Approval processes
        if (!listreq.isEmpty()) {
            if(!Test.isRunningTest()){            
                Approval.process(listreq);
            }else{
                for (Expense_Detail__c expenseApplication : expDetailList) {
                    expenseApplication.status__c = TEConstant.STATUS_PENDING_APPROVAL;
                }
                upsert expDetailList;
            }
        }
        //update expDetailList;
        if (expDetailList.isEmpty()) {
            msg = Label.TE_Expense_Application_No_Submitted_Detail;
        } else {
            msg = tmpmsg.substring(0, tmpmsg.length()-1);
        }
        p = returnURL+'?msg='+msg.replace(' ', '+');
        /*if(!isSalesforceOne) {
            p = returnURL+'?msg='+msg.replace(' ', '+');
        } else {
            // Must be some issue auto forwarding people on mobile
            p = null;
        }*/
        return p;
    }
}