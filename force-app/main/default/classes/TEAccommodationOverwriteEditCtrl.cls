public without sharing class TEAccommodationOverwriteEditCtrl
{    

    public String textId{get;set;}
    private string taId;
    
    
    public TEAccommodationOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
         for(Accommodation__c a : [
            SELECT Id, Travel_Application__r.Id
            FROM Accommodation__c 
            WHERE Id = :textId
        ]) {
            taId = a.Travel_Application__r.Id;
        }
    }

    public PageReference redirect() {
        return new PageReference('/apex/' + Label.TravelApplicationVFP+ '?taid=' + taId + '#tabs-2'); 
    }
     
}