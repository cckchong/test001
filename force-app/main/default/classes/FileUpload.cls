/*****************************************************

Controller for File Upload

1. Upload File to Personal Document Folder
2. Used when user upload image from CK Editor

******************************************************/
public with sharing class FileUpload {
    public Document document {get; set;}
    public String url {get; set;}
    public boolean hasImage {get; set;}
    
    public FileUpload() {
        hasImage = false;
        document = new document();
    }

    public PageReference doUpload() {

        if (document.body != null) {
            
            if (document.name != null) {                
                Document d = document;
                System.debug(document);
                System.debug(d);
        
                d.folderid = UserInfo.getUserId(); //store in Personal Documents
                d.IsPublic = true;
                
                try {
                    insert d;
                    url = DocumentUtil.getInstance().getURL(d);
                    hasImage = true;
                } catch (Exception e) {
                    ApexPages.addMessages(e);
                    url = '';
                }                
                d.body = null;            
                String url = DocumentUtil.getInstance(d).getURL();       
            }    
        }
        
        PageReference page = new PageReference('/apex/FileUpload');
        //page.setRedirect(true);
        return page;   
    }   
}