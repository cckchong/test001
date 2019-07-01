@istest
Public class TestIDPSitePreparation {
    

    Public String RANDOM_STRING = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    
    //Available key: [HKO, TAA]   
    Public Map<String, Site__c> siteMap {get;set;}
    
    Public boolean isSeeAllData;

    
    Public TestIDPSitePreparation (boolean isSeeAllData) {
        this.isSeeAllData = isSeeAllData;
        initVariable();

    }
    
    Public void initVariable() {
        this.siteMap = new Map<String, Site__c> ();
    }
    
    Public void basicSetting() {
        prepareSiteData();
    }
    
    Public void prepareSiteData() {
       List<Site__c> toBeInsertedSiteList = new List<Site__c>();
        Site__c site1 = new Site__c (
            Name = 'HKO',
            Site_ID__c = 'HKO'
        );
        
        Site__c site2 = new Site__c (
            Name = 'TAA',
            Site_ID__c = 'TAA'
        );
        toBeInsertedSiteList.add(site1);
        toBeInsertedSiteList.add(site2);
        
        
        insert toBeInsertedSiteList;
        
        for (Site__c s : toBeInsertedSiteList) {
            this.siteMap.put(s.Name, s);
        }    
    
    
    }
    
}