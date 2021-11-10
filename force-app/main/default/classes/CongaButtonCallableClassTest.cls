@IsTest
public class CongaButtonCallableClassTest {
    @IsTest
    static void testCallValidate() {
        Test.startTest();
        String validate = (String) CongaButtonCallableClass.call('validate', new Map<String, Object>{'recordId' => 'myId'});
        Test.stopTest();
        System.assertEquals(null, validate);
    }

    @IsTest
    static void testCallGetIds() {
        Test.startTest();
        String ids = (String) CongaButtonCallableClass.call('getIds', new Map<String, Object>{'recordId' => 'myId'});
        Test.stopTest();
        System.assertEquals('myId', ids);
    }

    @IsTest
    static void testCallNotDefined() {
        Test.startTest();
        try {
            String methodNotDefined = (String) CongaButtonCallableClass.call('methodNotDefined', new Map<String, Object>{'recordId' => 'myId'});
        }
        catch(CongaButtonCallableClass.CongaButtonCallableClass_Exception e) {
            System.assertEquals('Method not implemented', e.getMessage());
        }
        Test.stopTest();
    }
}