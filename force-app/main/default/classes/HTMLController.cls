/*****************************************************
Controller for HTML Component
1. Get the html record to show in the visualforce page

******************************************************/
public without sharing class HTMLController {
    
    public Id htmlID { get; set; }
    
    public Id recordID { get; set; }
    
    public Portal_Content__c htmlText { get {
            List<Portal_Content__c> html = [select Id, HTML__c, Contents__c from Portal_Content__c where RecordType.DeveloperName = 'HTML' and Id = :htmlID LIMIT 1];
            if(!html.isEmpty()) {
            	return html.get(0);
            }
            return null;
        } set; }

}