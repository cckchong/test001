@isTest
private class TestGSurveyController {
		
	@isTest static void testDeleteSurvey(){
	    SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String ownerId = surveyTestingUtil.ownerId;
		
		User u = [Select ID, Name, UserName From User Where Id = :ownerId];
		System.runAs(u) {
			Apexpages.currentPage().getParameters().put('uId', u.id);
		    Survey__c survey = [Select Id, Name From Survey__c Where ID = :surveyId];
		    ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
		    GSurveysController sc = new GSurveysController(stdSurvey);
		    sc.surveyDelete = surveyId;
		    System.assertEquals(GSurveysController.deleteSurvey(surveyId), 'Survey ' + survey.Name + ' is deleted.');
		}
	}

    @isTest static void testMakeNewSurvey(){
	    SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String ownerId = surveyTestingUtil.ownerId;
	    
	    User u = [Select ID, Name, UserName From User Where Id = :ownerId];
		System.runAs(u) {
			Apexpages.currentPage().getParameters().put('uId', u.id);
		    Survey__c survey = [Select Id, Name From Survey__c Where ID = :surveyId];
		    ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
		    GSurveysController sc = new GSurveysController(stdSurvey);
		    System.assert(sc.makeNewSurvey()==null);

		    sc.surveySite = '--SELECT SITE--';
		    sc.newSurveyName = 'TestMakeNewSurvey';
		    system.assert(sc.makeNewSurvey()==null);
		    
		    sc.surveySite = 'blah';
		    System.assert(sc.makeNewSurvey() != null);
		    sc.doSurveyReset();    
		} 
	}

    @isTest static void testGSurveysController(){
	    SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String ownerId = surveyTestingUtil.ownerId;
	    
	    User u = [Select ID, Name, UserName From User Where Id = :ownerId];
		System.runAs(u) {
			Apexpages.currentPage().getParameters().put('uId', u.id);
		    Survey__c survey = [Select Id, Name From Survey__c Where ID = :surveyId];
		    ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
		    GSurveysController sc = new GSurveysController(stdSurvey);
		    System.assert(sc.myAllSurveys.size()>0);   
		} 
	}  

	@isTest static void testCopySurvey() {
		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String ownerId = surveyTestingUtil.ownerId;
		String newSurveyId = '';
		
		User u = [Select ID, Name, UserName From User Where Id = :ownerId];
		System.runAs(u) {
			Apexpages.currentPage().getParameters().put('uId', u.id);
		    Survey__c survey = [Select Id, Name From Survey__c Where ID = :surveyId limit 1];
		    ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
		    GSurveysController sc = new GSurveysController(stdSurvey);
		    sc.surveyCopy = surveyId;
		    GSurveysController.copySurveyResult surveyResult = GSurveysController.copySurvey(surveyId);

		    System.assertEquals('', surveyResult.errorMessage);
		    System.assertEquals(true, surveyResult.status);

		    String newUrl = '/apex/SurveyManagerPage?id=';
		    System.assert(surveyResult.url != null);
		    System.assert(surveyResult.url.contains(newUrl));		

		    Integer idx = surveyResult.url.indexOf('=');
		    if (idx >= 0) {
		    	newSurveyId = surveyResult.url.substring(idx+1);
			}
		}

		Survey__c verifySurvey = [Select Id, Name, Survey_Toggle__c, Survey_Admin_List_1__c, 
									Survey_Admin_List_2__c, Survey_Admin_List_3__c,
									Survey_Admin_List_4__c, Survey_Admin_List_5__c
								  	From Survey__c Where ID = :newSurveyId limit 1];

	    // verify survey toggle of the new copy survey is false
	    System.assertEquals(false, verifySurvey.Survey_Toggle__c);
	 	// verify survey admin list 2,3,4,5 are blank 
	 	// admin list 1 stores owner id
	    System.assertEquals(ownerId + SurveyAdminListHelper.ADMIN_LIST_SEPARATOR, verifySurvey.Survey_Admin_List_1__c);
	    System.assertEquals(null, verifySurvey.Survey_Admin_List_2__c);
	    System.assertEquals(null, verifySurvey.Survey_Admin_List_3__c);
	    System.assertEquals(null, verifySurvey.Survey_Admin_List_4__c);
	    System.assertEquals(null, verifySurvey.Survey_Admin_List_5__c);
	}
}