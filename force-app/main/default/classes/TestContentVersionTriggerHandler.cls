@isTest
private class TestContentVersionTriggerHandler {
    static testMethod void myUnitTest() {
        DMS_Settings__c dmsU = new DMS_Settings__c(
			Name = 'manager_user',
			Value__c = UserInfo.getUserId()
		);
        insert dmsU;
		DMS_Settings__c dmsS = new DMS_Settings__c(
			Name = 'managerGroup',
			Value__c = 'TestDMSManagerGroup'
		);
		insert dmsS;
		CollaborationGroup dmsG= new CollaborationGroup(
			Name = dmsS.Value__c,
			CollaborationType='Public',
			OwnerId = UserInfo.getUserId()
		);
		insert dmsG;
		ContentVersion cv = new ContentVersion(
			Title = 'Test File',
			Description = 'Desc',
			PathOnClient = 'text.txt',
			Origin = 'H',
			VersionData = Blob.valueOf('testDoc')
		);
		insert cv;
		cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
		Set<Id> cds = new Set<Id>();
		for (ContentDocumentLink cdl : [
			SELECT Id, ContentDocumentId FROM ContentDocumentLink
				WHERE LinkedEntityId = :dmsG.id
			]) {
			cds.add(cdl.ContentDocumentId);
		}        
        //System.assert(cds.contains(cv.ContentDocumentId));
    }
}