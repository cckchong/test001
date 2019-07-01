/*****************************************************
Controller for Editing Announcement Article

1. The reason of having this controller is to build an the inline visualforce page to render a CKEditor for the announcement editing

******************************************************/
public without sharing class ACGArticleEditCtrl {
    
    public String getUrlToAnnouncement() {
        // First let's just get the Detail Page's unique name
        if(objPC == null || objPC.Distribution_Target__c == null) {
            return '';   
        }
        
        String[] distTargList = objPC.Distribution_Target__c.split(';');
        
        Map<String, String> uniqueNameToDistTarget = new Map<String, String>();
        
        String url = '';
        
        if(distTargList != null && !distTargList.isEmpty() && distTargList[0] != null) {

            for(String distTarg : distTargList) {
                String uniqueName = 'MainPage_General_' + objPC.Distribution_Level__c + '_' + distTarg;
                uniqueNameToDistTarget.put(uniqueName, distTarg);
                
                //url = url + uniqueName + ' | ';
            }
            
        } else {
            throw new TalException(Label.General_Exception);
        }
        
        List<Portal_Content__c> childUniquePageName = 
            [
                Select Child_Unique_Page_Name__c, Unique_Page_Name__c
                From Portal_Content__c
                Where Unique_Page_Name__c IN :uniqueNameToDistTarget.keySet()
                And Content_Type__c = 'Rich Text' 
            ];
        
        /* // Only for debugging
        url = url + '\n\n';
        for(Portal_Content__c pc : childUniquePageName) {
            url = url + pc.Unique_Page_Name__c + ' | ';
        }
        
        return url;
        */
        
        if(childUniquePageName != null && !childUniquePageName.isEmpty()) {
            String uniqueName = childUniquePageName[0].Child_Unique_Page_Name__c;
            String distTarget = uniqueNameToDistTarget.get(childUniquePageName[0].Unique_Page_Name__c);

            List<Portal_Content__c> template = 
                [
                    SELECT Id, Template_ID__c, Template_ID__r.Template_Name__c, Unique_Page_Name__c 
                    FROM Portal_Content__c 
                    WHERE RecordType.DeveloperName = 'Settings' 
                    AND Unique_Page_Name__c = :uniqueName
                    limit 1
                ];
            
            if(template != null && !template.isEmpty()){            
                url = '/apex/' + 
                        template.get(0).Template_ID__r.Template_Name__c + 
                        '?uniquePageName=' + 
                        template.get(0).Unique_Page_Name__c +
                        '&Id=' + objPC.Id +
                        '&title=Announcements' +
                        '&ContentCategory=' + objPC.Content_Category__c +
                        '&DistLevel=' + objPC.Distribution_Level__c +
                        '&DistTarget=' + distTarget +
                        '&' + Label.ConnecTalTab;
            }
        }

        return url;
    }
    
    public Portal_Content__c objPC {get;set;} 
    public String strLanguage {get;set;}    
    public String strErrorMessage {get;set;}
    public Boolean bEdit {get;set;}    
    public Boolean bCreate {get;set;}    
    public Boolean bClone {get;set;}    
    public Boolean bShouldRedirect {public get; private set;}    
    public Boolean bCanDelete {get;set;}    
    public String redirectUrl {public get; private set;}    
    public String chatterGroupName{get;set;}    
    public Boolean bNoMatch {get;set;}    
    public String strEmailResult {get;set;}      
    public Set<String> usrAdminRegions {get;set;}    
    public Boolean bIsBlog {get{
        return selectedArticleType == 'Blog';
    }set;}
    List<CollaborationGroup> chatterGroups = new List<CollaborationGroup>();    
    Set<Id> chatterGroupIds = new Set<Id>();
    User usr = new User();   
    String strRecordTypeId ='';    
    Map<String, ACG_Hierarchy__c> mapACG = new Map<String, ACG_Hierarchy__c>();
    String keyPrefix;
    
    // File Upload
    public transient Document uploadedDocument {get;set;}
    public transient Blob documentContent {get;set;}
    public transient String documentName {get;set;}
    
    //add by DTT
    public transient String documentName1 {get;set;}
    public transient String documentName2 {get;set;}
    public transient String documentName3 {get;set;}
    public transient String documentName4 {get;set;}
    public transient Blob documentContent1 {get;set;}
    public transient Blob documentContent2 {get;set;}
    public transient Blob documentContent3 {get;set;}
    public transient Blob documentContent4 {get;set;}
    
    public ACGArticleEditCtrl (ApexPages.StandardController stdController) {
        List<ACG_Hierarchy__c> labels = 
            [
                SELECT Id, Name, Site__c, Content_Category__c, Division__c, Group__c, Type__c, Icon_Link__c, Label__c, Order__c, Location__c, Level__c,
                isLabelSetting__c, isDistributionSetting__c, isHierarchySetting__c, isPageListSetting__c, isDepartmentSetting__c
                FROM ACG_Hierarchy__c 
                WHERE isLabelSetting__c = true
            ];
        for(ACG_Hierarchy__c label:labels) {
            mapACG.put(label.Name, label);
        }
        if(objPC == null) {
            List<Portal_Content__c> listPC = 
                [
                    SELECT Id, Name, Unique_Page_Name__c, Child_Unique_Page_Name__c, Child_List_Unique_Page_Name__c,
                    LastModifiedDate, LastModifiedById, LastModifiedBy.Name,
                    CreatedDate, CreatedById, CreatedBy.Name,
                    OwnerId, Owner.Name, Owner.Email, Owner.Id,
                    RecordType.DeveloperName, RecordType.Name,
                    Publish_Datetime__c, Is_Article_Priority_Active__c,
                    //Distribution Section
                    Article_Type__c, Content_Category__c, Distribution_Level__c, Distribution_Target__c, Status__c, Sticky_Scale__c, Expiry_Date__c, Article_Priority__c,
                    //Content Fields Section
                    Language__c, Title__c, Summary__c, Contents__c, Revised__c ,
                    Title_en__c, Title_zhhk__c, Title_zhcn__c, Title_th__c, Title_vi__c, Title_id__c,
                    Summary_en__c, Summary_zhhk__c, Summary_zhcn__c, Summary_th__c, Summary_vi__c, Summary_id__c,
                    Contents_en__c ,Contents_zhhk__c, Contents_zhcn__c, Contents_th__c, Contents_vi__c, Contents_id__c,
                    Revised_en__c, Revised_zhhk__c, Revised_zhcn__c, Revised_th__c, Revised_vi__c, Revised_id__c,       
                    //Tech Custom Fields
                    Tech_Id__c, Tech_LastUpdateDateTime__c, Tech_LastUpdateDate__c, Tech_CreatedDate__c, LangAlreadySendNotification__c,
                    Attached_File_ID__c, Attached_File_Name__c,
                    Attached_File_ID1__c, Attached_File_Name1__c, //add by DTT
                    Attached_File_ID2__c, Attached_File_Name2__c, //add by DTT
                    Attached_File_ID3__c, Attached_File_Name3__c, //add by DTT
                    Attached_File_ID4__c, Attached_File_Name4__c //add by DTT
                    FROM Portal_Content__c 
                    WHERE Id = :ApexPages.currentPage().getParameters().get('Id') 
                    limit 1
                ];
           if(!listPC.isEmpty()) {
                objPC = listPC.get(0);
           } else {
                objPC = new Portal_Content__c();
           }             
        }
        bEdit = ApexPages.currentPage().getParameters().get('Edit') == null ? false : Boolean.ValueOf(ApexPages.currentPage().getParameters().get('Edit'));
        bCreate = ApexPages.currentPage().getParameters().get('Create') == null ? false : Boolean.ValueOf(ApexPages.currentPage().getParameters().get('Create'));
        bClone = ApexPages.currentPage().getParameters().get('Clone') == null ? false : Boolean.ValueOf(ApexPages.currentPage().getParameters().get('Clone'));
        strRecordTypeId = ApexPages.currentPage().getParameters().get('RecordTypeId') == null ? '': String.ValueOf(ApexPages.currentPage().getParameters().get('RecordTypeId'));
        bEdit = bEdit || bCreate || bClone;
        
        Schema.DescribeSObjectResult sobj = Portal_Content__c.sObjectType.getDescribe();
        bCanDelete = sobj.isDeletable();
        
        //Init Language Field
        if(bCreate) {
            objPC.Language__c = 'en';
            objPC.RecordTypeId = strRecordTypeId;
            objPC.Sticky_Scale__c = '5';
            objPC.Expiry_Date__c = date.today()+ AcgUtil.getDefaultStickyExpiryDays();
        }
        strLanguage = objPC.Language__c;
        strErrorMessage = '';      
        bShouldRedirect = false;
        redirectUrl='';
        
        //Get Current User Info
        usr = SystemUtil.getCurrentUserInfo();
        
        //Init Picklist Values        
        if(objPC.Article_Type__c != null) {
            selectedArticleType = objPC.Article_Type__c;
        }
        if(objPC.Content_Category__c != null) {
            selectedContentCategory = objPC.Content_Category__c;
        }
        if(objPC.Distribution_Level__c != null) {
            selectedDistLevel = objPC.Distribution_Level__c;
        }
        if(selectedDistTarget==null) {
            selectedDistTarget = new List<SelectOption>();
        }
        if(objPC.Distribution_Target__c != null && objPC.Distribution_Level__c != null && objPC.Content_Category__c != null) {
            Set<SelectOption> tmp = new Set<SelectOption>();
            for(String s: objPC.Distribution_Target__c.split(';')) {
                if(mapACG.containsKey(s)) {
                    tmp.add(new SelectOption(s, mapACG.get(s).Label__c));
                }
            }
            selectedDistTarget = new List<SelectOption>(tmp);            
        }        
        refreshAllDistribution();        
        //Get keyPrefix
        Schema.DescribeSObjectResult r = Portal_Content__c.sObjectType.getDescribe();
        keyPrefix = r.getKeyPrefix();
        
        uploadedDocument = new Document();
    }
    /**
        Picklist Value Security
    */
    public List<SelectOption> availableArticleType {get;set;} {availableArticleType = new List<SelectOption>();}
    public List<SelectOption> availableContentCategory {get;set;} {availableContentCategory = new List<SelectOption>();}
    public List<SelectOption> availableDistLevel {get;set;} {availableDistLevel = new List<SelectOption>();} 
    public List<SelectOption> availableDistTarget {get;set;} {availableDistTarget = new List<SelectOption>();}
    
    public String selectedArticleType {get;set;}    
    public String selectedContentCategory {get;set;}    
    public String selectedDistLevel {get;set;}    
    public List<SelectOption> selectedDistTarget {get;set;}
    Boolean bChangeCategory = false;
    public PageReference refreshAllDistribution() {
        refreshAvailableArticleType();
        refreshAvailableContentCategory();
        refreshAvailableDistLevel();
        refreshAvailableDistTarget();
        return null;
    }
    
    public PageReference refreshAllDistributionOnChangeConCat() {
        selectedDistTarget = new List<SelectOption>();
        refreshAvailableContentCategory();
        refreshAvailableDistLevel();
        refreshAvailableDistTarget();
        return null;
    }
    
    public PageReference refreshAllDistributionOnChangeArticleType() {
        selectedDistTarget = new List<SelectOption>();
        selectedContentCategory = '';
        selectedDistLevel = '';
        refreshAvailableContentCategory();
        refreshAvailableDistLevel();
        refreshAvailableDistTarget();   
        return null;
    }
    
    public void refreshAvailableArticleType() {
        Set<String> tmp = new Set<String>();
        if(usr.Administrative_Category__c != null) {
            for(String s: usr.Administrative_Category__c.split(';')) {
                String str = s.contains('Blog')?'Blog': 'Announcement';
                if(!tmp.contains(str)) {
                    tmp.add(str);
                }
            }
        }
        List<SelectOption> result = new List<SelectOption>();
        for(String s: tmp) {
            result.add(new SelectOption(s, s));
        }
        //Default Value Section
        if(selectedArticleType == null) {
            if(result.size()==1) {
                selectedArticleType = result.get(0).getValue();
            } else if (result.size()>1) {
                selectedArticleType = 'Announcement';
            }
        }
        availableArticleType = result;
    }
    
    public void refreshAvailableContentCategory() {
        List<SelectOption> result = new List<SelectOption>();
        Set<String> tmpSet = new Set<String>();
        Boolean isContainsGeneral = false;   
        List<ACG_Hierarchy__c> acgs = new List<ACG_Hierarchy__c>();
        if(usr.Administrative_Category__c != null) {
            acgs =
                [
                    SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Location__c, Label__c
                    FROM ACG_Hierarchy__c 
                    WHERE Name IN :usr.Administrative_Category__c.split(';')
                    And Type__c = 'Label_ContentCategory'
                    order by Order__c
                ];
        }
        for(ACG_Hierarchy__c acg: acgs) {           
            if(!tmpSet.contains(acg.Name) && ((acg.Name.contains('Blog') && bIsBlog) || (!acg.Name.contains('Blog') && !bIsBlog)) ) {
                tmpSet.add(acg.Name);
                result.add(new SelectOption(acg.Name, acg.Label__c));
            }
            if(acg.Name == 'General') {
                isContainsGeneral = true;
            }
        }
        if(result.size() > 1) {
            result.add(0, new SelectOption('--None--','--None--'));
        } else if (result.size() == 1){
            selectedContentCategory = acgs.get(0).Name;          
        }
        availableContentCategory = result;
        //Default Value Section
        if((selectedContentCategory == '' || selectedContentCategory == null) && isContainsGeneral) {
            selectedContentCategory = 'General';
        }
        refreshAvailableDistLevel();
    }
        
    private void refreshAvailableDistLevel() {
        if(!bIsBlog) {
            List<SelectOption> result = new List<SelectOption>();
            Set<String> tmpSet = new Set<String>();
            List<ACG_Hierarchy__c> acgs = new List<ACG_Hierarchy__c>();
            if(usr.Administrative_Target__c != null) {
                acgs = 
                    [
                        SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Location__c
                        FROM ACG_Hierarchy__c 
                        WHERE Content_Category__c = :selectedContentCategory
                        AND (
                                (Group__c != null AND Group__c IN:usr.Administrative_Target__c.split(';')) OR
                                (Division__c != null AND Division__c IN:usr.Administrative_Target__c.split(';')) OR
                                (Site__c != null AND Site__c IN:usr.Administrative_Target__c.split(';'))
                            )
                        AND isDistributionSetting__c = true
                        //And Type__c != null
                        order by Order__c
                    ];
            }    
            for(ACG_Hierarchy__c acg: acgs) {
                if(mapACG.containsKey(acg.Type__c)) {
                    if(!tmpSet.contains(acg.Type__c)) {
                        tmpSet.add(acg.Type__c);
                        if(acg.Type__c == 'Group') {
                            if(result.size() > 0) {
                                result.add(0, new SelectOption(acg.Type__c, mapACG.get(acg.Type__c).Label__c));
                            } else {
                                result.add(new SelectOption(acg.Type__c, mapACG.get(acg.Type__c).Label__c));
                            }
                        } else {
                            result.add(new SelectOption(acg.Type__c, mapACG.get(acg.Type__c).Label__c));
                        }
                    }
                }            
            }
            if(result.size() > 1) {
                result.add(0, new SelectOption('--None--','--None--'));           
            } else 
            if (result.size() == 1){
                selectedDistLevel = acgs.get(0).Type__c;
            }
            //Default Value Section
            if (result.size() > 1 && (selectedDistLevel == null || selectedDistLevel == '') ){
                if(tmpSet.contains('Site')) {
                    selectedDistLevel = 'Site';
                }
                bChangeCategory = false;
            }     
            availableDistLevel = result;
            refreshAvailableDistTarget();
        } else {
            availableDistLevel = new List<SelectOption>();
        }
    }
    
    private void refreshAvailableDistTarget(){
        if(!bIsBlog) {
            List<SelectOption> result = new List<SelectOption>();
            Set<String> tmpSet = new Set<String>();
            Set<SelectOption> selectOptions = new Set<SelectOption>();
            List<ACG_Hierarchy__c> acgs = new List<ACG_Hierarchy__c>();
            if(usr.Administrative_Target__c != null) {
                acgs = ACGUtil.getACGList(selectedContentCategory, selectedDistLevel, usr.Administrative_Target__c);
                system.debug('### acgs ' + acgs.size());
            }
            for(ACG_Hierarchy__c acg : acgs) {
                if(acg.Type__c == 'Group') {
                    if(!tmpSet.contains(acg.Group__c)) {
                        tmpSet.add(acg.Group__c);
                        result.add(new SelectOption(acg.Group__c, mapACG.get(acg.Group__c).Label__c));
                    }
                } else if(acg.Type__c == 'Division') {
                    if(!tmpSet.contains(acg.Division__c)) {
                        tmpSet.add(acg.Division__c);
                        result.add(new SelectOption(acg.Division__c, mapACG.get(acg.Division__c).Label__c));
                    }
                } else if(acg.Type__c == 'Site') {
                    if(!tmpSet.contains(acg.Site__c)) {
                        tmpSet.add(acg.Site__c);
                        result.add(new SelectOption(acg.Site__c, mapACG.get(acg.Site__c).Label__c));
                    }
                }  
            }
            if(selectedDistTarget == null || selectedDistTarget.size()==0) {
                //Default Value Section             
                if (result.size() == 1){
                    for(ACG_Hierarchy__c acg : acgs) {
                        if(acg.Type__c == 'Group') {
                            if(mapACG.containsKey(acg.Group__c)) {
                                selectOptions.add(new SelectOption(acg.Group__c, mapACG.get(acg.Group__c).Label__c));
                            }
                        }
                        else if(acg.Type__c == 'Division') {
                            if(mapACG.containsKey(acg.Division__c)) {
                                selectOptions.add(new SelectOption(acg.Division__c, mapACG.get(acg.Division__c).Label__c));
                            }
                        }
                        else if(acg.Type__c == 'Site') {
                            if(mapACG.containsKey(acg.Site__c)) {
                                selectOptions.add(new SelectOption(acg.Site__c, mapACG.get(acg.Site__c).Label__c));
                            }
                        }
                    }
                }
                selectedDistTarget = new List<SelectOption>(selectOptions);    
            }
            Set<SelectOption> tmpSetSelected = new Set<SelectOption>(selectedDistTarget);
            List<SelectOption> resultAva = new List<SelectOption>();
            for(SelectOption so :result) {
                if(!tmpSetSelected.contains(so)) {
                    resultAva.add(so);
                }
            }
            availableDistTarget = resultAva;
        } else {
            availableDistTarget = new List<SelectOption>();
        }
    }
    
    /**
        Onchange Action Section 
    */
    public PageReference switchLanguageInEditMode() {
        strErrorMessage = '';
        strLanguage = objPC.Language__c;
        bEdit = true;
        return null;
    }
    
    public void switchLanguageInReadMode() {       
        strLanguage = objPC.Language__c;
    }
    
    /** 
        Button Action Section
    */    
    private void bindArticleType() {
        objPC.Article_Type__c = selectedArticleType;
    }
    private void bindContentCategory() {
        objPC.Content_Category__c = selectedContentCategory;
    }
    private void bindDistLevel() {
        objPC.Distribution_Level__c = selectedDistLevel;
    }    
    private void bindDistTarget() {
        String tmpDistTarget = '';
        if(selectedDistTarget.size()>0) {
            for (SelectOption so : selectedDistTarget) {
                tmpDistTarget += so.getValue() +';';
            }           
        }
        objPC.Distribution_Target__c = tmpDistTarget;
    }
    private void bindArticleContent() {
        if(objPC.LangAlreadySendNotification__c != null && objPC.LangAlreadySendNotification__c != '') {
            if(objPC.LangAlreadySendNotification__c.contains(objPC.Language__c)) {
                objPC.LangAlreadySendNotification__c = objPC.LangAlreadySendNotification__c.replace(objPC.Language__c, '');
            }   
        }
    }
    
    private void bindAllValues() {
        //Distribution Section
        bindArticleType();
        bindContentCategory();
        bindDistLevel();
        bindDistTarget();    
        //Content Section
        bindArticleContent();        
    }
    
    private boolean isAllFilled() {
        boolean isFilled = true;
        if(objPC.Content_Category__c == null || selectedContentCategory == null || objPC.Content_Category__c == '--None--' || selectedContentCategory == '--None--') {
            strErrorMessage = Label.DefineContentCategoryErrorMessage;
            isFilled = false;
        } else if((objPC.Distribution_Level__c == null || selectedDistLevel == null || objPC.Distribution_Level__c == '--None--' || selectedDistLevel == '--None--') && !bIsBlog) {
            strErrorMessage = Label.DefineDistLevelErrorMessage;
            isFilled = false;
        } else if((objPC.Distribution_Target__c == null || selectedDistTarget == null || objPC.Distribution_Target__c == '' || selectedDistTarget.size() == 0) && !bIsBlog) {
            strErrorMessage = Label.DefineDistTargetErrorMessage;
            isFilled = false;
        } else if(objPC.title_en__c == null || objPC.summary_en__c == null || objPC.title_en__c == '' || objPC.summary_en__c == '') {
            strErrorMessage = Label.PleaseEnterEnglishAnnouncementError;
            isFilled = false;
        }
        return isFilled;
    }    
    
    public void getChatterGroupIds() {   
        chatterGroups = new List<CollaborationGroup>();
        chatterGroupIds = new Set<Id>();
        if(objPC.Content_Category__c != null ) {
            if(objPC.Content_Category__c.contains('Blog')) {
                Set<String> emptySet = new Set<String>();
                Map<String, Id> tmpBlog = ACGUtil.getAssociatedChatterGroup(emptySet, objPC.Content_Category__c, false, false, true);   
                Boolean b1 = chatterGroupIds.addAll(tmpBlog.values());
            } if(objPC.Content_Category__c.contains('Office')) { //AN: Added this block 19/03/2015. See Tracker Defect DEF-000472
                Set<String> emptySet = new Set<String>();
                Map<String, Id> tmpBlog = ACGUtil.getAssociatedChatterGroup(emptySet, objPC.Content_Category__c, false, false, true);   
                Boolean b1 = chatterGroupIds.addAll(tmpBlog.values());
                
                if(objPC.Distribution_Target__c != null) {
                    Set<String> targets = new Set<String>();
                    targets.addAll(objPC.Distribution_Target__c.split(';'));
                    
                    emptySet = new Set<String>();
                    tmpBlog = ACGUtil.getAssociatedChatterGroup(targets, objPC.Content_Category__c, false, true, false);    
                    Boolean b3 = chatterGroupIds.addAll(tmpBlog.values());
                }
                
            } else {
                if(objPC.Distribution_Target__c != null) {
                    Set<String> targets = new Set<String>();
                    targets.addAll(objPC.Distribution_Target__c.split(';'));
                    if(objPC.Content_Category__c == 'General') {
                        Map<String, Id> tmpBlog = ACGUtil.getAssociatedChatterGroup(targets, objPC.Content_Category__c, true, false, false);    
                        Boolean b2 = chatterGroupIds.addAll(tmpBlog.values());
                    } else {
                        Set<String> emptySet = new Set<String>();
                        Map<String, Id> tmpBlog = ACGUtil.getAssociatedChatterGroup(targets, objPC.Content_Category__c, false, true, false);    
                        Boolean b3 = chatterGroupIds.addAll(tmpBlog.values());
                    }
                }
            }
        }       
        chatterGroups = 
            [
                SELECT c.Name, c.Id 
                FROM CollaborationGroup c 
                WHERE Id in :chatterGroupIds
            ];
        system.debug('@@@ chatterGroups ' + chatterGroups);
        system.debug('@@@ chatterGroupIds ' + chatterGroupIds);

    }

    public PageReference edit() {           
        bEdit = true;
        return null;
    }
    
    public void deleteRecord() {           
        bShouldRedirect = true;
        redirectUrl = '/'+keyPrefix+'/o';
        if(objPC.id != null) {
            try {
                delete objPC;
            } catch (exception ex) {/*die silently*/}
        }
    }
    
    public PageReference cloneRecord() {
        //Record being cloned
        Portal_Content__c newArticle = objPC;        
        newArticle.Id = null;
        newArticle.Status__c = 'Draft';
        newArticle.Revised_en__c = false;
        newArticle.Revised_id__c = false;
        newArticle.Revised_th__c = false;
        newArticle.Revised_vi__c = false;
        newArticle.Revised_zhcn__c = false;
        newArticle.Revised_zhhk__c = false;
        newArticle.Revised__c = false;
        newArticle.Tech_CreatedDate__c = null;
        newArticle.Tech_LastUpdateDate__c = null;
        newArticle.Tech_Id__c = null;
        newArticle.Tech_CreatedBy__c = null;
        insert newArticle;
        return new PageReference('/'+newArticle.Id + '?edit=true&clone=true');
    }    
    
    public PageReference shareRecord() {   
        PageReference PageRef = new PageReference('/p/share/CustomObjectSharingDetail?parentId=' + objPC.Id);
        return PageRef;
    }
    
    public PageReference previewArticle() {
        if(objPC.Status__c == 'Draft') {           
            objPC.Status__c = 'Reviewed';
            update objPC;
        }
        return null;
    }
    
    /**
     * @description publish the article to the relevant ACG Pages
     */
    public PageReference publishArticle() {       
        objPC.Status__c = 'Published';
        objPC.Publish_Datetime__c = datetime.now();
        strErrorMessage = SystemUtil.DMLUpdate(objPC);
        List<ACG_Content_Post__c> acgContentPosts = new List<ACG_Content_Post__c>();
        
        //Retrive corresponding Chatter Group
        getChatterGroupIds();
        List<FeedItem> feedItems = new List<FeedItem>();
        Set<String> existingFeeds = new Set<String>();
        for(FeedItem fi: 
            [
                SELECT Id, LinkURL, Type, parentId 
                FROM FeedItem 
                WHERE parentId IN :chatterGroups
                AND Type = 'LinkPost'
            ]){
            existingFeeds.add(fi.parentId + '-' + fi.LinkURL);
        }
        
        String urlToAnnouncement = getUrlToAnnouncement();
        
        // An ACG Announcement can show up in multiple pages, this is where we grab the Groups
        for(CollaborationGroup chatterGroup: chatterGroups) {
            
            // Construct the Chatter Post for each group
            String tmp = URL.getSalesforceBaseUrl().toExternalForm() + urlToAnnouncement;
            if(!existingFeeds.contains(chatterGroup.Id + '-' + tmp) || 
                objPC.Revised_en__c || objPC.Revised_zhhk__c || objPC.Revised_zhcn__c || 
                objPC.Revised_th__c || objPC.Revised_vi__c || objPC.Revised_id__c) {
                    
                FeedItem f = new FeedItem();
                f.ParentId = chatterGroup.Id;
                f.Body = 'Title: ' + objPC.Title_en__c + ' \n\n '+ objPC.Summary_en__c;
                f.type = 'LinkPost';
                f.Title = Label.ACGPublishKeyword + '[Read More]';
                f.LinkURL = tmp;
                f.CreatedById = UserInfo.getUserID();
                feedItems.add(f);
            }
        }
        
        // Create a FeedItem for the post itself
        // We only need one of these
        if(!feedItems.isEmpty()) { 
            
            // Check if we need to create the Chatter Post Comments post
            List<FeedItem> fiList = [SELECT Id FROM FeedItem WHERE ParentId = :objPC.Id AND CreatedById = :Label.ServiceAccountUserId];
            if(fiList == null || fiList.isEmpty()) {
                FeedItem f = new FeedItem();
                f.ParentId = objPC.Id;
                f.Body = 'Chatter Post Comments';
                f.type = 'TextPost';
                f.CreatedById = Label.ServiceAccountUserId; // Use a Service Account, because we don't want this post showing up on people's feeds
    
                insert f;
                objPC.Tech_Article_Feed_Item_Id__c = f.Id;
                acgContentPosts.add(new ACG_Content_Post__c(Acg_Content__c = objPC.Id , Post_Id__c = f.Id));
            } else {
                objPC.Tech_Article_Feed_Item_Id__c = fiList[0].Id;
                acgContentPosts.add(new ACG_Content_Post__c(Acg_Content__c = objPC.Id , Post_Id__c = fiList[0].Id));
            }
            
            // Handle the posts
            insert feedItems;
            
            for(FeedItem fi : feedItems) {
                acgContentPosts.add(new ACG_Content_Post__c(Acg_Content__c = objPC.Id , Post_Id__c = fi.Id));
            }
            
            if(!acgContentPosts.isEmpty()) {
                insert acgContentPosts;
            }
            
            objPC.Tech_Feed_Item_Id__c = feedItems[0].Id; //soon to be deprecated
        }
        
        update objPC;
            
        return null;
    }
    
    public PageReference UnpublishArticle() {       
        objPC.Status__c = 'Draft';
        objPC.Publish_Datetime__c = null;
        strErrorMessage = SystemUtil.DMLUpdate(objPC);
        
        // Clean up the Chatter Posts
        List<ACG_Content_Post__c> acpList = new List<ACG_Content_Post__c>();
        List<String> fiListIds = new List<String>();
        for(ACG_Content_Post__c acp : [SELECT Id, Post_Id__c FROM ACG_Content_Post__c WHERE Acg_Content__c =: objPC.Id]) {
            acpList.add(acp);
            fiListIds.add(acp.Post_Id__c);
        }
        
        List<FeedItem> fiList = [SELECT Id FROM FeedItem WHERE Id IN: fiListIds AND CreatedById = :UserInfo.getUserId()];
        delete acpList;
        delete fiList;
        
        return null;
    }
    
    public PageReference sendNotificationEmail() {
        strEmailResult = '';
        Portal_Content__c announcement = new Portal_Content__c();   
        String lang = objPC.LangAlreadySendNotification__c;
        Set<String> setSentLang = new Set<String>();
        if(lang != null && lang !='')       {
            List<String> sentLang = lang.split(';');
            for(String str: sentLang) {
                setSentLang.add(str.trim());
            }
        }
        if(setSentLang.contains(objPC.Language__c)) {
            strEmailResult = 'You have sent ' + (SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Language__c').containsKey(objPC.Language__c)? SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Language__c').get(objPC.Language__c):objPC.Language__c) + ' Notification before!';
        } else {
            announcement = ACGUtil.getUserPreferLanguageArticle(objPC, objPC.Language__c);            
            EmailTemplate et = 
                [
                    SELECT Id, HtmlValue, Subject 
                    FROM EmailTemplate
                    WHERE DeveloperName= :Label.ACGEmailNotificationTemplate
                ];          
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();     
            //Get correpsonding mailing list / email address
            getChatterGroupIds();
            List<CollaborationGroupMember> groupMembers = 
                [
                    SELECT c.Member.Email, c.Member.Name, c.MemberId, CollaborationGroup.Name
                    FROM CollaborationGroupMember c
                    WHERE c.CollaborationGroupId In :chatterGroupIds
                ];
            List<String> ccEmails = new List<String>();
            Set<Id> tmpSent = new Set<Id>();
            Integer i = 1;
            
            String urlToAnnouncement = getUrlToAnnouncement();
            
            for(CollaborationGroupMember gm: groupMembers) {
                if(!tmpSent.contains(gm.MemberId)) {
                    // Construct the list of emails we want to send         
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setTargetObjectId(gm.MemberId);                
                    msg.setSubject(Label.ACGImmedidateEmailSubject + ' ' + announcement.Title__c);          
                    msg.setHTMLBody(et.HtmlValue);         
                    msg.setCcAddresses(ccEmails);
                    msg.setHTMLBody(msg.getHTMLBody().replace('Put Your Subject Here', '' + announcement.Title__c));
                    Datetime dt = datetime.now();
                    if(announcement.Tech_LastUpdateDateTime__c != null) {
                        dt = announcement.Tech_LastUpdateDateTime__c;
                    } else if (objPC.LastModifiedDate != null){
                        dt = objPC.LastModifiedDate;
                    }
                    msg.setHTMLBody(msg.getHTMLBody().replace('Put Your Date Here', '' + dt.format('EEEE, MMMM dd, YYYY')));
                    msg.setHTMLBody(msg.getHTMLBody().replace('Put Your Summary Here', '' + announcement.Summary__c));
                    msg.setHTMLBody(msg.getHTMLBody().replace('https://', URL.getSalesforceBaseUrl().toExternalForm() + urlToAnnouncement));//'/apex/ACGPreviewVFPage?Id=' + objPC.Id + '&size=12&type=richtext&preview=true'));                    
                    msg.setHTMLBody(msg.getHTMLBody().replace('Put Your Record Link Here', URL.getSalesforceBaseUrl().toExternalForm() + urlToAnnouncement));//'/apex/ACGPreviewVFPage?Id=' + objPC.Id + '&size=12&type=richtext&preview=true'));
                    msg.setHTMLBody(msg.getHTMLBody().replace('Put Your Chatter Group Name Here', gm.CollaborationGroup.Name ));
                    msg.setHTMLBody(msg.getHTMLBody().replace(']]>', ''));
                    msg.setHTMLBody(msg.getHTMLBody().replace('<![CDATA[', ''));
                    msg.SaveAsActivity = false;
                    lstMsgs.add(msg);
                    tmpSent.add(gm.MemberId);
                    i++;
                }
            }     
            Messaging.sendEmail(lstMsgs);
            strEmailResult = (SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Language__c').containsKey(objPC.Language__c)? SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Language__c').get(objPC.Language__c):objPC.Language__c) + ' Notification sent successfully!';
            objPC.LangAlreadySendNotification__c += ';'+objPC.Language__c;
        }        
        strErrorMessage = SystemUtil.DMLUpdate(objPC);
        return null;        
    }
    
    //change by DTT
    public void save() {
        bindAllValues();
        strErrorMessage = '';
        List<Portal_Content__c> list2Update = new List<Portal_Content__c>();
        list2Update.add(objPC);
        if(isAllFilled()) {
            try {
                if((documentContent1 == null && documentName1 == null && objPC.Attached_File_ID1__c==null) &&((documentContent2 != null && documentName2 != null)||(documentContent3 != null && documentName3 != null)||(documentContent4 != null && documentName4 != null)||(documentContent != null && documentName != null)))
                    {    
                         strErrorMessage =Label.ACGFirstFileMissing;
                         return;
                    }
                if(documentContent1 != null && documentName1 != null) { 
                    ContentVersion cv1 = saveTheFile(documentContent1,documentName1);
                    list2Update[0].Attached_File_Name1__c = cv1.Title;
                    list2Update[0].Attached_File_ID1__c = cv1.Id;
                }
                if(documentContent2 != null && documentName2 != null) { 
                    ContentVersion cv2 = saveTheFile(documentContent2,documentName2);
                    list2Update[0].Attached_File_Name2__c = cv2.Title;
                    list2Update[0].Attached_File_ID2__c = cv2.Id;
                }
                if(documentContent3 != null && documentName3 != null) { 
                    ContentVersion cv3 = saveTheFile(documentContent3,documentName3);
                    list2Update[0].Attached_File_Name3__c = cv3.Title;
                    list2Update[0].Attached_File_ID3__c = cv3.Id;
                }
                if(documentContent4 != null && documentName4 != null) { 
                    ContentVersion cv4 = saveTheFile(documentContent4,documentName4);
                    list2Update[0].Attached_File_Name4__c = cv4.Title;
                    list2Update[0].Attached_File_ID4__c = cv4.Id;
                }
                if(documentContent != null && documentName != null) { 
                    ContentVersion cv = saveTheFile(documentContent,documentName);
                    list2Update[0].Attached_File_Name__c = cv.Title;
                    list2Update[0].Attached_File_ID__c = cv.Id;
                } 
              //  system.assert(false,list2Update[0].Attached_File_Name1__c);
                // if(Test.isRunningTest())
                //  {
                //      return;
                //  }
                 update (list2Update);
                 bEdit = false;
                
                
                
            } catch (DMLException e) {   
                strErrorMessage = e.getDmlMessage(0);
            }
        }
    }
    
    //add by DTT
    private ContentVersion saveTheFile(Blob documentContents,String documentNames) {
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = documentNames;
        cv.VersionData = documentContents;
        cv.Title = documentNames;
        cv.Origin = 'H';
        insert cv;
        List<ContentVersion> cvRequeried = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];

        // Share with Whole Company
        //try {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.contentdocumentid = cvRequeried[0].ContentDocumentId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId = UserInfo.getOrganizationId();
            insert cdl;
        //} catch (Exception e) {}
        
        return cv;
    }
    
    private ContentVersion saveFile() {
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = documentName;
        cv.VersionData = documentContent;
        cv.Title = documentName;
        cv.Origin = 'H';
        insert cv;
        List<ContentVersion> cvRequeried = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];

        // Share with Whole Company
        //try {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.contentdocumentid = cvRequeried[0].ContentDocumentId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId = UserInfo.getOrganizationId();
            insert cdl;
        //} catch (Exception e) {}
        
        return cv;
    }
    
    //change by DTT
    public void saveCreate() {
        bindAllValues();
        strErrorMessage  ='';
        if(bCreate) {   
            if(isAllFilled()) {               
                try {
                    if((documentContent1 == null && documentName1 == null) &&((documentContent2 != null && documentName2 != null)||(documentContent3 != null && documentName3 != null)||(documentContent4 != null && documentName4 != null)||(documentContent != null && documentName != null)))
                    {    
                         strErrorMessage =Label.ACGFirstFileMissing;
                         return;
                    }
                    if(documentContent1 != null && documentName1 != null) { 
                        ContentVersion cv1 = saveTheFile(documentContent1,documentName1);
                        objPC.Attached_File_Name1__c = cv1.Title;
                        objPC.Attached_File_ID1__c = cv1.Id;
                    }
                    if(documentContent2 != null && documentName2 != null) { 
                        ContentVersion cv2 = saveTheFile(documentContent2,documentName2);
                        objPC.Attached_File_Name2__c = cv2.Title;
                        objPC.Attached_File_ID2__c = cv2.Id;
                    }
                    if(documentContent3 != null && documentName3 != null) { 
                        ContentVersion cv3 = saveTheFile(documentContent3,documentName3);
                        objPC.Attached_File_Name3__c = cv3.Title;
                        objPC.Attached_File_ID3__c = cv3.Id;
                    }
                    if(documentContent4 != null && documentName4 != null) { 
                        ContentVersion cv4 = saveTheFile(documentContent4,documentName4);
                        objPC.Attached_File_Name4__c = cv4.Title;
                        objPC.Attached_File_ID4__c = cv4.Id;
                    }
                    if(documentContent != null && documentName != null) {
                        ContentVersion cv = saveTheFile(documentContent,documentName);
                        objPC.Attached_File_Name__c = cv.Title;
                        objPC.Attached_File_ID__c = cv.Id;
                    }
                  
                    insert objPC;
                    
                    bEdit = false;
                    bShouldRedirect = true;
                    redirectUrl = '/' + objPC.Id;
                } catch (DMLException e) {   
                    strErrorMessage = e.getDmlMessage(0);
                }
            }
        }   
    }
    
    public PageReference cancel() {   
        strErrorMessage= '';
        if(bCreate) {
            bShouldRedirect = true;
            redirectUrl = '/'+keyPrefix+'/o';
            return null;
        } else if(bClone) {
            deleteRecord();
            return null;
        } else {
            bEdit = false;
        }
        
        PageReference pageRef = new PageReference('/apex/ACGArticleEditVFPage?id=' + objPC.Id + '&inline=1&edit=false');
        pageRef.setRedirect(true);
        return pageRef;
    }  

    /**
        Article Content Section
    */    
    public String setEditorLang {get{
        return strLanguage;
    }set;}
    
    //Get Picklist Values in the Languages Field
    public List<String> getLanguages() {
        return SystemUtil.getPicklistValues('Portal_Content__c', 'Language__c');
    }
    
    //Get the API Name of the title field for each language
    public Map<String, String> getTitleLangVar() {
        Map<String, String> mapLang = new Map<String, String>();
        for(String strLang: getLanguages()) {
            mapLang.put(strLang, 'title_' + strLang + '__c');
        }
        return mapLang;
    }
    
    //Get the API Name of the summary field for each language
    public Map<String, String> getSummaryLangVar() {
        Map<String, String> mapLang = new Map<String, String>();
        for(String strLang: getLanguages()) {
            mapLang.put(strLang, 'summary_' + strLang + '__c');
        }
        return mapLang;
    }
    
    //Get the API Name of the contents field for each language
    public Map<String, String> getContentsLangVar() {
        Map<String, String> mapLang = new Map<String, String>();
        for(String strLang: getLanguages()) {
            mapLang.put(strLang, 'contents_' + strLang + '__c');
        }
        return mapLang;
    }
    
    //Get the API Name of the mark as revised field for each language
    public Map<String, String> getRevisedLangVar() {
        Map<String, String> mapLang = new Map<String, String>();
        for(String strLang: getLanguages()) {
            mapLang.put(strLang, 'revised_' + strLang + '__c');
        }
        return mapLang;
    }
    
    public String getLanguageLabel() {
        return (SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Language__c').containsKey(strLanguage)? 
                SystemUtil.getPicklistValues2Label('Portal_Content__c', 'Language__c').get(strLanguage):strLanguage);
    }
    
    /**
     * @description check if the user has Edit rights on this record
     */
    public boolean getCanEditRecord() {
        boolean result = false;
        if(objPC != null && objPC.Id != null) {
            List<UserRecordAccess> uraList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :objPC.Id];
            if(uraList != null && !uraList.isEmpty() && uraList[0].HasEditAccess) {
                result = true;
            }
        }
        return result;
    }
}