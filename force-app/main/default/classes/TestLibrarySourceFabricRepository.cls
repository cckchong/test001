@isTest
private class TestLibrarySourceFabricRepository {
    
    static testMethod void testSampleFabricGetItems() {
        
        LibrarySourceFabricRepository fr = new LibrarySourceFabricRepository();
        Map<String, List<String>> keyToFabricIds = new Map<String, List<String>>();
        
        List<String> fabricIds = new List<String>();
        fabricIds.add('W000000123');
        fabricIds.add('W000000124');
        
        keyToFabricIds.put('VeryUniqueKey', fabricIds);
        
        Map<String, List<Library_Item__c>> resultMap = fr.getItems(keyToFabricIds);
        
        System.assertEquals(resultMap.get('VeryUniqueKey').isEmpty(), true);
    }
    
    static SearchSObjectWrapper prepareSow(boolean afterDip) {
        SearchSObjectWrapper sow = new SearchSObjectWrapper('Library_Item__c');
        sow.obj.put('Fabric_ID__c', 'W000001');
        sow.obj.put('Density_Warp__c', 123);
        sow.obj.put('Density_Weft__c', 123);
        sow.obj.put('Yarn_Type_Warp__c', '123');
        sow.obj.put('Season__c', '123');
        sow.obj.put('Yarn_Type_Weft__c', '123');
        
        LibraryDateWrapper dateWrapper = new LibraryDateWrapper();
        dateWrapper.proxy.Tech_Start_Date_Proxy__c = Date.today();
        dateWrapper.proxy.Tech_End_Date_Proxy__c = Date.today().addDays(1);
        sow.dateWrapperMap.put('CreatedDate', dateWrapper);
        
        MultiSelectWrapper msw = new MultiSelectWrapper();
        msw.selectedValues.add('123');
        
        sow.multiSelectWrapperMap.put('Fls_Material_Type__c', msw);
        sow.multiSelectWrapperMap.put('Fls_Material_Type__c', msw);
        
        LibraryNumberWrapper lnw = new LibraryNumberWrapper();
        lnw.max = 1.0;
        lnw.min = 2.0;
        
        if(!afterDip) {
        	sow.numberWrapperMap.put('Weight_Before_Dip__c', lnw);
        } else {
            sow.numberWrapperMap.put('Weight_After_Dip__c', lnw);
        }
        
        return sow;
    }
    
    static testMethod void testGetItemsSow() {
        SearchSObjectWrapper sow = prepareSow(true);
        
        LibrarySourceFabricRepository fr = new LibrarySourceFabricRepository();
        List<Library_Item__c> libList = fr.getItems(sow);
        System.assertEquals(libList.isEmpty(), true);
    }
    
    static testMethod void testGetAllFabricItems() {
        SearchSObjectWrapper sow = prepareSow(false);
        
        LibrarySourceFabricRepository fr = new LibrarySourceFabricRepository();
        List<Library_Item__c> libList = fr.getAllFabricItems('', 5, sow);
        System.assertEquals(libList.isEmpty(), true);
        
        System.assertEquals(false, fr.getHasNextPage());
        System.assertEquals(false, fr.getHasPrevPage());
        List<Library_Item__c> libList2 = fr.getItemsNextPage('', sow);
        System.assertEquals(libList2.isEmpty(), true);
        List<Library_Item__c> libList3 = fr.getItemsPrevPage('', sow);
        System.assertEquals(libList3.isEmpty(), true);
    }
    
    static testMethod void testGetItemsFromResponseResultsNoCommit() {
        LibrarySourceFabricRepository fr = new LibrarySourceFabricRepository();
        LibraryFlsFabricSearchWs.fabricSearchResult[] fsrList = new List<LibraryFlsFabricSearchWs.fabricSearchResult>();
        
        LibraryFlsFabricSearchWs.fabricSearchResult fsr = new LibraryFlsFabricSearchWs.fabricSearchResult();
        LibraryFlsFabricSearchWs.fabric fab = new LibraryFlsFabricSearchWs.fabric();
        List<String> testValues = new List<String>();
        testValues.add('123');
        
        string year = '2008';
        string month = '10';
        string day = '5';
        string hour = '12';
        string minute = '20';
        string second = '20';
        string stringDate = year + '-' + month
         + '-' + day + ' ' + hour + ':' + 
        minute + ':' + second;
        
        fab.actualWidth = 1.0;
        fab.actualWidthUom = 'Meters';
        fab.brandCustomer = 'Adidas';
        fab.countryOfOrigins = 'Canada';
        fab.createDateStr = stringDate;
        fab.currency_x = 'USD';
        fab.cuttableWidth = 1.0;
        fab.cuttableWidthUom = 'Meters';
        fab.densityStr = '123';
        fab.DWashTest = '123';
        fab.exclusiveCustomer = 'Adidas';
        fab.fabricEndUse = 'For Fun';
        fab.fabricName = 'W00000001';
        fab.fabricSeason = '123';
        fab.fabricYear = 123;
        fab.fiberContentStr = '123';       
        fab.fiberContents = new List<String>(testValues);
        fab.freightTerms = '123';
        fab.garmentFinishings = new List<String>(testValues);
        fab.gauge = '123';
        fab.isCompleted = true;
        fab.isDipping = true;
        fab.isKnitFabric = true;
        fab.isWovenFabric = false;
        fab.materialFinishings = new List<String>(testValues);
        fab.materialType = '123';
        fab.pilotFabric = '123';
        fab.quotedPrice = '123';
        fab.quotedPriceUom = '123';
        fab.requestBy = '123';
        fab.requestByRnD = true;
        fab.requireRndTest = '123';
        fab.status = '123';
        fab.supplierName = '123';
        fab.validDate = stringDate;
        fab.warpDensity = '123';
        fab.warpYarnSizeStr = '123';
        fab.weaveType = '123';
        fab.weftDensity = '123';
        fab.weftYarnSizeStr = '123';
        fab.weightBeforeDipStr = '123';
        fab.weightStr = '123';
        fab.yarnDyeMethod = '123';
        fab.yarnSizeStr = '123';
        
        fsr.fabric = fab;
        fsrList.add(fsr);
        
        List<Library_Item__c> libList = fr.getItemsFromResponseResultsNoCommit(fsrList);
        
        System.assertEquals(1, libList.size());
        
        List<Library_Item__c> libList2 = fr.getItemsFromResponseResults(fsrList);
        System.assertEquals(1, libList2.size());
        
        List<Library_Item__c> libList3 = LibrarySourceFabricRepository.getDummyFabricItemFields();
        System.assertEquals(0, libList3.size());
    }
}