public without sharing class TETravelDetailOverwriteEditCtrl
{    

    public String textId{get;set;}
    private string taId;
    
    
    public TETravelDetailOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
         for(Travel_Detail__c td : [
            SELECT Id, Travel_Application__r.Id
            FROM Travel_Detail__c 
            WHERE Id = :textId
        ]) {
            taId = td.Travel_Application__r.Id;
        }
    }

    public PageReference redirect() {
        return new PageReference('/apex/' + Label.TravelApplicationVFP+ '?taid=' + taId + '#tabs-1'); 
    }
     
}