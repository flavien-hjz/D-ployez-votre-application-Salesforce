@RestResource(urlMapping='/v1/Contacts/*')
global with sharing class ContactResource {

    // Method to create a new contact
    @HttpPost
    global static void createContact(String lastName, String firstName, String email) {
        RestResponse response = initializeResponse();

        try{
            // Validate input parameters
            validateInput(lastName, firstName, email);

            //Check if contact with given email already exists
            Contact existingContact = [SELECT Id FROM Contact WHERE Email =:email LIMIT 1];

            if (existingContact != null){
                // If contact already exists, return error response
                sendSuccessResponse(response, existingContact.Id, 'This contact already exists', 200);
            } else {
                //Create a new contact
                Contact newContact = new Contact(
                    LastName = lastName,
                    FirstName = firstName,
                    Email = email
                );
                insert newContact;
                // Send success response
                sendSuccessResponse(response, newContact.Id, 'Contact ' + newContact.Id + ' was successfully created', 201);
            }
        } catch(Exception e) {
            // Handle any exception
            handleException(response, 'An error occured: ' + e.getMessage());
        }
    }

    // Method to update an existing contact
    @HttpPatch
    global static void updateContact(String lastName, String firstName, String email) {
        RestResponse response = initializeResponse();

        try {
            RestRequest request = RestContext.request;
            String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);

            // Retrieve the contact to be updated
            Contact contact = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
            if (contact == null) {
                // If contact not found, return error response
                sendErrorResponse(response, 'Contact not found', 404);
                return;
            }

            // Update contact fields if provided in request body
            if (!String.isBlank(lastName)) {
                contact.LastName = lastName;
            }
            if (!String.isBlank(firstName)) {
                contact.FirstName = firstName;
            }
            if (!String.isBlank(email)) {
                contact.Email = email;
            }
            //Update the contact
            update contact;

            // Send success response
            sendSuccessResponse(response, contact.Id, 'Contact ' + contact.Id + ' was successfully updated');
        } catch(Exception e) {
            // Handle any exception
            handleException(response, 'An error occurred: ' + e.getMessage());
        }
    }

    // Method to delete a contact
    @HttpDelete
    global static void deleteContact(){
        RestResponse response = initializeResponse();

        try{
            RestRequest request = RestContext.request;
            String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);

            // Retrieve the contact to be deleted
            Contact contact = [SELECT Id, Active__c FROM Contact WHERE Id =:contactId];
            if (contact == null){
                // If contact not found, return error response
                sendErrorResponse(response, 'Contact not found', 404);
                return;
            }

            // Deactivate the contact
            contact.Active__c = false;
            update contact;

            //Send success response
            sendSuccessResponse(response, contact.Id, 'Contact ' + contact.Id + ' was successfully deactivated');
        } catch(Exception e){
            // Handle any exceptions
            handleException(response, 'An error occured: ' + e.getMessage());
        }
    }

    //Helper methods

    // Method to initialize response object
    global static RestResponse initializeResponse(){
        RestResponse response = RestContext.response;
        if (response == null){
            // If response object is null, create a new one
            response = new RestResponse();
            RestContext.response = response;
        }
        // Add content type header
        response.addHeader('Content-Type', 'application/json');
        return response;
    }

    // Method to validate input parameters
    private static void validateInput(String lastName, String firstName, String email){
        if (String.isBlank(lastName) || String.isBlank(firstName) || String.isBlank(email)){
            // Throw exception if any input parameter is blank
            throw new IllegalArgumentException('Invalid input parameters');
        }
    }

    // Method to send success response
    private static void sendSuccessResponse(RestResponse response, Id contactId, String message){
        sendSuccessResponse(response, contactId, message, 200);
    }

    // Overloaded method to send success response with status code
    private static void sendSuccessResponse(RestResponse response, Id contactId, String message, Integer statusCode){
        Map<String,String> responseValuesMap = new Map<String,String>{
            'Id' => String.valueOf(contactId),
            'Message' => message
        };
        // Serialize response values and set response body and status code
        response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
        response.statusCode = statusCode;
    }

    // Method to send error response
    private static void sendErrorResponse(RestResponse response, String errorMessage, Integer statusCode){
        Map<String,String> responseValuesMap = new Map<String,String>{
            'Message' => errorMessage
        };
        // Serialize error message and set response body and status code
        response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
        response.statusCode = statusCode;
    }

    // Method to handle exceptions
    private static void handleException(RestResponse response, String errorMessage){
        // Log error message
        System.debug(errorMessage);
        Map<String,String> responseValuesMap = new Map<String,String>{
            'Message' => errorMessage
        };
        // Serialize error message and set response body and status code
        response.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
        response.statusCode = 400;
    }
}