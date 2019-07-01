/**
 * @description To handle employ access right
 */
public without sharing class EmployeeAdministratorTriggerHandler {
    
    public static final String Manual =  Schema.Employee_Administrator__Share.RowCause.Manual;
    public static final String ApproverAccessRight = 'read';
    public static final String UserAccessRight = 'Edit';    
    /**
     * @description EmployeeAdministratorTriggerHandler constructor 
    */     
    public EmployeeAdministratorTriggerHandler ( ) {}
    
   /**
    * @description To gain access right to emplayee administrator when the employee record is updated
    */
    public void afterUpdate ( Map <Id, Employee_Administrator__c> newEmployeeAdministratorMap, Map<Id, Employee_Administrator__c> oldEmployeeAdministratorMap) {

        Map <Id, Employee_Administrator__c> EmployeeAdministratorMap = new Map <Id, Employee_Administrator__c>();        
        List <Employee_Administrator__Share> employeeAdministratorShareList = new List <Employee_Administrator__Share> ();
        List <Employee_Administrator__Share> toBeDelEmployeeAdminShareList = new List <Employee_Administrator__Share>();
        List <Employee_Administrator__c> employeeAdministratorList = new List <Employee_Administrator__c>();
        Set <String> existingEmployeeAdminShareSetID = new Set <String>();
        
        for (Employee_Administrator__c reader : newEmployeeAdministratorMap.values()){
            if ((reader.Employee_Administrator__c != oldEmployeeAdministratorMap.get(reader.id).Employee_Administrator__c) ||
                (reader.is_active__c != oldEmployeeAdministratorMap.get(reader.id).is_active__c)
            ){
                EmployeeAdministratorMap.put(reader.id, reader);
            }
        }
        
        for ( Employee_Administrator__Share reader : 
            [select id, ParentId, UserOrGroupId, AccessLevel, RowCause from Employee_Administrator__Share where ParentId  in :EmployeeAdministratorMap.keyset()] ) {                 
                if ( reader.RowCause ==  Manual ) {
                    toBeDelEmployeeAdminShareList.add(reader);
                }
                else {
                    existingEmployeeAdminShareSetID.add(String.Valueof(reader.ParentId)+String.Valueof(reader.UserOrGroupId).left(15) );
                }
        }
        
        for (Employee_Administrator__c reader : EmployeeAdministratorMap.values()){
            if ( reader.Administrator__c != null && reader.Is_User_Active__c && reader.Is_Active__c){
                if ( !existingEmployeeAdminShareSetID.contains( String.valueof(reader.id) + String.valueof(reader.Administrator__c) ) ) {
                    employeeAdministratorShareList.add(EmployeeAdministratorShare(reader.id, reader.Administrator__c, UserAccessRight));
                    employeeAdministratorList.add(reader);
                }
            }
        }
        
        if ( !toBeDelEmployeeAdminShareList.isempty() ){
            delete toBeDelEmployeeAdminShareList;
        }
         
        if ( !employeeAdministratorShareList.isempty() ){
            insert employeeAdministratorShareList;
            try{
                insert employeeSharingList(employeeAdministratorList);
            }
            catch(DmlException e) {} 
        }
    }
    
    /**
    * @description To gain access right to emplayee administrator
    */
    public void afterInsert (List<Employee_Administrator__c> newEmployeeAdministratoList ){
        
        List <Employee_Administrator__Share> employeeAdministratorShareList = new List <Employee_Administrator__Share> ();
        List <Employee_Administrator__c> employeeAdministratorList = new List <Employee_Administrator__c>();
        
        for (Employee_Administrator__c reader : newEmployeeAdministratoList){
            if (reader.Administrator__c != null && reader.is_active__c && reader.is_user_active__c){
                if(reader.OwnerId != reader.Administrator__c) {
                	employeeAdministratorShareList.add(EmployeeAdministratorShare(reader.id, reader.Administrator__c, UserAccessRight));
                }
                employeeAdministratorList.add(reader);
            }
        }
        
        if(!employeeAdministratorShareList.isempty()){
            insert employeeAdministratorShareList;
            try{
                insert employeeSharingList(employeeAdministratorList);
            }
            catch(DmlException e) {} 
        }
    }
    
    Private  List<Employee__Share> employeeSharingList (List <Employee_Administrator__c> employeeAdministratorList){
        List<Employee__Share> employeeSharingList = new List<Employee__Share>();        
        for (Employee_Administrator__c reader : employeeAdministratorList){
            employeeSharingList.add(EmployeeShare (reader.employee__c, reader.Administrator__c, UserAccessRight));
        }
        return employeeSharingList ;
    }
    
    /**
    * @description To create a sharing record to employee
    */
    Private Employee_Administrator__Share EmployeeAdministratorShare ( Id pid, Id uid, String AccessLevel  )
    {
        Employee_Administrator__Share  employeeAdministratorShare = new Employee_Administrator__Share ();
        employeeAdministratorShare.ParentId =pid ;
        employeeAdministratorShare.UserOrGroupId = uid ;
        employeeAdministratorShare.AccessLevel =  AccessLevel  ;
        return employeeAdministratorShare ;
    }    
    
    Private Employee__Share EmployeeShare ( Id pid, Id uid, String AccessLevel  )
    {
        Employee__Share  employeeShare = new Employee__Share ();
        employeeShare.ParentId =pid ;
        employeeShare.UserOrGroupId = uid ;
        employeeShare.AccessLevel =  AccessLevel  ;
        return employeeShare ;
    }
}