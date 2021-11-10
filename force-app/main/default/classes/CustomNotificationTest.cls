/**
 * @author       Tiaan Swart (tswart@deloitte.co.nz)
 * @date         16/10/19
 * @description  CustomNotificationTest
 *
 * CHANGE LOG
 * 16/10/19 - Initial Setup of CustomNotificationTest
 **/
/**
  * Test code servers as a good demo of the FlowProcess mocking feature
  */
@IsTest
public inherited sharing class CustomNotificationTest {
    
    @IsTest
    private static void whenSendNotificationFlowVarsPassed() {

        // Create an Account
        Account newAccount = new Account(Name='Test Account');
        insert newAccount;

        // Create a mock runner for the flow
        FlowProcessRunner mockRunner = (FlowProcessRunner) Test.createStub(FlowProcessRunner.class, new RunnerMock());
        FlowProcess.setMock(mockRunner);

        new CustomNotification()
                .type( 'Flow_Custom_Notification' )
                .title( '{{ Name }} notification' )
                .body( 'Test message regarding {{ Name }}' )
                .recipients( new Set<Id>{UserInfo.getUserId()} )
                .target( newAccount.Id )
                .send();
    }

    private class RunnerMock implements System.StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            // Assert FlowProcess was passed the correct Flow name to resolve
            FlowProcess.ResolveByName resolver = (FlowProcess.ResolveByName) listOfArgs[0];
            System.assertEquals('SendCustomNotification', resolver.flowName);
            // Assert the passed variables
            Map<String, Object> inputs = (Map<String, Object>) listOfArgs[1];
            System.assert(String.isNotBlank((String) inputs.get('CustomNotificationTypeId')), 'Expected the Custom Notification Type Id to not be empty');
            System.assertEquals('Test Account notification', inputs.get('NotificationTitle'), 'Expected the Notification Title with merge fields resolved');
            System.assertEquals('Test message regarding Test Account', inputs.get('NotificationBody'), 'Expected the Notification Body with merge fields resolved');
            System.assertEquals(new List<Id>{UserInfo.getUserId()}, inputs.get('RecipientIds'), 'Expected the current user as the the only recipient');
            System.assertEquals(UserInfo.getUserId(), inputs.get('SenderId'), 'Expected the current user as the sender');
            // Mock a response from the Flow
            return new Map<String, Object>();
        }
    }
}