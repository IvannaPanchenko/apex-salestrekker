/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Oct 14, 2020
* @description Test class for LookupRollupCalculator class
*
* CHANGE LOG
*
**/

@isTest
public class LookupRollupCalculatorTest {
    

    @TestSetup static void setup(){
        //insert test data
        Account acct = TestData.createPersonAccount(true, 'testacct');

        Fact_Find__c factFind = TestData.createFactFind(true, acct.Id, 'testFactFind');
      
        Opportunity opp = TestData.createOpportunity(true, acct.Id);

        opp.Fact_Find__c = factFind.Id;

        update opp;

        insert new Trigger_Manager__c(Advice__c = true);

        Advice__c advice = TestData.createAdvice(true, opp.Id);
    }

    @isTest static void testLookupCalculatorForAdvice(){

        Advice__c advice = [SELECT Id FROM Advice__c LIMIT 1];

        Test.startTest();

        String result = LookupRollupCalculator.calculateRollupOfParentRecord(advice.Id);

        Test.stopTest();

        System.assertEquals(result, 'advice object updated');

    }
}