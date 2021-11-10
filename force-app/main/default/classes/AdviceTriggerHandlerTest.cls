/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Nov 11, 2020
* @description Test class for AdviceTriggerHandler class
*
* CHANGE LOG
*
**/
@isTest
public class AdviceTriggerHandlerTest {

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

        //Insert fact find
        Fact_Find__c factFind = TestData.createFactFind(true, newAcc.Id, 'testFactFind');

        Policy__c policy = TestData.createPolicy(false);

        policy.Policy_Status__c = 'Existing';

        insert policy;

        Policy_Benefit__c policyBenefit = TestData.createPolicyBenefit(true, newAcc.Id, policy.Id);

        //Insert new opportunity.
        Opportunity opp = TestData.createOpportunity(false, newAcc.Id);

        opp.Fact_Find__c = factFind.Id;

        insert opp;

        // Create new job application role
        Application_Role__c applicationRole = TestData.createApplicationRole(true, newAcc.Id, opp.Id);

        // insert new relationship
        Relationship__c relationship = TestData.createRelationship(true, newAcc.Id, newRelatedAcc.Id, 'Child', 'Yes');

        // insert new Employment
        Employment_Detail__c employmentDetail = TestData.createEmploymentDetail(true, newAcc.Id);

        // insert new other entity relationship
        Relationship__c otherEntity = TestData.createRelationship(true, newAcc.Id, legalEntity.Id, 'Trustee', 'No');

        // insert a goal
        Goal__c goal = TestData.createGoal(true, newAcc.Id);

        // insert a referral
        Referral__c referral = TestData.createReferral(true, newAcc.Id);

        insert new Trigger_Manager__c(Advice__c = true, Opportunity__c = true, KAR__c = true);

    }

    @isTest static void testCreateAdvice(){

        Opportunity opp = [SELECT Id FROM Opportunity];

        Test.startTest();
        //insert advice
        Advice__c advice = TestData.createAdvice(true, opp.Id);

        Test.stopTest();

        List<KAR__c> karList = [SELECT Id FROM KAR__c WHERE Advice__r.Opportunity__c =: opp.Id];

        System.assertNotEquals(karList.isEmpty(), true);

    }


}