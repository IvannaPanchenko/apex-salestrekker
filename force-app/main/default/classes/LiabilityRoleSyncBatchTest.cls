/**
 * @author Pablo Martinez (pablomartinex@deloitte.co.nz)
 * @date 05/07/2019
 * @description  LiabilityRoleSyncBatchTest
 * 
 * CHANGE LOG
 * 05/07/2019 - Initial Setup of LiabilityRoleSyncBatchTest
 **/
@IsTest
private class LiabilityRoleSyncBatchTest {

    @IsTest
    static void runBatchFromScheduleTest() {

        String timeNow = System.now().addMinutes(-1).format('h:mm a');

        insert new LiabilityRoleSyncSettings__c(
            Stop_Time__c = timeNow,
            Sync_Batch_Size__c = 1000
        );

        List<Account> accounts = new List<Account>();

        Account account = TestData.createPersonAccount(true, 'Test');
        accounts.add(account);
        Account partnerAccount = TestData.createPersonAccount(true, 'Partner Test99');
        accounts.add(partnerAccount);

        account.Partner__c = partnerAccount.Id;
        account.Partner_Status__pc = 'Primary Partner';
        partnerAccount.Partner__c = account.Id;
        partnerAccount.Partner_Status__pc = 'Secondary Partner';
        update accounts;

        Liability__c liability = TestData.createLiability(true, false);
        Liability_Role__c role = TestData.createLiabilityRole(true, liability.Id, account.Id);
        Liability_Role__c partnerRole = TestData.createLiabilityRole(true, liability.Id, partnerAccount.Id);

        Test.startTest();
        new LiabilityRoleSyncScheduler().execute(null);
        Test.stopTest();

        System.assertEquals(
                [SELECT Type__c FROM Liability__c WHERE Id = :liability.Id].Type__c,
                [SELECT Liability_Type__c FROM Liability_Role__c WHERE Id = :role.Id].Liability_Type__c,
                'Role Type did not get updated'
        );

        System.assertEquals(
                [SELECT Current_Balance__c FROM Liability__c WHERE Id = :liability.Id].Current_Balance__c,
                [SELECT Liability_Value__c FROM Liability_Role__c WHERE Id = :role.Id].Liability_Value__c,
                'Role Value did not get updated'
        );
        
        System.assertEquals(
                [SELECT Serviced_by_Apex__c FROM Liability__c WHERE Id = :liability.Id].Serviced_by_Apex__c,
                [SELECT Liability_Serviced_By_Apex__c FROM Liability_Role__c WHERE Id = :role.Id].Liability_Serviced_By_Apex__c,
                'Serviced by Apex did not get updated'
        );

        System.assertEquals(
                [SELECT Status__c FROM Liability__c WHERE Id = :liability.Id].Status__c,
                [SELECT Liability_Status__c FROM Liability_Role__c WHERE Id = :role.Id].Liability_Status__c,
                'Role Status did not get updated'
        );

        System.assertEquals(
                true,
                [SELECT Joint_with_Partner__c FROM Liability_Role__c WHERE Id = :role.Id].Joint_with_Partner__c,
                'Role should be marked as Joint'
        );
    }
}