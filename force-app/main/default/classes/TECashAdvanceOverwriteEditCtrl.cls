public without sharing class TECashAdvanceOverwriteEditCtrl
{    

    public String textId{get;set;}
    private string taId;
    
    
    public TECashAdvanceOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
         for(Cash_Advance__c a : [
            SELECT Id, Travel_Application__r.Id
            FROM Cash_Advance__c
            WHERE Id = :textId
        ]) {
            taId = a.Travel_Application__r.Id;
        }
    }

    public PageReference redirect() {
        return new PageReference('/apex/' + Label.TravelApplicationVFP+ '?taid=' + taId + '#tabs-4'); 
    }
     
}