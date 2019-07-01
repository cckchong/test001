public without sharing class TETravelOptionTriggerHandler { 
    
     public static void chatterPost( List<TravelOption__c> travelOptionList){
         Boolean isChange = false;
         Set<id> taSet = new Set<id>();
         for(TravelOption__c reader : travelOptionList){
             if ( reader.status__c == TEConstant.STATUS_PENDING_SELECTION && (reader.Option1__c != NULL || reader.Option2__c != NULL || reader.Option3__c != NULL)){
                 taSet.add(reader.Travel_Application__c); 
             }
         }
         if(!taSet.isEmpty()){ 
             post(taSet);
         }
     }
     
     public static void chatterPost(Map<Id, TravelOption__c> OldtravelOptionMap, Map<Id, TravelOption__c> NewtravelOptionLMap){
         Boolean isChange = false;
         Set<id> taSet = new Set<id>();
         for(TravelOption__c reader : NewtravelOptionLMap.values()){
             isChange = false;
             if(reader.Option1__c != OldtravelOptionMap.get(reader.id).Option1__c && reader.status__c == TEConstant.STATUS_PENDING_SELECTION ){
                 isChange = true;
             }
             if(reader.Option2__c != OldtravelOptionMap.get(reader.id).Option2__c && reader.status__c == TEConstant.STATUS_PENDING_SELECTION ){
                 isChange = true;
             }
             if(reader.Option3__c != OldtravelOptionMap.get(reader.id).Option3__c && reader.status__c == TEConstant.STATUS_PENDING_SELECTION ){
                 isChange = true;
             }
             if(reader.status__c != OldtravelOptionMap.get(reader.id).status__c && reader.status__c == TEConstant.STATUS_PENDING_SELECTION ){
                 isChange = true;
             }
             if(isChange){
                 taSet.add(reader.Travel_Application__c); 
             }
         }
         if(!taSet.isEmpty()){ 
             post(taSet);
         }
     }
     
     public static void post(Set<id> taidSet){
         List <FeedComment> listfcomment = new List <FeedComment>();
         String content = '';
         String contenth1 = '';
         String contenth2 = '';
         String contenth3 = '';
         String content1 = '';
         String content2 = '';
         String content3 = '';
         String Hotelcontenth = '';
         String Hotelcontent = '';
         List <Id> activeUserList = null;
         //content += '\n\n';
         for(travel_application__c reader : [select id, ChatterFeedId__c, createdbyid,
                                             Option_Estimated_Currency__r.Name, Option_Estimated_Currency2__r.Name,Option_Estimated_Currency3__r.Name,
                                             Option_Estimated_Price1__c, Option_Estimated_Price2__c, Option_Estimated_Price3__c,                                             
                                             (select id, recordType.Name, 
                                             From__r.Name, Destination__r.Name, To__r.Name,
                                             From__r.City_Code__c, Destination__r.City_Code__c, To__r.City_Code__c,
                                             Departure_Date__c, Check_in_Date__c, Check_out_Date__c,
                                             Option1__c, Option2__c, Option3__c from travelOptions__r order by recordTypeId, Departure_Date__c, Check_in_Date__c)
                                             from travel_application__c where id in :taidSet] ){
             activeUserList = new List <Id>();
             activeUserList.add(reader.createdbyid);             
             Hotelcontenth = '\n'+'Hotel Option(s): ';
             Hotelcontenth += '\n'+'=================================';
             
             contenth1 = '\n'+'Air Option 1: ';
             if( reader.Option_Estimated_Currency__r.Name != null || reader.Option_Estimated_Price1__c != null){
                 contenth1 += reader.Option_Estimated_Currency__r.Name +' '+ String.Valueof(reader.Option_Estimated_Price1__c);
             }
             contenth1 += '\n'+'=================================';
             
             contenth2 = '\n'+'Air Option 2: ';
             if( reader.Option_Estimated_Currency2__r.Name != null || reader.Option_Estimated_Price2__c != null){
                 contenth2 += reader.Option_Estimated_Currency2__r.Name +' '+ String.Valueof(reader.Option_Estimated_Price2__c);
             }
             contenth2 += '\n'+'=================================';
             
             contenth3 = '\n'+'Air Option 3: ';
             if( reader.Option_Estimated_Currency3__r.Name != null || reader.Option_Estimated_Price3__c != null){
                 contenth3 += reader.Option_Estimated_Currency3__r.Name +' '+ String.Valueof(reader.Option_Estimated_Price3__c);
             }
             contenth3 += '\n'+'=================================';
             
             for(travelOption__c toReader : reader.travelOptions__r){
                 if(toReader.RecordType.Name == 'Hotel'){
                     if(!String.IsBlank(toReader.Option1__c)){
                         Hotelcontent += '\n';
                         if(toReader.Destination__r.Name != null){
                             Hotelcontent += 'Location: ' + toReader.Destination__r.Name+'\n';
                         }
                         if(toReader.Check_in_Date__c != null){
                             Hotelcontent += 'Check-In Date: ' + ((DateTime)toReader.Check_in_Date__c).format('dd MMMM YYYY') +'\n';
                         }
                         if(toReader.Check_out_Date__c != null){
                             Hotelcontent += 'Check-Out Date: ' + ((DateTime)toReader.Check_out_Date__c ).format('dd MMMM YYYY') +'\n';
                         }
                         Hotelcontent += toReader.Option1__c.replace(';', '\n') +'\n';
                     }
                 }
                 if(toReader.RecordType.Name == 'Air'){
                     if(!String.IsBlank(toReader.Option1__c)){
                         content1 += '\n';
                         if(toReader.From__r.City_Code__c!= null){
                             content1 += toReader.From__r.City_Code__c;//+'\n';
                         }else{
                             if(toReader.From__r.Name != null){
                                 content1 += toReader.From__r.Name;//+'\n';
                             }
                         }
                         
                         if(toReader.To__r.City_Code__c!= null){
                             content1 += ' --> ' + toReader.To__r.City_Code__c;//+'\n';
                         }else{
                             if(toReader.To__r.Name != null){
                                 content1 += ' --> ' + toReader.To__r.Name;//+'\n';
                             }
                         }
                         
                         if(toReader.Departure_Date__c != null){
                             //content1 += 'Date: '+ ((DateTime)toReader.Departure_Date__c).format('dd MMMM YYYY') +'\n';
                             content1 += '  '+ ((DateTime)toReader.Departure_Date__c).format('dd MMMM YYYY') +'\n';
                         }
                         //content1 += toReader.Option1__c +'\n';
                         content1 += toReader.Option1__c.replace(';', '\n');
                     }
                     
                     if(!String.IsBlank(toReader.Option2__c)){
                         content2 += '\n';
                         if(toReader.From__r.City_Code__c!= null){
                             content2 += toReader.From__r.City_Code__c;//+'\n';
                         }else{
                             if(toReader.From__r.Name != null){
                                 content2 += toReader.From__r.Name;//+'\n';
                             }
                         }
                         
                         if(toReader.To__r.City_Code__c!= null){
                             content2 += ' --> ' + toReader.To__r.City_Code__c;//+'\n';
                         }else{
                             if(toReader.To__r.Name != null){
                                 content2 += ' --> ' + toReader.To__r.Name;//+'\n';
                             }
                         }
                         
                         if(toReader.Departure_Date__c != null){
                             //content2 += 'Date: '+ ((DateTime)toReader.Departure_Date__c).format('dd MMMM YYYY') +'\n';
                             content2 += '  '+ ((DateTime)toReader.Departure_Date__c).format('dd MMMM YYYY') +'\n';
                         }
                         //content2 += toReader.Option2__c +'\n';
                         content2 += toReader.Option2__c.replace(';', '\n');
                     }
                     
                     if(!String.IsBlank(toReader.Option3__c)){
                         content3 += '\n';
                         if(toReader.From__r.City_Code__c!= null){
                             content3 += toReader.From__r.City_Code__c;//+'\n';
                         }else{
                             if(toReader.From__r.Name != null){
                                 content3 += toReader.From__r.Name;//+'\n';
                             }
                         }
                         
                         if(toReader.To__r.City_Code__c!= null){
                             content3 += ' --> ' + toReader.To__r.City_Code__c;//+'\n';
                         }else{
                             if(toReader.To__r.Name != null){
                                 content3 += ' --> ' + toReader.To__r.Name;//+'\n';
                             }
                         }
                         
                         if(toReader.Departure_Date__c != null){
                             //content3 += 'Date: '+ ((DateTime)toReader.Departure_Date__c).format('dd MMMM YYYY') +'\n';
                             content3 += '  '+ ((DateTime)toReader.Departure_Date__c).format('dd MMMM YYYY') +'\n';
                         }
                         //content3 += toReader.Option3__c +'\n';
                         content3 += toReader.Option3__c.replace(';', '\n');
                     }
                 } 
             }
             
             if(!String.IsBlank(content1)){
                 content += contenth1 + content1 + '\n';
             }
             if(!String.IsBlank(content2)){
                 content += contenth2 + content2 + '\n';
             }
             if(!String.IsBlank(content3)){
                 content += contenth3 + content3 + '\n';
             }
             if(!String.IsBlank(Hotelcontent)){
                 content += Hotelcontenth + Hotelcontent + '\n';
             }
             content = 'Please select option(s)' + '\n' 
                        + content;
             content = content.unescapeJava().unescapeHtml4();
             if(!test.isrunningtest()){
                 ChatterUtil.simpleTextPostWithMultipleMentions(reader.id, activeUserList, content, 'AllUsers');
             }
             //listfcomment.add(new FeedComment(FeedItemId = reader.ChatterFeedId__c, CommentBody = content));
        }
        /*
        if (!listfcomment.isempty()){
             upsert listfcomment;
         }
         */ 
         
     }
     
               
     
}