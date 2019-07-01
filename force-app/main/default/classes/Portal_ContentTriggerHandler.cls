/*****************************************************
Handler for Portal Content 

1. addReviseWord
	a. Add [Revised] to the title of the corresponding translated version
2. storeCreatedDateAndLastModdate
	a. Store the Created Date,  Last Modified Date, Created By and Id of the announcement for Article Wrapper deep clone
3. ensureSubCatIsDefined
	a. Ensure the Distribution Site is defined
******************************************************/
public without sharing class Portal_ContentTriggerHandler {
	/*
    public static void calculateSharing(Map<Id, Portal_Content__c> oldMap, Map<Id, Portal_Content__c> newMap) {
        List<Portal_Content__c> pcList = new List<Portal_Content__c>();
        Id settingsRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Portal_Content__c' AND DeveloperName = 'Settings'].Id;
        Id htmlRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Portal_Content__c' AND DeveloperName = 'HTML'].Id;
        Id videoRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Portal_Content__c' AND DeveloperName = 'Video'].Id;
		

        Set<Id> componentIds = new Set<Id>();
        for(Portal_Content__c pc : newMap.values()) {
            if( Trigger.isInsert || (pc.RecordTypeId == settingsRecordTypeId &&
                (pc.Sub_Category__c != oldMap.get(pc.Id).Sub_Category__c ||
               	pc.BU__c != oldMap.get(pc.Id).BU__c))) {
				
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
            List<Portal_Content__Share> pShareList = [SELECT Id FROM Portal_Content__Share WHERE rowcause = 'Manual' AND (ParentId IN : pcList OR ParentId IN: componentIds)];
            
            if(!pShareList.isEmpty()) {
                delete pShareList;
            }
            
            SharingManagementUtil.calculatePortalContentSharingRules(pcList, componentIds);
            
        }        
    }
    
    public static void updateFieldsforListViewSecurity(Map<Id, Portal_Content__c> oldMap, Map<Id, Portal_Content__c> newMap) 
    {
    	//if distribution site / grade is changed
    	List<Portal_Content__c> pcList = new List<Portal_Content__c>();
    	Id AnnouncementRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Portal_Content__c' AND DeveloperName = 'Rich_Text'].Id;
    	for(Portal_Content__c pc : newMap.values()) 
    	{
    		//Announcecement Records
    		if(pc.RecordTypeId == AnnouncementRecordTypeId)
    		{    			
    			//Site Change
    			//if(Trigger.isUpdate)
    			{
    				if ((pc.Sub_Category__c != null && pc.Sub_Category__c != '') &&
	    				(pc.Sub_Category__c != oldMap.get(pc.Id).Sub_Category__c 
			        	|| pc.Tech_Distribution_Site_Formula_Text__c == null || pc.Tech_Distribution_Site_Formula_Text__c == ''))
	           		{		
		            	pc.Tech_Distribution_Site_Formula_Text__c = '';	
		            	for(String site :pc.Sub_Category__c.split(';'))
		            	{
		            		pc.Tech_Distribution_Site_Formula_Text__c += site + ',';	            		         			
		            	}    
		            	if(pc.Tech_Distribution_Site_Formula_Text__c.endsWith(','))
		            	{
		            		pc.Tech_Distribution_Site_Formula_Text__c = pc.Tech_Distribution_Site_Formula_Text__c.substring(0,pc.Tech_Distribution_Site_Formula_Text__c.length()-1);
		            	} 	
		            }
		            
		            //Grade Change
		            if((pc.Distribution_Grade__c != null && pc.Distribution_Grade__c != '') &&
		            	(pc.Distribution_Grade__c != oldMap.get(pc.Id).Distribution_Grade__c
		            	|| pc.Tech_Distribution_Grade_Formula_Text__c == null || pc.Tech_Distribution_Grade_Formula_Text__c == '')) 
		            {			
		            	pc.Tech_Distribution_Grade_Formula_Text__c = '';	
		            	for(String grade :pc.Distribution_Grade__c.split(';'))
		            	{
		            		pc.Tech_Distribution_Grade_Formula_Text__c += grade + ',';
		            	}       
		            	if(pc.Tech_Distribution_Grade_Formula_Text__c.endsWith(','))
		            	{
		            		pc.Tech_Distribution_Grade_Formula_Text__c = pc.Tech_Distribution_Grade_Formula_Text__c.substring(0,pc.Tech_Distribution_Grade_Formula_Text__c.length()-1);
		            	}    	 	
		            }
    			}
    		}	    		
        }
    }
    
    public static void insertFieldsforListViewSecurity(List<Portal_Content__c> newRecords) 
    {
    	//if distribution site / grade is changed
    	List<Portal_Content__c> pcList = new List<Portal_Content__c>();
    	Id AnnouncementRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Portal_Content__c' AND DeveloperName = 'Rich_Text'].Id;
    	for(Portal_Content__c pc : newRecords) 
    	{
    		//Announcecement Records
    		if(pc.RecordTypeId == AnnouncementRecordTypeId)
    		{    			
    			//if (Trigger.isInsert)
    			{
    				//Site
    				if(pc.Sub_Category__c != null && pc.Sub_Category__c != '')
    				{
    					pc.Tech_Distribution_Site_Formula_Text__c = '';	
		            	for(String site :pc.Sub_Category__c.split(';'))
		            	{
		            		pc.Tech_Distribution_Site_Formula_Text__c += site + ',';	            		         			
		            	}    
		            	if(pc.Tech_Distribution_Site_Formula_Text__c.endsWith(','))
		            	{
		            		pc.Tech_Distribution_Site_Formula_Text__c = pc.Tech_Distribution_Site_Formula_Text__c.substring(0,pc.Tech_Distribution_Site_Formula_Text__c.length()-1);
		            	} 
    				}
	    				
	            	//Grade
	            	if(pc.Distribution_Grade__c != null && pc.Distribution_Grade__c != '')
    				{
    					pc.Tech_Distribution_Grade_Formula_Text__c = '';	
		            	for(String grade :pc.Distribution_Grade__c.split(';'))
		            	{
		            		pc.Tech_Distribution_Grade_Formula_Text__c += grade + ',';
		            	}       
		            	if(pc.Tech_Distribution_Grade_Formula_Text__c.endsWith(','))
		            	{
		            		pc.Tech_Distribution_Grade_Formula_Text__c = pc.Tech_Distribution_Grade_Formula_Text__c.substring(0,pc.Tech_Distribution_Grade_Formula_Text__c.length()-1);
		            	}
    				}		            	 
    			}
		        
    		}	    		
        }
    }
    
  	public static void addReviseWord(List<Portal_Content__c> listNewPortalContent, Map<Id,Portal_Content__c> OldMapPortalContent, RecordType rt)
  	{
	 	for(Portal_Content__c pc: listNewPortalContent)
	 	{
	 		if(pc.RecordTypeId == rt.Id)
	 		{
	 			if(pc.Revised_en__c == true && OldMapPortalContent.get(pc.Id).Revised_en__c == false)
		 		{
		 			pc.Title_en__c = '['+System.Label.Revised + '] ' + pc.Title_en__c;
		 		}
		 		if(pc.Revised_zhhk__c == true && OldMapPortalContent.get(pc.Id).Revised_zhhk__c == false)
		 		{
		 			pc.Title_zhhk__c = '['+System.Label.Revised + '] ' + pc.Title_zhhk__c;
		 		}
		 		if(pc.Revised_zhcn__c == true && OldMapPortalContent.get(pc.Id).Revised_zhcn__c == false)
		 		{
		 			pc.Title_zhcn__c = '['+System.Label.Revised + '] ' + pc.Title_zhcn__c;
		 		}
		 		if(pc.Revised_th__c == true && OldMapPortalContent.get(pc.Id).Revised_th__c == false)
		 		{
		 			pc.Title_th__c = '['+System.Label.Revised + '] ' + pc.Title_th__c;
		 		}
		 		if(pc.Revised_vi__c == true && OldMapPortalContent.get(pc.Id).Revised_vi__c == false)
		 		{
		 			pc.Title_vi__c = '['+System.Label.Revised + '] ' + pc.Title_vi__c;
		 		}
		 		if(pc.Revised_id__c == true && OldMapPortalContent.get(pc.Id).Revised_id__c == false)
		 		{
		 			pc.Title_id__c = '['+System.Label.Revised + '] ' + pc.Title_id__c;
		 		}     
	 		}	 			
	 	}     	
 	}

	public static void storeCreatedDateAndLastModdate(List<Portal_Content__c> listNewPortalContent, RecordType rt)
	{
    	for(Portal_Content__c pc :listNewPortalContent)
	    {
	    	if(pc.RecordTypeId == rt.Id)
	 		{
		    	if(pc.Tech_CreatedDate__c != null)
		    	{
		    		pc.Tech_LastUpdateDate__c = pc.LastModifiedDate;
		    	}
		    	else
		    	{        		
		    		pc.Tech_CreatedDate__c = pc.CreatedDate;
		    		pc.Tech_CreatedBy__c = pc.CreatedById;
		    		pc.Tech_Id__c = pc.Id;
		    	}
	 		}
	    }
	}
	
	public static void ensureSubCatIsDefined(List<Portal_Content__c> listNewPortalContent, RecordType rt)
	{
    	for(Portal_Content__c pc :listNewPortalContent)
	    {
	    	if(pc.RecordTypeId == rt.Id)
	 		{
		    	if(pc.Sub_Category__c == null)
		    	{
		    		pc.Sub_Category__c.addError('You must define a Distribution Site!');
		    	}
	 		}
	    }
	}
	*/
}