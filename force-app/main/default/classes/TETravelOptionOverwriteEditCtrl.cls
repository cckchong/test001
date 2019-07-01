public without sharing class TETravelOptionOverwriteEditCtrl
{    

    public String textId{get;set;}
    private string taId;
    
    
    public TETravelOptionOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
         for(TravelOption__c to : [
            SELECT Id, Travel_Application__r.Id
            FROM TravelOption__c
            WHERE Id = :textId
        ]) {
            taId = to.Travel_Application__r.Id;
        }
    }

    public PageReference redirect() {
        return new PageReference('/apex/' + Label.TravelApplicationVFP+ '?taid=' + taId + '#tabs-3'); 
    }
     
}