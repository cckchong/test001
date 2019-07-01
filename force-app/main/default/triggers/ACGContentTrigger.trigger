trigger ACGContentTrigger on Portal_Content__c (before insert, before update, after insert, after update) {
    /*List<RecordType> rts = 
    	[
    		SELECT Id, Name, Developername
    		FROM RecordType 
    		WHERE SObjectType = 'Portal_Content__c' 
			AND (Developername = 'Rich_Text' OR Developername = 'Settings' ) 
			limit 2
		];
	
    RecordType rtRichText = new RecordType();
    RecordType rtSettings = new RecordType();
    if(!rts.isEmpty()) {
    	for(RecordType rt: rts) {
    		if(rt.Developername == 'Rich_Text') {
    			rtRichText = rt;
    		} else if (rt.Developername == 'Settings') {
    			rtSettings = rt;
    		}    		
    	}
    }
    */
    RecordType rtRichText = ACGContentTriggerHandler.getRichTextRecordType();
    RecordType rtSettings = ACGContentTriggerHandler.getSettingsRecordType();
    
    if(Trigger.IsBefore) {
        if(Trigger.isInsert) {
            //Store the created date and last modified date to custom field
            ACGContentTriggerHandler.storeCreatedDateAndLastModdate(Trigger.new, rtRichText);
            //Validation
        	ACGContentTriggerHandler.onlyOneRssFeedIsAllowedPerPage(Trigger.new, rtSettings);
        }
        if(Trigger.isUpdate) {
            //Add [REVISED] to the title of article announcement
            ACGContentTriggerHandler.addReviseWord(Trigger.new, Trigger.oldMap, rtRichText);
            //Store the created date and last modified date to custom field
            ACGContentTriggerHandler.storeCreatedDateAndLastModdate(Trigger.new, rtRichText);
        	//Validation
        	ACGContentTriggerHandler.onlyOneRssFeedIsAllowedPerPage(Trigger.new, rtSettings);
        }
    } else {
        ACGContentTriggerHandler.calculateSharing(Trigger.oldMap, Trigger.newMap);
    }
}