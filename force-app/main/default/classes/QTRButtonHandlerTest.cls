@isTest(SeeAllData=true)

private class QTRButtonHandlerTest {

     static testMethod void mytest(){
        Quotation_System_Task_Request__c newRequest = new Quotation_System_Task_Request__c(
            Type_of_Request__c = 'Add Existing Brand for User',
            Priority__c = 'LOW',
            Quotation__c = '111000111',
            Descriptions_and_Comments__c = 'Hello',
            Is_Submit_Clicked__c = true
            );
         insert newRequest;
         
         newRequest = [SELECT id FROM Quotation_System_Task_Request__c WHERE id =: newRequest.id];
         
        QTRButtonHandler.handleSubmitClicked(newRequest.id);
        QTRButtonHandler.handleCompleteClicked(newRequest.id);
        QTRButtonHandler.handleCancelClicked(newRequest.id);

    }
}