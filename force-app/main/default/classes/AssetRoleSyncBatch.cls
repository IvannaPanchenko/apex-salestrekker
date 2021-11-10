/**
 * @author       Tiaan Swart (tswart@deloitte.co.nz)
 * @date         2019-05-16
 * @description  AssetRoleSyncBatch (Is based on the logic in PolicyRoleSyncBatch)
 *               This logic lives in a batch and because of various flows executing and locking transactions
 * 
 * CHANGE LOG
 * 2019-05-16 - Initial Setup of AssetRoleSyncBatch
 **/
public with sharing class AssetRoleSyncBatch implements Database.Batchable<SObject> {

    // Settings relating to the batch execution
    private AssetRoleSyncSettings__c assetSettings = AssetRoleSyncSettings__c.getInstance();

    // Query locator to determine records and number of batches
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('### assetSettings >>> ' + assetSettings);

        // Get the Last Job Run Time
        ApexClass thisClass = [SELECT Id FROM ApexClass WHERE Name = 'AssetRoleSyncBatch' LIMIT 1];
        List<AsyncApexJob> jobs = [SELECT CreatedDate FROM AsyncApexJob WHERE ApexClassId =: thisClass.Id LIMIT 1];
        // This variable can be used with the Where Clause
        Datetime lastJobRunTime = jobs.isEmpty() || Test.isRunningTest() ? Datetime.newInstance(2000, 0, 0, 0, 0, 0) : jobs[0].CreatedDate;

        System.debug('### lastJobRunTime >>> ' + lastJobRunTime);

        // Return the Query Locator
        return Database.getQueryLocator(
                'SELECT Id, Asset_Type__c, Asset_Value__c, Asset_Status__c, Asset__c,' +
                ' Asset__r.Type__c, Asset__r.Value__c, Asset__r.Status__c, Account__c, Account__r.Partner__c, Joint_with_Partner__c, Asset_Serviced_By_Apex__c, Asset__r.Serviced_By_Apex__c ' +
                'FROM Asset_Role__c' + (String.isNotBlank(assetSettings.Where_Clause__c) ? ' WHERE ' + assetSettings.Where_Clause__c : '')
        );
    }

    // Batch logic
    public void execute(Database.BatchableContext bc, List<Asset_Role__c> assetRoles) {

        System.debug('### assetRoles.size() >>> ' + assetRoles.size());

        // Get Asset Id's and Partner Ids
        Set<Id> assetIds = new Set<Id>();
        Set<Id> partnerIds = new Set<Id>();
        for (Asset_Role__c role : assetRoles) {
            if (String.isNotBlank(role.Asset__c)) assetIds.add(role.Asset__c);
            if (String.isNotBlank(role.Account__c) && String.isNotBlank(role.Account__r.Partner__c)) partnerIds.add(role.Account__r.Partner__c);
        }

        System.debug('### assetIds >>> ' + assetIds);
        System.debug('### partnerIds >>> ' + partnerIds);

        // Get a Map of related roles mapped by Account Id (Partner Account Ad) and Asset Id
        Map<String, List<Asset_Role__c>> relatedRolesMap = new Map<String, List<Asset_Role__c>>();
        for (Asset_Role__c relatedRole : [SELECT Asset__c, Account__c FROM Asset_Role__c WHERE Asset__c IN: assetIds AND Account__c IN: partnerIds]) {
            String key = relatedRole.Asset__c + '' + relatedRole.Account__c;
            if (!relatedRolesMap.containsKey(key)) relatedRolesMap.put(key, new List<Asset_Role__c>());
            relatedRolesMap.get(key).add(relatedRole);
        }

        System.debug('### relatedRolesMap.keySet() >>> ' + relatedRolesMap.keySet());

        // Construct a list of roles to update
        List<Asset_Role__c> rolesToUpdate = new List<Asset_Role__c>();

        for (Asset_Role__c role : assetRoles) {
            // Joint Asset Key
            String key = role.Asset__c + '' + role.Account__r.Partner__c;

            // Flag for Joint with Partner
            Boolean jointWithPartner = relatedRolesMap.containsKey(key) && !relatedRolesMap.get(key).isEmpty();

            // Check if the role should be updated
            if (isRoleValidForUpdate(role, jointWithPartner)) {

                System.debug('### role before >>> ' + role);

                // Add the role to the list of roles to be updated.
                rolesToUpdate.add(new Asset_Role__c(
                    Id = role.Id,
                    Asset_Type__c = role.Asset__r.Type__c,
                    Asset_Value__c = role.Asset__r.Value__c,
                    Asset_Status__c = role.Asset__r.Status__c,
                    Joint_with_Partner__c = jointWithPartner,
                    Asset_Serviced_By_Apex__c = role.Asset__r.Serviced_By_Apex__c
                ));
            }
        }

        // Update roles if we have any
        if (!rolesToUpdate.isEmpty()) {
            List<Database.SaveResult> saveResults = Database.update(rolesToUpdate, false);

            // Log the errors
            for (Database.SaveResult saveResult : saveResults) {
                if (!saveResult.isSuccess()) {
                    System.debug('AssetRoleSyncBatch error: ' + saveResult.getErrors());
                }
            }
        }
    }

    // Finish logic to execute the schedule of the batch again
    public void finish(Database.BatchableContext BC) {
        Time timeNow = System.now().time();

        if (assetSettings != null && String.isNotBlank(assetSettings.Stop_Time__c)) {

            String meridiem = assetSettings.Stop_Time__c.substringAfter(' ');
            Integer stopHour = Integer.valueOf(assetSettings.Stop_Time__c.substringBefore(':')) + (meridiem == 'PM' ? 12 : 0);
            Integer stopMinutes = Integer.valueOf(assetSettings.Stop_Time__c.substringAfter(':').substringBefore(' '));
            Time stopTime = Time.newInstance(stopHour, stopMinutes, 0, 0);

            if (timeNow <= stopTime && !Test.isRunningTest()) {
                System.scheduleBatch(new AssetRoleSyncBatch(), 'AssetRoleSyncBatch', 1,assetSettings.Sync_Batch_Size__c != null ? Integer.valueOf(assetSettings.Sync_Batch_Size__c) : 200);
            }
        }
    }

    // Validation utility to verify that the record needs to be updated
    private Boolean isRoleValidForUpdate(Asset_Role__c role, Boolean jointWithPartner) {
        return role.Asset_Type__c != role.Asset__r.Type__c || role.Asset_Value__c != role.Asset__r.Value__c
                || role.Asset_Status__c != role.Asset__r.Status__c || role.Joint_with_Partner__c != jointWithPartner || role.Asset_Serviced_by_Apex__c != role.Asset__r.Serviced_by_Apex__c;
    }
}