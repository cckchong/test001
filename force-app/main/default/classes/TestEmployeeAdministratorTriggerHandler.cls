@isTest
public with sharing class TestEmployeeAdministratorTriggerHandler
{
    
    public static Map<String, User> UserMap ;
    public static Map<String, Employee__c> EmployeeMap ;   
    public static TestEleavePreparation  EleavePreparation;
     
    public static void Preparation(Boolean isSeeAllData) {
        EleavePreparation = new TestEleavePreparation (isSeeAllData);
        UserMap = EleavePreparation.getUserMap();
        EmployeeMap = EleavePreparation.getEmployeeMap(UserMap);
    }
    
     /*
         Test: Add a new employee to Employee Administrator
     */
     @IsTest
     public static void  addEmployee() {
     
         Employee__c emp1 = null;
         Employee__c emp2 = null;         
         Preparation(false);          
         Test.startTest();

         for ( Employee__c reader: EmployeeMap.values() ) {
             if ( emp1 == null && reader.user__c != null ){
                 emp1 = reader;
             }
             emp2 = reader;
         }
         
         Employee_Administrator__c employeeAdministrator = new Employee_Administrator__c(
             Employee_Administrator__c = emp1.id,
             Employee__c = emp2.id
         );
         insert employeeAdministrator;
         
         Test.stopTest();   
     }
     
     /*
         Test: update employee records
     */
     @IsTest
     public static void  updateEmployee() {
     
         Employee__c emp1 = null;
         Employee__c emp2 = null;
         Employee__c emp3 = null;
         Preparation(false);          
         Test.startTest();

         for ( Employee__c reader: EmployeeMap.values() ) {

             if (emp2 != null ){
                 emp3 = reader;
             }

             if (emp1 != null ){
                 emp2 = reader;
             }
             
             if ( emp1 == null && reader.user__c != null ){
                 emp1 = reader;
             }
             
         }
         
         Employee_Administrator__c employeeAdministrator = new Employee_Administrator__c(
             Employee_Administrator__c = emp1.id,
             Employee__c = emp2.id
         );
         insert employeeAdministrator;
         
         employeeAdministrator.Employee__c = emp1.id;
         update employeeAdministrator;
         
         Test.stopTest();   
     }
      
     
}