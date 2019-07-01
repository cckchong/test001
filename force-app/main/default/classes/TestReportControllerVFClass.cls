@isTest(SeeAllData=true)
private class TestReportControllerVFClass {

	static testMethod void reportFound() {            
		      
        ReportController extn = new ReportController();
        String testReportName = 'SampleReportActiveUsers';
        List<Report> reports = [Select r.DeveloperName, r.Id From Report r Where DeveloperName =: testReportName limit 1];
        extn.reportID = reports.get(0).Id;
        Id ReportId = extn.getReportResult();
        
        List<Report> reportResults = [Select r.DeveloperName, r.Id From Report r Where DeveloperName =: testReportName limit 1];
        
        System.assertEquals(reportResults.get(0).Id, ReportId);     
    }

	static testMethod void noReportFound() {                
        ReportController extn = new ReportController();
         extn.reportID = '000000000011111111';
        Id ReportId = extn.getReportResult();
          	
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;
		for(Apexpages.Message msg:msgs) {
			if (msg.getDetail().contains('Report Not Found')) {
				b = true;
			}
		}
		//Assert the Page Message was Properly Displayed   
		System.assert(b);     
    }
    
}