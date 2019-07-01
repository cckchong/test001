public class attachmentTO{

    public attachment file{get;set;}
    public Expense_Application__Feed eaf{get;set;}
    public TEExpenseApplicationCtrl controller{get;set;}
    public Double size{get;set;}
    public String type{get;set;}
    Public String fileName{get;set;}
    Public String lastModifiedDate{get;set;}
    Public String Id{get;set;}
    Public String fid{get;set;}
    
    public attachmentTO(attachment f, TEExpenseApplicationCtrl c){
          this.type = 'a';
          this.file = f;
          this.controller = c;
          this.size = 0;
          if(f.BodyLength != null){
              this.size = (Double) f.BodyLength / 1024;
          }
          this.filename = f.Name;
          //this.lastModifiedDate = f.lastModifiedDate;
          if( f.lastModifiedDate != null){
              this.lastModifiedDate = f.lastModifiedDate.format();
          }
          this.Id = f.id;
    }
    
    public attachmentTO(Expense_Application__Feed f, TEExpenseApplicationCtrl c){
          this.type = 'c';
          this.eaf = f;
          this.controller = c;
          this.size = 0;
          if(eaf.ContentSize != null){
              this.size = (Double) eaf.ContentSize / 1024;
          }
          this.filename = f.ContentFileName;
          //this.lastModifiedDate= f.LastModifiedDate;
          if( f.lastModifiedDate != null){
              this.lastModifiedDate = f.lastModifiedDate.format();
          }
          this.Id = f.RelatedRecordId;
          this.fId = f.id;
    }
    
    public void deleteFile(){
         if( type == 'a'){
             delete new Attachment (id = this.id);
         }
         if( type == 'c'){            
            delete new FeedItem (id = fid);
            for(ContentVersion reader : [select id, ContentDocumentId from ContentVersion where id = :id limit 1]){
                delete new ContentDocument(id = reader.ContentDocumentId);           
            }
            
         }
         controller.getAllAttachments();
    }

}