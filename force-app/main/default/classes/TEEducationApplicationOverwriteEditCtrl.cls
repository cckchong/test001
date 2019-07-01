public without sharing class TEEducationApplicationOverwriteEditCtrl
{    

    public String textId{get;set;}
    
    
    public TEEducationApplicationOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {
      
        return new PageReference('/apex/' + Label.EducationApplicationVFP+ '?id=' + textId); 
    }
     
}