@isTest
global class TestLibraryFlsFabricSearchWsMockImpl implements WebServiceMock {
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
        LibraryFlsFabricSearchWs.fabricColor color = new LibraryFlsFabricSearchWs.fabricColor();
	    color.colorName = 'Bona(2)57/WK';
        color.colorNo = 'BP1';
        color.fabricColor = 'Blue (B)';
        color.fabricPattern = 'Print (P)';
        
        LibraryFlsFabricSearchWs.fabric fabric = new LibraryFlsFabricSearchWs.fabric();
        //public LibraryFlsFabricSearchWs.fabricAccess access;
		fabric.actualWidth = 57.0;
		fabric.actualWidthUom = 'Inch';
		//public LibraryFlsFabricSearchWs.fabricConstructAttachment[] attachments;
		fabric.brandCustomer = 'Giordano Junior';
		fabric.countryOfOrigins = 'China';
		fabric.createDateStr = '2015-03-19';
		fabric.currency_x = 'USD';
		fabric.cuttableWidth = 56.0;
		fabric.cuttableWidthUom = 'Inch';
		fabric.DWashTest = '';
		fabric.densityStr = '140 x 72';
		fabric.exclusiveCustomer = '';
		fabric.fabricEndUse = 'G01 - Shirt';
		fabric.fabricName = 'W000040068';
		fabric.fabricSeason = 'Fall';
		fabric.fabricYear = 2015;
		fabric.fiberContentStr = '100% Cotton';
		fabric.fiberContents = new List<String>{'100% Cotton'};
		fabric.freightTerms = 'CIF';
		//fabric.garmentFinishings;
		//public String gauge;
		fabric.isCompleted = false;
		fabric.isDipping = false;
		fabric.isKnitFabric = false;
		fabric.isWovenFabric = true;
		fabric.materialFinishings = new List<String>{'Wrinkle Free'};
		fabric.materialType = 'Shell fabric';
		fabric.pilotFabric = '';
		fabric.quotedPrice = '0.0';
		fabric.quotedPriceUom = 'Yard';
		fabric.requestBy = 'ROBIN XIONG';
		fabric.requestByRnD = false;
		fabric.requireRndTest = 'No';
		fabric.status = 'Active';
		fabric.supplierName = 'NDP';
		fabric.validDate = '2015-05-19';
		fabric.warpDensity = '140';
		fabric.warpYarnSizeStr = '40 , 40 40';
		fabric.weaveType = 'W-Poplin';
		fabric.weftDensity = '72';
		fabric.weftYarnSizeStr = '40 , 40 80';
		fabric.weightBeforeDipStr = 'N/A';
		fabric.weightStr = 'N/A';
		fabric.yarnDyeMethod = 'Printed';
		fabric.yarnSizeStr = '40 , 40';
        
		LibraryFlsFabricSearchWs.fabricSearchResult fsResult = new LibraryFlsFabricSearchWs.fabricSearchResult();
		fsResult.color = color;
		fsResult.fabric = fabric;
		
		//Second Fabric
		LibraryFlsFabricSearchWs.fabricConstructAttachment att = new LibraryFlsFabricSearchWs.fabricConstructAttachment();
        att.fileName = 'report1';
        att.attachmentId = 10001;
        LibraryFlsFabricSearchWs.fabricConstructAttachment att2 = new LibraryFlsFabricSearchWs.fabricConstructAttachment();
        att2.fileName = 'report2';
        att2.attachmentId = 10002;
        LibraryFlsFabricSearchWs.fabricConstructAttachment att3 = new LibraryFlsFabricSearchWs.fabricConstructAttachment();
        att3.fileName = 'report3';
        att3.attachmentId = 10003;
        LibraryFlsFabricSearchWs.fabricConstructAttachment att4 = new LibraryFlsFabricSearchWs.fabricConstructAttachment();
        att4.fileName = 'report4';
        att4.attachmentId = 10004;
		List<LibraryFlsFabricSearchWs.fabricConstructAttachment> atts = new List<LibraryFlsFabricSearchWs.fabricConstructAttachment>();
		atts.add(att);
		atts.add(att2);
		atts.add(att3);
		atts.add(att4);
        LibraryFlsFabricSearchWs.fabric fabric2 = new LibraryFlsFabricSearchWs.fabric();
        //public LibraryFlsFabricSearchWs.fabricAccess access;
		fabric2.actualWidth = 57.0;
		fabric2.actualWidthUom = 'Inch';
		fabric2.attachments = atts;
		fabric2.brandCustomer = 'Giordano Junior';
		fabric2.countryOfOrigins = 'China';
		fabric2.createDateStr = '2015-03-19';
		fabric2.currency_x = 'USD';
		fabric2.cuttableWidth = 56.0;
		fabric2.cuttableWidthUom = 'Inch';
		fabric2.DWashTest = '';
		fabric2.densityStr = '140 x 72';
		fabric2.exclusiveCustomer = '';
		fabric2.fabricEndUse = 'G01 - Shirt';
		fabric2.fabricName = 'W000040068';
		fabric2.fabricSeason = 'Fall';
		fabric2.fabricYear = 2015;
		fabric2.fiberContentStr = '80% Cotton, 8% Wool, 8% Polyester, 4% Freefit';
		fabric2.fiberContents = new List<String>{'80% Cotton', '8% Wool', '8% Polyester', '4% Freefit'};
		fabric2.freightTerms = 'CIF';
		fabric2.garmentFinishings = new List<String>{'A', 'B'};
		//public String gauge;
		fabric2.isCompleted = false;
		fabric2.isDipping = false;
		fabric2.isKnitFabric = true;
		fabric2.isWovenFabric = false;
		fabric2.materialFinishings = new List<String>{'Wrinkle Free'};
		fabric2.materialType = 'Shell fabric';
		fabric2.pilotFabric = '';
		fabric2.quotedPrice = '0.0';
		fabric2.quotedPriceUom = 'Yard';
		fabric2.requestBy = 'ROBIN XIONG';
		fabric2.requestByRnD = false;
		fabric2.requireRndTest = 'Yes';
		fabric2.status = 'Active';
		fabric2.supplierName = 'NDP';
		fabric2.validDate = '2015-05-19';
		fabric2.warpDensity = '140';
		fabric2.warpYarnSizeStr = '40 , 40 40';
		fabric2.weaveType = 'W-Poplin';
		fabric2.weftDensity = '72';
		fabric2.weftYarnSizeStr = '40 , 40 80';
		fabric2.weightBeforeDipStr = 'N/A';
		fabric2.weightStr = 'N/A';
		fabric2.yarnDyeMethod = 'Printed';
		fabric2.yarnSizeStr = '40 , 40';
		
		LibraryFlsFabricSearchWs.fabricSearchResult fsResult2 = new LibraryFlsFabricSearchWs.fabricSearchResult();
		fsResult2.fabric = fabric2;
		
		List<LibraryFlsFabricSearchWs.fabricSearchResult> fsResults = new List<LibraryFlsFabricSearchWs.fabricSearchResult>();
		fsResults.add(fsResult);
		fsResults.add(fsResult2);
		
		LibraryFlsFabricSearchWs.fabricSearchResponse fsResponse = new LibraryFlsFabricSearchWs.fabricSearchResponse();
		fsResponse.results = fsResults;
		fsResponse.totalResultCount = 1;
		
		List<LibraryFlsFabricSearchWs.fabricSearchResponse> fsResponses = new List<LibraryFlsFabricSearchWs.fabricSearchResponse>();
		fsResponses.add(fsResponse);
		
		LibraryFlsFabricSearchWs.searchFabricResponse sfResponse = new LibraryFlsFabricSearchWs.searchFabricResponse();	
		sfResponse.return_x = fsResponses;
		response.put('response_x', sfResponse);
	}
}