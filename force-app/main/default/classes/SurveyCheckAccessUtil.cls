public without sharing class SurveyCheckAccessUtil {
	
	public String surveyId { get; set; }
	public String userId { get; set; }

	public SurveyCheckAccessUtil(String otherUserId, String otherSurveyId) {
		surveyId = otherSurveyId;	
		userId = otherUserId;
	}

	public boolean canTakeSurvey () {

		// if user has edit right to Survey record, he can take survey and create survey response objects 
		List<UserRecordAccess> ll = [Select RecordId, HasEditAccess from UserRecordAccess 
									 where UserId = :userId AND 
									 	RecordId = :surveyId];
		
		if (ll != null && ll.size() > 0) {
			for (UserRecordAccess recAccess : ll) {
				if (recAccess.HasEditAccess == true) {
					return true;
				}
			}
		}									 	
		return false;
	}

	public boolean canManageSurvey () {

		// current user has read or write access to the survey record
		// user has Owner or Administrator sharing reason
		List<UserRecordAccess> listUserRecordAccess = 
						[Select RecordId, HasReadAccess, HasEditAccess From UserRecordAccess 
						 Where UserId = :userId AND RecordId = :surveyId];

		List<Survey__Share> listSurveyShare = [Select Id, AccessLevel, UserOrGroupId, RowCause FROM Survey__Share 
		                                        Where ParentId = :surveyId AND UserOrGroupId = :userId ];

		if (listUserRecordAccess != null && listUserRecordAccess.size() > 0 && 
			listSurveyShare != null && listSurveyShare.size() > 0) {
			Boolean hasEditAccess = listUserRecordAccess.get(0).HasEditAccess;
			// a user can have at most two survey share records
			// Different Combinations:
			// 1) Owner and Taker
			// 2) Administrator and Taker
			// 3) Administrator
			// 4) Taker
			// 5) Owner
			// 6) No record
			// a user can edit survey and survey question records in 1), 2, 3) and 5).  
			for (Survey__Share survey_share : listSurveyshare) {
				String reason = survey_share.RowCause;
				System.debug('canManageSurvey: surveyId: ' + surveyId + ', userId: ' + userId);
				System.debug('canManageSurvey: hasEditAccess: ' + hasEditAccess + ', reason: ' + reason);
				if (hasEditAccess && (reason == Survey__Share.RowCause.Owner || reason == Survey__Share.RowCause.Administrator__c)) {
					return true;
				}
			}
		}									 	
		return false;
	}
}