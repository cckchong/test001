@isTest(SeeAllData=true)

private class MTRButtonHandlerTest {

     static testMethod void mytest(){
        Movex_Task_Request__c newRequest = new Movex_Task_Request__c(
            Task_Category__c = 'BND',
            Priority__c = 'LOW',
            Request_delivery_date__c= System.now().date(),
            Descriptions_and_Comments__c = 'Hello',
            Is_Submit_Clicked__c = true
            );
         insert newRequest;
         
         newRequest = [SELECT id FROM Movex_Task_Request__c WHERE id =: newRequest.id];
         
        MTRButtonHandler.handleSubmitClicked(newRequest.id);
        MTRButtonHandler.handleCompleteClicked(newRequest.id);
        MTRButtonHandler.handleWIPClicked(newRequest.id);
        MTRButtonHandler.handleCancelClicked(newRequest.id);
        //MTRButtonHandler.handleRecallClicked(newRequest.id);
    }
}