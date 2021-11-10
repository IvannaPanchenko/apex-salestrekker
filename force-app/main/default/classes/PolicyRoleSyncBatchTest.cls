/**
 * Description
 * TestClass for PolicyRoleSyncBatch
 *
 * @author Jayson Faderanga
 * @date October 2018
 */
@isTest
public with sharing class PolicyRoleSyncBatchTest {

    @isTest static void runBatchFromScheduleTest() {

        String timeNow = System.now().addMinutes(-1).format('h:mm a');

        insert new PolicyRoleSyncSettings__c(
            Stop_Time__c = timeNow,
            Sync_Batch_Size__c = 1
        );

        Account account = TestData.createAccount();
        Policy__c policy = TestData.createPolicy(true);
        Policy_Role__c role = TestData.createPolicyRole(true, account.Id, policy.Id);

        Test.startTest();
            new PolicyRoleSyncScheduler().execute(null);
        Test.stopTest();

        System.assertEquals(
            [SELECT Type__c FROM Policy__c WHERE Id = :policy.Id].Type__c,
            [SELECT Policy_Type__c FROM Policy_Role__c WHERE Id = :role.Id].Policy_Type__c,
            'Role did not get updated'
        );
    }
}