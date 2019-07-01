@isTest(SeeAllData=true)

private class MTRButtonPermissionTest {

     static testMethod void permissionTest(){
     MTRButtonPermission.isOwner(Userinfo.getUserId());
     MTRButtonPermission.WIPButtonPermission();

    }
}