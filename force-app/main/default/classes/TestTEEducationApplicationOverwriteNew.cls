@isTest
public with sharing class TestTEEducationApplicationOverwriteNew
{

    @isTest
    public static void EduOverwriteNew() {
        ApexPages.StandardController sc = null;
        PageReference page;
        TEEducationApplicationOverwriteNewCtrl ctrl = new TEEducationApplicationOverwriteNewCtrl(sc);
        page = ctrl.redirectIfOnlySingleRecordType();
        system.assertNotEquals(null, page);
        
        page = ctrl.GoBtn();
        system.assertNotEquals(null, page);
        
        page = ctrl.CancelBtn();
        system.assertNotEquals(null, page);
    }
      
}