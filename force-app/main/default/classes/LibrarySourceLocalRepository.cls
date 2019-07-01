/*
    LibrarySourceLocalRepository Class
    Repository of non-fabric source data in the Library app
*/
public class LibrarySourceLocalRepository {
    
    public List<String> conditionCriteria = new List<String>();
    public List<String> selectCriteria = new List<String>();
    
    public Integer pageSize {get;set;} { pageSize = Integer.valueOf(Label.Library_Page_Size); }
    public Integer currentPage {get;set;} { currentPage = 0; }
    public Integer pageOffset {get;set;} {pageOffset = 0;}
    public Integer totalPages {get;set;} { totalPages = 0; }
    public Integer totalRecordCount {get;set;} {totalRecordcount = 0; }
    public boolean fabricCriteriaEntered {get;set;} {fabricCriteriaEntered = false;}
    
    private String recordType;
    
    //get the list of library item for next 10 items
    public List<Library_Item__c> getItemsNextPage() {
        if(this.currentPage != null) {
            this.currentPage = this.currentPage + 1;
            this.pageOffset = this.pageSize * this.currentPage;
        }
        return getItems(null);
    }
    
    //get the list of library item for previous 10 items
    public List<Library_Item__c> getItemsPrevPage() {
        if(this.currentPage != null && this.currentPage > 0) {
            this.currentPage = this.currentPage - 1;
            this.pageOffset = this.pageSize * this.currentPage;
        }
        return getItems(null);
    }
    
    //check if has next 10 items
    public boolean getHasNextPage() {
        boolean result = false;
        if(this.totalRecordCount != null) {
            if(((this.currentPage + 1) * Integer.valueOf(Label.Library_Page_Size)) < this.totalRecordCount) {
                result = true;
            }
        } 
        return result;
    }
    
    //check if has previous 10 items
    public boolean getHasPrevPage() {
        boolean result = false;
        if(this.totalRecordCount != null) {
            if(this.currentPage != 0) {
                result = true;
            }
        }
        return result;
    }
    
    //get the library item list from selected record types and filters
    public List<Library_Item__c> getItems(String selectedRecordType) {
        if((selectedRecordType == Label.Library_RecordType_SamplesTGA || 
                selectedRecordType == Label.Library_RecordType_SamplesPD) && 
                this.fabricCriteriaEntered) {
            return new List<Library_Item__c>();
        }
        List<Library_Item__c> resultList = new List<Library_Item__c>();
        String recordType = '';
        if(selectedRecordType != null && this.recordType != selectedRecordType) {
            this.recordType = selectedRecordType;
            recordType = selectedRecordType;
        } else if(this.recordType != null) {
            recordType = this.recordType;
        }
        String query = '';
        String queryCount = '';
        if(conditionCriteria.isEmpty()) {
            queryCount = 'SELECT count() FROM Library_Item__c WHERE RecordType.DeveloperName = :recordType';
                                         
            query = String.format('SELECT {0} , Id, Name FROM Library_Item__c WHERE RecordType.DeveloperName = :recordType ORDER BY CreatedDate DESC LIMIT {1} OFFSET {2}',
                                         new List<String>{ String.join(selectCriteria, ','), Label.Library_Page_Size, String.valueOf(this.pageOffset) });
        } else {
            queryCount = String.format('SELECT count() FROM Library_Item__c WHERE RecordType.DeveloperName = :recordType and {0}',
                                         new List<String>{ String.join(conditionCriteria, ' AND ') });
                                         
            query = String.format('SELECT {0} , Id, Name FROM Library_Item__c WHERE RecordType.DeveloperName = :recordType and {1} LIMIT {2} OFFSET {3}',
                                         new List<String>{ String.join(selectCriteria, ','),  String.join(conditionCriteria, ' AND '), Label.Library_Page_Size, String.valueOf(this.pageOffset) });
        }        
        system.debug(' $$@@ ' +query);
        List<Library_Item__c> itemResultSet = (List<Library_Item__c>)Database.query(query);
        this.totalRecordCount = (Integer) Database.countQuery(queryCount);
        Decimal totalPages = 0;
        if(this.totalRecordCount == 0)
            totalPages = 0;
        else
            totalPages = Decimal.valueOf(this.totalRecordCount / this.pageSize);
        
        this.totalPages = Integer.valueOf(totalPages.round(System.RoundingMode.UP));
        
        if(itemResultSet != null && !itemResultSet.isEmpty()) {
            resultList = itemResultSet;
        }
        return resultList;
    }
    
    //set searching criteria
    public void setSelectionCriteria(List<String> s) {
        this.selectCriteria = s;
    }
    
    //set the detail of searching criteria
    public void setConditionCriteria(   String selectedRecordType, 
                                        Set<Id> sampleIds, Set<Id> inventoryIdSet, 
                                        SObject sObjItem, 
                                        List<Schema.FieldSetMember> fieldSet,
                                        Map<String, LibraryNumberWrapper> numberWrapperMap,
                                        Map<String, MultiSelectWrapper> multiSelectWrapperMap,
                                        Map<String, LibraryDateWrapper> libraryDateWrapperMap) {
                                            
        List<String> selectConditions = new List<String>();
        
        String limitedMasterIds = '';
        if(inventoryIdSet != null) {
            for(Id masterId : inventoryIdSet) {
                limitedMasterIds = limitedMasterIds + '\'' + masterId + '\','; 
            }
            if(limitedMasterIds.contains(',')) {
                limitedMasterIds = limitedMasterIds.substring(0, limitedMasterIds.length() - 1);
            }
        }
        
        /*
            NickWu added for created Date searching for Book & Warehouse
        */      
        if(sObjItem.get('Created_Date__c')!=null && (selectedRecordType==Label.Library_RecordType_Book || selectedRecordType ==Label.Library_RecordType_Warehouse)){
        
            Date cDate = Date.valueOf(sObjItem.get('Created_Date__c'));          
            selectConditions.add('DAY_ONLY(CreatedDate) = ' + Datetime.newInstance(cDate , Time.newInstance(0,0,0,0)).format('yyyy-MM-dd') );
        }
        
        if(sampleIds == null) {
            this.fabricCriteriaEntered = true;
            
        } else if(sampleIds != null && !sampleIds.isEmpty()) {
            for(Id masterId : sampleIds) {
                limitedMasterIds = limitedMasterIds + '\'' + masterId + '\','; 
            }
            
            if(limitedMasterIds.contains(',')) {
                limitedMasterIds = limitedMasterIds.substring(0, limitedMasterIds.length() - 1);
            }
        } 
        
        for(Schema.FieldSetMember f : fieldSet)  {

            if( (sObjItem.get(f.getFieldPath()) != null && sObjItem.get(f.getFieldPath()) != '') || 
                    f.getType() == DisplayType.Double || 
                    (multiSelectWrapperMap.get(f.getFieldPath()) != null)) {
                if(f.getType() == DisplayType.String || f.getType() == DisplayType.TextArea || f.getType() == DisplayType.Email || f.getType() == DisplayType.Phone || f.getType() == DisplayType.URL) {
                    selectConditions.add( ' ' + f.getFieldPath() + ' like \'%' + sObjItem.get(f.getFieldPath()) + '%\'');             
                } else if (f.getType() == DisplayType.Boolean) {
                    selectConditions.add( ' ' + f.getFieldPath() + ' = ' + sObjItem.get(f.getFieldPath()) + '');                    
                } else if(f.getType() == DisplayType.Reference) {
                    selectConditions.add( ' ' + f.getFieldPath() + ' = \'' + sObjItem.get(f.getFieldPath()) + '\'');                    
                } else if(f.getType() == DisplayType.Double) {
                    // First get the min and max values
                    if(numberWrapperMap.get(f.getFieldPath()) != null) {

                        LibraryNumberWrapper lnw = numberWrapperMap.get(f.getFieldPath());
                        Double min = lnw.min;
                        Double max = lnw.max;
                        if((min == null || min == 0) && (max != null && max != 0)) {
                            selectConditions.add( ' ' + f.getFieldPath() + ' <= ' + max + ' ');
                        } else if((min != null && min != 0) && (max == null || max == 0)) {
                            selectConditions.add( ' ' + f.getFieldPath() + ' >= ' + min + ' ');
                        } else if(min != null && max != null && min != 0 && max != 0) {
                            selectConditions.add( ' ' + f.getFieldPath() + ' >= ' + min + ' ');
                            selectConditions.add( ' ' + f.getFieldPath() + ' <= ' + max + ' ');
                        }
                    }
                } else if(f.getType() == DisplayType.MULTIPICKLIST || f.getType() == DisplayType.Picklist) {
                    if(multiSelectWrapperMap.get(f.getFieldPath()) != null) {
                        String splitSelections = '';
                        List<String> selectedValues = (List<String>) multiSelectWrapperMap.get(f.getFieldPath()).selectedValues;
                        
                        for(String s: selectedValues){
                            splitSelections += s + '\',\'';
                        }
                        
                        splitSelections = '(\'' + splitSelections + '\')';
                        splitSelections = splitSelections.replace(',\'\'','');
                        
                        if(splitSelections != '(\'\')') {
                            selectConditions.add( ' ' + f.getFieldPath() + (f.getType() == DisplayType.MULTIPICKLIST?' INCLUDES ': ' IN ') + splitSelections + ' ' );
                        }
                    }
                } else if(f.getType() == DisplayType.Datetime) {
                    LibraryDateWrapper dateWrapper = libraryDateWrapperMap.get(f.getFieldPath());
                    Date minDate = dateWrapper.proxy.Tech_Start_Date_Proxy__c;
                    Date maxDate = dateWrapper.proxy.Tech_End_Date_Proxy__c;
                    
                    if(minDate != null && maxDate != null) {
                        selectConditions.add( ' ' + f.getFieldPath() + ' >= ' + Datetime.newInstance(minDate, Time.newInstance(0,0,0,0)).format('yyyy-dd-MM') + ' ');
                        selectConditions.add( ' ' + f.getFieldPath() + ' <= ' + Datetime.newInstance(maxDate, Time.newInstance(0,0,0,0)).format('yyyy-dd-MM') + ' ');
                    }
                }
            }
        }
        
        if(limitedMasterIds != null && limitedMasterIds != '') {
            selectConditions.add( ' Id IN (' + limitedMasterIds + ') ' );
        }
        
        this.conditionCriteria = selectConditions;
    }
}