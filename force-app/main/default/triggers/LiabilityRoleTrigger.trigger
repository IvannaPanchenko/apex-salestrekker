/**
* @author Pablo Martinez (pablomartinex@deloitte.co.nz)
* @date 05/07/2019
* @description Trigger on Liability Role.
*
* CHANGE LOG
**/
trigger LiabilityRoleTrigger on Liability_Role__c (before insert, before update) {

    // Make sure this will only be called before DML action
    // in case in the future "after DML" operations is going to be added
    if (trigger.isBefore) {
        // Call method to link master account
        LiabilityRoleTriggerHandler.linkPrimaryOwner(
                Trigger.new
        );

    }

}