/**
 * @author       Tiaan Swart (tswart@deloitte.co.nz)
 * @date         2019-05-16
 * @description  AssetRoleSyncScheduler
 * 
 * CHANGE LOG
 * 2019-05-16 - Initial Setup of AssetRoleSyncScheduler
 **/
global without sharing class AssetRoleSyncScheduler implements Schedulable {

    // Settings relating to the batch execution
    private AssetRoleSyncSettings__c assetSettings = AssetRoleSyncSettings__c.getInstance();

    global void execute (SchedulableContext sc) {
        Database.executeBatch(
            new AssetRoleSyncBatch(),
            assetSettings.Sync_Batch_Size__c != null ? Integer.valueOf(assetSettings.Sync_Batch_Size__c) : 200
        );
    }
}