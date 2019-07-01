/**
 * TraveDistanceOverwriteNewController
 * @author Kelvin Wong
 * @description override new button of Travel Distance
 */
public without sharing class TravelDistanceOverwriteNewController 
{    
    /**
     * @description contructor with StandardController
     * @param controller Controller of Travel Distance(s)
     */ 
    public TravelDistanceOverwriteNewController (ApexPages.StandardController controller) {}
    
    /**
     * @description redirect the user right away if the user is on Web and has a single record type assigned
     * @return the URL to redirect
     */ 
    public PageReference redirectIfOnlySingleRecordType() {
       
       Schema.DescribeSObjectResult r = Travel_Distance__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        return new PageReference('/'+keyPrefix+'/e?Name='+Label.TE_Travel_Distance_Default_Name+'&nooverride=1&retURL=%2F'+keyPrefix);
        
        
    }
     
}