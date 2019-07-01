/**
 * TETravelApplicationDelCtrl
 * @description Applicant to Delete Travel Application(s)
 * @author kong
 */
public without sharing class TETravelApplicationDelCtrl{
    private Travel_Application__c ea {get; set;}
    
    /**
     * @description constructor with StandardController
     */
    public TETravelApplicationDelCtrl (ApexPages.StandardController controller){
        this.ea=(Travel_Application__c)controller.getRecord();
        for(Travel_Application__c reader : [select id, status__c from Travel_Application__c where id = :this.ea.id ]){
            this.ea = reader;
        }
        
    }
    
    public PageReference action() {
        String path = '';
        if (this.ea.status__c != TEConstant.STATUS_DRAFT){
            path = 'javascript: alert(\''+ Label.TE_General_Del_Error +'\');window.history.back();';             
        }
        else{
            delete ea;
            path = '/'+Travel_Application__c.sObjectType.getDescribe().getKeyPrefix();
        }
        return new PageReference(path);        
    }
    
}