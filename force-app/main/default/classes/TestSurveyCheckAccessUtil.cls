@isTest
private class TestSurveyCheckAccessUtil {
	
	@isTest static void testCanOwnerTakeSurvey() {

		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String ownerId = surveyTestingUtil.ownerId;

		User u = [Select id, name, username from User where id = :ownerId];
		System.runAs(u) {
			SurveyCheckAccessUtil checkAccessUtil = new SurveyCheckAccessUtil(ownerId, surveyId);
			boolean result = checkAccessUtil.canTakeSurvey();
			System.assertEquals(true, result);		
		}
	}

	@isTest static void testCanAdminTakeSurvey() {

		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String adminId = surveyTestingUtil.adminId;

		User u = [Select id, name, username from User where id = :adminId];
		System.runAs(u) {
			SurveyCheckAccessUtil checkAccessUtil = new SurveyCheckAccessUtil(adminId, surveyId);
			boolean result = checkAccessUtil.canTakeSurvey();
			System.assertEquals(true, result);
		}
	}

	@isTest static void testCanTakerTakeSurvey() {

		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String takerId = surveyTestingUtil.taker1Id;

		User u = [Select id, name, username from User where id = :takerId];
		System.runAs(u) {
			SurveyCheckAccessUtil checkAccessUtil = new SurveyCheckAccessUtil(takerId, surveyId);
			boolean result = checkAccessUtil.canTakeSurvey();
			System.assertEquals(true, result);
		}
	}

	@isTest static void testCanPublicGroupTakeSurvey() {

		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String taker2Id = surveyTestingUtil.taker2Id;
		String taker3Id = surveyTestingUtil.taker3Id;

		SurveyCheckAccessUtil checkAccessUtil = null;

		User u1 = [Select id, name, username from User where id = :taker2Id];
		System.runAs(u1) {
			checkAccessUtil = new SurveyCheckAccessUtil(taker2Id, surveyId);
			boolean result1 = checkAccessUtil.canTakeSurvey();
			System.assertEquals(true, result1);
		}

		User u2 = [Select id, name, username from User where id = :taker3Id];
		System.runAs(u2) {
			checkAccessUtil = new SurveyCheckAccessUtil(taker3Id, surveyId);
			boolean result2 = checkAccessUtil.canTakeSurvey();
			System.assertEquals(true, result2);
		}
	}

	@isTest static void testCanUnauthorizedUserTakeSurvey() {

		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String unAuthUserId = surveyTestingUtil.unAuthUserId;

		User u = [Select id, name, username from User where id = :unAuthUserId];
		System.runAs(u) {
			SurveyCheckAccessUtil checkAccessUtil = new SurveyCheckAccessUtil(unAuthUserId, surveyId);
			boolean result = checkAccessUtil.canTakeSurvey();
			System.assertEquals(false, result);
		}
	}
	
	@isTest static void testCanOwnerManageSurvey() {
		
		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String ownerId = surveyTestingUtil.ownerId;

		User u = [Select id, name, username from User where id = :ownerId];
		System.runAs(u) {
			SurveyCheckAccessUtil checkAccessUtil = new SurveyCheckAccessUtil(ownerId, surveyId);
			boolean result = checkAccessUtil.canManageSurvey();
			System.assertEquals(true, result);	
		}			
	}
	
	@isTest static void testCanAdminManageSurvey() {
		
		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String adminId = surveyTestingUtil.adminId;

		User u = [Select id, name, username from User where id = :adminId];
		System.runAs(u) {
			SurveyCheckAccessUtil checkAccessUtil = new SurveyCheckAccessUtil(adminId, surveyId);
			boolean result = checkAccessUtil.canManageSurvey();
			System.assertEquals(true, result);
		}
	}

	@isTest static void testCanTakerManageSurvey() {

		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String takerId = surveyTestingUtil.taker1Id;
		String taker2Id = surveyTestingUtil.taker2Id;
		String taker3Id = surveyTestingUtil.taker3Id;

		SurveyCheckAccessUtil checkAccessUtil = null;

		User u1 = [Select id, name, username from User where id = :takerId];
		System.runAs(u1) {
			checkAccessUtil = new SurveyCheckAccessUtil(takerId, surveyId);
			boolean result1 = checkAccessUtil.canManageSurvey();
			System.assertEquals(false, result1);
		}

		User u2 = [Select id, name, username from User where id = :taker2Id];
		System.runAs(u2) {	
			checkAccessUtil = new SurveyCheckAccessUtil(taker2Id, surveyId);
			boolean result2 = checkAccessUtil.canManageSurvey();
			System.assertEquals(false, result2);
		}

		User u3 = [Select id, name, username from User where id = :taker3Id];
		System.runAs(u3) {
			checkAccessUtil = new SurveyCheckAccessUtil(taker3Id, surveyId);
			boolean result3 = checkAccessUtil.canManageSurvey();
			System.assertEquals(false, result3);
		}
	}

	@isTest static void testCanUnauthorizedUserManageSurvey() {

		SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
		String surveyId = surveyTestingUtil.surveyId;
		String unAuthUserId = surveyTestingUtil.unAuthUserId;

		User u = [Select id, name, username from User where id = :unAuthUserId];
		System.runAs(u) {
			SurveyCheckAccessUtil checkAccessUtil = new SurveyCheckAccessUtil(unAuthUserId, surveyId);
			boolean result = checkAccessUtil.canManageSurvey();
			System.assertEquals(false, result);
		}
	}
}