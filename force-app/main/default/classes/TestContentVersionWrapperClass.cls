@isTest
private class TestContentVersionWrapperClass {

    /*static testMethod void myUnitTest() {
        String groupName = 'Test Group' + TestUtil.generateRandomString();
        CollaborationGroup chatterGroup = new CollaborationGroup(Name=groupName, CollaborationType='Public');
        chatterGroup.OwnerId = UserInfo.getUserId() ;
        try
        {
            insert chatterGroup;
        }
        catch (exception ex)
        {
            //chatterGroup = [Select Id, Name From CollaborationGroup Where Name = :groupName limit 1];
        }   
            
        FeedItem ChatterPhoto = TestUtil.getChatterPhoto();
        ChatterPhoto.ParentId=chatterGroup.Id;
        insert ChatterPhoto;
        
        Set<Id> listFiles = new Set<Id>();      
        for(ContentDocumentLink files : [Select c.LinkedEntityId, c.Id, c.ContentDocument.PublishStatus, c.ContentDocument.Title, c.ContentDocument.Id, c.ContentDocumentId 
                                        From ContentDocumentLink c
                                        WHERE LinkedEntityId = :chatterGroup.Id])
        {
            listFiles.add(files.ContentDocumentId); 
        }       
        
        ContentVersion cv = 
                [SELECT ContentDocument.Id, ContentDocument.Title, Description, FileType, TagCsv, ContentDocumentId, ContentDocument.LatestPublishedVersionId 
                FROM ContentVersion
                Where ContentDocument.Id IN :listFiles limit 1];
        
        ContentVersionWrapper cvw = new ContentVersionWrapper(cv);
        String returnId = cvw.Id;
        String returnFileName = cvw.FileName;
        String returnFileType = cvw.FileType;
        String returnTagCsv = cvw.TagCsv;        
        System.assertEquals('JPG', returnFileType);
        System.assertEquals('kittens', returnFileName);
        System.assertEquals('JPG',cvw.origContentVersion.FileType);
        System.assertEquals('Image (JPG)', cvw.friendlyFileType);
        System.assertEquals('sprite-doctype_image_16', cvw.fileTypeStyle);
                
        ContentVersionWrapper cvw2 = new ContentVersionWrapper(cv, 999);
        System.assertEquals(999, cvw2.fileSeq);
    }*/
}