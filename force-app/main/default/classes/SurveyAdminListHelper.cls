public without sharing class SurveyAdminListHelper {

	public static final String ADMIN_LIST_SEPARATOR = ';';
	private static final Integer MAX_TEXT_LENGTH = 255;

	public static Boolean isSurveyAdminListContainUserId(Survey__c survey, String userId) {
		
		System.debug('(isSurveyAdminListContainUserId) userId: ' + userId);
		System.debug('(isSurveyAdminListContainUserId) found in list 1: ' + 
				(survey.Survey_Admin_List_1__c != null && survey.Survey_Admin_List_1__c.contains(userId)));
		System.debug('(isSurveyAdminListContainUserId) found in list 2: ' + 
				(survey.Survey_Admin_List_2__c != null && survey.Survey_Admin_List_2__c.contains(userId))); 
		System.debug('(isSurveyAdminListContainUserId) found in list 3: ' + 
				(survey.Survey_Admin_List_3__c != null && survey.Survey_Admin_List_3__c.contains(userId))); 
		System.debug('(isSurveyAdminListContainUserId) found in list 4: ' + 
				(survey.Survey_Admin_List_4__c != null && survey.Survey_Admin_List_4__c.contains(userId))); 
		System.debug('(isSurveyAdminListContainUserId) found in list 5: ' + 
				(survey.Survey_Admin_List_5__c != null && survey.Survey_Admin_List_5__c.contains(userId)));

		return ((survey.Survey_Admin_List_1__c != null && survey.Survey_Admin_List_1__c.contains(userId))
			|| (survey.Survey_Admin_List_2__c != null && survey.Survey_Admin_List_2__c.contains(userId))
			|| (survey.Survey_Admin_List_3__c != null && survey.Survey_Admin_List_3__c.contains(userId))
			|| (survey.Survey_Admin_List_4__c != null && survey.Survey_Admin_List_4__c.contains(userId))
			|| (survey.Survey_Admin_List_5__c != null && survey.Survey_Admin_List_5__c.contains(userId)));
	}

	public static void appendAdminId(Survey__c survey, String userId) {

		if (String.IsNotBlank(userId) && !SurveyAdminListHelper.isSurveyAdminListContainUserId(survey, userId)) {
			Integer userLen = userId.length();
			System.debug('(appendAdminId) User Id: ' + userId + ', user length: ' + userLen);

			if (String.IsBlank(survey.Survey_Admin_List_1__c)) {
				survey.Survey_Admin_List_1__c = '';
			}
			if (String.IsBlank(survey.Survey_Admin_List_2__c)) {
				survey.Survey_Admin_List_2__c = '';
			}
			if (String.IsBlank(survey.Survey_Admin_List_3__c)) {
				survey.Survey_Admin_List_3__c = '';
			}
			if (String.IsBlank(survey.Survey_Admin_List_4__c)) {
				survey.Survey_Admin_List_4__c = '';
			}
			if (String.IsBlank(survey.Survey_Admin_List_5__c)) {
				survey.Survey_Admin_List_5__c = '';
			}

			System.debug('(appendAdminId) survey admin 1 list\'s length: ' + (survey.Survey_Admin_List_1__c.length() + userLen + 1));
			System.debug('(appendAdminId) survey admin 2 list\'s length: ' + (survey.Survey_Admin_List_2__c.length() + userLen + 1));
			System.debug('(appendAdminId) survey admin 3 list\'s length: ' + (survey.Survey_Admin_List_3__c.length() + userLen + 1));
			System.debug('(appendAdminId) survey admin 4 list\'s length: ' + (survey.Survey_Admin_List_4__c.length() + userLen + 1));
			System.debug('(appendAdminId) survey admin 5 list\'s length: ' + (survey.Survey_Admin_List_5__c.length() + userLen + 1));

			if ((survey.Survey_Admin_List_1__c.length() + userLen + 1) <= MAX_TEXT_LENGTH) {
				survey.Survey_Admin_List_1__c += userId + ADMIN_LIST_SEPARATOR;
				System.debug('(appendAdminId) append user id to survey admin 1 list');
			} else if ((survey.Survey_Admin_List_2__c.length() + userLen + 1) <= MAX_TEXT_LENGTH) {
				survey.Survey_Admin_List_2__c += userId + ADMIN_LIST_SEPARATOR;
				System.debug('(appendAdminId) append user id to survey admin 2 list');
			} else if ((survey.Survey_Admin_List_3__c.length() + userLen + 1) <= MAX_TEXT_LENGTH) {
				survey.Survey_Admin_List_3__c += userId + ADMIN_LIST_SEPARATOR;
				System.debug('(appendAdminId) append user id to survey admin 3 list');
			} else if ((survey.Survey_Admin_List_4__c.length() + userLen + 1) <= MAX_TEXT_LENGTH) {
				survey.Survey_Admin_List_4__c += userId + ADMIN_LIST_SEPARATOR;
				System.debug('(appendAdminId) append user id to survey admin 4 list');
			} else if ((survey.Survey_Admin_List_5__c.length() + userLen + 1) <= MAX_TEXT_LENGTH) {
				survey.Survey_Admin_List_5__c += userId + ADMIN_LIST_SEPARATOR;
				System.debug('(appendAdminId) append user id to survey admin 5 list');
			} else {
				System.debug('Number of administrators exceeds the maximum number allowed.' + 
					userId + ' is not appended.');
				// throw custom exception????
			}
		} else {
			System.debug('(appendAdminId) User Id is found blank.');			
		}
	}

	public static void deleteAdminId(Survey__c survey, String userId) {

		Integer idx = -1;
		Integer idx2 = -1;
		Integer idx3 = -1;
		Integer idx4 = -1;
		Integer idx5 = -1;
		if (survey != null) {
			if (String.IsNotBlank(userId) && isSurveyAdminListContainUserId(survey, userId)) { 

				String userIdWithSeparator = userId + ADMIN_LIST_SEPARATOR;
				System.debug('(deleteAdminId) User Id: ' + userId + ', user length: ' + userId.length());
				System.debug('(deleteAdminId) User Id Search Pattern: ' + userIdWithSeparator);

				if (String.IsNotBlank(survey.Survey_Admin_List_1__c)) {
					idx = survey.Survey_Admin_List_1__c.indexOf(userIdWithSeparator);
					System.debug('(deleteAdminId) search user id in survey admin 1 list');
				}
				if (String.IsNotBlank(survey.Survey_Admin_List_2__c)) {
					idx2 = survey.Survey_Admin_List_2__c.indexOf(userIdWithSeparator);
					System.debug('(deleteAdminId) search user id in survey admin 1 list');
				}
				if (String.IsNotBlank(survey.Survey_Admin_List_3__c)) {
					idx3 = survey.Survey_Admin_List_3__c.indexOf(userIdWithSeparator);
					System.debug('(deleteAdminId) search user id in survey admin 1 list');
				}
				if (String.IsNotBlank(survey.Survey_Admin_List_4__c)) {
					idx4 = survey.Survey_Admin_List_4__c.indexOf(userIdWithSeparator);
					System.debug('(deleteAdminId) search user id in survey admin 1 list');
				}
				if (String.IsNotBlank(survey.Survey_Admin_List_5__c)) {
					idx5 = survey.Survey_Admin_List_5__c.indexOf(userIdWithSeparator);
					System.debug('(deleteAdminId) search user id in survey admin 1 list');
				}
				if (idx >= 0) {
					survey.Survey_Admin_List_1__c = survey.Survey_Admin_List_1__c.remove(userIdWithSeparator);
					System.debug('(deleteAdminId) idx: ' + idx + ', delete user id ' + userId + ' from survey admin 1 list. New value: ' 
						+ survey.Survey_Admin_List_1__c);
				} else if (idx2 >= 0) {
					survey.Survey_Admin_List_2__c = survey.Survey_Admin_List_2__c.remove(userIdWithSeparator);
					System.debug('(deleteAdminId) idx2: ' + idx2 + ', delete user id ' + userId + ' from survey admin 2 list. New value: ' 
						+ survey.Survey_Admin_List_2__c);
				} else if (idx3 >= 0) {
					survey.Survey_Admin_List_3__c = survey.Survey_Admin_List_3__c.remove(userIdWithSeparator);
					System.debug('(deleteAdminId) idx3: ' + idx3 + ', delete user id ' + userId + ' from survey admin 3 list. New value: ' 
						+ survey.Survey_Admin_List_3__c);
				} else if (idx4 >= 0) {
					survey.Survey_Admin_List_4__c = survey.Survey_Admin_List_4__c.remove(userIdWithSeparator);
					System.debug('(deleteAdminId) idx4: ' + idx4 + ', delete user id ' + userId + ' from survey admin 4 list. New value: ' 
						+ survey.Survey_Admin_List_4__c);
				} else if (idx5 >= 0) {
					survey.Survey_Admin_List_5__c = survey.Survey_Admin_List_5__c.remove(userIdWithSeparator);
					System.debug('(deleteAdminId) idx5: ' + idx5 + ', delete user id ' + userId + ' from survey admin 5 list. New value: ' 
						+ survey.Survey_Admin_List_5__c);
				}
			}
		} else {
			System.debug('(deleteAdminId) User Id is found blank.');	
		}
	}
}