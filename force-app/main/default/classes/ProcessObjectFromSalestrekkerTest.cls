/*************************************************************************************************************
 * @name			ProcessObjectFromSalestrekkerTest
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			14th October 2021
 * @description		Test class for ProcessObjectFromSalestrekker
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-14      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
@isTest
public with sharing class ProcessObjectFromSalestrekkerTest {
    
    //setup method
    @TestSetup
    static void setup(){
        Account newAcc = TestData.createPersonAccount(true, 'Homer');
        Opportunity opp = TestData.createOpportunity(true, newAcc.Id); 
    }

    @IsTest static void testCreateOpportunities() {
		Account[] accountRec = [SELECT Id FROM Account LIMIT 1];

        Opportunity opp = new Opportunity();

        opp.Name = 'Test OPP';
        opp.Description = 'Test opp create';
        opp.AccountId = accountRec.get(0).Id;
        opp.RecordTypeId = ApexAkina_Constants.MORTGAGE_RECTYPE;
        opp.Type = ApexAkina_Constants.MORTGAGE;

        ProcessObjectFromSalestrekker.FlowInput input = new ProcessObjectFromSalestrekker.FlowInput();
        input.objectName = 'Opportunity';
        input.oppsToBeCreated = new List<Opportunity>();
        input.oppsToBeCreated.add(opp);

        List<ProcessObjectFromSalestrekker.FlowInput> inputs = new List<ProcessObjectFromSalestrekker.FlowInput> ();

		Test.startTest();

                ProcessObjectFromSalestrekker.processObjectFromSalestrekker(inputs);
         
        Test.stopTest();

         List<Opportunity> oppResults = [SELECT Name,Description  FROM Opportunity WHERE Name ='Test OPP'];

         System.assert(oppResults != null);
	}


    
    @IsTest static void TestCreateAccount() {
		
        Account account = new Account(
            RecordTypeId = ApexAkina_Constants.ACC_CLIENTRECTYPE,
            FirstName = 'TestAccount',
            LastName = 'Test LastName',
            PersonEmail = 'testAccount@testdata.co.nz',
            Partner_Status__pc = 'Primary Partner',
            Salestrekker_Contact_Id__c ='445f2dff-56ba-4cf4-94dd-82cf7de9d64d'
        );

        ProcessObjectFromSalestrekker.FlowInput input = new ProcessObjectFromSalestrekker.FlowInput();
        input.objectName = 'Account';
        input.accountToBeCreatedOrUpdated = account;

        List<ProcessObjectFromSalestrekker.FlowInput> inputs = new List<ProcessObjectFromSalestrekker.FlowInput> ();

		Test.startTest();

            ProcessObjectFromSalestrekker.processObjectFromSalestrekker(inputs);
         
        Test.stopTest();

         List<Account> accounts = [SELECT Name,Description  FROM Account WHERE Salestrekker_Contact_Id__c ='445f2dff-56ba-4cf4-94dd-82cf7de9d64d'];

         System.assert(accounts != null);
	}
}