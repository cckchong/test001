public without sharing class TEExpenseApplicationOverwriteEditCtrl
{    

    public String textId{get;set;}
    
    
    public TEExpenseApplicationOverwriteEditCtrl(ApexPages.StandardController controller) {
         textId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference redirect() {
      
        return new PageReference('/apex/' + Label.ExpenseApplicationVFP+ '?id=' + textId); 
    }
     
}