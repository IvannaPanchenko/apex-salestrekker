/*************************************************************************************************************
 * @name			OpportunityServicesTest
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			14th October 2021
 * @description		Test class for OpportunityServices
 *
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-14      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
@isTest
public with sharing class OpportunityServicesTest {

     
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
        opp.Salestrekker_Deal_Id__c = '3d8d036b-7745-4e75-a41e-6182a390c566';

        List<Opportunity> opports = new List<Opportunity> ();
        opports.add(opp);

		Test.startTest();

            OpportunityServices.createOrUpdateOppFromSalestrekker(opports);
         
        Test.stopTest();

        //  List<Opportunity> oppResults = [SELECT Name, Description, Type  FROM Opportunity WHERE Name ='Test OPP'];

        //  System.assert(oppResult);
        

	}



    @IsTest static void testUpdateOpportunities() {
		Opportunity[] opps = [SELECT Id, StageName, Salestrekker_Deal_Id__c FROM Opportunity LIMIT 1];

        System.assert(opps != null); 
        opps.get(0).StageName = 'Application Submitted';
        opps.get(0).Salestrekker_Deal_Id__c = '3d8d036b-7745-4e75-a41e-6182a390c566';

		Test.startTest();

            OpportunityServices.createOrUpdateOppFromSalestrekker(opps);
         
        Test.stopTest();

         List<Opportunity> oppResults = [SELECT Name,Description,StageName, Salestrekker_Deal_Id__c  FROM Opportunity WHERE StageName ='Application Submitted'];

         System.assert(oppResults != null);
         System.assert(oppResults.get(0).Salestrekker_Deal_Id__c == '3d8d036b-7745-4e75-a41e-6182a390c566');
	}

}