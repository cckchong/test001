/**
 * IDPPurchaseOrderOverwriteNewCtrl
 * @description override new button of Catalog Item
 */
public without sharing class IDPPurchaseOrderOverwriteNewCtrl
{    

    //private String PROCUREMENT_GROUP_POLICY = '@policy';

    public PageReference redirect() {
        return new PageReference(Label.IDP_Path_IDPCreatePurchaseOrderVFP);
        /*
        Boolean isValid = false;
        Boolean isCatalogOwner = false;
        Boolean IsPurchaser = false;
        String userId = null;
        Employee__c employee = null;
        
        userId = UserInfo.getUserId();
        
        employee = getEmployeeRecord(userId);
        
        if(employee == null){ 
            isValid = false;
        }
        else {
            IsPurchaser = getIsPurchaser(employee.IDP_Policy__r.Name);
            isCatalogOwner = getIsCatalogOwner(userId);
        }
        
        if(IsPurchaser || isCatalogOwner) {
            isValid = true;
        }
        
        if(isValid) {
            return new PageReference(Label.IDP_Path_IDPCreatePurchaseOrderVFP);
        }
        else {
            return null;
        }
        */
    }
    
    /**
     * @description contructor with StandardController
     */
    public IDPPurchaseOrderOverwriteNewCtrl(ApexPages.StandardController controller) {
         
    }

    
    /*
    Private Employee__c getEmployeeRecord(Id pUserId){
        Employee__c emp = null;
        for(Employee__c reader : [select id, IDP_Policy__c, IDP_Policy__r.Name
                                  from Employee__c 
                                  where User__c = :pUserId] ){
            emp = reader;
        }
        return emp;
    }  
    
    
    Private Boolean getIsCatalogOwner(String pUserId){
        Boolean isCatalogOwner = false;
        Set<Id> userIdSet = new Set<Id> ();
        Map<Id, Set<Id>> userIdOwnedCatalogIdSetMap = new Map<Id, Set<Id>> ();
        userIdSet.add(pUserId);
        
        userIdOwnedCatalogIdSetMap = IDPCommonUtils.getUserCatalogs(userIdSet);
        
        if(!userIdOwnedCatalogIdSetMap.isEmpty()) {
            isCatalogOwner = true;
        }
        else{
            isCatalogOwner = false;
        }
        
        return isCatalogOwner;
    }
    
    Private Boolean getIsPurchaser(String policyName){
        Boolean isPurchaser = false;
        String procurmentQueue = IDPConstant.PROCUREMENT_QUEUE;
        List <String> userGroupList = new List <String>();
        if(String.isBlank(policyName)){
            return isPurchaser;
        }
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
    */  
}