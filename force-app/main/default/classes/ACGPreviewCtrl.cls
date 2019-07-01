public without sharing class ACGPreviewCtrl {
	public ApexPages.Component [] portalComponent {get; set;}
	public Integer iSize {get;set;}
	public String strType {get;set;}
	public Portal_Content__c objPC {get;set;}
	public String strErrorMessage {get;set;} 
    public Boolean bSalesforceOne {get;set;}
	public ACGPreviewCtrl() {		 
	    bSalesforceOne = SystemUtil.isMobileDevice();
	    if(!bSalesforceOne) {
        	bSalesforceOne = ApexPages.currentPage().getParameters().get('isMobileDevice') == null ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get('isMobileDevice'));
        }
		Id componentID = ApexPages.currentPage().getParameters().get('Id') == null ? '' : ApexPages.currentPage().getParameters().get('Id');
		iSize = Integer.valueof(ApexPages.currentPage().getParameters().get('size') == null ? '0' : ApexPages.currentPage().getParameters().get('size'));
		strType = ApexPages.currentPage().getParameters().get('type') == null ? 'richtext' : ApexPages.currentPage().getParameters().get('type');
        strErrorMessage = '';        
		portalComponent = new ApexPages.Component[1];		
		if(strType.toUpperCase() == 'HTML') {
			portalComponent[0] = new Component.c.HTMLComponent(Id=componentID, recordRef=componentID, isEditable=false);
		} else {
			portalComponent[0] = new Component.c.ACGArticleFullComponent(recordRef=componentID, isEditable=false, articleRef=componentID, title='Preview');
		}		
	}
}