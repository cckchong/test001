public without sharing class TETravelPriceOverwriteEditCtrl
{    

    public String textId{get;set;}
    private string taId;
    
    
    public TETravelPriceOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
         for(Travel_Price__c a : [
            SELECT Id, Travel_Application__r.Id
            FROM Travel_Price__c
            WHERE Id = :textId
        ]) {
            taId = a.Travel_Application__r.Id;
        }
    }

    public PageReference redirect() {
        return new PageReference('/apex/' + Label.TravelApplicationVFP+ '?taid=' + taId + '#tabs-5'); 
    }
     
}