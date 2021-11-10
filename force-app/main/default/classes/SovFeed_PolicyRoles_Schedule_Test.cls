/**
 * Description
 * TestClass for SovFeed_PolicyRoles_Schedule and SovFeed_PolicyRoles_Delete_Batch
 *
 * @author Jacob Taljaard
 * @date December 2018
 */
@isTest
public without sharing class SovFeed_PolicyRoles_Schedule_Test {

    @isTest static void runBatchFromScheduleTest() {

        insert new Apex_Admin_Settings__c(
            Sov_Policy_Roles_Delete_Script__c = 'SELECT Id FROM Policy_Role__c WHERE Policy_Provider_ID__c IN (\'sov\')'
        );

        Account account = TestData.createPersonAccount(true,'TEST PERSON');
        Account provider = TestData.createBusinessAccountWithProviderId(true,'Sovereign Test','sov');
        Policy__c policy = TestData.createPolicyWithProvider(true,provider.Id);
        Policy_Role__c role = TestData.createPolicyRole(true, account.Id, policy.Id);
        Policy_Benefit__c benefit = TestData.createPolicyBenefit(true, account.Id, policy.Id); 

        System.assertEquals(
            1,
            [SELECT Id FROM Policy_Role__c WHERE Policy_Provider_ID__c = 'sov'].SIZE(),
            'Roles not created'
        );

        Test.startTest();
            new SovFeed_PolicyRoles_Schedule().execute(null);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT Id FROM Policy_Role__c WHERE Policy_Provider_ID__c = 'sov'].SIZE(),
            'Roles not deleted'
        );
    }

    @isTest static void runBatchFromScheduleTestMultipleProviders() {

        String timeNow = System.now().addMinutes(-1).format('h:mm a');

        insert new Apex_Admin_Settings__c(
            Sov_Policy_Roles_Delete_Script__c = 'SELECT Id FROM Policy_Role__c WHERE Policy_Provider_ID__c IN (\'sov\',\'sov2\')'
        );

        Account account = TestData.createPersonAccount(true,'TEST PERSON');
        Account provider = TestData.createBusinessAccountWithProviderId(true,'Sovereign Test','sov');
        Policy__c policy = TestData.createPolicyWithProvider(true,provider.Id);
        Policy_Role__c role = TestData.createPolicyRole(true, account.Id, policy.Id);
        Policy_Benefit__c benefit = TestData.createPolicyBenefit(true, account.Id, policy.Id); 

        Account account2 = TestData.createPersonAccount(true,'TEST HUMAN2');
        Account provider2 = TestData.createBusinessAccountWithProviderId(true,'Sovereign Test2','sov2');
        Policy__c policy2 = TestData.createPolicyWithProvider(true,provider2.Id);
        Policy_Role__c role2 = TestData.createPolicyRole(true, account2.Id, policy2.Id);
        Policy_Benefit__c benefit2 = TestData.createPolicyBenefit(true, account2.Id, policy2.Id); 

        System.assertEquals(
            2,
            [SELECT Id FROM Policy_Role__c WHERE Policy_Provider_ID__c = 'sov' or Policy_Provider_ID__c = 'sov2' ].SIZE(),
            'Roles not created'
        );

        Test.startTest();
            new SovFeed_PolicyRoles_Schedule().execute(null);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT Id FROM Policy_Role__c WHERE Policy_Provider_ID__c = 'sov' or Policy_Provider_ID__c = 'sov2' ].SIZE(),
            'Roles not deleted'
        );
    }

    @isTest static void testInvocable() {

        String timeNow = System.now().addMinutes(-1).format('h:mm a');

        insert new Apex_Admin_Settings__c(
                Sov_Policy_Roles_Delete_Script__c = 'SELECT Id FROM Policy_Role__c WHERE Policy_Provider_ID__c IN (\'sov\',\'sov2\')'
        );

        Account account = TestData.createPersonAccount(true,'TEST PERSON');
        Account provider = TestData.createBusinessAccountWithProviderId(true,'Sovereign Test','sov');
        Policy__c policy = TestData.createPolicyWithProvider(true,provider.Id);
        Policy_Role__c role = TestData.createPolicyRole(true, account.Id, policy.Id);
        Policy_Benefit__c benefit = TestData.createPolicyBenefit(true, account.Id, policy.Id);

        Account account2 = TestData.createPersonAccount(true,'TEST HUMAN2');
        Account provider2 = TestData.createBusinessAccountWithProviderId(true,'Sovereign Test2','sov2');
        Policy__c policy2 = TestData.createPolicyWithProvider(true,provider2.Id);
        Policy_Role__c role2 = TestData.createPolicyRole(true, account2.Id, policy2.Id);
        Policy_Benefit__c benefit2 = TestData.createPolicyBenefit(true, account2.Id, policy2.Id);

        System.assertEquals(
                2,
                [SELECT Id FROM Policy_Role__c WHERE Policy_Provider_ID__c = 'sov' or Policy_Provider_ID__c = 'sov2' ].SIZE(),
                'Roles not created'
        );

        Test.startTest();
            SovFeed_PolicyRoles_Delete_Batch.invokePolicyRolesDeleteBatch();
        Test.stopTest();

        System.assertEquals(
                0,
                [SELECT Id FROM Policy_Role__c WHERE Policy_Provider_ID__c = 'sov' or Policy_Provider_ID__c = 'sov2' ].SIZE(),
                'Roles not deleted'
        );
    }
}