/*************************************************************************************************************
 * @name			SalestrekkerServiceMock
 * @author			James Winter <james@beintelligent.nz>
 * @created			13th September 2021
 * @description		Mock Service for Salestrekker callout
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-13		James Winter			Creation of the class
 *
**************************************************************************************************************/
@IsTest
public with sharing class SalestrekkerServiceMock implements HttpCalloutMock {
    Boolean isMockResponseException;
    Boolean isMockResponseError;
    String responseText;

    @TestVisible private static String CALLOUT_EXCEPTION_TEXT = 'Unauthorized endpoint, please check Setup->Security->Remote site settings.';
    @TestVisible private static String QUERY_TEXT = '{"query": "{contacts {id idOwner description person {information {firstName familyName}}}}"}';
    @TestVisible private static String QUERY_RESPONSE = '{"data": {"contacts": [{"id": "e9516fbc-6988-4a61-a0b8-fb9d6863692d", "idOwner": "c9bdc816-3b38-476e-96a3-df3158758bd4", "description": "", "person": {"information": {"firstName": "Wesley", "familyName": "Arendsen"} } } ] } }';
    @TestVisible private static String TOKEN = 'my-token-123';
    @TestVisible private static String TOKEN_RESPONSE = '{"data": {"authenticate": {"token": "' + TOKEN + '"} } }';

    public SalestrekkerServiceMock(Boolean isMockResponseException, Boolean isMockResponseError, String responseText) {
        this.isMockResponseException = isMockResponseException;
        this.isMockResponseError = isMockResponseError;
        this.responseText = responseText;
    }

    public HttpResponse respond(HttpRequest req) {

        if(this.isMockResponseException) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage(CALLOUT_EXCEPTION_TEXT);
            throw e;
        }

        String responseBody = responseText;

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseBody);
        res.setStatusCode(200);
        if(isMockResponseError) {res.setStatusCode(400);}

        return res;
    }

}