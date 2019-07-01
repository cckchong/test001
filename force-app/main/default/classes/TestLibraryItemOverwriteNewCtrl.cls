/*
* Test Class of LibraryItemOverwriteNewCtrl
*/
@isTest
private class TestLibraryItemOverwriteNewCtrl {

    static testMethod void unitTest() {
    
        Library_Item__c li = LibraryTestDataUtility.insertLibraryItem();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(li);
        
        LibraryItemOverwriteNewCtrl liCtrl = new LibraryItemOverwriteNewCtrl(sc);
        
        List<SelectOption> lso = liCtrl.availableRecordTypes;
        
        PageReference p = liCtrl.onload();
        pageReference p1 = liCtrl.GoBtn();
        pageReference p2 = liCtrl.CancelBtn();
        String str = liCtrl.preFix;
        
        liCtrl.isSalesforceOne =true;
        p = liCtrl.onload();
        p1 = liCtrl.GoBtn();
        p2 = liCtrl.CancelBtn();
        
        liCtrl.isRedirect =true;
        p = liCtrl.onload();
        p1 = liCtrl.GoBtn();
        p2 = liCtrl.CancelBtn();
        liCtrl.isRedirect =false;
        p = liCtrl.onload();
        p1 = liCtrl.GoBtn();
        p2 = liCtrl.CancelBtn();
        
        system.assertNotEquals(p1,null);
        
        liCtrl.isSalesforceOne =false;
        p = liCtrl.onload();
        p1 = liCtrl.GoBtn();
        p2 = liCtrl.CancelBtn();
        liCtrl.isRedirect =true;
        p = liCtrl.onload();
        p1 = liCtrl.GoBtn();
        p2 = liCtrl.CancelBtn();
        liCtrl.isRedirect =false;
        p = liCtrl.onload();
        p1 = liCtrl.GoBtn();
        p2 = liCtrl.CancelBtn();
        
        
        User u1 = LibraryTestDataUtility.createUser(Label.Library_Profile_TFEBAA);
        /*
        System.runAs(u1){
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            liCtrl.isSalesforceOne =true;
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            liCtrl.isRedirect =false;
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            system.assertNotEquals(p2,null);
        }
        
        
        User u2 = LibraryTestDataUtility.createUser(Label.Library_Profile_TFEFA);
        System.runAs(u2){
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            liCtrl.isSalesforceOne =true;
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            liCtrl.isRedirect =false;
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            system.assertNotEquals(p2,null);
        }
        
        User u3 = LibraryTestDataUtility.createUser(Label.Library_Profile_TFEBA);
        System.runAs(u3){
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            liCtrl.isSalesforceOne =true;
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            liCtrl.isRedirect =false;
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            system.assertNotEquals(p2,null);
        }
        
        User u4 = LibraryTestDataUtility.createUser(Label.Library_Profile_TFEFSU);
        System.runAs(u4){
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            liCtrl.isSalesforceOne =true;
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            liCtrl.isRedirect =false;
            p = liCtrl.onload();
            p1 = liCtrl.GoBtn();
            p2 = liCtrl.CancelBtn();
            system.assertNotEquals(p2,null);
        } */
        
    }
    
}