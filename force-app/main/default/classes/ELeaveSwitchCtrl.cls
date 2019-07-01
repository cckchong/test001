/**
 * EleaveSwitchCtrl
 * @description button for enable/disable ELE Application
 */
public class ELeaveSwitchCtrl{ 
    public PermissionSet objPermSet {set; get;}
    public List<PermissionSetAssignment> listPermSetAss {set; get;}
    public Set<Id> setAdminGpMemberId {set; get;}
    public Set<Id> setTAAUsersId {set; get;}
    public Boolean boolDisabled {set; get;}

    public EleaveSwitchCtrl() {
        setAdminGpMemberId = new Set<Id>();
        setTAAUsersId  = new Set<Id>(); //Ex. Admin
        
        //Retrieve users from TAA & TAA2 admin groups, who will bypass the e-leave edisability
        for(GroupMember gm : [SELECT Id, UserOrGroupId From GroupMember WHERE 
                              GroupId IN (SELECT id FROM Group WHERE (DeveloperName = 'ELE_TAA_Admin' OR DeveloperName = 'ELE_TAA2_Admin'))])
            setAdminGpMemberId.add(gm.UserOrGroupId);
        
        //Retrieve TAA & TAA2 users
        for(Employee__c emp: [SELECT User__c FROM Employee__c WHERE Is_Active__c = true AND User__c != '' AND 
                              Leave_Policy__r.Leave_Policy_ID__c IN ('TAA','TAA2') AND
                              User__c NOT IN: (setAdminGpMemberId)])
            setTAAUsersId.add(emp.User__c);
            
        //Permission to access e-Leave Application
        objPermSet = [SELECT Id, name FROM PermissionSet WHERE Name = 'Leave_User_Prod'];
        
        checkPermission();
    }
    
    public void checkPermission(){
        listPermSetAss = [SELECT AssigneeId, Id, PermissionSetId FROM PermissionSetAssignment 
                          WHERE PermissionSetId =: objPermSet.id
                          AND AssigneeID NOT IN: (setAdminGpMemberId)
                          AND AssigneeId IN 
                          (   SELECT User__c FROM Employee__c 
                              WHERE Is_Active__c = true AND User__c != ''
                              AND Leave_Policy__r.Leave_Policy_ID__c IN ('TAA','TAA2')
                          )
                         ];
                                                      
        if(listPermSetAss != null && listPermSetAss.size() > 0){
            boolDisabled = FALSE;
        }
        else{
            boolDisabled = TRUE;
        }
    }
    
    public void enableAction(){
        //Assign e-leave Application Permission Set to TAA & TAA2 users
        List<PermissionSetAssignment> listToInsertPSA = new List<PermissionSetAssignment>();
        for(Id taaId : setTAAUsersId){
            listToInsertPSA.add(new PermissionSetAssignment(PermissionSetId = objPermSet.id, AssigneeId = taaId));
        }
            
        insert listToInsertPSA;     
         
        checkPermission();
    }
    
    public void disableAction(){
        //Removing e-leave Application Permission Set from TAA & TAA2 users
        if(listPermSetAss != null && listPermSetAss.size() > 0)
            delete listPermSetAss;
        checkPermission();
    }
}