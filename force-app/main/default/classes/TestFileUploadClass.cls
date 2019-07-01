@isTest
private class TestFileUploadClass {

	static testmethod void testFileUpload() {
        FileUpload fu = new FileUpload();
        fu.doUpload();        
        fu.document.Name = 'test1';
        fu.document.Body = Blob.valueOf('test1');         
        fu.doUpload();
        System.assertEquals(fu.document.Name, 'test1' );
    }
}