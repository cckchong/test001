/**
 * Test Class of LibraryFlsSearchValuesScheduledJob
 */
@isTest
private class TestLibraryFlsSearchValuesScheduledJob {
	
	
    static testMethod void myUnitTest() {
        LibraryFlsSearchValuesScheduledJob job = new LibraryFlsSearchValuesScheduledJob();
        job.execute(null);
    }
    
    static testmethod void test() {
		// Test.startTest();
		// Test.setMock(WebServiceMock.class, new TestLibraryFlsSearchValuesWsMockImpl());
		// // Schedule the test job
		// String CRON_EXP = '0 0 8 * * ?';
		// String jobId = System.schedule('TestLibraryFLSSearchValuesJob',
		// 								CRON_EXP, 
		// 								new LibraryFlsSearchValuesScheduledJob());
		// //Run second time to cover deletion of FLS Param 
		// String CRON_EXP2 = '0 0 9 * * ?';
		// String jobId2 = System.schedule('TestLibraryFLSSearchValuesJob2',
		// 								CRON_EXP2, 
		// 								new LibraryFlsSearchValuesScheduledJob());
		// // Get the information from the CronTrigger API object
		// CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		
		// // Verify the expressions are the same
		// //System.assertEquals(CRON_EXP, ct.CronExpression);
		
		// // Verify the job has not run
		// //System.assertEquals(0, ct.TimesTriggered);
		
		// // Verify the next time the job will run
		// //System.assertEquals(true, String.valueOf(ct.NextFireTime).contains('08:00:00'));
		// //System.assertNotEquals('TestLibraryFLSSearchValuesJob', [SELECT id, name FROM account WHERE id = :a.id].name);
		
		// Test.stopTest();
		
		//System.assertEquals('TestLibraryFLSSearchValuesJob', [SELECT Id, Name FROM Account WHERE Id = :a.Id].Name);
		
	}    
}