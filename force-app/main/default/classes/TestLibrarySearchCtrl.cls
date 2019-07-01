/**
 * Test class of LibrarySearchCtrl
 */
@isTest
private class TestLibrarySearchCtrl {

    static testMethod void myUnitTest() {
        
        LibrarySearchCtrl lsc = new LibrarySearchCtrl();
        lsc.selectedRecordType = Label.Library_RecordType_Book_Label;
        String selectedRecordType = lsc.selectedRecordType;
        LibrarySourceFabricRepository libSourceFabricRepo = lsc.libSourceFabricRepo;
        LibrarySourceLocalRepository libSourceLocalRepo = lsc.libSourceLocalRepo;
        Boolean isShowRecentAddedBooks = lsc.isShowRecentAddedBooks;
        
        String addedMsg = LibrarySearchCtrl.addedMsg ='abc';
        String existedMsg = LibrarySearchCtrl.existedMsg = '123';
        
        String getLibraryCart= LibrarySearchCtrl.getLibraryCart();
        Integer getLibraryCartNum= LibrarySearchCtrl.getLibraryCartNum();
        boolean isMobile = lsc.getIsMobile();
        lsc.setIsMobile(true);
        PageReference p = lsc.jsSetIsMobile();
        
        boolean isTGAUser = lsc.isTGAUser;
        boolean isBurberryUser = lsc.isBurberryUser;
        
        lsc.selectedRecordType = Label.Library_RecordType_Fabric;
        List<Schema.FieldSetMember> getFieldSet = lsc.getFieldSet('Library_Item__c', false);
        getFieldSet = lsc.getFieldSet('Library_Item__c', true);
        getFieldSet = lsc.getFieldSet('Library_Inventory__c', false);
        getFieldSet = lsc.getFieldSet('Library_Inventory__c', true);
        
        lsc.selectedRecordType = Label.Library_select;
        getFieldSet = lsc.getFieldSet('Library_Item__c', false);
        
        lsc.selectedRecordType = 'Book123';
        getFieldSet = lsc.getFieldSet('Library_Item__c', false);
        getFieldSet = lsc.getFieldSet('Library_Item__c', true);
        getFieldSet = lsc.getFieldSet('Library_Inventory__c', false);
        getFieldSet = lsc.getFieldSet('Library_Inventory__c', true);
        
        lsc.selectedRecordType = Label.Library_RecordType_Book;
        List<Schema.FieldSetMember> getFieldSetMaster = lsc.getFieldSetMaster();
        List<Schema.FieldSetMember> getFieldSetInventory = lsc.getFieldSetInventory();
        List<Schema.FieldSetMember> getFieldSetSamplesFabric = lsc.getFieldSetSamplesFabric();
        List<Schema.FieldSetMember> getFieldResultSet = lsc.getFieldResultSet('Library_Item__c');
        getFieldResultSet = lsc.getFieldResultSet('Library_Inventory__c');
        
        lsc.selectedRecordType = Label.Library_select;
        getFieldResultSet = lsc.getFieldResultSet('Library_Inventory__c');
        List<Schema.FieldSetMember> getFieldSearchResultSet = lsc.getFieldSearchResultSet();
        
        lsc.selectedRecordType = Label.Library_RecordType_Book;
        getFieldSearchResultSet = lsc.getFieldSearchResultSet();
        List<Schema.FieldSetMember> getFieldResultSetMaster = lsc.getFieldResultSetMaster();
        List<Schema.FieldSetMember> getFieldResultSetInventory = lsc.getFieldResultSetInventory();
        
        //Library_Item__c getLibraryItem = lsc.getLibraryItem();
        //Library_Inventory__c getLibraryInventory = lsc.getLibraryInventory();
        
        List<SelectOption> availableRecordTypes = lsc.availableRecordTypes;
        lsc.resetFilters();
        PageReference clearFilters = lsc.clearFilters();
        //List<String> selectFields = lsc.selectFields;
        
        //Set<Id> searchInventoryItems = lsc.searchInventoryItems();
        //Set<Id> searchFabricItems = lsc.searchFabricItems('Book');
        Map<String, LibraryDateWrapper> dateWrapperMap = new Map<String, LibraryDateWrapper>();
        LibraryDateWrapper dateWrapper = new LibraryDateWrapper(
                    System.today()-1, System.today()
                    );
        dateWrapperMap.put('CreatedDate',dateWrapper);
        lsc.sow.dateWrapperMap = dateWrapperMap;
        boolean SearchObjValidation = lsc.SearchObjValidation();
        
        PageReference searchRecord = lsc.searchRecord();
        
        PageReference nextPage = lsc.nextPage();
        PageReference prevPage = lsc.prevPage();
        boolean getIsCategorySelected = lsc.getIsCategorySelected();
        
        PageReference purgeSearchResults = lsc.purgeSearchResults();
        
        Integer libraryOverdueItemCount = lsc.libraryOverdueItemCount;
        String libraryOverdueWarningMessage = lsc.libraryOverdueWarningMessage;
        
        Library_Item__c lItem = LibraryTestDataUtility.insertLibraryItem();
        Library_Inventory__c lInventory = LibraryTestDataUtility.insertBookInventory(lItem);
        
        Library_Item__c lItem2 = LibraryTestDataUtility.insertLibraryItem();
        Library_Inventory__c lInventory2 = LibraryTestDataUtility.insertBookInventory2(lItem2);
        
        String inventoryIds = LibrarySearchCtrl.borrowSelectedAction(lItem.id);
        inventoryIds = LibrarySearchCtrl.borrowSelectedAction(lItem.id+';'+lItem2.id);
        
        lsc.QRCodeNumber = lInventory.serial_Number__c;
        lsc.selectedRecordType = Label.Library_RecordType_Fabric;
        boolean isSearchInventoryItemsFabric = lsc.isSearchInventoryItemsFabric();
        
        
        lItem = lsc.getLibraryItem();
        lInventory = lsc.getLibraryInventory();
        
    }
    
    static testMethod void myUnitTestBook() {
        LibrarySearchCtrl lsc = new LibrarySearchCtrl();
        lsc.selectedRecordType = Label.Library_RecordType_Book;
        
        Library_Item__c bookItem = LibraryTestDataUtility.insertLibItem(Label.Library_RecordType_Book);
        Library_Inventory__c bookInventory = LibraryTestDataUtility.insertBookInventory(bookItem);
        
        List<SelectOption> availableRecordTypes = lsc.availableRecordTypes;
        lsc.sow.obj =bookItem;
        lsc.selectedRecordType=null;
        availableRecordTypes = lsc.availableRecordTypes;
        
        // bookItem = LibraryTestDataUtility.insertLibItem(Label.Library_RecordType_Fabric);
        // bookInventory = LibraryTestDataUtility.insertBookInventory(bookItem);
        // lsc.selectedRecordType=null;
        // availableRecordTypes = lsc.availableRecordTypes;
        
    }
    
    static testMethod void myUnitTestSampleTGA() {
        
        LibrarySearchCtrl lsc = new LibrarySearchCtrl();
        lsc.selectedRecordType = Label.Library_RecordType_SamplesTGA;
        Library_Item__c sampleTGAItem = LibraryTestDataUtility.insertLibItem(Label.Library_Item_category_Samples_TGA);
        Library_Inventory__c sampleTGAItemInventory = LibraryTestDataUtility.insertBookInventory(sampleTGAItem);
        
        lsc.QRCodeNumber ='lin' ;
        lsc.libInvSow.obj = sampleTGAItemInventory;
        lsc.sow.fabric =sampleTGAItem;
        lsc.sow.obj =sampleTGAItem;
        lsc.searchInventoryItems();
        
        lsc.sow.dateWrapperMap.put('CreatedDate', new LibraryDateWrapper(system.today(),system.today()));
        lsc.sow.numberWrapperMap.put('Content_Percent__c', new LibraryNumberWrapper(10,50));
        lsc.sow.numberWrapperMap.put('Content_Percent_2__c',new LibraryNumberWrapper(10,50));
        lsc.sow.numberWrapperMap.put('Content_Percent_3__c',new LibraryNumberWrapper(10,50));
        lsc.sow.numberWrapperMap.put('Content_Percent_4__c',new LibraryNumberWrapper(10,50));
        lsc.sow.numberWrapperMap.put('Density_Warp__c',new LibraryNumberWrapper(1,100));
        lsc.sow.numberWrapperMap.put('Density_Weft__c',new LibraryNumberWrapper(1,100));
        
        lsc.sow.multiSelectWrapperMap.put('Weave_Knit_Type_TGA__c',new MultiSelectWrapper());
        lsc.sow.multiSelectWrapperMap.put('Fls_Woven_Type__c',new MultiSelectWrapper());
        lsc.sow.multiSelectWrapperMap.put('Fls_Fabric_Finish__c',new MultiSelectWrapper());
        lsc.sow.multiSelectWrapperMap.put('Fls_Color__c',new MultiSelectWrapper());
        lsc.sow.multiSelectWrapperMap.put('Fls_Pattern__c',new MultiSelectWrapper());
        
        lsc.searchFabricItems('SamplesTGA');
        
        PageReference searchRecord = lsc.searchRecord();
        
        lsc.libSourceLocalRepo.currentPage = -1;
        searchRecord = lsc.nextPage();
        lsc.libSourceLocalRepo.currentPage = 2;
        searchRecord = lsc.prevPage();
        
        lsc.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c = null;
        lsc.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c = system.today();
        Boolean b = lsc.SearchObjValidation();
        lsc.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c = system.today();
        lsc.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c = null;
        b = lsc.SearchObjValidation();
        lsc.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c = system.today()+1;
        lsc.sow.dateWrapperMap.get('CreatedDate').proxy.Tech_Start_Date_Proxy__c = system.today();
        b = lsc.SearchObjValidation();
        
    }
    
    static testMethod void unitTestSamplesPD() {
    	
        LibrarySearchCtrl lsc = new LibrarySearchCtrl();
        Library_Item__c samplesPDItem = LibraryTestDataUtility.insertLibItem('Samples PD');
    }
    
    static testMethod void unitTestWarehouse() {
    	
        LibrarySearchCtrl lsc = new LibrarySearchCtrl();
        Library_Item__c warehouseItem = LibraryTestDataUtility.insertLibItem('Warehouse');
    }
    
    static testMethod void unitTestFabric() {
        
        LibrarySearchCtrl lsc = new LibrarySearchCtrl();
        lsc.selectedRecordType = Label.Library_RecordType_Fabric;
        Library_Item__c fabricItem = LibraryTestDataUtility.insertLibItem('Fabric');
        Library_Inventory__c fabricItemInventory = LibraryTestDataUtility.insertBookInventory(fabricItem);
        
        lsc.sow.fabric =fabricItem;
        lsc.sow.obj =fabricItemInventory;
        
        lsc.sow.dateWrapperMap.put('CreatedDate', new LibraryDateWrapper(system.today(),system.today()));
        lsc.sow.numberWrapperMap.put('Content_Percent__c', new LibraryNumberWrapper(10,50));
        lsc.sow.numberWrapperMap.put('Content_Percent_2__c',new LibraryNumberWrapper(10,50));
        lsc.sow.numberWrapperMap.put('Content_Percent_3__c',new LibraryNumberWrapper(10,50));
        lsc.sow.numberWrapperMap.put('Content_Percent_4__c',new LibraryNumberWrapper(10,50));
        lsc.sow.numberWrapperMap.put('Density_Warp__c',new LibraryNumberWrapper(1,100));
        lsc.sow.numberWrapperMap.put('Density_Weft__c',new LibraryNumberWrapper(1,100));
        
        lsc.sow.multiSelectWrapperMap.put('Weave_Knit_Type_TGA__c',new MultiSelectWrapper());
        lsc.sow.multiSelectWrapperMap.put('Fls_Woven_Type__c',new MultiSelectWrapper());
        lsc.sow.multiSelectWrapperMap.put('Fls_Fabric_Finish__c',new MultiSelectWrapper());
        lsc.sow.multiSelectWrapperMap.put('Fls_Color__c',new MultiSelectWrapper());
        lsc.sow.multiSelectWrapperMap.put('Fls_Pattern__c',new MultiSelectWrapper());
        
        PageReference searchRecord = lsc.searchRecord();
        searchRecord = lsc.nextPage();
        searchRecord = lsc.prevPage();
        
        lsc.libSourceFabricRepo.currentPage = -1;
        searchRecord = lsc.nextPage();
        lsc.libSourceFabricRepo.currentPage = 2;
        searchRecord = lsc.prevPage();
        
        lsc.libSourceFabricRepo = null;
        searchRecord = lsc.nextPage();
        searchRecord = lsc.prevPage();
    }
    
}