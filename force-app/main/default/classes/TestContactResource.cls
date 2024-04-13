@isTest
public with sharing class TestContactResource {

    static final string REQUEST_URI = '/services/apexrest/v1/Contacts/';

    @TestSetup
    static void makeData(){

        Contact testContact = new Contact(
            LastName = 'Doe',
            FirstName = 'John',
            Email = 'john.doe@test.com'
        );
        insert testContact;
    }

    @isTest
    static void testCreateNewContact(){

        Contact testNewContact = new Contact(
            LastName = 'Roe',
            FirstName = 'Richard',
            Email = 'richard.roe@test.com'
        );

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(testNewContact));
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContactResource.createContact(testNewContact.LastName, testNewContact.FirstName, testNewContact.Email);
        Test.stopTest();

        System.debug(res.responseBody.toString());
        Map<String, Object> responseBody = (Map<String,Object>)JSON.deserializeUntyped(res.responseBody.toString());
        System.debug((String)responseBody.get('Id'));

        Assert.areEqual(201, res.statusCode);
        Assert.areNotEqual(null, (String)responseBody.get('Id'));
    }

    @isTest
    static void testCreateExistingContact(){

        Contact testExistingContact = new Contact(
            LastName = 'Doe',
            FirstName = 'John',
            Email = 'john.doe@test.com'
        );

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(testExistingContact));
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContactResource.createContact(testExistingContact.LastName, testExistingContact.FirstName, testExistingContact.Email);
        Test.stopTest();

        Map<String,Object> responseBody = (Map<String,Object>)JSON.deserializeUntyped(res.responseBody.toString());

        Assert.areNotEqual(null, (String)responseBody.get('Id'));
        Assert.areEqual(200, res.statusCode);
    }

    @isTest
    static void testCreateContactFailed(){

        // Mocking the request with invalid data
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty('testFail'));
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContactResource.createContact('failLastName', 'failFirstName', 'failEmail');
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

    @isTest
    static void testUpdateContact(){

        Contact testContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'john.doe@test.com' LIMIT 1];

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + testContact.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Email": "updated.johndoe@test.com"}');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContactResource.updateContact();
        Test.stopTest();

        Contact updatedContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'updated.johndoe@test.com' LIMIT 1];
        Map<String,Object> responseBody = (Map<String,Object>)JSON.deserializeUntyped(res.responseBody.toString());

        Assert.areEqual(updatedContact.Id, (String)responseBody.get('Id'));
        Assert.areEqual(200, res.statusCode);
        Assert.areNotEqual('john.doe@test.com', updatedContact.Email);
    }

    @isTest
    static void testUpdateContactFailed(){

        Contact testContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'john.doe@test.com' LIMIT 1];

        // Mocking the request with invalid data
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + testContact.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Email": "invalidEmail"}');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContactResource.updateContact();
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

    @isTest
    static void testDeleteContact(){

        Contact testContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'john.doe@test.com' LIMIT 1];

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + testContact.Id;
        req.httpMethod = 'DELETE';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContactResource.deleteContact();
        Test.stopTest();

        Contact deactivatedContact = [SELECT Id, LastName, FirstName, Email, Active__c FROM Contact WHERE Email = 'john.doe@test.com' LIMIT 1];

        Assert.areEqual(false, deactivatedContact.Active__c);
        Assert.areEqual(200, res.statusCode);
    }

    @isTest
    static void testDeleteContactFailed(){

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + 'invalidId';
        req.httpMethod = 'DELETE';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;

        // Mocking the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContactResource.deleteContact();
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

    @isTest
    static void testDeleteContactNullResponse(){

        // Mocking the request
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI + 'invalidId';
        req.httpMethod = 'DELETE';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;

        // Mocking the response as null
        RestContext.response = null;

        Test.startTest();
        ContactResource.deleteContact();
        Test.stopTest();
    }

}