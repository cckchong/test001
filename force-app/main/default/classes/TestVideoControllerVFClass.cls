@isTest
private class TestVideoControllerVFClass {

	static testMethod void video() {            
		
        Portal_Content__c video = TestClassUtil.getVideo();
        insert video;			
		
        VideoController extn = new VideoController();
        extn.videoID = video.Id;
        Portal_Content__c content = extn.video;
                
        System.assertEquals(content.Id, video.Id);     
    }
}