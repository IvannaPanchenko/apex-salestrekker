/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Opportunity_Provider_ProductTrigger on Opportunity_Provider_Product__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Opportunity_Provider_Product__c.SObjectType);
}