/**
 * Description
 * This class initiates the run time of PolicyRoleSyncBatch
 *
 * @author Jayson Faderanga
 * @date October 2018
 * @test PolicyRoleSyncBatch
 */
global without sharing class PolicyRoleSyncScheduler implements Schedulable {

    // Settings relating to the batch execution
    private PolicyRoleSyncSettings__c policySettings = PolicyRoleSyncSettings__c.getInstance();

    global void execute (SchedulableContext sc) {
        Database.executeBatch(
            new PolicyRoleSyncBatch(),
            policySettings.Sync_Batch_Size__c != null ? Integer.valueOf(policySettings.Sync_Batch_Size__c) : 200
        );
    }
}