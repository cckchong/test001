Global without sharing class IDPPhotoMappingItemToPhotoCtrl{

    //public List<Document> photoList{get;set;}
    public String currentPhotoName {get;set;}
    public Catalog_Item__c catItem {get;set;}
    public List<DocWrapper> docWrapperList{get;set;}
    
    public Map<String, Document> documentIdDocMap = new Map<String, Document>();
    public String docId {get;set;}
    public String catItemId {get;set;}
    public String searchPhotoString {get;set;}
    public String defaultImgName {get;set;}

    public IDPPhotoMappingItemToPhotoCtrl(){
        
        docId = apexpages.currentpage().getparameters().get('selected');
        catItemId = apexpages.currentpage().getparameters().get('cId');
        
        searchPhotoString = '';
        
        getAllPhotos();
        
        catItem = [Select  Description__c, Item_Name__c, //Item_Code__c,
                    Photo_Doc_Id__c, Photo_Name__c, Catalog__r.display_name__c , Catalog__r.Owner.lastName, Catalog__r.Owner.FirstName
                    From Catalog_Item__c 
                    WHERE Id = :ApexPages.currentPage().getParameters().get('cId')
                    limit 1];
        
        defaultImgName = 'defaultzpng';
    }

    public void save(){
        
        docId = apexpages.currentpage().getparameters().get('selected');
        if (docId!=null && documentIdDocMap.containsKey(docId)){
            catItem.Photo_Doc_Id__c = docId;
            catItem.Photo_Name__c = documentIdDocMap.get(docId).Name;
            update catItem;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Photo was mapped successfully.'));
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a photo to map first.'));
        }
        //return new PageReference('/' + prefix + '/o');

    }
    
    public void resumeToDefaultPic(){
            Document defaultImgObj = [select id, name from document where DeveloperName =:defaultImgName];
            catItem.Photo_Doc_Id__c = defaultImgObj.id;
            catItem.Photo_Name__c = defaultImgObj.Name;
            update catItem;    
    }

    public void getAllPhotos(){    
        //photoList = new List<Document>();
        String searchStr = '%' + searchPhotoString + '%';
        docWrapperList = new List<DocWrapper>();
        documentIdDocMap.clear();
        /*List<Document> doc = [Select d.Type, d.Name, d.Id, d.FolderId, d.Body, d.AuthorId, d.lastModifiedDate
                                From Document d 
                                WHERE FolderId = '00lp0000000NaH0' // hardcoded document folder id for tal idp photos
                                AND AuthorId = :UserInfo.getUserId()
                                AND lastModifiedDate = TODAY
                                order by lastModifiedDate desc];
                                */
        
        for (Document doc : [Select Type, Name, Id, FolderId, AuthorId, lastModifiedDate, DeveloperName
                                From Document
                                WHERE FolderId = : Label.IDP_Catalog_Photos_Folder_Id 
                                AND Name LIKE :searchStr
                                AND AuthorId = :UserInfo.getUserId()
                                order by Name desc]){
            documentIdDocMap.put(doc.Id, doc);
            docWrapperList.add(new DocWrapper(doc));
                                    
        }
        
    }
    
    public class DocWrapper{
        
        public Document doc {get;set;}
        public boolean isSelected {get;set;}
        
        public DocWrapper(Document pDoc){
            doc = pDoc;
            isSelected = false;
        }
    }

}