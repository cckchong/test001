/*
	LibraryItemDetailImageCtrl Class
	
	@Author: AN, WG
	@Object: Attachment, ContentDocumentLink
	@Description: Used to handle the detail image info of Library_Item__c
*/
public class LibraryItemDetailImageCtrl {
    
    public List<Attachment> photoAttachmentList {get;set;}
    public List<ContentDocumentLink> feedPhotoAttachmentList {get;set;}
    
    //Constructor, loading the attached images associated with the library item
    public LibraryItemDetailImageCtrl(ApexPages.StandardController ctrl) {
        String theId = ctrl.getRecord().Id;
        this.photoAttachmentList = new List<Attachment>();
        List<Attachment> photos = [
            SELECT Id 
            FROM Attachment 
            WHERE ParentId =: theId 
            AND (ContentType LIKE : Label.Library_Image_Format_JPG 
            OR   ContentType LIKE : Label.Library_Image_Format_JPEG 
            OR   ContentType LIKE : Label.Library_Image_Format_GIF 
            OR   ContentType LIKE : Label.Library_Image_Format_PNG)            
       		LIMIT 5
        ]; 
        
        if(!ErrorUtils.isEmpty(photos)) {
            this.photoAttachmentList = photos;
        }
        
        this.feedPhotoAttachmentList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> feedPhotos = [
        	Select c.ContentDocument.LatestPublishedVersionId, c.ContentDocument.Id 
			From ContentDocumentLink c
			WHERE LinkedEntityId =: theId
			AND (ContentDocument.FileType LIKE : Label.Library_Image_Format_JPG 
			OR   ContentDocument.FileType LIKE : Label.Library_Image_Format_JPEG 
			OR   ContentDocument.FileType LIKE : Label.Library_Image_Format_GIF
			OR   ContentDocument.FileType LIKE : Label.Library_Image_Format_PNG)
			LIMIT 5
        ];
        
        if(!ErrorUtils.isEmpty(feedPhotos)) {
            this.feedPhotoAttachmentList = feedPhotos;
        }
    }
}