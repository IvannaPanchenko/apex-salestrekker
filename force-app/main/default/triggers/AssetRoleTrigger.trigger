/**
* @author David (dcatindoy@deloitte.co.nz)
* @date May 6, 2019
* @description Trigger on Asset Role.
*
* CHANGE LOG
**/
trigger AssetRoleTrigger on Asset_Role__c (before insert, before update) {

    // Make sure this will only be called before DML action
    // in case in the future "after DML" operations is going to be added
    if (trigger.isBefore) {
        // Call method to link master account
        AssetRoleTriggerHandler.linkPrimaryOwner(
            Trigger.new
        );

    }

}