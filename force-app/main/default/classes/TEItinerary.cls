/**
 * TEItinerary
 * @description Travel Application Itinerary Attachment Handler
 */
public without sharing class TEItinerary {
    
    Public Static String INDICATOR = '--------------';
    Public Static String SPLIT = '[\r\n]';
    Public Static String ENDPOINT = '##';
    Public String itineraryDate {get; set;}
    Public String fullContent;
    Public List <String> journeyList {get; set;}
    Public List <TETripInfo> tripInfoList {get; set;}
    Public TETripInfo tripInfo {get; set;}
    /**
     * @description constructor with TEItinerary
     */
    Public TEItinerary( String fullContent ){        
        tripInfoList = new List <TETripInfo>();
        this.itineraryDate = '';
        this.fullContent = fullContent;
        journeyList = itineraryReader( this.fullContent );
        for ( String reader : journeyList ){
            tripInfo = new TETripInfo (this.itineraryDate, reader, ENDPOINT);
            if(!tripInfo.isskip){
                tripInfoList.add(tripInfo);
            }
        }
        
    }
    /**
     * @description itinerary reader for travel application attachment 
     */    
    Public List<String> itineraryReader( String fullContent ) {        
        List <String> readerList = fullContent.split(SPLIT);
        List <String> contentList = new List <String>();
        Boolean startRecord = false;
        String temp = '';
        for ( String reader : readerList ){
            if ( itineraryDate == '' ){
                itineraryDate = reader.replaceall(' ','');
                itineraryDate = itineraryDate.substring(itineraryDate.length()-7, itineraryDate.length());
            }
            if ( reader.contains(INDICATOR) ){
                startRecord = !startRecord;
                if ( temp.length() > 0 ){
                    contentList.add(temp);
                }
                continue;
            }
            
            if ( startRecord ){
                if ( reader != '  '){
                     if ( reader.length() > 0  ){                         
                         temp += reader + ENDPOINT;
                     }
                }
                else {                
                    if ( temp.length() > 0 ){
                        contentList.add(temp);
                        temp = '';
                    }
                }                
            }
        }
       
        return contentList;
    }
    
    

}