public with sharing class PortalContentOverrideEditButtonCtrl {
    
    public String recordTypeName {get;set;}
    
    public PortalContentOverrideEditButtonCtrl(ApexPages.StandardController controller) {
    
        String theId = ((Portal_Content__c) controller.getRecord()).Id;
        if(theId != null & theId != '') {
            List<Portal_Content__c> acg = [SELECT Id, RecordType.Name FROM Portal_Content__c WHERE Id =: theId limit 1];
            if(!acg.isEmpty()) {
            	this.recordTypeName = acg.get(0).RecordType.Name;
            }
        }
    }
    
}