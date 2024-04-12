@isTest
public with sharing class TestContractResource {

    static final string REQUEST_URI = '/services/apexrest/v1/Contacts/';

    @TestSetup
    static void makeData(){

        Account testAccount1 = new Account(Name = 'testAccount1');
        insert testAccount1;

        Contract testContract1 = new Contract(
            AccountId = testAccount1.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
        );
        insert testContract1;
    }

    @isTest
    static void testCreateContract(){

        Account testAccount2 = new Account(Name = 'testAccount2');
        insert testAccount2;

        Contract testContract2 = new Contract(
            AccountId = testAccount2.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
        );

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serializePretty(testContract2));
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        Test.startTest();
        ContractResource.createContract(testContract2.AccountId, testContract2.Status, testContract2.StartDate, testContract2.ContractTerm);
        Test.stopTest();

        // Verify response
        System.assertEquals(201, res.statusCode);
        Map<String,Object> responseBodyMap = (Map<String,Object>)JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('Contract successfully created', responseBodyMap.get('Message'));
        System.assertNotEquals(null, (String)responseBodyMap.get('Id'));

    }

    @isTest
    static void testCreateContractFailed(){

        Account testAccount3 = new Account(Name = 'testAccount3');
        insert testAccount3;

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty('testFail'));
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        Test.startTest();
        ContractResource.createContract(testAccount3.Id, 'testFail', Date.today(), 12);
        Test.stopTest();

        // Verify response
        System.assertEquals(400, res.statusCode);
    }

    @isTest
    static void testCreateContractNullResponse(){

        Account testAccount4 = new Account(Name = 'testAccount4');
        insert testAccount4;

        Contract testContract4 = new Contract(
            AccountId = testAccount4.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
        );

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('testContract4');

        // Mocking the response as null
        RestContext.response = null;

        // Call the method
        Test.startTest();
        ContractResource.createContract(testContract4.AccountId, testContract4.Status, testContract4.StartDate, testContract4.ContractTerm);
        Test.stopTest();
    }

    @isTest
    static void testCreateContractMissingRequiredFields(){

        // Mocking the request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Set up test data with missing required fields
        String accountId= null;
        String status = '';
        Date startDate = null;
        Integer contractTerm = null;

        // Call the createContract method and catch the exception
        try{
            ContractResource.createContract(accountId, status, startDate, contractTerm);
        } catch (Exception e){

            // Verify that the exception message matches the expected message
            System.assertEquals('Missing required fields', e.getMessage());

            // Verify that the response status code is 400
            System.assertEquals(400, res.statusCode);
        }
    }

    @isTest
    static void testUpdateContract(){

        Account existingAccount = [SELECT Id, Name FROM Account WHERE Name = 'testAccount1'];
        Contract existingContract = [SELECT Id, ContractTerm FROM Contract WHERE AccountId =:existingAccount.Id];

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + existingContract.Id;
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{"ContractTerm": 24}');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContractResource.updateContract();
        Test.stopTest();

        System.assertEquals(200, res.statusCode);
        Map<String,Object> responseBodyMap = (Map<String,Object>)JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('Contract successfully updated', responseBodyMap.get('Message'));
        System.assertEquals(existingContract.Id, (String)responseBodyMap.get('Id'));

    }

    @isTest
    static void testUpdateContractFailed(){

        Account existingAccount = [SELECT Id, Name FROM Account WHERE Name = 'testAccount1'];
        Contract existingContract = [SELECT Id, ContractTerm FROM Contract WHERE AccountId =:existingAccount.Id];

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + existingContract.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"ContractTerm": "invalidValue"}');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContractResource.updateContract();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    @isTest
    static void testUpdateContractNullResponse(){

        Account existingAccount = [SELECT Id, Name FROM Account WHERE Name = 'testAccount1'];
        Contract existingContract = [SELECT Id, ContractTerm FROM Contract WHERE AccountId =:existingAccount.Id];

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + existingContract.Id;
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{"ContractTerm": 24}');
        RestContext.request = req;

        // Mocking the response as null
        RestContext.response = null;

        // Call the method
        Test.startTest();
        ContractResource.updateContract();
        Test.stopTest();
    }
}