/*****************************************************
Controller for Video Component

1. Get Video Record

******************************************************/
public without sharing class VideoController {
    
    public Id videoID { get; set; }
    
    public Id recordID { get; set; }
    
    public Portal_Content__c video {
        get {
            List<Portal_Content__c> video = [select Id, HTML__c from Portal_Content__c where RecordType.DeveloperName = 'Video' and Id = :videoID LIMIT 1];
            if(!video.isEmpty()) {
            	return video.get(0);
            }
            return null;
        }
        set; }

    
}