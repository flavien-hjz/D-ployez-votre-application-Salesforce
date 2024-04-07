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

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(testNewContact));

        RestContext.request = req;
        RestContext.response = res;

        // ContactResource.initializeResponse();
        Test.startTest();
        // RestContext.request = req;
        // RestContext.response = res;
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

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(testExistingContact));

        RestContext.request = req;
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

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty('testFail'));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ContactResource.createContact('failLastName', 'failFirstName', 'failEmail');
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

    @isTest
    static void testUpdateContact(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Contact testContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'john.doe@test.com' LIMIT 1];

        req.requestURI = REQUEST_URI + testContact.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Email": "updated.johndoe@test.com"}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ContactResource.updateContact(testContact.LastName, testContact.FirstName, 'updated.johndoe@test.com');
        Test.stopTest();

        Contact updatedContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'updated.johndoe@test.com' LIMIT 1];
        Map<String,Object> responseBody = (Map<String,Object>)JSON.deserializeUntyped(res.responseBody.toString());

        Assert.areEqual(updatedContact.Id, (String)responseBody.get('Id'));
        Assert.areEqual(200, res.statusCode);
        Assert.areNotEqual('john.doe@test.com', updatedContact.Email);
    }

    @isTest
    static void testUpdateContactFailed(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Contact testContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'john.doe@test.com' LIMIT 1];

        req.requestURI = REQUEST_URI + testContact.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Email": "invalidEmail"}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ContactResource.updateContact(testContact.LastName, testContact.FirstName, 'invalidEmail');
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

    @isTest
    static void testDeleteContact(){

        Contact testContact = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email = 'john.doe@test.com' LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = REQUEST_URI + testContact.Id;
        req.requestBody = Blob.valueOf('');
        req.httpMethod = 'DELETE';

        RestContext.request = req;
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

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = REQUEST_URI + 'invalidId';
        req.requestBody = Blob.valueOf('');
        req.httpMethod = 'DELETE';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ContactResource.deleteContact();
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

}