@istest
Public class TestIDPPolicyPreparation {
    
    //format: [key, value]
    //[Policy name, Records], Available key: [HKO, TAA]
    Public Map<String, IDP_Policy__c> idpPolicyMap {get;set;}
    Public boolean isSeeAllData;

    Public TestIDPPolicyPreparation (boolean isSeeAllData) {
        this.isSeeAllData = isSeeAllData;
        initVariable();

    }
    
    Public void initVariable() {
        this.idpPolicyMap = new Map<String, IDP_Policy__c> ();
    }
    
    Public void basicSetting() {
        prepareIDPPolicyTestData();
    }
    
    
    Public void prepareIDPPolicyTestData() {
        List<IDP_Policy__c> toBeInsertedIDPPolicy = new List<IDP_Policy__c>();
        IDP_Policy__c policyHKO = new IDP_Policy__c (
            Name = 'HKO',
            Is_Group_Procurement__c = true
        );        

        IDP_Policy__c policyTAA = new IDP_Policy__c (
            Name = 'TAA',
            Is_Group_Procurement__c = false
        );     
        
        toBeInsertedIDPPolicy.add(policyHKO);
        toBeInsertedIDPPolicy.add(policyTAA);
        
        insert toBeInsertedIDPPolicy;
        
        for(IDP_Policy__c reader : toBeInsertedIDPPolicy ) {
            this.idpPolicyMap.put(reader.Name, reader);
        }
    }
    
}