/**
* @author Pablo Martinez (pablomartinez@deloitte.co.nz)
* @date 14/10/2019
* @description Test class for the NZPostAPIService class.
* 
* CHANGE LOG
**/
@IsTest
public class NZPostAPIServiceTest {

    @IsTest
    static void testGetTokenFail () {

        Test.setMock(HttpCalloutMock.class, new NZPostAPIMockService(true));

        NZPostAPIService.settings = new NZ_Post_API_Service__c(URL_Token__c = 'tokenURL' , Client_Id__c='clientId', Client_Secret__c ='tokenSecret');

        NZPostAPIService.NZPostAPIData result = NZPostAPIService.getTokenAndData();

        System.assertEquals('Error getting the Token', ((Map<String,Object>) result.tokenResponse.get('errors')).get('message'));
    }

    @IsTest
    static void testGetToken () {

        Test.setMock(HttpCalloutMock.class, new NZPostAPIMockService(false));

        NZPostAPIService.settings = new NZ_Post_API_Service__c(URL_Token__c = 'tokenURL' , Client_Id__c='clientId', Client_Secret__c ='tokenSecret');

        NZPostAPIService.NZPostAPIData result = NZPostAPIService.getTokenAndData();

        System.assertEquals(result.tokenResponse.get('access_token'), 'tokenResponse');
    }
}