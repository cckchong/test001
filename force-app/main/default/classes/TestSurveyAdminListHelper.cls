@isTest
private class TestSurveyAdminListHelper {
	
	@isTest static void testAppendAdminId() {
		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String adminId = surveyTestingUtil.adminId;
		
		List<User> listAdminUser = [Select Id From User Where Alias like 'Ad%'];
		Survey__c survey = [Select Id, Survey_Admin_List_1__c 
									, Survey_Admin_List_2__c, Survey_Admin_List_3__c 
									, Survey_Admin_List_4__c, Survey_Admin_List_5__c 
							From Survey__c 
							Where Id = :surveyId limit 1];
		User u = [Select id, name, username from User where id = :adminId];
		System.runAs(u) {
			for (User adminUser : listAdminUser) {
				SurveyAdminListHelper.appendAdminId(survey, adminUser.Id);
			}
		}
		for (User adminUser : listAdminUser) {
			System.assert(SurveyAdminListHelper.isSurveyAdminListContainUserId(survey, adminUser.Id));
		}
	}
	
	@isTest static void testDeleteAdminId() {
		
		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String adminId = surveyTestingUtil.adminId;
		
		List<User> listAdminUser = [Select Id From User Where Alias like 'Ad%'];
		Survey__c survey = [Select Id, Survey_Admin_List_1__c 
									, Survey_Admin_List_2__c, Survey_Admin_List_3__c 
									, Survey_Admin_List_4__c, Survey_Admin_List_5__c 
							From Survey__c 
							Where Id = :surveyId limit 1];
		User u = [Select id, name, username from User where id = :adminId];
		System.runAs(u) {
			survey.Survey_Admin_List_2__c = '';
			survey.Survey_Admin_List_3__c = '';
			survey.Survey_Admin_List_4__c = '';
			survey.Survey_Admin_List_5__c = '';
			for (Integer i = 0; i < 11; i++) {
				survey.Survey_Admin_List_1__c += listAdminUser.get(i).Id + ';';	
				System.debug('1: ' + survey.Survey_Admin_List_1__c.length());
			}
			for (Integer i = 11; i < 24; i++) {
				survey.Survey_Admin_List_2__c += listAdminUser.get(i).Id + ';';				
				System.debug('2: ' + survey.Survey_Admin_List_2__c.length());
			}
			for (Integer i = 24; i < 37; i++) {
				survey.Survey_Admin_List_3__c += listAdminUser.get(i).Id + ';';				
				System.debug('3: ' + survey.Survey_Admin_List_3__c.length());
			}
			for (Integer i = 37; i < 50; i++) {
				survey.Survey_Admin_List_4__c += listAdminUser.get(i).Id + ';';	
				System.debug('4: ' + survey.Survey_Admin_List_4__c.length());
			}
			for (Integer i = 50; i < 55; i++) {
				survey.Survey_Admin_List_5__c += listAdminUser.get(i).Id + ';';				
				System.debug('5: ' + survey.Survey_Admin_List_5__c.length());
			}
			update survey;

			for (User adminUser : listAdminUser) {
				SurveyAdminListHelper.deleteAdminId(survey, adminUser.Id);
			}

			for (User adminUser : listAdminUser) {
				System.assert(!SurveyAdminListHelper.isSurveyAdminListContainUserId(survey, adminUser.Id));
			}
		}
	}
	
}