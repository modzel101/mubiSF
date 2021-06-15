@IsTest
private class LeadManagerService_Test {
    @IsTest
    public static void testHttpPost() {
        // prepare test-data

        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/MubiService'; //Request URL
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf('[ { "id":"123e4567-e89b-12d3-a456-426655440000", "createddate":"2019-10-24T11:28:41.000-0700", "firstname":"Arnold", "lastname":"Shwarzenegger", "phone":null, "address":{ "street":"Coulterville", "city":"Los Angeles", "postalcode":"99501", "country":"United States" } }, { "id":"00112233-4455-6677-8899-aabbccddeeff", "createddate":"2019-10-24T13:02:45.000-0700", "firstname":"Brad", "lastname":"Pitt", "phone":"12223334444", "address":{ "street":"Beverly Dr 238/1", "city":"Beverly Hills", "postalcode":"90212", "country":"United States" } } ]');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            String actual = LeadManagerService.upsertLeads();
        Test.stopTest();

        System.assertEquals('expected value', actual, 'Value is incorrect');
    }
    
}