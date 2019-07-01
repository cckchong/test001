@isTest(SeeAllData=true)

private class QTRButtonPermissionTest {

     static testMethod void permissionTest(){
        QTRButtonPermission.WIPButtonPermission();
        QTRButtonPermission.isOwner(Userinfo.getUserId());

    }
}