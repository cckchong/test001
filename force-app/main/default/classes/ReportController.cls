public without sharing class ReportController {
	
    public String reportName {get; set;}
    
    public Id recordID { get; set; }
    
    public Id reportID { get; set; }
    
    public Id getReportResult() {    	
        try {
            List<Report> reportList = [Select Id, DeveloperName, Name from Report where Id = :reportID limit 1];
            if (reportList.size() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Report Not Found'));
                
            } else {
                return reportList.get(0).Id;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }        
        return null;
    }
}