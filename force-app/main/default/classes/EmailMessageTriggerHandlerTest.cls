/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Feb 4 2021
* @description Test class for KARTriggerHandlerTest class
*
* CHANGE LOG
*
**/
@isTest
public with sharing class EmailMessageTriggerHandlerTest {

    @TestSetup static void setup(){

        //insert test data
        Account acct = TestData.createPersonAccount(true, 'testacct');

        Fact_Find__c factFind = TestData.createFactFind(true, acct.Id, 'testFactFind');
      
        Opportunity opp = TestData.createOpportunity(true, acct.Id);

        opp.Fact_Find__c = factFind.Id;

        update opp;

        insert new Trigger_Manager__c(EmailMessage__c = true);

    }

    @isTest static void testSendEmail(){

        Opportunity opp = [SELECT Id FROM Opportunity];

        //Insert email message for opp

        EmailMessage email = new EmailMessage();
        email.FromAddress = 'tester1@test.tst';
        email.Incoming = true;
        email.ToAddress= 'tester2@test.tst';
        email.Subject = 'Apex Advice Appointment Confirmation';
        email.HtmlBody = 'Test email  htmlbody';
        email.RelatedToId = opp.Id; 

        Test.startTest();

        insert email;

        Test.stopTest();
        
        //file created as a result
        List<ContentDocument> cdList = [SELECT Id FROM ContentDocument];

        System.assertEquals(cdList.isEmpty(), false);

    }




}