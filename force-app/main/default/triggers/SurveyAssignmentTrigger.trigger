trigger SurveyAssignmentTrigger on Survey_Assignment__c (
	after insert, after delete, before delete, before update) {

	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			SurveyAssignmentTriggerHandler.createSurveyAssignmentShare(Trigger.new, Trigger.newMap);
		} else if (Trigger.isDelete) {
			SurveyAssignmentTriggerHandler.deleteSurveyAssignmentShare(Trigger.old, Trigger.oldMap);
		} 
	} else if (Trigger.isBefore) {
		if (Trigger.isDelete) {
			SurveyAssignmentTriggerHandler.validateDeleteSurveyAssignment(Trigger.old);
		} else if (Trigger.isUpdate) {
			// user id and group id must be mutually exclusive in survey assignment record
			SurveyAssignmentTriggerHandler.validateUserAndGroupMutuallyExclusive(Trigger.new);
        }
	}
}