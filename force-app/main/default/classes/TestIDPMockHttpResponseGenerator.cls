@isTest
global class TestIDPMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('1234567');
         req.setMethod('POST');
        res.setStatusCode(200);
        return res;
    }
}