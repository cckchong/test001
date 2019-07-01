/**
 * IDPManualSharingCtrl
 * @description To set Manual Sharing for IDP Sharing
 */
 
public without sharing class IDPManualSharingCtrl  {

    /*Sharing Rule Reason*/
    Public static final String PURCHASE_REQUEST_SHARING_RULE_APPROVER_SHARING = Schema.Purchase_Request__Share.RowCause.Approver_Sharing__c;
    Public static final String PURCHASE_REQUEST_SHARING_RULE_CATALOG_OWNER_SHARING = Schema.Purchase_Request__Share.RowCause.Catalog_Owner_Sharing__c;
    Public static final String PURCHASE_REQUEST_SHARING_RULE_PROCUREMENT_SHARING = Schema.Purchase_Request__Share.RowCause.Procurement_Sharing__c;
    Public static final String PURCHASE_REQUEST_SHARING_RULE_APPLICANT_SHARING = Schema.Purchase_Request__Share.RowCause.Applicant_Sharing__c;
    Public static final String PURCHASE_REQUEST_SHARING_RULE_MENTION_USER_SHARING = Schema.Purchase_Request__Share.RowCause.Mention_User_Sharing__C;
    Public static final String PURCHASE_REQUEST_SHARING_RULE_REQUESTOR_SHARING = Schema.Purchase_Request__Share.RowCause.Owner;
    Public static final String PURCHASE_REQUEST_SHARING_RULE_FINANCE_SHARING = Schema.Purchase_Request__Share.RowCause.Finance_Sharing__c;

    Public static final String PURCHASE_ORDER_SHARING_RULE_PR_APPROVER_SHARING = Schema.Purchase_Order__Share.RowCause.PR_Approver_Sharing__c;
    Public static final String PURCHASE_ORDER_SHARING_RULE_PR_CATALOG_OWNER_SHARING = Schema.Purchase_Order__Share.RowCause.PR_Catalog_Owner_Sharing__c;
    Public static final String PURCHASE_ORDER_SHARING_RULE_PR_PROCUREMENT_SHARING = Schema.Purchase_Order__Share.RowCause.PR_Procurement_Sharing__c;
    Public static final String PURCHASE_ORDER_SHARING_RULE_PR_APPLICANT_SHARING = Schema.Purchase_Order__Share.RowCause.PR_Applicant_Sharing__c;
    Public static final String PURCHASE_ORDER_SHARING_RULE_PR_MENTION_USER_SHARING = Schema.Purchase_Order__Share.RowCause.PR_Mention_User_Sharing__C;
    Public static final String PURCHASE_ORDER_SHARING_RULE_PR_REQUESTOR_SHARING = Schema.Purchase_Order__Share.RowCause.PR_Requestor_Sharing__c;
    Public static final String PURCHASE_ORDER_SHARING_RULE_PR_FINANCE_SHARING = Schema.Purchase_Order__Share.RowCause.PR_Finance_Sharing__c;
    


    Public static String purchaseRequestApproverSharing = PURCHASE_REQUEST_SHARING_RULE_APPROVER_SHARING;
    Public static String purchaseRequestCatalogOwnerSharing = PURCHASE_REQUEST_SHARING_RULE_CATALOG_OWNER_SHARING;
    Public static String purchaseRequestProcurementSharing = PURCHASE_REQUEST_SHARING_RULE_PROCUREMENT_SHARING;
    Public static String purchaseRequestApplicantSharing  = PURCHASE_REQUEST_SHARING_RULE_APPLICANT_SHARING;
    Public static String purchaseRequestCopyToUserSharing  = PURCHASE_REQUEST_SHARING_RULE_MENTION_USER_SHARING;
    Public static String purchaseRequestRequestorSharing  = PURCHASE_REQUEST_SHARING_RULE_REQUESTOR_SHARING;
    Public static String purchaseRequestFinanceSharing  = PURCHASE_REQUEST_SHARING_RULE_FINANCE_SHARING;
    
    Public static String purchaseOrderPRApproverSharing = PURCHASE_ORDER_SHARING_RULE_PR_APPROVER_SHARING;
    Public static String purchaseOrderPRCatalogOwnerSharing = PURCHASE_ORDER_SHARING_RULE_PR_CATALOG_OWNER_SHARING;
    Public static String purchaseOrderPRProcurementSharing = PURCHASE_ORDER_SHARING_RULE_PR_PROCUREMENT_SHARING;
    Public static String purchaseOrderPRApplicantSharing  = PURCHASE_ORDER_SHARING_RULE_PR_APPLICANT_SHARING;
    Public static String purchaseOrderPRCopyToUserSharing  = PURCHASE_ORDER_SHARING_RULE_PR_MENTION_USER_SHARING;
    Public static String purchaseOrderPRRequestorSharing  = PURCHASE_ORDER_SHARING_RULE_PR_REQUESTOR_SHARING;
    Public static String purchaseOrderPRFinanceSharing = PURCHASE_ORDER_SHARING_RULE_PR_FINANCE_SHARING;

    
    public static final String PURCHASE_REQUEST_APPROVER_ACCESS_RIGHT = 'Read';
    public static final String PURCHASE_REQUEST_CATALOG_OWNER_ACCESS_RIGHT = 'Edit';
    public static final String PURCHASE_REQUEST_PROCUREMENT_ACCESS_RIGHT = 'Edit';
    public static final String PURCHASE_REQUEST_COPY_TO_USER_ACCESS_RIGHT  = 'Read';
    public static final String PURCHASE_REQUEST_APPLICANT_ACCESS_RIGHT  = 'Read';
    public static final String PURCHASE_REQUEST_FINANCE_ACCESS_RIGHT  = 'Read';


    public static final String PURCHASE_ORDER_APPROVER_ACCESS_RIGHT = 'Read';
    public static final String PURCHASE_ORDER_CATALOG_OWNER_ACCESS_RIGHT = 'Edit';
    public static final String PURCHASE_ORDER_PROCUREMENT_ACCESS_RIGHT = 'Edit';
    public static final String PURCHASE_ORDER_PR_COPY_TO_USER_ACCESS_RIGHT = 'Read';
    public static final String PURCHASE_ORDER_APPLICANT_ACCESS_RIGHT  = 'Read';
    public static final String PURCHASE_ORDER_REQUESTOR_ACCESS_RIGHT  = 'Read'; 
    public static final String PURCHASE_ORDER_FINANCE_ACCESS_RIGHT  = 'Read';   
    
    Public static String PROCUREMENT_GROUP_NAME = 'IDP_Procurement_@IDPPOLICY';
    Public static String LOCAL_PROCUREMENT_GROUP_NAME = 'IDP_Catalog_@IDPPOLICY';
    Public static String PROCUREMENT_GROUP_NAME_REPLACE_TARGET = '@IDPPOLICY';
    
    Public static String FINANCE_PROCURMENT_GROUP_NAME = 'IDP_Finance_@IDPPOLICY';
    
    /*@description Purchase Request Sharing*/
    public static void IDPPurchaseRequestSharing (Map<Id, Purchase_Request__c> purchaseRequestMap, Boolean removeAllSharing) {
        Set<ID> userIdSet = new Set<ID>();
        Set<ID> requestuserIdSet = null;
        Set<ID> requestgroupIdSet = null;
        Set<String> purchaseRequestProcurementQueueNameSet = null;
        Set<String> purchaseRequestFinanceQueueNameSet = null;
        Map <Id, Set<ID>> purchaseRequestApproverUserMapping = new Map <Id, Set<ID>>();
        Map <Id, Set<ID>> purchaseRequestCopyToUserMapping = new Map <Id, Set<ID>>();
        Map <Id, Set<ID>> purchaseRequestCatalogOwnerGroupMapping = new Map <Id, Set<ID>>();
        Map <Id, Set<String>> purchaseRequestProcurementGroupMapping = new Map <Id, Set<String>>();
        Map <Id, Set<String>> purchaseRequestFinanceGroupMapping = new Map <Id, Set<String>>();
        Map <String, Group> groupDeveloperNameGroupMap = new Map <String, Group>();
        Map <String, Group> financeGroupDeveloperNameGroupMap = new Map <String, Group>();
        Map <ID, user> activeUserMap = null;
        List <Purchase_Request__Share> purchaseRequestShareList = new List <Purchase_Request__Share>();
        List <Purchase_Request__Share> toBeDeletePurchaseRequestShareList = new List <Purchase_Request__Share>();
        Id userId = null;
        String procurementQueueName = '';
        
        for(Purchase_Request__c reader : purchaseRequestMap.values()){
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Actual_Approver_1__c);
            requestuserIdSet.add(reader.Actual_Approver_2__c);
            requestuserIdSet.add(reader.Actual_Approver_3__c);
            requestuserIdSet.add(reader.Actual_Approver_4__c); 
            
            if(reader.Tech_ROI_Approver__c != null) {
                requestuserIdSet.add(reader.Tech_ROI_Approver__c); 
            }
            if(reader.Tech_C_Level_Approver__c != null) {
                requestuserIdSet.add(reader.Tech_C_Level_Approver__c); 
            }
            
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            purchaseRequestApproverUserMapping.put(reader.Id, requestuserIdSet);
            
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Copy_to_1__c);
            requestuserIdSet.add(reader.Copy_to_2__c);
            requestuserIdSet.add(reader.Copy_to_3__c);
            requestuserIdSet.add(reader.Copy_to_4__c);
            requestuserIdSet.add(reader.Copy_to_5__c);
            requestuserIdSet.add(reader.Copy_to_6__c);
            requestuserIdSet.add(reader.Copy_to_7__c);
            requestuserIdSet.add(reader.Copy_to_8__c);
            requestuserIdSet.add(reader.Copy_to_9__c);
            requestuserIdSet.add(reader.Copy_to_10__c);
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            purchaseRequestCopyToUserMapping.put(reader.id, requestuserIdSet);            
            
            requestgroupIdSet = new Set<ID>();
            requestgroupIdSet.add(reader.Catalog__r.OwnerId);
            purchaseRequestCatalogOwnerGroupMapping.put(reader.Id, requestgroupIdSet);
            
            purchaseRequestProcurementQueueNameSet = new Set<String>();
            procurementQueueName = '';
            procurementQueueName = PROCUREMENT_GROUP_NAME.replace(PROCUREMENT_GROUP_NAME_REPLACE_TARGET, reader.IDP_Policy__r.Name);
            purchaseRequestProcurementQueueNameSet.add(procurementQueueName);
            if(reader.Assign_to_Local_Purchaser__c){
                procurementQueueName = '';
                procurementQueueName = LOCAL_PROCUREMENT_GROUP_NAME.replace(PROCUREMENT_GROUP_NAME_REPLACE_TARGET, reader.IDP_Policy__r.Name);
                purchaseRequestProcurementQueueNameSet.add(procurementQueueName);
            }
            purchaseRequestProcurementGroupMapping.put(reader.Id, purchaseRequestProcurementQueueNameSet);
            
            purchaseRequestFinanceQueueNameSet = new Set<String>();
            procurementQueueName = '';
            procurementQueueName = FINANCE_PROCURMENT_GROUP_NAME.replace(PROCUREMENT_GROUP_NAME_REPLACE_TARGET, reader.IDP_Policy__r.Name);
            purchaseRequestFinanceQueueNameSet.add(procurementQueueName);
            purchaseRequestFinanceGroupMapping.put(reader.Id, purchaseRequestFinanceQueueNameSet);
            
            
            if(reader.On_Behalf_of__r.Employee__r.User__c != reader.ownerId){
                userIdSet.add(reader.On_Behalf_of__r.Employee__r.User__c);
            }        
        }
        
        for(Group reader : [SELECT Id, DeveloperName, Name FROM Group WHERE DeveloperName in :purchaseRequestProcurementQueueNameSet]) {
            groupDeveloperNameGroupMap.put(reader.DeveloperName, reader);
        }

        for(Group reader : [SELECT Id, DeveloperName, Name FROM Group WHERE DeveloperName in :purchaseRequestFinanceQueueNameSet]) {
            financeGroupDeveloperNameGroupMap.put(reader.DeveloperName, reader);
        }
        
        if (removeAllSharing){
            for(Purchase_Request__Share reader :[select id from Purchase_Request__Share where ParentId in :purchaseRequestApproverUserMapping.KeySet() and RowCause in (:purchaseRequestApproverSharing, :purchaseRequestCatalogOwnerSharing, :purchaseRequestProcurementSharing, :purchaseRequestApplicantSharing, :purchaseRequestCopyToUserSharing )]){
                toBeDeletePurchaseRequestShareList.add(reader);
            }
        }
                            
        activeUserMap = activeUsers(userIdSet);   
        purchaseRequestApproverUserMapping = requesetActiveUserMap (purchaseRequestApproverUserMapping, activeUserMap);
        purchaseRequestCopyToUserMapping = requesetActiveUserMap (purchaseRequestCopyToUserMapping, activeUserMap);
            
        for(Id requestId : purchaseRequestProcurementGroupMapping.keySet()){
            if(purchaseRequestMap.containsKey(requestId)) {
                if(purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION ||
                   purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL ||
                   purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED) {
                    if(!purchaseRequestMap.get(requestId).IDP_Policy__r.Is_Group_Procurement__c) {
                        for(String groupDeveloperName : purchaseRequestProcurementGroupMapping.get(requestId)){
                            if(groupDeveloperNameGroupMap.containsKey(groupDeveloperName)) {
                                purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = groupDeveloperNameGroupMap.get(groupDeveloperName).Id, AccessLevel = PURCHASE_REQUEST_PROCUREMENT_ACCESS_RIGHT, RowCause = purchaseRequestProcurementSharing));
                            }
                        }
                    }
                }
           }
        }
        for(Id requestId : purchaseRequestFinanceGroupMapping.keySet()){
            if(purchaseRequestMap.containsKey(requestId)) {
                if(purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED) {
                    for(String groupDeveloperName : purchaseRequestFinanceGroupMapping.get(requestId)){
                        if(financeGroupDeveloperNameGroupMap.containsKey(groupDeveloperName)) {
                            purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = financeGroupDeveloperNameGroupMap.get(groupDeveloperName).Id, AccessLevel = PURCHASE_REQUEST_FINANCE_ACCESS_RIGHT, RowCause = purchaseRequestFinanceSharing));
                        }
                    }
                }
           }
        }

        for(Id requestId : purchaseRequestCatalogOwnerGroupMapping.keySet()){
            if(purchaseRequestMap.containsKey(requestId)) {
                //if(purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION) {
                    if(purchaseRequestMap.get(requestId).IDP_Policy__r.Is_Group_Procurement__c) {
                        for(Id groupId : purchaseRequestCatalogOwnerGroupMapping.get(requestId)){
                            purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = groupId, AccessLevel = PURCHASE_REQUEST_PROCUREMENT_ACCESS_RIGHT, RowCause = purchaseRequestProcurementSharing));
                        }
                    }
                //}
                //else if(purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL ) {
                    if(!purchaseRequestMap.get(requestId).IDP_Policy__r.Is_Group_Procurement__c) {
                        for(Id groupId : purchaseRequestCatalogOwnerGroupMapping.get(requestId)){
                            purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = groupId, AccessLevel = PURCHASE_REQUEST_CATALOG_OWNER_ACCESS_RIGHT, RowCause = purchaseRequestCatalogOwnerSharing));
                        }
                    } 
                //}
            }
        }        
        
        for(Id requestId : purchaseRequestApproverUserMapping.keySet()){
            if(purchaseRequestMap.containsKey(requestId)) {
                if(purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL ||
                   purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED) {
                    for(Id activeuserId : purchaseRequestApproverUserMapping.get(requestId)){
                        purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = PURCHASE_REQUEST_APPROVER_ACCESS_RIGHT, RowCause = purchaseRequestApproverSharing));
                    }
                }
            }
        }

        for(Id requestId : purchaseRequestCopyToUserMapping.keySet()){
            for(Id activeuserId : purchaseRequestCopyToUserMapping.get(requestId)){
                purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = PURCHASE_REQUEST_COPY_TO_USER_ACCESS_RIGHT, RowCause = purchaseRequestCopyToUserSharing));
            }
        }
        
        for(Purchase_Request__c reader : purchaseRequestMap.values()){
            if(reader.On_Behalf_of__r.Employee__r.User__c != null && activeUserMap.containsKey(reader.On_Behalf_of__r.Employee__r.User__c)){
                purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = reader.id, UserOrGroupId = reader.On_Behalf_of__r.Employee__r.User__c, AccessLevel = PURCHASE_REQUEST_APPLICANT_ACCESS_RIGHT  , RowCause = purchaseRequestApplicantSharing ));
            }
        }
                
        if (!toBeDeletePurchaseRequestShareList.isEmpty()){
            delete toBeDeletePurchaseRequestShareList;
        }
        if (!purchaseRequestShareList.isEmpty()){
            insert purchaseRequestShareList;
        }                                                      
    }
    
    /*@description Purchase Order Sharing*/
    public static void IDPPurchaseOrderSharing (Map<Id, Purchase_Order__c> purchaseOrderMap, Boolean removeAllSharing) {
        
        Map<Id, Purchase_Order_item__c> poiMap = new Map<Id, Purchase_Order_item__c>();
        Map<Id, Set<Id>> prIdPOIdSetMap = new Map<Id, Set<Id>> ();
        Map<String, String> prpoSharingRuleMap = new Map<String, String> ();
        Map<String, String> poSharingRuleAccessRightMap = new Map<String, String> ();
        List <Purchase_Order__Share> purchaseOrderShareList = new List <Purchase_Order__Share>();
        List <Purchase_Order__Share> toBeDeletePurchaseOrderShareList = new List <Purchase_Order__Share> ();
        Set<Id> tempPOIdSet = null;
        String tempParentId = null;
        String tempUserOrGroupId = null;
        String tempAccessLevel = null;
        String tempRowcause = null;
        
        prpoSharingRuleMap.put(purchaseRequestApproverSharing, purchaseOrderPRApproverSharing);
        prpoSharingRuleMap.put(purchaseRequestCatalogOwnerSharing, purchaseOrderPRCatalogOwnerSharing);
        prpoSharingRuleMap.put(purchaseRequestProcurementSharing, purchaseOrderPRProcurementSharing);
        prpoSharingRuleMap.put(purchaseRequestCopyToUserSharing, purchaseOrderPRCopyToUserSharing);
        prpoSharingRuleMap.put(purchaseRequestApplicantSharing, purchaseOrderPRApplicantSharing );
        prpoSharingRuleMap.put(purchaseRequestRequestorSharing, purchaseOrderPRRequestorSharing );
        prpoSharingRuleMap.put(purchaseRequestFinanceSharing, purchaseOrderPRFinanceSharing );
        
        poSharingRuleAccessRightMap.put(purchaseOrderPRApproverSharing, PURCHASE_ORDER_APPROVER_ACCESS_RIGHT);
        poSharingRuleAccessRightMap.put(purchaseOrderPRCatalogOwnerSharing, PURCHASE_ORDER_CATALOG_OWNER_ACCESS_RIGHT);
        poSharingRuleAccessRightMap.put(purchaseOrderPRProcurementSharing, PURCHASE_ORDER_PROCUREMENT_ACCESS_RIGHT);
        poSharingRuleAccessRightMap.put(purchaseOrderPRCopyToUserSharing, PURCHASE_ORDER_PR_COPY_TO_USER_ACCESS_RIGHT);
        poSharingRuleAccessRightMap.put(purchaseOrderPRApplicantSharing, PURCHASE_ORDER_APPLICANT_ACCESS_RIGHT);
        poSharingRuleAccessRightMap.put(purchaseOrderPRRequestorSharing, PURCHASE_ORDER_REQUESTOR_ACCESS_RIGHT);
        poSharingRuleAccessRightMap.put(purchaseOrderPRFinanceSharing, PURCHASE_ORDER_FINANCE_ACCESS_RIGHT);

        if (removeAllSharing){
            for(Purchase_Order__Share reader :[select id from Purchase_Order__Share where ParentId in :purchaseOrderMap.KeySet() and RowCause in (:purchaseOrderPRApproverSharing, :purchaseOrderPRCatalogOwnerSharing, :purchaseOrderPRProcurementSharing, :purchaseOrderPRApplicantSharing, :purchaseOrderPRRequestorSharing, :purchaseOrderPRCopyToUserSharing, :purchaseOrderPRFinanceSharing)]){
                toBeDeletePurchaseOrderShareList.add(reader);
            }
        }              
        
        /*
        for(Purchase_Order_Item__c reader : [SELECT Id, Purchase_Order__c 
                                                FROM Purchase_Order_Item__c 
                                                where Purchase_Order__c in :purchaseOrderMap.keySet()]) {
            poiMap.put(reader.Id, reader);
        }
        */
        
        for(Purchase_Request_Item__c reader : [SELECT Id, Purchase_Request__c, Purchase_Order__c 
                                                FROM Purchase_Request_Item__c 
                                                WHERE Purchase_Order__c in :purchaseOrderMap.keySet()]) {
            tempPOIdSet = new Set<Id> ();
            if(prIdPOIdSetMap.containsKey(reader.Purchase_Request__c)) {
                tempPOIdSet = prIdPOIdSetMap.get(reader.Purchase_Request__c);
            }
            
            tempPOIdSet.add(reader.Purchase_Order__c);
            prIdPOIdSetMap.put(reader.Purchase_Request__c,tempPOIdSet);
        }
        
        for(Purchase_Request__Share reader : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause 
                                                FROM Purchase_Request__Share
                                                WHERE ParentId in :prIdPOIdSetMap.keySet()
                                                AND RowCause in (:purchaseRequestApproverSharing, :purchaseRequestCatalogOwnerSharing, :purchaseRequestProcurementSharing, :purchaseRequestApplicantSharing, :purchaseRequestRequestorSharing, :purchaseRequestCopyToUserSharing, :purchaseRequestFinanceSharing)]) {
            for(String poId : prIdPOIdSetMap.get(reader.ParentId)) {
            
                tempParentId = poId;
                tempUserOrGroupId = reader.UserOrGroupId;
                tempRowcause = prpoSharingRuleMap.get(reader.RowCause);
                tempAccessLevel = poSharingRuleAccessRightMap.get(tempRowcause);
                
                purchaseOrderShareList.add(new Purchase_Order__Share(ParentId = tempParentId, UserOrGroupId = tempUserOrGroupId, RowCause = tempRowcause, AccessLevel = tempAccessLevel));
            
            }
        }
                
        if (!toBeDeletePurchaseOrderShareList.isEmpty()){
            delete toBeDeletePurchaseOrderShareList ;
        }  
        
        if(!purchaseOrderShareList.isEmpty()) {
            insert purchaseOrderShareList;
        }
        
        
        /*
        Set<ID> userIdSet = new Set<ID>();
        Set<ID> requestuserIdSet = null;
        Set<ID> requestgroupIdSet = null;
        Set<String> purchaseRequestProcurementQueueNameSet = null;
        Map <Id, Set<ID>> purchaseRequestApproverUserMapping = new Map <Id, Set<ID>>();
        Map <Id, Set<ID>> purchaseRequestCatalogOwnerGroupMapping = new Map <Id, Set<ID>>();
        Map <Id, Set<String>> purchaseRequestProcurementGroupMapping = new Map <Id, Set<String>>();
        Map <String, Group> groupDeveloperNameGroupMap = new Map <String, Group>();
        Map <ID, user> activeUserMap = null;
        List <Purchase_Request__Share> purchaseRequestShareList = new List <Purchase_Request__Share>();
        List <Purchase_Request__Share> toBeDeletePurchaseRequestShareList = new List <Purchase_Request__Share>();
        Id userId = null;
        String procurementQueueName = '';
        
        for(Purchase_Request__c reader : purchaseRequestMap.values()){
            requestuserIdSet = new Set<ID>();
            requestuserIdSet.add(reader.Actual_Approver_1__c);
            requestuserIdSet.add(reader.Actual_Approver_2__c);
            requestuserIdSet.add(reader.Actual_Approver_3__c);
            requestuserIdSet.add(reader.Actual_Approver_4__c); 
            
            if(reader.Tech_ROI_Approver__c != null) {
                requestuserIdSet.add(reader.Tech_ROI_Approver__c); 
            }
            if(reader.Tech_C_Level_Approver__c != null) {
                requestuserIdSet.add(reader.Tech_C_Level_Approver__c); 
            }
            
            for(Id usrId : requestuserIdSet){
                userIdSet.add(usrId);
            }
            purchaseRequestApproverUserMapping.put(reader.Id, requestuserIdSet);
            
            requestgroupIdSet = new Set<ID>();
            requestgroupIdSet.add(reader.Catalog__r.OwnerId);
            purchaseRequestCatalogOwnerGroupMapping.put(reader.Id, requestgroupIdSet);
            
            purchaseRequestProcurementQueueNameSet = new Set<String>();
            procurementQueueName = '';
            procurementQueueName = PROCUREMENT_GROUP_NAME.replace(PROCUREMENT_GROUP_NAME_REPLACE_TARGET, reader.IDP_Policy__r.Name);
            purchaseRequestProcurementQueueNameSet.add(procurementQueueName);
            purchaseRequestProcurementGroupMapping.put(reader.Id, purchaseRequestProcurementQueueNameSet);
            
            if(reader.On_Behalf_of__r.Employee__r.User__c != reader.ownerId){
                userIdSet.add(reader.On_Behalf_of__r.Employee__r.User__c);
            }        
        }
        
        for(Group reader : [SELECT Id, DeveloperName, Name FROM Group WHERE DeveloperName in :purchaseRequestProcurementQueueNameSet]) {
            groupDeveloperNameGroupMap.put(reader.DeveloperName, reader);
        }
        
        if (removeAllSharing){
            for(Purchase_Request__Share reader :[select id from Purchase_Request__Share where ParentId in :purchaseRequestApproverUserMapping.KeySet() and RowCause in (:purchaseRequestApproverSharing, :purchaseRequestCatalogOwnerSharing, :purchaseRequestProcurementSharing, :purchaseRequestApplicantSharing  )]){
                toBeDeletePurchaseRequestShareList.add(reader);
            }
        }
                            
        activeUserMap = activeUsers(userIdSet);   
        purchaseRequestApproverUserMapping = requesetActiveUserMap (purchaseRequestApproverUserMapping, activeUserMap);

            
        for(Id requestId : purchaseRequestProcurementGroupMapping.keySet()){
            if(purchaseRequestMap.containsKey(requestId)) {
                if(purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION ||
                   purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL) {
                    if(!purchaseRequestMap.get(requestId).IDP_Policy__r.Is_Group_Procurement__c) {
                        for(String groupDeveloperName : purchaseRequestProcurementGroupMapping.get(requestId)){
                            if(groupDeveloperNameGroupMap.containsKey(groupDeveloperName)) {
                                purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = groupDeveloperNameGroupMap.get(groupDeveloperName).Id, AccessLevel = PURCHASE_REQUEST_PROCUREMENT_ACCESS_RIGHT, RowCause = purchaseRequestProcurementSharing));
                            }
                        }
                    }
                }
           }
        }
    
        for(Id requestId : purchaseRequestCatalogOwnerGroupMapping.keySet()){
            if(purchaseRequestMap.containsKey(requestId)) {
                if(purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION) {
                    if(purchaseRequestMap.get(requestId).IDP_Policy__r.Is_Group_Procurement__c) {
                        for(Id groupId : purchaseRequestCatalogOwnerGroupMapping.get(requestId)){
                            purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = groupId, AccessLevel = PURCHASE_REQUEST_CATALOG_OWNER_ACCESS_RIGHT, RowCause = purchaseRequestCatalogOwnerSharing));
                        }
                    }
                }
                else if(purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL ) {
                    for(Id groupId : purchaseRequestCatalogOwnerGroupMapping.get(requestId)){
                        purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = groupId, AccessLevel = PURCHASE_REQUEST_CATALOG_OWNER_ACCESS_RIGHT, RowCause = purchaseRequestCatalogOwnerSharing));
                    }                    
                }
            }
        }        
        
        for(Id requestId : purchaseRequestApproverUserMapping.keySet()){
            if(purchaseRequestMap.containsKey(requestId)) {
                if(purchaseRequestMap.get(requestId).Status__c == IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL ) {
                    for(Id activeuserId : purchaseRequestApproverUserMapping.get(requestId)){
                        purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = requestId, UserOrGroupId = activeuserId, AccessLevel = PURCHASE_REQUEST_APPROVER_ACCESS_RIGHT, RowCause = purchaseRequestApproverSharing));
                    }
                }
            }
        }
        
        for(Purchase_Request__c reader : purchaseRequestMap.values()){
            if(reader.On_Behalf_of__r.Employee__r.User__c != null && activeUserMap.containsKey(reader.On_Behalf_of__r.Employee__r.User__c)){
                purchaseRequestShareList.add(new Purchase_Request__Share(ParentId = reader.id, UserOrGroupId = reader.On_Behalf_of__r.Employee__r.User__c, AccessLevel = PURCHASE_REQUEST_APPLICANT_ACCESS_RIGHT  , RowCause = purchaseRequestApplicantSharing ));
            }
        }
                
        if (!toBeDeletePurchaseRequestShareList.isEmpty()){
            delete toBeDeletePurchaseRequestShareList;
        }
        if (!purchaseRequestShareList.isEmpty()){
            insert purchaseRequestShareList;
        }    
        
        */                                                  
    }
        
    /*@description To Return Request active users*/
    private static Map <Id, Set<Id>> requesetActiveUserMap (Map<Id, Set<Id>> requestUserMapping, Map <Id, user> activeUserMap){
        Map<Id, Set<Id>> requestActiveUsersMap = new Map<Id, Set<Id>>();
        Set<Id> userIdSet = null;

        for (Id key : requestUserMapping.keyset()){
            userIdSet = new Set<Id>();
            for (Id userId : requestUserMapping.get(key)){
                if(activeUserMap.containsKey(userId)){
                    userIdSet.add(userId);
                }
            }
            if (!userIdSet.isempty()){
                requestActiveUsersMap.put(key, userIdSet);
            }
        }
        return requestActiveUsersMap;
    }
    
    
    /*@description To Return active users*/
    private static Map <ID, user> activeUsers (Set<ID> userIdSet){
        return new Map <ID, user>([select id from user where id in :userIdSet and isactive = true]);
    }
}