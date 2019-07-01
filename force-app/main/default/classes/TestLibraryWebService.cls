/**
 * Test class of web services
 */
@isTest
private class TestLibraryWebService {

    static testMethod void testLibraryFlsFabricSearchWs() {
    	// This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new TestLibraryFlsFabricSearchWsMockImpl());        
        LibraryFlsFabricSearchWs.fabricSearchPort ws = new LibraryFlsFabricSearchWs.fabricSearchPort();
        ws.timeout_x = Integer.valueOf(Label.Tech_Api_Timeout_Millis);
        LibraryFlsFabricSearchWs.fabricSearchRequest fs = new LibraryFlsFabricSearchWs.fabricSearchRequest();        
        fs.userId = 'root';
        fs.pageSize = Integer.valueOf(Label.Library_Page_Size);
        fs.pageNo = 1;
        LibraryFlsFabricSearchWs.fabricSearchResponse[] fsrList = ws.searchFabric(fs);
        //System.assertEquals('Bona(2)57/WK', fsrList[0].results[0].color.colorName); 
        //System.assertEquals('W000040068', fsrList[0].results[0].fabric.fabricName);
        
        System.assertEquals(true, fsrList.isEmpty());
        LibraryFlsFabricSearchWs.fabricSearchModel fsm = new LibraryFlsFabricSearchWs.fabricSearchModel();        
        LibraryFlsFabricSearchWs.fabricSearchValue fsv = new LibraryFlsFabricSearchWs.fabricSearchValue();        
        LibraryFlsFabricSearchWs.testReportPrintout reportCls = new LibraryFlsFabricSearchWs.testReportPrintout();
        LibraryFlsFabricSearchWs.searchFabricResponse respCls  = new LibraryFlsFabricSearchWs.searchFabricResponse();
        LibraryFlsFabricSearchWs.fabricColor colCls  = new LibraryFlsFabricSearchWs.fabricColor();
        LibraryFlsFabricSearchWs.fabricSearchResult resultCls = new LibraryFlsFabricSearchWs.fabricSearchResult();
        LibraryFlsFabricSearchWs.fabricInventory invCls = new LibraryFlsFabricSearchWs.fabricInventory();
        LibraryFlsFabricSearchWs.fabricConstructAttachment attCls=new LibraryFlsFabricSearchWs.fabricConstructAttachment();
        LibraryFlsFabricSearchWs.fabricAccess accCls = new LibraryFlsFabricSearchWs.fabricAccess();
        LibraryFlsFabricSearchWs.fabric fabCls = new LibraryFlsFabricSearchWs.fabric();
        LibraryFlsFabricSearchWs.fabricSearchResponse responseCls = new LibraryFlsFabricSearchWs.fabricSearchResponse();
    }
    
    static testMethod void testLibraryFlsHangerVisibilityWs() {
    	LibraryFlsHangerVisibilityWs.hangerUpdateRequest hObj = new LibraryFlsHangerVisibilityWs.hangerUpdateRequest();
        LibraryFlsHangerVisibilityWs.hangerItem iObj = new LibraryFlsHangerVisibilityWs.hangerItem();
        LibraryFlsHangerVisibilityWs.updateFabricHangerResponse rObj = new LibraryFlsHangerVisibilityWs.updateFabricHangerResponse();
        LibraryFlsHangerVisibilityWs.updateFabricHanger uObj = new LibraryFlsHangerVisibilityWs.updateFabricHanger();
        LibraryFlsHangerVisibilityWs.hangerUpdateResult huObj = new LibraryFlsHangerVisibilityWs.hangerUpdateResult();
        LibraryFlsHangerVisibilityWs.hangerAvailabilityPort haObj = new LibraryFlsHangerVisibilityWs.hangerAvailabilityPort();
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new TestLibraryFlsHangerVisibilityWsMockImpl());
        LibraryFlsHangerVisibilityWs.hangerUpdateResult[] huResults = haObj.updateFabricHanger(hObj);
    }
    
    static testMethod void testLibraryFlsSearchValuesWs() {
        LibraryFlsSearchValuesWs.getSearchValuesResponse resp = new LibraryFlsSearchValuesWs.getSearchValuesResponse();
        LibraryFlsSearchValuesWs.getFabricSearchValuesResponse valResp = new LibraryFlsSearchValuesWs.getFabricSearchValuesResponse();
        LibraryFlsSearchValuesWs.getSearchValuesRequest req = new LibraryFlsSearchValuesWs.getSearchValuesRequest();
        LibraryFlsSearchValuesWs.getFabricSearchValues val = new LibraryFlsSearchValuesWs.getFabricSearchValues();
        LibraryFlsSearchValuesWs.fabricSearchValue sVal = new LibraryFlsSearchValuesWs.fabricSearchValue();
        LibraryFlsSearchValuesWs.getSearchValuesPort port = new LibraryFlsSearchValuesWs.getSearchValuesPort();    
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new TestLibraryFlsSearchValuesWsMockImpl());
        //LibraryFlsSearchValuesWs.getSearchValuesResponse svResponse = port.getFabricSearchValues(req);
    }
    
}