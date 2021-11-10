@IsTest
public class CongaButtonControllerTest {
    @IsTest
    static void testGetApiURL() {
        Test.startTest();
        String url = CongaButtonController.getApiURL();
        Test.stopTest();
        System.assertNotEquals(null, url);
    }

    @IsTest
    static void testCallMethod() {
        Test.startTest();
        String ids = CongaButtonController.callMethod('CongaButtonCallableClass', 'getIds', 'myId');
        Test.stopTest();
        System.assertEquals('myId', ids);
    }
}