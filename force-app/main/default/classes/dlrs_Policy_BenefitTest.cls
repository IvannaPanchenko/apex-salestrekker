/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Policy_BenefitTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Policy_BenefitTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Policy_Benefit__c());
    }
}