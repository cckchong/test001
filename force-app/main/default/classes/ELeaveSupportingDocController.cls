/**
 * ELeaveSupportingDocController 
 * @description leave request(s) Supporting Document 
 */
public without sharing class ELeaveSupportingDocController 
{
    private static final String LEAVE_SUPPORTING_DOC_FUNCTION = 'Leave_Supporting_Doc';    
    private ApexPages.StandardSetController standardController;
    private Set<Id> Ids;
    private Map<Id, String> recordtype;
    private List<Leave_Request__c> listlq;
    
    /**
     * @description constructor with StandardController
     */
     
    public ELeaveSupportingDocController (ApexPages.StandardSetController controller) 
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
        for ( Leave_Request__c reader:  [select id, Supporting_Document_Provided__c from Leave_Request__c  where id in :Ids ] )
        {
            listlq.add( reader );
        }
        
    } 
    
    public PageReference supportingDocResult(String accessID, List<Leave_Request__c> listlq)
    {
        if ( accessID != null ){            
            for ( Leave_Request__c reader : listlq )
            {
                reader.Supporting_Document_Provided__c = !reader.Supporting_Document_Provided__c;
            }
            update listlq;            
            return new PageReference('/' + Leave_Request__c.sObjectType.getDescribe().getKeyPrefix() + '?fcf=' + Label.ELeave_Leave_Request_Support_Doc_View ); 
        }
        else {
            return new PageReference('javascript: alert(\''+ Label.ELeave_Error_Support_Doc +'\');window.history.back();');
        }
    }
    
    public PageReference supportingDocAction()
    {
        Id accessID = null;
        for ( SetupEntityAccess reader : 
        [
            SELECT Id
            FROM SetupEntityAccess 
            where SetupEntityId in ( SELECT Id  FROM CustomPermission where DeveloperName = :LEAVE_SUPPORTING_DOC_FUNCTION  )
            and ParentId in 
            (
                SELECT   PermissionSetId
                FROM PermissionSetAssignment
                where AssigneeId  = :UserInfo.getUserId()
            )
            limit 1 
        ]){
            accessID = reader.id;
        }
        return supportingDocResult(accessID, this.listlq);         
    }
}