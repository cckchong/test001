/*
    LibraryItemOverwriteNewCtrl Class
    
    @Author: AN, WG, NW
    @Object: Library_Item__c
    @Description: Overwrite the standard new button for creating library item
*/
public with sharing class LibraryItemOverwriteNewCtrl{

    String recordTypeId;
    public boolean isLoad{get;set;}

    /*
        Added by NickWu
        To check the current login user whether in Burberry achrive profile
    */
    public boolean isBurberryUser{get;set;}{
        isBurberryUser = false;
        String str = Label.Library_Check_BurberryUser;
        Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and name like :str limit 1]);
        isBurberryUser = (pMap.size()>0) ? true:false;
    }

    /*
        Added by NickWu
        To check the current login user whether in Admin profile
    */
    public boolean isAdmin{get;set;}{
        isAdmin = false;
        String str = Label.Library_Profile_SA;
        Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and (name =:str or name =:Label.Library_Profile_TFELA) limit 1]);
        isAdmin = (pMap.size()>0) ? true:false;
    }

    /*
        Added by NickWu
        To check the current login user whether in Admin profile
    */
    public boolean isWarehouseStandardUser{get;set;}{
        isWarehouseStandardUser = false;
        String str = Label.Library_Profile_TFEWSU;
        Map<ID,profile> pMap = new Map<ID,profile>([select Name from profile where id =: UserInfo.getProfileId() and name =:str limit 1]);
        isWarehouseStandardUser = (pMap.size()>0) ? true:false;
    }

    public String selectedRecordType{get;set;}{
    	// if(selectedRecordType!=null && selectedRecordType==Label.Library_RecordType_Book_Label){
    	// 	selectedRecordType=Label.Library_RecordType_Book;
    	// }

        if(isBurberryUser || isAdmin){
            this.selectedRecordType = Label.Library_RecordType_BurberryArchive_Label;
        }else if(isWarehouseStandardUser){
            this.selectedRecordType = Label.Library_RecordType_Warehouse;
        }else{
            this.selectedRecordType = Label.Library_RecordType_Fabric;
        }

    }
    
    public boolean isSizeEmpty{get;set;}{
    	isSizeEmpty = true;
    	Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{'Library_Item__c'});
        Schema.DescribeSObjectResult schemaResults = descResult[0];
    	for(Schema.RecordTypeInfo sr : schemaResults.getRecordTypeInfos()){
            if(sr.isAvailable() && sr.getName()!= Label.Library_RecordType_Master ){
                isSizeEmpty = false;
            }
        }
    }
    
    public boolean isSizeOne{get;set;}{
    	isSizeOne = false;
    	Integer inCount = 0;
    	Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{'Library_Item__c'});
        Schema.DescribeSObjectResult schemaResults = descResult[0];
    	for(Schema.RecordTypeInfo sr : schemaResults.getRecordTypeInfos()){
            if(sr.isAvailable() && sr.getName()!= Label.Library_RecordType_Master ){
                inCount++;
            }
        }
        if(inCount==1){
        	isSizeOne = true;
        }
    }
    
    public boolean isSalesforceOne{get;set;}{isSalesforceOne = SystemUtil.isMobileDevice();}
    
    //check if there are available record types for the current user, return false, else return true
    public boolean isRedirect{get;set;}{
        if(SystemUtil.availRecordTypes(Label.Library_Item_ObjectName,true)!=null && 
           !SystemUtil.availRecordTypes(Label.Library_Item_ObjectName,true).isEmpty())
           isRedirect = true;
        else
            isRedirect = false;
    }
	
	//get library item record prefix
    public String preFix{get;set;}{
        preFix = '';
        Schema.DescribeSObjectResult r = Library_Item__c.sObjectType.getDescribe();
        preFix  = r.getKeyPrefix();
    }
	
	//Constructor to get the record Id from param recordType
    public LibraryItemOverwriteNewCtrl(ApexPages.StandardController controller) {
        recordTypeId = ApexPages.currentPage().getParameters().get(Label.Library_RecordTypeName);
    }
    
    // record type list for choosing it to create new library items
    public List<SelectOption> availableRecordTypes{get;set;}{
 
         availableRecordTypes = new List<SelectOption>();
        
            
        try{
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{Label.Library_Item_ObjectName});
            Schema.DescribeSObjectResult schemaResults = descResult[0];
            List<Schema.RecordTypeInfo> recordTypeInfos = schemaResults.getRecordTypeInfos();
            
            Map<String, Schema.RecordTypeInfo> mapRecordTypeInfos = schemaResults.getRecordTypeInfosByName();
            
            /*
                Modified by Nick Wu 29 Apr 2015
                For disable Book
            */
            //Check record types availability
            for(Schema.RecordTypeInfo rti: mapRecordTypeInfos.values()) {
                if(rti.getName() != Label.Library_RecordType_Master && rti.getName() != Label.Library_RecordType_Book && rti.isAvailable()) {
                    if(rti.getName() == Label.Library_RecordType_Book){
                        String tempStr = Label.Library_RecordType_Book_Label;
                        availableRecordTypes.add( new SelectOption(rti.getRecordTypeId(), tempStr));
                    }else               
                        availableRecordTypes.add( new SelectOption(rti.getRecordTypeId(), rti.getName()));
                }
            }
            availableRecordTypes.sort();
        }catch(Exception ex){
        }
        
        SelectOptionUtil.doSort(availableRecordTypes,SelectOptionUtil.FieldToSort.Label);
        if(availableRecordTypes==null)
            availableRecordTypes = new List<SelectOption>();
    }
    
    /*
        for those profiles which can only create one type of records, redirect them to the create page
        for those profiles which did not have create privilege, popup err msg
    */
    public PageReference onload(){
        
        PageReference p;
        String returnURL ='';
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{'Library_Item__c'});
        Schema.DescribeSObjectResult schemaResults = descResult[0];
        List<String> avaiList = new List<String>();
        List<Schema.RecordTypeInfo> recordTypeInfos = schemaResults.getRecordTypeInfos();
        
        for(Schema.RecordTypeInfo sr : schemaResults.getRecordTypeInfos()){
            if(sr.isAvailable() && sr.getName()!= Label.Library_RecordType_Master ){
                avaiList.add(sr.getRecordTypeId());
            }
        }
                
        if (avaiList.isEmpty()){
            if(!isSalesforceOne){
            	returnURL = Label.Library_JavaScriptName+ Label.Library_Mobile_Alert+'(\''+Label.Library_not_allowed_createRecords+'\');'+Label.Library_window_location_href+'=\'/' + preFix +'/o\'';
            	p = new PageReference(returnURL);
            	return p;
            }
            return null;
        }else if(avaiList.size() == 1){

            returnURL = '/' + preFix + '/e?retURL=/' + preFix + '/o&RecordType='+ avaiList[0] +'&nooverride=1';
            
            if(!isSalesforceOne){
                p = new PageReference(returnURL);
                return p;
            }
            return null;
        }else
            return null;
    }
    
    //redirect to the standard create library item page
    public PageReference GoBtn(){
        
        String url=Label.Library_JavaScriptName;
        PageReference pr;
        
        if(isSalesforceOne){
            if(!isRedirect){
                url +=  Label.Library_Mobile_Alert+ '(\''+Label.Library_item_creation_msg+'\');';
                url += Label.Library_Mobile_NavigateURL + '(\'/'+preFix+'/o\');';
            }else{
                url += Label.Library_Mobile_CreateRecord + '(\''+Label.Library_Item_ObjectName+'\',\''+ selectedRecordType +'\');';
            }
            pr = new PageReference(url);
        }else{
            Schema.DescribeSObjectResult r = Library_Item__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            List<String> tempList = SystemUtil.availRecordTypes(Label.Library_Item_ObjectName,false);
            if(tempList==null && tempList.isEmpty()){
                return new PageReference(Label.Library_JavaScriptName+ Label.Library_Mobile_Alert+'(\''+Label.Library_item_creation_msg+'\');'+Label.Library_window_location_href+'=\'/' + keyPrefix +'/o\'');
            }else{
                if(tempList.size()==1)
                    recordTypeId = tempList[0];
                String returnURL = '/' + keyPrefix + '/e?retURL=/' + keyPrefix + '/o&RecordType='+ selectedRecordType +'&nooverride=1';
                PageReference p = new PageReference(returnURL );
                return p;
            }
        }
        return pr;
    }
    
    //return back to library item view
    public PageReference CancelBtn(){
        String url = Label.Library_JavaScriptName;
        if(isSalesforceOne)
            url += Label.Library_Mobile_NavigateURL +'(\'/'+preFix+'/o\');';
        else
            url += Label.Library_window_location_href+'=\'/'+preFix+'/o\' ';
        PageReference pr = new PageReference(url);
        return pr;
    }
}