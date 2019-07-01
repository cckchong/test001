@isTest
private class TestCustomerOrderLogController {
    
    static testMethod void testGetLogs() {
        Test.startTest();
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            // create a log at TGA feedback customer, insert, update again for getting the "from tga to customer" date value
            Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackReturnResubmit(null);
            insert log;
            update log;
            
            // case complete button click
            CustomerOrderLogButtonHandler.handleCaseCompletedClicked(String.valueOf(log.Id));
            
            // get ReportLog
            CustomerOrderLogController c = new CustomerOrderLogController();
            List<CustomerOrderLogController.ReportLog> logs = c.getLogs();
            
            // assert reportLogs should have 2 elements
            System.assertEquals(2, logs.size());
            
            // assert version 1 'Status' is 'Confirmed'
            CustomerOrderLogController.ReportLog logV1 = null;
            for (CustomerOrderLogController.ReportLog r : logs) {
                if (r.Version == 1) {
                    logV1 = r;
                }
            }
            
            System.assertEquals('Confirmed', logV1.Status);
            
        }

        Test.stopTest();
        
    }
        
    static testMethod void testRedirect() {
        Test.startTest();
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            CustomerOrderLogController c = new CustomerOrderLogController();
            
            PageReference pr = c.redirectToGlobalForTGA();
            System.assertNotEquals(null, pr);
            // make sure it won't return something like '/null?fcf=null'
            System.assert(!pr.getUrl().contains('null'));
            
        }
    
        Test.stopTest();
    }
    
}