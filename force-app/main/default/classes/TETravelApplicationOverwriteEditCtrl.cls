public without sharing class TETravelApplicationOverwriteEditCtrl
{    

    public String textId{get;set;}
    
    
    public TETravelApplicationOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {
        //return new PageReference('http://google.com');
        return new PageReference('/apex/' + Label.TravelApplicationVFP+ '?taid=' + textId); 
    }
     
}