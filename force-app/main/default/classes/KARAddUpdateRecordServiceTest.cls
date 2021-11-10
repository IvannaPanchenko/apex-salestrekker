/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Nov 11, 2020
* @description Test class for KARAddUpdateRecordServiceTest class
*
* CHANGE LOG
*
**/
@isTest
public class KARAddUpdateRecordServiceTest {

    @TestSetup static void setup(){
        //insert test data
        Account newAcc = TestData.createPersonAccount(false, 'tstacct');

        Account newAcc1 = TestData.createPersonAccount(true, 'otheraccttst123');

        newAcc.Partner__c = newAcc1.Id;

        insert newAcc;
        
        // insert related account
        Account newRelatedAcc = TestData.createBeneficiary(true, 'tstrelacct');

        // Insert legal entity
        Account legalEntity = TestData.createLegalEntityAccount(true);

        //Insert fact find, policy and policy benefit
        Fact_Find__c factFind = TestData.createFactFind(true, newAcc.Id, 'testFactFind');

        Policy__c policy = TestData.createPolicy(false);

        policy.Policy_Status__c = 'Existing';

        insert policy;

        Policy_Benefit__c policyBenefit = TestData.createPolicyBenefit(true, newAcc.Id, policy.Id);

        //Insert new opportunity.
        Opportunity opp = TestData.createOpportunity(false, newAcc.Id);

        opp.Fact_Find__c = factFind.Id;

        insert opp;

        // Create new job application role, new relationship and new employment detail
        Application_Role__c applicationRole = TestData.createApplicationRole(true, newAcc.Id, opp.Id);

        Relationship__c relationship = TestData.createRelationship(true, newAcc.Id, newRelatedAcc.Id, 'Child', 'Yes');

        Employment_Detail__c employmentDetail = TestData.createEmploymentDetail(true, newAcc.Id);

        Non_Apex_Cover__c nonApex = TestData.createNonApexCover(true, newAcc.Id);

        // insert new other entity relationship, goal and referral
        Relationship__c otherEntity = TestData.createRelationship(true, newAcc.Id, legalEntity.Id, 'Trustee', 'No');

        Goal__c goal = TestData.createGoal(true, newAcc.Id);

        Referral__c referral = TestData.createReferral(true, newAcc.Id);

        insert new Trigger_Manager__c(Advice__c = true, Opportunity__c = true, KAR__c = true);
        
        //insert advice 
        Advice__c advice = TestData.createAdvice(true, opp.Id);

    }

     @isTest static void testKAREditService(){

        Non_Apex_Cover__c nonApex = [SELECT Id, Value__c FROM Non_Apex_Cover__c LIMIT 1];
        //change sum
        nonApex.Value__c = 100;

        Test.startTest();

        update nonApex;

        Test.stopTest();

     }

      @isTest static void testKARAddService(){

        Account acct = [SELECT Id FROM Account WHERE LastName = 'tstacct'];

        Fact_Find__c factFind = [SELECT Id FROM Fact_Find__c];
        //insert products

        Test.startTest();

        Non_Apex_Cover__c nonApex = TestData.createNonApexCover(true, acct.Id);

        Policy__c policy = TestData.createPolicy(false);

        policy.Policy_Status__c = 'Existing';

        insert policy;

        Policy_Benefit__c policyBenefit = TestData.createPolicyBenefit(true, acct.Id, policy.Id);

        Test.stopTest();

        List<KAR__c> karList = [SELECT Id FROM KAR__c];

        System.assertEquals(karList.isEmpty(), false);

     }

}