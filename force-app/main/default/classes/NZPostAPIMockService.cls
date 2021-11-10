/**
* @author Pablo Martinez (pablomartinez@deloitte.co.nz)
* @date 14/10/2019
* @description Mock response for the
* 
* CHANGE LOG
**/

public class NZPostAPIMockService implements HttpCalloutMock {
    
    public Boolean failed;

    public NZPostAPIMockService(Boolean failed) {

        this.failed = failed;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (this.failed) {
            res.setBody('{"errors": {"code": "500", "message": "Error getting the Token", "details": "Error getting the Token"}}"');
        } else {
            res.setBody('{"access_token": "tokenResponse"}');
        }
        res.setStatusCode(200);
        
        return res;
    }
}