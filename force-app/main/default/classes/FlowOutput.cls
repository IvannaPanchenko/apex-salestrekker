/*************************************************************************************************************
 * @name			FlowOutput
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			14th October 2021
 * @description		To recieve from flows that are not able to handle apex-defined inner class
 * @testClass       FlowOutput
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-14      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
global with sharing class FlowOutput {
 //Only for Opportunity
 //@InvocableVariable(Label='Opp Id' Description='Opp Id')
 @AuraEnabled
 global String oppId;
 // Only for accounts
 @AuraEnabled
 global String accountId;
 // Only for accounts
 @AuraEnabled
 global String salesTrekkerContactId;
 // Salestrakker Id
 @AuraEnabled
 global String salesTrekkerId;
 @AuraEnabled
 global Boolean success;
 @AuraEnabled
 global String errorMessage;

//label attributes
@AuraEnabled
global String labelName;
@AuraEnabled
global String oppType;
@AuraEnabled
global String RecordTypeId;



}