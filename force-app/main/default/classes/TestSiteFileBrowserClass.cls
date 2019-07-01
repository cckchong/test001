@isTest
private class TestSiteFileBrowserClass {

    static testmethod void testSiteFileBrowser() {
        // Create a Doc.
        Document doc1 = new Document();
        doc1.ContentType = 'image/png';
        doc1.Name = 'testdoc1.png';
        doc1.IsPublic = true;
        doc1.Url = 'testURL';
        doc1.FolderId = System.Userinfo.getUserId();
        
        insert doc1;
        
		PageReference pageRef = Page.MainTemplate1_Left;
		Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('folder', System.Userinfo.getUserId());
        
        // Instantiate the SFB, and look for the image that we just pushed in...
        SiteFileBrowser sfb = new SiteFileBrowser();
        List<ImageFile> imageList = sfb.files;
        
        for (ImageFile loopImage : imageList) {
            if (loopImage.doc.Name == doc1.Name) {
                System.assert(true);
            }
        }
    }
    
    static testmethod void testSiteFileBrowser2() {
        // Create a Doc.
        Document doc1 = new Document();
        doc1.ContentType = 'image/png';
        doc1.Name = 'testdoc1.png';
        doc1.IsPublic = true;
        doc1.Url = 'testURL';
        doc1.FolderId = System.Userinfo.getUserId();
        
        insert doc1;
       
        // Instantiate the SFB, and look for the image that we just pushed in...
        SiteFileBrowser sfb = new SiteFileBrowser();
        List<ImageFile> imageList = sfb.files;
        
        for (ImageFile loopImage : imageList) {
            if (loopImage.doc.Name == doc1.Name) {
                System.assert(true);
            }
        }
    }
}