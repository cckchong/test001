public without sharing class ACGAdminCtrl {

/**
	Controller for ACG Pages Administration
	1. Edit Contents for Existing Page
	    Select a. Content Category
	           b. Distribution Level
	           c. Distribution Target
	2. Create new Page
	    Select a. Template Name
	           b. Content Category
	           c. Distribution Level
	           d. Distribution Target
	           e. Page Name
*/
    public String selectedContentCategory {get;set;}    
    public String selectedDistLevel {get;set;}    
    public String selectedDistTarget {get;set;}        
    public String selectedPage {get;set;}    
    public String selectedNewTemplate {get;set;}    
    public Integer iTotalComponents {get;set;}    
    public String selectedNewContentCategory {get;set;}    
    public String selectedNewDistLevel  {get;set;}    
    public String selectedNewDistTarget {get;set;}    
    public String selectedNewPageName {get;set;}        
    public String selectedConvertTemplate {get;set;}
    public String pageLink {get;set;}    
    public Boolean bCreatePage {get;set;}
    public Boolean bConvertPage {get;set;}        
    Boolean bBlogOrOffice = false; 
    Boolean bExistingBlogOrOffice = false;
    public List<Portal_Content__c> pageList {get;set;}    
    User usr = new User();    
    Map<Id, Integer> mapId2NumComponents;        
    public String strResult {get;set;}
    public ACGAdminCtrl() {
        //Get Current User Info
        usr = SystemUtil.getCurrentUserInfo();
        
        //Initialization
        mapId2NumComponents = new Map<Id, Integer>();
        bCreatePage = false;
        bConvertPage = false;
        bCreatePage = usr.Create_Portal_Page__c;
        bConvertPage = usr.Convert_ACG_Page_Layout__c;  
        
        //Default Values for Admin Page Load
        strResult = '';        
        refreshAllDistribution();
    }
    
    /**
    	Search Section 
    */  
    private List<String> selectFields = new List<String> {
		'Id', 'Page_Name__c', 'Unique_Page_Name__c', 'Template_ID__c', 'Template_Unique_Name__c', 'Fixed_Component__c', 'Content_Type__c',
		'Content_Category__c', 'Distribution_Level__c', 'Distribution_Target__c', 'ACG_Hierarchy__c'
    }; 
        
    private List<String> buildSelectionCriteria(String conCat, String level, String target, String pageName) {        
        List<String> selectConditions = new List<String>();        
        if (conCat != null && conCat != ''){
            selectConditions.add(' Content_Category__c = \''+conCat+'\'');
        }
        if (level != null && level != ''){
            selectConditions.add(' Distribution_Level__c = \''+level+'\'');
        }
        if (target != null && target !=''){
            selectConditions.add(' Distribution_Target__c = \''+target+'\'');
        }       
        if (pageName != null && pageName != ''){
            selectConditions.add(' Page_Name__c = \''+PageName+'\'');            
        }        
        return selectConditions;        
    }
    
    public String getOrderBy() {
        return 'Component_Number__c ASC';
    }
    public String debugQuery{get;set;}

    public PageReference searchPages() {
        strResult='';
        /*
        system.debug('@@@ selectedContentCategory ' + selectedContentCategory);	
        system.debug('@@@ selectedDistLevel ' + selectedDistLevel);	
        system.debug('@@@ selectedDistTarget ' + selectedDistTarget);	
        system.debug('@@@ selectedPage ' + selectedPage);
        */
        if(selectedPage == '' || selectedPage == '<Select One>' || selectedPage == null) {
        	strResult = 'Please select one page name!';
        	return null;
        } else {
	        List<String> queryCriteria = buildSelectionCriteria(selectedContentCategory, selectedDistLevel, selectedDistTarget, selectedPage);        
	        String recordType = 'Settings';
	        String query = String.format('SELECT {0} FROM Portal_Content__c WHERE RecordType.DeveloperName = :recordType and  {1} ORDER BY {2}',
										new List<String>{ String.join(selectFields, ','),  String.join(queryCriteria, ' AND '), getOrderBy() });
	        debugQuery = query;           
	        pageList = (List<Portal_Content__c>) Database.query(query);      
	        system.debug('@@@ debugQuery ' + debugQuery);			  
	        buildPageLink(false);
        }
        return null;
    }    
    
    /**
    	Edit page Section
    */
    
    public List<SelectOption> availableContentCategory {get;set;} {availableContentCategory = new List<SelectOption>();}
    public List<SelectOption> availableDistLevel {get;set;} {availableDistLevel = new List<SelectOption>();} 
    public List<SelectOption> availableDistTarget {get;set;} {availableDistTarget = new List<SelectOption>();}
    public List<SelectOption> availablePageNames {get;set;} {availablePageNames = new List<SelectOption>();}
        
    public PageReference refreshAllDistribution() {	
        refreshAvailableContentCategory();
        refreshAvailableDistLevel();
        refreshAvailableDistTarget();
        refreshAvailablePageNames();
        return null;
    }
    
	public void refreshAvailableContentCategory() {
     	List<SelectOption> result = new List<SelectOption>();
     	if(usr.Administrative_Category__c != null) {
     		Set<String> setTmp = new Set<String>();
	    	List<Portal_Content__c> tmps = 
	    		[
	    			Select Page_Name__c, Content_Category__c, Distribution_Level__c, Distribution_Target__c, 
					Unique_Page_Name__c, Template_ID__c, Template_Unique_Name__c,
					Child_List_Page__c, Child_List_Unique_Page_Name__c, Child_Page__c, Child_Unique_Page_Name__c
	                From Portal_Content__c 
	                Where RecordType.DeveloperName = 'Settings'
	                And Component_Number__c != ''
	                And Content_Category__c IN :usr.Administrative_Category__c.split(';')
				];
			for(Portal_Content__c tmp: tmps) {
				setTmp.add(tmp.Content_Category__c);
			}
			List<ACG_Hierarchy__c> acgs = 
	    		[
	    			SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Level__c, Label__c
					FROM ACG_Hierarchy__c
					WHERE Name IN :setTmp
	                AND Type__c = 'Label_ContentCategory'
	                order by Order__c
				];	
			for(ACG_Hierarchy__c acg: acgs) {
				result.add(new SelectOption(acg.Name, acg.Label__c));
			}
			if(result.size() > 1) {
				result.add(0, new SelectOption('<Select one>','<Select one>'));			
			} else if (result.size() == 1){
				selectedContentCategory = result.get(0).getValue();			
			}
     	} 
    	availableContentCategory = result;
	}
	
	public void refreshAvailableDistLevel() {		
		if(selectedContentCategory != null && selectedContentCategory != '') {
    		bExistingBlogOrOffice = selectedContentCategory.contains('Blog') || selectedContentCategory.contains('Office');
    	}
    	if(bExistingBlogOrOffice) {
    		selectedDistLevel = '';
    		selectedDistTarget = '';
    		availableDistLevel = new List<SelectOption>();
    		availableDistTarget = new List<SelectOption>();
    	} else {
     		List<SelectOption> result = new List<SelectOption>();
	    	List<Portal_Content__c> tmps = new List<Portal_Content__c>();
	    	if(usr.Administrative_Target__c != null) {	    		
     			Set<String> setTmp = new Set<String>();
		    	tmps = 
		    		[
		    			SELECT Page_Name__c, Content_Category__c, Distribution_Level__c, Distribution_Target__c, 
						Unique_Page_Name__c, Template_ID__c, Template_Unique_Name__c, ACG_Hierarchy__c,
						Child_List_Page__c, Child_List_Unique_Page_Name__c, Child_Page__c, Child_Unique_Page_Name__c
		                FROM Portal_Content__c 
		                WHERE RecordType.DeveloperName = 'Settings'
		                AND Component_Number__c != ''
		                AND Content_Category__c =: selectedContentCategory
					];
				for(Portal_Content__c tmp: tmps) {
					if(usr.Administrative_Target__c.contains(tmp.Distribution_Target__c)) {
						if(ACG_Hierarchy__c.getAll().containsKey(tmp.ACG_Hierarchy__c)) {
							String strType = ACG_Hierarchy__c.getAll().get(tmp.ACG_Hierarchy__c).Level__c;
							if(strType != null) {
								setTmp.add(strType);
							}
						}
					}
				}
				List<ACG_Hierarchy__c> acgs = 
		    		[
		    			SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Level__c, Label__c
						FROM ACG_Hierarchy__c
						WHERE Name IN :setTmp
		                AND Type__c = 'Label_Hierarchy'
		                order by Order__c
					];	
				for(ACG_Hierarchy__c acg: acgs) {
					result.add(new SelectOption(acg.Name, acg.Label__c));
				}
				if(result.size() > 1) {
					result.add(0, new SelectOption('<Select one>','<Select one>'));			
				} else if (result.size() == 1){
					selectedDistLevel = result.get(0).getValue();			
				}
	    	}
			availableDistLevel = result;
    	}
	}
	
	public void refreshAvailableDistTarget() {
		if(selectedContentCategory != null && selectedContentCategory != '') {
    		bExistingBlogOrOffice = selectedContentCategory.contains('Blog') || selectedContentCategory.contains('Office');
    	}
    	if(!bExistingBlogOrOffice) {
     		List<SelectOption> result = new List<SelectOption>();
			List<Portal_Content__c> tmps = new List<Portal_Content__c>();
			if(usr.Administrative_Target__c != null) {
		    	Set<String> setTmp = new Set<String>();
		    	tmps = 
		    		[
		    			Select Page_Name__c, Content_Category__c, Distribution_Level__c, Distribution_Target__c, 
						Unique_Page_Name__c, Template_ID__c, Template_Unique_Name__c, ACG_Hierarchy__c,
						Child_List_Page__c, Child_List_Unique_Page_Name__c, Child_Page__c, Child_Unique_Page_Name__c
		                From Portal_Content__c 
		                Where RecordType.DeveloperName = 'Settings'
		                And Component_Number__c != ''
		                And Content_Category__c =: selectedContentCategory
		                And Distribution_Level__c =: selectedDistLevel
					];			
				for(Portal_Content__c tmp: tmps) {
					if(usr.Administrative_Target__c.contains(tmp.Distribution_Target__c)) {
						setTmp.add(tmp.Distribution_Target__c);
					}
				}
				List<ACG_Hierarchy__c> acgs = 
		    		[
		    			SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Level__c, Label__c
						FROM ACG_Hierarchy__c
						WHERE Name IN :setTmp
		                AND Type__c = 'Label_Hierarchy'
		                order by Order__c
					];	
				for(ACG_Hierarchy__c acg: acgs) {
					result.add(new SelectOption(acg.Name, acg.Label__c));
				}
				if(result.size() > 1) {
					result.add(0, new SelectOption('<Select one>','<Select one>'));			
				} else if (result.size() == 1){
					selectedDistTarget = result.get(0).getValue();			
				}
			}
	        availableDistTarget = result;
    	}
	}
	
	public void refreshAvailablePageNames() {
		Set<SelectOption> options = new Set<SelectOption>();      
    	List<Portal_Content__c> tmps = 
    		[
    			Select Page_Name__c, Content_Category__c, Distribution_Level__c, Distribution_Target__c, 
				Unique_Page_Name__c, Template_ID__c, Template_Unique_Name__c, ACG_Hierarchy__c,
				Child_List_Page__c, Child_List_Unique_Page_Name__c, Child_Page__c, Child_Unique_Page_Name__c
                From Portal_Content__c 
                Where RecordType.DeveloperName = 'Settings'
                And Component_Number__c != ''
                And Content_Category__c =: selectedContentCategory
                And Distribution_Level__c =: selectedDistLevel
                And Distribution_Target__c = :selectedDistTarget
			];
        for(Portal_Content__c tmp: tmps) {
			options.add(new SelectOption(tmp.Page_Name__c, tmp.Page_Name__c));
		}
		if(options.size() > 1) {
			options.add(new SelectOption('<Select one>','<Select one>'));			
		} else if (options.size() == 1){
			List<SelectOption> tmpSelected = new List<SelectOption>(options);
			selectedPage = tmpSelected.get(0).getValue();		
		}	
		List<SelectOption> result = new List<SelectOption>(options);
        SelectOptionUtil.doSort(result, SelectOptionUtil.FieldToSort.Label);   
    	availablePageNames = result;
	}	
    
    /**
    	Create New Page Section
    */
    public List<SelectOption> availableTemplateNames {get{
        List<Portal_Content__c> tmp = 
        	[
        		Select Id, Template_Name__c, Tech_Total_Component__c
                from Portal_Content__c 
                Where RecordType.DeveloperName = 'Template'
                And Tech_Total_Component__c != null
            ];
        Set<SelectOption> options = new Set<SelectOption>();
        for (Portal_Content__c p:tmp)
        {
            options.add(new SelectOption(p.Id, p.Template_Name__c));
            mapId2NumComponents.put(p.Id, Integer.valueOf(p.Tech_Total_Component__c));
        }
        options.add(new SelectOption('<Select one>','<Select one>'));
        List<SelectOption> result = new List<SelectOption>(options);
        SelectOptionUtil.doSort(result, SelectOptionUtil.FieldToSort.Label);
        return result;
    }
    set;}
    
    public List<SelectOption> availableNewContentCategory {get{
    	List<SelectOption> result = new List<SelectOption>();
	    if(usr.Administrative_Category__c != null) {   	
	    	List<ACG_Hierarchy__c> acgs = 
	    		[
	    			SELECT Name, Content_Category__c, Division__c, Group__c, Site__c, Type__c, Level__c, Label__c
					FROM ACG_Hierarchy__c
					WHERE Name IN :usr.Administrative_Category__c.split(';')
	                AND Type__c = 'Label_ContentCategory'
	                order by Order__c
				];	
			for(ACG_Hierarchy__c acg: acgs) {
				result.add(new SelectOption(acg.Name, acg.Label__c));
			}
			if(result.size() > 1) {
				result.add(0, new SelectOption('<Select one>','<Select one>'));			
			} else if (result.size() == 1){
				selectedNewContentCategory = result.get(0).getValue();			
			}
	    }	
    	return result;
    }
    set;}
    
    public List<SelectOption> availableNewDistLevel {get{
    	List<SelectOption> result = new List<SelectOption>();
    	if(selectedNewContentCategory != null && selectedNewContentCategory != '') {
    		bBlogOrOffice = selectedNewContentCategory.contains('Blog') || selectedNewContentCategory.contains('Office');
    	}
    	if(bBlogOrOffice) {
    		selectedNewDistLevel = '';
    		selectedNewDistTarget = '';
    	} else {
	    	Boolean bContainsDivision = false;  	
	    	Set<String> tmpSet = new Set<String>();
	    	List<ACG_Hierarchy__c> acgs = new List<ACG_Hierarchy__c>();
	    	if(usr.Administrative_Target__c != null) {
		        acgs = ACGUtil.getACGLevelList(selectedNewContentCategory, usr.Administrative_Target__c);
				system.debug('### acgs ' + acgs.size());
				for(ACG_Hierarchy__c acg: acgs) {
					//system.debug('### acg ' + acg);
					//system.debug('### acg Level__c ' + acg.Level__c);
					//system.debug('### acg Site__c ' + acg.Site__c);
					//system.debug('### acg Division__c ' + acg.Division__c);
					if(!tmpSet.contains(acg.Level__c)) {
						tmpSet.add(acg.Level__c);
						result.add(new SelectOption(acg.Level__c, ACG_Hierarchy__c.getValues(acg.Level__c).Label__c));
					}
					if(acg.Content_Category__c != 'General' && acg.Level__c == 'Division') {
						bContainsDivision = true;
					}
				}
	    	}
			if(bContainsDivision) {
				result = new List<SelectOption>();
				result.add(new SelectOption('Division', ACG_Hierarchy__c.getValues('Division').Label__c));
			}
			if(result.size() > 1) {
				result.add(0, new SelectOption('<Select one>','<Select one>'));			
			} else if (result.size() == 1){
				selectedNewDistLevel = result.get(0).getValue();
			}
    	}
    	return result;
    }
    set;}
    
    public List<SelectOption> availableNewDistTarget {get{    	
    	List<SelectOption> result = new List<SelectOption>();
    	if(selectedNewContentCategory != null && selectedNewContentCategory != '') {
    		bBlogOrOffice = selectedNewContentCategory.contains('Blog') || selectedNewContentCategory.contains('Office');
    	}
    	system.debug('### selectedNewDistLevel ' + selectedNewDistLevel);
    	if(!bBlogOrOffice) {
	    	Set<String> tmpSet = new Set<String>();
	    	List<ACG_Hierarchy__c> acgs = new List<ACG_Hierarchy__c>();
	    	if(usr.Administrative_Target__c != null) {
		        acgs = ACGUtil.getACGList(selectedNewContentCategory, selectedNewDistLevel, usr.Administrative_Target__c);
				system.debug('### acgs ' + acgs.size());
	       	}
			for(ACG_Hierarchy__c acg: acgs) {
				if(acg.Level__c == 'Group') {
					if(!tmpSet.contains(acg.Group__c)) {
						tmpSet.add(acg.Group__c);
						result.add(new SelectOption(acg.Group__c, ACG_Hierarchy__c.getValues(acg.Group__c).Label__c));
					}
				} else if(acg.Level__c == 'Division') {
					if(!tmpSet.contains(acg.Division__c)) {
						tmpSet.add(acg.Division__c);
						result.add(new SelectOption(acg.Division__c, ACG_Hierarchy__c.getValues(acg.Division__c).Label__c));
					}
				} else if(acg.Level__c == 'Site') {
					if(!tmpSet.contains(acg.Site__c)) {
						tmpSet.add(acg.Site__c);
						result.add(new SelectOption(acg.Site__c, ACG_Hierarchy__c.getValues(acg.Site__c).Label__c));
					}
				}			
			}
			if(result.size() > 1) {
				result.add(0, new SelectOption('<Select one>','<Select one>'));			
			} else if (result.size() == 1){
				selectedNewDistTarget = result.get(0).getValue();
			}
    	}
    	return result;
    }
    set;}
    
    public List<SelectOption> availableNewPageName {get{    
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('<Select one>','<Select one>'));
        result.add(new SelectOption('MainPage','MainPage'));
        result.add(new SelectOption('ListPage','ListPage'));
        result.add(new SelectOption('DetailPage','DetailPage'));
        return result;
    }
    set;}
    
    /** 
    	Create Section 
    */
    public PageReference createPage(){
        strResult='';
        
        if(selectedNewTemplate == '<Select one>') {
        	strResult = 'Please select one Template!';
        } else if(selectedNewContentCategory == '<Select one>') {
        	strResult = 'Please select one Content Category!';
        } else if(selectedNewDistLevel == '<Select one>') {
        	strResult = 'Please select one Distribution Level!';
        } else if(selectedNewPageName == '<Select one>') {
        	strResult = 'Please select one page name!';
        } else {
        	//Check if page exist
	        List<String> queryCriteria = buildSelectionCriteria(selectedNewContentCategory, selectedNewDistLevel, selectedNewDistTarget, selectedNewPageName);     
	        String recordType = 'Settings';
	        String query = String.format('SELECT {0} FROM Portal_Content__c WHERE RecordType.DeveloperName = :recordType and  {1} ORDER BY {2}',
	                                            new List<String>{ String.join(selectFields, ','),  String.join(queryCriteria, ' AND '), getOrderBy() });       
	        pageList =  (List<Portal_Content__c>) Database.query(query);
	        if(pageList.size()==0) {
	            //Existing Page not found, continue to create new page          
	            RecordType rt = [Select Id, Name From RecordType Where Name ='Settings' limit 1];
	            
	            List<Portal_Content__c> newSettings = new List<Portal_Content__c>();
	            //Get the number of components required for the selected template
	            iTotalComponents = mapId2NumComponents.containsKey(selectedNewTemplate)?mapId2NumComponents.get(selectedNewTemplate):0;
	            if(iTotalComponents > 0) {
	                //Create number of required setting records 
	                for(Integer i=1; i<=iTotalComponents; i++) {
	                    Portal_Content__c obj = new Portal_Content__c();
	                    obj.RecordTypeId = rt.Id;
	                    obj.Page_Name__c = selectedNewPageName;                      
	                    obj.Content_Category__c = selectedNewContentCategory;
	                    obj.Distribution_Level__c = selectedNewDistLevel;
	                    obj.Distribution_Target__c = selectedNewDistTarget;
	                    obj.Template_ID__c = selectedNewTemplate;
	                    obj.HTML_Selected__c = SystemUtil.getBlankHTMLId();
	                    obj.Content_Type__c = 'HTML';
	                    obj.Component_Number__c = String.ValueOf(i);
	                    newSettings.add(obj);
	                }	                    
	                insert (newSettings);
	                	                
	                Set<Id> setNewIds = new Set<Id>();
	                for(Portal_Content__c p: newSettings) {
	                    setNewIds.add(p.Id);
	                }	                    
	                pageList = [Select Id, Template_Unique_Name__c, Unique_Page_Name__c, Fixed_Component__c, Content_Category__c, Distribution_Level__c, Distribution_Target__c 
	                            From Portal_Content__c Where Id In:setNewIds];
	                buildPageLink(true);	                
	                //Page Created
	                strResult = 'Page created successfully!';
	            }
	        } else {
	            //Existing Page found
	            strResult = 'Existing Page found!';
	            //Open the existing page instead of creating a new page
	            buildPageLink(true);
	        }        
        }       
        return null;
    }
    
    /**
    	Convert Section 
    */ 
    public void convertTemplate() {
        List<String> queryCriteria = buildSelectionCriteria(selectedContentCategory, selectedDistLevel, selectedDistTarget, selectedPage);        
        String recordType = 'Settings';
        String query = String.format('SELECT {0} FROM Portal_Content__c WHERE RecordType.DeveloperName = :recordType and  {1} ORDER BY {2}',
                                            new List<String>{ String.join(selectFields, ','),  String.join(queryCriteria, ' AND '), getOrderBy() });
        debugQuery = query;        
        List<Portal_Content__c> existingPageList = new List<Portal_Content__c>();    
        existingPageList =  (List<Portal_Content__c>) Database.query(query); 
        List<Portal_Content__c> newComps = new List<Portal_Content__c>();
        if(existingPageList.size()>0) {
            //Get number of components in the target template layout
            Integer numComps = mapId2NumComponents.containsKey(selectedConvertTemplate)?mapId2NumComponents.get(selectedConvertTemplate):0;                        
            //Change the template Id of the existing records to the target template Id 
            for(Portal_Content__c tmp: existingPageList) {
                tmp.Template_ID__c = selectedConvertTemplate;
            }
            update existingPageList;
            //Check if the number of components of target template is larger than existing template
            //if yes, insert 'Blank" html records            
            if(numComps>existingPageList.size()) {
                for(Integer i=existingPageList.size()+1; i<=numComps; i++ ) {
                    Portal_Content__c obj = new Portal_Content__c();
                    obj.RecordTypeId = existingPageList.get(0).RecordTypeId;
                    obj.Page_Name__c = existingPageList.get(0).Page_Name__c;                        
                    obj.Content_Category__c = existingPageList.get(0).Content_Category__c;
                    obj.Distribution_Level__c = existingPageList.get(0).Distribution_Level__c;
                    obj.Distribution_Target__c = existingPageList.get(0).Distribution_Target__c;
                    obj.Template_ID__c = selectedConvertTemplate;
                    obj.HTML_Selected__c = SystemUtil.getBlankHTMLId();
                    obj.Content_Type__c = 'HTML';
                    obj.Component_Number__c = String.ValueOf(i);
                    newComps.add(obj);
                }
                insert newComps;
            }        
            if(pageList == null) {
                pageList  = new List<Portal_Content__c>();
            } else {
                pageList.clear();
            }
            pageList = (List<Portal_Content__c>) Database.query(query);
            for(Portal_Content__c tmp:newComps) {
                pageList.add(tmp);
            }
            buildPageLink(false);
        } else {
            //Page not found
            strResult = 'Page not found!';
        }
    }        
    
    /**
    	Common Function Section 
    */    
    public void buildPageLink(boolean bCreate) {
        Map<String, Portal_Content__c> mapPage = new Map<String, Portal_Content__c>();
        for(Portal_Content__c pc : pageList) {
            if(pc.Fixed_Component__c == 'Article Detail') {
                mapPage.put(pc.Fixed_Component__c, pc);
            }
        }
        if (!pageList.isEmpty())  {
            pageLink = '/apex/'+pageList.get(0).Template_Unique_Name__c;
            pageLink += '?uniquePageName='+pageList.get(0).Unique_Page_Name__c;
            pageLink += '&edit=true';
	        
            //If the page contains 'Article Details component'
            Integer numberArticles = 1;            
			String contentCategory;  
            String level;
            String target;
            if(bCreate) {
				contentCategory = selectedNewContentCategory;  
	            level = selectedNewDistLevel;
	            target = selectedNewDistTarget;
            } else {
            	contentCategory = selectedContentCategory;  
	            level = selectedDistLevel;
	            target = selectedDistTarget;	
            }
            if(mapPage.containsKey('Article Detail')) {
            	List<Portal_Content__c> articleFeed = ACGUtil.getPageArticleFeeds(contentCategory, level, target, 1, true);      	
                if(!articleFeed.isEmpty()) {
                    pageLink += '&Id='+ articleFeed.get(0).Id;
                    pageLink += '&title='+ articleFeed.get(0).title_en__c;
                } else {                    	
                	pageLink += '&Id='+userinfo.getUserID();  
                }                
            }
            
        	pageLink += '&ContentCategory='+ contentCategory;
            pageLink += '&DistLevel='+ level;
            pageLink += '&DistTarget='+ target;
                       
        }
        system.debug('### pageLink ' + pageLink);
    }
}