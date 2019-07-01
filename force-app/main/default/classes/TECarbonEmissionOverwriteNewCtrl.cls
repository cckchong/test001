/**
 * TECarbonEmissionOverwriteNewCtrl
 * @description override new button of Carbon Emission
 */
public without sharing class TECarbonEmissionOverwriteNewCtrl 
{    

    public PageReference redirect() {
        String preFix = '';
        Schema.DescribeSObjectResult r = Carbon_Emission__c.sObjectType.getDescribe();
        preFix  = r.getKeyPrefix();
        return new PageReference( '/' + preFix + '/e?Name=%3CSYSTEM+GENERATED%3E&nooverride=1&retURL=%2F' + preFix );
    }
    
    /**
     * @description contructor with StandardController
     */
    public TECarbonEmissionOverwriteNewCtrl (ApexPages.StandardController controller) {
         
    }
    
}