public with sharing class ReportFinderUtil {

  public ReportFinderUtil(){}
  
  public String findReportId(String reportName){
    
    Sobject myReport = [select Id,Name From Report Where Name=:reportName];
      if (myReport != null){
          return myReport.Id;
      }
      else{
      return '';   
      }
   }
  
}