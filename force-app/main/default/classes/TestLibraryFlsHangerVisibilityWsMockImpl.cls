@isTest
global class TestLibraryFlsHangerVisibilityWsMockImpl implements WebServiceMock {
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
        LibraryFlsHangerVisibilityWs.hangerItem hangerItem = new LibraryFlsHangerVisibilityWs.hangerItem();
        
		LibraryFlsHangerVisibilityWs.hangerUpdateResult huResult = new LibraryFlsHangerVisibilityWs.hangerUpdateResult();
		huResult.hanger = hangerItem;
		
		List<LibraryFlsHangerVisibilityWs.hangerUpdateResult> huResults= new List<LibraryFlsHangerVisibilityWs.hangerUpdateResult>();
		huResults.add(huResult);
		
		LibraryFlsHangerVisibilityWs.updateFabricHangerResponse fhResponse = new LibraryFlsHangerVisibilityWs.updateFabricHangerResponse();	
		fhResponse.results = huResults;
		response.put('response_x', fhResponse);
	}
}