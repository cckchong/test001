/*****************************************************
Handler for ACG Content 

1. addReviseWord
    a. Add [Revised] to the title of the corresponding translated version
2. storeCreatedDateAndLastModdate
    a. Store the Created Date,  Last Modified Date, Created By and Id of the announcement for Article Wrapper deep clone
3. calculateSharing
	a. Add apex sharing rule to content admin
******************************************************/
public without sharing class ACGContentTriggerHandler {
    private static RecordType richTextRt {get;}
    private static RecordType settingsRt {get;}
    
    public static RecordType getSettingsRecordType() {
        if(ACGContentTriggerHandler.settingsRt == null) {
            List<RecordType> rts = 
                [
                    SELECT Id, Name, Developername
                    FROM RecordType 
                    WHERE SObjectType = 'Portal_Content__c' 
                    AND (Developername = 'Settings') 
                    limit 2
                ];
            
            if(rts != null && !rts.isEmpty()) {
                ACGContentTriggerHandler.settingsRt = rts[0];
            }
            
        }
        
        return ACGContentTriggerHandler.settingsRt;
    }
    
    public static RecordType getRichTextRecordType() {
        if(ACGContentTriggerHandler.richTextRt == null) {
            List<RecordType> rts = 
                [
                    SELECT Id, Name, Developername
                    FROM RecordType 
                    WHERE SObjectType = 'Portal_Content__c' 
                    AND (Developername = 'Rich_Text') 
                    limit 2
                ];
            
            if(rts != null && !rts.isEmpty()) {
                ACGContentTriggerHandler.richTextRt = rts[0];
            }
            
        }
        
        return ACGContentTriggerHandler.richTextRt;
    }
    
    public static void calculateSharing(Map<Id, Portal_Content__c> oldMap, Map<Id, Portal_Content__c> newMap) {
        List<Portal_Content__c> pcList = new List<Portal_Content__c>();
        
        //List<RecordType> rts = [SELECT Id FROM RecordType WHERE SObjectType = 'Portal_Content__c' AND DeveloperName = 'Settings' limit 1]; // AN: Commented out 04/08/2015
        
        Id settingsRecordTypeId;
        
        // AN: Commented out 04/08/2015
        //if(!rts.isEmpty()) {
        //    settingsRecordTypeId = rts.get(0).Id;
        //}
        
        settingsRecordTypeId = ACGContentTriggerHandler.getSettingsRecordType().Id;
        
        Set<Id> componentIds = new Set<Id>();
        for(Portal_Content__c pc : newMap.values()) {
            if( Trigger.isInsert || (pc.RecordTypeId == settingsRecordTypeId &&
                (pc.Content_Category__c != oldMap.get(pc.Id).Content_Category__c ||
                pc.Distribution_Target__c != oldMap.get(pc.Id).Distribution_Target__c))) {                
                pcList.add(pc);                
                if(pc.HTML_Selected__c != null) {
                    componentIds.add(pc.HTML_Selected__c);
                }
                if(pc.Video_Selected__c != null) {
                    componentIds.add(pc.Video_Selected__c);
                }
            }
        }        
        Map<Id, List<Portal_Content__c>> parentSettingsToComponent = new Map<Id, List<Portal_Content__c>>();       
        if(!pcList.isEmpty()) {
            List<Portal_Content__Share> pShareList = 
            	[
            		SELECT Id FROM Portal_Content__Share 
            		WHERE rowcause = 'Manual' 
            		AND (ParentId IN : pcList OR ParentId IN: componentIds)
            	];            
            if(!pShareList.isEmpty()) {
                delete pShareList;
            }
            system.debug('### sharing management' + pcList);
            SharingManagementUtil.calculatePortalContentSharingRules(pcList, componentIds);            
        }        
    }
    
    public static void addReviseWord(List<Portal_Content__c> listNewPortalContent, Map<Id,Portal_Content__c> OldMapPortalContent, RecordType rt)
    {
        for(Portal_Content__c pc: listNewPortalContent) {
            if(pc.RecordTypeId == rt.Id) {
                if(pc.Revised_en__c == true && OldMapPortalContent.get(pc.Id).Revised_en__c == false) {
                    pc.Title_en__c = '['+System.Label.Revised + '] ' + pc.Title_en__c;
                }
                if(pc.Revised_zhhk__c == true && OldMapPortalContent.get(pc.Id).Revised_zhhk__c == false) {
                    pc.Title_zhhk__c = '['+System.Label.Revised + '] ' + pc.Title_zhhk__c;
                }
                if(pc.Revised_zhcn__c == true && OldMapPortalContent.get(pc.Id).Revised_zhcn__c == false) {
                    pc.Title_zhcn__c = '['+System.Label.Revised + '] ' + pc.Title_zhcn__c;
                }
                if(pc.Revised_th__c == true && OldMapPortalContent.get(pc.Id).Revised_th__c == false) {
                    pc.Title_th__c = '['+System.Label.Revised + '] ' + pc.Title_th__c;
                }
                if(pc.Revised_vi__c == true && OldMapPortalContent.get(pc.Id).Revised_vi__c == false) {
                    pc.Title_vi__c = '['+System.Label.Revised + '] ' + pc.Title_vi__c;
                }
                if(pc.Revised_id__c == true && OldMapPortalContent.get(pc.Id).Revised_id__c == false) {
                    pc.Title_id__c = '['+System.Label.Revised + '] ' + pc.Title_id__c;
                }     
            }               
        }       
    }

    public static void storeCreatedDateAndLastModdate(List<Portal_Content__c> listNewPortalContent, RecordType rt)
    {
        for(Portal_Content__c pc :listNewPortalContent) {
            if(pc.RecordTypeId == rt.Id) {
                if(pc.Tech_CreatedDate__c != null) {
                    pc.Tech_LastUpdateDate__c = datetime.now();
                }  else {               
                    pc.Tech_CreatedDate__c = pc.CreatedDate;
                    pc.Tech_CreatedBy__c = pc.CreatedById;                    
                }
                pc.Tech_Id__c = pc.Id;
            }
            system.debug('### trigger storeCreatedDateAndLastModdate ' + pc.Tech_Id__c + ' - ' + pc.Id);
        }
    }
    
    public static void onlyOneRssFeedIsAllowedPerPage(List<Portal_Content__c> listNewPortalContent, RecordType rt)
    { 	
    	Set<String> pages = new Set<String>();
    	for(Portal_Content__c pc :listNewPortalContent) {
    		if(pc.RecordTypeId == rt.Id && pc.Content_Type__c== 'RSS') {
    			pages.add(pc.Unique_Page_Name__c);
    		}
    	}
    	//system.debug('### pages ' + pages);
    	List<Portal_Content__c> pcs = 
    		[
    			SELECT
                //Page Setting
                Id, Unique_Page_Name__c, Content_Type__c, Fixed_Component__c,                
                //Distribution
                Content_Category__c, Distribution_Level__c, Distribution_Target__c,
                //Template
                Template_ID__c, Template_ID__r.Template_Name__c, Template_Unique_Name__c, Template_ID__r.Tech_Total_Component__c, Component_Number__c,
                //Child Page
                Child_List_Unique_Page_Name__c, Child_Unique_Page_Name__c,
                //Chatter
                Chatter_Feed_ID__c, Number_of_Slides__c, Slideshow_Topic__c,
                Show_Chatter_File_On_Page__c, Show_Chatter_Group_On_Page__c, Show_Chatter_Photo_On_Page__c,
                //Content Section
                Article_Feed_Title__c, HTML_Selected__c, Video_Selected__c, RSS_Title__c, RSS_Feed_URL__c, Report_Name__c, Report_ID__c
                FROM Portal_Content__c 
				WHERE RecordType.DeveloperName = 'Settings' 
				AND Unique_Page_Name__c IN :pages
				AND Content_Type__c = 'RSS'
                AND Component_Number__c != null 
    		];
    	//system.debug('### pcs ' + pcs);
   		Map<String, Id> pageWithRSS = new Map<String, Id>();
   		for(Portal_Content__c pc :pcs) {
   			pageWithRSS.put(pc.Unique_Page_Name__c, pc.Id);
   		}
   		//system.debug('### pageWithRSS ' + pageWithRSS);
        for(Portal_Content__c pc :listNewPortalContent) {
        	if(pc.RecordTypeId == rt.Id) {
	        	if(pageWithRSS.containsKey(pc.Unique_Page_Name__c)) {
	        		if(pageWithRSS.get(pc.Unique_Page_Name__c) != pc.Id && pc.Content_Type__c== 'RSS') {

	        			pc.addError(Label.ACGOnlyOneRssFeedIsAllowedPerPage);
	        		}
	        	}
        	}
        }
    }
    
}