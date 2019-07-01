/**
 * TravelLocationOverwriteNewController
 * @description override new button of Travel Location
 * @author Kelvin Wong
 */
public without sharing class TravelLocationOverwriteNewController 
{    
    String recordTypeId;
    Map<Id, String> recordtype = new Map<Id, String> ();
    public boolean isSalesforceOne{get;set;} {isSalesforceOne = SystemUtil.isMobileDevice();}
    public String selectedRecordType{get;set;}
    
    /**
     * @description get prefix identifier of the object
     * @return string of the prefix
     */
    public String preFix{get;set;}{
        preFix = '';
        Schema.DescribeSObjectResult r = Travel_Location__c.sObjectType.getDescribe();
        preFix  = r.getKeyPrefix();
    }
    
    /**
     * @description contructor with StandardController
     * @param controller Controller of Travel Locaiton(s)
     */
    public TravelLocationOverwriteNewController (ApexPages.StandardController controller) {
          
    }
    /**
     * @description redirect the user right away if the user is on Web and has a single record type assigned
     * @return the URL to redirect
     */ 
    public PageReference redirectIfOnlySingleRecordType() {
        PageReference p;
        String returnURL = '/'+preFix+'/e?nooverride=1&Name='+Label.TE_Travel_Location_Default_Name+'&retURL=%2F'+preFix ;
        p = new PageReference(returnURL);
        //https://talgroup--uat.cs6.my.salesforce.com/a16/e?Name=%3CSYSTEM+GENERATED%3E&nooverride=1&retURL=%2Fa16
        return p;
    }
}