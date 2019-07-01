/**
 * TEEducationRequestStatusController 
 * @description To change status in education requests
 * @author Kelvin Wong
 */
public without sharing class TEEducationRequestStatusController
{
    //private List<ID> idList;
    private ID textId;
    
    /**
     * constructor with StandardController
     * @param  controller controller of education request(s)
     */
    public TEEducationRequestStatusController ( ApexPages.StandardController controller) {
        
        //idList = new List<ID> ();
        this.textId = ApexPages.currentPage().getParameters().get('id');
        if (this.textId != null) {
            //Travel_Application__c a = controller;
            //this.textId = 'a0mO0000005DtBRIA0';
        }
    }
    
    /**
     * change status upon save
     * @return the URL after being saved
     */
    public PageReference SaveAction(){
        
        Education_Application__c EducationApplication = null;
        for( Education_Application__c reader : [ Select id, Status__c from Education_Application__c where id = :this.textId]){
            reader.Status__c = TEConstant.STATUS_NOT_SUBMITTED;
            EducationApplication = reader;
        }
        upsert EducationApplication;

        return new PageReference('/' + EducationApplication.id );  
    }
    
    /**
     * change status upon submit
     * @return the URL after being submitted
     */
    public PageReference SubmitAction(){
        
        Education_Application__c EducationApplication = null;
        for( Education_Application__c reader : [ Select id, Status__c from Education_Application__c where id = :this.textId]){
            reader.Status__c = TEConstant.STATUS_PENDING_APPROVAL;
            EducationApplication = reader;
        }
        upsert EducationApplication;

        return new PageReference('/' + EducationApplication.id );  
    }

    
}