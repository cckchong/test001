/**
 * Test Class of LibraryFlsFabricModelUtil
 */
@isTest
private class TestLibraryFlsFabricModelUtil {
    
    // @IsTest
    // static void myUnitTest() {
    //     Test.setMock(WebServiceMock.class, new TestLibraryFlsFabricSearchWsMockImpl());
    //     LibraryFlsFabricSearchWs.fabricSearchPort ws = new LibraryFlsFabricSearchWs.fabricSearchPort();
    //     ws.timeout_x = Integer.valueOf(Label.Tech_Api_Timeout_Millis);
    //     LibraryFlsFabricSearchWs.fabricSearchRequest fs = new LibraryFlsFabricSearchWs.fabricSearchRequest();        
    //     fs.userId = 'root';
    //     fs.pageSize = Integer.valueOf(Label.Library_Page_Size);
    //     fs.pageNo = 1;
    //     LibraryFlsFabricSearchWs.fabricSearchResponse[] fsrList = ws.searchFabric(fs);
        
    //     List<Library_Item__c> resList = new List<Library_Item__c>();
        
    //     if(fsrList != null && !fsrList.isEmpty()) {
    //         resList = LibraryFlsFabricModelUtil.mapFlsResultsToItemsNoCommit(fsrList[0].results);
    //         resList = LibraryFlsFabricModelUtil.mapFlsResultsToItems(fsrList[0].results);
    //     }
    //      system.debug(resList);
    // }
    
    static testMethod void testGetItemsFromResponseResultsNoCommit() {
        LibrarySourceFabricRepository fr = new LibrarySourceFabricRepository();
        LibraryFlsFabricSearchWs.fabricSearchResult[] fsrList = new List<LibraryFlsFabricSearchWs.fabricSearchResult>();
        
        LibraryFlsFabricSearchWs.fabricSearchResult fsr = new LibraryFlsFabricSearchWs.fabricSearchResult();
        LibraryFlsFabricSearchWs.fabric fab = new LibraryFlsFabricSearchWs.fabric();
        List<String> testValues = new List<String>();


        LibraryFlsFabricSearchWs.fabricInventory myInventory=new LibraryFlsFabricSearchWs.fabricInventory();
        myInventory.availableQty=12.2;
        myInventory.facility='VVVVV';
        myInventory.reservedQty=22;
        myInventory.unit='12312';
        List<LibraryFlsFabricSearchWs.fabricInventory> inList=new List<LibraryFlsFabricSearchWs.fabricInventory>();
        inList.add(myInventory);

        LibraryFlsFabricSearchWs.fabricColor myColor=new LibraryFlsFabricSearchWs.fabricColor();
        myColor.colorName='red';
        myColor.colorNo='red';
        myColor.fabricColor='red';
        myColor.fabricPattern='12312';
        // List<LibraryFlsFabricSearchWs.fabricColor> coList=new List<LibraryFlsFabricSearchWs.fabricColor>();
        // coList.add(myColor);

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
        fab.fiberContentStr = '1 2 3, 1 2 3, 1 2 3,1 2 3, 1 2 3';       
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
        fsr.Inventory=inList;
        fsr.color=myColor;
        List<Library_Item__c> libList = fr.getItemsFromResponseResultsNoCommit(fsrList);
        
        System.assertEquals(1, libList.size());
        
        List<Library_Item__c> libList2 = fr.getItemsFromResponseResults(fsrList);
        System.assertEquals(1, libList2.size());
        
        List<Library_Item__c> libList3 = LibrarySourceFabricRepository.getDummyFabricItemFields();
        System.assertEquals(0, libList3.size());
    }

}