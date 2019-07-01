public without sharing class ACGUtil {
    
    public static Map<String, Portal_Content__c> getAssociatedChatterGroup(Set<Id> chatterIds) {
        Map<String, Portal_Content__c> returnMap = new Map<String, Portal_Content__c>();
        List<Portal_Content__c> tmpList = 
            [
                SELECT
                //Page Setting
                Id, Unique_Page_Name__c, Content_Type__c, Fixed_Component__c, Article_Type__c, Article_Thumbnail__c,             
                //Distribution
                Content_Category__c, Distribution_Level__c, Distribution_Target__c,
                //Template
                Template_ID__c, Template_ID__r.Template_Name__c, Template_Unique_Name__c, Template_ID__r.Tech_Total_Component__c, Component_Number__c,
                //Child Page
                Child_List_Unique_Page_Name__c, Child_Unique_Page_Name__c,
                //Chatter
                Chatter_Feed_ID__c, Chatter_Feed_ID_Long__c, Number_of_Slides__c, Slideshow_Topic__c,
                Show_Chatter_File_On_Page__c, Show_Chatter_Group_On_Page__c, Show_Chatter_Photo_On_Page__c,
                //Content Section
                Article_Feed_Title__c, HTML_Selected__c, Video_Selected__c, RSS_Title__c, RSS_Feed_URL__c, Report_Name__c, Report_ID__c
                FROM Portal_Content__c
                WHERE RecordType.DeveloperName = 'Settings' 
                AND Content_Type__c = 'Chatter'
                And Chatter_Feed_ID_Long__c IN :chatterIds
                AND Component_Number__c != null
            ];
        system.debug('### tmpList size ' + tmpList.size());
        //system.debug('### tmpList ' + tmpList);
        for(Portal_Content__c s: tmpList) {
            returnMap.put(s.Chatter_Feed_ID_Long__c, s);            
        }
        system.debug('@@@ returnMap ' + returnMap );
        return returnMap;
    }
    
    public static Map<String, Id> getAssociatedChatterGroup(Set<String> pages, String conCats, Boolean isGeneral, Boolean isCategory, Boolean isBlog) {
        Map<String, Id> returnMap = new Map<String, Id>();
        List<Portal_Content__c> tmpList = 
            [
                SELECT
                //Page Setting
                Id, Unique_Page_Name__c, Content_Type__c, Fixed_Component__c, Article_Type__c,               
                //Distribution
                Content_Category__c, Distribution_Level__c, Distribution_Target__c,
                //Template
                Template_ID__c, Template_ID__r.Template_Name__c, Template_Unique_Name__c, Template_ID__r.Tech_Total_Component__c, Component_Number__c,
                //Child Page
                Child_List_Unique_Page_Name__c, Child_Unique_Page_Name__c,
                //Chatter
                Chatter_Feed_ID__c, Chatter_Feed_ID_Long__c, Number_of_Slides__c, Slideshow_Topic__c,
                Show_Chatter_File_On_Page__c, Show_Chatter_Group_On_Page__c, Show_Chatter_Photo_On_Page__c,
                //Content Section
                Article_Feed_Title__c, HTML_Selected__c, Video_Selected__c, RSS_Title__c, RSS_Feed_URL__c, Report_Name__c, Report_ID__c
                FROM Portal_Content__c
                WHERE RecordType.DeveloperName = 'Settings' 
                AND Content_Type__c = 'Chatter'
                //AND Distribution_Target__c IN :pages              
                And ( 
                    (Content_Category__c = 'General' AND Distribution_Target__c IN :pages) //General
                    OR ((Content_Category__c = :conCats OR Content_Category__c = 'General') AND Distribution_Target__c != null AND Distribution_Target__c != '') //Content Category
                    OR (Content_Category__c = :conCats AND (Distribution_Target__c = null OR Distribution_Target__c = '')) //Blog
                    )
                AND Component_Number__c != null
            ];      
        system.debug('### ACGUtil pages ' + pages);
        system.debug('### ACGUtil conCats ' + conCats);
        system.debug('### tmpList size ' + tmpList.size());
        //system.debug('### tmpList ' + tmpList);
        for(Portal_Content__c s: tmpList) {
            //system.debug('### s.Content_Category__c ' + s.Content_Category__c);
            //system.debug('### s.Distribution_Target__c ' + s.Distribution_Target__c);
            if(isGeneral && s.Content_Category__c == 'General' && pages.contains(s.Distribution_Target__c)) {
                returnMap.put(s.Distribution_Target__c, s.Chatter_Feed_ID__c);
            } else if(isCategory && ((conCats == s.Content_Category__c && s.Distribution_Target__c != null && s.Distribution_Target__c != '') || (pages.contains(s.Distribution_Target__c) && s.Content_Category__c == 'General'))) {
                returnMap.put(s.Content_Category__c + '-' + s.Distribution_Target__c, s.Chatter_Feed_ID__c);
            } else if(isBlog && conCats == s.Content_Category__c && (s.Distribution_Target__c == null || s.Distribution_Target__c == '')) {
                returnMap.put(s.Content_Category__c, s.Chatter_Feed_ID__c);
            }           
        }
        system.debug('@@@ returnMap ' + returnMap );
        return returnMap;
    }
    
    public static Portal_Content__c getfullArticle(String articleID) {
        List<Portal_Content__c> tmpList =
            [
                SELECT Id, Name,            
                LastModifiedDate, LastModifiedById, LastModifiedBy.Name,
                CreatedDate, CreatedById, CreatedBy.Name,
                OwnerId, Owner.Name, Owner.Email, Owner.Id,
                RecordType.DeveloperName, RecordType.Name,
                Publish_Datetime__c,
                //Distribution Section
                Content_Category__c, Distribution_Level__c, Distribution_Target__c, Status__c, Sticky_Scale__c, Expiry_Date__c, Article_Priority__c,
                //Content Fields Section
                Language__c, Title__c, Summary__c, Contents__c, Revised__c ,
                Title_en__c, Title_zhhk__c, Title_zhcn__c, Title_th__c, Title_vi__c, Title_id__c,
                Summary_en__c, Summary_zhhk__c, Summary_zhcn__c, Summary_th__c, Summary_vi__c, Summary_id__c,
                Contents_en__c ,Contents_zhhk__c, Contents_zhcn__c, Contents_th__c, Contents_vi__c, Contents_id__c,
                Revised_en__c, Revised_zhhk__c, Revised_zhcn__c, Revised_th__c, Revised_vi__c, Revised_id__c,       
                //Tech Custom Fields
                Tech_Id__c, Tech_LastUpdateDateTime__c, Tech_LastUpdateDate__c, Tech_CreatedDate__c, LangAlreadySendNotification__c, Tech_Feed_Item_Id__c,
                Attached_File_ID__c, Attached_File_Name__c,
                Attached_File_ID1__c, Attached_File_Name1__c,
                Attached_File_ID2__c, Attached_File_Name2__c,
                Attached_File_ID3__c, Attached_File_Name3__c,
                Attached_File_ID4__c, Attached_File_Name4__c //Add by DTT            
                FROM Portal_Content__c 
                WHERE Id = :articleID
                AND RecordType.DeveloperName = 'Rich_Text'
                limit 1
            ];
        if(!tmpList.isEmpty() && tmpList.size()==1) {
            return tmpList.get(0);
        }
        return null;
    }
    
    public static List<Portal_Content__c> getPageArticleFeeds(String contentCategory, String level, String target, Integer numberArticles, Boolean isLimit) {
        String recordTypeDeveloperName = 'Rich_Text';
        Date dtToday = date.today();
        //FIXME: Combine this section with that in ArticleListCtrl
        //Find Content Category & Division / Site
        Set<String> relatedConCats = new Set<String>();
        String relatedDiv = '';
        List<ACG_Hierarchy__c> acgs = new List<ACG_Hierarchy__c>();
        if(level == 'Site') {
            acgs = 
                [
                    SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Location__c
                    FROM ACG_Hierarchy__c
                    WHERE Type__c = :level
                    AND isHierarchySetting__c = true
                ];
            for(ACG_Hierarchy__c acg: acgs) {
                relatedConCats.add(acg.Content_Category__c);
                relatedDiv = acg.Division__c + ';' + acg.Group__c;
            }
            relatedDiv += ';'+target;
        }       
        String query = String.format(
            'SELECT {0} FROM Portal_Content__c WHERE RecordType.DeveloperName = :recordTypeDeveloperName AND {1} ORDER BY {2}',
            new List<String>{
                String.join(getArticleFields(), ', '),
                String.join(getArticleFeedConditions(contentCategory, level, target, relatedDiv), ' AND '),
                getArticleOrderBy()
            }
        );
        if(isLimit) {
            query += ' limit :numberArticles ';
        }
        system.debug('### query ' + query);
        List<Portal_Content__c> tmpList = (List<Portal_Content__c>) Database.query(query); 
        if(!tmpList.isEmpty()) {
            return tmpList;
        }
        return new List<Portal_Content__c>();
    }
    
    public static Integer getPageArticleFeedsCount(String contentCategory, String level, String target, Integer lastUpdateHours) {
        String recordTypeDeveloperName = 'Rich_Text';
        Date dtToday = date.today();
        //FIXME: Combine this section with that in ArticleListCtrl
        //Find Content Category & Division / Site
        Set<String> relatedConCats = new Set<String>();
        String relatedDiv = '';
        List<ACG_Hierarchy__c> acgs = new List<ACG_Hierarchy__c>();
        if(level == 'Site') {
            acgs = 
                [
                    SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Location__c
                    FROM ACG_Hierarchy__c
                    WHERE Type__c = :level
                    AND isHierarchySetting__c = true
                ];
            for(ACG_Hierarchy__c acg: acgs) {
                relatedConCats.add(acg.Content_Category__c);
                relatedDiv = acg.Division__c + ';' + acg.Group__c;
            }
            relatedDiv += ';'+target;
        }       
        String query = String.format(
            'SELECT COUNT(Id) FROM Portal_Content__c WHERE RecordType.DeveloperName = :recordTypeDeveloperName AND {0}',
            new List<String>{
                String.join(getLastUpdateArticleFeedConditions(contentCategory, level, target, relatedDiv), ' AND ')
            }
        );
        system.debug('### query ' + query);
        List<AggregateResult> tmpList = (List<AggregateResult>) Database.query(query);
        Integer i = 0;
        if(!tmpList.isEmpty()) {
            return (Integer) tmpList.get(0).get('expr0');
        }
        return i;
        
    }   
    
    public static Portal_Content__c getACGSettingByUniquePageName(String uniquePageName) {
        List<Portal_Content__c> tmpList = 
            [
                SELECT Name, Id, Template_ID__c, Template_ID__r.Template_Name__c, Unique_Page_Name__c 
                FROM Portal_Content__c
                WHERE RecordType.DeveloperName = 'Settings'  
                AND Unique_Page_Name__c = :uniquePageName 
                limit 1
            ];
        if(!tmpList.isEmpty() && tmpList.size()==1) {
            return tmpList.get(0);
        }
        return null;
    }
    public static Portal_Content__c getACGSettingById(Id recordId, String recordTypeDeverloperName) {
        List<Portal_Content__c> tmpList = 
            [
                SELECT Name, Id, Template_ID__c, Template_ID__r.Template_Name__c, Unique_Page_Name__c 
                , Content_Category__c, Distribution_Level__c, Distribution_Target__c
                FROM Portal_Content__c
                WHERE RecordType.DeveloperName = :recordTypeDeverloperName
                AND Id = :recordId 
                limit 1
            ];
        if(!tmpList.isEmpty() && tmpList.size()==1) {
            return tmpList.get(0);
        }
        return null;
    }   
        
    /**
        Dynamic Query Section
    */
    
    public static List<String> getArticleFields() {
        //FiXME - Combine with Article Edit Page SOQL
        return new List<String> {
            //System Fields
            'Id', 'Name',
            'LastModifiedDate', 'LastModifiedById', 'LastModifiedBy.Name',
            'CreatedDate', 'CreatedById', 'CreatedBy.Name',
            'OwnerId', 'Owner.Name', 'Owner.Email', 'Owner.Id',
            'RecordType.DeveloperName', 'RecordType.Name',
            'Publish_Datetime__c', 'Is_Article_Priority_Active__c', 'Article_Type__c', 'Article_Thumbnail__c',
            //Distribution Section
            'Content_Category__c', 'Distribution_Level__c', 'Distribution_Target__c', 'Status__c', 'Sticky_Scale__c', 'Expiry_Date__c', 'Article_Priority__c',
            //Content Fields Section
            'Language__c', 'Title__c', 'Summary__c', 'Contents__c', 'Revised__c ',
            'Title_en__c', 'Title_zhhk__c', 'Title_zhcn__c', 'Title_th__c', 'Title_vi__c', 'Title_id__c',
            'Summary_en__c', 'Summary_zhhk__c', 'Summary_zhcn__c', 'Summary_th__c', 'Summary_vi__c', 'Summary_id__c',
            'Contents_en__c ,Contents_zhhk__c', 'Contents_zhcn__c', 'Contents_th__c', 'Contents_vi__c', 'Contents_id__c',
            'Revised_en__c', 'Revised_zhhk__c', 'Revised_zhcn__c', 'Revised_th__c', 'Revised_vi__c', 'Revised_id__c',
            //Tech Custom Fields
            'Tech_Id__c', 'Tech_LastUpdateDateTime__c', 'Tech_LastUpdateDate__c', 'Tech_CreatedDate__c', 'LangAlreadySendNotification__c', 'Tech_Feed_Item_Id__c', 'Tech_Article_Feed_Item_Id__c'
        };
    }
    
    public static List<String> getArticleFeedConditions(String contentCategory, String level, String target, String relatedDiv) {  
        String tmpCond = '';        
        //system.debug('### level ' + level);
        //system.debug('### target ' + target);
        List<String> selectConditions = new List<String>();
        if(level != '' && level != null && target != ''&& target != null && !contentCategory.contains('Blog')) {
            //General
            if(contentCategory == 'General') {
                tmpCond = ' ( ( Distribution_Level__c = :level AND Distribution_Target__c INCLUDES(' + splitMultiSelectField(target) + ') ) ';
                if(level == 'Site') {
                    tmpCond += 'OR ( Content_Category__c IN :relatedConCats AND Distribution_Target__c INCLUDES(' + splitMultiSelectField(relatedDiv) + ') ) )';
                } else {
                    tmpCond += ' )';
                }
            } else { //Cateory Page
                //Division Level Category Page
                if(level == 'Division') {
                    tmpCond = ' Content_Category__c = :contentCategory ';
                } else if(level == 'Site') {
                    tmpCond = ' ( Content_Category__c = :contentCategory AND Distribution_Level__c = :level AND Distribution_Target__c INCLUDES(' + splitMultiSelectField(target) + ') ) ';        
                }
            }           
            selectConditions.add(tmpCond);
        } else {
            selectConditions.add(' Content_Category__c = :contentCategory ');
        }
        selectConditions.add(' Status__c = \'Published\' ');
        return selectConditions;
    }
    
    public static List<String> getLastUpdateArticleFeedConditions(String contentCategory, String level, String target, String relatedDiv) {  
        List<String> selectConditions = new List<String>();
        selectConditions = getArticleFeedConditions(contentCategory, level, target, relatedDiv);        
        selectConditions.add(' Tech_LastUpdateHours__c < :lastUpdateHours ');
        return selectConditions;        
    }

    public static String getArticleOrderBy() {
        return 'Is_Article_Priority_Active__c ASC, Article_Priority__c ASC, Tech_LastUpdateDateTime__c DESC ';
    }
    public static String splitMultiSelectField(String field) {
        String result='';
        List<String> tmpList = new List<String>();
        if (field != null && field !=''){
            for(String s: field.split(';')) {
                tmpList.add('\'' + s + '\'');
            }
        }
        if(!tmpList.isEmpty()) {
            return String.format('{0}', new List<String>{ String.join(tmpList, ', ') });
        }
        return '';
    }   
    
    /**
        Content Language Section
    */
    
    public static Portal_Content__c getUserPreferLanguageArticle(Portal_Content__c pc, String userPreferLanguage) {   
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Portal_Content__c');
        SObject sObj = (SObject) pc;
        for(String lang: SystemUtil.getPicklistValues('Portal_Content__c', 'Language__c')) {
            if(lang == userPreferLanguage) {
                //If user preferred translated version is available, return; else default English
                sObj.put('Title__c', sObj.get('Title_' + lang + '__c') != null? sObj.get('Title_' + lang + '__c'):sObj.get('Title_en__c'));
                sObj.put('Summary__c', sObj.get('Summary_' + lang + '__c') != null? sObj.get('Summary_' + lang + '__c'):sObj.get('Summary_en__c'));
                sObj.put('Contents__c', sObj.get('Contents_' + lang + '__c') != null? sObj.get('Contents_' + lang + '__c'):sObj.get('Contents_en__c'));
                sObj.put('Revised__c', sObj.get('Title_' + lang + '__c') != null? sObj.get('Revised_' + lang + '__c'):sObj.get('Revised_en__c'));
            }
        }
        return (Portal_Content__c) sObj;
    }
    
    /**
        Custom Setting SOQL
    */
    public static List<ACG_Hierarchy__c> getPageListValues(String pageDistTarget) {
        List<ACG_Hierarchy__c> tmpList = 
            [
                SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Level__c, Icon_Link__c, Order__c
                FROM ACG_Hierarchy__c 
                WHERE 
                (
                    (Site__c = :pageDistTarget And Level__c = 'Site') 
                    OR 
                    (Division__c = :pageDistTarget And Level__c = 'Division')
                )
                AND Content_Category__c != 'General'
                AND isPageListSetting__c = true
                order By Order__c
            ];
        if(!tmpList.isEmpty()) {
            return tmpList;
        }
        return new List<ACG_Hierarchy__c>();
    }
    
    public static List<ACG_Hierarchy__c> getACGList(String contentCategory, String level, String target) {
        String query = String.format(
            'Select Id, Name, Site__c, Content_Category__c, Division__c, Group__c, Type__c, Icon_Link__c, Label__c, Order__c, Location__c, Level__c, isLabelSetting__c, isDistributionSetting__c, isHierarchySetting__c, isPageListSetting__c, isDepartmentSetting__c FROM ACG_Hierarchy__c WHERE isDistributionSetting__c = true AND {0} ORDER BY Order__c',
            new List<String>{
                String.join(getACGConditions(contentCategory, level, target), ' AND ')
            }
        );
        system.debug('### query ' + query);
        List<ACG_Hierarchy__c> tmpList = (List<ACG_Hierarchy__c>) Database.query(query); 
        if(!tmpList.isEmpty()) {
            return tmpList;
        }
        return new List<ACG_Hierarchy__c>();
    }
    
    public static List<String> getACGConditions(String contentCategory, String level, String target) {  
        List<String> selectConditions = new List<String>();
        selectConditions.add(' Content_Category__c = :contentCategory ');
        selectConditions.add(' Type__c = :level ');
        if(level == 'Group') {
            selectConditions.add(' ( Group__c != null AND Group__c IN(' + splitMultiSelectField(target) + ') ) ');
        } else if(level == 'Division') {
            selectConditions.add(' ( Division__c != null AND Division__c IN(' + splitMultiSelectField(target) + ') ) ');
        } else if(level == 'Site') {
            selectConditions.add(' ( Site__c != null AND Site__c IN(' + splitMultiSelectField(target) + ') ) ');
        }
        return selectConditions;        
    }
    
    public static List<ACG_Hierarchy__c> getACGLevelList(String contentCategory, String target) {
        String query = String.format(
            'Select Id, Name, Site__c, Content_Category__c, Division__c, Group__c, Type__c, Icon_Link__c, Label__c, Order__c, Location__c, Level__c, isLabelSetting__c, isDistributionSetting__c, isHierarchySetting__c, isPageListSetting__c, isDepartmentSetting__c FROM ACG_Hierarchy__c WHERE isHierarchySetting__c = true AND Content_Category__c = :contentCategory AND ({0}) ORDER BY Order__c',
            new List<String>{
                String.join(getACGLevelConditions(target), ' OR ')
            }
        );
        system.debug('### query ' + query);
        List<ACG_Hierarchy__c> tmpList = (List<ACG_Hierarchy__c>) Database.query(query); 
        if(!tmpList.isEmpty()) {
            return tmpList;
        }
        return new List<ACG_Hierarchy__c>();
    }
    
    public static List<String> getACGLevelConditions(String target) {  
        List<String> selectConditions = new List<String>();
        selectConditions.add(' ( Level__c = \'Group\' AND Group__c IN(' + splitMultiSelectField(target) + ') ) ');
        selectConditions.add(' ( Level__c = \'Division\' AND Division__c IN(' + splitMultiSelectField(target) + ') ) ');
        selectConditions.add(' ( Level__c = \'Site\' AND Site__c IN(' + splitMultiSelectField(target) + ') ) ');
        return selectConditions;        
    }
    
    /**
        Site Path Utility
    */
    public static String getDivisonName(String strSite) {
        String result = '';
        List<ACG_Hierarchy__c> acgs = new List<ACG_Hierarchy__c>();
        acgs = 
            [
                SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Location__c
                FROM ACG_Hierarchy__c
                WHERE Type__c = 'Site'
                AND Site__c = :strSite
                AND isHierarchySetting__c = true
                limit 1
            ];
        if(!acgs.isEmpty()) {
            result = acgs.get(0).Division__c;
        }
        return result;      
    }
    
    public static String getPageURL(String page, String level) {
        //Construct Unique Page Name        
        String strPageName = 'MainPage_General_';
        strPageName += level + '_';
        String templateName = '';
        String url='';
        //Check if Default Landing Page is set
        if(page != '' && page != null) {
            strPageName += page;
            //Get Template Unique Name for landing page by Unique Page Name
            List<Portal_Content__c> uniquePages = 
                [   
                    SELECT Id, Unique_Page_Name__c, Template_Unique_Name__c
                    FROM Portal_Content__c 
                    WHERE RecordType.DeveloperName = 'Settings' 
                    AND Unique_Page_Name__c = :strPageName
                    limit 1
                ];          
            //system.debug('### uniquePages ' + uniquePages);
            if(uniquePages.size()>0) {
                templateName = uniquePages.get(0).Template_Unique_Name__c;          
                //Construct URL for landing page            
                url = '/apex/' + templateName + '?uniquePageName=' + StrPageName;
                url += '&' + Label.ConnecTalTab;
            } else {
                //No default landing page found
                url ='/apex/DefaultErrorPage';  
            }       
        } else {
            //No default landing page found
            url ='/apex/DefaultErrorPage';  
        }       
        return url;
    }
    
    public static String getDefaultLandingPageURL(String page) {
        //Construct Unique Page Name        
        String strPageNameSite = 'MainPage_General_';
        String strPageNameDivision = 'MainPage_General_';
        strPageNameSite += 'Site_';
        strPageNameDivision += 'Division_';
        String templateName = '';
        String url='';
        //Check if Default Landing Page is set
        if(page != '' && page != null) {
            strPageNameSite += page;
            strPageNameDivision += page;
            //Get Template Unique Name for landing page by Unique Page Name
            List<Portal_Content__c> uniquePages = 
                [   
                    SELECT Id, Unique_Page_Name__c, Template_Unique_Name__c
                    FROM Portal_Content__c 
                    WHERE RecordType.DeveloperName = 'Settings' 
                    AND (Unique_Page_Name__c = :strPageNameSite OR Unique_Page_Name__c = :strPageNameDivision)
                    limit 1
                ];          
            system.debug('### uniquePages ' + uniquePages);
            if(uniquePages.size()>0) {
                templateName = uniquePages.get(0).Template_Unique_Name__c;          
                //Construct URL for landing page            
                url = '/apex/' + templateName + '?uniquePageName=' + uniquePages.get(0).Unique_Page_Name__c;
                url += '&' + Label.ConnecTalTab;
            } else {
                //No default landing page found
                url ='/apex/DefaultErrorPage';  
            }       
        } else {
            //No default landing page found
            url ='/apex/DefaultErrorPage';  
        }       
        return url;
    }
    
    public static Integer getDefaultStickyExpiryDays() {
        Integer result = 7;
        
        try {
            if(Label.ACGDaysExpiry != null && Label.ACGDaysExpiry != '') {
                result = Integer.valueOf(Label.ACGDaysExpiry);
            }
        } catch (Exception e) {
            // die silently
        }
        
        return result;
    }
}