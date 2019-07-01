/*
    
    This is the Common Methods used across the IDP project-specific classes
    
    Created By:     Robert Andrew Almedina
    Date Created:   August 22, 2016
    
    * Version   Author                  |   Date            |       Description
    
    * ----------------------------------------------------------------------
    
    * V1.0  |   Robert Andrew Almedina  |   2016-08-22      |       New created
    ------------------------------------------------------------------------

    * V1.1  |   Ted Pang                |   2016-08-26      |       New method:findPurchaseRequestToApproveList 
    ------------------------------------------------------------------------

    * V1.2  |   Ted Pang                |   2016-08-29      |       New method:findPurchaseOrderList, findRecentPurchaseRequestList
    ------------------------------------------------------------------------

    * V1.3  |   Ted Pang                |   2016-08-29      |       Update method:findPurchaseRequestToApproveList ,findPurchaseOrderList, findRecentPurchaseRequestList

    The records are updated to from 'ORDER BY LastModifiedDate DESC' to 'ORDER BY LastModifiedDate DESC, Name ASC'
    ------------------------------------------------------------------------

    * V1.4  |   Ted Pang                |   2016-09-12      |      New method: loadSortingSelectOptionList
    ------------------------------------------------------------------------    
    
    * V1.5  |   Ted Pang                |   2016-09-14      |      New method: loadDisplayCurrencySelectOptionList, loadExchangeRateMap
    ------------------------------------------------------------------------   

    * V1.6  |   Ted Pang                |   2016-10-04      |      New method: singleAddRemoveFavouriteItem, massAction
    ------------------------------------------------------------------------       
    
    * V1.7  |   Ted Pang                |   2016-10-05      |      Update method: loadSortingSelectOptionList, loadDisplayCurrencySelectOptionList
    ------------------------------------------------------------------------       
    
    * V1.8  |   Ted Pang                |   2016-10-05      |      Update method: createCatalogItemPermissions,loadExchangeRateMap 
    
    createCatalogItemPermissions: update the unique to be the catalog's Name field (Reference No.)
    loadExchangeRateMap: filter out the null in CatalogIdSet
    ------------------------------------------------------------------------        
    * V1.9  |   Ted Pang                |   2016-10-13      |      New method: loadPhotoNameUrlMap 
    ------------------------------------------------------------------------        
    * V2.0  |   Ted Pang                |   2016-10-17      |      Update method: loadPhotoNameUrlMap    
    
    loadPhotoNameUrlMap: 
    1. loadPhotoNameUrlMap is renamed to loadPhotoUrlMap
    2. use Photo_Doc_Id__c instead of Photo_Name__c to skip the SOQL
    ------------------------------------------------------------------------               
    * V2.1  |   Ted Pang                |   2016-10-18      |      new method: loadCatalogItemIdUOMSelectOptionMap,
                                                                   update method: singleAddtoCart, massAction

    singleAddtoCart, massAction:
    existingShoppingCartItemMap's key is changed to Catalog_Item__c + Shopping Cart Item Unit_Of_Measure__c
    ------------------------------------------------------------------------    
    * V2.2  |   Robert Andrew Almedina  |   2016-11-02      |      new method: getUserCatalogs

    singleAddtoCart, massAction:
    existingShoppingCartItemMap's key is changed to Catalog_Item__c + Shopping Cart Item Unit_Of_Measure__c
    ------------------------------------------------------------------------                          
    
*/
public without sharing class IDPCommonUtils {
    
    //Salesforce standard pending status for ProcessInstance Object
    public static final String PENDING_STATUS = 'Pending';
    
    public static final Integer NUMBER_OF_QUERRY_RECORDS  = 10000;


// ==============================================================================================================================================================

    /*
        Returns a map of userId and Catalog Ids of Catalogs Owned by the Queues where the Public Groups the user is a member of are members. Map<UserId, Set<CatalogIds>>
        It does not return Catalogs owned by Queues where the user is directly a member of.
        It still returns a empty set even if a user is not in any queues
        
        @userIdSet      - the SF Id set of the users you want to get the list of items accessible
        @catalogIdSet   - the SF Id set of the Catalog__c records that the catalog items should belong to, if null, returns all Catalog_Item__c records with access by the users
    */
    public static Map<Id, Set<Id>>  getUserCatalogs (Set<Id> userIdSet){
        
        if (userIdSet==null || userIdSet.size()==0) return null;
        
        // get all public groups that the user Ids belong to
        Map<Id, Set<Id>> userIdGroupIdSetMap = new Map<Id, Set<Id>>();
        Set<Id> publicGrpIdSet = new Set<Id>();
        for (GroupMember gm : [ Select UserOrGroupId, GroupId 
                                From GroupMember
                                where UserOrGroupId IN : userIdSet]){
            Set<Id> tempPublicGrpIdSet = new Set<Id>();
            //if (userIdGroupIdSetMap.containsKey(gm.GroupId)){
                //tempPublicGrpIdSet = userIdGroupIdSetMap.get(gm.GroupId);
            if (userIdGroupIdSetMap.containsKey(gm.UserOrGroupId)){
                tempPublicGrpIdSet = userIdGroupIdSetMap.get(gm.UserOrGroupId);
                tempPublicGrpIdSet.add(gm.GroupId);
                
            }else{
                tempPublicGrpIdSet.add(gm.GroupId);
            }
            publicGrpIdSet.add(gm.GroupId);
            userIdGroupIdSetMap.put(gm.UserOrGroupId, tempPublicGrpIdSet);

        }
        system.debug('userIdGroupIdSetMap: ' + userIdGroupIdSetMap); 
        

        
        // get all Queues the public groups belong to
        Map<Id, Set<Id>> groupIdQueueIdSetMap = new Map<Id, Set<Id>>();
        Set<Id> queueIdSet = new Set<Id>();
        for (GroupMember gm : [ Select UserOrGroupId, GroupId 
                                From GroupMember
                                where UserOrGroupId IN : publicGrpIdSet]){
            Set<Id> tempQueueIdSet = new Set<Id>();
            if (groupIdQueueIdSetMap.containsKey(gm.UserOrGroupId)){
                tempQueueIdSet = groupIdQueueIdSetMap.get(gm.UserOrGroupId);
                tempQueueIdSet.add(gm.GroupId);
                
            }else{
                tempQueueIdSet.add(gm.GroupId);
            }
            queueIdSet.add(gm.GroupId);

            groupIdQueueIdSetMap.put(gm.UserOrGroupId, tempQueueIdSet);
            system.debug('tempQueueIdSet: ' + tempQueueIdSet);    
            system.debug('groupIdQueueIdSetMap: ' + groupIdQueueIdSetMap.get(gm.UserOrGroupId));    
        }
        system.debug('groupIdQueueIdSetMap: ' + groupIdQueueIdSetMap);    

        // loop the public group and the queue to create the User ID and QueueId Map
        Map<Id, Set<Id>> userIdQueueIdSetMap = new Map<Id, Set<Id>>();
        for (Id userId : userIdSet){
            if (userIdGroupIdSetMap.containsKey(userId)){
                // loop to get the public group id where the current user in loop is a member of
                
                for (Id grpId : userIdGroupIdSetMap.get(userId)){
                    if (groupIdQueueIdSetMap.containsKey(grpId)){
                        // loop to get the queue id where the current pubic group is a member of
                        for (Id queueId : groupIdQueueIdSetMap.get(grpId)){
                            Set<Id> tempQueueIdSet = new Set<Id>();
                            if (userIdQueueIdSetMap.containsKey(userId)){
                                tempQueueIdSet = userIdQueueIdSetMap.get(userId);
                                tempQueueIdSet.add(queueId);
                                
                            }else{
                                tempQueueIdSet.add(queueId);
                            }
                            userIdQueueIdSetMap.put(userId, tempQueueIdSet);
                            
                        }
                    }
                }
            }
        }
        // get all Catalogs owned by the queueIds (queueIdSet)
        Map<Id, Set<Id>> queueIdCatalogIdSetMap = new Map<Id, Set<Id>>();
        for (Catalog__c cat : [select Id, OwnerId from Catalog__c where OwnerId IN :queueIdSet]){
            Set<Id> tempCatalogIdSet = new Set<Id>();
            if (queueIdCatalogIdSetMap.containsKey(cat.OwnerId)){
                tempCatalogIdSet = queueIdCatalogIdSetMap.get(cat.OwnerId);
                tempCatalogIdSet.add(cat.Id);
                
            }else{
                tempCatalogIdSet.add(cat.Id);
            }
            queueIdCatalogIdSetMap.put(cat.OwnerId, tempCatalogIdSet);
        }
        
        // loop all queue related to the user and get all catalogs owned by that queue and put in a map with the user id as the key
        Map<Id, Set<Id>> userIdCatalogIdSetMap = new Map<Id, Set<Id>>();
        for (Id userId : userIdSet){
            if (userIdQueueIdSetMap.containsKey(userId)){
                for (Id queueId : userIdQueueIdSetMap.get(userId)){
                    if (queueIdCatalogIdSetMap.containsKey(queueId)){
                        
                            Set<Id> tempCatalogIdSet = new Set<Id>();
                            if (userIdCatalogIdSetMap.containsKey(userId)){
                                tempCatalogIdSet = userIdCatalogIdSetMap.get(userId);
                                tempCatalogIdSet.addAll(queueIdCatalogIdSetMap.get(queueId));
                            }else{
                                tempCatalogIdSet.addAll(queueIdCatalogIdSetMap.get(queueId));
                            }
                            userIdCatalogIdSetMap.put(userId, tempCatalogIdSet);
                    }
                }
            }
        }
        
        return userIdCatalogIdSetMap;
    }


// ==============================================================================================================================================================

    /*
        Returns a map of userId and catalog items. Map<UserId, Map<CatalogItemPermissionId, Catalog Item>>
        
        @userIdSet      - the SF Id set of the users you want to get the list of items accessible
        @catalogIdSet   - the SF Id set of the Catalog__c records that the catalog items should belong to, if null, returns all Catalog_Item__c records with access by the users
    */
    public static Map<Id, Map<Id, Catalog_Item_Permission__c>>  getUserCatalogItems (Set<Id> userIdSet, Set<Id> catalogIdSet){
        
        if (userIdSet==null || userIdSet.size()==0) return null;
        
        List<Catalog_Item_Permission__c> ciPermissionList = new List<Catalog_Item_Permission__c>();
        
        // add some related field query here as needed for the Catalog_Item__c
        // use Catalog_Item__r.xxxx
        
        if (catalogIdSet==null){
            ciPermissionList = [select Id, Catalog__c, Catalog_Item__c, Department__c, isCatalogItemLevel__c, 
                                    User__c, isCatalogLevel__c, isDepartmentLevel__c//, isUserLevel__c, Unique_Key__c
                                from Catalog_Item_Permission__c
                                where User__c IN :userIdSet
                                Order by User__c];
        }else{
            ciPermissionList = [select Id, Catalog__c, Catalog_Item__c, Department__c, isCatalogItemLevel__c, 
                                    User__c, isCatalogLevel__c, isDepartmentLevel__c//, isUserLevel__c, Unique_Key__c
                                from Catalog_Item_Permission__c
                                where User__c IN :userIdSet AND (Catalog__c IN :catalogIdSet OR Catalog__r.Parent_Catalog__c IN :catalogIdSet)
                                Order by User__c];
        }
        
        
        Map<Id, Map<Id, Catalog_Item_Permission__c>> userIdCatItemMapMap = new Map<Id, Map<Id, Catalog_Item_Permission__c>>();
        Map<Id, Catalog_Item_Permission__c> tempCatItemIdCatItemMap = new Map<Id, Catalog_Item_Permission__c>();
        
        for (Catalog_Item_Permission__c cip : ciPermissionList){
            
            tempCatItemIdCatItemMap.clear();
            
            if (cip.User__c!=null){
                if (userIdCatItemMapMap.containsKey(cip.User__c)){
                    userIdCatItemMapMap.get(cip.User__c).put(cip.Catalog_Item__c, cip);
                }else{
                    
                    tempCatItemIdCatItemMap.put(cip.Catalog_Item__c, cip);
                    
                    userIdCatItemMapMap.put(cip.User__c, tempCatItemIdCatItemMap);
                }
            }
            
        }
        
        return userIdCatItemMapMap;
    }

// ==============================================================================================================================================================

    /*
        Returns a true if the userId has access to the Catalog__c record, otherwise, returns false
        
        @userId     - the SF Id of the user trying to get view the catalog__c record
        @catalogId  - the SF Id of the Catalog__c record that the user want to access
    */
//    public static Boolean isUserAllowedToViewCatalog (Id pUserId, Id pCatalogId){
    //outdated-----------------------------------------------------------------
/*
    public static List<Catalog_Item_Permission__c> getUserCatalogItemPermission (Id pUserId, Id pCatalogId){
               
        List<Employee__c> employeeList = new List<Employee__c>();
        List<Catalog_Item_Permission__c> ciPermissionList = new List<Catalog_Item_Permission__c>();
        List<Catalog__c> selectedCatalogList = new List<Catalog__c> ();
        Set<String> levelOneTwoCatalogIdSet = new Set<String>();

//        if (pUserId==null || pCatalogId==null )   return false;
        if (pUserId==null || pCatalogId==null )   return new List<Catalog_Item_Permission__c>(); 
                   
        employeeList = [SELECT IDP_Policy__c, IDP_Policy__r.Name, IDP_Policy__r.Currency__c,IDP_Policy__r.Currency__r.Name, Tech_Policy_Function_Department__c FROM Employee__c WHERE User__c = :pUserId LIMIT 1]; 

        String tempTechUniqueFunctionDepartmentKey = employeeList.get(0).Tech_Policy_Function_Department__c.split('_').get(1) + '_' + employeeList.get(0).Tech_Policy_Function_Department__c.split('_').get(2);

        selectedCatalogList = [SELECT Id, Parent_Catalog__c FROM Catalog__c WHERE Id =: pCatalogId];
        if(selectedCatalogList.size() > 0) {
            if(selectedCatalogList.get(0).Parent_Catalog__c != null) {
                levelOneTwoCatalogIdSet.add(selectedCatalogList.get(0).Parent_Catalog__c);
            }
            levelOneTwoCatalogIdSet.add(selectedCatalogList.get(0).Id);
        }
        else {
//            return false;
            return new List<Catalog_Item_Permission__c>();
        }

        ciPermissionList = [SELECT Catalog__c, Catalog__r.Catalog_Name__c,
                                Catalog__r.Parent_Catalog__c, Catalog__r.Parent_Catalog__r.Catalog_Name__c,
                                Catalog_item__c, Catalog_item__r.Catalog__c, Catalog_item__r.Catalog__r.Catalog_Name__c,
                                Catalog_item__r.Catalog__r.Parent_Catalog__c, Catalog_item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c,
                                 
                                IsDepartmentLevel__c,IsUserLevel__c , IsCatalogLevel__c,IsCatalogItemLevel__c   
                            FROM Catalog_Item_Permission__c 
                            WHERE 
                                (IsDepartmentLevel__c = true
                                AND IsCatalogLevel__c = true
                                AND Function_Department__c = :tempTechUniqueFunctionDepartmentKey
                                AND (
                                    Catalog__c in :levelOneTwoCatalogIdSet
                                    OR Catalog__r.Parent_Catalog__c in :levelOneTwoCatalogIdSet)
                                )
                            OR
                                
                                (IsUserLevel__c = true
                                AND IsCatalogLevel__c = true
                                AND User__c = :pUserId
                                AND (
                                    Catalog__c in :levelOneTwoCatalogIdSet
                                    OR Catalog__r.Parent_Catalog__c in :levelOneTwoCatalogIdSet)
                                )                            
                            OR 
                                (IsUserLevel__c = true
                                AND IsCatalogItemLevel__c = true
                                AND User__c = :pUserId 
                                AND (
                                    Catalog_item__r.Catalog__c = :levelOneTwoCatalogIdSet
                                    OR Catalog_item__r.Catalog__r.Parent_Catalog__c in :levelOneTwoCatalogIdSet)
                                )
                                ];


//        if (ciPermissionList.size()>0)  return true;
//        else                            return false;
        if (ciPermissionList.size()>0)  return ciPermissionList;
        else                            return new List<Catalog_Item_Permission__c>();
               
    }
*/

   //used in IDPAjaxDataTableCtrl
   public static List<Catalog_Item_Permission__c> getUserAllPermission (Id pUserId){
        List<Employee__c> employeeList = new List<Employee__c>();
        List<Catalog_Item_Permission__c> ciPermissionList = new List<Catalog_Item_Permission__c>();
        List<Catalog__c> selectedCatalogList = new List<Catalog__c> ();
        Set<String> levelOneTwoCatalogIdSet = new Set<String>();

        if (pUserId==null)   return new List<Catalog_Item_Permission__c>(); 
        /*IDP_Policy__r.Currency__c,IDP_Policy__r.Currency__r.Name, */
        employeeList = [SELECT Id, User__c, IDP_Policy__c, IDP_Policy__r.Name,  Tech_IDP_Policy_Function_Department__c FROM Employee__c WHERE User__c = :pUserId LIMIT 1]; 

        //String tempTechUniqueFunctionDepartmentKey = employeeList.get(0).Tech_Policy_Function_Department__c.split('_').get(1) + '_' + employeeList.get(0).Tech_Policy_Function_Department__c.split('_').get(2);

         
        ciPermissionList = [SELECT Catalog__c, Catalog__r.Catalog_Name__c,
                                Catalog__r.Parent_Catalog__c, Catalog__r.Parent_Catalog__r.Catalog_Name__c,
                                Catalog_item__c, Catalog_item__r.Catalog__c, Catalog_item__r.Catalog__r.Catalog_Name__c,
                                Catalog_item__r.Catalog__r.Parent_Catalog__c, Catalog_item__r.Catalog__r.Parent_Catalog__r.Catalog_Name__c,
                                IsDepartmentLevel__c,IsUserLevel__c , IsCatalogLevel__c,IsCatalogItemLevel__c   
                            FROM Catalog_Item_Permission__c 
                            WHERE 
                                (IsDepartmentLevel__c = true
                                AND IsCatalogLevel__c = true
                                //AND Function_Department__c = :tempTechUniqueFunctionDepartmentKey
                                AND Unique_Key__c like :employeeList.get(0).Tech_IDP_Policy_Function_Department__c + '%'
/*                                AND (
                                    Catalog__c in :levelOneTwoCatalogIdSet
                                    OR Catalog__r.Parent_Catalog__c in :levelOneTwoCatalogIdSet)
*/                                )
                            OR
                                
                                (IsUserLevel__c = true
                                AND IsCatalogLevel__c = true
                                AND User__c = :pUserId
/*                                AND (
                                    Catalog__c in :levelOneTwoCatalogIdSet
                                    OR Catalog__r.Parent_Catalog__c in :levelOneTwoCatalogIdSet)
*/                                )                            
                            OR 
                                (IsUserLevel__c = true
                                AND IsCatalogItemLevel__c = true
                                AND User__c = :pUserId 
/*                                AND (
                                    Catalog_item__r.Catalog__c = :levelOneTwoCatalogIdSet
                                    OR Catalog_item__r.Catalog__r.Parent_Catalog__c in :levelOneTwoCatalogIdSet)
*/                                )
                                ];
                                
        if (ciPermissionList.size()>0)  return ciPermissionList;
        else                            return new List<Catalog_Item_Permission__c>();
}    
    /*
        Returns a true if the userId has access to the Catalog_Item__c record, otherwise, returns false
        
        @userId         - the SF Id of the user trying to get view the catalog_item__c record
        @catalogItemId  - the SF Id of the Catalog_Item__c record that the user want to access
    */
    //public static Boolean isUserAllowedToViewCatalogItem (Id userId, Id catalogItemId){
        
    //    if (userId==null || catalogItemId==null )   return false;
        
    //    List<Catalog_Item_Permission__c> ciPermissionList = new List<Catalog_Item_Permission__c>();
        
    //    ciPermissionList = [select Id, Catalog__c, Catalog_Item__c, Department__c, isCatalogItemLevel__c, 
    //                                User__c, isCatalogLevel__c, isDepartmentLevel__c//, isUserLevel__c, Unique_Key__c
    //                            from Catalog_Item_Permission__c
    //                            where User__c = :userId AND Catalog_Item__c = :catalogItemId
    //                            limit 1];
        
    //    if (ciPermissionList.size()>0)  return true;
    //    else                            return false;
        
    //}

// ==============================================================================================================================================================

    /*
        Returns a list of Purchase_Request__c, where the records are submitted to approve
        
        @userId         - the SF Id of the user that the Purchase_Request__c belongs to
        @pNumberOfRecords        - number of records that the maximum number of rows to return

    */
    //--------------------------------Outdated------------------------------------------
    public static List<Purchase_Request__c> findPurchaseRequestToApproveList(String pUserId, Integer pNumberOfRecords) {
    
        List<Purchase_Request__c> purchaseRequestToApproveList = new List<Purchase_Request__c> ();
        List<ProcessInstanceWorkitem> currentUserProcessInstanceWorkitemList = new List<ProcessInstanceWorkitem> ();
        List<String> currentUserProcessInstanceIdList = new List<String> ();
       
        if(pnumberOfRecords == null){
            pNumberOfRecords = NUMBER_OF_QUERRY_RECORDS;
        }
       
        currentUserProcessInstanceWorkitemList = [SELECT ProcessInstanceId 
                                          FROM ProcessInstanceWorkitem 
                                          WHERE ActorId = :pUserId];
        
        
        if(!currentUserProcessInstanceWorkitemList.isempty()){       
                                     
            for (ProcessInstanceWorkitem reader : currentUserProcessInstanceWorkitemList) {
                currentUserProcessInstanceIdList.add(reader.ProcessInstanceId);
            }
                                
            purchaseRequestToApproveList = [SELECT Id, Name, Estimated_Total_Price__c, Status__c, On_Behalf_of__r.Employee_Full_Name__c, On_Behalf_of__r.Employee__r.Site__r.Name, Need_by_Date__c, Apply_Date__c 
                                            FROM Purchase_Request__c
                                            WHERE Id IN (SELECT  TargetObjectId 
                                                        FROM ProcessInstance 
                                                        WHERE Status =: PENDING_STATUS
                                                        AND Id IN :currentUserProcessInstanceIdList)
                                                        ORDER BY LastModifiedDate DESC, Name ASC
                                                        LIMIT :pNumberOfRecords];      
        }                      
        
                   
        return purchaseRequestToApproveList;
    }
    
    
// ==============================================================================================================================================================
 
    /*
        Returns a list of Purchase_Order__c, where the records are ordered by LastModifiedDate descendingly

        @pNumberOfRecords        - number of records that the maximum number of rows to return

    */
    //--------------------------------Outdated------------------------------------------
    public static List<Purchase_Order__c> findPurchaseOrderList(Integer pNumberOfRecords) {
    
        List<Purchase_Order__c> purchaseOrderList = new List<Purchase_Order__c> ();

        if(pnumberOfRecords == null){
            pNumberOfRecords = NUMBER_OF_QUERRY_RECORDS;
        }
                
        purchaseOrderList = [SELECT Id, Name, Supplier__r.Name, Status__c, Estimated_Total_Price__c, 
        //Applicant__c.Site__r.Name, 
        Currency__r.Name, LastModifiedDate 
                            FROM Purchase_Order__c 
                            ORDER BY LastModifiedDate DESC, Name ASC
                            LIMIT :pNumberOfRecords];
        return purchaseOrderList;    
    }

// ==============================================================================================================================================================

    /*
        Returns a list of Purchase_Request__c, where the records are related to user himself/herself
        
        @pUserId         - the SF Id of the user that the Purchase_Request__c belongs to
        @pNumberOfRecords        - number of records that the maximum number of rows to return

    */
    //--------------------------------Outdated------------------------------------------
    public static List<Purchase_Request__c> findRecentPurchaseRequestList(String pUserId, Integer pNumberOfRecords) {
    
        List<Purchase_Request__c> recentPurchaseRequestList= new List<Purchase_Request__c> ();

        if(pnumberOfRecords == null){
            pNumberOfRecords = NUMBER_OF_QUERRY_RECORDS;
        }

        recentPurchaseRequestList = [SELECT Id, Name, Estimated_Total_Price__c, Status__c, On_Behalf_of__r.Employee_Full_Name__c, On_Behalf_of__r.Employee__r.Site__r.Name, Need_by_Date__c, Apply_Date__c, LastModifiedDate  
                                    FROM Purchase_Request__c
                                    WHERE  On_Behalf_of__r.employee__r.User__c = :pUserId
                                    ORDER BY LastModifiedDate DESC, Name ASC
                                    LIMIT :pNumberOfRecords];

        return recentPurchaseRequestList;
                                    
    }
    
    
    
// ==============================================================================================================================================================

    /*
        Returns a list of SelectOption for the sorting picklist in VFPs 
        
    */
   public static List<SelectOption> loadSortingSelectOptionList() {

        List<SelectOption> options = new List<SelectOption>();

        //options.add(new SelectOption('', ''));
        options.add(new SelectOption(Label.IDP_Sorting_Field_Name_Asc_Key, Label.IDP_Sorting_Field_Name_Asc_Value));
        options.add(new SelectOption(Label.IDP_Sorting_Field_Name_Desc_Key, Label.IDP_Sorting_Field_Name_Desc_Value)); 
        options.add(new SelectOption(Label.IDP_Sorting_Field_Last_Supplier_Asc_Key, Label.IDP_Sorting_Field_Last_Supplier_Asc_Value));
        options.add(new SelectOption(Label.IDP_Sorting_Field_Last_Supplier_Desc_Key, Label.IDP_Sorting_Field_Last_Supplier_Desc_Value));
        options.add(new SelectOption(Label.IDP_Sorting_Field_Reference_Price_Asc_Key, Label.IDP_Sorting_Field_Reference_Price_Asc_Value));
        options.add(new SelectOption(Label.IDP_Sorting_Field_Reference_Price_Desc_Key, Label.IDP_Sorting_Field_Reference_Price_Desc_Value));

        return options;
    }
    
// ==============================================================================================================================================================

    /*
        Returns a list of SelectOption for the display Currency picklist in VFPs 
        
    */
   public static List<SelectOption> loadDisplayCurrencySelectOptionList() {
        List<SelectOption> options = new List<SelectOption>();
        
        //options.add(new SelectOption('', ''));
        options.add(new SelectOption(Label.IDP_Display_Currency_Original, Label.IDP_Display_Currency_Original));
        options.add(new SelectOption(Label.IDP_Display_Currency_Local, Label.IDP_Display_Currency_Local));        
        return options;


   }    
   
// ==============================================================================================================================================================

    /*
        Returns a Map of From Currency and Exchange Rate, Key is the [FromCurrencyId], value is [Rate__c]
        
        @pFromCurrencyIdSet    - the set of Currency Id that will be converted from
        @pToCurrencyId    - the Currency Id that will be converted to
    */   
    
    public static Map<String, Exchange_Rate__c> loadExchangeRateMap(set<String> pFromCurrencyIdSet, String pToCurrencyId){
    
        Map<String, Exchange_Rate__c> fromToCurencyIdExchangeRateMap=  new Map<String, Exchange_Rate__c> ();
        set<String> fromCurrencyIdSet = new set<String> ();
        
        for(String reader : pFromCurrencyIdSet) {
            if(reader != null) {
               fromCurrencyIdSet.add(reader);
            }
        }
        List<Exchange_Rate__c> exchangeRateList = [SELECT Tech_From_To_Currency_ID__c, Rate__c, From_Currency__c, To_Currency__c, To_Currency__r.Name 
                                                    FROM Exchange_Rate__c 
                                                    WHERE Is_Latest__c = true and Is_Book_Rate__c = true 
                                                    AND From_Currency__c = :fromCurrencyIdSet
                                                    AND To_Currency__c = :pToCurrencyId];
        
        for(Exchange_Rate__c reader: exchangeRateList) {
            fromToCurencyIdExchangeRateMap.put(reader.From_Currency__c, reader);
        }
        
        return fromToCurencyIdExchangeRateMap;
    }   
    
// ==============================================================================================================================================================
//    public static Map<String, Shopping_Cart_Item__c> singleAddtoCart(Map<String, Shopping_Cart_Item__c> pExistingShoppingCartItemMap,String pCatalogItemId,Integer pAddToCartQuantity) {
    
//        return null;
//    }

    public static Map<String, Shopping_Cart_Item__c> singleAddtoCart(Map<String, Shopping_Cart_Item__c> pExistingShoppingCartItemMap,String pCatalogItemId,Integer pAddToCartQuantity, String pAddToCartUOM) {
        
        Map<String, Shopping_Cart_Item__c> existingShoppingCartItemMap= pExistingShoppingCartItemMap;
        
        String UserId = UserInfo.getUserId();
        //String CatalogItemId= Apexpages.currentPage().getParameters().get('addToCartCatalogItemId');
        //Integer AddToCartQuantity = Integer.valueOf(Apexpages.currentPage().getParameters().get('addToCartQuantity'));

        Shopping_Cart_Item__c scItem = new Shopping_Cart_Item__c();

        if(pAddToCartUOM =='') {
            pAddToCartUOM = null;
        }
                
        List<Shopping_Cart_Item__c> scItemList = [SELECT Id, Name, User__c, Catalog_Item__c, Quantity__c, Status__c, Unit_Of_Measure__c
                                                    FROM Shopping_Cart_Item__c
                                                    WHERE User__c = :UserId
                                                    AND Catalog_Item__c = :pCatalogItemId
                                                    AND Unit_Of_Measure__c = : pAddToCartUOM
                                                    AND Status__c = 'OP'
                                                    LIMIT 1];
        

        if(scItemList.size() > 0) {
            scItemList.get(0).Quantity__c += pAddToCartQuantity;
        }                               
        else {
            scItem.User__c = UserId;
            scItem.Catalog_Item__c = pCatalogItemId;
            scItem.Quantity__c = pAddToCartQuantity;
            scItem.Unit_Of_Measure__c = pAddToCartUOM;
            scItem.Status__c= 'OP';
            scItemList.add(scItem);
        }
        system.debug(existingShoppingCartItemMap);
        if(scItemList.size() > 0) {
            //put the new added item to the existing map, but if it is a new record, the Id is not created at this moment, the map does not have the Id
            existingShoppingCartItemMap.put(scItemList.get(0).Catalog_Item__c + '_' + scItemList.get(0).Unit_Of_Measure__c, scItemList.get(0));
            upsert scItemList;
        }
        system.debug(existingShoppingCartItemMap);        
        return existingShoppingCartItemMap;
    }
    
// ==============================================================================================================================================================

    public static Map<String, Favourite_Item__c> singleAddRemoveFavouriteItem(Map<String, Favourite_Item__c> pExistingFavouriteItemMap,String pCatalogItemId) {
    
        Map<String, Favourite_Item__c> existingFavouriteItemMap = pExistingFavouriteItemMap;

        String UserId = UserInfo.getUserId();
        Favourite_Item__c newItem = new Favourite_Item__c();
        
        List<Favourite_Item__c> favItemList = [SELECT Id, Name, User__c, Catalog_Item__c
                                                FROM Favourite_Item__c
                                                WHERE User__c = :UserId
                                                AND Catalog_Item__c = :pCatalogItemId
                                                LIMIT 1];
 
        if(favItemList.size() > 0) {
            existingFavouriteItemMap.remove(favItemList.get(0).Catalog_Item__c);
            delete favItemList;
        }
        else {
            newItem.User__c = UserId;
            newItem.Catalog_Item__c = pCatalogItemId;
            favItemList.add(newItem);
            //put the new added item to the existing map, but if it is a new record, the Id is not created at this moment, the map does not have the Id
            existingFavouriteItemMap.put(favItemList.get(0).Catalog_Item__c, favItemList.get(0));
            upsert favItemList;
        }
        
        return existingFavouriteItemMap;

    }    


// ==============================================================================================================================================================

    public static String massAction(Map<String, Shopping_Cart_Item__c> pExistingShoppingCartItemMap, Map<String, Favourite_Item__c> pExistingFavouriteItemMap, String pCheckedCatalogItemIdQuantityJSON, String pMassMode) {
        system.debug(pExistingShoppingCartItemMap);

        // remark: Did not use one sOject List because upsert cannot be directly used to sOject List
        List<Shopping_Cart_Item__c> modifiedShoppingCartItemList = new List<Shopping_Cart_Item__c> ();
        List<Favourite_Item__c> modifiedFavouriteItemList = new List<Favourite_Item__c> ();

        Shopping_Cart_Item__c scItem = new Shopping_Cart_Item__c();
        Favourite_Item__c favItem = new Favourite_Item__c();

        String message = '';
        String UserId = UserInfo.getUserId();

        system.debug('pCheckedCatalogItemIdQuantityJSON:'+pCheckedCatalogItemIdQuantityJSON);

        IDPCommonUtils.EditedCatalogItems items = (IDPCommonUtils.EditedCatalogItems) JSON.deserialize(pCheckedCatalogItemIdQuantityJSON, IDPCommonUtils.EditedCatalogItems.class);
        //Loop the edited catalog item in browsing catalog item page i.e. (checked or unchecked) and (changed the quantity) catalog item         
        for(IDPCommonUtils.EditedCatalogItemWrapper reader : items.editedCatalogItemList) {
            //if the edited catalog Item is checked
            if(reader.checked == true) {
                //the mode is Add to Shopping Cart
                if(pMassMode == Label.IDP_Mass_Add_Mode_Add_To_Cart || pMassMode == Label.IDP_Mass_Add_Mode_Add_To_Cart_Remove_Favourite) {            
                    //if shopping cart exists record that is look up the same catalog item
                    // for the IDP_Mass_Add_Mode_Add_To_Cart or IDP_Mass_Add_Mode_Add_To_Cart_Remove_Favourite mode, the reader.catalogItemId = [catalog_Item__r.Id]
                    //because in BrowseCatalogVFP, the javascript saveEditedCatalogItemIdQuantity parameter is [catalog_Item_r.Id], the [Shopping_Cart_item__r.UOM] is not confirmed and the checkbox, quantity, UOM html element id is using [elementprefix] + [catalog_Item__r.Id] only
                    //But the ExistingShoppingCartItemMap's key = [Catalog_Item__r.Id] + '_' + [UOM] to distinguish same catalog item with different UOM

                        if(reader.unitOfMeasure == '') {
                            reader.unitOfMeasure = null;
                        }
                        if(pExistingShoppingCartItemMap.containsKey(reader.catalogItemId + '_' + reader.unitOfMeasure)) {
                            //sum up the original quantity in shopping cart and the new inputted quanitty in browsing catalog
                            pExistingShoppingCartItemMap.get(reader.catalogItemId + '_' + reader.unitOfMeasure).Quantity__c += reader.quantity;
                            //add it in the upsert list
                            modifiedShoppingCartItemList.add(pExistingShoppingCartItemMap.get(reader.catalogItemId + '_' + reader.unitOfMeasure));
                            //system.debug(pExistingShoppingCartItemMap);
                            //system.debug(pExistingShoppingCartItemMap.get(reader.catalogItemId + reader.unitOfMeasure));
                            //system.debug(modifiedShoppingCartItemList);
                        }
                        else {
                            scItem = new Shopping_Cart_Item__c();
                            scItem.User__c = UserId;

                            system.debug('massAction() reader:'+reader);
                            system.debug('massAction() reader.catalogItemId:'+reader.catalogItemId);

                            scItem.Catalog_Item__c = reader.catalogItemId;       
                            scItem.Unit_Of_Measure__c= reader.unitOfMeasure;
                            scItem.Quantity__c = reader.quantity;
                            scItem.Status__c = 'OP';
                            modifiedShoppingCartItemList.add(scItem);                    
                        }
                        
                        /*
                        if (pMassMode == Label.IDP_Mass_Add_Mode_Add_To_Cart_Remove_Favourite) {
                            if(pExistingFavouriteItemMap.containsKey(reader.catalogItemId)) {
                                modifiedFavouriteItemList.add(pExistingFavouriteItemMap.get(reader.catalogItemId));
                            }
                        }
                        */
                }        
                //the mode is Add to Favourite List                    
                else if(pMassMode == Label.IDP_Mass_Add_Mode_Add_To_Favourite_List) {
                    //if favourite list exists record that is look up the same catalog item
                    //for the IDP_Mass_Add_Mode_Add_To_Favourite_List mode, the reader.catalogItemId = [catalog_Item__r.Id]
                    //because in IDPBrowseCatalogVFP, the javascript saveEditedCatalogItemIdQuantity parameter is [catalog_Item_r.Id], the UOM is not confirmed and the checkbox, quantity, UOM html element id is using [elementprefix] + [catalog_Item__r.Id] only
                    //And pExistingFavouriteItemMap's key is catalog_Item__r.Id only  because 1 catalog item with only have 1 favourite item
                    if(pExistingFavouriteItemMap.containsKey(reader.catalogItemId)) {
                        //still add those existing item for checking the modifiedFavouriteItemList size is > 0 and provide message
                        modifiedFavouriteItemList.add(pExistingFavouriteItemMap.get(reader.catalogItemId));
                    }
                    else {
                        favItem = new Favourite_Item__c();
                        favItem.User__c = UserId;
                        favItem.Catalog_Item__c = reader.catalogItemId; 
                        modifiedFavouriteItemList.add(favItem);                    
                    }
                }
                else if(pMassMode == Label.IDP_Mass_Remove_Mode_Remove_From_Favourite_List) {
                
                    // for the IDP_Mass_Remove_Mode_Remove_From_Favourite_List mode, the reader.catalogItemId = [catalog_Item__r.Id]
                    //because in IDPBrowseCatalogVFP, the javascript saveEditedCatalogItemIdQuantity parameter is catalog_Item_r.Id, the UOM is not confirmed and the checkbox, quantity, UOM html element id is using [elementprefix] + [catalog_Item__r.Id] only
                    //And pExistingFavouriteItemMap's key is catalog_Item__r.Id only  because 1 catalog item with only have 1 favourite item
                    if(pExistingFavouriteItemMap.containsKey(reader.catalogItemId)) {
                        modifiedFavouriteItemList.add(pExistingFavouriteItemMap.get(reader.catalogItemId));
                    }
                }
                else if(pMassMode == Label.IDP_Mass_Remove_Mode_Remove_From_Cart) {
                
                    // for the IDP_Mass_Remove_Mode_Remove_From_Cart mode, the reader.catalogItemId = [catalog_Item__r.Id] + '_' + [UOM], because there may be same catalog item but with different UOM
                    //because in IDPBrowseCatalogVFP, the javascript saveEditedCatalogItemIdQuantity parameter is catalog_Item_r.Id + UOM
                    
                    if(pExistingShoppingCartItemMap.containsKey(reader.catalogItemId)) {
                        modifiedShoppingCartItemList.add(pExistingShoppingCartItemMap.get(reader.catalogItemId));
                    }



                }
                
            }

        }

        if(pMassMode == Label.IDP_Mass_Add_Mode_Add_To_Cart) {            
            if(modifiedShoppingCartItemList.size() > 0) {
                upsert modifiedShoppingCartItemList;            
                message = Label.IDP_Mass_Add_to_Cart_Message;
            }
        }
        else if(pMassMode == Label.IDP_Mass_Add_Mode_Add_To_Favourite_List) {
            if(modifiedFavouriteItemList.size() > 0) {
                upsert modifiedFavouriteItemList;
                message = Label.IDP_Mass_Add_to_Favourite_List_Message;
            }
        }
        else if(pMassMode == Label.IDP_Mass_Remove_Mode_Remove_From_Favourite_List) {
            if(modifiedFavouriteItemList.size() > 0) {
                delete modifiedFavouriteItemList;
                message = Label.IDP_Mass_Remove_From_Favourite_List_Message;
            }
        }
        else if (pMassMode == Label.IDP_Mass_Add_Mode_Add_To_Cart_Remove_Favourite) {
            if(modifiedShoppingCartItemList.size() > 0) {
                upsert modifiedShoppingCartItemList;            
                message = Label.IDP_Mass_Add_to_Cart_Message;
            }   
            /*
            if(modifiedFavouriteItemList.size() > 0) {
                delete modifiedFavouriteItemList;
                message = Label.IDP_Mass_Add_to_Favourite_List_Message;
            }
            */            
        }
        else if(pMassMode == Label.IDP_Mass_Remove_Mode_Remove_From_Cart) {
            if(modifiedShoppingCartItemList.size() > 0) {
                delete modifiedShoppingCartItemList;
                message = Label.IDP_Mass_Remove_From_Cart_Message;
            }
            
        }

        
        if(modifiedShoppingCartItemList.size() == 0 && modifiedFavouriteItemList.size() == 0) {
            message = Label.IDP_Have_Not_Selected_An_Item_Message;
        }
        
        return message;

        /*
        if(upsertShoppingCartItemList.size() > 0) {
            upsert upsertShoppingCartItemList;            
            message = Label.IDP_Mass_Add_to_Cart_Message;
        }
        else if(upsertShoppingCartItemList.size() == 0) {
       
            if(modifiedFavouriteItemList.size() > 0) {
                if(pMassMode == Label.IDP_Mass_Add_Mode_Add_To_Favourite_List) {
                    upsert modifiedFavouriteItemList;
                    message = Label.IDP_Mass_Add_to_Favourite_List_Message;
                    
                }
                else if(pMassMode == Label.IDP_Mass_Remove_Mode_Remove_From_Favourite_List) {
                    delete modifiedFavouriteItemList;
                    message = Label.IDP_Mass_Add_to_Favourite_List_Message;
                }
            }      
            else if (modifiedFavouriteItemList.size() == 0) {
                //upsert upsertFavouriteItemList;
                message = Label.IDP_Have_Not_Selected_An_Item_Message;
            }  
        }

        return message;
                 */
    }

    //Classes for massAdd method, need to match with the JSON format created in the VFP
    //Example:
    //[editedCatalogItemList=(EditedCatalogItemWrapper:[catalogItemId=a1Ep0000000iMUwEAM, checked=true, quantity=1])]
    public class EditedCatalogItems {
    
         public List<EditedCatalogItemWrapper> editedCatalogItemList;

    }
    
    public class EditedCatalogItemWrapper{
        
        public String catalogItemId;
        public boolean checked;
        public Integer quantity;
        public String unitOfMeasure;
    } 
    
// ==============================================================================================================================================================

    public static Map<String,List<String>> dependPickListValue(String ObjName, String ctrlField, String depField){        
        List<Schema.PicklistEntry> ctrl_ple = null;
        List<Schema.PicklistEntry> dep_ple = null;
        Schema.PicklistEntry dep_entry = null;
        Schema.PicklistEntry ctrl_entry = null;
        String pControllingLabel = '';
        String pEntryStructure = '';
        
        PickListUtils.Bitset objBitSet = new PickListUtils.Bitset();
        Map<String,List<String>> objResults  = new Map<String,List<String>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType pType = objGlobalMap.get(ObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        ctrl_ple = objFieldMap.get(ctrlField).getDescribe().getPicklistValues();
        dep_ple  = objFieldMap.get(depField).getDescribe().getPicklistValues();
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){            
            //get the pointer to the entry
            ctrl_entry = ctrl_ple[pControllingIndex];
            //get the label
            
            //pControllingLabel = ctrl_entry.getLabel();
            pControllingLabel = ctrl_entry.getValue();
            
            //create the entry with the label
            objResults.put(pControllingLabel,new List<String>());
        }
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){
            //get the pointer to the dependent index
            dep_entry = dep_ple[pDependentIndex];
            //get the valid for
            pEntryStructure = JSON.serialize(dep_entry);                
            PickListUtils.PicklistDetails objDepPLE = (PickListUtils.PicklistDetails)JSON.deserialize(pEntryStructure, PickListUtils.PicklistDetails.class);
            //iterate through the controlling values
            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){    
                if (objBitSet.fitBit(objDepPLE.validFor,pControllingIndex)){                    
                    //get the label
                    //pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
                    pControllingLabel = ctrl_ple[pControllingIndex].getValue();
                    //objResults.get(pControllingLabel).add(objDepPLE.label);
                    objResults.get(pControllingLabel).add(objDepPLE.value);
                }
            }
        }
        return objResults;
    }
    
// =============================================================================================================================================
    public static Map<String,String> picklistWithTranslation(String ObjName, String ctrlField, String depField){   
        List<Schema.PicklistEntry> ctrl_ple = null;
        List<Schema.PicklistEntry> dep_ple = null;
        Schema.PicklistEntry dep_entry = null;
        Schema.PicklistEntry ctrl_entry = null; 
        String pControllingLabel = '';
        String pEntryStructure = '';                
        Map<String,String> picklistWithTranslationMap = new Map<String,String>();  
        
        PickListUtils.Bitset objBitSet = new PickListUtils.Bitset();
        Map<String,List<String>> objResults  = new Map<String,List<String>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType pType = objGlobalMap.get(ObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        ctrl_ple = objFieldMap.get(ctrlField).getDescribe().getPicklistValues();
        dep_ple = objFieldMap.get(depField).getDescribe().getPicklistValues();    
    
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){            
            ctrl_entry = ctrl_ple[pControllingIndex];
            picklistWithTranslationMap.put(ctrl_entry.getValue(),ctrl_entry.getLabel());   
        }   
         
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){
            dep_entry = dep_ple[pDependentIndex];
            pEntryStructure = JSON.serialize(dep_entry);                
            PickListUtils.PicklistDetails objDepPLE = (PickListUtils.PicklistDetails)JSON.deserialize(pEntryStructure, PickListUtils.PicklistDetails.class);
            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){    
                if (objBitSet.fitBit(objDepPLE.validFor,pControllingIndex)){                    
                    pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
                    picklistWithTranslationMap.put(objDepPLE.value,objDepPLE.label);   
                }
            }
        }    
        system.debug(picklistWithTranslationMap);
        
        return picklistWithTranslationMap;
    }
// =============================================================================================================================================   
    
    
    
// ==============================================================================================================================================================

    public static Map<String, String> loadPhotoNameUrlMap(Set<String> pCatalogItemPhotoDocIdSet) {
    
    return null;
    }
    public static Map<String, String> loadPhotoUrlMap(Set<String> pCatalogItemPhotoDocIdSet) {
        Map<String, String> tempPhotoNameUrlMap = new Map<String, String> ();
        
        for(String reader : pCatalogItemPhotoDocIdSet) {
            tempPhotoNameUrlMap.put(reader, Label.IDP_Path_Photo_Document + reader);
        }
        return tempPhotoNameUrlMap;
    }
    
// ==============================================================================================================================================================
    public static List<String> loadUOMSelectOptionMap(String pUOMString) {
        //List<SelectOption> tempUOMSelectOption = new List<SelectOption>();
        List<String> tempUOMSelectOption = new List<String>();
        for(String reader : pUOMString.split(';')) {
            //tempUOMSelectOption.add(new SelectOption(reader, reader));
            
            tempUOMSelectOption.add(reader);
        }
        return tempUOMSelectOption;
    }
    
// ==============================================================================================================================================================

    public static Set<String> loadIsQueueMemeberQueueIdSet (String pUserId) {
        
        Set<String> IsQueueMemeberQueueIdSet = new Set<String> ();

        
        for(GroupMember reader: [SELECT Group.Id
                                    FROM GroupMember 
                                    WHERE UserOrGroupId = :pUserId 
                                    AND Group.Type = 'Queue'
                                    AND Group.DeveloperName like 'IDP%']) {
            
            IsQueueMemeberQueueIdSet.add(reader.Group.Id);               
        }
                                                    
        
        /*
SELECT Group.Name 
FROM GroupMember 
WHERE UserOrGroupId = 'YOUR-USER-ID' 
 AND Group.Type = 'Queue'
    */
        return IsQueueMemeberQueueIdSet;
    }
    
// ==============================================================================================================================================================

    public static Purchase_Request__c createAddToPurchaseRequest(String pUserId, Map<String, Shopping_Cart_Item__c> pShoppingCartItemMap) {
        
        Map<String, Purchase_Request_Item__c> CatalogItemIdexistingPurchaseRequestItemMap = new Map<String, Purchase_Request_Item__c> ();
        List<Purchase_Request_Item__c> tempPurchaseReqeustItemList = new List<Purchase_Request_Item__c> ();
        Purchase_Request__c  tempPurchaseRequest = null;
        String usedPurchaseRequestId = null;
        Purchase_Request_Item__c purchaseRequestItem = new Purchase_Request_Item__c ();
        Employee_Administrator__c applicant = new Employee_Administrator__c();
        String userId = '';
        String existingPurchaseRequestId = '';
        Integer purchaseItemNumber = 1;
        UserId = UserInfo.getUserId();
        applicant = getEmployeeAdministrator(userId);
        
        
        for(String scItemId: pShoppingCartItemMap.keyset()) {
            
            if(pShoppingCartItemMap.get(scItemId).Status__c != IDPConstant.SHOPPING_CART_STATUS_CLOSED) {
                return null;
            }
            
            
            if(String.isBlank(pShoppingCartItemMap.get(scItemId).Tech_Purchase_Request__c)) {
                tempPurchaseRequest = new Purchase_Request__c ();
                tempPurchaseRequest.On_Behalf_of__c = applicant.Id;
                tempPurchaseRequest.Catalog__c = pShoppingCartItemMap.get(scItemId).Catalog_Item__r.Catalog__r.Parent_Catalog__c;
                tempPurchaseRequest.IDP_Policy__c = applicant.Employee__r.IDP_Policy__c;
                tempPurchaseRequest.Delivery_Site__c = applicant.Employee__r.Site__c;
                tempPurchaseRequest.Delivery_To__c  = '';
                if(!String.isBlank(applicant.Employee__r.Site__r.Address_1__c)){
                    tempPurchaseRequest.Delivery_To__c  = applicant.Employee__r.Site__r.Address_1__c + ' ';                
                }
                if(!String.isBlank(applicant.Employee__r.Site__r.Address_2__c)){
                    tempPurchaseRequest.Delivery_To__c += applicant.Employee__r.Site__r.Address_2__c + ' ';
                }
                if(!String.isBlank(applicant.Employee__r.Site__r.Address_3__c)){
                    tempPurchaseRequest.Delivery_To__c += applicant.Employee__r.Site__r.Address_3__c + ' ';
                }
                if(!String.isBlank(applicant.Employee__r.Site__r.Address_4__c)){
                    tempPurchaseRequest.Delivery_To__c += applicant.Employee__r.Site__r.Address_4__c + ' ';
                }
                /*
                tempPurchaseRequest.Delivery_To__c += applicant.Employee__r.Site__r.Address_3__c + ' ';
                tempPurchaseRequest.Delivery_To__c += applicant.Employee__r.Site__r.Address_4__c;
                */
                tempPurchaseRequest.Tech_Catalog_Owner_Queue_Name__c = pShoppingCartItemMap.get(scItemId).Catalog_Item__r.Catalog__r.Tech_Catalog_Owner_Queue_Name__c;
                tempPurchaseRequest.Status__c = IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT;            
            }
            else {
                existingPurchaseRequestId = pShoppingCartItemMap.get(scItemId).Tech_Purchase_Request__c;
            }
            break;
        }
        
        if(tempPurchaseRequest != null) {
            insert tempPurchaseRequest;
        }
        else {
            for(Purchase_Request_Item__c reader : [SELECT Id, Catalog_Item__c, Purchase_Request__c, Purchase_Request__r.PR_Item_Count__c,    
                                                            Price__c, Unit_of_Measure__c, 
                                                            Status__c, Quantity__c, Supplier__c, Currency__c, Name, Catalog__c 
                                                    FROM Purchase_Request_Item__c
                                                    WHERE Purchase_Request__c = : existingPurchaseRequestId]) {
                                                    
                CatalogItemIdexistingPurchaseRequestItemMap.put(reader.Catalog_Item__c, reader);
            }
        }
        
        //shopping cart item change from Open to Closed
        for(String scItemId : pShoppingCartItemMap.keyset()) {
            
            if(tempPurchaseRequest != null) {
                purchaseRequestItem = new Purchase_Request_Item__c ();
                purchaseRequestItem.Purchase_Request__c = tempPurchaseRequest.Id;
            }
            else {  
                if(!CatalogItemIdexistingPurchaseRequestItemMap.containsKey(pShoppingCartItemMap.get(scItemId).Catalog_Item__c)) {
                    purchaseRequestItem = new Purchase_Request_Item__c ();
                    purchaseRequestItem.Purchase_Request__c = existingPurchaseRequestId ;
                }
                else {
                    purchaseRequestItem = CatalogItemIdexistingPurchaseRequestItemMap.get(pShoppingCartItemMap.get(scItemId).Catalog_Item__c);
                }
            }          
            purchaseRequestItem.Catalog_Item__c = pShoppingCartItemMap.get(scItemId).Catalog_Item__c;
            purchaseRequestItem.Currency__c = pShoppingCartItemMap.get(scItemId).Catalog_Item__r.Currency__c;
            purchaseRequestItem.Price__c = pShoppingCartItemMap.get(scItemId).Catalog_Item__r.Reference_Price__c;
            if(purchaseRequestItem.Quantity__c == null) {
                purchaseRequestItem.Quantity__c = pShoppingCartItemMap.get(scItemId).Quantity__c;
            }
            else {
                purchaseRequestItem.Quantity__c += pShoppingCartItemMap.get(scItemId).Quantity__c;
            }
            purchaseRequestItem.Supplier__c = pShoppingCartItemMap.get(scItemId).Catalog_Item__r.Last_Supplier__c;
            purchaseRequestItem.Unit_of_Measure__c= pShoppingCartItemMap.get(scItemId).Catalog_Item__r.Unit_Of_Measure__c;
            tempPurchaseReqeustItemList.add(purchaseRequestItem);
        } 
        
        upsert tempPurchaseReqeustItemList;

        if(tempPurchaseRequest != null) {
            usedPurchaseRequestId = tempPurchaseRequest.Id;
        }
        else {
            usedPurchaseRequestId = existingPurchaseRequestId;
        }
        if(usedPurchaseRequestId != null) {
               
            List<Purchase_Request_Item__c> orderedpurchaserRequestItemList = [SELECT Id, Catalog_Item__c, Catalog_Item__r.Catalog__r.Catalog_Name__c, Catalog_Item__r.Item_Name__c,
                                                                                        Purchase_Request__c, Purchase_Request__r.PR_Item_Count__c,    
                                                                                        Price__c, Unit_of_Measure__c, 
                                                                                        Status__c, Quantity__c, Supplier__c, Currency__c, Name, Catalog__c 
                                                                                FROM Purchase_Request_Item__c
                                                                                WHERE Purchase_Request__c = : usedPurchaseRequestId
                                                                                ORDER BY Catalog_Item__r.Catalog__r.Catalog_Name__c ASC, Catalog_Item__r.Item_Name__c ASC];
                                                                                
            for(Purchase_Request_Item__c prItem : orderedpurchaserRequestItemList) {
                prItem.Number__c = purchaseItemNumber;
                purchaseItemNumber ++;

            }
            
            update orderedpurchaserRequestItemList;
        }                                           
        return tempPurchaseRequest;
    }
    
    public static Employee_Administrator__c getEmployeeAdministrator(String pUserId) {
        Employee_Administrator__c tempEmployeeAdminstrator = [SELECT Id, Name, Administrator__c, Employee__c,
                                                                 Employee__r.IDP_Policy__c,
                                                                 Employee__r.Site__c, Employee__r.Site__r.Address_1__c,
                                                                 Employee__r.Site__r.Address_2__c,
                                                                 Employee__r.Site__r.Address_3__c,
                                                                 Employee__r.Site__r.Address_4__c
                                                                FROM Employee_Administrator__c
                                                                WHERE Employee_Administrator__r.User__c = :pUserId
                                                                AND Employee__r.User__c = :pUserId
                                                                AND Application__c INCLUDES ('IDP')];
        
        return tempEmployeeAdminstrator;
    }   
    /*
    public static PageReference redirectToShoppingCatalog() {
        return null;
    }
    */
    public static PageReference redirectToPage(String pPage) {
        String tempQueryCatalog = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Catalog);
        String tempqueryInput = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Input);
        String tempCurrencyName = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Display_Currency);
        String tempSortFieldName = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Sorting_Field);
        String tempPageNumber = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_DataTable_Page_Number); 
        String tempPageLength = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_DataTable_Page_Length);        
        String tempIsSearch = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Is_Search);  
        String tempBreadcrumbs = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Breadcrumbs);
        

        PageReference VFP = new PageReference(Label.IDP_Path_IDPBrowseCatalogVFP);
        
        if(pPage != null && pPage != '') {
            if(pPage == Label.IDP_Path_IDPShoppingCartVFP) {
                VFP = new PageReference(Label.IDP_Path_IDPShoppingCartVFP);
            }        
        }
        
        //PageReference shoppingCatalogVFP = new PageReference(Label.IDP_Path_IDPBrowseCatalogVFP);
        if(tempQueryCatalog != null && tempQueryCatalog != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Catalog, tempQueryCatalog );
        }
        if(tempqueryInput != null && tempqueryInput != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Input, tempqueryInput );
        }
        if(tempCurrencyName != null && tempCurrencyName != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Display_Currency, tempCurrencyName );
        }
        if(tempSortFieldName != null && tempSortFieldName != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Sorting_Field, tempSortFieldName );
        }
        if(tempPageNumber != null && tempPageNumber != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_DataTable_Page_Number, tempPageNumber );
        }
        if(tempPageLength != null && tempPageLength != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_DataTable_Page_Length, tempPageLength );
        }
        if(tempIsSearch != null && tempIsSearch != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Is_Search, tempIsSearch );
        }
        if(tempBreadcrumbs != null && tempBreadcrumbs != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Breadcrumbs, tempBreadcrumbs );
        }         
        return VFP;
    }
    public static PageReference redirectToPage() {
        String tempQueryCatalog = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Catalog);
        String tempqueryInput = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Input);
        String tempCurrencyName = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Display_Currency);
        String tempSortFieldName = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Sorting_Field);
        String tempPageNumber = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_DataTable_Page_Number); 
        String tempPageLength = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_DataTable_Page_Length);        
        String tempIsSearch = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Is_Search);  
        String tempBreadcrumbs = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Breadcrumbs);
        
        String tempPage = Apexpages.currentPage().getParameters().get(Label.IDP_Parameter_Name_Redirect_Page);
        system.debug ('tempPage' + tempPage );

        PageReference VFP = new PageReference(Label.IDP_Path_IDPBrowseCatalogVFP);
        
        if(tempPage != null && tempPage != '') {
            if(tempPage == Label.IDP_Path_IDPShoppingCartVFP) {
                VFP = new PageReference(Label.IDP_Path_IDPShoppingCartVFP);
            }        
        }
        
        //PageReference shoppingCatalogVFP = new PageReference(Label.IDP_Path_IDPBrowseCatalogVFP);
        if(tempQueryCatalog != null && tempQueryCatalog != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Catalog, tempQueryCatalog );
        }
        if(tempqueryInput != null && tempqueryInput != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Input, tempqueryInput );
        }
        if(tempCurrencyName != null && tempCurrencyName != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Display_Currency, tempCurrencyName );
        }
        if(tempSortFieldName != null && tempSortFieldName != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Sorting_Field, tempSortFieldName );
        }
        if(tempPageNumber != null && tempPageNumber != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_DataTable_Page_Number, tempPageNumber );
        }
        if(tempPageLength != null && tempPageLength != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_DataTable_Page_Length, tempPageLength );
        }
        if(tempIsSearch != null && tempIsSearch != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Is_Search, tempIsSearch );
        }
        if(tempBreadcrumbs != null && tempBreadcrumbs != '') {
            VFP.getParameters().put(Label.IDP_Parameter_Name_Breadcrumbs, tempBreadcrumbs );
        }

        //shoppingCatalogVFP.getParameters().put(Label.IDP_Parameter_Name_Breadcrumbs_Sub_Catalog, tempParentCatalogName );  
        //shoppingCatalogVFP.getParameters().put(Label.IDP_Parameter_Name_Breadcrumbs_Sub_Catalog, tempSubCatalogName );          
        return VFP;
    }
// ==============================================================================================================================================================
// ==============================================================================================================================================================
// ==============================================================================================================================================================

//Outdated
    /*
        Returns a list of Catalog_Item_Permission__c records that are to be inserted by the user. List is containing permission for catalog and all catalog items under each catalog
        
        @departmentStringSet    - the department name set of the Departments you want to grant access to the catalog items > User.Department__c
        @catalogIdSet           - the SF Id set of the Catalog__c records that you want the userIdSet to have access to
    */
    public static List<Catalog_Item_Permission__c>  createDepartmentPermissions (Set<String> departmentStringSet, Set<Id> catalogIdSet){
        
        if (departmentStringSet==null || departmentStringSet.size()==0 || catalogIdSet==null || catalogIdSet.size()==0) return null;
        
        
        List<Catalog_Item_Permission__c> ciPermissionListToUpsert = new List<Catalog_Item_Permission__c>();
        List<Catalog__c> catalogList = new List<Catalog__c>();
        
        // get all the catalog items under the catalog and the child catalog
        //catalogList = [select Id, Name, Catalog_Code__c, (select Id, Item_Code__c, Catalog__c, Name from Catalog_Items__r) from Catalog__c where Id IN: catalogIdSet OR Parent_Catalog__c IN :catalogIdSet];
        catalogList = [select Id, Name, Catalog_Code__c, (select Id, Catalog__c, Name from Catalog_Items__r) from Catalog__c where Id IN: catalogIdSet OR Parent_Catalog__c IN :catalogIdSet];
        
        // create CIP records for the department level and catalog level first
        for (String department : departmentStringSet){
            for (Catalog__c c : catalogList){
                
                // use the Catalog_Code__c + Department as unique key
                String uniqueKey = c.Catalog_Code__c + department;
                
                ciPermissionListToUpsert.add( new Catalog_Item_Permission__c(   isCatalogLevel__c = true,
                                                                                isDepartmentLevel__c = true,
                                                                                Department__c = department,
                                                                                Catalog__c = c.Id,
                                                                                Unique_Key__c = uniqueKey) );
                                                                                
            }
        }
        
        
        // create CIP records for the User under the departments and Catalog Level
        for (User u : [select Id, Department__c from User where Department__c IN: departmentStringSet]){
            for (Catalog__c c : catalogList){
                
                // use the Catalog_Code__c + userId as unique key
                String uniqueKey = c.Catalog_Code__c + u.Id;
                
                ciPermissionListToUpsert.add( new Catalog_Item_Permission__c(   isCatalogLevel__c = true,
                                                                                User__c = u.Id,
                                                                                Department__c = u.Department__c,
                                                                                Catalog__c = c.Id,
                                                                                Unique_Key__c = uniqueKey) );
                
                // create CIP records for the User under the departments and Catalog Items Level
                for (Catalog_Item__c ci : c.Catalog_Items__r){
                
                    // use Item_Code__c + userId for the unique key
                    //String uniqueKey2 = ci.Item_Code__c + u.Id;
                    String uniqueKey2 = u.Id;
                    ciPermissionListToUpsert.add( new Catalog_Item_Permission__c(   isCatalogItemLevel__c = true,
                                                                                    User__c = u.Id,
                                                                                    Department__c = u.Department__c,
                                                                                    Catalog_Item__c = ci.Id,
                                                                                    Catalog__c = ci.Catalog__c,
                                                                                    Unique_Key__c = uniqueKey2) );
                    
                }
            }
        }
        
        return ciPermissionListToUpsert;
        
    }

// ==============================================================================================================================================================

    /*
        Returns a list of Catalog_Item_Permission__c records that are to be inserted by the user. List is containing permission for catalog and all catalog items under each catalog
        
        @userIdSet          - the SF Id set of the users you want to grant access to the list of items accessible
        @catalogIdSet       - the SF Id set of the Catalog__c records that you want the userIdSet to have access to
    */
    public static List<Catalog_Item_Permission__c>  createCatalogPermissions (Set<Id> userIdSet, Set<Id> catalogIdSet){
        
        if (userIdSet==null || userIdSet.size()==0 || catalogIdSet==null || catalogIdSet.size()==0) return null;
        
        
        List<Catalog_Item_Permission__c> ciPermissionListToUpsert = new List<Catalog_Item_Permission__c>();
        List<Catalog__c> catalogList = new List<Catalog__c>();
        
        // get all the catalog items under the catalog and the child catalog
        //catalogList = [select Id, Name, Catalog_Code__c, (select Id, Item_Code__c, Catalog__c, Name from Catalog_Items__r) from Catalog__c where Id IN: catalogIdSet OR Parent_Catalog__c IN :catalogIdSet];
        catalogList = [select Id, Name, Catalog_Code__c, (select Id,  Catalog__c, Name from Catalog_Items__r) from Catalog__c where Id IN: catalogIdSet OR Parent_Catalog__c IN :catalogIdSet];
        
        
        for (User u : [select Id, Department__c from User where Id IN: userIdSet]){
            for (Catalog__c c : catalogList){
                
                // use the Catalog_Code__c + userId as unique key
                String uniqueKey = c.Catalog_Code__c + u.Id;
                
                ciPermissionListToUpsert.add( new Catalog_Item_Permission__c(   isCatalogLevel__c = true,
                                                                                User__c = u.Id,
                                                                                Department__c = u.Department__c,
                                                                                Catalog__c = c.Id));//,
                                                                                //Unique_Key__c = uniqueKey) );
                
                // create CIP records for the User under the departments and Catalog Items Level
                for (Catalog_Item__c ci : c.Catalog_Items__r){
                
                    // use Item_Code__c + userId for the unique key
                    //String uniqueKey2 = ci.Item_Code__c + u.Id;

                    ciPermissionListToUpsert.add( new Catalog_Item_Permission__c(   isCatalogItemLevel__c = true,
                                                                                    User__c = u.Id,
                                                                                    Department__c = u.Department__c,
                                                                                    Catalog_Item__c = ci.Id,
                                                                                    Catalog__c = ci.Catalog__c)); //,
                                                                                    //Unique_Key__c = uniqueKey2) );
                    
                }
                
                
            }
            
            
        }
        
        return ciPermissionListToUpsert;
        
    }

// ==============================================================================================================================================================

    /*
        Returns a list of Catalog_Item_Permission__c records that are to be inserted by the user
        
        @userIdSet          - the SF Id set of the users you want to grant access to the list of items accessible
        @catalogItemIdSet   - the SF Id set of the Catalog_Item__c records that you want the userIdSet to have access to
    */
    public static List<Catalog_Item_Permission__c>  createCatalogItemPermissions (Set<Id> userIdSet, Set<Id> catalogItemIdSet){
        
        if (userIdSet==null || userIdSet.size()==0 || catalogItemIdSet==null || catalogItemIdSet.size()==0) return null;
        
        List<Catalog_Item_Permission__c> ciPermissionListToUpsert = new List<Catalog_Item_Permission__c>();
        List<Catalog_Item__c> catalogItemList = new List<Catalog_Item__c>();
        
        // get all the catalog items under the catalog and the child catalog
        catalogItemList = [select Id, Catalog__c, Name//, Item_Code__c,
                           from Catalog_Item__c where Id IN: catalogItemIdSet];
        
        for (User u : [select Id, Department__c from User where Id IN: userIdSet]){
            for (Catalog_Item__c ci : catalogItemList){
                
                // use Item_Code__c + userId for the unique key
                //String uniqueKey = ci.Item_Code__c + u.Id;
                //String uniqueKey = ci.Name;
                ciPermissionListToUpsert.add( new Catalog_Item_Permission__c(   isCatalogItemLevel__c = true,
                                                                                User__c = u.Id,
                                                                                Department__c = u.Department__c,
                                                                                Catalog_Item__c = ci.Id,
                                                                                Catalog__c = ci.Catalog__c) );//,
                                                                                //Unique_Key__c = uniqueKey) );
                
            }
            
            
        }
        
        return ciPermissionListToUpsert;
        
    }
    
    
    
}