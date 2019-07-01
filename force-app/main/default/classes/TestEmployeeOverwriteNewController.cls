@isTest
public with sharing class TestEmployeeOverwriteNewController 
{
    
    /*
        Test: Employee Page New Botton
    */
    @isTest
    public static void EmployeeOverwriteNew() {
        ApexPages.StandardController sc = null;
        PageReference page;
        EmployeeOverwriteNewController EmployeeNew = new EmployeeOverwriteNewController(sc);
        page = EmployeeNew.actionNew();
        system.assertNotEquals(null, page);
    }
      
}