public with sharing class NZPostAPIService {
	public static NZ_Post_API_Service__c settings = NZ_Post_API_Service__c.getOrgDefaults();

    public static Map<String, Object> tokenResponse;

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to get the token response from NZPost
    *   @return The returned map of the response from NZPost
    **/
    @AuraEnabled
    public static NZPostAPIData getTokenAndData() {
    	if (tokenResponse == null) {
            try {
                tokenResponse = new Map<String,Object>();
                // Build the request to login to the API
                HttpRequest req = new HttpRequest();
                req.setEndpoint(settings.URL_Token__c);
                req.setMethod('POST');
                req.setTimeout(60000); // 60 seconds

                // Set the body including the credentials
                req.setBody(
                    String.format(
                        'grant_type=client_credentials&client_id={0}&client_secret={1}', 
                        new List<String>{settings.Client_Id__c, settings.Client_Secret__c}
                    )
                );

                // set header only for testing
                req.setHeader('method', 'login');
                
                // call to login
                HttpResponse response = new Http().send(req);

                // return response
                tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            } catch (Exception ex) {
                tokenResponse = null;
                throw new AuraHandledException('Error calling the NZ POST API Service ' + ex.getMessage() + ' / ' + ex.getStackTraceString());
            }
        }

        return new NZPostAPIData(tokenResponse, settings.URL_API__c);
    }

    public class NZPostAPIData {
        @AuraEnabled
        public Map<String,Object> tokenResponse;

        @AuraEnabled
        public String apiURL;

        public NZPostAPIData (Map<String,Object> token, String apiURL) {
            this.tokenResponse = token;
            this.apiURL = apiURL;
        }
    }
}