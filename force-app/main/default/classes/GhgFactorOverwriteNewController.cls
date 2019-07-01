/**
 * GhgFactorOverwriteNewController
 * @author Kelvin Wong
 * @description override new button of GHG Factor
 */
public without sharing class GhgFactorOverwriteNewController 
{    

   public PageReference redirect() {
        String preFix = '';
        Schema.DescribeSObjectResult r = GHG_Factor__c.sObjectType.getDescribe();
        preFix  = r.getKeyPrefix();
        return new PageReference( '/' + preFix + '/e?Name=%3CSYSTEM+GENERATED%3E&nooverride=1&retURL=%2F' + preFix );
    }

    /**
     * @description contructor with StandardController
     * @param controller controller of GHG Factor(s)
     */
    public GhgFactorOverwriteNewController (ApexPages.StandardController controller) {
        
    }
 
}