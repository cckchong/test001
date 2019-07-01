@isTest
public with sharing class TestEmployeeAdminOverwriteNewController 
{
    
    /*
        Test: EmployeeAdmin Page New Botton
    */
    @isTest
    public static void EmployeeAdminOverwriteNew() {
        ApexPages.StandardController sc = null;
        PageReference page;
        EmployeeAdminOverwriteNewController EmployeeAdminNew = new EmployeeAdminOverwriteNewController(sc);
        page = EmployeeAdminNew.actionNew();
        system.assertNotEquals(null, page);
    }
      
}