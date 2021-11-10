/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Opportunity_Provider_ProductTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Opportunity_Provider_ProductTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Opportunity_Provider_Product__c());
    }
}