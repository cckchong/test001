@isTest
public with sharing class TestEmployeeTrigger
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
         Test:Change Approver
     */
     @IsTest
     public static void changeApprover() {
         Preparation(false);          
         Test.startTest();
         for ( Employee__c employee : EmployeeMap.values() ){             
             employee.Approver_1__c = UserMap.get('actapr1').id;
             employee.Approver_2__c = UserMap.get('actapr2').id;
             employee.Approver_3__c = UserMap.get('actapr3').id;
             employee.Approver_4__c = UserMap.get('actapr4').id;             
             employee.Acting_Approver_1__c = UserMap.get('apr1').id;
             employee.Acting_Approver_2__c = UserMap.get('apr2').id;
             employee.Acting_Approver_3__c = UserMap.get('apr3').id;
             employee.Acting_Approver_4__c = UserMap.get('apr4').id;             
         }
         update  EmployeeMap.values();
         
         for ( Employee__c employee : EmployeeMap.values() ){         
             system.assertEquals( UserMap.get('actapr1').id, employee.Approver_1__c );
             system.assertEquals( UserMap.get('actapr2').id, employee.Approver_2__c );
             system.assertEquals( UserMap.get('actapr3').id, employee.Approver_3__c );
             system.assertEquals( UserMap.get('actapr4').id, employee.Approver_4__c );             
             system.assertEquals( UserMap.get('apr1').id, employee.Acting_Approver_1__c );
             system.assertEquals( UserMap.get('apr2').id, employee.Acting_Approver_2__c );
             system.assertEquals( UserMap.get('apr3').id, employee.Acting_Approver_3__c );
             system.assertEquals( UserMap.get('apr4').id, employee.Acting_Approver_4__c );
         }
         Test.stopTest();   
     }
     
     /*
         Test: Duplicate User
     */
     @IsTest
     public static void duplicateUser() {
         Employee__c employee =null;
         Preparation(false);
         
         Test.startTest();
         for ( Employee__c reader : EmployeeMap.values() ){             
             if (reader.First_Name__c == 'user2') {
                 employee = reader;
                 break;
             }
         }
         
         if ( employee != null ){
             employee.user__c = UserMap.get('user1').id;
             try {
                 update  employee;
             }
             catch(DmlException e) {
                 for (Integer i = 0; i < e.getNumDml(); i++) {
                     system.assertEquals(Label.ELeave_Error_Duplicate_User, e.getDmlMessage(i) );
                 }
             } 
         }
         
    }
    
    /*
         Test: InActive User
     */
     @IsTest
     public static void inactiveUser() {
         Employee__c employee = null;
         Preparation(false);
         List <User> userList = new List <User>();
         User [] usrs = new User [9];
         Integer userSize = usrs.size();
         
         Test.startTest();
         for ( Employee__c reader : EmployeeMap.values() ){             
             reader.Approver_1__c = null;
             reader.Approver_2__c = null;
             reader.Approver_3__c = null;
             reader.Approver_4__c = null;
             reader.Acting_Approver_1__c = null;
             reader.Acting_Approver_2__c = null;
             reader.Acting_Approver_3__c = null;
             reader.Acting_Approver_4__c = null;
             reader.user__c = null;             
         }
         
         for ( Integer i = 0; i < userSize; i++ ){
             usrs[i] = EleavePreparation.userCreation ('testusr'+String.valueof(i), String.valueof(i)+'testusr@testclass.com', EleavePreparation.systemAdminprofile.Id, TestEleavePreparation.USER_GLOBAL, TestEleavePreparation.USER_REGION, TestEleavePreparation.USER_LOCAL, TestEleavePreparation.USER_GRADE, TestEleavePreparation.USER_DEPT, TestEleavePreparation.USER_FUNCTION, TestEleavePreparation.USER_LANG, TestEleavePreparation.USER_ADMIN_REGION, TestEleavePreparation.USER_ADMIN_DEPT, TestEleavePreparation.USER_CREATE_PAGE );
             usrs[i].isActive = false;
             userList.add(usrs[i]);
         }
         insert userList;
         
         for ( User reader : userList ) {
             for ( Integer i = 0; i < userSize; i++ ){
                 if ( reader == usrs[i]){
                     usrs[i] = reader;
                 }
             }
         }
         
         
         for ( Employee__c reader : EmployeeMap.values() ){
             employee = reader;
         }
         employee.Approver_1__c = usrs[1].id;
         employee.Approver_2__c = usrs[2].id;
         employee.Approver_3__c = usrs[3].id;
         employee.Approver_4__c = usrs[4].id;
         employee.Acting_Approver_1__c = usrs[5].id;
         employee.Acting_Approver_2__c = usrs[6].id;
         employee.Acting_Approver_3__c = usrs[7].id;
         employee.Acting_Approver_4__c = usrs[8].id;
         
         
         
         if ( employee != null ){             
             try {
                 update employee;
             }
             catch(DmlException e) {
                 for (Integer i = 0; i < e.getNumDml(); i++) {
                     system.assertEquals(Label.ELeave_Error_Inactive_user, e.getDmlMessage(i) );
                 }
             } 
         }
        
         Test.stopTest();   
     }

     
}