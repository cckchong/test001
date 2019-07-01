public with sharing class PortalContentOverrideNewButtonController {

	public String prmStr {get;set;}
	
	public boolean bError {get;set;}
	
	string strURLDomain = URL.getSalesforceBaseUrl().toExternalForm(); 
	
    string strURL = '';   
    
    public PortalContentOverrideNewButtonController(ApexPages.StandardController controller) {    
        prmStr = system.currentPageReference().getParameters().get('RecordType');
        bError = false;
    }
    
    public PageReference onLoad() {    	
    	Schema.DescribeSObjectResult r = Portal_Content__c.sObjectType.getDescribe();
		String keyPrefix = r.getKeyPrefix();
		List<RecordType> rt = new List<RecordType>();
		if(prmStr != null && prmStr != '') {
			rt = [Select Id, Name, DeveloperName From RecordType Where Id = :prmStr];
		} else {
			List<String> availableRecordTypes = GetAvailableRecordTypeNamesForSObject(Portal_Content__c.SObjectType);
			rt = [Select Id, Name, DeveloperName From RecordType Where SObjectType = 'Portal_Content__c' And Name in :availableRecordTypes limit 1];
			if(rt.size()>0) {
				prmStr = rt.get(0).Id;
			}
		}
    	if(rt.size()>0) {
    		if(rt.get(0).DeveloperName == 'Rich_Text') {
    			strURL = '/apex/ACGArticleEditVFPage?Create=true&RecordTypeId='+prmStr;
    		} else if(rt.get(0).DeveloperName == 'HTML') {
    			strURL = '/apex/HTMLEditVFPage?Create=true&RecordTypeId='+prmStr;    			
	        } else {
	            strURL = strURLDomain + '/'+ keyPrefix + '/e?retURL='+ keyPrefix + '&RecordType='+prmStr+'&nooverride=1';
	        }
    	} else {    		
    		return null;
    	}
        PageReference PageRef = new PageReference(strURL);
        PageRef.setRedirect(true);         
        return PageRef;              
    }
    
    public static List<String> GetAvailableRecordTypeNamesForSObject(Schema.SObjectType objType) {
	    List<String> names = new List<String>();
	    List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
	    // If there are 2 or more RecordTypes...
	    if (infos.size() > 1) {
	        for (RecordTypeInfo i : infos) {
	           if (i.isAvailable() 
	           // Ignore the Master Record Type, whose Id always ends with 'AAA'.
	           // We check the Id because Name can change depending on the user's language.
	            && !String.valueOf(i.getRecordTypeId()).endsWith('AAA'))
	                names.add(i.getName());
	        }
	    } 
	    // Otherwise there's just the Master record type,
	    // so add it in, since it MUST always be available
	    else {
	    	names.add(infos[0].getName());
	    }
	    return names;
	}
}