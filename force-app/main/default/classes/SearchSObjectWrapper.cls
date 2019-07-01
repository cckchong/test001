/**
 * Used for wrapping an SObject when building custom
 * search pages.
 */
public class SearchSObjectWrapper {
    public SObject obj {get;set;}
    //public Library_Item__c fabric {get;set;} //WG 20141222 Change fabric to SObject
    public SObject fabric {get;set;}
    
    /** Wrappers provide additional data structures to render non-default UI controls */
    
    /** Render a min and max range */
    public Map<String, LibraryNumberWrapper> numberWrapperMap {get;set;}
    
    /** Render a multiselect picklist*/
    public Map<String, MultiSelectWrapper> multiSelectWrapperMap {get;set;}
    
    /** Render a date range */
    public Map<String, LibraryDateWrapper> dateWrapperMap {get;set;}
    
    /**
     * Constructor
     */
    public SearchSObjectWrapper(String SObjectType) {
        this.numberWrapperMap = new Map<String, LibraryNumberWrapper>();
        this.multiSelectWrapperMap = new Map<String, MultiSelectWrapper>();
        this.dateWrapperMap = new Map<String, LibraryDateWrapper>();
        
        this.fabric = new Library_Item__c();
        
        if(SObjectType == 'Library_Item__c') {
            this.obj = new Library_Item__c();
        } else if(SObjectType == 'Library_Inventory__c') {
            this.obj = new Library_Inventory__c();
        }
    }
    
    public void clear() {

    }
    
    
    public Library_Item__c getLibraryItem() {
    	return (Library_Item__c) this.obj;
    }

}