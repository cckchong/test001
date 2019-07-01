public without sharing class TEExpenseDetailOverwriteEditCtrl
{    

    public String textId{get;set;}
    
    
    public TEExpenseDetailOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {
      
        return new PageReference('/apex/' + Label.ExpenseApplicationVFP+ '?id=' + textId); 
    }
     
}