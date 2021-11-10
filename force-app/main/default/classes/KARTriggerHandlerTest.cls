/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Nov 11, 2020
* @description Test class for KARTriggerHandlerTest class
*
* CHANGE LOG
*
**/
@isTest
public class KARTriggerHandlerTest {

    @TestSetup static void setup(){

        //insert test data
        Account acct = TestData.createPersonAccount(true, 'testacct');

        Account businessAcct = TestData.createBusinessAccount(true, 'test business acct');

        Fact_Find__c factFind = TestData.createFactFind(true, acct.Id, 'testFactFind');
      
        Opportunity opp = TestData.createOpportunity(true, acct.Id);

        opp.Fact_Find__c = factFind.Id;

        update opp;

        Policy__c policyRec = TestData.createPolicyWithProviderAndStatus(true, businessAcct.Id,'Existing');

        Policy_Benefit__c policyBenft = TestData.createPolicyBenefit(true, acct.Id,policyRec.Id);

        insert new Trigger_Manager__c(KAR__c = true, Advice__c = true);

        Advice__c advice = TestData.createAdvice(true, opp.Id);
    }


    @isTest static void testEditKAR(){

        List<KAR__c> karList = [SELECT Id, For_Who__c, Before__c, After__c, Approach__c FROM KAR__c];
        //edit KAR fields
        for(KAR__c kar : karList){
            kar.For_Who__c = 'testacct';
            kar.Before__c = 100;
            kar.After__c = 50;
            kar.Approach__c = 'Keep';
            kar.Status__c = 'Complete';
            kar.Provider_Name__c = 'AIA';
        }

        System.debug('\n\n\n kar list123'+karList);

        Test.startTest();

            update karList;

        Test.stopTest();
        
        Advice__c advice = [SELECT Id, KAR_Totals__c FROM Advice__c];

        System.assertEquals(String.isNotBlank(advice.KAR_Totals__c), true);

    }


     @isTest static void testDeleteKAR(){

        List<KAR__c> karList = [SELECT Id, For_Who__c, Before__c, After__c, Approach__c FROM KAR__c];
        //edit KAR fields
        for(KAR__c kar : karList){
            kar.For_Who__c = 'testacct';
            kar.Before__c = 100;
            kar.After__c = 50;
            kar.Approach__c = 'Keep';
            kar.Status__c = 'Complete';
            kar.Provider_Name__c = 'AIA';
        }

        update karList;

        Test.startTest();

           delete karList;

        Test.stopTest();
        
        Advice__c advice = [SELECT Id, KAR_Totals__c FROM Advice__c];

        System.assertEquals(String.isNotBlank(advice.KAR_Totals__c), true);

    }


    



}