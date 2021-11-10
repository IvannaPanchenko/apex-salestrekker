/**
 * Description
 * Updates all policy role that are not in sync with the parent Policy
 * This batch class runs based on the Schedule Apex - PolicyRoleSyncScheduler
 * This is terminated based on the policy settings
 *
 * @author Jayson Faderanga
 * @date October 2018
 * @test PolicyRoleSyncBatchTest
 *
 * CHANGE LOG
 * 2019-05-16 - Add changes from AssetRoleSync to this Batch Class as well
 */
global without sharing class PolicyRoleSyncBatch implements Database.Batchable<sObject> {

    private PolicyRoleSyncSettings__c policySettings = PolicyRoleSyncSettings__c.getInstance();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('### policySettings >>> ' + policySettings);

        // Get the Last Job Run Time
        ApexClass thisClass = [SELECT Id FROM ApexClass WHERE Name = 'PolicyRoleSyncBatch' LIMIT 1];
        List<AsyncApexJob> jobs = [SELECT CreatedDate FROM AsyncApexJob WHERE ApexClassId =: thisClass.Id LIMIT 1];
        // This variable can be used with the Where Clause
        Datetime lastJobRunTime = jobs.isEmpty() || Test.isRunningTest() ? Datetime.newInstance(2000, 0, 0, 0, 0, 0) : jobs[0].CreatedDate;

        System.debug('### lastJobRunTime >>> ' + lastJobRunTime);

        // Return the Query Locator
        return Database.getQueryLocator('SELECT Id, Policy_Status__c, Policy_Total_Premium__c, Policy_Type__c, '
                + 'Policy__c, Policy__r.Policy_Status__c, Policy__r.Total_Premium__c, Policy__r.Type__c '
                + 'FROM Policy_Role__c' + (String.isNotBlank(policySettings.Where_Clause__c) ? ' WHERE ' + policySettings.Where_Clause__c : ''));
    }

    public void execute(Database.BatchableContext bc, List<Policy_Role__c> policyRoles) {

        System.debug('### policyRoles.size() >>> ' + policyRoles.size());

        List<Policy_Role__c> rolesToUpdate = new List<Policy_Role__c>();

        for (Policy_Role__c role : policyRoles) {
            if (isRoleValidForUpdate(role)) {

                System.debug('### role before >>> ' + role);

                rolesToUpdate.add(new Policy_Role__c(
                    Id = role.Id,
                    Policy_Status__c = role.Policy__r.Policy_Status__c,
                    Policy_Type__c = role.Policy__r.Type__c,
                    Policy_Total_Premium__c = role.Policy__r.Total_Premium__c
                ));
            }
        }

        // Update rolesToUpdate if we have any
        if (!rolesToUpdate.isEmpty()) {
            List<Database.SaveResult> saveResults = Database.update(rolesToUpdate, false);

            // Log the errors
            for (Database.SaveResult saveResult : saveResults) {
                if (!saveResult.isSuccess()) {
                    System.debug('PolicyRoleSyncBatch error: ' + saveResult.getErrors());
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        Time timeNow = System.now().time();

        if (policySettings != null && String.isNotBlank(policySettings.Stop_Time__c)) {

            String meridiem = policySettings.Stop_Time__c.substringAfter(' ');
            Integer stopHour = Integer.valueOf(policySettings.Stop_Time__c.substringBefore(':')) + (meridiem == 'PM' ? 12 : 0);
            Integer stopMinutes = Integer.valueOf(policySettings.Stop_Time__c.substringAfter(':').substringBefore(' '));
            Time stopTime = Time.newInstance(stopHour, stopMinutes, 0, 0);

            if (timeNow <= stopTime) {
                System.scheduleBatch(new PolicyRoleSyncBatch(), 'PolicyRoleSyncBatch', 1, Integer.valueOf(policySettings.Sync_Batch_Size__c));
            }
        }
    }

    private Boolean isRoleValidForUpdate(Policy_Role__c role) {
        return role.Policy_Status__c != role.Policy__r.Policy_Status__c || role.Policy_Type__c != role.Policy__r.Type__c
               || role.Policy_Total_Premium__c != role.Policy__r.Total_Premium__c;
    }
}