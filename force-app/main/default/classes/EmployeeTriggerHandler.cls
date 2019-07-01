/**
 * @description To handle employ access right and validation
 */
public without sharing class EmployeeTriggerHandler {
    public static Boolean beforeTriggerEecuted = false;
    public static Boolean afterTriggerEecuted = false;
    public static String ApproverAccessRight = 'Read';
    public static String UserAccessRight = 'Edit';
    public static String Manual =  Schema.Employee__Share.RowCause.Manual;

    public static void mapUserRecord(Map<Id, Employee__c> oldEmployeeMap, List<Employee__c> newEmployeeList) {
        Map <String, Employee__c> employeesInScopeMap = new Map <String, Employee__c>();
        Map <Id, String> SiteMap = new Map <Id, String>();
        
        for(Employee__c e : newEmployeeList) {
            if(Trigger.isUpdate &&
               (
                   oldEmployeeMap.get(e.Id).Original_Employee_ID__c != e.Original_Employee_ID__c ||
                   oldEmployeeMap.get(e.Id).Site__c != e.Site__c 
                   
               )
              ) {
                  SiteMap.put(e.Site__c , '');
                  if (oldEmployeeMap.get(e.Id).Original_Employee_ID__c != e.Original_Employee_ID__c ) {
                      e.user__c = null;
                      employeesInScopeMap.put(e.Original_Employee_ID__c, e);
                  }
                  else{
                      employeesInScopeMap.put(e.Original_Employee_ID__c, e);
                  }
              } else if(Trigger.isInsert) {
                  SiteMap.put(e.Site__c , '');
                  employeesInScopeMap.put(e.Original_Employee_ID__c , e);
              }
        }
        
        for ( Site__c site : [ Select id, name from site__c where id in :SiteMap.keySet() ] ){
                SiteMap.put( site.id, site.name );
        }
        
        for (User usr : [select id, employeeNumber, Physical_Delivery_Address__c from user where employeeNumber in :employeesInScopeMap.KeySet() and Physical_Delivery_Address__c in :SiteMap.values() ]){            
            if ( employeesInScopeMap.containskey( usr.employeeNumber ) ){
                if ( SiteMap.get(employeesInScopeMap.get(usr.employeeNumber).site__c) == usr.Physical_Delivery_Address__c   ){
                    employeesInScopeMap.get(usr.employeeNumber).user__c = usr.id;
                }
            }       
        }
    }
    
   /**
     * @description To gain employ access right to employee administeror
     */     
    public static void createEmployeeAdministrator(Map<Id, Employee__c> oldEmployeeMap, Map<Id, Employee__c> newEmployeeMap) {
        
        // Setup variables for the fun below
        List<Employee__c> employeesToCreateAdmins = new List<Employee__c>();
        List<Employee_Administrator__c> employeeAdmins = new List<Employee_Administrator__c>();

        List<Employee__Share> employeeSharingList = new List<Employee__Share>();
        List<Employee__Share> tmpemployeeSharingList = new List<Employee__Share>();
        List<Employee__Share> toBeDelemployeeSharingList = new List<Employee__Share>();
        List<Employee__Share> ownerList = new List<Employee__Share>();
        List<Id> approverIdList  = new List<Id>();
        List<Id> EmployeeIdList = new List<Id>();
        Map<Id, Boolean> isActiveUserMap =  ActiveUserMap (newEmployeeMap);
        Map<Id, List<Employee_Administrator__c>> empIdToEmployeeAdmins = new Map<Id, List<Employee_Administrator__c>>();
        
        // Note: Formula fields that reference the SFDC Internal ID will display a 15 character ID
        
        // UPDATE Scenario
        if(Trigger.isUpdate) {
            List <Employee__Share> employeeShareList = new List <Employee__Share>();
            Set<ID> OwerUserIdSet = new Set<ID>();
            
            for(Employee__c e : newEmployeeMap.values()) {
                EmployeeIdList.add(e.id); 
               
            }

            for(Employee__Share  reader : [ select id, UserOrGroupId, ParentId, RowCause  from Employee__Share where  ParentId in :EmployeeIdList ]) {
                employeeShareList.add( reader );
            }

            // Gain access right to employee approver 1, 2, 3 and 4 (Apex Sharing Rules)
            for(Employee__c e : newEmployeeMap.values()) {
                if ( ( e.user__c != oldEmployeeMap.get(e.id).user__c ) ||  ( e.ownerid != oldEmployeeMap.get(e.id).ownerid ) || ( e.Approver_1__c != oldEmployeeMap.get(e.id).Approver_1__c ) || ( e.Approver_2__c != oldEmployeeMap.get(e.id).Approver_2__c ) || ( e.Approver_3__c != oldEmployeeMap.get(e.id).Approver_3__c ) || ( e.Approver_4__c != oldEmployeeMap.get(e.id).Approver_4__c ) || ( e.Acting_Approver_1__c != oldEmployeeMap.get(e.id).Acting_Approver_1__c) || ( e.Acting_Approver_2__c != oldEmployeeMap.get(e.id).Acting_Approver_2__c) || ( e.Acting_Approver_3__c != oldEmployeeMap.get(e.id).Acting_Approver_3__c) || ( e.Acting_Approver_4__c != oldEmployeeMap.get(e.id).Acting_Approver_4__c)){
                    OwerUserIdSet.clear();
                    for ( Employee__Share reader : employeeShareList ){
                        if ( reader.RowCause == Manual   && reader.ParentId == e.id  ){
                            toBeDelemployeeSharingList.add(reader);
                        }
                        if ( reader.RowCause != Manual   && reader.ParentId == e.id  ){
                            OwerUserIdSet.add(reader.UserOrGroupId);
                        }
                    }
                    tmpemployeeSharingList = employeeSharingList( e, employeeShareList, OwerUserIdSet, isActiveUserMap);
                    for ( Employee__Share reader : tmpemployeeSharingList ){
                        employeeSharingList.add(reader);
                    }
                }
            }
            
            for(Employee_Administrator__c ea : 
                [
                    SELECT Id, Name, Employee__c, Employee_Administrator__c 
                    FROM Employee_Administrator__c
                    WHERE Employee__c IN: EmployeeIdList]
            ) {
                
                if(empIdToEmployeeAdmins.get(ea.Employee__c) != null) {
                    List<Employee_Administrator__c> eaList = empIdToEmployeeAdmins.get(ea.Employee__c);
                    eaList.add(ea);
                    empIdToEmployeeAdmins.put(ea.Employee__c, eaList);
                } else {
                    List<Employee_Administrator__c> eaList = new List<Employee_Administrator__c>();
                    eaList.add(ea);
                    empIdToEmployeeAdmins.put(ea.Employee__c, eaList);                    
                }
                   
                System.debug('### ' + ea);
            }
            
            for(Employee__c e : newEmployeeMap.values()) {
                if(
                    ( 
                        ( newEmployeeMap.get(e.Id).is_active__c != oldEmployeeMap.get(e.Id).is_active__c  || newEmployeeMap.get(e.Id).User__c != oldEmployeeMap.get(e.Id).User__c) || (newEmployeeMap.get(e.Id).Tech_Name__c != oldEmployeeMap.get(e.Id).Tech_Name__c) 
                    ) //&& (e.User__c != null)
                ) {
                    
                    List<Employee_Administrator__c> eaList = empIdToEmployeeAdmins.get(e.Id);
                    if ( eaList  != null){
                        for(Employee_Administrator__c ea : eaList) {
                            ea.Name = e.Tech_Name__c;
                            if ( !e.is_active__c ){
                                ea.is_active__c = e.is_active__c;
                            }
                            employeeAdmins.add(ea);
                        }
                    }
                    
                }
            }
            
            
        }
        
        // INSERT Scenario
        if(Trigger.isInsert) { 
            // Insert Approver 1, 2, 3, and 4 to employee share
            for(Employee__c e : newEmployeeMap.values()) {     
                if ( e.User__c != null && e.User__c != e.OwnerId  ){
                    employeeSharingList.add( EmployeeShare ( e.id, e.User__c,  UserAccessRight));
                }
                if ( e.Approver_1__c != null  && e.Approver_1__c != e.OwnerId ){
                    employeeSharingList.add( EmployeeShare ( e.id, e.Approver_1__c ,  ApproverAccessRight));
                }
                if ( e.Approver_2__c != null && e.Approver_2__c != e.OwnerId  ){
                    employeeSharingList.add( EmployeeShare ( e.id, e.Approver_2__c ,  ApproverAccessRight));
                }
                if ( e.Approver_3__c != null && e.Approver_3__c != e.OwnerId  ){
                    employeeSharingList.add( EmployeeShare ( e.id, e.Approver_3__c , ApproverAccessRight));
                }
                if ( e.Approver_4__c != null && e.Approver_4__c != e.OwnerId  ){
                    employeeSharingList.add( EmployeeShare ( e.id, e.Approver_4__c, ApproverAccessRight));
                }
                if ( e.Acting_Approver_1__c  != null && e.Acting_Approver_1__c  != e.OwnerId  ){
                    employeeSharingList.add( EmployeeShare ( e.id, e.Acting_Approver_1__c  ,  ApproverAccessRight));
                }
                if ( e.Acting_Approver_2__c  != null && e.Acting_Approver_2__c  != e.OwnerId  ){
                    employeeSharingList.add( EmployeeShare ( e.id, e.Acting_Approver_2__c  ,  ApproverAccessRight));
                }
                if ( e.Acting_Approver_3__c  != null && e.Acting_Approver_3__c   != e.OwnerId  ){
                    employeeSharingList.add( EmployeeShare ( e.id, e.Acting_Approver_3__c  ,  ApproverAccessRight));
                }
                if ( e.Acting_Approver_4__c  != null && e.Acting_Approver_4__c  != e.OwnerId  ){
                    employeeSharingList.add( EmployeeShare ( e.id, e.Acting_Approver_4__c  ,  ApproverAccessRight));
                }                         
            }
            
            // Create an Employee Administrator for the User__c of this Employee__c
            for(Employee__c e : newEmployeeMap.values()) {
                employeeAdmins.add(new Employee_Administrator__c(Name = e.Tech_Name__c, Employee__c = e.Id, Employee_Administrator__c = e.Id, is_active__c = e.is_active__c ));
            }            
        }
        
        if(!employeeAdmins.isEmpty()) {
            upsert employeeAdmins;
        }
        
        if(!toBeDelemployeeSharingList.isEmpty()) {
            delete toBeDelemployeeSharingList;
        }
        
        if(!employeeSharingList.isEmpty()) {
            upsert employeeSharingList;
        } 
    }
    
    /**
     * @description To create list of approver for employee sharing
     */    
    public static List<Employee__Share> employeeSharingList(Employee__c e, List<Employee__Share> employeeShareList, Set<ID> OwerUserIdSet, Map<Id, Boolean> isActiveUserMap){
        List<Employee__Share> employeeSharingList = new List<Employee__Share>();
        for ( Employee__Share reader : employeeShareList ){
            if ( e.User__c != null && e.User__c != e.OwnerId  )
            {           
                employeeSharingList.add( EmployeeShare ( e.id, e.User__c,  UserAccessRight));
            }
            if ( e.Approver_1__c != null && !OwerUserIdSet.contains(e.Approver_1__c) && reader.ParentId  == e.id && isActiveUserMap.containskey(e.Approver_1__c) && isActiveUserMap.get(e.Approver_1__c) ){
                employeeSharingList.add( EmployeeShare ( e.id, e.Approver_1__c ,  ApproverAccessRight));
            }
            if ( e.Approver_2__c != null && !OwerUserIdSet.contains(e.Approver_2__c) && reader.ParentId  == e.id && isActiveUserMap.containskey(e.Approver_2__c) && isActiveUserMap.get(e.Approver_2__c)){
                employeeSharingList.add( EmployeeShare ( e.id, e.Approver_2__c ,  ApproverAccessRight));
            }
            if ( e.Approver_3__c != null && !OwerUserIdSet.contains(e.Approver_3__c) && reader.ParentId  == e.id && isActiveUserMap.containskey(e.Approver_3__c) && isActiveUserMap.get(e.Approver_3__c)){
                employeeSharingList.add( EmployeeShare ( e.id, e.Approver_3__c ,  ApproverAccessRight));
            }
            if ( e.Approver_4__c != null && !OwerUserIdSet.contains(e.Approver_4__c) && reader.ParentId  == e.id && isActiveUserMap.containskey(e.Approver_4__c) && isActiveUserMap.get(e.Approver_4__c)){
                employeeSharingList.add( EmployeeShare ( e.id, e.Approver_4__c ,  ApproverAccessRight));
            }                        
            if ( e.Acting_Approver_1__c  != null && !OwerUserIdSet.contains(e.Acting_Approver_1__c  ) && reader.ParentId  == e.id  && isActiveUserMap.containskey(e.Acting_Approver_1__c  ) && isActiveUserMap.get(e.Acting_Approver_1__c  ) ){
                employeeSharingList.add( EmployeeShare ( e.id, e.Acting_Approver_1__c  ,  ApproverAccessRight));
            }
            if ( e.Acting_Approver_2__c  != null && !OwerUserIdSet.contains(e.Acting_Approver_2__c  ) && reader.ParentId  == e.id && isActiveUserMap.containskey(e.Acting_Approver_2__c  ) && isActiveUserMap.get(e.Acting_Approver_2__c  ) ){
                employeeSharingList.add( EmployeeShare ( e.id, e.Acting_Approver_2__c  ,  ApproverAccessRight));
            }
            if ( e.Acting_Approver_3__c  != null && !OwerUserIdSet.contains(e.Acting_Approver_3__c  ) && reader.ParentId  == e.id && isActiveUserMap.containskey(e.Acting_Approver_3__c  ) && isActiveUserMap.get(e.Acting_Approver_3__c  ) ){
                employeeSharingList.add( EmployeeShare ( e.id, e.Acting_Approver_3__c  ,  ApproverAccessRight));
            }
            if ( e.Acting_Approver_4__c  != null && !OwerUserIdSet.contains(e.Acting_Approver_4__c  ) && reader.ParentId  == e.id   && isActiveUserMap.containskey(e.Acting_Approver_4__c  ) && isActiveUserMap.get(e.Acting_Approver_4__c  ) ){
                employeeSharingList.add( EmployeeShare ( e.id, e.Acting_Approver_4__c  ,  ApproverAccessRight));
            }
        }
        return employeeSharingList;
    }
    
    /**
     * @description To create employee share record
     */
    public static Employee__Share EmployeeShare ( Id pid, Id uid, String AccessLevel  )
    {
        Employee__Share  employeeShare = new Employee__Share ();
        employeeShare.ParentId =pid ;
        employeeShare.UserOrGroupId = uid ;
        employeeShare.AccessLevel =  AccessLevel  ;
        return employeeShare ;
    }
    
    /**
     * @description To check the user account is acctive or inactive
     */
    public static Map<Id, Boolean> ActiveUserMap(Map<Id, Employee__c> newEmployeeMap){
        Set<Id> employeeIdSet = new Set<Id>();
        Map<Id, Boolean> isActiveUserMap = new Map<Id, Boolean>();
        for ( Employee__c reader : newEmployeeMap.values() ) {
            if ( reader.user__c != null ){
                employeeIdSet.add(reader.user__c);
            }
            if ( reader.Acting_Approver_1__c!= null ){
                employeeIdSet.add(reader.Acting_Approver_1__c);
            } 
            if ( reader.Acting_Approver_2__c!= null ){
                employeeIdSet.add(reader.Acting_Approver_2__c);
            } 
            if ( reader.Acting_Approver_3__c!= null ){
                employeeIdSet.add(reader.Acting_Approver_3__c);
            } 
            if ( reader.Acting_Approver_4__c!= null ){
                employeeIdSet.add(reader.Acting_Approver_4__c);
            } 
            if ( reader.Approver_1__c!= null ){
                employeeIdSet.add(reader.Approver_1__c);
            } 
            if ( reader.Approver_2__c!= null ){
                employeeIdSet.add(reader.Approver_2__c);
            }
            if ( reader.Approver_3__c!= null ){
                employeeIdSet.add(reader.Approver_3__c);
            }
            if ( reader.Approver_4__c!= null ){
                employeeIdSet.add(reader.Approver_4__c);
            }     
        }
        for ( user reader : [ select id, IsActive from user where id in :employeeIdSet ] ){
            isActiveUserMap.put ( reader.id , reader.IsActive );
        }
        return isActiveUserMap;
    }
 
    public static void validationRule (Map<Id, Employee__c> newEmployeeMap) {
        EmployeeTriggerHandler.validationRule(newEmployeeMap, null);
    }
    
    /**
     * @description To check employ user__c duplication
     */
    public static void validationRule (Map<Id, Employee__c> newEmployeeMap, Map<Id, Employee__c> oldEmployeeMap) {         
        set <String> emplyeeUserIDSet = new set <String> ();
        set <String> duplicateEmplyeeUserIDSet = new set <String> ();        
        for ( Employee__c employee : newEmployeeMap.values() ){
            if ( employee.user__c != null ){
                emplyeeUserIDSet .add(employee.user__c);
            }
        }
        
        for ( AggregateResult employee : 
        [ 
            select user__c, count(id) id
            from Employee__c
            where user__c in :emplyeeUserIDSet
            and user__c != null
            group by user__c
            having count(id) > 1            
        ]){
            duplicateEmplyeeUserIDSet.add((String)employee.get('user__c'));
            
        }
        
        if ( !duplicateEmplyeeUserIDSet.isempty() ){
            for ( Employee__c employee : newEmployeeMap.values() ){
                if ( duplicateEmplyeeUserIDSet.contains(employee.user__c) ){
                    employee.user__c.adderror(Label.ELeave_Error_Duplicate_User);
                }
            }
        }
        
        Map<Id, Boolean> isActiveUserMap =  ActiveUserMap (newEmployeeMap);         
        for ( Employee__c reader : newEmployeeMap.values() ) {
            boolean hasEmployeeActiveFlagChanged = false;
            if(oldEmployeeMap != null) {
            
                Employee__c oldEmp = oldEmployeeMap.get(reader.Id);
                if(reader.Is_Active__c != oldEmp.Is_Active__c) {
                    hasEmployeeActiveFlagChanged = true;
                }
            }
            
            if ( isActiveUserMap.containskey(reader.user__c) &&  !isActiveUserMap.get(reader.user__c) && !hasEmployeeActiveFlagChanged){
                reader.user__c.adderror(Label.ELeave_Error_Inactive_user);
            }
            if ( isActiveUserMap.containskey(reader.Acting_Approver_1__c) && !isActiveUserMap.get(reader.Acting_Approver_1__c) ){
                reader.Acting_Approver_1__c.adderror(Label.ELeave_Error_Inactive_user);
            }
            if ( isActiveUserMap.containskey(reader.Acting_Approver_2__c) && !isActiveUserMap.get(reader.Acting_Approver_2__c) ){
                reader.Acting_Approver_2__c.adderror(Label.ELeave_Error_Inactive_user);
            }
            if ( isActiveUserMap.containskey(reader.Acting_Approver_3__c) &&  !isActiveUserMap.get(reader.Acting_Approver_3__c) ){
                reader.Acting_Approver_3__c.adderror(Label.ELeave_Error_Inactive_user);
            }
            if ( isActiveUserMap.containskey(reader.Acting_Approver_4__c) &&  !isActiveUserMap.get(reader.Acting_Approver_4__c) ){
                reader.Acting_Approver_4__c.adderror(Label.ELeave_Error_Inactive_user);
            }
            if ( isActiveUserMap.containskey(reader.Approver_1__c) &&  !isActiveUserMap.get(reader.Approver_1__c) ){
                reader.Approver_1__c.adderror(Label.ELeave_Error_Inactive_user);
            }
            if ( isActiveUserMap.containskey(reader.Approver_2__c) &&  !isActiveUserMap.get(reader.Approver_2__c) ){
                reader.Approver_2__c.adderror(Label.ELeave_Error_Inactive_user);
            }
            if ( isActiveUserMap.containskey(reader.Approver_3__c) &&  !isActiveUserMap.get(reader.Approver_3__c) ){
                reader.Approver_3__c.adderror(Label.ELeave_Error_Inactive_user);
            }
            if ( isActiveUserMap.containskey(reader.Approver_4__c) &&  !isActiveUserMap.get(reader.Approver_4__c) ){
                reader.Approver_4__c.adderror(Label.ELeave_Error_Inactive_user);
            }
        }        
    }    
}