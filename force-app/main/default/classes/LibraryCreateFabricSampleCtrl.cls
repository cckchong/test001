/*
    LibraryCreateFabricSampleCtrl Class
    
    @Autor: AN, WG
    @Objects:  Sample_Fabric__c, Library_Item__c
    @Description: It is a controller class for Sample_Fabric__c 
*/
public without sharing class LibraryCreateFabricSampleCtrl {
    public Sample_Fabric__c sf {get;set;}
    public Library_Item__c fabric {get;set;}
    public String sampleName {get;set;}
    public String theSampleId {get;set;}
    public Boolean bEditMode {get;set;}
    public Boolean bEditAccess {get;set;}
    public Boolean bTGASamples {get;set;}
    
    /*
        Constructor
        if the sample fabric id not empty, then display the fabric info in page
        else create a new sample fabric
    */
    public LibraryCreateFabricSampleCtrl(ApexPages.StandardController ctrl) {
        String theId = ctrl.getRecord().Id;
        bEditMode = false;
        if(theId != null && theId != '') {
            List<Sample_Fabric__c> sf = [SELECT Fabric__c, Id, Sample__c, Sample__r.Item_Name__c, Sample__r.RecordType.DeveloperName FROM
            Sample_Fabric__c WHERE Id = : theId];
            
            if(!sf.isEmpty()) {
                List<Library_Item__c> fabric = new List<Library_Item__c>();
                fabric = [SELECT Item_Description__c, Id, RecordTypeId, Sample_Fabric_ID_1__c, Color_ID_1__c, Fls_Content__c, Content_Percent__c,
                        Fls_Content_2__c, Content_Percent_2__c, Fls_Content_3__c, Content_Percent_3__c, Fls_Content_4__c, Content_Percent_4__c,
                        Density_Warp__c, Density_Weft__c, Warp_Yarn_Size__c, Yarn_Type_Warp__c,
                        Weft_Yarn_Size__c, Yarn_Type_Weft__c, Fls_Woven_Type__c, Weave_Knit_Type_TGA__c,
                        Fls_Fabric_Finish__c,Fls_Color__c, Fls_Pattern__c, Fabric_ID__c  FROM Library_Item__c WHERE
                        Id = :sf[0].Fabric__c];
                
                if(!fabric.isEmpty()){
                    this.fabric = fabric[0];
                    this.theSampleId = sf[0].Sample__c;
                    this.sampleName = sf[0].Sample__r.Item_Name__c;
                    this.sf = sf[0];
                    bTGASamples = sf[0].Sample__r.RecordType.DeveloperName ==Label.Library_RecordType_SamplesTGA;
                }
            }
        } else {
            ApexPages.currentPage().getParameters().put(Label.retURL, '/' + theSampleId);
            theSampleId = ApexPages.currentPage().getParameters().get(Label.Library_SampleFabric_Id);
            this.sampleName = ApexPages.currentPage().getParameters().get(Label.Library_SampleFabric_Name);
            
            this.sf = new Sample_Fabric__c();
            this.sf.Sample__c = theSampleId;
            this.fabric = new Library_Item__c();
            Schema.DescribeSObjectResult r = Library_Item__c.sObjectType.getDescribe();
            Map<String,Schema.RecordTypeInfo> rtMapByName = r.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName =  rtMapByName.get(Label.Library_RecordType_Fabric);
            this.fabric.RecordTypeId =  rtByName.getRecordTypeId();
            
            List<Library_Item__c> samples = [Select Id, RecordType.DeveloperName FROM Library_Item__c Where Id = :theSampleId limit 1];
            if(!samples.isEmpty()) {
                bTGASamples = samples[0].RecordType.DeveloperName ==Label.Library_RecordType_SamplesTGA;
            }
        }
        bEditMode = ApexPages.currentPage().getParameters().get(Label.retURL)!=null && ApexPages.currentPage().getParameters().get(Label.retURL)!='';
        
        List<UserRecordAccess> ura = [SELECT RecordId, HasEditAccess, HasReadAccess, HasTransferAccess, MaxAccessLevel
                                 FROM UserRecordAccess
                                 WHERE RecordId  = :this.theSampleId
                                 AND UserId = :UserInfo.getUserId()
                                 limit 1];
        bEditAccess = ura.size()>0?ura.get(0).HasEditAccess:false;
        
    }
    
    //create new sample fabric
    public PageReference createNewButton() {
        fabric.Item_Description__c = '';
        if(fabric.Fls_Content__c != null) {
            fabric.Item_Description__c = fabric.Item_Description__c + fabric.Fls_Content__c;
            
            if(fabric.Content_Percent__c != null) {
                fabric.Item_Description__c = fabric.Item_Description__c + ' ' + fabric.Content_Percent__c + '% ';
            }
        }
        if(fabric.Fls_Content_2__c != null) {
            fabric.Item_Description__c = fabric.Item_Description__c + fabric.Fls_Content_2__c;
            
            if(fabric.Content_Percent_2__c != null) {
                fabric.Item_Description__c = fabric.Item_Description__c +  ' ' + fabric.Content_Percent_2__c + '% ';
            }
        }
        if(fabric.Fls_Content_3__c != null) {
            fabric.Item_Description__c = fabric.Item_Description__c +  fabric.Fls_Content_3__c;
            
            if(fabric.Content_Percent_3__c != null) {
                fabric.Item_Description__c = fabric.Item_Description__c +  ' ' + fabric.Content_Percent_3__c + '% ';
            }
        }
        if(fabric.Sample_Fabric_ID_1__c != null) {
            sf.Tech_Getting_Data__c = true;
        }
        
        try {
            if(fabric.Sample_Fabric_ID_1__c == null) {
                fabric.item_Name__c = Label.Library_fabricSample_itemname_prefix + this.sampleName;
            }
            upsert fabric;
            sf.Fabric__c = fabric.Id;
            upsert sf;
        } catch (System.DmlException ex) {
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getDmlMessage(i)));
            }       
            return null;
        }
        if(fabric.Sample_Fabric_ID_1__c != null) {
            LibraryItemTriggerHandler.upsertSampleFabric2(sf.Id, fabric.Id, fabric.Sample_Fabric_ID_1__c, fabric.Color_ID_1__c);
        }
        return new PageReference('/'+ theSampleId);
    }
    
    //redirect to standard edit sample fabric
    public PageReference editButton() {
        ApexPages.currentPage().getParameters().put(Label.retURL, '/' + theSampleId);   
        bEditMode = true;
        return null;
    }
    
    //save and create new sample fabric
    public PageReference saveAndNewButton() {
        fabric.Item_Description__c = '';
        if(fabric.Fls_Content__c != null) {
            fabric.Item_Description__c = fabric.Item_Description__c + fabric.Fls_Content__c;
            
            if(fabric.Content_Percent__c != null) {
                fabric.Item_Description__c = fabric.Item_Description__c + ' ' + fabric.Content_Percent__c + '% ';
            }
        }
        if(fabric.Fls_Content_2__c != null) {
            fabric.Item_Description__c = fabric.Item_Description__c + fabric.Fls_Content_2__c;
            
            if(fabric.Content_Percent_2__c != null) {
                fabric.Item_Description__c = fabric.Item_Description__c +  ' ' + fabric.Content_Percent_2__c + '% ';
            }
        }
        if(fabric.Fls_Content_3__c != null) {
            fabric.Item_Description__c = fabric.Item_Description__c +  fabric.Fls_Content_3__c;
            
            if(fabric.Content_Percent_3__c != null) {
                fabric.Item_Description__c = fabric.Item_Description__c +  ' ' + fabric.Content_Percent_3__c + '% ';
            }
        }
        try {
            if(fabric.Sample_Fabric_ID_1__c == null) {
                fabric.item_Name__c = Label.Library_fabricSample_itemname_prefix + this.sampleName;
            }
            upsert fabric;
            sf.Fabric__c = fabric.Id;
            upsert sf;
        } catch (System.DmlException ex) {
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getDmlMessage(i)));
            }       
            return null;
        }
        if(fabric.Sample_Fabric_ID_1__c != null) {
            LibraryItemTriggerHandler.upsertSampleFabric2(sf.Id, fabric.Id, fabric.Sample_Fabric_ID_1__c, fabric.Color_ID_1__c);
        }
        PageReference pr = new PageReference(Label.Library_FabricSample_SampleId + theSampleId + Label.Library_FabricSample_SampleName + sampleName);
        pr.setRedirect(true);
        return pr; 
    }
    
    //return back to the detail page of the sample id
    public PageReference cancelButton() {
        return new PageReference('/'+ theSampleId);
    }
}