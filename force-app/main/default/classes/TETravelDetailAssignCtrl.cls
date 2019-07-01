public without sharing class TETravelDetailAssignCtrl{

    Public Static String TDURLParameter = 'tdid';
    Public Static String TYPEParameter = 'type';
    Public Static String TSSParameter = './apex/TEShuttleAssignmentVFP';
    Public String tdID = '';
    Public String type = '';
    
    Public TETravelDetailAssignCtrl(){        
        this.tdID =  ApexPages.currentPage().getParameters().get(TDURLParameter);
        this.type =  ApexPages.currentPage().getParameters().get(TYPEParameter);
        
    }
    
    Public PageReference action(){
        String keyPrefix = Travel_Detail__c.sObjectType.getDescribe().getKeyPrefix();
        Date routeDate = null;
        String routeId = null;
        Travel_Detail__c td = null;
        Car_Journey__c cj = null;
        PageReference prf = new PageReference('/'+keyPrefix);
        
        if (this.tdID == null || this.type == null){
            prf.setRedirect(true);
            return prf;
        }
        for (Travel_Detail__c reader : [select Preferred_Departure_Date__c, Preferred_Return_Date__c, Departure_Route__c, Return_Route__c 
                                        from travel_detail__c where id = :tdID] ){
            td = reader;
        }
        tdID = TSSParameter;
        if ( td != null){
            if( this.type == 'd'){
                routeDate = td.Preferred_Departure_Date__c;
                routeId = td.Departure_Route__c;
            }
            if( this.type == 'r'){
                routeDate = td.Preferred_Return_Date__c;
                routeId = td.Return_Route__c ;
            }
            for (Car_Journey__c reader : [select id from Car_Journey__c where date__c = :routeDate and route__c = :routeId]){
                this.tdID = reader.id;
            }   
            prf = new PageReference('/'+this.tdID);
        }
        prf.setRedirect(true);
        return prf;
    }
}