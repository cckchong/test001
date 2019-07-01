global without sharing class QTRButtonPermission {

    webservice static boolean isOwner(String ownerId){
        if ( ownerId.left(15) == Userinfo.getUserId().left(15)) {
            return true;
        }
        return false;
    }

     webservice static boolean WIPButtonPermission(){

    List<PermissionSetAssignment> currentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId
                                                       FROM PermissionSetAssignment
                                                       WHERE AssigneeId = :Userinfo.getUserId() ];

    system.debug('currentUserPerSet' + currentUserPerSet);

    for (PermissionSetAssignment psa: currentUserPerSet)
    {
        system.debug('psa.PermissionSet.Name' + psa.PermissionSet.Name);
        if(psa.PermissionSet.Name.equals('QTR_Complete_Case') || psa.PermissionSet.Name.equals('Quotation_System_Task_Request_Complete_Case')){

            return true;
        }
    }return false;
    }
}