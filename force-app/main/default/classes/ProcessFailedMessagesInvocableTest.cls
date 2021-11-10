@isTest
private class ProcessFailedMessagesInvocableTest {
    
    @isTest
    static void testInvocable() {

        Test.startTest();

        ProcessFailedMessagesInvocable.invokeProcess();

        Test.stopTest();

    }
}