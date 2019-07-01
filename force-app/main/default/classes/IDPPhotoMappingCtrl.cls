Global without sharing class IDPPhotoMappingCtrl{

    public transient List<Document> attachments{get;set;}
    //public List<Document> oldDocuments{get;set;}
    
    public Integer countOfFiles {get;set;}
    public Boolean isfileUploaded {get;set;}
    public Boolean isfileDeleted {get;set;}
    
    public List<String> docIdsStringSet {get;set;}
    public String defaultImgName {get;set;}

    public IDPPhotoMappingCtrl(){
        isfileDeleted = false;
        countOfFiles = 0;
        docIdsStringSet = new List<String>();
        isfileUploaded = false;
        defaultImgName = 'defaultzpng';
        //getAllDocuments();
        //oldDocuments = new List<Document>();
        getAllAttachments();
    }
    
    public void passDocId(){
        String docIds = Apexpages.currentPage().getParameters().get('docIds');
        if (docIds==null)   docIds = '';
        docIdsStringSet = docIds.split(';');
    }
    
    // select the seleted photo and update the photo to default if mapped
    public void deletePhoto(){
        String delPhotoId = Apexpages.currentPage().getParameters().get('delPhotoId');

        // update mapped photo
        List<Catalog_Item__c> mappedPhotoList =  [select id, Photo_Doc_Id__c, Photo_Name__c from Catalog_Item__c where Photo_Doc_Id__c =:delPhotoId];
        Document defaultImage = [select id, Name from Document where developerName = :defaultImgName];
        
        if(mappedPhotoList.size() > 0){
            for(Catalog_Item__c mappedPhoto:mappedPhotoList){
                if(defaultImage.id != null){
                    mappedPhoto.Photo_Doc_Id__c = defaultImage.id;
                    mappedPhoto.Photo_Name__c = defaultImage.Name;
                }    
            }
        }
        update mappedPhotoList;
                
        // delete photo
        List<Document> delIdList = [select id from document where id =:delPhotoId];

        if(delIdList.size() > 0){
            Delete delIdList;
            isfileDeleted = true;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Photo was deleted successfully.'));
        }
        
        getAllAttachments();
    }
    
    
/*
    public PageReference cancel(){
        if (textId  == null){
            String preFix = '';
            Schema.DescribeSObjectResult r = Expense_Application__c.sObjectType.getDescribe();
            preFix  = r.getKeyPrefix();
            return new PageReference('/' + prefix + '/o');
            
        }
        else{
            return new PageReference('/' + eaId);
        }
    }
*/    
  /*
    Datetime refDatetime = Datetime.now().addMinutes(-1);
    public void getAllDocuments(){    
        oldDocuments = new List<Document>(); 
        docIdsStringSet.clear();
        List<Document> doc = [Select d.Type, d.Name, d.Id, d.FolderId, d.Body, d.AuthorId, d.lastModifiedDate
                                From Document d 
                                WHERE FolderId = '00lp0000000NaH0' // hardcoded document folder id for tal idp photos
                                AND AuthorId = :UserInfo.getUserId()
                                AND lastModifiedDate >= :refDatetime
                                //AND Id IN :docIdsStringSet
                                order by lastModifiedDate desc];
        
        //if(doc != null && doc.size()>0 ){  
            oldDocuments = doc;
            for (Document d: doc){
                docIdsStringSet.add(d.Id);
            }
        //}
    }
*/

    public void getAllAttachments(){    
        attachments = new List<Document>();
        //countOfFiles = 0;
        //if (IDPPhotoMappingCtrl.docIdSet!=null && IDPPhotoMappingCtrl.docIdSet.size()>0){    
            List<Document> att = [Select d.Type, d.Name, d.Id, d.FolderId, d.AuthorId, d.lastModifiedDate//, d.Body
                                    From Document d 
                                    WHERE FolderId = :Label.IDP_Catalog_Photos_Folder_Id // hardcoded document folder id for tal idp photos
                                    AND AuthorId = :UserInfo.getUserId()
                                    //AND lastModifiedDate < :refDatetime
                                    //AND Id NOT IN :docIdsStringSet
                                    order by lastModifiedDate desc
                                    ];
            
            if(att != null && att.size()>0 ){  
                attachments = att;
                //countOfFiles = att.size();
            }
            isfileUploaded = true;
        //}
    }
    
    public void rerenderAllDocTables(){
        //getAllDocuments();
        getAllAttachments();
    }
    
   public String body{set;get;}
   public String name{set;get;}
   public String contentType{set;get;}

   
   @RemoteAction
   Global static String uploadFileAction(String name, String contentType, String body, string attachid) {
       system.debug('attachid ' + attachid);
       
       String regex = '[^A-Z,a-z,0-9,_]';
       Document d = new Document();

       if (attachid != ''){
           for(Document atm : [select Id, Body from Document where id =:attachid]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Document ( Id = attachid, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + body));
            }
           return attachid;
       }
                    
       d.ContentType = contentType;
       //d.ParentId =pid;
       d.Body = EncodingUtil.Base64Decode(body);
       d.FolderId = Label.IDP_Catalog_Photos_Folder_Id;

       String[] file = name.split('\\.(?=[^\\.]+$)');
       String fileName = file[0];
       String ext = file[1];

       String dname = fileName + '_' + dateTime.now().getTime() + '.' + ext;
       String devName = dname.replaceAll(regex,'z');
       d.Name = dname;
       d.DeveloperName = devName;



       //String devName = name.replaceAll(regex,'z');
       //d.Name = name;
       //d.DeveloperName = devName;
       //d.Name = name + '_' + dateTime.now().getTime();
       //d.DeveloperName = devName  + '_' + dateTime.now().getTime();
       
       system.debug('d.Name:'+d.Name);
       system.debug('d.DeveloperName:'+d.DeveloperName);
       
       upsert d Name;  



       
       return d.id;
   }
   
}