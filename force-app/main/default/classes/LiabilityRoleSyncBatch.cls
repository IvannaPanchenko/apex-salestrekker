/**
* @author Pablo Martinez (pablomartinex@deloitte.co.nz)
* @date 05/07/2019
 * @description  LiabilityRoleSyncBatch (Is based on the logic in PolicyRoleSyncBatch)
 *               This logic lives in a batch and because of various flows executing and locking transactions
 * 
 * CHANGE LOG
 * 2019-05-16 - Initial Setup of LiabilityRoleSyncBatch
 **/
public with sharing class LiabilityRoleSyncBatch implements Database.Batchable<SObject> {

    // Settings relating to the batch execution
    private LiabilityRoleSyncSettings__c liabilitySettings = LiabilityRoleSyncSettings__c.getInstance();

    // Query locator to determine records and number of batches
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('### liabilitySettings >>> ' + liabilitySettings);

        // Get the Last Job Run Time
        ApexClass thisClass = [SELECT Id FROM ApexClass WHERE Name = 'LiabilityRoleSyncBatch' LIMIT 1];
        List<AsyncApexJob> jobs = [SELECT CreatedDate FROM AsyncApexJob WHERE ApexClassId =: thisClass.Id LIMIT 1];
        // This variable can be used with the Where Clause
        Datetime lastJobRunTime = jobs.isEmpty() || Test.isRunningTest() ? Datetime.newInstance(2000, 0, 0, 0, 0, 0) : jobs[0].CreatedDate;

        System.debug('### lastJobRunTime >>> ' + lastJobRunTime);

        // Return the Query Locator
        return Database.getQueryLocator(
                'SELECT Id, Liability_Type__c, Liability_Value__c, Liability_Serviced_By_Apex__c, Liability_Status__c, Liability__c,' +
                ' Liability__r.Type__c, Liability__r.Serviced_by_Apex__c, Liability__r.Current_Balance__c, Liability__r.Status__c, Account__c, Account__r.Partner__c, Joint_with_Partner__c ' +
                'FROM Liability_Role__c' + (String.isNotBlank(liabilitySettings.Where_Clause__c) ? ' WHERE ' + liabilitySettings.Where_Clause__c : '')
        );
    }

    // Batch logic
    public void execute(Database.BatchableContext bc, List<Liability_Role__c> liabilityRoles) {

        System.debug('### liabilityRoles.size() >>> ' + liabilityRoles.size());

        // Get Liability Id's and Partner Ids
        Set<Id> liabilityIds = new Set<Id>();
        Set<Id> partnerIds = new Set<Id>();
        for (Liability_Role__c role : liabilityRoles) {
            if (String.isNotBlank(role.Liability__c)) liabilityIds.add(role.Liability__c);
            if (String.isNotBlank(role.Account__c) && String.isNotBlank(role.Account__r.Partner__c)) partnerIds.add(role.Account__r.Partner__c);
        }

        System.debug('### liabilityIds >>> ' + liabilityIds);
        System.debug('### partnerIds >>> ' + partnerIds);

        // Get a Map of related roles mapped by Account Id (Partner Account Ad) and Liability Id
        Map<String, List<Liability_Role__c>> relatedRolesMap = new Map<String, List<Liability_Role__c>>();
        for (Liability_Role__c relatedRole : [SELECT Liability__c, Account__c FROM Liability_Role__c WHERE Liability__c IN :liabilityIds AND Account__c IN :partnerIds]) {
            String key = relatedRole.Liability__c + '' + relatedRole.Account__c;
            if (!relatedRolesMap.containsKey(key)) relatedRolesMap.put(key, new List<Liability_Role__c>());
            relatedRolesMap.get(key).add(relatedRole);
        }

        System.debug('### relatedRolesMap.keySet() >>> ' + relatedRolesMap.keySet());

        // Construct a list of roles to update
        List<Liability_Role__c> rolesToUpdate = new List<Liability_Role__c>();

        for (Liability_Role__c role : liabilityRoles) {
            // Joint Asset Key
            String key = role.Liability__c + '' + role.Account__r.Partner__c;

            // Flag for Joint with Partner
            Boolean jointWithPartner = relatedRolesMap.containsKey(key) && !relatedRolesMap.get(key).isEmpty();

            // Check if the role should be updated
            if (isRoleValidForUpdate(role, jointWithPartner)) {

                System.debug('### role before >>> ' + role);

                // Add the role to the list of roles to be updated.
                rolesToUpdate.add(new Liability_Role__c(
                    Id = role.Id,
                    Liability_Type__c = role.Liability__r.Type__c,
                    Liability_Value__c = role.Liability__r.Current_Balance__c,
                    Liability_Serviced_By_Apex__c = role.Liability__r.Serviced_by_Apex__c,
                    Liability_Status__c = role.Liability__r.Status__c,
                    Joint_with_Partner__c = jointWithPartner
                ));
            }
        }

        // Update roles if we have any
        if (!rolesToUpdate.isEmpty()) {
            List<Database.SaveResult> saveResults = Database.update(rolesToUpdate, false);

            // Log the errors
            for (Database.SaveResult saveResult : saveResults) {
                if (!saveResult.isSuccess()) {
                    System.debug('LiabilityRoleSyncBatch error: ' + saveResult.getErrors());
                }
            }
        }
    }

    // Finish logic to execute the schedule of the batch again
    public void finish(Database.BatchableContext BC) {
        Time timeNow = System.now().time();

        if (liabilitySettings != null && String.isNotBlank(liabilitySettings.Stop_Time__c)) {

            String meridiem = liabilitySettings.Stop_Time__c.substringAfter(' ');
            Integer stopHour = Integer.valueOf(liabilitySettings.Stop_Time__c.substringBefore(':')) + (meridiem == 'PM' ? 12 : 0);
            Integer stopMinutes = Integer.valueOf(liabilitySettings.Stop_Time__c.substringAfter(':').substringBefore(' '));
            Time stopTime = Time.newInstance(stopHour, stopMinutes, 0, 0);

            if (timeNow <= stopTime && !Test.isRunningTest()) {
                System.scheduleBatch(new LiabilityRoleSyncBatch(), 'LiabilityRoleSyncBatch', 1,liabilitySettings.Sync_Batch_Size__c != null ? Integer.valueOf(liabilitySettings.Sync_Batch_Size__c) : 200);
            }
        }
    }

    // Validation utility to verify that the record needs to be updated
    private Boolean isRoleValidForUpdate(Liability_Role__c role, Boolean jointWithPartner) {
        return role.Liability_Type__c != role.Liability__r.Type__c || role.Liability_Value__c != role.Liability__r.Current_Balance__c || role.Liability_Serviced_By_Apex__c != role.Liability__r.Serviced_by_Apex__c
                || role.Liability_Status__c != role.Liability__r.Status__c || role.Joint_with_Partner__c != jointWithPartner;
    }
}