@isTest
global class TestLibraryFlsSearchValuesWsMockImpl implements WebServiceMock {
	global void doInvoke(
		Object stub,
		Object request,
		Map<String, Object> response,
		String endpoint,
		String soapAction,
		String requestName,
		String responseNS,
		String responseName,
		String responseType) {
		//fake response here
		LibraryFlsSearchValuesWs.fabricSearchValue child = new LibraryFlsSearchValuesWs.fabricSearchValue();
		child.group_x = '511';
        child.groupHeader = false;
        child.name = '51 - 511 Tactical Series';
        child.id = 43918;
        List<LibraryFlsSearchValuesWs.fabricSearchValue> children = new List<LibraryFlsSearchValuesWs.fabricSearchValue>();
        children.add(child);
        
		LibraryFlsSearchValuesWs.fabricSearchValue fsValue = new LibraryFlsSearchValuesWs.fabricSearchValue();
		//fake response for BRAND_CUSTOMER
		fsValue.children = children;
        fsValue.group_x = '511';
        fsValue.groupHeader = true;
        fsValue.name = '511';
        fsValue.id = -1;
        
        LibraryFlsSearchValuesWs.fabricSearchValue fsValue2 = new LibraryFlsSearchValuesWs.fabricSearchValue();
		//fake response for BRAND_CUSTOMER
        fsValue2.group_x = '511';
        fsValue2.groupHeader = false;
        fsValue2.name = '51 - 511 Tactical Series';
        fsValue2.id = 43918;
		List<LibraryFlsSearchValuesWs.fabricSearchValue> fsValues = new List<LibraryFlsSearchValuesWs.fabricSearchValue>();
		fsValues.add(fsValue);
		fsValues.add(fsValue2);
		
		LibraryFlsSearchValuesWs.getSearchValuesResponse svResponse = new LibraryFlsSearchValuesWs.getSearchValuesResponse();
		svResponse.values = fsValues;
		
		LibraryFlsSearchValuesWs.getFabricSearchValuesResponse fsvResponse = new LibraryFlsSearchValuesWs.getFabricSearchValuesResponse();	
		fsvResponse.return_x = svResponse;
		response.put('response_x', fsvResponse);
	}
}