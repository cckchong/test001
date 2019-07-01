public with sharing class viewSurveyResultsComponentController {

    public String viewSurveyId {get;set;}

    public String reportId {get;set;}
    //public PageReference results;
        
    // visualforce page that renders chart and embed into iframe
    public pageReference getSurveyReportResult() {
        viewSurveyId = viewSurveyId.substring(0,15);
//        return new PageReference('/apex/viewSurveyResultsReportPage?reportId=' + reportId + '&surveyId=' + viewSurveyId);
        PageReference pr = new PageReference('/apex/viewSurveyResultsReportPage');
        pr.getParameters().put('reportId', reportId);
        pr.getParameters().put('surveyId', viewSurveyId);
        return pr;
    }
        
    public viewSurveyResultsComponentController() {
        ReportFinderUtil rfu = new ReportFinderUtil();
        reportId = rfu.findReportId('Survey with Questions and Responses'); 
    }

// commented out by Connie  
/*     
public pageReference getResults()
{
    viewSurveyId = viewSurveyId.substring(0,15);
    return new PageReference('/' + reportId + '?pv0=' + viewSurveyId);
}

private static testmethod void testResultController()
{
    Survey__c mySurvey = new Survey__c();
    mySurvey.Submit_Response__c = 'empty';  
    insert mySurvey;
    
    viewSurveyResultsComponentController vsr = new viewSurveyResultsComponentController();
    vsr.viewSurveyId = mySurvey.Id;
    
    String mySurveyId = mySurvey.Id;
    PageReference pageRef = new PageReference ('/' + vsr.reportId + '?pv0=' + mySurveyId.substring(0,15));
    System.assertEquals(pageRef.getURL(),vsr.getResults().getURL());
    
}*/

    // added test case by Connie
    private static testmethod void testGetSurveyReportResultPageReference() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;

        viewSurveyResultsComponentController vsr = new viewSurveyResultsComponentController();
        vsr.viewSurveyId = surveyId;
        PageReference pr = vsr.getSurveyReportResult();
        String expectedPageUrl = '/apex/viewSurveyResultsReportPage?reportId=' + vsr.reportId + '&surveyId=' + vsr.viewSurveyId;
        System.assertEquals(expectedPageUrl, pr.getURL());
    }

}