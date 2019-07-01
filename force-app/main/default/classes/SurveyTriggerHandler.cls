public without sharing class SurveyTriggerHandler {
	
	public static void deleteOrphanSurveyAssignment() {
		// delete Survey Assignment with empty Survey__c 
		List<Survey_Assignment__c> listBlankSurvey = [Select Id, Name from Survey_Assignment__c where Survey__c = ''];
		for (Survey_Assignment__c sa : listBlankSurvey) {
			System.debug('Delete survey assignment with blank survey, id: ' + sa.id + ', name: ' + sa.name);
		}
		delete listBlankSurvey;
	}

	private static void changeSurveyOwner(String surveyId, List<Survey_Assignment__c> listUpdateSurveyAssignment,
			Map<Id, Survey__c> newSurveyMap) {
		
		Integer i = 0;
		if (listUpdateSurveyAssignment != null && listUpdateSurveyAssignment.size() > 0) {
			System.debug ('(changeSurveyOwner) SOQL update fires');
			// change  owner of survey assignment from old owner to new owner
			List<Database.SaveResult> results = Database.update(listUpdateSurveyAssignment, false);
			for (Database.SaveResult sr : results) {
				if (!sr.isSuccess()) {
					// Get the first save result error
	                Database.Error err = sr.getErrors()[0];
	                // Check if the error is related to a trivial access level
	                // Access levels equal or more permissive than the object's default
	                // access level are not allowed.
	                // These sharing records are not required and thus an insert exception is
	                // acceptable.
	                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
	                                               &&  err.getMessage().contains('AccessLevel'))) {
	                    // Throw an error when the error is not related to trivial access level.
	                    newSurveyMap.get(surveyId).
	                      addError('Unable to transfer ownership of survey assignment records related to survey id, ' 
	                      	+ surveyId + ' due to the following exception: ' + err.getMessage());
	                }
				}
				i++;
			}
		}
	}

	private static void createSurveyAssignmentRecord(String surveyId, String newSurveyOwnerId, Map<Id, Survey__c> newSurveyMap) {

		System.debug ('(createSurveyAssignmentRecord) Survey id: ' + surveyId 
				+ ', new survey owner id: ' + newSurveyOwnerId);

		Integer i = 0;
		List<Survey_Assignment__c> listNewSurveyAssignment = new List<Survey_Assignment__c>();
		Survey_Assignment__c sa = new Survey_Assignment__c();
		sa.Survey__c = surveyId;
		sa.User__c = newSurveyOwnerId;
		sa.GroupId__c= '';
		sa.Assignment_Nature__c = 'Administrator';
		sa.OwnerId = newSurveyOwnerId;

		System.debug ('(createSurveyAssignmentRecord) Survey__c: ' + sa.Survey__c 
				+ ', User__c: ' + sa.User__c + ', GroupId__c: ' + sa.GroupId__c
				+ ', Assignment_Nature__c: '  + sa.Assignment_Nature__c
				+ ', sa.OwnerId: ' + sa.OwnerId);

		listNewSurveyAssignment.add(sa);
		System.debug ('(createSurveyAssignmentRecord) SOQL insert fires');
		List<Database.SaveResult> results = Database.insert(listNewSurveyAssignment, false);
		for (Database.SaveResult sr : results) {
			if (!sr.isSuccess()) {
				// Get the first save result error
                Database.Error err = sr.getErrors()[0];
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default
                // access level are not allowed.
                // These sharing records are not required and thus an insert exception is
                // acceptable.
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                                               &&  err.getMessage().contains('AccessLevel'))) {
                    // Throw an error when the error is not related to trivial access level.
                    newSurveyMap.get(surveyId).
                      addError('Unable to create survey assignment record for new owner of survey id, ' 
                      	+ surveyId +' due to the following exception: ' + err.getMessage());
                }
			}
			i++;
		}
	}

	private static boolean isSurveyAssignmentAdministrator(String surveyId, String newSurveyOwnerId) {

		List<Survey_Assignment__c> listResult = [Select Id 
												 From Survey_Assignment__c 
												 Where Survey__c = :surveyId 
												 		AND User__c = :newSurveyOwnerId 
												 		AND assignment_nature__c = 'Administrator'];

		if (listResult != null && listResult.size() > 0) {
			return true;
		}										 
		return false;
	}

	private static boolean isChangeOwnership(Survey__c newSurvey, Map<Id, Survey__c> oldSurveyMap) {

		if (newSurvey != null && oldSurveyMap != null) {
			String newSurveyOwnerId = newSurvey.OwnerId;
			Survey__c oldSurvey = oldSurveyMap.get(newSurvey.Id);
			if (oldSurvey != null) {
				String oldSurveyOwnerId = oldSurvey.OwnerId;
				if (String.isNotBlank(oldSurveyOwnerId) && String.isNotBlank(newSurveyOwnerId)
					&& !oldSurveyOwnerId.equals(newSurveyOwnerId)) {
					System.debug('(isChangeOwnership) Survey id: ' + newSurvey.Id + ' change ownership from ' + oldSurveyOwnerId 
								+ ' to ' + newSurveyOwnerId);
						
					return true;
				}
			}
		}
		return false;
	}

	private static List<Survey_Assignment__Share> createNewOwnerSurveyAssignmentShare(Survey__c newSurvey) {

		// create survey assignment share such that new owner can see all survey assignment records that belong to the survey
		List<Survey_Assignment__Share> listSurveyAssignmentShare = new List<Survey_Assignment__Share>();
		// retrieve survey assignment records not created by new owner
		List<Survey_Assignment__c> listOtherOwnerAssignment = [Select Id, Name 
																From Survey_Assignment__c 
																Where Survey__c = :newSurvey.Id AND OwnerId != :newSurvey.OwnerId];

		System.Debug('(createNewOwnerSurveyAssignmentShare) listOtherOwnerAssignment size: ' + listOtherOwnerAssignment.size());
		Set<String> setOtherSurveyAssignmentId = new Set<String>();
		for (Survey_Assignment__c sa : listOtherOwnerAssignment) {
			System.Debug('(createNewOwnerSurveyAssignmentShare) Other Survey Assignment id: ' + sa.id + ', Name: ' + sa.Name);
			setOtherSurveyAssignmentId.add(sa.Id);
		}														

		// check whether or not new owner has access to the survey assignment record
		Set<String> setOtherAssignmentNewOwnerHasAccess = new Set<String>();
		List<Survey_Assignment__Share> listOtherSurveyAssignmentShare = [Select ParentId  
																		 From Survey_Assignment__Share 
																		 WHERE ParentId IN :setOtherSurveyAssignmentId  
																		 AND UserOrGroupId = :newSurvey.OwnerId];
		for (Survey_Assignment__Share sas : listOtherSurveyAssignmentShare) {
			System.debug ('(createNewOwnerSurveyAssignmentShare) New owner has access to other survey assignment id: ' + sas.ParentId);
			setOtherAssignmentNewOwnerHasAccess.add(sas.ParentId); 
		}

		// create new survey assignment share records for new owner
		for (Survey_Assignment__c sa : listOtherOwnerAssignment) {
			if (!setOtherAssignmentNewOwnerHasAccess.contains(sa.Id)) {

				Survey_Assignment__Share sa_share = new Survey_Assignment__Share();
	    		sa_share.UserOrGroupId = newSurvey.OwnerId;
	    		sa_share.AccessLevel = 'Edit';
	    		sa_share.RowCause = Survey_Assignment__Share.RowCause.Survey_Administrator__c;
    			sa_share.ParentId = sa.Id;
    			System.debug('(createNewOwnerSurveyAssignmentShare) survsey assignment share - parentId: ' + sa_share.ParentId 
    				+ ', UserOrGroupId: ' + sa_share.UserOrGroupId 
    				+ ', sa_share.AccessLevel: ' + sa_share.AccessLevel 
    				+ ', sa_share.RowCause: ' + sa_share.RowCause);
				listSurveyAssignmentShare.add(sa_share);
			}
		}
		return listSurveyAssignmentShare;
	}

	private static void deleteOldOwnerSurveyAssignment(String surveyId, Survey__c oldSurvey, Map<Id, Survey__c> newSurveyMap) {

		// delete survey assignment of old owner
		List<Survey_Assignment__c> listDelAssignment = [Select Id, Name 
														from Survey_Assignment__c Where Survey__c = :oldSurvey.Id
														    AND User__c = :oldSurvey.OwnerId
														    AND Assignment_Nature__c = :SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR];  
		if (listDelAssignment != null && listDelAssignment.size() > 0) {

			for (Survey_Assignment__c sa : listDelAssignment) {
				System.debug('(deleteOldOwnerSurveyAssignment) Delete survey assignment id: ' + sa.Id + ', Name: ' + sa.Name);
			}
			System.debug ('(deleteOldOwnerSurveyAssignment) SOQL survey assignment delete fires');
			List<Database.DeleteResult> results = Database.delete(listDelAssignment, false);
			Integer i =  0;
			for (Database.DeleteResult dr : results) {
				if (!dr.isSuccess()) {
					// Get the first save result error
	                Database.Error err = dr.getErrors()[0];
	                newSurveyMap.get(surveyId).
	                      addError('Unable to delete survey assignment record of old owner of survey id, ' 
	                      	+ surveyId +' due to the following exception: ' + err.getMessage());   
				}
			
			}
		}

		// delete survey assignment share granted access to old owner
		List<Survey_Assignment__c> listRemainAssignment = [Select Id from Survey_Assignment__c Where Survey__c = :oldSurvey.Id]; 
		List<Survey_Assignment__Share> listDelAssignmentShare = [Select Id, ParentId 
																 From Survey_Assignment__Share 
																 Where ParentId IN :listRemainAssignment 
														    	    AND UserOrGroupId = :oldSurvey.OwnerId];  
		if (listDelAssignmentShare != null && listDelAssignmentShare.size() > 0) {

			for (Survey_Assignment__Share sas : listDelAssignmentShare) {
				System.debug('(deleteOldOwnerSurveyAssignment) Delete survey assignment share id: ' + sas.Id + ', ParentId: ' + sas.ParentId);
			}
			System.debug ('(deleteOldOwnerSurveyAssignment) SOQL survey assignment share delete fires');
			List<Database.DeleteResult> results = Database.delete(listDelAssignmentShare, false);
			Integer i =  0;
			for (Database.DeleteResult dr : results) {
				if (!dr.isSuccess()) {
					// Get the first save result error
	                Database.Error err = dr.getErrors()[0];
	                newSurveyMap.get(surveyId).
	                      addError('Unable to delete survey assignment share of old owner of survey id, ' 
	                      	+ surveyId +' due to the following exception: ' + err.getMessage());   
				}
			
			}
		}
	}

	public static void beforeUpdateSurvey(Map<Id, Survey__c> oldSurveyMap, 	List<Survey__c> newSurveyList) {

		// if survey change ownership, change ownership of survey assignment records from old owner to new owner
		//   
		for (Survey__c newSurvey : newSurveyList) {
			String surveyId = newSurvey.id;
			if (isChangeOwnership(newSurvey, oldSurveyMap)) {
				Survey__c oldSurvey = oldSurveyMap.get(surveyId);
				if (oldSurvey != null && String.IsNotBlank(oldSurvey.OwnerId)) {
					System.debug('Delete old owner from survey admin list field, owner id: ' + oldSurvey.OwnerId);
					SurveyAdminListHelper.deleteAdminId(newSurvey, oldSurvey.OwnerId);
				}
				if (newSurvey != null && String.IsNotBlank(newSurvey.OwnerId)) {
					System.debug('Append new owner to survey admin list field, owner id: ' + newSurvey.OwnerId);
					SurveyAdminListHelper.appendAdminId(newSurvey, newSurvey.OwnerId);
				}
			}
		}
	}

	public static void updateSurvey(Map<Id, Survey__c> oldSurveyMap, 
			List<Survey__c> newSurveyList, Map<Id, Survey__c> newSurveyMap) {

		// if survey change ownership, change ownership of survey assignment records from old owner to new owner
		//   
		for (Survey__c newSurvey : newSurveyList) {
			String surveyId = newSurvey.id;
			if (isChangeOwnership(newSurvey, oldSurveyMap)) {
				List<Survey_Assignment__c> listUpdateSurveyAssignment =  new List<Survey_Assignment__c>(); 
				Survey__c oldSurvey = oldSurveyMap.get(surveyId);
				if (oldSurvey != null && String.IsNotBlank(oldSurvey.OwnerId)) {
					for (Survey_Assignment__c sa : [Select Id, Name, OwnerId From Survey_Assignment__c 
											 Where Survey__c = :surveyId and OwnerId = :oldSurvey.OwnerId]) {
						sa.OwnerId = newSurvey.OwnerId;
						listUpdateSurveyAssignment.add(sa);
					}
					for (Survey_Assignment__c sa : listUpdateSurveyAssignment) {
						System.debug('(updateSurvey) Survey assignment id: ' + sa.id + ', name: ' + sa.Name + 
							', owner: ' + sa.OwnerId);
					}

					// change owner of survey assignment records of this survey to new owner
					changeSurveyOwner(surveyId, listUpdateSurveyAssignment, newSurveyMap);
				}
				deleteOldOwnerSurveyAssignment(surveyId, oldSurvey, newSurveyMap);

				// if new owner does not have survey assignment record with administrator reason, create a new Survey_Assignment__c record
				if (!isSurveyAssignmentAdministrator(surveyId, newSurvey.OwnerId)) {
					createSurveyAssignmentRecord(surveyId, newSurvey.OwnerId, newSurveyMap);
				}
				List<Survey_Assignment__Share> listSurveyAssignmentShare = createNewOwnerSurveyAssignmentShare(newSurvey);
				persistSurveyAssignmentShareRecord(listSurveyAssignmentShare, surveyId, newSurveyMap);
			}
		}
	}

	private static void persistSurveyAssignmentShareRecord(List<Survey_Assignment__Share> listAssignmentShareInsert, 
			String surveyId, Map<Id, Survey__c> newSurveyMap) {

		if (listAssignmentShareInsert.size() > 0) {
			System.debug ('(persistSurveyAssignmentShareRecord) SOQL survey assignment insert fires');
			List<Database.SaveResult> results = Database.insert(listAssignmentShareInsert, false);
			for (Database.SaveResult sr : results) {
				if(!sr.isSuccess()) {
	                // Get the first save result error
	                Database.Error err = sr.getErrors()[0];
	                // Check if the error is related to a trivial access level
	                // Access levels equal or more permissive than the object's default
	                // access level are not allowed.
	                // These sharing records are not required and thus an insert exception is
	                // acceptable.
	                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
	                                               &&  err.getMessage().contains('AccessLevel'))) {
	                    // Throw an error when the error is not related to trivial access level.
	                    newSurveyMap.get(surveyId)
	                    	.addError('Unable to grant sharing access of survey assignment records to new owner due to following exception: '
	                       + err.getMessage());
	                }
				}
			}
		}
	}
}