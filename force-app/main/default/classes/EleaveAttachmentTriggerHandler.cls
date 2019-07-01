/*
*   @description To update supportinf doc counter when the attachment is added or removed
*/  
   
public without sharing class EleaveAttachmentTriggerHandler {
  
  /*
   *   @description update Tech_Supporting_Doc_Counter__c value when the attachemnt is added or removed
   */    
  public static void updateSupportingDoc(List<Attachment> attachments, String action){
    Schema.DescribeSObjectResult r = Leave_Request__c.sObjectType.getDescribe();
    String keyPrefix = r.getKeyPrefix();
    Set <Id> LeaveRequestIds = new Set <Id> ();
    List <Leave_Request__c> LeaveRequestList = null;
    
    //Get leave request in attachment list
    for (Attachment reader : attachments ){
        if ( String.Valueof(reader.ParentId).startsWith(keyPrefix ) ){
            LeaveRequestIds.add(reader.ParentId);
        }
    }
    
    
    if ( !LeaveRequestIds.isempty() ) {
        LeaveRequestList  = new List <Leave_Request__c>();
        for ( Leave_Request__c reader : [ select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id in :LeaveRequestIds ]) {
            LeaveRequestList.add (reader);
        }
        
        //if the attachment is removed, Tech_Supporting_Doc_Counter__c = Tech_Supporting_Doc_Counter__c - 1
        if ( action == 'Delete') {
            for ( Leave_Request__c reader : LeaveRequestList ){
                if ( reader.Tech_Supporting_Doc_Counter__c == null ){
                    reader.Tech_Supporting_Doc_Counter__c = 1;
                }
                reader.Tech_Supporting_Doc_Counter__c -= 1;                
            }
        }
        
        //if the attachment is attached , Tech_Supporting_Doc_Counter__c = Tech_Supporting_Doc_Counter__c + 1
        if ( action == 'Insert'  ) {
            for ( Leave_Request__c reader : LeaveRequestList ){
                if ( reader.Tech_Supporting_Doc_Counter__c == null ){
                    reader.Tech_Supporting_Doc_Counter__c = 0;
                }
                reader.Tech_Supporting_Doc_Counter__c += 1;
            }
        } 
        if ( !LeaveRequestList.isempty() ) {
            update LeaveRequestList;
        }
    }
    
  }

}