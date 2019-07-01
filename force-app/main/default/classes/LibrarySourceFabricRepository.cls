/**
 * Repository for Fabric source data in the Library app
 * 
 * @author Andrew Ng
 * @date 29/10/2014
 */
public class LibrarySourceFabricRepository {

    /*
        NickWu Added on 12 Dec 2014
        Pagination for Fabric items
    */
    //define page stuffs
    public Integer pageSize {get;set;} { pageSize = Integer.valueOf(Label.Library_Page_Size); }
    public Integer currentPage {get;set;} { currentPage = 1; }
    public Integer totalPages {get;set;} { totalPages = 0; }
    public Integer totalRecordCount {get;set;} {totalRecordcount = 0; }
    private SearchSObjectWrapper sow;

    /**
     * Get the items based on search criteria
     * @param keyToValueListMap the key is the search criteria name, where the list stores the optional values to search against
     * @return a list of Library Item SObjects
     */
    public Map<String, List<Library_Item__c>> getItems(Map<String, List<String>> keyToFabricIds) {
        Map<String, List<Library_Item__c>> resultMap = new Map<String, List<Library_Item__c>>();
        
        
        LibraryFlsFabricSearchWs.fabricSearchPort ws = new LibraryFlsFabricSearchWs.fabricSearchPort();
        ws.timeout_x = Integer.valueOf(Label.Tech_Api_Timeout_Millis);
        
        LibraryFlsFabricSearchWs.fabricSearchRequest fs = new LibraryFlsFabricSearchWs.fabricSearchRequest();
        fs.model = new LibraryFlsfabricSearchWs.fabricSearchModel();

        fs.userId = getFlsUserId();
        fs.pageSize = 1;
        fs.pageNo = 1;
        List<Library_Item__c> upsertList = new List<Library_Item__c>();
        
        for(String key : keyToFabricIds.keyset()) {
            List<String> fabricIds = keyToFabricIds.get(key);
            List<Library_Item__c> libItems = new List<Library_Item__c>();
            //Per Sample
            
            for(String s : fabricIds) {
                if(s != null && s != '') {
                    fs.fabricName = s;
                    // Warning this is not bulkified
                    LibraryFlsFabricSearchWs.fabricSearchResponse[] fsrList = ws.searchFabric(fs);
                    
                    if(fsrList != null && !fsrList.isEmpty()) {
                    	libItems.addall(getItemsFromResponseResultsNoCommit(fsrList[0].results));
                    }
                }
            }
            upsertList.addall(libItems);
            resultMap.put(key, libItems);
        }
        upsert upsertList Fabric_External_Id__c;
        return resultMap;
    }
    
    public List<Library_Item__c> getItemsFromResponseResultsNoCommit(LibraryFlsFabricSearchWs.fabricSearchResult[] results) {
        List<Library_Item__c> resultList = new List<Library_Item__c>();
        resultList = LibraryFlsFabricModelUtil.mapFlsResultsToItemsNoCommit(results);
        return resultList;
    }
    
    /**
     * Get the items based on search criteria
     * @param keyToValueListMap the key is the search criteria name, where the list stores the optional values to search against
     * @return a list of Library Item SObjects
     */
    public List<Library_Item__c> getItems(SearchSObjectWrapper sow) {
        this.sow = sow;
        List<Library_Item__c> resultList = new List<Library_Item__c>();
        LibraryFlsFabricSearchWs.fabricSearchPort ws = new LibraryFlsFabricSearchWs.fabricSearchPort();
        ws.timeout_x = Integer.valueOf(Label.Tech_Api_Timeout_Millis);
        
        LibraryFlsFabricSearchWs.fabricSearchRequest fs = new LibraryFlsFabricSearchWs.fabricSearchRequest();
        
        if(sow.obj.get('Fabric_ID__c') != null && sow.obj.get('Fabric_ID__c') != '') {
            fs.fabricName = (String) sow.obj.get('Fabric_ID__c');
        }
        fs.model = this.getFabricSearchModel(sow);
        fs.userId = getFlsUserId();
        fs.pageSize = Integer.valueOf(Label.Library_Page_Size);
        fs.pageNo = 1;
        
        //TODO: colorNo, articleNo, colorRefNo
        LibraryFlsFabricSearchWs.fabricSearchResponse[] fsrList = ws.searchFabric(fs);
        
        if(fsrList != null && !fsrList.isEmpty()) {
        	resultList = getItemsFromResponseResults(fsrList[0].results);
        }
        
        // Re-Query the list so we can get the Inventory items
        resultList = 
            [SELECT Tech_Selected__c, Id, Item_Name__c, Item_Description__c, Fabric_ID__c, Fabric_Type__c,
                        Fls_Material_Type__c, Color_ID_1__c,Fls_Pattern__c,  Total_Available_Quantity__c
                FROM Library_Item__c
                WHERE Id IN: resultList
            ];
        return resultList;
    }
    
    // return a dummy library item list
    public static List<Library_Item__c> getDummyFabricItemFields() {
        List<Library_Item__c> resultList = new List<Library_Item__c>();
        return resultList;
    }
    
    //return the result list from FLS response
    public List<Library_Item__c> getItemsFromResponseResults(LibraryFlsFabricSearchWs.fabricSearchResult[] results) {
        List<Library_Item__c> resultList = new List<Library_Item__c>();
        resultList = LibraryFlsFabricModelUtil.mapFlsResultsToItems(results);
        return resultList;
    }
    
    //return FLS multi picklist values
    private LibraryFlsFabricSearchWs.fabricSearchValue[] getSearchValueFromPicklist(MultiSelectWrapper msw) {
        LibraryFlsFabricSearchWs.fabricSearchValue[] fsvList = new List<LibraryFlsFabricSearchWs.fabricSearchValue>();
        
        if(msw != null) {
            for(String s : msw.selectedValues) {
                LibraryFlsFabricSearchWs.fabricSearchValue fsv = new LibraryFlsFabricSearchWs.fabricSearchValue();
                fsv.id = Long.valueOf(s);
                fsvList.add(fsv);
            }
        }
        if(fsvList.isEmpty()) {
            fsvList = null;
        }
        return fsvList;
    }
    
    //return FLS String values
    private LibraryFlsFabricSearchWs.fabricSearchValue getSingleSearchValueFromPicklist(String value) {
        LibraryFlsFabricSearchWs.fabricSearchValue fsv = new LibraryFlsFabricSearchWs.fabricSearchValue();
        if(value != null && value != '') {
            fsv.id = Long.valueOf(value);
        } else {
            fsv = null;
        }
        return fsv;
    }
    
    //return decimal from library number wrapper 
    private Decimal getDecimalFromNumberWrapper(LibraryNumberWrapper num, boolean isMin) {
        Decimal result = null;
        if(num != null && num.min != null && num.max != null && num.min != 0.0 && num.max != 0.0) {
            if(isMin) {
                result = num.min;
            } else {
                result = num.max;
            }
        }
        return result;
    }
    
    //convert values from FLS to string
    private String getStringFromValue(Object s) {
        String result = null;
        if(s != null && s != '') {
            result = (String) s;
        }
        return result;
    }
        
    /**
     * For picklists, we need to assume that we receive a list of selected values,
     * 
     */
    private LibraryFlsfabricSearchWs.fabricSearchModel getFabricSearchModel(SearchSObjectWrapper sow) {
        LibraryFlsfabricSearchWs.fabricSearchModel fabric = new LibraryFlsfabricSearchWs.fabricSearchModel();
        
        //fabric.beforeDipWeight = false;
        fabric.brandCustomers = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Brand_Customer__c'));
        fabric.colors = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Color__c'));
        
        fabric.contentPercentage1From = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Content_Percent__c'), true);
        fabric.contentPercentage1To = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Content_Percent__c'), false);
        fabric.contentPercentage2From = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Content_Percent_2__c'), true);
        fabric.contentPercentage2To = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Content_Percent_2__c'), false);
        
        fabric.contents1 = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Content__c'));
        fabric.contents2 = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Content_2__c'));
        fabric.otherContents = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Content_3__c'));
        
        fabric.countryOrigin = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Country__c'));
        
        /*
            Modified by nickwu 20141223
            passing dateFrom and dateTo to search model
        */
        // Handle Dates
        if(sow.dateWrapperMap.get('CreatedDate')!=null) {
        
            LibraryDateWrapper dateWrapper = sow.dateWrapperMap.get('CreatedDate');
            
            if(dateWrapper != null ) {
                Date minDate = dateWrapper.proxy.Tech_Start_Date_Proxy__c;
                Date maxDate = dateWrapper.proxy.Tech_End_Date_Proxy__c;
                
                if(minDate != null && maxDate != null) {
                    fabric.createDateFrom = minDate;
                    fabric.createDateTo = maxDate;
                }                
            }
        }

       
        
        fabric.fabricEndUses = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Product_Type__c'));
        fabric.fabricPatterns = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Pattern__c'));

        fabric.fabricType = this.getSingleSearchValueFromPicklist((String) sow.obj.get('Fabric_Type__c'));
        
        fabric.garmentFinishings = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Garment_Finish__c'));
        
        fabric.gauge = this.getStringFromValue(sow.obj.get('Gauge__c'));
        
        /*
        	Nick Wu added for handling fabric items will show for 
        	TGA/PD admin 
        	when
        	1. completeness = true
        	2. status = active
		*/
		Profile pro = new Profile();
        pro = SystemUtil.getCurrentUserProfile();
        
		if(pro.name == Label.Library_Profile_TFEPA ||
		   pro.name == Label.Library_Profile_TFETGAA){
			fabric.isCompleted = 'T';
		}else{
			fabric.isCompleted = this.getStringFromValue(sow.obj.get('Completeness__c'));   //modified by NickWu
		}
        
        fabric.materialFinishings = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Fabric_Finish__c')); //modified by NickWu
        if(this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Material_Type__c')) != null &&
            !this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Material_Type__c')).isEmpty()) {
            fabric.materialType = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Material_Type__c'))[0];
        }
        fabric.pilotFabricRequired = this.getStringFromValue(sow.obj.get('Pilot_Fabric__c'));
        
        fabric.priceFrom = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Quoted_Price__c'), true);
        fabric.priceTo = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Quoted_Price__c'), false);
        
        
        fabric.suppliers = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Supplier__c'));
        
        if(sow.obj.get('Density_Warp__c') != null) {
            fabric.warpDensity = Integer.valueOf(sow.obj.get('Density_Warp__c'));
        }
        if(sow.obj.get('Density_Weft__c') != null) {
            fabric.weftDensity = Integer.valueOf(sow.obj.get('Density_Weft__c'));
        }
        
        fabric.weaveKnitTypes = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Woven_Type__c'));
        
        /** The 4 Yarn Size and Types - Massive need of fixing */
        Map<String, String> valueToKeyMap = new Map<String, String>();
        for(Fls_Search_Params__c p : [SELECT Name, Key__c, Value__c FROM Fls_Search_Params__c WHERE FIELD_NAME__C = 'YARN_TYPE' OR FIELD_NAME__C = 'WEIGHT_UOM' OR FIELD_NAME__C = 'FABRIC_SEASON']) {
            valueToKeyMap.put(p.Value__c, p.Key__c);
        }
        
        fabric.warpYarnSize1 = this.getStringFromValue(sow.obj.get('Warp_Yarn_Size__c'));
        
        if(sow.obj.get('Yarn_Type_Warp__c') != null && sow.obj.get('Yarn_Type_Warp__c') != '') {
            fabric.warpYarnType1 = getSingleSearchValueFromPicklist((String) valueToKeyMap.get((String) sow.obj.get('Yarn_Type_Warp__c')));
        }
        
        if(sow.obj.get('Season__c') != null && sow.obj.get('Season__c') != '') {
            fabric.fabricSeason = getSingleSearchValueFromPicklist((String)valueToKeyMap.get((String)sow.obj.get('Season__c'))); // added by nickwu
        }
        
        fabric.fabricYear = Integer.valueOf(sow.obj.get('Season_Year__c')); // added by nickwu

        fabric.weftYarnSize1 = this.getStringFromValue(sow.obj.get('Weft_Yarn_Size__c'));
        if(sow.obj.get('Yarn_Type_Weft__c') != null && sow.obj.get('Yarn_Type_Weft__c') != '') {
            fabric.weftYarnType1 = getSingleSearchValueFromPicklist((String) valueToKeyMap.get((String) sow.obj.get('Yarn_Type_Weft__c')));
        }     
        
        
        /* 
            Criteria:
            Before Dip
            1. Weight before dip From & To
            2. Weight before dip UOM
            3. Dipping Type
            4. beforeDipWeight
            
            After Dip
            1. Weight after dip From & To
            2. Weight after dip UOM
            3. Dipping Type
            4. beforeDipWeight 
            
        */
        if(getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Weight_Before_Dip__c'), true) != null 
            && getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Weight_Before_Dip__c'), false) != null) {
            
            fabric.weightFrom = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Weight_Before_Dip__c'), true);
            fabric.weightTo = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Weight_Before_Dip__c'), false);        
            fabric.weightUom = getSingleSearchValueFromPicklist((String) valueToKeyMap.get((String) sow.obj.get('Weight_UOM_Before_Dip__c')));
            
             if(sow.obj.get('Dipping__c') != null && sow.obj.get('Dipping__c') == 'Dip') {
	            fabric.dippingType = true;  
	        } else if(sow.obj.get('Dipping__c') != null && sow.obj.get('Dipping__c') == 'Non-Dip') {
	            fabric.dippingType = false;
	        }
            
            fabric.beforeDipWeight = true;
        }
        else if( getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Weight_After_Dip__c'), true) != null 
            && getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Weight_After_Dip__c'), false) != null){
            
            fabric.weightFrom = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Weight_After_Dip__c'), true);
            fabric.weightTo = getDecimalFromNumberWrapper(sow.numberWrapperMap.get('Weight_After_Dip__c'), false);        
            fabric.weightUom = getSingleSearchValueFromPicklist((String) valueToKeyMap.get((String) sow.obj.get('Weight_UOM_After_Dip__c')));
            
            if(sow.obj.get('Dipping__c') != null && sow.obj.get('Dipping__c') == 'Dip') {
	            fabric.dippingType = true;  
	        } else if(sow.obj.get('Dipping__c') != null && sow.obj.get('Dipping__c') == 'Non-Dip') {
	            fabric.dippingType = false;
	        }
            
            fabric.beforeDipWeight = false;
        }else{
        	if(sow.obj.get('Dipping__c') != null && sow.obj.get('Dipping__c') == 'Dip') {
	            fabric.dippingType = true;  
	        } else if(sow.obj.get('Dipping__c') != null && sow.obj.get('Dipping__c') == 'Non-Dip') {
	            fabric.dippingType = false;
	        }
        } 
          
        fabric.yarnDyeingMethods = this.getsearchValueFromPicklist(sow.multiSelectWrapperMap.get('Fls_Dyeing_Method__c'));
        
        
        fabric.dWashRequired = this.getStringFromValue(sow.obj.get('D_Wash__c'));
        
        // 30/01/2015
        if(sow.obj.get('Test_Result__c') != null && this.getStringFromValue(sow.obj.get('Test_Result__c')) == 'Pass') {
            fabric.releaseToSales = 'T';  
        } else if(sow.obj.get('Test_Result__c') != null && this.getStringFromValue(sow.obj.get('Test_Result__c')) == 'Fail') {
            fabric.releaseToSales = 'F';
        }
        // 2014-12-30
        //fabric.releaseToSales = this.getStringFromValue(sow.obj.get('Test_Result__c'));
		
        return fabric;
    }
    
    /*
        NickWu Added on 12 Dec 2014
        Pagination for Fabric items
        
        modified by nickwu on 17 Dec 2014
        
    */
    public List<Library_Item__c> getAllFabricItems(String itemId, Integer cp, SearchSObjectWrapper sow) {
        
        this.sow = sow;
        List<Library_Item__c> resultList = new List<Library_Item__c>();
        LibraryFlsFabricSearchWs.fabricSearchPort ws = new LibraryFlsFabricSearchWs.fabricSearchPort();
        ws.timeout_x = Integer.valueOf(Label.Tech_Api_Timeout_Millis);
        
        LibraryFlsFabricSearchWs.fabricSearchRequest fs = new LibraryFlsFabricSearchWs.fabricSearchRequest();
        
        //added by nicwu for remove all special chars
        if(this.sow.obj.get('Fabric_ID__c') != null && this.sow.obj.get('Fabric_ID__c') != '') {
        	//String regEx  = '[^a-zA-Z0-9]';
        	//.replaceAll(regEx,'')
            fs.fabricName = ((String) this.sow.obj.get('Fabric_ID__c'));
        }
        fs.model = this.getFabricSearchModel(this.sow);
        fs.userId = getFlsUserId();
        fs.pageSize = Integer.valueOf(Label.Library_Page_Size);
        fs.pageNo = cp;
        
        LibraryFlsFabricSearchWs.fabricSearchResponse[] fsrList = ws.searchFabric(fs);
        
        
        if(fsrList!=null && fsrList.size()>0) {
            resultList = getItemsFromResponseResults(fsrList[0].results);
            
            //for QR code number searching
            if(itemId!=null && itemId!=''){
            	for(Integer i=0;i<resultList.size();i++){
            		if(resultList[i].id!=itemId){
            			resultList.remove(i);
            		}
            	}
            }
            totalRecordCount = Integer.valueOf(fsrList[0].totalResultCount); 
            Decimal totalPages = Decimal.valueOf(totalRecordCount / this.pageSize);
            this.totalPages = Integer.valueOf(totalPages.round(System.RoundingMode.UP));
        }else{
            totalRecordCount=0;
            this.totalPages=0;
        }
        	return resultList;
    }
    
    //check if has next page
    public boolean getHasNextPage() {
      boolean result = false;
        if(this.totalRecordCount != null) {
            if(((this.currentPage) * Integer.valueOf(Label.Library_Page_Size)) < this.totalRecordCount) {
                result = true;
            }
        }   
        return result;
    }
    
    //check if has prev page
    public boolean getHasPrevPage() {
      boolean result = false;
        if(this.totalRecordCount != null) {            
            if(this.currentPage > 1) {
                result = true;
            }
        }
        return result;
    }
    
    //get the library item list of next 10 items
    public List<Library_Item__c> getItemsNextPage(String itemId, SearchSObjectWrapper sow) {        
        if(this.currentPage != null && getHasNextPage()) {
            this.currentPage = this.currentPage + 1;
        }
        return getAllFabricItems(itemId, this.currentPage, sow);
    }
    
    //get the library item list of prev 10 items
    public List<Library_Item__c> getItemsPrevPage(String itemId, SearchSObjectWrapper sow) {        
        if(this.currentPage != null && this.currentPage > 0  &&  getHasPrevPage()) {
            this.currentPage = this.currentPage - 1;
        }      
      return getAllFabricItems(itemId, this.currentPage, sow);
    }
    
    //get FLS user id
    //2015-01-08
    public String getFlsUserId() {
        String userId = '';
        List<User> usr = [Select Id, sAMAccountName__c From User Where Id = :UserInfo.getuserId() limit 1];
        if(!usr.isEmpty()) {
            userId = usr[0].sAMAccountName__c;
        }
        return userId;
    }
    
}