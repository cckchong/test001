@isTest
public with sharing class TestTEExpenseAppOverwriteNewController
{

    @isTest
    public static void ExpOverwriteNew() {
        ApexPages.StandardController sc = null;
        PageReference page;
        TEExpenseAppOverwriteNewController ctrl = new TEExpenseAppOverwriteNewController(sc);
        page = ctrl.redirectIfOnlySingleRecordType();
        system.assertEquals(null, page);
        
        for ( RecordType rt : [SELECT Id, DeveloperName FROM RecordType where SobjectType = :TEConstant.EXPENSE_APPLICATION_OBJECT_NAME and IsActive = true Limit 1] )
        {
             ctrl.selectedRecordType = rt.id;
        }
        page = ctrl.GoBtn();
        system.assertNotEquals(null, page);
        
        page = ctrl.CancelBtn();
        system.assertNotEquals(null, page);
    }
      
}