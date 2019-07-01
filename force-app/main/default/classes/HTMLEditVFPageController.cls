public without sharing class HTMLEditVFPageController {
    
    public Portal_Content__c objPC  {get;set;}
        
    public String strErrorMessage {get;set;}    
    
    public Boolean bEdit {get;set;}
    
    public Boolean bCreate {get;set;}
    
    public Boolean bClone {get;set;}
    
    public Boolean bShouldRedirect {public get; private set;}
    
    public String redirectUrl {public get; private set;}    
    
    public Boolean bCanDelete {get;set;}
    	    
    User usr = new User();  
    
    String keyPrefix;    
    
    String StrRecordTypeId ='';
    
    public HTMLEditVFPageController(ApexPages.StandardController stdController) {    	
        if(objPC == null) {
        	List<Portal_Content__c> listPC = 
        			[Select Id, Name, Contents__c , CreatedById, LastModifiedById, CreatedDate, LastModifiedDate
					, Owner.Email, LangAlreadySendNotification__c, Owner.Id, Owner.Name
					, RecordType.DeveloperName, RecordType.Name, Description__c, RecordTypeId, System_Setting__c
            		from Portal_Content__c Where Id = :ApexPages.currentPage().getParameters().get('Id') limit 1];
           if(listPC.size()>0) {
           		objPC = listPC.get(0);
           } else {
           		objPC = new Portal_Content__c();
           }
             
        }
        bEdit = ApexPages.currentPage().getParameters().get('Edit') == null ? false : Boolean.ValueOf(ApexPages.currentPage().getParameters().get('Edit'));
        bCreate = ApexPages.currentPage().getParameters().get('Create') == null ? false : Boolean.ValueOf(ApexPages.currentPage().getParameters().get('Create'));
        bClone = ApexPages.currentPage().getParameters().get('Clone') == null ? false : Boolean.ValueOf(ApexPages.currentPage().getParameters().get('Clone'));
        StrRecordTypeId = ApexPages.currentPage().getParameters().get('RecordTypeId') == null ? '': String.ValueOf(ApexPages.currentPage().getParameters().get('RecordTypeId'));
        bEdit = bEdit || bCreate || bClone;
        
        Schema.DescribeSObjectResult sobj = Portal_Content__c.sObjectType.getDescribe();
        bCanDelete = sobj.isDeletable();
        //Init
        
        if(bCreate) {
        	objPC.RecordTypeId = StrRecordTypeId;
        }
        strErrorMessage = '';      
        bShouldRedirect = false;
        redirectUrl='';        
        //Get Current User Info
		usr = SystemUtil.getCurrentUserInfo();
		
		//Get keyPrefix 
		Schema.DescribeSObjectResult r = Portal_Content__c.sObjectType.getDescribe();
		keyPrefix = r.getKeyPrefix();
    }
    	
	//**************************************** Button Action Section ****************************************
    public PageReference edit() {	        
        bEdit = true;
        return null;
    }
    
    public PageReference saveClone() {	    	    	
    	strErrorMessage = '';
        List<Portal_Content__c> list2Update = new List<Portal_Content__c>();
        list2Update.add(objPC);        
        try {
    		update (list2Update);
    		bEdit = false;
    	} catch (DMLException e) {	
    		strErrorMessage = e.getDmlMessage(0);
    	}  
    	return null;
    }
    
    public void save() {	    	    	
    	strErrorMessage = '';
        List<Portal_Content__c> list2Update = new List<Portal_Content__c>();
        list2Update.add(objPC);        
        try {
    		update (list2Update);
    		bEdit = false;
    	} catch (DMLException e) {	
    		strErrorMessage = e.getDmlMessage(0);
    	}
    	if(bCreate) {
			bShouldRedirect = true;
			redirectUrl = '/' + objPC.Id;
    	}		  	
    }
    
    public void saveCreate() {	 
    	strErrorMessage = '';   	    	
    	if(bCreate) {
    		try {
	    		insert objPC;
	    		bEdit = false;
	    		bShouldRedirect = true;
				redirectUrl = '/' + objPC.Id;
	    	} catch (DMLException e) {	
	    		strErrorMessage = e.getDmlMessage(0);
	    	}
    	}	
    }
    
    public PageReference cancel() {	
    	strErrorMessage= '';
        if(bCreate || bClone) {
        	bShouldRedirect = true;
    		redirectUrl = '/'+ keyPrefix + '/o';
	        return null;
        } else {
        	bEdit = false;
        }
        
		PageReference pageRef = new PageReference('/apex/HTMLEditVFPage?id=' + objPC.Id + '&inline=1&edit=false');
        pageRef.setRedirect(true);
        return pageRef;
    }    
    
    public void deleteRecord() {	    	
    	bShouldRedirect = true;
    	redirectUrl = '/'+ keyPrefix + '/o';
    	delete objPC;
    }
    
    public PageReference shareRecord() {	
    	PageReference PageRef = new PageReference('/p/share/CustomObjectSharingDetail?parentId=' + objPC.Id);
        return PageRef;
    }
    
    public PageReference cloneRecord() {
        // Record being cloned
        Portal_Content__c newArticle = objPC;        
        newArticle.Id = null;
        newArticle.Status__c = 'Draft';
        insert newArticle;
        return new PageReference('/'+newArticle.Id + '?edit=true&clone=true');
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