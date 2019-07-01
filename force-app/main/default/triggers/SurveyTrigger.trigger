trigger SurveyTrigger on Survey__c (
	before update, after delete, after update) {

	if (Trigger.isAfter) {
    	if (Trigger.isDelete) {
    		SurveyTriggerHandler.deleteOrphanSurveyAssignment();
    	} else if (Trigger.isUpdate) {
    		SurveyTriggerHandler.updateSurvey(Trigger.oldMap, Trigger.new, Trigger.newMap);
    	}
	} else {
		if (Trigger.isUpdate) {
    		SurveyTriggerHandler.beforeUpdateSurvey(Trigger.oldMap, Trigger.new);
    	} 
	}
}