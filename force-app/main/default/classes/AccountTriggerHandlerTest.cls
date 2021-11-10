/**
 * Description
 * TestClass for AccountTriggerHandler
 *
 * Note: Sharepoint Methods Test - SharepointIntegrationTest.cls
 * ServiceFields Methods Test - ChangeCategoryTest.cls 
 *
 * @author Jayson Faderanga
 * @date October 2018
 */
@isTest
public with sharing class AccountTriggerHandlerTest {
    private static final String PERSONNAME = 'PersonAccountTriggerHandlerTest';
    private static final String BUSINESSNAME = 'BusinessAccountTriggerHandlerTest';

    @testSetup static void setup() {
        insert new Trigger_Manager__c(
            Account__c = true
        );

    }

    @isTest static void dupeHandlerTestTotalAmtUpdate() {

        
        Id ACC_UNKNOWN_CLIENT_PERSON_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unknown Client').getRecordTypeId();
        Id ACC_UNKNOWN_BUSINESS_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unknown Business').getRecordTypeId();

        Account account = TestData.createBusinessAccount(false, BUSINESSNAME);
        account.Provider_Customer_Number__c = 'TESTID123456890';
        account.Created_By_Integration__c = true;

        Account partnerPerson = TestData.createPersonAccount(false, 'partner');
        partnerPerson.Provider_Customer_Number__c = 'TESTI5555';
        partnerPerson.Created_By_Integration__c = false;
        partnerPerson.RecordTypeId = ACC_UNKNOWN_CLIENT_PERSON_RT;
        insert partnerPerson;

        Account person = TestData.createPersonAccount(false, 'testestset');
        person.Provider_Customer_Number__c = 'TESTID0987654321';
        person.Created_By_Integration__c = true;
        person.RecordTypeId = ACC_UNKNOWN_CLIENT_PERSON_RT;
        person.Partner__c = partnerperson.Id;
        

        Test.startTest();
            insert account;
            insert person;

            Opportunity opp = TestData.createOpportunity(true, person.Id);

            Advice__c advice = TestData.createAdvice(true, opp.Id);
                
            Liability__c lb = TestData.createLiability(true,false); 
            Liability_Role__c lbRole = TestData.createLiabilityRole(true,lb.Id,person.Id);
            lbRole.Liability_Value__c = 500;
            update lbRole; 
                
            person = [SELECT Id, Total_Client_Liabilities__c FROM Account WHERE Id =: person.Id];
            update person;

        Test.stopTest();

        System.assertEquals(person.Total_Client_Liabilities__c, 500);

    }

    @isTest static void dupeHandlerTestNotDuplicate() {

            Id ACC_UNKNOWN_CLIENT_PERSON_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unknown Client').getRecordTypeId();
            Id ACC_UNKNOWN_BUSINESS_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unknown Business').getRecordTypeId();

            Account account = TestData.createBusinessAccount(false, BUSINESSNAME);
            account.Provider_Customer_Number__c = 'TESTID123456890';
            account.Created_By_Integration__c = true;

            Account person = TestData.createPersonAccount(false, 'testestset');
            person.Provider_Customer_Number__c = 'TESTID0987654321';
            person.Created_By_Integration__c = true;
            person.RecordTypeId = ACC_UNKNOWN_CLIENT_PERSON_RT;

            Test.startTest();
                insert account;
                insert person;
                Account[] aac = [select Id,Name,RecordTypeId from Account];
                account.Created_By_Integration__c = true;
                update person;
                account.Created_By_Integration__c = true;
                update person;
            Test.stopTest();       
    }

    @isTest static void dupeHandlerTestNotDuplicate2() {

            Id ACC_UNKNOWN_CLIENT_PERSON_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unknown Client').getRecordTypeId();
            Id ACC_UNKNOWN_BUSINESS_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unknown Business').getRecordTypeId();

            Account account = TestData.createBusinessAccount(false, BUSINESSNAME);
            account.Provider_Customer_Number__c = 'new233';
            account.Created_By_Integration__c = true;

            Account accoun2 = TestData.createBusinessAccount(false, 'businesstwo');
            accoun2.Provider_Customer_Number__c = 'new234';
            accoun2.Created_By_Integration__c = true;


            Customer_Provider_Code__c acp = new Customer_Provider_Code__c();
            acp.Name = 'new234';
            acp.Ext_Id__c = 'new234';
            acp.IsMaster__c = true;

            Account person = TestData.createPersonAccount(false, 'testestset');
            person.Provider_Customer_Number__c = 'ct123';
            person.Created_By_Integration__c = true;

            Customer_Provider_Code__c acp2 = new Customer_Provider_Code__c();
            acp2.Name = 'p1234';
            acp2.Ext_Id__c = 'p1234';
            acp2.IsMaster__c = true;

            Account person2 = TestData.createPersonAccount(false, 'person2');
            person.Provider_Customer_Number__c = 'p1234';
            person.Created_By_Integration__c = true;

            Test.startTest();
                insert account;
                acp.Customer__c = account.Id;
                insert acp;
                List<Account> nl = new List<Account>{accoun2};
                upsert nl Provider_Customer_Number__c;


                insert person;
                acp2.Customer__c = person.Id;
                List<Customer_Provider_Code__c> cpl = new List<Customer_Provider_Code__c>{acp2};
                upsert cpl Ext_Id__c;
                List<Account> nl2 = new List<Account>{person2};
                upsert nl2;

                //AccountTriggerHandler.isPersonValidForMatching(person2);

            Test.stopTest();
       
    }
}