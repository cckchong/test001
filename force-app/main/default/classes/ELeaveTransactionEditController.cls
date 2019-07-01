/*
*   @description To over Leave Request Edit button
*/
public without sharing class ELeaveTransactionEditController 
{    
    String recordTypeId;
    Map<Id, String> recordtype = new Map<Id, String> ();
    public String returnURL {set;get;}
    public String errorMsg {set;get;}
    public Leave_Request__c LeaveRequest {get;set;} { LeaveRequest = null; }
    public boolean notSupported {get;set;} {notSupported = false;}
    public ELeaveTransactionEditController (ApexPages.StandardController controller) 
    {
         errorMsg = '';
         LeaveRequest =  (Leave_Request__c ) controller.getRecord(); 
         for ( Leave_Request__c lq : 
                 [select id, Late_Application__c, Leave_Application__c, status__c, Leave_Application__r.type__c, RecordTypeId
                 from Leave_Request__c where Id = :LeaveRequest.id  ]
             )
         {
             LeaveRequest = lq;
         }
         
         recordTypeId = LeaveRequest.RecordTypeId ;
         for ( RecordType rt : [SELECT Id,   DeveloperName FROM RecordType   where SobjectType  = :LeaveRequestConstant.LEAVE_REQUEST_OBJECT_NAME  and IsActive = true] )
         {
             recordtype.put ( rt.id , rt.DeveloperName );
         }
        
    }
    
    public PageReference newaction() 
    {
        errorMsg = '';
        String keyPrefix = '';
        PageReference acctPage = null;
        returnURL = '';
        if ( recordtype.get(recordTypeId)  ==  LeaveRequestConstant.LEAVE_TYPE_LEAVE_REQUEST  )
        {
            
            
            if ( LeaveRequest.Leave_Application__r.type__c ==  LeaveRequestConstant.LEAVE_APPLICATION_BATCH  )
            {
                returnURL =  '/'+LeaveRequest.id;
                notSupported = true;
            }
            else
            {
                returnURL = Label.ELeave_App_Path+'?id='+LeaveRequest.Leave_Application__c +'&sfdc.tabName='+label.ELeave_Leave_Request_TabnameID+'&nooverride=1'  ;
                if ( LeaveRequest.status__c == LeaveRequestConstant.STATUS_REJECT || LeaveRequest.status__c == LeaveRequestConstant.STATUS_DRAFT || LeaveRequest.status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED  || LeaveRequest.status__c == LeaveRequestConstant.STATUS_CANCELLED )
                {
                    returnURL = Label.ELeave_App_Path+'?id='+LeaveRequest.Leave_Application__c +'&sfdc.tabName='+label.ELeave_Leave_Request_TabnameID+'&nooverride=1'  ;
                }
                else
                {
                    Leave_Request__c lr = [select id, Tolabel(status__c) from Leave_Request__c  where id = :LeaveRequest.id];
                    errorMsg = Label.ELeave_Error_Edit1 + ' ' + lr.status__c;
                    if ( LeaveRequest.status__c == LeaveRequestConstant.STATUS_APPROVED ) {
                        errorMsg = Label.ELeave_Error_Edit;
                    }   
                    returnURL = '/'+LeaveRequest.id ;
                }
            }
        } 
         
        if ( recordtype.get(recordTypeId).contains ( LeaveRequestConstant.LEAVE_TYPE_FLEXIBLE_TIME_REQUEST ) )
        {
            for (Employee__c employee : [ Select Name  from Employee__c where  User__r.id = :UserInfo.getUserId()   ])
            {
                if ( LeaveRequest.status__c == LeaveRequestConstant.STATUS_NOT_SUBMITTED  || LeaveRequest.status__c == LeaveRequestConstant.STATUS_CANCELLED  )
                {
                    returnURL = '/'+LeaveRequest.id+'/e?retURL=%2F'+LeaveRequest.id+'&nooverride=1';
                }
                else
                {
                    returnURL = '/'+LeaveRequest.id;                    
                }                
            }
            notSupported = true;
        } 
        return acctPage;
    }

}