/**
 * Scheduled job to load the FLS selection values into Library
 * @author Andrew Ng
 * @date 05/11/2014
 **/
public class LibraryFlsSearchValuesScheduledJob implements Schedulable {
	
    /**
     * Enums defined by FLS
     */
    private enum FLS_FIELD {
        FABRIC_TYPE, 
        COLOR, 
        PATTERN,
        PRODUCT_TYPE,
        WOVEN_TYPE, 
        KNIT_TYPE, 
        YARN_TYPE, 
        CONTENT, 
        GARMENT_FINISH,
        FABRIC_FINISH,
        DYEING_METHOD,
        COUNTRY,
        MATERIAL_TYPE,
        BRAND_CUSTOMER,
        FABRIC_SEASON,
        WEIGHT_UOM,
        SUPPLIER
    }
    
    //get all FLS picklist values from FLS, and then upsert to Fls_Search_Params__c custom settings
    @future(callout=true)
    public static void getFabricSearchValues() {
        List<Fls_Search_Params__c> fspToDelete = [SELECT Id FROM Fls_Search_Params__c];
        
        List<FLS_FIELD> fieldValues = FLS_Field.values();
        Map<String, LibraryFlsSearchValuesWs.getSearchValuesResponse> categoryToResponsesMap = new Map<String, LibraryFlsSearchValuesWs.getSearchValuesResponse>();
        List<Fls_Search_Params__c> params = new List<Fls_Search_Params__c>();
        
        LibraryFlsSearchValuesWs.getSearchValuesPort gsvp = new LibraryFlsSearchValuesWs.getSearchValuesPort();
        gsvp.timeout_x = Integer.valueOf(Label.Tech_Api_Timeout_Millis);
        LibraryFlsSearchValuesWs.getSearchValuesRequest svr = new LibraryFlsSearchValuesWs.getSearchValuesRequest();
        
        for(FLS_FIELD field : fieldValues) {
            svr.category = field.name();
            
            LibraryFlsSearchValuesWs.getSearchValuesResponse resp = gsvp.getFabricSearchValues(svr);
            
            categoryToResponsesMap.put(field.name(), resp);
        }
        
        // Loop through the responses
        
        for(String key : categoryToResponsesMap.keySet()) {
            
            if(categoryToResponsesMap.get(key) != null && categoryToResponsesMap.get(key).values != null) {
                for(LibraryFlsSearchValuesWs.fabricSearchValue fsv : categoryToResponsesMap.get(key).values) {
                    if(fsv.Id != null && fsv.Id != -1) {
                        Fls_Search_Params__c fsp = new Fls_Search_Params__c();
                        fsp.Name = key + fsv.Id;
                        fsp.Key__c = String.valueOf(fsv.Id);
                        fsp.Field_Name__c = key;
                        
                        if((key == 'WOVEN_TYPE' || key == 'KNIT_TYPE') && fsv.group_x != null && fsv.group_x != '') {
                            fsp.Value__c = fsv.group_x;
                        } else {
                            fsp.Value__c = fsv.name;
                        }
                        
                        params.add(fsp);
                    }
                }
        	}
        }
        
        if(!ErrorUtils.isEmpty(fspToDelete)) {
            delete fspToDelete;
        }
        
        upsert params;

    }
    
    /**
     * Execute the scheduled job
     */
    public void execute(SchedulableContext sc) {

		//this.getFabricSearchValues();
		getFabricSearchValues();
    }
}