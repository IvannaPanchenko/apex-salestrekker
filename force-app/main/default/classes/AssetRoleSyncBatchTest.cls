/**
 * @author       Tiaan Swart (tswart@deloitte.co.nz)
 * @date         2019-05-16
 * @description  AssetRoleSyncBatchTest
 * 
 * CHANGE LOG
 * 2019-05-16 - Initial Setup of AssetRoleSyncBatchTest
 **/
@IsTest
private class AssetRoleSyncBatchTest {

    @IsTest
    static void runBatchFromScheduleTest() {

        String timeNow = System.now().addMinutes(-1).format('h:mm a');

        insert new AssetRoleSyncSettings__c(
            Stop_Time__c = timeNow,
            Sync_Batch_Size__c = 1000
        );

        List<Account> accounts = new List<Account>();

        Account account = TestData.createPersonAccount(true, 'Test');
        accounts.add(account);
        Account partnerAccount = TestData.createPersonAccount(true, 'Partner Test');
        accounts.add(partnerAccount);

        account.Partner__c = partnerAccount.Id;
        account.Partner_Status__pc = 'Primary Partner';
        partnerAccount.Partner__c = account.Id;
        partnerAccount.Partner_Status__pc = 'Secondary Partner';
        update accounts;

        Client_Asset__c asset = TestData.createAsset(true);
        Asset_Role__c role = TestData.createAssetRole(true, asset.Id, account.Id);
        Asset_Role__c partnerRole = TestData.createAssetRole(true, asset.Id, partnerAccount.Id);

        Test.startTest();
        new AssetRoleSyncScheduler().execute(null);
        Test.stopTest();

        System.assertEquals(
                [SELECT Type__c FROM Client_Asset__c WHERE Id = :asset.Id].Type__c,
                [SELECT Asset_Type__c FROM Asset_Role__c WHERE Id = :role.Id].Asset_Type__c,
                'Role Type did not get updated'
        );

        System.assertEquals(
                [SELECT Value__c FROM Client_Asset__c WHERE Id = :asset.Id].Value__c,
                [SELECT Asset_Value__c FROM Asset_Role__c WHERE Id = :role.Id].Asset_Value__c,
                'Role Value did not get updated'
        );

        System.assertEquals(
                [SELECT Status__c FROM Client_Asset__c WHERE Id = :asset.Id].Status__c,
                [SELECT Asset_Status__c FROM Asset_Role__c WHERE Id = :role.Id].Asset_Status__c,
                'Role Status did not get updated'
        );

        System.assertEquals(
                true,
                [SELECT Joint_with_Partner__c FROM Asset_Role__c WHERE Id = :role.Id].Joint_with_Partner__c,
                'Role should be marked as Joint'
        );
    }
}