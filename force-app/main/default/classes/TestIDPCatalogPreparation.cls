@istest
public class TestIDPCatalogPreparation {
    
    //format: [key, value]
    //[Catalog_Name__c, Records]
    //Available key: [Administration, Machinery, TAA Local Catalog]
    public Map<String, Catalog__c> catalogAllMap {get;set;}

    //[Catalog_Name__c, Records]
    //Available key: [Administration_HKO, Machinery_TAA, TAA Local Catalog_TAA]    
    public Map<String, Catalog_Policy_Setting__c> catalogPolicySettingMap {get;set;}
    public Map<String, Currency__c> currencyMap;
    public Map<String, IDP_Policy__c> idpPolicyMap;
    public Map<String, User> userMap;
    public boolean isSeeAllData;
    //Public Map<String, Catalog__c> catalogLevelOneMap {get;set;}
    //Public Map<String, Catalog__c> catalogLevelTwoMap {get;set;}
    
    
    public TestIDPCatalogPreparation (boolean isSeeAllData,  Map<String, Currency__c> currencyMap, Map<String, IDP_Policy__c> idpPolicyMap, Map<String, User> userMap) {
        this.isSeeAllData = isSeeAllData;
        initVariable(currencyMap,idpPolicyMap, userMap);

    }
    
    public void initVariable(Map<String, Currency__c> currencyMap, Map<String, IDP_Policy__c> idpPolicyMap, Map<String, user> userMap) {
        this.catalogAllMap = new Map<String, Catalog__c> ();
        this.catalogPolicySettingMap = new Map<String, Catalog_Policy_Setting__c> ();
        this.currencyMap = currencyMap;
        this.idpPolicyMap = idpPolicyMap;
        this.userMap = userMap;
        //this.catalogLevelOneMap = new Map<String, Catalog__c> (); 
        //this.catalogLevelTwoMap = new Map<String, Catalog__c> ();
    }
    
    public void basicSetting() {
        prepareLevelOneCatalogData();
        system.debug(LoggingLevel.ERROR, this.catalogAllMap);
        prepareLevelTwoCatalogData();
        prepareCatalogPolicySetting();
    }
    
    
    public void prepareLevelOneCatalogData() {

        List<Catalog__c> toBeInsertedCatalog = new List<Catalog__c>();
        Map<String, Id> queueNameIdMap = new Map<String, Id> ();

        for(Group q:  [SELECT Id, DeveloperName From group WHERE Type ='Queue' and DeveloperName Like 'IDP_%']) {
            queueNameIdMap.put(q.DeveloperName, q.Id);
        }
        Catalog__c catalogAdmin = new Catalog__c (
            Name = 'Administration',
            Catalog_Name__c = 'Administration',
            Catalog_Code__c = 'I01',
            OwnerId = queueNameIdMap.get('IDP_Catalog_Administration'),
            C_Level_Approver__c = UserMap.get('clevel').Id
        );        

        Catalog__c catalogMachinery = new Catalog__c(
            Name = 'Machinery',
            Catalog_Name__c = 'Machinery',
            Catalog_Code__c = 'I02',
            OwnerId = queueNameIdMap.get('IDP_Catalog_Machinery'),
            C_Level_Approver__c = UserMap.get('clevel').Id,
            ROI_Approver__c = UserMap.get('roiUser').Id


        );   
          
        Catalog__c catalogTAALocal = new Catalog__c(
            Name = 'TAA Local Catalog',
            Catalog_Name__c = 'TAA Local Catalog',
            Catalog_Code__c = 'I03',
            OwnerId = queueNameIdMap.get('IDP_Catalog_TAA'),
            C_Level_Approver__c = UserMap.get('clevel').Id

        );             
        toBeInsertedCatalog.add(catalogAdmin);
        toBeInsertedCatalog.add(catalogMachinery);
        toBeInsertedCatalog.add(catalogTAALocal);

        insert toBeInsertedCatalog;
        
        for(Catalog__c reader : [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, 
                                        LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
                                        Parent_Catalog__c,  Catalog_Code__c, Catalog_Name__c, //Level__c, 
                                        Description__c, Display_Name__c, Tech_Is_Owner__c, Parent_Catalog_Name__c, ROI_Approver__c, 
                                        C_Level_Approver__c, Tech_Catalog_Owner_Queue_Name__c 
                                FROM Catalog__c]) {
            this.catalogAllMap.put(reader.Catalog_Name__c, reader);
            //this.catalogLevelOneMap.put(reader.Name, reader);
        }
    }
    
    public void prepareLevelTwoCatalogData() {
        List<Catalog__c> toBeInsertedCatalog = new List<Catalog__c>();




        Catalog__c catalog1 = new Catalog__c (
            Name = 'Motor Vehicles',
            Parent_Catalog__c = catalogAllMap.get('Administration').Id,
            Catalog_Name__c = 'Motor Vehicles',
            Catalog_Code__c = 'IDP-ADMIN_MOTOR'
            //OwnerId = '',
            //C_Level_Approver__c = '',
            //ROI_Approver__c = ''
        );        
        Catalog__c catalog2 = new Catalog__c(
            Name = 'Shirts - Cutting',
            Parent_Catalog__c = catalogAllMap.get('Machinery').Id,
            Catalog_Name__c = 'Shirts - Cutting',
            Catalog_Code__c = 'IDP-MACH-SHIRT'
        );   
          
        Catalog__c catalog3 = new Catalog__c(
            Name = 'General',
            Parent_Catalog__c = catalogAllMap.get('TAA Local Catalog').Id,
            Catalog_Name__c = 'General',
            Catalog_Code__c = 'IDP-TAALOCAL-GEN'
        );             
        toBeInsertedCatalog.add(catalog1);
        toBeInsertedCatalog.add(catalog2);
        toBeInsertedCatalog.add(catalog3);    
        
        insert toBeInsertedCatalog;
        
        for(Catalog__c reader : [SELECT Id, Catalog_Name__c, Catalog_Code__c, Parent_Catalog__c,
                                        Parent_Catalog__r.Catalog_Name__c, Parent_Catalog__r.Catalog_Code__c
                                FROM Catalog__c
                                WHERE Id in : toBeInsertedCatalog]) {
            this.catalogAllMap.put(reader.Catalog_Name__c, reader);
            //this.catalogLevelTwoMap.put(reader.Catalog_Name__c, reader);
        }
    }
    
    public void prepareCatalogPolicySetting() {
        List<Catalog_Policy_Setting__c> toBeInsertedCatalogPolicySetting = new List<Catalog_Policy_Setting__c>();
        String key = '';
        Catalog_Policy_Setting__c tempCPS1 = new Catalog_Policy_Setting__c(
            Catalog__c = catalogAllMap.get('Administration').Id,
            IDP_Policy__c = idpPolicyMap.get('HKO').Id,
            First_Threshold__c = 5000,
            Second_Threshold__c = 5000,
            PR_Amount_Tier_Currency__c = currencyMap.get('USD').Id,
            Approval_Workflow__c = 'Approval_Workflows_Type_Head_Office'
        );
        
        Catalog_Policy_Setting__c tempCPS2 = new Catalog_Policy_Setting__c(
            Catalog__c = catalogAllMap.get('Machinery').Id,
            IDP_Policy__c = idpPolicyMap.get('TAA').Id,
            First_Threshold__c = 2500,
            Second_Threshold__c = 5000,
            PR_Amount_Tier_Currency__c = currencyMap.get('USD').Id,
            Approval_Workflow__c = 'IDP_Catalog_Machinery'
        );            


        Catalog_Policy_Setting__c tempCPS3 = new Catalog_Policy_Setting__c(
            Catalog__c = catalogAllMap.get('TAA Local Catalog').Id,
            IDP_Policy__c = idpPolicyMap.get('TAA').Id,
            First_Threshold__c = 2500,
            Second_Threshold__c = 5000,
            PR_Amount_Tier_Currency__c = currencyMap.get('USD').Id,
            Approval_Workflow__c = 'IDP_Catalog_TAA'
            
        );       
        
        toBeInsertedCatalogPolicySetting.add(tempCPS1);
        toBeInsertedCatalogPolicySetting.add(tempCPS2);     
        toBeInsertedCatalogPolicySetting.add(tempCPS3);
        
        insert toBeInsertedCatalogPolicySetting;
        
        
        for(Catalog_Policy_Setting__c reader :  toBeInsertedCatalogPolicySetting) {
            
            system.debug('catalogAllMap:'+catalogAllMap);
            system.debug('Catalog_Policy_Setting__c:'+reader);
            //system.debug('catalogAllMap.get(reader.Catalog__c).Catalog_Name__c:'+catalogAllMap.get(reader.Catalog__c).Catalog_Name__c);
            //system.debug('idpPolicyMap.get(reader.IDP_Policy__c).Name:'+idpPolicyMap.get(reader.IDP_Policy__c).Name);
            
            String catalogName = '';
            for (String catalogKey : catalogAllMap.keySet()) {
                if (catalogAllMap.get(catalogKey).Id == reader.Catalog__c) {
                    catalogName = catalogKey;
                    break;
                }
            }

            String policyName = '';
            for (String policyKey : idpPolicyMap.keySet()) {
                if (idpPolicyMap.get(policyKey).Id == reader.IDP_Policy__c) {
                    policyName = policyKey;
                    break;
                }
            }

            //key = catalogAllMap.get(reader.Catalog__c).Catalog_Name__c + '_' + idpPolicyMap.get(reader.IDP_Policy__c).Name;
            key = catalogName + '_' + policyName;
            system.debug('key:'+key);
            catalogPolicySettingMap.put(key, reader);
        }
    }
    
}