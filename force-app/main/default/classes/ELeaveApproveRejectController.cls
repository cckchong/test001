/**
 * ELeaveApproveRejectController
 * @description To approve/reject leave request(s) 
 */
public without sharing class ELeaveApproveRejectController 
{
    private static final String LEAVE_SUPPORTING_DOC_FUNCTION = 'Leave_Supporting_Doc';    
    private ApexPages.StandardSetController standardController;
    private Set<Id> Ids;
    private Map<Id, String> recordtype;
    private List<Leave_Request__c> listlq;
    private String ACTION_APPROVE = 'Approve';
    private String ACTION_REJECT = 'Reject';
    
    /**
     * @description constructor with StandardController
     */
     
    public ELeaveApproveRejectController (ApexPages.StandardSetController controller) 
    {
        String textId = ApexPages.currentPage().getParameters().get('id');
        Ids = new Set<Id> ();
        this.standardController = controller;
        listlq  = (List<Leave_Request__c>) standardController.getSelected();
        for (Leave_Request__c request : listlq  ) 
        {
                Ids.add(request.id);
        }
        if (textId != null) 
        {
             Ids.add(textId);
        }
        listlq  = new List<Leave_Request__c> ();
        for ( Leave_Request__c reader:  [select id, I_Am_Approver__c from Leave_Request__c  where id in :Ids and status__c in ( :LeaveRequestConstant.STATUS_PENDING_APPROVAL, :LeaveRequestConstant.STATUS_PENDING_CANCELLATION ) and I_Am_Approver__c = true ] )
        {
            if ( reader.I_Am_Approver__c ){
                listlq.add( reader );
            }
        }
        
    } 
    
    public PageReference ApprovalResult(String action, List<Leave_Request__c> listlq)
    {
    
        if ( !listlq.isempty() ){        
            Approval.ProcessWorkitemRequest req = null;
            List <Approval.ProcessWorkitemRequest> reqList = new List <Approval.ProcessWorkitemRequest>();
            
            for ( ProcessInstanceWorkitem p : [Select Id from ProcessInstanceWorkitem where   ProcessInstance.TargetObjectId in :listlq ]){
                req = new Approval.ProcessWorkitemRequest();
                req.setAction(action);
                req.setWorkitemId(p.id);
                reqList.add(req);
            }         
            Approval.process(reqList);
            return new PageReference('/' + Leave_Request__c.sObjectType.getDescribe().getKeyPrefix() + '?fcf=' + Label.ELeave_Leave_Requests_to_Approve ); 
        }
        else{
            return new PageReference('javascript: alert(\''+ Label.ELeave_Error_Batch_Approval +'\');window.history.back();');
        }
        
    }
    
    public PageReference ApproveAction()
    {    
        return ApprovalResult(ACTION_APPROVE, this.listlq);         
    }
    
    public PageReference RejectAction()
    {    
        return ApprovalResult(ACTION_REJECT, this.listlq);         
    }
}