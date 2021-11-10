/**
 * @author Pablo Martinez (pablomartinex@deloitte.co.nz)
 * @date 05/07/2019
 * @description  LiabilityRoleSyncScheduler
 * 
 * CHANGE LOG
 * 05/07/2019 - Initial Setup of LiabilityRoleSyncScheduler
 **/
global without sharing class LiabilityRoleSyncScheduler implements Schedulable {

    // Settings relating to the batch execution
    private LiabilityRoleSyncSettings__c liabilitySettings = LiabilityRoleSyncSettings__c.getInstance();

    global void execute (SchedulableContext sc) {
        Database.executeBatch(
            new LiabilityRoleSyncBatch(),
                liabilitySettings.Sync_Batch_Size__c != null ? Integer.valueOf(liabilitySettings.Sync_Batch_Size__c) : 200
        );
    }
}