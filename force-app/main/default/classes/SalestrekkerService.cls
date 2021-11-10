/*************************************************************************************************************
 * @name			SalestrekkerService
 * @author			James Winter <james@beintelligent.nz>
 * @created			13th September 2021
 * @description		Class to send Requests to Salestrekker
 * @testClass       SalestrekkerServiceTest
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-13      James Winter			Creation of the class
 *
**************************************************************************************************************/
public without sharing class SalestrekkerService {

    @TestVisible private static String token;
    @TestVisible private static List<Exception_Event__e> eventList = new List<Exception_Event__e>();


    /*********************************************************************************************************
      * @name			salestrekkerSend
      * @author			James Winter <james@beintelligent.nz>
      * @created		13th September 2021
      * @description	Send a request to Salestrekker
      * @param			requestBody : Request Body as String
      * @return			HttpResponse : Full response from the service
     **********************************************************************************************************/
    public static HttpResponse salestrekkerSend(String requestBody) {

        getToken();

        return doSend(requestBody);
    }

    /*********************************************************************************************************
  * @name			doSend
  * @author			James Winter <james@beintelligent.nz>
  * @created		13th September 2021
  * @description	Send a request to Salestrekker
  * @param			requestBody : Request Body as String
  * @return			HttpResponse : Full response from the service
 **********************************************************************************************************/
    public static HttpResponse doSend(String requestBody) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Salestrekker');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer '+ token);
        req.setBody(requestBody);

        HttpResponse httpResponse = new HttpResponse();
        try {
            httpResponse = new Http().send(req);
            System.debug(httpResponse.getBody());
        } catch (CalloutException e) {
            Exception_Event__e myException = new Exception_Event__e(Function__c='CalloutException from SalestrekkerService',
                    Additional_Information__c=e.getMessage().left(131072), Exception_Details__c=e.getStackTraceString().left(131072));
            eventList.add(myException);
            EventBus.publish(eventList);
        }
        return httpResponse;
    }

    /*********************************************************************************************************
      * @name			getToken
      * @author			James Winter <james@beintelligent.nz>
      * @created		13th September 2021
      * @description	Send a request to Salestrekker to get a auth token
      * @return			HttpResponse : Full response from the service
     **********************************************************************************************************/
    public static HttpResponse getToken(){

        tokenClassResponse response = new tokenClassResponse();

        if (Cache.Org.contains('local.salestrekker.token')) {
            token = (String) Cache.Org.get('local.salestrekker.token');
            return null;
        }

        String requestBody = SalestrekkerAuth.createAuthPayload();

        HttpResponse httpResponse = doSend(requestBody);

        response = (tokenClassResponse) System.JSON.deserialize(httpResponse.getBody(), tokenClassResponse.class);
        
        System.debug('########### RESPONSE'+ response);
        System.debug('########### data'+ response?.data);
        System.debug('########### authenticate'+ response?.data?.authenticate);
        System.debug('########### token'+ response?.data?.authenticate?.token);
        token = response?.data?.authenticate?.token;
        Cache.Org.put('local.salestrekker.token', token, 3600);
        return httpResponse;
    }

    // These wrapper classes are probably overkill given the response is pretty basic
    // but does allow us to deserialize simply
    public class tokenClassResponse{
        public Data data;
    }

    public class Data {
        public Authenticate authenticate;
    }

    public class Authenticate {
        public String token;
        public Integer code;
    }

}